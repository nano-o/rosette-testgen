#lang errortrace racket

; Compiles an XDR specification to:
; - A set of Racket definitions (constants and structs)
; - Lenses to manipulate the above
; Reads an input specification in guile-rpc AST format; so, one must first pre-process an XDR specification with the guile-rpc XDR parser

; XDR opaque fixed-length arrays become instances of -byte-array containing a bitvector
; XDR non-opaque fixed-length arrays become Racket lists
; XDR variable-length arrays become Racket vectors
; XDR enums become Racket 32-bit bitvectors
; XDR unions become structs with two members, tag and value, except when the tag is a boolean, in which case the union become an -optional struct
; XDR constants get an associated symbol
; Some of those representations were chosen for compatibility with the guile-rpc representation.
; See the implementation of valid?/syntax

; We use the nanopass compiler framework

; TODO use lenses to allow writing functional specifications; first try it on the merge demo.
; TODO there's pretty much no error checking
; TODO write tests
; TODO a pass to remove recursion or limit its depth (ClaimPredicate)? For now I manually removed the recursion from the XDR spec.
; TODO a way to check that a Racket structure conforms to an XDR spec

(provide
  ; generates Racket definitions corresponding to an XDR specification (constants and structs) and a
  ; function `valid?` that can be used to check wether a Racket datum is valid with respect to the XDR
  ; specification given
  xdr-types->racket
  ; computes the maximum depth of an XDR specification (useful to generate grammars; TODO move to the
  ; grammar-generator module)
  max-depth)

(require
  nanopass
  racket/hash
  (only-in list-util zip)
  racket/syntax
  graph
  (for-template
    racket/base
    lens
    (only-in rosette bitvector bveq)))

(module+ test
  (require rackunit "read-datums.rkt")
  (define Stellar-xdr-types
    (read-datums "Stellar.xdr-types"))
  (define (gobble x) ; to have rackunit evaluate something without printing it
    (void)))

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
  (define test-0 '((define-type "t" (union (case ("tag" "type") (("X") ("x" "tx")) (else ("y" "Y")))))))
  (define test-1
    '((define-type "test-union"
        (union (case ("tagname" "tagtype")
                 (("A") ("c" (union (case ("tagname-2" "tagtype-2") (("X" "Y") ("x" "T"))))))
                 (("B" "C") ("d" "int")))))
      (define-type "test-struct"
        (struct ("t1" (union (case ("tagname-3" "tagtype-3") (("F" "G") ("y" "T")))))))))
    (test-case
     "parse simple examples"
        (gobble (L0-parser test-0))
        (gobble (L0-parser test-1)))
    (test-case
     "parser Stellar-xdr-types"
        (gobble (L0-parser Stellar-xdr-types)))
  (define Stellar-l0 (L0-parser Stellar-xdr-types)))

; L0a simplifies L0 a bit by removing the superfluous Union-Spec production

(define-language L0a
  ; TODO how to remove Union-Spec entirely?
  (extends L0)
  (Spec (type-spec)
        (- (union union-spec))
        (+ (union (i1 i2) union-case-spec* ...))))

