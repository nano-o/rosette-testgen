#lang errortrace racket

;; Compiles an XDR specification to:
;; - A set of Racket definitions (constants and structs)
;; - TODO Lenses to manipulate the above
;; - A Rosette grammar
;; Reads an input specification in guile-rpc AST format; so, one must first pre-process an XDR specification with the guile-rpc XDR parser

;; XDR opaque fixed-length arrays become instances of -byte-array containing a bitvector
;; XDR non-opaque fixed-length arrays become Racket lists
;; XDR variable-length arrays become Racket vectors
;; XDR enums become Racket 32-bit bitvectors
;; XDR struct become struct with the same name except for the addition of the $ prefix
;; XDR unions become structs whose name is the name of the union prefixed by '+', with two members, tag and value, except when the tag is a boolean, in which case the union become an -optional struct
;; XDR constants get an associated symbol
;; Some of those representations were chosen for compatibility with the guile-rpc representation.
;; See the implementation of valid?/syntax
;; Only top-level enums are supported

;; We use the nanopass compiler framework

(provide
  ;; generates Racket definitions corresponding to an XDR specification
  ;; (constants, structs); a function `valid?-t`, for every type `t`, can be
  ;; used to check wether a Racket datum is valid with respect to the XDR
  ;; specification given
  xdr-types->racket
  xdr-types->grammar
  preprocess-ir
  max-depth)

(require
  nanopass
  racket/hash
  (only-in list-util zip)
  racket/syntax
  (only-in mischief/for for/dict)
  graph
  racket/generator
  (only-in rosette bitvector->natural)
  (for-template
    racket/base
    lens
    (only-in rosette bitvector bveq bv)))

(define-language L0
  ; This is a subset of the language of guile-rpc ASTs
  ; TODO what's not supported?
  (terminals
   (identifier (i))
   (constant (c))
   (value (v)) ; an identifier or a constant
   (void (void)))
  (XDR-Spec ()
            (def* ...))
  (Def (def) ; definition
       (define-type i type-spec)
       (define-constant i c))
  (Decl (decl)
        void
        (i type-spec))
  (Spec (type-spec)
        i
        (string c)
        (variable-length-array type-spec (maybe v))
        (fixed-length-array type-spec v)
        (enum (i* c*) ...)
        (struct decl* ...)
        (union union-spec))
  (Union-Spec (union-spec) ; NOTE cannot inline in Spec because of the "case" symbol
              (case (i1 i2)
                union-case-spec* ...))
  (Union-Case-Spec (union-case-spec)
                   ((v* ...) decl)
                   (else decl)))

(define constant? number?)
(define identifier? string?)
(define (value? o) (or (constant? o) (identifier? o)))
(define (value-or-false? o) (or (constant? o) (identifier? o) (equal? o #f)))
(define (void? x) (equal? x "void"))

(define-parser L0-parser L0)

(module+ test
  (require rackunit "read-datums.rkt")
  (define (gobble x) ; to have rackunit evaluate something without printing it
    (void))
  ;; we now define a few XDR specifications for use in tests
  (define test-xdr-spec-0 '((define-type "t" (union (case ("tag" "type") (("X") ("x" "tx")) (else ("y" "Y")))))))
  (define test-xdr-spec-1
    '((define-type "test-union"
        (union (case ("tagname" "tagtype")
                 (("A") ("c" (union (case ("tagname-2" "tagtype-2") (("X" "Y") ("x" "T"))))))
                 (("B" "C") ("d" "int")))))
      (define-type "test-struct"
        (struct ("t1" (union (case ("tagname-3" "tagtype-3") (("F" "G") ("y" "T")))))))))
  (define test-xdr-spec-2
    '((define-type "test-struct"
                   (struct ("t1" (enum ("A" 1)))))))
  (define test-xdr-spec-3
    '((define-type "t1" (enum ("A" 1)))))
  (define test-xdr-spec-4
    '((define-type "test-enum" (enum ("A" 1) ("B" 2))) (define-constant "C" 3)))
  (define test-xdr-spec-5
    '((define-type "my-enum" (enum ("A" 0) ("B" 1) ("C" 2)))
      (define-type "my-union" (union (case ("tag" "my-enum") (("A") ("i" "int")) ((1) ("j" "int")))))))
  (define test-xdr-spec-6
    '((define-type "my-enum" (enum ("A" 0) ("B" 1) ("C" 2)))
      (define-type "my-union" (union (case ("tag" "my-enum") (("A") ("i" "int")) (else ("j" "int")))))))
  (define test-xdr-spec-7
    '((define-type "my-enum" (enum ("A" 0) ("B" 1) ("C" 2)))
      (define-type "my-union" (union (case ("tag" "my-enum")
                                       (("A") ("i" "int"))
                                       (else ("j" (struct ("field1" "int") ("field2" "hyper")))))))))
  ;; the Stellar XDR spec:
  (define Stellar-xdr-types
    (read-datums "Stellar.xdr-types")))

(module+ test
    (test-case
     "parse simple examples"
        (gobble (L0-parser test-xdr-spec-0))
        (gobble (L0-parser test-xdr-spec-1)))
    (test-case
     "parser Stellar-xdr-types"
        (gobble (L0-parser Stellar-xdr-types)))
  (define Stellar-l0 (L0-parser Stellar-xdr-types)))

