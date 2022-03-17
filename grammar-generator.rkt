#lang nanopass
; Generate a Rosette grammar corresponding to an XDR specification
; We use the nanopass compiler framework

; TODO there's pretty much no error checking
; TODO write tests

(require
  racket/hash
  list-util
  racket/syntax
  racket/generator
  pretty-format
  ;racket/trace
  graph
  "read-spec.rkt")

(provide generate-grammar)
 ;L0-parser normalize-unions has-nested-enum? make-consts-hashmap)

(define the-ast
  (read-spec "temp/Stellar.sexp")) ; for testing

(define-language L0
  ; This is a subset of the the language of guile-rpc ASTs
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

(define test-0 '((define-type "t" (union (case ("tag" "type") (("X") ("x" "tx")) (else ("y" "Y")))))))
(L0-parser test-0)

(define test-1
  '((define-type "test-union"
     (union (case ("tagname" "tagtype")
              (("A") ("c" (union (case ("tagname-2" "tagtype-2") (("X" "Y") ("x" "T"))))))
              (("B" "C") ("d" "int")))))
    (define-type "test-struct"
      (struct ("t1" (union (case ("tagname-3" "tagtype-3") (("F" "G") ("y" "T")))))))))

(L0-parser test-1)

; L0a simplifies L0 a bit by removing the superfluous Union-Spec production