(define-pass simplify-union : L0 (ir) -> L0a ()
  (Spec : Spec (ir) -> Spec ()
        ((union (case (,i1 ,i2) ,[union-case-spec*] ...))
         `(union (,i1 ,i2) ,union-case-spec* ...))))

; Next we add the default bool enum
; This is a little awkward
(define-pass add-bool : L0a (ir) -> L0a ()
  (XDR-Spec : XDR-Spec (ir) -> XDR-Spec ()
            ((,def* ...)
             `(,def* ...
               ,(with-output-language (L0a Def) `(define-type "bool" (enum ("TRUE" 1) ("FALSE" 0))))))))

; does not work:
; (define-language-node-counter L0-counter L0)

(module+ test
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
  (define test-2
    '((define-type "test-struct"
                   (struct ("t1" (enum ("A" 1)))))))
  (define test-3
    '((define-type "t1" (enum ("A" 1)))))
  (test-case
    "should throw on nested enum"
    (check-exn
      exn:fail?
      (λ ()
         (throw-if-nested-enum (simplify-union (L0-parser test-2)))))
    (test-case
      "should not throw"
      (begin
        (gobble (throw-if-nested-enum (simplify-union (L0-parser test-1))))
        (gobble (throw-if-nested-enum (simplify-union (L0-parser test-3))))
        (gobble (throw-if-nested-enum Stellar-l0a))))))

; returns a hashmap mapping top-level enum symbols and constants to values
(define-pass make-consts-hashmap : L0a (ir) -> * (h)
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
  (XDR-Spec ir))

(module+ test
  (define test-4
    '((define-type "test-enum" (enum ("A" 1) ("B" 2))) (define-constant "C" 3)))

  (test-case
    "no exn"
    (begin
      (gobble (make-consts-hashmap (simplify-union (L0-parser test-3))))
      (gobble (make-consts-hashmap (simplify-union (L0-parser test-4))))
      (gobble (make-consts-hashmap Stellar-l0a)))))

; Make constant definitions:

(define (constant-definitions stx h)
  ; expects a hashmap mapping identifiers to values
  (let ([defs
          (for/list ([(k v) (in-dict h)])
            #`(define #,(format-id stx k) #,v))])
    #`(#,@defs)))

(module+ test
  (test-case
    "no exn"
    (gobble (constant-definitions #'() (make-consts-hashmap Stellar-l0a))))
  (define Stellar-const-defs (constant-definitions #'() (make-consts-hashmap Stellar-l0a))))

; Here we collect top-level enum definitions
; Returns an alist
(define-pass enum-defs : L0a (ir) -> * (l)
  (XDR-Spec : XDR-Spec (ir) -> * (l)
            ((,[l*] ...) (apply append l*)))
  (Def : Def (ir) -> * (l)
        ((define-type ,i (enum (,i* ,c*) ...)) `((,i . ,(zip i* c*))))
        (else '()))
  (append
   (XDR-Spec ir)
   '(("bool" . (("TRUE" . 1) ("FALSE" . 0)))))) ; bool is implicit

(module+ test
  (test-case
    "no exn"
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

(define (replace-else tag-decl* enum-type)
  (let* ([tags (dict-keys tag-decl*)]
         [all-tags (dict-keys enum-type)]
         [tag-decl2*
          (let* ([other-tags (set-remove tags 'else)]
                 [else-tags (set-subtract all-tags other-tags)]
                 [else-tag-decl* (for/list ([t else-tags])
                                   `(,t . ,(dict-ref tag-decl* 'else)))])
            (append (dict-remove tag-decl* 'else) else-tag-decl*))])
    tag-decl2*))

(define-pass normalize-unions : L0a (ir enum-dict) -> L1 ()
  (Union-Case-Spec : Union-Case-Spec (ir) -> * ()
                   (((,v* ...) ,[decl]) (for/list ([v v*])
                                          `(,v . ,decl)))
                   ((else ,decl) `((else . ,decl))))
  (Spec : Spec (ir) -> Spec ()
              ((union (,i1 ,i2) ,[Union-Case-Spec : union-case-spec -> * alist*] ...)
               (let* ([tag-decl* (apply append alist*)]
                      [_ (when (and
                                 (dict-has-key? enum-dict i2) ; tag type is an enum type
                                 (ormap number? (dict-keys tag-decl*)))
                           (error (format "numeric tag values not allowed in a union tagged by an enum type in: ~a" ir)))]
                      [tag-decl2*
                       (if (dict-has-key? tag-decl* 'else)
                           (replace-else tag-decl* (dict-ref enum-dict i2))
                           tag-decl*)]
                      [tag* (map car tag-decl2*)]
                      [decl* (map cdr tag-decl2*)])
                 `(union (,i1 ,i2) (,tag* ,decl*) ...)))))

(module+ test
  (define test-5
    '((define-type "my-enum" (enum ("A" 0) ("B" 1)))
      (define-type "my-union" (union (case ("tag" "my-enum") (("A") ("i" "int")) ((1) ("j" "int")))))))
  (test-case
    "throw on numeric tag value in union tagged by an enum type"
    (check-exn
      exn:fail?
      (λ ()
         (let* ([test-5-L0 (simplify-union (L0-parser test-5))]
                [test-5-enums (enum-defs test-5-L0)])
           (normalize-unions test-5-L0 test-5-enums)))))
  (define Stellar-l1 (normalize-unions Stellar-l0a Stellar-enum-defs)))

; Next we define a pass that changes the length of variable-length arrays as specified by the caller

(define (get-length overrides path len)
  (let ([key (reverse path)])
    (if (dict-has-key? overrides key)
        (let ([ov (dict-ref overrides key)])
          (if (eq? (car ov) 'len)
              (cdr ov)
              len))
        len)))

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
        (- (union (i1 i2) union-case-spec* ...))
        (- (struct decl* ...))
        (+ (union p (i1 i2) union-case-spec* ...))
        (+ (struct p decl* ...))))
(define path? list?) ; NOTE: this is part of the defintion of L2

(define-pass add-path : L1 (ir) -> L2 ()
  (Def : Def (ir) -> Def ()
       ((define-type ,i ,[Spec : type-spec0 (list i) -> type-spec1])
        `(define-type ,i ,type-spec1)))
  (Decl : Decl (ir p) -> Decl ()
        ((,i ,[Spec : type-spec0 (cons i p) -> type-spec1])
         `(,i ,type-spec1)))
  (Spec : Spec (ir p) -> Spec ()
        (,i i)
        ((union (,i1 ,i2) ,[Union-Case-Spec : union-case-spec0* p -> union-case-spec1*] ...)
         `(union ,p (,i1 ,i2) ,union-case-spec1* ...))
        ((string ,c) `(string ,c))
        ((variable-length-array ,[Spec : type-spec0 p -> type-spec1] ,v)
         `(variable-length-array ,type-spec1 ,v))
        ((fixed-length-array ,[Spec : type-spec0 p -> type-spec1] ,v)
         `(fixed-length-array ,type-spec1 ,v))
        ((enum (,i* ,c*) ...) `(enum (,i* ,c*) ...))
        ((struct ,[Decl : decl0 p -> decl1] ...)
         `(struct ,p ,decl1 ...)))
  (Union-Case-Spec : Union-Case-Spec (ir p) -> Union-Case-Spec ()
                   ((,v ,[Decl : decl0 p -> decl1])
                    `(,v ,decl1))))

(define (l0->l2 overrides l0)
  (let* ([l0a (throw-if-nested-enum (add-bool (simplify-union l0)))]
         [l1 (normalize-unions l0a (enum-defs l0a))]
         [l2 (add-path (override-lengths l1 overrides))])
    l2))

(module+ test
  (test-case
    "no exn on Stellar"
    (gobble (add-path Stellar-l1)))
  (define Stellar-l2 (add-path Stellar-l1)))

(define (struct-name path)
  (string-join (reverse path) "::"))

; collect all type defs in a hashmap
(define-pass collect-types : L2 (ir) -> * (h)
  (XDR-Spec : XDR-Spec (ir) -> * (h)
            ((,[def*] ...) (apply hash-union def*)))
  (Def : Def (ir) -> * (h)
       ((define-type ,i ,type-spec) (hash i type-spec))
       ((define-constant ,i ,c) (hash)))
  (XDR-Spec ir))

(module+ test
  (test-case
    "collect-types"
    (gobble (collect-types Stellar-l2)))
  (define Stellar-types (collect-types Stellar-l2)))

(define base-types '("opaque" "void" "int" "unsigned int" "hyper" "unsigned hyper"))
(define (base-type? t)
  (set-member? base-types t))

; Next we compute the type symbols that a type definition depends on.

(define-pass immediate-deps : (L2 Spec) (ir) -> * (d)
  ; all the types the given type spec depends on
  (Spec : Spec (ir) -> * (d)
        (,i (if (base-type? i) (set) (set i)))
        ((variable-length-array ,[d] ,v) d)
        ((fixed-length-array ,[d] ,v) d)
        ((struct ,p ,[d*] ...) (apply set-union d*))
        ((union ,p (,i1 ,i2) ,[d*] ...) (apply set-union d*))
        (else (set)))
  (Decl : Decl (ir) -> * (d)
        ((,i ,[d]) d)
        (else (set)))
  (Union-Case-Spec : Union-Case-Spec (ir) -> * (d)
                   ((,v ,[d]) d))
  (Spec ir)) ; TODO needed?

(module+ test
  (define TransactionEnvelope-deps (immediate-deps (hash-ref Stellar-types "TransactionEnvelope"))))

(define (type-graph-edges h)
  ; returns a list of edges
  (apply
    append
    (for/list ([(k v) (in-hash h)])
      (let ([deps (set->list (immediate-deps v))])
        (map (λ (d) (list k d)) deps)))))

(define (deps-graph h)
  (let ([edges (type-graph-edges h)])
    (unweighted-graph/directed edges)))

(define (deps h t)
    (do-bfs (deps-graph h) t
            #:init (set)
            #:visit: (set-add $acc $v)))

(module+ test
  (define TransactionEnvelope-deps/rec (deps Stellar-types "TransactionEnvelope"))
  (define TransactionResult-deps/rec (deps Stellar-types "TransactionResult"))
  (define LedgerEntry-deps/rec (deps Stellar-types "LedgerEntry")))

(define (min-depth h t)
  ; the minimum depth to cover the graph
  (let-values ([(a _) (bfs (deps-graph h) t)])
    (let ([reachable (for/fold ([acc null])
                               ([(k v) (in-hash a)])
                       (if (equal? v +inf.0)
                           acc
                           (cons (cons k v) acc)))])
      (cdr (argmax (λ (p) (cdr p)) reachable)))))

; max depth without recursing:
(define (max-depth xdr-types)
  (let ([h (collect-types (l0->l2 null (L0-parser xdr-types)))])
    (define g (deps-graph h))
    (define-vertex-property g max-depth)
    (do-dfs g
            #:epilogue: (let ([ns (get-neighbors g $v)])
                          (if (null? ns)
                            (max-depth-set! $v 1)
                            (let* ([get-depth (λ (v)
                                                 (if (max-depth-defined? v)
                                                   (max-depth v)
                                                   0))]
                                   [m (apply max (map get-depth ns))])
                              (max-depth-set! $v (+ m 1))))))
    (max-depth->hash)))

(define (recursive-types h t)
  ; returns the set of types that are recursive
  ; TODO a test
  (let ([g (deps-graph h)]
        [rec-types (mutable-set)])
    (define-vertex-property g path)
    (do-bfs g t
            #:init (path-set! t null)
            #:on-enqueue: (path-set! $v (cons $from (path $from)))
            #:visit?: (begin
                        (let ([seen (set-member? (path $from) $v)])
                          (when seen (set-add! rec-types $v))
                          (not seen))))
    rec-types))


; Next we define needed Racket struct types

(define (make-struct-type stx name fields) ; name and fields as strings
  (let ([field-names (for/list ([f fields])
                       (format-id stx "~a" f))])
        #`(struct/lens #,(format-id stx "~a" name) #,field-names #:transparent)))

(module+ test
  (test-case
    "make struct type"
         (gobble (make-struct-type #'() "my-struct" '("field1" "field2")))))

(define-pass make-struct-types : (L2 Spec) (ir stx) -> * (sts)
  ; NOTE stops at type identifiers
  (Spec : Spec (ir) -> * (sts)
        (,i (hash))
        ((string ,c) (hash))
        ((variable-length-array ,[sts] ,v) sts)
        ((fixed-length-array ,[sts] ,v) sts)
        ((enum (,i* ,c*) ...) (hash))
        ; The following may not be a good idea if we want to trgobble union with tag bool as generic option types.
        ; The problem is that guile-rpc transforms optionals into normal unions.
        ; For now we assume that any union with bool tag is in fact an optional.
        ((union ,p (,i1 ,i2) ,[sts*] ...)
         (let ([rest (apply hash-union sts*)])
          (if (equal? i2 "bool")
           rest
           (let ([t (make-struct-type stx (struct-name p) '("tag" "value"))])
             (hash-union (hash (struct-name p) t) rest)))))
        ((struct ,p ,decl* ...)
         (let* ([get-decl-pair
                 (λ (decl)
                   (nanopass-case (L2 Decl)
                                  decl
                                  ((,i ,type-spec) (cons i type-spec))
                                  (else #f)))]
                [non-void (filter identity (map get-decl-pair decl*))]
                [f* (map car non-void)]
                [s* (map cdr non-void)]
                [t (make-struct-type stx (struct-name p) f*)]
                [rec (apply hash-union (map (λ (s) (Spec s)) s*))])
           (hash-union rec (hash (struct-name p) t)))))
  (Decl : Decl (ir) -> * (sts)
        ((,i ,[sts]) sts)
        (else (hash)))
  (Union-Case-Spec : Union-Case-Spec (ir) -> * (sts)
                   ((,v ,[sts]) sts))
  (Spec ir))

(module+ test
  (test-case
    "make struct types"
      (gobble (make-struct-types (hash-ref Stellar-types "ManageOfferSuccessResult") #'()))
      (gobble (make-struct-types (hash-ref Stellar-types "LiquidityPoolEntry") #'()))))

(define (make-struct-types/rec stx h ts)
  (let* ([deps
          (apply
           set-union
           (for/list ([t (in-set ts)])
             (deps h t)))])
    (apply
     hash-union
     (for/list ([t (in-set (set-union ts deps))])
       (make-struct-types (hash-ref h t) stx)))))

(module+ test
  (test-case
    "make-struct-types/rec test"
    (gobble
      (make-struct-types/rec
        #'()
        Stellar-types
        (set "TransactionEnvelope" "TransactionResult" "LedgerEntry")))))

(define (built-in-structs stx)
  ; we can use union as it cannot be used as an identifier as per RFC4506
  ; we can also use a prefix like _ or -, which again cannot be used at the beginning of an identifier as per RFC4506
  (list
   (make-struct-type stx "-byte-array" '("value"))
   (make-struct-type stx "-optional" '("present" "value"))))

; this produces a syntax object
(define (xdr-types->racket xdr-spec overrides stx ts) ; ts is a set of types
  (let* ([l0 (throw-if-nested-enum (add-bool (simplify-union (L0-parser xdr-spec))))]
         [l1 (normalize-unions l0 (enum-defs l0))]
         [l2 (add-path (override-lengths l1 overrides))]
         [h (collect-types l2)]
         [consts-h (make-consts-hashmap l0)]
         [const-defs (constant-definitions stx consts-h)]
         [struct-defs (hash-values (make-struct-types/rec stx h ts))])
    #`(begin
        #,@const-defs
        #,@struct-defs
        #,@(built-in-structs stx))))

(module+ test
  (define test-overrides
    '((("Transaction" "operations") len . 1)
      (("TestLedger" "ledgerEntries") len . 2)
      (("MuxedAccount" "ed25519")
       key-set
       "GAD2EJUGXNW7YHD7QBL5RLHNFHL35JD4GXLRBZVWPSDACIMMLVC7DOY3"
       "GBASB5IEQQHYEVWJXTG6HVQR62FNASTOXMEGL4UOUQVNKDLR3BN2HIJL")))
  (test-case
    "xdr-types->racket"
      (gobble (xdr-types->racket Stellar-xdr-types test-overrides #'()  (set "TransactionEnvelope" "TestLedger" "TestCaseResult")))))

; Next we generate the valid? function for a given xdr spec
; TODO we could avoid all those lambdas if we passed a syntax object to Spec
(define-pass valid?/syntax : L2 (t types ctx) -> * (stx)
  (Spec : Spec (t) -> * (stx)
        (,i
          (cond
            [(not (base-type? i))
             (Spec (hash-ref types i))]
            [(equal? t "opaque")
             #`(λ (d) ((bitvector 8) d))]
            [(set-member? '("int", "unsigned int") t)
             #`(λ (d) ((bitvector 32) d))]
            [(set-member? '("hyper", "unsigned hyper") t)
             #`(λ (d) ((bitvector 64) d))]))
        ((string ,c)
         #`(λ (d) (and (vector? d) (equal? (vector-length d) #,c))))
        ((variable-length-array ,[stx] ,v)
         #`(λ (d)
              (and
                (vector? d)
                (when #,v (equal? (vector-length d) #,v))
                (for/and ([e d])
                  #,stx e))))
        ((fixed-length-array ,[stx] ,v)
         #`(λ (d)
              (and
                (vector? d)
                (equal? (vector-length d) #,v)
                (for/and ([e d])
                  #,stx e))))
        ((enum (,i* ,c*) ...)
         #`(λ (d)
              (and
                ((bitvector 32) d)
                (for/or ([v #,c*])
                  (bveq d v)))))
        ((struct ,p ,decl* ...)
         (define struct-type-valid?
           (format-id ctx "~a?" (struct-name p)))
         (define (field-valid? decl)
           (nanopass-case
             (L2 Decl)
             decl
             ((,i ,type-spec)
              (define type-valid? (Spec type-spec))
              (define accessor
                (format-id ctx "~a-~a" (struct-name p) i))
              #`(λ (d) (#,type-valid? (#,accessor d))))
             (,void (error "void struct member not supported"))))
         #`(λ (d)
              (and
                (#,struct-type-valid? d)
                #,@(for/list ([fd decl*])
                     #`(#,(field-valid? fd) d)))))
        ((union ,p (,i1 ,i2) ,union-case-spec* ...)
         #'todo)
        (else #'(λ (d) (#t))))
    (begin
      (define fn-id (format-id ctx "valid?"))
      #`(define (#,fn-id data) (#,(Spec t) data))))

(module+ test
  (test-case
    "valid?/syntax tests"
    (begin
      (gobble (valid?/syntax "int" (hash) #'()))
      (gobble (valid?/syntax "PublicKey" Stellar-types #'())))))