;; L0a simplifies L0 a bit by removing the superfluous Union-Spec production
(define-language L0a
  (extends L0)
  (Union-Spec (union-spec)
              (- (case (i1 i2) union-case-spec* ...)))
  (Spec (type-spec)
        (- (union union-spec))
        (+ (union (i1 i2) union-case-spec* ...))))

(define-pass simplify-union : L0 (ir) -> L0a ()
  (Spec : Spec (ir) -> Spec ()
        ((union (case (,i1 ,i2) ,[union-case-spec*] ...))
         `(union (,i1 ,i2) ,union-case-spec* ...))))

;; Add the default bool enum
(define-pass add-bool : L0a (ir) -> L0a ()
  (XDR-Spec : XDR-Spec (ir) -> XDR-Spec ()
            ((,def* ...)
             `(,def* ...
               ,(with-output-language (L0a Def) `(define-type "bool" (enum ("TRUE" 1) ("FALSE" 0))))))))

(module+ test
  (test-case
    "simplify-union"
    (check-equal?
      (simplify-union (L0-parser test-xdr-spec-0))
      (with-output-language
        (L0a XDR-Spec)
        `((define-type
            "t"
            (union
              ("tag" "type")
              (("X") ("x" "tx"))
              (else ("y" "Y"))))))))
    (test-case
     "run simplify-union on stellar spec"
        (gobble (simplify-union Stellar-l0)))
  (define Stellar-l0a (add-bool (simplify-union Stellar-l0))))

; throws an exception if there are any nested enums
; NOTE we produce L0a, even if we throw it away, so that the nanopass framework will synthesize most of the rules; otherwise it doesn't
(define-pass throw-if-nested-enum : L0a (ir) -> L0a ()
  (Def : Def (ir) -> Def ()
       ((define-type ,i (enum (,i* ,c*) ...)) ir))
  (Spec : Spec (ir) -> Spec ()
        ((enum (,i* ,c*) ...)
         (error "enums defined inside other types are not supported"))))

(module+ test
  (test-case
    "should throw on nested enum"
    (check-exn
      exn:fail?
      (λ ()
         (throw-if-nested-enum (simplify-union (L0-parser test-xdr-spec-2)))))
    (test-case
      "throw-if-nested-enum should not throw"
      (begin
        (gobble (throw-if-nested-enum (simplify-union (L0-parser test-xdr-spec-1))))
        (gobble (throw-if-nested-enum (simplify-union (L0-parser test-xdr-spec-3))))
        (gobble (throw-if-nested-enum Stellar-l0a))))))

; Here we collect top-level enum definitions in a hashmap
(define-pass enum-defs : L0a (ir) -> * (l)
  (XDR-Spec : XDR-Spec (ir) -> * (l)
            ((,[l*] ...) (apply hash-union l*)))
  (Def : Def (ir) -> * (l)
       ((define-type ,i (enum (,i* ,c*) ...)) (hash i (zip i* c*)))
       (else '#hash()))
  (invariant-assertion
    (hash/c string? list?)
    (XDR-Spec ir)))

(module+ test
  (test-case
    "enum-defs"
    (check-equal?
      (enum-defs (simplify-union (L0-parser test-xdr-spec-4)))
      '#hash(("test-enum" . (("A" . 1) ("B" . 2))))))
  (test-case
    "run enum-defs on Stellar spec"
    (gobble (enum-defs Stellar-l0a)))
  (define Stellar-enum-defs (enum-defs Stellar-l0a)))

; Next we normalize union specs.
; This means we flatten union specs (e.g. `(v1 v2) decl` becomes `(v1 decl) (v2
; delc)`) and we replace `else` by an explicit enumeration of all the remaining
; cases.

(define-language L1
  (extends L0a)
  (Union-Case-Spec (union-case-spec)
                   (- ((v* ...) decl)
                      (else decl))
                   (+ (v decl))))

;; replaces the else form in a union spec by a list of all cases it covers
(define/contract (replace-else tag-decl* enum-type)
  (-> (and/c dict? list?) list? (and/c dict? list?))
  (define tags (dict-keys tag-decl*))
  (define all-tags (dict-keys enum-type))
  (define else-tags (set-subtract all-tags (set-remove tags 'else)))
  (for/dict (dict-remove tag-decl* 'else)
      ([t else-tags])
    (values t (dict-ref tag-decl* 'else))))

(module+ test
  (test-case
    "replace-else"
    (define enum-type
      '(("A" . 1) ("B" . 2) ("C" . 3)))
    (define tag-decl*
      '(("A" . "int") (else . "hyper")))
    (check-equal?
      (make-hash (replace-else tag-decl* enum-type))
      (make-hash '(("A" . "int") ("B" . "hyper") ("C" . "hyper"))))))

(define-pass normalize-unions : L0a (ir enum-dict) -> L1 ()
  (Union-Case-Spec
    : Union-Case-Spec (ir) -> * (alist)
    (((,v* ...) ,[decl])
     (for/list ([v v*]) `(,v . ,decl)))
    ((else ,[decl]) `((else . ,decl))))
  (Spec
    : Spec (ir) -> Spec ()
    ((union (,i1 ,i2) ,[Union-Case-Spec : union-case-spec -> * alist*] ...)
     (define tag-decl* (apply append alist*))
     (when
       (and
         (dict-has-key? enum-dict i2) ; tag type is an enum type
         (ormap number? (dict-keys tag-decl*)))
       (error (format "numeric tag values not allowed in a union tagged by an enum type in: ~a" ir)))
     (define tag-decl-2*
       (if (dict-has-key? tag-decl* 'else)
         (if (not (dict-has-key? enum-dict i2))
           (error "else not allowed in union if tag type is not an enum")
           (replace-else tag-decl* (dict-ref enum-dict i2)))
         tag-decl*))
     (define tag* (map car tag-decl-2*))
     (define decl* (map cdr tag-decl-2*))
     `(union (,i1 ,i2) (,tag* ,decl*) ...))))

(module+ test
  (test-case
    "normalize-unions"
    (define enums (enum-defs (simplify-union (L0-parser test-xdr-spec-6))))
    (check-equal?
      (normalize-unions (simplify-union (L0-parser test-xdr-spec-6)) enums)
      (with-output-language (L1 XDR-Spec)
        `((define-type "my-enum" (enum ("A" 0) ("B" 1) ("C" 2)))
          (define-type
            "my-union"
            (union
              ("tag" "my-enum")
              ("A" ("i" "int"))
              ("C" ("j" "int"))
              ("B" ("j" "int"))))))))
  (test-case
    "throw on numeric tag value in union tagged by an enum type"
    (check-exn
      exn:fail?
      (λ ()
         (let* ([test-xdr-spec-5-L0 (simplify-union (L0-parser test-xdr-spec-5))]
                [test-xdr-spec-5-enums (enum-defs test-xdr-spec-5-L0)])
           (normalize-unions test-xdr-spec-5-L0 test-xdr-spec-5-enums)))))
  (test-case
    "run normalize-unions on Stellar spec"
    (gobble (normalize-unions Stellar-l0a Stellar-enum-defs)))
  (define Stellar-l1 (normalize-unions Stellar-l0a Stellar-enum-defs)))

;; Next we define a pass that changes the length of variable-length arrays as specified by the caller

(define (get-length overrides path len)
  (define key (reverse path))
  (cond
    [(dict-has-key? overrides key)
     (define ov (dict-ref overrides key))
     (if (eq? (car ov) 'len)
       (cdr ov)
       len)])
  len)

; overridess must be a dict mapping paths to natural numbers
; NOTE could be done in make-rule instead of rewriting L1
; TODO move to make-rule in order to support ranges
(define-pass override-lengths : L1 (ir overridess) -> L1 ()
  (Def : Def (ir) -> Def ()
       ((define-type ,i ,[Spec : type-spec (list i) -> type-spec2])
        `(define-type ,i ,type-spec2))
       (else ir))
  (Decl : Decl (ir path) -> Decl ()
        ((,i ,[Spec : type-spec (cons i path) -> type-spec2]) `(,i ,type-spec2))
        (else ir))
  (Spec : Spec (ir path) -> Spec ()
        ((struct ,[Decl : decl* path -> decl2*] ...) `(struct ,decl2* ...))
        ((union (,i1 ,i2) ,[Union-Case-Spec : union-case-spec* path -> union-case-spec2*] ...)
         `(union (,i1 ,i2) ,union-case-spec2* ...))
        ((variable-length-array ,type-spec ,v)
         (begin
           `(variable-length-array ,type-spec ,(get-length overridess path v))))
        (else ir))
  (Union-Case-Spec : Union-Case-Spec (ir path) -> Union-Case-Spec ()
                   ((,v ,[Decl : decl path -> decl2]) `(,v ,decl2))))

(define-language L2
  ; add path field to struct and union types
  (extends L1)
  (terminals
   (+ (path (p))))
  (Spec (type-spec)
        (- i)
        (- (union (i1 i2) union-case-spec* ...))
        (- (struct decl* ...))
        (- (variable-length-array type-spec (maybe v)))
        (+ (p i))
        (+ (union p (i1 i2) union-case-spec* ...))
        (+ (struct p decl* ...))
        (+ (variable-length-array p type-spec (maybe v)))))
(define path? list?) ; NOTE: this is part of the defintion of L2

(define-pass add-path : L1 (ir) -> L2 ()
  (Def
    : Def (ir) -> Def ()
    ((define-type ,i ,[Spec : type-spec0 (list i) -> type-spec1])
     `(define-type ,i ,type-spec1)))
  (Decl
    : Decl (ir p) -> Decl ()
    ((,i ,[Spec : type-spec0 (cons i p) -> type-spec1])
     `(,i ,type-spec1)))
  (Spec
    : Spec (ir p) -> Spec ()
    (,i `(,p ,i))
    ((union (,i1 ,i2) ,[Union-Case-Spec : union-case-spec0* p -> union-case-spec1*] ...)
     `(union ,p (,i1 ,i2) ,union-case-spec1* ...))
    ((string ,c) `(string ,c))
    ((variable-length-array ,[Spec : type-spec0 p -> type-spec1] ,v)
     `(variable-length-array ,p ,type-spec1 ,v))
    ((fixed-length-array ,[Spec : type-spec0 p -> type-spec1] ,v)
     `(fixed-length-array ,type-spec1 ,v))
    ((enum (,i* ,c*) ...) `(enum (,i* ,c*) ...))
    ((struct ,[Decl : decl0 p -> decl1] ...)
     `(struct ,p ,decl1 ...)))
  (Union-Case-Spec
    : Union-Case-Spec (ir p) -> Union-Case-Spec ()
    ((,v ,[Decl : decl0 p -> decl1])
     `(,v ,decl1))))

(define (l0->l2 l0)
  (define l0a
    (add-bool (throw-if-nested-enum (simplify-union l0))))
  (define l1
    (normalize-unions l0a (enum-defs l0a)))
  (add-path l1))

(module+ test
  (test-case
    "l0->l2"
    (check-equal?
      (l0->l2 (L0-parser test-xdr-spec-7))
      (with-output-language (L2 XDR-Spec)
        (let* ([my-union-path '("my-union")]
               [my-struct-path '("j" "my-union")]
               [field-1-path '("field1" "j" "my-union")]
               [field-2-path '("field2" "j" "my-union")]
               [union-A-path '("i" "my-union")]
               [my-struct (with-output-language (L2 Spec) `(struct ,my-struct-path ("field1" (,field-1-path "int")) ("field2" (,field-2-path "hyper"))))])
          `((define-type "my-enum" (enum ("A" 0) ("B" 1) ("C" 2)))
            (define-type
              "my-union"
              (union
                ,my-union-path
                ("tag" "my-enum")
                ("A" ("i" (,union-A-path "int")))
                ("C" ("j" ,my-struct))
                ("B" ("j" ,my-struct))))
            (define-type "bool" (enum ("TRUE" 1) ("FALSE" 0))))))))
  (test-case
    "run add-path on Stellar spec"
    (gobble (add-path Stellar-l1)))
  (define Stellar-l2 (add-path Stellar-l1)))

;; returns a hashmap mapping top-level enum symbols and constants to values
;; TODO add path in var-length array
(define-pass consts-hashmap : L2 (ir) -> * (h)
  (XDR-Spec : XDR-Spec (ir) -> * (h)
            ((,[h*] ...) (apply hash-union h*)))
  (Def : Def (ir) -> * (h)
        ((define-type ,i ,[h]) h)
        ((define-constant ,i ,c) (hash i c)))
  (Spec : Spec (ir) -> * (h)
        ((enum (,i* ,c*) ...)
         (for/hash ([i i*] [c c*])
           (values i c)))
        (else (hash)))
  (invariant-assertion
    (hash/c string? number?)
    (XDR-Spec ir)))

(module+ test
  (test-case
    "consts-hashmap"
    (begin
      (check-equal?
        (consts-hashmap (l0->l2 (L0-parser test-xdr-spec-3)))
        '#hash(("A" . 1) ("FALSE" . 0) ("TRUE" . 1)))
      (check-equal?
        (consts-hashmap (l0->l2 (L0-parser test-xdr-spec-4)))
        '#hash(("A" . 1) ("B" . 2) ("C" . 3) ("FALSE" . 0) ("TRUE" . 1)))
      (gobble (consts-hashmap Stellar-l2)))))

;; Make constant definitions:
(define/contract
  (constant-definitions stx h)
  (-> syntax? (hash/c string? number?) syntax?)
  (define defs
    (for/list ([(k v) (in-dict h)])
      #`(define #,(format-id stx k) #,v)))
  #`(#,@defs))

(module+ test
  (test-case
    "no exn"
    (gobble (constant-definitions #'() (consts-hashmap Stellar-l2))))
  (define Stellar-const-defs (constant-definitions #'() (consts-hashmap Stellar-l2))))


; collect all type defs in a hashmap
(define-pass collect-types : L2 (ir) -> * (h)
  (XDR-Spec : XDR-Spec (ir) -> * (h)
            ((,[def*] ...) (apply hash-union def*)))
  (Def : Def (ir) -> * (h)
       ((define-type ,i ,type-spec) (hash i type-spec))
       ((define-constant ,i ,c) (hash)))
  (invariant-assertion
    (hash/c string? (const #t))
    (XDR-Spec ir)))

(module+ test
  (test-case
    "collect-types"
    (gobble (collect-types Stellar-l2)))
  (define Stellar-types (collect-types Stellar-l2)))

(define base-types '("opaque" "void" "int" "unsigned int" "hyper" "unsigned hyper"))
(define (base-type? t)
  (set-member? base-types t))

;; Next we compute the (non-base) type symbols that a type definition depends on.
(define-pass immediate-deps : (L2 Spec) (ir) -> * (d)
  ; all the types the given type spec depends on
  (Spec : Spec (ir) -> * (d)
        ((,p ,i) (if (base-type? i) (set) (set i)))
        ((variable-length-array ,p ,[d] ,v) d)
        ((fixed-length-array ,[d] ,v) d)
        ((struct ,p ,[d*] ...) (apply set-union d*))
        ((union ,p (,i1 ,i2) ,[d*] ...)
         (define tag-type
           (if (base-type? i2) (set) (set i2)))
         (apply set-union (cons tag-type d*)))
        (else (set)))
  (Decl : Decl (ir) -> * (d)
        ((,i ,[d]) d)
        (else (set)))
  (Union-Case-Spec : Union-Case-Spec (ir) -> * (d)
                   ((,v ,[d]) d))
  (invariant-assertion
    (set/c string?)
    (Spec ir)))

(module+ test
  (test-case
    "immediate-deps of LedgerKey"
  (define LedgerKey-deps (immediate-deps (hash-ref Stellar-types "LedgerKey")))
  (check-equal?
    LedgerKey-deps
    (set "LedgerEntryType" "PoolID" "string64" "TrustLineAsset" "ClaimableBalanceID" "AccountID" "int64"))))

(define/contract (type-graph-edges h)
  (-> hash? (*list/c (list/c string? string?)))  ; returns a list of edges
  (apply
    append
    (for/list ([(k v) (in-hash h)])
      (define deps (set->list (immediate-deps v)))
      (map (λ (d) (list k d)) deps))))

(define/contract (deps-graph h)
  (-> hash? unweighted-graph?)
  (let ([edges (type-graph-edges h)])
    (unweighted-graph/directed edges)))

(define/contract (deps h t)
  (-> hash? string? (set/c string?))
  (define g (deps-graph h))
  (cond
    [(has-vertex? g t)
     (do-bfs
       g ; the graph
       t ; the source of the bfs
       #:init (set)
       #:visit: (set-add $acc $v))]
    [else (set)]))

(module+ test
  (test-case
    "deps"
    (check-equal?
      (deps Stellar-types "TrustLineAsset")
      (set "PoolID" "PublicKeyType" "AssetType" "AccountID" "PublicKey" "TrustLineAsset" "AssetCode12" "AlphaNum12" "AlphaNum4" "uint256" "Hash" "AssetCode4"))))

(define (min-depth h t)
  ; the minimum depth to cover the graph
  (let-values ([(a _) (bfs (deps-graph h) t)])
    (define reachable
      (for/fold ([acc null])
        ([(k v) (in-hash a)])
        (if (equal? v +inf.0)
          acc
          (cons (cons k v) acc))))
    (cdr (argmax (λ (p) (cdr p)) reachable))))

(module+ test
  (test-case
    "min-depth"
    (check-equal?
      (min-depth Stellar-types "TransactionEnvelope")
      7)))

; max depth without recursing:
(define (max-depth xdr-types)
  (let ([h (collect-types (l0->l2 (L0-parser xdr-types)))])
    (define g (deps-graph h))
    (define-vertex-property g max-depth)
    (do-dfs
      g
      #:epilogue:
        (begin
          (define ns (get-neighbors g $v))
          (cond
            [(null? ns) (max-depth-set! $v 1)]
            [else
              (define (get-depth v)
                (if (max-depth-defined? v) (max-depth v) 0))
              (define m (apply max (map get-depth ns)))
              (max-depth-set! $v (+ m 1))]))
      (max-depth->hash))))

(module+ test
  (test-case
    "max-depth"
    (check-equal?
      (dict-ref (max-depth Stellar-xdr-types) "AccountEntry")
      7)))

(define/contract (recursive-types h t)
  (-> hash? string? set-mutable?)
  ; returns the set of types that are recursive
  (define g (deps-graph h))
  (define rec-types (mutable-set))
  (define-vertex-property g path)
  (do-bfs
    g
    t
    #:init (path-set! t null)
    #:on-enqueue: (path-set! $v (cons $from (path $from)))
    #:visit?:
      (begin
        (define seen (set-member? (path $from) $v))
        (when seen (set-add! rec-types $v))
        (not seen)))
  rec-types)

(module+ test
  (test-case
    "recursive-types"
    (check-equal?
      (recursive-types Stellar-types "TransactionEnvelope")
      (mutable-set))))

; Next we define needed Racket struct types

(define (make-struct-type ctx name fields) ; name and fields as strings
  (let ([field-names (for/list ([f fields])
                       (format-id ctx "~a" f))])
        #`(struct/lens #,(format-id ctx "~a" name) #,field-names #:transparent)))

(module+ test
  (test-case
    "make struct type"
         (gobble (make-struct-type #'() "my-struct" '("field1" "field2")))))

(define/contract (struct-name path)
  (-> (and/c (listof string?) (not/c null?)) string?)
  (string-append "$" (string-join (reverse path) "::")))

(define/contract (union-struct-name path)
  (-> (and/c (listof string?) (not/c null?)) string?)
  (string-append "+" (string-join (reverse path) "::")))

(module+ test
  (check-equal? (struct-name '("c" "b" "a")) "$a::b::c")
  (check-equal? (struct-name '("c")) "$c"))

;; define struct types for nested structs
(define-pass make-struct-types : (L2 Spec) (ir stx) -> * (sts)
  (Spec
    : Spec (ir) -> * (sts)
    ((,p ,i) (hash))
    ((string ,c) (hash))
    ((variable-length-array ,p ,[sts] ,v) sts)
    ((fixed-length-array ,[sts] ,v) sts)
    ((enum (,i* ,c*) ...) (hash))
    ; The problem is that guile-rpc transforms optionals into normal unions.
    ; For now we assume that any union with bool tag is in fact an optional.
    ((union ,p (,i1 ,i2) ,[sts*] ...)
     (define rest (apply hash-union sts*))
     (cond
       [(equal? i2 "bool") rest]
       [else
         (define t (make-struct-type stx (union-struct-name p) '("tag" "value")))
         (hash-union (hash (struct-name p) t) rest)]))
    ((struct ,p ,decl* ...)
     (define (->pair decl)
       (nanopass-case
         (L2 Decl)
         decl
         ((,i ,type-spec) (cons i type-spec))
         (else #f)))
     (define decl-pairs (filter identity (map ->pair decl*)))
     (define fields (map car decl-pairs))
     (define specs (map cdr decl-pairs))
     (define the-struct (make-struct-type stx (struct-name p) fields))
     (define rest (apply hash-union (map (λ (s) (Spec s)) specs)))
     (hash-union rest (hash (struct-name p) the-struct))))
  (Decl
    : Decl (ir) -> * (sts)
    ((,i ,[sts]) sts)
    (else (hash)))
  (Union-Case-Spec
    : Union-Case-Spec (ir) -> * (sts)
    ((,v ,[sts]) sts))
  (invariant-assertion
    (hash/c string? syntax?)
    (Spec ir)))

(module+ test
  (test-case
    "make struct types"
      (gobble (make-struct-types (hash-ref Stellar-types "ManageOfferSuccessResult") #'()))
      (gobble (make-struct-types (hash-ref Stellar-types "TransactionEnvelope") #'()))
      (gobble (make-struct-types (hash-ref Stellar-types "LiquidityPoolEntry") #'()))))

(define/contract (make-struct-types/rec stx h ts)
  (-> syntax? hash? (*list/c string?) (hash/c string? syntax?))
  (define ts-deps
    (apply
      set-union
      (for/list ([t ts])
        (deps h t))))
  (apply
    hash-union
    (for/list ([t (in-set (set-union (list->set ts) ts-deps))])
      (make-struct-types (hash-ref h t) stx))))

(module+ test
  (test-case
    "make-struct-types/rec test"
    (gobble
      (make-struct-types/rec
        #'()
        Stellar-types
        (hash-keys Stellar-types)))))

(define (built-in-structs stx)
  ; we can use union as it cannot be used as an identifier as per RFC4506
  ; we can also use a prefix like _ or -, which again cannot be used at the beginning of an identifier as per RFC4506
  (list
   (make-struct-type stx "-byte-array" '("value"))
   (make-struct-type stx "-optional" '("present" "value"))))

;; Next we generate a function that checks the conformance of data to an xdr spec

(define/contract (with-error fn type-name)
  (-> syntax? string? syntax?)
  #`(λ (d)
       (or
         (#,fn d)
         (raise-user-error
           (format
             (string-append "invalid " #,type-name ": ~a")
             d)))))

(define-pass valid?/syntax : L2 (t types consts-h ctx) -> * (stx)
  (Spec
    : Spec (t) -> * (stx)

    ((,p ,i)
     (cond
       [(not (base-type? i))
        (format-id ctx "~a-valid?" i)]
       [(equal? i "opaque")
        (with-error #`(bitvector 8) "opaque")]
       [(set-member? '("int" "unsigned int") i)
        (with-error #`(bitvector 32) "int")]
       [(set-member? '("hyper" "unsigned hyper") i)
        (with-error #`(bitvector 64) "hyper")]
       [else (error (format "this is a bug: case missing for base type ~a" i))]))

    ((string ,c)
     (with-error #`(λ (d) (and (vector? d) (<= (vector-length d) #,c))) "string"))

    ((variable-length-array ,p ,[stx] ,v)
     (define len
       (if v
         (if (number? v) v (hash-ref consts-h v))
         v))
     (define the-check
       #`(λ (d)
            (and
              (vector? d)
              (when #,len (<= (vector-length d) #,len))
              (for/and ([e (in-vector d)])
                (#,stx e)))))
     (with-error the-check "variable-length array"))

    ((fixed-length-array ,type-spec ,v)
     (define len
       (if (number? v) v (hash-ref consts-h v)))
     (define the-check
       (cond
         [(nanopass-case
            (L2 Spec)
            type-spec
            [(,p ,i) (equal? i "opaque")]
            [else #f])
          #`(λ (d)
               (and
                 (#,(format-id ctx "-byte-array?") d)
                 ((bitvector #,(* v 8)) (#,(format-id ctx "-byte-array-value") d))))]
         [else
           (define elem-valid? (Spec type-spec))
           #`(λ (d)
                (and
                  (vector? d)
                  (equal? (vector-length d) #,v)
                  (for/and ([e (in-vector d)])
                    (#,elem-valid? e))))]))
     (with-error the-check "fixed-length array"))

    ((enum (,i* ,c*) ...)
     (define the-check
       #`(λ (d)
            (and
              ((bitvector 32) d)
              (for/or ([v (list #,@c*)])
                (bveq d (bv v 32))))))
     (with-error the-check "enum"))

    ((struct ,p ,decl* ...)
     (define type-check
       #`(λ (d)
            (#,(format-id ctx "~a?" (struct-name p)) d)))
     (define struct-type-valid?
       (with-error type-check (format "struct type ~a" (struct-name p))))
     (define (field-valid? decl)
       (nanopass-case
         (L2 Decl)
         decl
         ((,i ,type-spec)
          (define type-valid? (Spec type-spec))
          (define accessor
            (format-id ctx "~a-~a" (struct-name p) i))
          #`(λ (d)
               (#,type-valid? (#,accessor d))))
         (,void (error "void struct member not supported"))))
     #`(λ (d)
          (and
            (#,struct-type-valid? d)
            #,@(for/list ([f decl*])
                 #`(#,(field-valid? f) d)))))

    ((union ,p (,i1 ,i2) ,[case-test*] ...)
     (define tag-getter
       (if (equal? i2 "bool")
         (format-id ctx "-optional-present")
         (format-id ctx "~a-tag" (union-struct-name p))))
     (define value-getter
       (if (equal? i2 "bool")
         (format-id ctx "-optional-value")
         (format-id ctx "~a-value" (union-struct-name p))))
     (define tag-valid?
       (with-error #'(bitvector 32) "union tag"))
     #`(λ (d)
          (and
            (#,tag-valid? (#,tag-getter d))
            (for/or ([c (list #,@case-test*)])
              (c (#,tag-getter d) (#,value-getter d)))))))

  (Union-Case-Spec
    : Union-Case-Spec (t) -> * (stx)
    ((,v ,decl)
     (define tag
       (if (number? v) v (hash-ref consts-h v)))
     (define check-value
       (nanopass-case
         (L2 Decl)
         decl
         ((,i ,type-spec)
          (Spec type-spec))
         (,void #'null?)))
     #`(λ (tag value)
          (and
            (bveq tag (bv #,tag 32))
            (#,check-value value)))))

  (begin
    (define fn-id (format-id ctx "~a-valid?" t))
    (define type-rep (if (base-type? t) t (hash-ref types t)))
    #`(define (#,fn-id data) (#,(Spec type-rep) data))))

(module+ test
  (test-case
    "valid?/syntax tests"
    (begin
      (gobble (valid?/syntax "PublicKey" Stellar-types (consts-hashmap Stellar-l2) #'())))))

(define (preprocess-ir xdr-spec)
  (define l2 (l0->l2 (L0-parser xdr-spec)))
  (define types-h (collect-types l2))
  (define consts-h (consts-hashmap l2))
  `((types . ,types-h)
    (consts . ,consts-h)))

; this produces a syntax object
(define/contract (xdr-types->racket stx consts types ts)
  (-> syntax? hash? hash? (*list/c string?) syntax?)
  (define const-defs (constant-definitions stx consts))
  (define struct-defs (hash-values (make-struct-types/rec stx types ts)))
  (define all-deps
    (for/fold ([acc (set)] #:result acc)
              ([t ts])
      (set-union acc (deps types t))))
  (define valid?-defs
    (for/list ([t all-deps])
      (valid?/syntax t types consts stx)))
  #`(begin
      #,@const-defs
      #,@struct-defs
      #,@(built-in-structs stx)
      #,@valid?-defs))

(module+ test
  (match-define
    `((types . ,types) (consts . ,consts))
    (preprocess-ir Stellar-xdr-types))
  (test-case
    "run xdr-types->racket on Stellar"
    (gobble (xdr-types->racket #'() consts types '("TransactionEnvelope")))
    (gobble (xdr-types->racket #'() consts types '("SCPQuorumSet")))))

;; Generate grammar rules

(define/contract (size->number consts size)
  (-> (hash/c string? number?) (or/c number? string? boolean?) (or/c boolean? number?))
  (if (string? size)
    (hash-ref consts size)
    size))

(define (make-sequence stx seq-t elem-type-rule-thunk size)
  ; seq-t is list or vector
  ; elem-type-rule produces syntax or string
  ; size is a numeric value
  #`(#,seq-t
     #,@(for/list ([i (in-range size)]) (elem-type-rule-thunk))))

(define (make-list stx consts elem-type-rule-thunk size)
  (let ([n (size->number consts size)])
    (make-sequence stx #'list elem-type-rule-thunk n)))

(define max-seq-len 3) ; we never make variable-length sequences bigger than that
;; TODO move to overrides

(define (make-vector stx consts elem-type-rule-thunk size) ; variable-size array
  (let ([n (size->number consts size)])
    (let ([m (if (or (not n) (> n max-seq-len)) max-seq-len n)])
      (make-sequence stx #'vector elem-type-rule-thunk m))))

; generate unique indices (used to generate unique slocs)
(define get-index!
  (generator
    ()
    (let loop ([index 0])
      (yield index)
      (loop (+ index 1)))))

; generate an identifier for a grammar rule:
(define (format-id/unique-sloc str [stx #f])
  ; Rosette seems to be relying on source-location information to create symbolic variable names.
  ; Since we want all grammar holes to be independent, we need to use a unique location each time.
  ; This is only useful if using the grammar generator in a macro.
  (format-id stx "~a" str #:source (make-srcloc (format "generated-sloc:~a" (get-index!)) 1 0 1 0)))

; make a hole for a particular type name (provided as a string)
(define (rule-hole str)
  #`(#,(format-id/unique-sloc (string-append str "-rule")))) ; TODO: unique-loc not needed anymore since we call instantiate-rule later?

(define (value-rule stx v)
  (if (string? v)
    (format-id/unique-sloc v stx) ; TODO unique-loc needed?
    v))

(require
  "strkey-utils.rkt")

(define-pass make-rule : (L2 Spec) (ir stx type-name consts overrides) -> * (grammar)
  ; For use as a macro, we need unique source locations for each sub-rule invocation
  ; (this does include rules of the form (?? bitvector 32))
  ; That's why we produce thunks; new slocs will be generated each time we call a thunk.
  (Spec
    : Spec (ir) -> * (rule-thunk)

    [(,p ,i)
     (define key (reverse p))
     (cond
       [(and
          (dict-has-key? overrides key)
          (eq? (car (dict-ref overrides key)) 'key-set))
        (define vals
          (map
            (compose bitvector->natural strkey->bv)
            (cdr (dict-ref overrides key))))
        (define byte-arrays
          (map
            (λ (v) #`(#,(format-id stx "-byte-array") (bv #,v 256)))
            vals))
        (thunk #`(choose #,@byte-arrays))]
       [else
         (case i
           [("opaque") (thunk #`(#,(format-id/unique-sloc "??" #'()) (bitvector 8)))]
           [("int" "unsigned int") (thunk #`(#,(format-id/unique-sloc "??" #'()) (bitvector 32)))]
           [("hyper" "unsigned hyper") (thunk #`(#,(format-id/unique-sloc "??" #'()) (bitvector 64)))]
           [else (thunk (rule-hole i))])])]

    [(struct ,p ,[rule-thunk*] ...)
     (define name
       (format-id/unique-sloc (struct-name p) stx))
     (thunk #`(#,name #,@(map (λ (f) (f)) rule-thunk*)))]

    [(string ,c)
     (thunk (make-vector stx consts (thunk #`(#,(format-id/unique-sloc "??" #'()) (bitvector 8))) c))]

    [(variable-length-array ,p ,[elem-rule-thunk] ,v)
     (define key (reverse p))
     (define len
       (cond
         [(and
            (dict-has-key? overrides key)
            (eq? (car (dict-ref overrides key)) 'len))
          (cdr (dict-ref overrides key))]
         [else v]))
     (thunk (make-vector stx consts elem-rule-thunk len))]

    [(fixed-length-array ,type-spec ,v)
     ; special case for opaque fixed-length arrays: we use -byte-array
     (guard
       (nanopass-case
         (L2 Spec)
         type-spec
         [(,p ,i) (equal? i "opaque")]
         [else #f]))
     (define n (size->number consts v))
     (thunk
       #`(
          #,(format-id stx "-byte-array")
          (#,(format-id/unique-sloc "??" #'()) (bitvector #,(* n 8)))))]

    [(fixed-length-array ,[elem-rule-thunk] ,v)
     (thunk (make-list stx consts elem-rule-thunk v))]

    [(enum (,i* ,c*) ...)
     (define bv* (map (λ (i) (value-rule stx i)) i*))
     (if (> (length bv*) 1)
       (thunk #`(choose #,@bv*))
       (thunk (car bv*)))]

    [(union ,p (,i1 ,i2) ,[Union-Case-Spec : union-case-spec -> thunk-1* thunk-2*] ...)
     (define the-struct
       (if (equal? i2 "bool")
         (format-id stx "-optional")
         (format-id stx (union-struct-name p))))
     (thunk
       (if (> (length thunk-1*) 1)
         #`(choose
             #,@(for/list
                  ([thunk-1 thunk-1*]
                   [thunk-2 thunk-2*])
                  #`(#,the-struct #,(thunk-1) #,(thunk-2))))
         #`(#,the-struct #,((car thunk-1*)) #,((car thunk-2*)))))])

  (Union-Case-Spec
    : Union-Case-Spec (ir) -> * (thunk-1 thunk-2)
    [(,v ,[rule-thunk])
     (values
       (thunk
         #`(bv #,(value-rule stx v) 32))
       rule-thunk)])

  (Decl
    : Decl (ir) -> * (rule-thunk)
    [(,i ,[rule-thunk]) rule-thunk]
    [,void (thunk #'null)])

  #`(
     #,(format-id/unique-sloc (string-append type-name "-rule"))
     #,((Spec ir))))

(module+ test
  (define test-overrides
    '((("Transaction" "operations") len . 1)
      (("TestLedger" "ledgerEntries") len . 2)
      (("MuxedAccount" "ed25519")
       key-set
       "GAD2EJUGXNW7YHD7QBL5RLHNFHL35JD4GXLRBZVWPSDACIMMLVC7DOY3"
       "GBASB5IEQQHYEVWJXTG6HVQR62FNASTOXMEGL4UOUQVNKDLR3BN2HIJL")))
  (define ts '("TransactionEnvelope" "SCPQuorumSet"))
  (test-case
    "run make-rule on Stellar"
    (begin
      (define all-deps
        (for/fold ([acc (set)] #:result acc)
          ([t ts])
          (set-union acc (deps Stellar-types t))))
      (for ([t all-deps])
        (gobble (make-rule (hash-ref Stellar-types t) #'() t (consts-hashmap Stellar-l2) test-overrides))))))

(define/contract (xdr-types->grammar stx consts types ts overrides)
  (-> syntax? hash? hash? (*list/c string?) list? syntax?)
  (for ([t ts])
    (define rec-types (recursive-types types t))
    (when (not (set-empty? rec-types))
      (for ([t rec-types])
        (displayln (format "WARNING: recursive type detected: ~a" t)))))
  (define all-deps
    (for/fold ([acc (set)] #:result acc)
      ([t ts])
      (set-union acc (deps types t))))
  (define rules
    (for/list ([t all-deps])
      (make-rule (hash-ref types t) stx t consts overrides)))
  #`(begin
      (define-grammar
        (#,(format-id stx "~a" "the-grammar")) #,@rules)))

(module+ test
  (test-case
    "run xdr-types->grammar on Stellar"
    (gobble (xdr-types->grammar #'() consts types '("TransactionEnvelope") test-overrides))))
