#lang racket

; Generate a Rosette grammar corresponding to an XDR specification
; Reads an input specification in guile-rpc AST format
; We use the nanopass compiler framework

; TODO there's pretty much no error checking
; TODO write tests
; TODO a pass to remove recursion or limit its depth (ClaimPredicate)?
; TODO using this in a macro to generate a grammar does not work because there's unintended sharing
; (e.g. to invocation of the same rules are interpreted by Rosette as the same)

(require
  (rename-in nanopass [extends extends-language]) ; conflicts with rosette
  racket/hash
  (only-in list-util zip)
  racket/syntax
  racket/generator
  racket/pretty
  graph
  "key-utils.rkt"
  (only-in rosette bitvector->natural)
  (for-template ; useful if we were to use the functionality in a macro
   rosette
   rosette/lib/synthax))

(provide xdr-types->grammar-datum xdr-types->grammar max-depth)

(module+ test
  (require rackunit "read-datums.rkt")
  (define Stellar-xdr-types
    (read-datums "Stellar.xdr-types")))

(define-language L0
  ; This is a subset of the language of guile-rpc ASTs
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
  (define/provide-test-suite L0-parser/test
    (test-case
     "parse simple examples"
     (check-not-exn
      (λ ()
        (L0-parser test-0)
        (L0-parser test-1))
      "parsing threw an exception"))
    (test-case
     "parser Stellar-xdr-types"
     (check-not-exn
      (λ ()
        (L0-parser Stellar-xdr-types))
      "exception parsing Stellar-xdr-types")))
  (define Stellar-l0 (L0-parser Stellar-xdr-types)))

; L0a simplifies L0 a bit by removing the superfluous Union-Spec production

(define-language L0a
  ; TODO how to remove Union-Spec entirely?
  (extends-language L0)
  (Spec (type-spec)
        (- (union union-spec))
        (+ (union (i1 i2) union-case-spec* ...))))