(define-language L0a
  (extends L0)
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

(define Stellar-L0a (add-bool (simplify-union (L0-parser the-ast))))

; throws an exception if there are any nested enums
; NOTE we produce L0 to allow the framework to synthesis most of the rules
(define-pass throw-if-nested-enum : L0a (ir) -> L0a ()
  (Def : Def (ir) -> Def ()
       ; a top-level enum: 
       ((define-type ,i (enum (,i* ,c*) ...)) ir))
  (Spec : Spec (ir) -> Spec ()
        ((enum (,i* ,c*) ...)
         (error "enums defined inside other types are not supported"))))

(define (has-nested-enum? l0)
  (with-handlers ([exn:fail? (λ (exn) #t)])
    (begin
      (throw-if-nested-enum l0)
      #f)))

(println (has-nested-enum? (simplify-union (L0-parser test-1))))

(define test-2
  '((define-type "test-struct"
      (struct ("t1" (enum ("A" 1)))))))

(define test-3
  '((define-type "t1" (enum ("A" 1)))))

(println (has-nested-enum? (simplify-union (L0-parser test-2))))
(println (has-nested-enum? (simplify-union (L0-parser test-3))))


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

(define test-4
  '((define-type "test-enum" (enum ("A" 1) ("B" 2))) (define-constant "C" 3)))

(make-consts-hashmap (simplify-union (L0-parser test-3)))
(make-consts-hashmap (simplify-union (L0-parser test-4)))
                     
; Make constant definitions:

(define (constant-definitions stx h)
  ; expects a hashmap mapping identifiers to values
  (let ([defs
          (for/list ([(k v) (in-dict h)])
            #`(define #,(format-id stx k) #,v))])
    #`(#,@defs)))

(define Stellar-const-defs (constant-definitions #'() (make-consts-hashmap Stellar-L0a)))

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

(define Stellar-enum-defs (enum-defs Stellar-L0a))

; next we normalize union specs

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

(define test-5
  '((define-type "my-enum" (enum ("A" 0) ("B" 1)))
    (define-type "my-union" (union (case ("tag" "my-enum") (("A") ("i" "int")) ((1) ("j" "int")))))))
(let* ([test-5-L0 (simplify-union (L0-parser test-5))]
       [test-5-enums (enum-defs test-5-L0)])
  (with-handlers ([exn:fail? (λ (exn) (println "okay"))])
    (normalize-unions test-5-L0 test-5-enums)))

(define Stellar-L1 (normalize-unions Stellar-L0a Stellar-enum-defs))

; Next we define a pass that changes the length of variable-length arrays as specified by the caller

(define (get-length len-specs path len)
  (let ([key (reverse (cons "_len" path))])
    (if (dict-has-key? len-specs key)
        (begin
          (dict-ref len-specs key))
        len)))

(define test-len-specs
  '((("Transaction" "operations" "_len") . 1)))

; TODO what about specifying more specific paths, e.g. ("TransactionEnvelope" "v1" "tx" "operations" "_len")
(define-pass override-lengths : L1 (ir len-specs) -> L1 ()
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
           `(variable-length-array ,type-spec ,(get-length len-specs path v))))
        (else ir))
  (Union-Case-Spec : Union-Case-Spec (ir path) -> Union-Case-Spec ()
                   ((,v ,[Decl : decl path -> decl2]) `(,v ,decl2))))

(define-language L2
  ; add path of a struct in the type hierarchy
  ; this is to generate unique Racket struct names that represent struct types
  (extends L1)
  (terminals
   (+ (path (p))))
  (Spec (type-spec)
        (- (struct decl* ...))
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
        ((struct ,[Decl : decl0 p -> decl1] ...)
         `(struct ,p ,decl1 ...)))
  (Union-Spec : Union-Spec (ir p) -> Union-Spec ())  ; NOTE processors with inputs are not auto-generated, but their body is
  (Union-Case-Spec : Union-Case-Spec (ir p) -> Union-Case-Spec ()))

(define Stellar-L2 (add-path Stellar-L1))

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

(define Stellar-types (collect-types Stellar-L2))

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
        ((union (,i1 ,i2) ,[d*] ...) (apply set-union d*))
        (else (set)))
  (Decl : Decl (ir) -> * (d)
        ((,i ,[d]) d)
        (else (set)))
  (Union-Case-Spec : Union-Case-Spec (ir) -> * (d)
                   ((,v ,[d]) d))
  (Spec ir))

(define TransactionEnvelope-deps (immediate-deps (hash-ref Stellar-types "TransactionEnvelope")))

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

(define (depth h t)
  ; the minimum depth to cover the graph
  (let-values ([(a _) (bfs (deps-graph h) t)])
    (let ([reachable (for/fold ([acc null])
                               ([(k v) (in-hash a)])
                       (if (equal? v +inf.0)
                           acc
                           (cons (cons k v) acc)))])
      (cdr (argmax (λ (p) (cdr p)) reachable)))))

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

#;(depth Stellar-types "TransactionEnvelope")

(define TransactionEnvelope-deps/rec (deps Stellar-types "TransactionEnvelope"))
(define TransactionResult-deps/rec (deps Stellar-types "TransactionResult"))
(define LedgerEntry-deps/rec (deps Stellar-types "LedgerEntry"))

; Next we define needed Racket struct types

(define (make-struct-type stx name fields) ; name and fields as strings
  (let ([field-names (for/list ([f fields])
                       (format-id stx "~a" f))])
        #`(struct #,(format-id stx "~a" name) #,field-names #:transparent)))

(make-struct-type #'() "my-struct" '("field1" "field2"))

(define-pass make-struct-types : (L2 Spec) (ir stx) -> * (sts)
  ; NOTE stops at type identifiers
  (Spec : Spec (ir) -> * (sts)
        (,i (hash))
        ((string ,c) (hash))
        ((variable-length-array ,[sts] ,v) sts)
        ((fixed-length-array ,[sts] ,v) sts)
        ((enum (,i* ,c*) ...) (hash))
        ((union (,i1 ,i2) ,[sts*] ...) (apply hash-union sts*))
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

(make-struct-types (hash-ref Stellar-types "ManageOfferSuccessResult") #'())
(make-struct-types (hash-ref Stellar-types "LiquidityPoolEntry") #'())

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

(hash-count (make-struct-types/rec #'() Stellar-types
                                   (set "TransactionEnvelope" "TransactionResult" "LedgerEntry")))

; Next:
; Generate rules

(define (size->number consts size)
  (if (string? size)
      (hash-ref consts size)
      size))
(define (make-sequence seq-t elem-type-rule size)
  ; seq-t is "list" or "vector"
  ; size is a numeric value
  #`(#,seq-t
     #,@(for/list ([i (in-range size)]) elem-type-rule)))
(define (make-list consts elem-type-rule size)
  (let ([n (size->number consts size)])
    (make-sequence "list" elem-type-rule n)))
;struct union (tag value) #:transparent)
(define max-seq-len 2)
(define (make-vector consts elem-type-rule size) ; variable-size array
  (let ([n (size->number consts size)])
    (let ([m (if (or (not n) (> n max-seq-len)) max-seq-len n)])
      (make-sequence "vector" elem-type-rule m))))

; generate an identifier for a grammar rule:
(define (rule-id str)
  ; generate unique indices
  (define get-index! (generator ()
                                (let loop ([index 0])
                                  (yield index)
                                  (loop (+ index 1)))))
  ; Rosette seems to be relying on source-location information to create symbolic variable names.
  ; Since we want all grammar holes to be independent, we need to use a unique location each time.
  ; This is only useful if using the grammar generator in a macro
  (format-id #f "~a-rule" str #:source (make-srcloc (format "~a-rule:~a" str (get-index!)) 1 0 1 0)))

(define (rule-hole str)
  #`(#,(rule-id str)))

(define (value-rule stx v)
  (if (string? v)
      (format-id stx "~a" v)
      v))

(define built-in-structs
  ; we put ":" in the name to avoid clashes with XDR names
  (list 
   #'(struct :byte-array: (value) #:transparent)
   #'(struct :union: (tag value) #:transparent)))

(define-pass make-rule : (L2 Spec) (ir stx type-name consts) -> * (rule)
  (Spec : Spec (ir) -> * (rule)
        [,i (case i
              [("opaque") #`(?? (bitvector 8))]
              [("int" "unsigned int") #`(?? (bitvector 32))]
              [("hyper" "unsigned hyper") #`(?? (bitvector 64))]
              [else (rule-hole i)])]
        [(struct ,p ,[decl-body*] ...)
         (let ([struct-name (format-id stx "~a" (struct-name p))])
           #`(#,struct-name #,@decl-body*))]
        [(string ,c) (make-vector consts #'(?? (bitvector 8)) c)]
        [(variable-length-array ,[elem-rule] ,v)
         (make-vector consts elem-rule v)]
        [(fixed-length-array ,type-spec ,v)
         (guard (equal? type-spec "opaque"))
         (let ([n (size->number consts v)])
           #`(:byte-array: (?? (bitvector #,(* n 8)))))]
        [(fixed-length-array ,[elem-rule] ,v)
         (make-list consts elem-rule v)]
        [(enum (,i* ,c*) ...)
         (let ([bv* (map (λ (i) #`(bv #,(format-id stx "~a" i) 32)) i*)])
           (if (> (length bv*) 1)
               #`(choose #,@bv*)
               (car bv*)))]
        [(union (,i1 ,i2) ,[rule*] ...)
         (if (> (length rule*) 1)
                   #`(choose #,@rule*)
                   (car rule*))])
  (Decl : Decl (ir) -> * (rule)
        [(,i ,[rule]) rule]
        [,void #'null])
  (Union-Case-Spec : Union-Case-Spec (ir) -> * (rule)
                   [(,v ,[rule])
                    #`(:union: (bv #,(value-rule stx v) 32) #,rule)])
  #`(#,(rule-id type-name) #,(Spec ir)))

(let ([t "SimplePaymentResult"])
  (make-rule (hash-ref Stellar-types t)  #'() t (make-consts-hashmap Stellar-L0a) ))
(let ([t "PathPaymentStrictReceiveResult"])
  (make-rule (hash-ref Stellar-types t)  #'() t (make-consts-hashmap Stellar-L0a) ))

(define (xdr-types->grammar xdr-spec len-specs stx ts) ; ts is a set of types
  (let* ([l0 (throw-if-nested-enum (add-bool (simplify-union (L0-parser xdr-spec))))]
         [consts-h (make-consts-hashmap l0)]
         [l1 (normalize-unions l0 (enum-defs l0))]
         [l2 (add-path (override-lengths l1 len-specs))]
         [h (collect-types l2)]
         [const-defs (constant-definitions stx (make-consts-hashmap l0))]
         [struct-defs (hash-values (make-struct-types/rec stx h ts))]
         [deps (set-union
                ts
                (apply set-union
                       (for/list ([t ts])
                         (deps h t))))]
         [rules (for/list ([t deps])
                  (make-rule (hash-ref h t) stx t consts-h))])
    #`(begin
        #,@const-defs
        #,@struct-defs
        #,@built-in-structs
        (define-grammar
          (#,(format-id stx "~a" "the-grammar")) #,@rules))))

(define (generate-grammar xdr-spec len-specs)
  (pretty-display
   (syntax->datum
    (xdr-types->grammar
     xdr-spec
     len-specs
     #'()
     (set "TestCase")))))