(define-pass simplify-union : L0 (ir) -> L0a ()
  (Spec : Spec (ir) -> Spec ()
        ((union (case (,i1 ,i2) ,[union-case-spec*] ...))
         `(union (,i1 ,i2) ,union-case-spec* ...))))

; Next we add the default bool enum

(define-pass add-bool : L0a (ir) -> L0a ()
  (XDR-Spec : XDR-Spec (ir) -> XDR-Spec ()
            ((,def* ...)
             `(,def* ...
               ,(with-output-language (L0a Def) `(define-type "bool" (enum ("TRUE" 1) ("FALSE" 0))))))))

; does not work:
; (define-language-node-counter L0-counter L0)

(module+ test
  (define/provide-test-suite simplify-union/test
    (test-case
     "run simplify-union on stellar spec"
     (check-not-exn
      (λ ()
        (simplify-union Stellar-l0))
      "exception in simplify-union")))
  (define Stellar-l0a (add-bool (simplify-union Stellar-l0))))

; throws an exception if there are any nested enums
; NOTE we produce L0a to allow the nanopass framework to synthesize most of the rules
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
  (define/provide-test-suite throw-if-nested-enum/test
    (test-case
     "should throw on nested enum"
     (check-exn
      exn:fail?
      (λ ()
          (throw-if-nested-enum (simplify-union (L0-parser test-2)))))
    (test-case
     "should not throw"
     (check-not-exn
      (λ ()
        (begin
          (throw-if-nested-enum (simplify-union (L0-parser test-1)))
          (throw-if-nested-enum (simplify-union (L0-parser test-3)))
          (throw-if-nested-enum Stellar-l0a))))))))

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

  (define/provide-test-suite make-consts-hashmap/test
    (test-case
     "no exn"
     (check-not-exn
      (λ ()
        (begin
          (make-consts-hashmap (simplify-union (L0-parser test-3)))
          (make-consts-hashmap (simplify-union (L0-parser test-4)))
          (make-consts-hashmap Stellar-l0a)))))))
                     
; Make constant definitions:

(define (constant-definitions stx h)
  ; expects a hashmap mapping identifiers to values
  (let ([defs
          (for/list ([(k v) (in-dict h)])
            #`(define #,(format-id stx k) #,v))])
    #`(#,@defs)))

(module+ test
  (define/provide-test-suite constant-definitions/test
    (test-case
     "no exn"
     (check-not-exn
      (λ ()
        (constant-definitions #'() (make-consts-hashmap Stellar-l0a))))))
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
  (define/provide-test-suite enum-defs/test
    (test-case
     "no exn"
     (check-not-exn
      (λ ()
        (enum-defs Stellar-l0a))
      "exception in enum-defs")))
  (define Stellar-enum-defs (enum-defs Stellar-l0a)))

; next we normalize union specs

(define-language L1
  (extends-language L0a)
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
  (define/provide-test-suite normalize-unions/test
    (test-case
     "throw on numeric tag value in union tagged by an enum type"
     (check-exn
      exn:fail?
      (λ ()
        (let* ([test-5-L0 (simplify-union (L0-parser test-5))]
               [test-5-enums (enum-defs test-5-L0)])
          (normalize-unions test-5-L0 test-5-enums))))))
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
  ; add path field to types
  (extends-language L1)
  (terminals
   (+ (path (p))))
  (Spec (type-spec)
        (- i)
        (- (union (i1 i2) union-case-spec* ...))
        (- (string c))
        (- (variable-length-array type-spec (maybe v)))
        (- (fixed-length-array type-spec v))
        (- (enum (i* c*) ...))
        (- (struct decl* ...))
        (+ (p i))
        (+ (union p (i1 i2) union-case-spec* ...))
        (+ (string p c))
        (+ (variable-length-array p type-spec (maybe v)))
        (+ (fixed-length-array p type-spec v))
        (+ (enum p (i* c*) ...))
        (+ (struct p decl* ...))))
(define path? list?)

(define-pass add-path : L1 (ir) -> L2 ()
  (Def : Def (ir) -> Def ()
       ((define-type ,i ,[Spec : type-spec0 (list i) -> type-spec1])
        `(define-type ,i ,type-spec1)))
  (Decl : Decl (ir p) -> Decl ()
        ((,i ,[Spec : type-spec0 (cons i p) -> type-spec1])
         `(,i ,type-spec1)))
  (Spec : Spec (ir p) -> Spec ()
        (,i
         `(,p ,i))
        ((union (,i1 ,i2) ,[Union-Case-Spec : union-case-spec0* p -> union-case-spec1*] ...)
         `(union ,p (,i1 ,i2) ,union-case-spec1* ...))
        ((string ,c)
         `(string ,p ,c))
        ((variable-length-array ,[Spec : type-spec0 p -> type-spec1] ,v)
         `(variable-length-array ,p ,type-spec1 ,v))
        ((fixed-length-array ,[Spec : type-spec0 p -> type-spec1] ,v)
         `(fixed-length-array ,p ,type-spec1 ,v))
        ((enum (,i* ,c*) ...)
         `(enum ,p (,i* ,c*) ...))
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
  (define/provide-test-suite add-path/test
    (test-case
     "no exn on Stellar"
     (check-not-exn
      (λ ()
        (add-path Stellar-l1))
      "exception in add-path")))
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
  (define/provide-test-suite collect-types/test
    (test-case
     "no exn"
     (check-not-exn
      (λ ()
        (collect-types Stellar-l2))
      "exception in collect-types")))
  (define Stellar-types (collect-types Stellar-l2)))

(define base-types '("opaque" "void" "int" "unsigned int" "hyper" "unsigned hyper"))
(define (base-type? t)
  (set-member? base-types t))

; Next we compute the type symbols that a type definition depends on.

(define-pass immediate-deps : (L2 Spec) (ir) -> * (d)
  ; all the types the given type spec depends on
  (Spec : Spec (ir) -> * (d)
        ((,p ,i) (if (base-type? i) (set) (set i)))
        ((variable-length-array ,p ,[d] ,v) d)
        ((fixed-length-array ,p ,[d] ,v) d)
        ((struct ,p ,[d*] ...) (apply set-union d*))
        ((union ,p (,i1 ,i2) ,[d*] ...) (apply set-union d*))
        (else (set)))
  (Decl : Decl (ir) -> * (d)
        ((,i ,[d]) d)
        (else (set)))
  (Union-Case-Spec : Union-Case-Spec (ir) -> * (d)
                   ((,v ,[d]) d))
  (Spec ir))

(module+ test
  (define TransactionEnvelope-deps (immediate-deps (hash-ref Stellar-types "TransactionEnvelope"))))

(define (type-graph-edges h)
  (apply append
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

(module+ test
  (define TransactionEnvelope-deps/rec (deps Stellar-types "TransactionEnvelope"))
  (define TransactionResult-deps/rec (deps Stellar-types "TransactionResult"))
  (define LedgerEntry-deps/rec (deps Stellar-types "LedgerEntry")))

; Next we define needed Racket struct types

(define (make-struct-type stx name fields) ; name and fields as strings
  (let ([field-names (for/list ([f fields])
                       (format-id stx "~a" f))])
        #`(struct #,(format-id stx "~a" name) #,field-names #:transparent)))

(module+ test
  (make-struct-type #'() "my-struct" '("field1" "field2")))

(define-pass make-struct-types : (L2 Spec) (ir stx) -> * (sts)
  ; NOTE stops at type identifiers
  (Spec : Spec (ir) -> * (sts)
        ((,p ,i) (hash))
        ((string ,p ,c) (hash))
        ((variable-length-array ,p ,[sts] ,v) sts)
        ((fixed-length-array ,p ,[sts] ,v) sts)
        ((enum ,p (,i* ,c*) ...) (hash))
        ((union ,p (,i1 ,i2) ,[sts*] ...) (apply hash-union sts*))
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
  (make-struct-types (hash-ref Stellar-types "ManageOfferSuccessResult") #'())
  (make-struct-types (hash-ref Stellar-types "LiquidityPoolEntry") #'()))

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
  (hash-count
   (make-struct-types/rec
    #'()
    Stellar-types
    (set "TransactionEnvelope" "TransactionResult" "LedgerEntry"))))

; Next:
; Generate rules

(define (size->number consts size)
  (if (string? size)
      (hash-ref consts size)
      size))
(define (make-sequence seq-t elem-type-rule size)
  ; seq-t is list or vector
  ; size is a numeric value
  #`(#,seq-t
     #,@(for/list ([i (in-range size)]) elem-type-rule))) ; TODO: for use as a macro, we need different slocs for the rules
(define (make-list consts elem-type-rule size)
  (let ([n (size->number consts size)])
    (make-sequence #'list elem-type-rule n)))
;struct union (tag value) #:transparent)
(define max-seq-len 2)
(define (make-vector consts elem-type-rule size) ; variable-size array
  (let ([n (size->number consts size)])
    (let ([m (if (or (not n) (> n max-seq-len)) max-seq-len n)])
      (make-sequence #'vector elem-type-rule m))))

; generate an identifier for a grammar rule:
(define (format-id/unique-loc str [stx #f])
  ; generate unique indices
  (define get-index! (generator ()
                                (let loop ([index 0])
                                  (yield index)
                                  (loop (+ index 1)))))
  ; Rosette seems to be relying on source-location information to create symbolic variable names.
  ; Since we want all grammar holes to be independent, we need to use a unique location each time.
  ; This is only useful if using the grammar generator in a macro.
  (format-id stx "~a" str #:source (make-srcloc (format "~a:~a" str (get-index!)) 1 0 1 0)))

(define (rule-hole str)
  #`(#,(format-id/unique-loc (string-append str "-rule"))))

(define (value-rule stx v)
  (if (string? v)
      (format-id/unique-loc v stx)
      v))

(define (built-in-structs stx)
  ; we put ":" in the name to avoid clashes with XDR names
  (list
   (make-struct-type stx ":byte-array:" '("value"))
   (make-struct-type stx ":union:" '("tag" "value"))))

; TODO: when we have an override for a path, apply it
(define-pass make-rule : (L2 Spec) (ir stx type-name consts overrides) -> * (rule)
  ; TODO: for use as a macro, we need unique source locations for each sub-rule invocation (including e.g. (?? bitvector 32))
  (Spec : Spec (ir) -> * (rule)
        [(,p ,i)
         (let ([key (reverse p)])
           (if (and
                (dict-has-key? overrides key)
                (eq? (car (dict-ref overrides key)) 'key-set))
               (let* ([vals (map (λ (s) (bitvector->natural (strkey->bv s))) (cdr (dict-ref overrides key)))]
                      [vals/syn (map (λ (v) #`(bv #,v 256)) vals)])
                 #`(choose #,@vals/syn))
               (case i
                 [("opaque") #'(?? bitvector 8)]
                 [("int" "unsigned int") #'(?? bitvector 32)]
                 [("hyper" "unsigned hyper") #'(?? bitvector 64)]
                 [else (rule-hole i)])))]
        [(struct ,p ,[decl-body*] ...)
         (let ([struct-name (format-id/unique-loc (struct-name p) stx)]) ; TODO unique loc needed?
           #`(#,struct-name #,@decl-body*))]
        [(string ,p ,c) (make-vector consts #`(?? bitvector 8) c)]
        [(variable-length-array ,p ,[elem-rule] ,v)
         (make-vector consts elem-rule v)]
        [(fixed-length-array ,p ,type-spec ,v)
         (guard (equal? type-spec "opaque"))
         (let ([n (size->number consts v)])
           #`(:byte-array: (?? (bitvector #,(* n 8)))))]
        [(fixed-length-array ,p ,[elem-rule] ,v)
         (make-list consts elem-rule v)]
        [(enum ,p (,i* ,c*) ...)
         (let ([bv* (map (λ (i) #`(bv #,i 32)) i*)])
           (if (> (length bv*) 1)
               #`(choose #,@bv*)
               (car bv*)))]
        [(union ,p (,i1 ,i2) ,[rule*] ...)
         (if (> (length rule*) 1)
                   #`(choose #,@rule*)
                   (car rule*))])
  (Decl : Decl (ir) -> * (rule)
        [(,i ,[rule]) rule]
        [,void #'null])
  (Union-Case-Spec : Union-Case-Spec (ir) -> * (rule)
                   [(,v ,[rule])
                    #`(:union: (bv #,(value-rule stx v) 32) #,rule)])
  #`(#,(format-id/unique-loc (string-append type-name "-rule")) #,(Spec ir)))

(module+ test
  (let ([t "SimplePaymentResult"])
    (make-rule (hash-ref Stellar-types t)  #'() t (make-consts-hashmap Stellar-l0a) null))
  (let ([t "PathPaymentStrictReceiveResult"])
    (make-rule (hash-ref Stellar-types t)  #'() t (make-consts-hashmap Stellar-l0a) null)))

; returns a grammar as a syntax object
(define (xdr-types->grammar xdr-spec overrides stx ts) ; ts is a set of types
  (let* ([l0 (throw-if-nested-enum (add-bool (simplify-union (L0-parser xdr-spec))))]
         [l1 (normalize-unions l0 (enum-defs l0))]
         [l2 (add-path (override-lengths l1 overrides))]
         [h (collect-types l2)]
         [consts-h (make-consts-hashmap l0)]
         [const-defs (constant-definitions stx consts-h)]
         [struct-defs (hash-values (make-struct-types/rec stx h ts))]
         [deps (set-union
                ts
                (apply set-union
                       (for/list ([t ts])
                         (deps h t))))]
         [rules (for/list ([t deps])
                  (make-rule (hash-ref h t) stx t consts-h overrides))])
    #`(begin
        #,@const-defs
        #,@struct-defs
        #,@(built-in-structs stx)
        (define-grammar
          (#,(format-id stx "~a" "the-grammar")) #,@rules))))

(define (xdr-types->grammar-datum xdr-types overrides types)
   (syntax->datum
    (xdr-types->grammar
     xdr-types
     overrides
     #'()
     types)))

(module+ test
  (define test-overrides
    '((("Transaction" "operations") len . 1)
      (("TestCase" "ledgerEntries") len . 2)
      (("TestCase" "transactionEnvelopes") len . 1)
      (("MuxedAccount" "ed25519")
       key-set
       "GAD2EJUGXNW7YHD7QBL5RLHNFHL35JD4GXLRBZVWPSDACIMMLVC7DOY3"
       "GBASB5IEQQHYEVWJXTG6HVQR62FNASTOXMEGL4UOUQVNKDLR3BN2HIJL")))
  (xdr-types->grammar-datum Stellar-xdr-types test-overrides (set "TestCase" "TestCaseResult")))