#lang racket

(require
  racket/match racket/syntax racket/generator racket/hash
  "xdr-compiler.rkt" "guile-ast-example.rkt"
  "util.rkt"
  (for-template rosette rosette/lib/synthax))
(provide xdr-types->grammar const-definitions)

(module+ test
  (require rackunit)
  (provide test-sym-table test-sym-table-2))

(module+ test
  ; a simpler example:
  (define test-ast
    #'((define-type
         "uint256"
         (fixed-length-array "opaque" 32))
       (define-type
         "my-array"
         (fixed-length-array "uint256" 2))
       (define-type
         "PublicKeyType"
         (enum ("PUBLIC_KEY_TYPE_ED25519" 0) ("OTHER_PUBLIC_KEY_TYPE" 1) ("ANOTHER_PUBLIC_KEY_TYPE" 2) ("THREE" 3) ("FOUR" 4) ("FIVE" 5)))
       (define-type
         "PublicKey"
         (union (case ("type" "PublicKeyType")
                  (("PUBLIC_KEY_TYPE_ED25519") ("ed25519" "uint256"))
                  (("OTHER_PUBLIC_KEY_TYPE") ("array2" "my-array"))
                  (("ANOTHER_PUBLIC_KEY_TYPE") ("myint" "int"))
                  (("FIVE") ("myunion" (union (case ("tagtype" "PublicKeyType") (("THREE") ("myint" "int")) (else "void")))))
                  (else "void"))))))
  
  (define test-ast-literal-tag-value
    #'((define-type
         "PublicKeyType"
         (enum ("PUBLIC_KEY_TYPE_ED25519" 0) ("OTHER_PUBLIC_KEY_TYPE" 1) ("ANOTHER_PUBLIC_KEY_TYPE" 2) ("THREE" 3) ("FOUR" 4)))
       (define-type
         "PublicKey"
         (union (case ("type" "PublicKeyType")
                  (("PUBLIC_KEY_TYPE_ED25519") ("ed25519" "uint256"))
                  (("OTHER_PUBLIC_KEY_TYPE") ("array2" "my-array"))
                  ((2) ("myint" "int"))
                  (else "void"))))))

  (define test-sym-table
    (parse-ast test-ast))

  (define test-sym-table-2
    (parse-ast test-ast-literal-tag-value)))

; generate an identifier for a grammar rule:
(define (rule-id str)
  ; generate unique indices
  (define get-index! (generator ()
                                (let loop ([index 0])
                                  (yield index)
                                  (loop (+ index 1)))))
  ; Rosette seems to be relying on source-location information to create symbolic variable names.
  ; Since we want all grammar holes to be independent, we need to use a unique location each time.
  (format-id #f "~a-rule" str #:source (make-srcloc (format "~a-rule:~a" str (get-index!)) 1 0 1 0)))

(define (rule-hole str)
  #`(#,(rule-id str)))

#;(define (constant-hole c)
  (cond
    [(string? c) #`(bv #,(hash-ref sym-table c) (bitvector 32))]
    [(number? c) #`(bv ,c (bitvector 32))]
    [else (error "c should be a string or number")]))

; adds enum constants to symbol table
; NOTE What about nested enums? Not used in Stellar
; TODO this is not needed if defining enum consts
#;(define (with-enum-consts sym-table)
  (if (hash-empty? sym-table)
      sym-table
      (let ([enum-consts
             (apply hash-union
                    (hash-map sym-table
                              (λ (k v)
                                (match v
                                  [(enum-type vs) vs]
                                  [_ '#hash()]))))])
        (hash-union sym-table enum-consts))))

; returns a list of definitions (as syntax objects)
(define (const-definitions stx sym-table)
  (if (hash-empty? sym-table)
      #'(void)
      (let* ([enum-consts
              (apply hash-union
                     (hash-map sym-table
                               (λ (k v)
                                 (match v
                                   [(enum-type vs) vs]
                                   [_ '#hash()]))))] ; TODO use for/hash
             [top-level-consts
              (for/hash ([(k v) (in-hash sym-table)] #:when (number? v)) (values k v))]
             [all-consts (hash-union enum-consts top-level-consts)]
             [defs (hash-map all-consts
                             (λ (k v)
                               (begin
                                 (if (not (number? v)) (error "only literal numbers are supported in enums") (void))
                                 #`(define #,(format-id stx k) #,v))))])
        defs)))

#;(module+ test
  (provide with-enum-consts/test)
  (define-test-suite with-enum-consts/test
    (test-case
     "with-enum-consts"
     (check-equal?
      (with-enum-consts test-sym-table)
      '#hash(("ANOTHER_PUBLIC_KEY_TYPE" . 2)
             ("FALSE" . 0)
             ("FIVE" . 5)
             ("FOUR" . 4)
             ("OTHER_PUBLIC_KEY_TYPE" . 1)
             ("PUBLIC_KEY_TYPE_ED25519" . 0)
             ("PublicKey"
              .
              #s(union-type
                 "type"
                 "PublicKeyType"
                 #hash((else . "void")
                       ("ANOTHER_PUBLIC_KEY_TYPE" . ("myint" . "int"))
                       ("FIVE"
                        .
                        ("myunion"
                         .
                         #s(union-type
                            "tagtype"
                            "PublicKeyType"
                            #hash((else . "void") ("THREE" . ("myint" . "int"))))))
                       ("OTHER_PUBLIC_KEY_TYPE" . ("array2" . "my-array"))
                       ("PUBLIC_KEY_TYPE_ED25519" . ("ed25519" . "uint256")))))
             ("PublicKeyType"
              .
              #s(enum-type
                 #hash(("ANOTHER_PUBLIC_KEY_TYPE" . 2)
                       ("FIVE" . 5)
                       ("FOUR" . 4)
                       ("OTHER_PUBLIC_KEY_TYPE" . 1)
                       ("PUBLIC_KEY_TYPE_ED25519" . 0)
                       ("THREE" . 3))))
             ("THREE" . 3)
             ("TRUE" . 1)
             ("bool" . #s(enum-type #hash(("FALSE" . 0) ("TRUE" . 1))))
             ("my-array" . #s(fixed-length-array-type "uint256" 2))
             ("uint256" . #s(opaque-fixed-length-array-type 32)))))))

; replace else variants in unions by enumerating all tag values covered by the else case.
; TODO Would it be easier to flatten the type hierarchy once and for all in a previous pass?
(define (replace-else sym-table)
  (define (replace-else-in t) ; t is a type representation
    (match t ; NOTE inline type spec in tag-type not supported
      [(union-type tag tag-type variants) ; we assume tag-type is an enum type and all tag values are given by id (not literal values)
       #:when (not (base-type? tag-type))
       (begin
         (dict-for-each variants (λ (k v) (if (number? k) (error (format "literal tag values not supported in union-variant \"~a ~a\"" k v)) (void))))
         (let ([has-else? (ormap (λ (kv) (eq? 'else (car kv))) (dict->list variants))])
           (if has-else?
               (match-let* ([(struct* enum-type ([values (hash-table (id* _) ...)])) (hash-ref sym-table tag-type)] ; all enum values (no 'else here)
                            [(hash-table (tag-id* _) ...) variants]) ; tags appearing in the union (may contain 'else)
                 (let* ([missing-ids (set-subtract id* (set-subtract tag-id* '(else)))]
                        [else-decl (replace-else-in (dict-ref variants 'else))]
                        [old-variants (make-immutable-hash
                                       (dict-map (dict-remove variants 'else)
                                                 (λ (k v)
                                                   (match v
                                                     [`(,acc . ,tp) `(,k ,acc . ,(replace-else-in tp))]
                                                     ["void" `(,k . "void")]))))]
                        [new-variants (make-immutable-hash (map (λ (m) `(,m . ,else-decl)) missing-ids))])
                   (union-type tag tag-type (hash-union old-variants new-variants))))
               t)))]
      [(union-type tag tag-type variants) ; this whole case is just to recurse in variants...
       #:when (base-type? tag-type)
       (let ([new-variants
              (make-immutable-hash
               (dict-map
                variants
                (λ (k v)
                  (match v
                    [`(,acc . ,tp) `(,k ,acc . ,(replace-else-in tp))]
                    ["void" `(,k . "void")]))))])
         (union-type tag tag-type variants))]
      [(xdr-struct-type name fields)
       (let ([new-fields (for/list ([f fields]) ; TODO: can a struct member be void?
                           (match-let ([`(,acc . ,tp) f])
                             `(,acc . ,(replace-else-in tp))))])
         (xdr-struct-type name new-fields))]
      ; TODO non-opaque arrays
      [_ t]))
  (for/hash ([kv (hash->list sym-table)])
    (values (car kv) (replace-else-in (cdr kv)))))

(module+ test
  (provide replace-else/test)
  (define-test-suite replace-else/test
    
    (test-case
     "replace-else"
     (check-equal?
      (hash-ref (replace-else test-sym-table) "PublicKey")
      '#s(union-type
          "type"
          "PublicKeyType"
          #hash(("ANOTHER_PUBLIC_KEY_TYPE" . ("myint" . "int"))
                ("FIVE"
                 .
                 ("myunion"
                  .
                  #s(union-type
                     "tagtype"
                     "PublicKeyType"
                     #hash(("ANOTHER_PUBLIC_KEY_TYPE" . "void")
                           ("FIVE" . "void")
                           ("FOUR" . "void")
                           ("OTHER_PUBLIC_KEY_TYPE" . "void")
                           ("PUBLIC_KEY_TYPE_ED25519" . "void")
                           ("THREE" . ("myint" . "int"))))))
                ("FOUR" . "void")
                ("OTHER_PUBLIC_KEY_TYPE" . ("array2" . "my-array"))
                ("PUBLIC_KEY_TYPE_ED25519" . ("ed25519" . "uint256"))
                ("THREE" . "void")))))
    
    (test-case
     "literal tag value"
     (check-exn exn:fail?
                (λ () (replace-else (parse-ast test-ast-literal-tag-value)))))))

; TODO make definitions struct types

; extract type from enum variant spec
(define (variant-type v)
  (match v
    [`(,_ . ,t) t]
    ["void" "void"]
    [_ (error "v should be a pair or \"void\"")]
  ))

(define (get-const-value stx k) ; TODO use defined consts
  (if (number? k) k (format-id stx "~a" k)))

; rule-body returns a rule body for the type t
(define (rule-body stx-context t)
  ; NOTE Here we assume all 'else cases have been removed from unions
  (match t
    ["void" #'null]
    ["int" #'(?? (bitvector 32))]
    ["unsigned-int" #'(?? (bitvector 32))]
    ["hyper" #'(?? (bitvector 64))]
    ["unsigned-hyper" #'(?? (bitvector 64))]
    [s #:when (string? s) ; A type symbol: call its rule
       (rule-hole s)]
    ; Opaque fixed-length array. Represented by a bitvector.
    [(opaque-fixed-length-array-type nbytes)
     #`(?? (bitvector #,(* nbytes 8)))]
    [(opaque-variable-length-array-type max-length) ; a pair (length . data) where data is a bitvector
     ; TODO we will need a constraint saying that the first 4 bytes is the length...
     #`(cons #,max-length (?? (bitvector #,(* max-length 8))))]
    [(string-type nbytes)
     ; a pair (length . data) where data is a bitvector
     ; TODO should it be a sequence of bytes?
     ; TODO we will need a constraint saying that the first 4 bytes is the length...
     ; For now the length will be 2
     #`(cons (bv 2 32) (?? (bitvector 64)))]
    ; Fixed length array. Represented by a vector.
    ; TODO would it be better to create a rule for the element type if it's an inline type?
    [(fixed-length-array-type elem-type size)
     (let* ([elem-body (rule-body  stx-context elem-type)]
            [body #`(vector
                     #,@(for/list ([i (in-range (get-const-value stx-context size))]) elem-body))])
       body)]
    [(variable-length-array-type elem-type max-size) ; a pair (length . data) where data is a vector
     ; TODO we will need a constraint saying that the first 4 bytes is the length...
     ; In the meantime, let's just have 1 element
     (let* ([elem-body (rule-body  stx-context elem-type)]
            [body #`(cons 1 (vector elem-body))])
       body)]
    [(struct* enum-type ([values (hash-table (_ v*) ...)]))
     (let* ([bvs (map (λ (w) #`(bv #,w (bitvector 32))) v*)])
       #`(choose #,@bvs))]
    [(union-type tag tag-type variants)
     ; Variants can in principle refer to enum constants defined inline in the tag type, but we don't support inline tag types.
     ; The type of a variant can however be an inline type specification.
     (begin
       (if (not (string? tag-type)) (error "we do not support inline tag types") (void))
       (let* ([bodys ; a dict mapping tag-identifier to body
               (dict-map variants ;'(tag-value accessor . type) where type is not void, or '(tag-value . void)
                         (λ (k v) (cons k (rule-body  stx-context (variant-type v)))))]
              [bodys
               (dict-map bodys
                         (λ (k b)
                           (let ([tag-val (get-const-value stx-context k)])
                             #`(cons (bv #,tag-val (bitvector 32)) #,b))))]
              [body #`(choose #,@bodys)])
         body))]
    ; Here we need to generate a Racket struct type too; we'll do that in another pass
    [(struct* xdr-struct-type
              ([fields `((,_ . ,spec*) ...)]
               [name name]))
     (match-let*
         ([`(,body* ...) (map ((curry rule-body) stx-context) spec*)]
          [struct-name (format-id stx-context "~a" name)]
          [b #`(#,struct-name #,@body*)])
       b)]
    [else (error (format "unhandled type: ~a; this is a bug" else))]))

; a few tests
; TODO to write unit tests we need a way to compare grammars...
; See equal?/recur or something like that.
#|
(rule-body '#hash() #'() (fixed-length-array-type (opaque-fixed-length-array-type 32) 3))
(rule-body  '#hash() #'() (fixed-length-array-type "some-type" 3))
(rule-body  '#hash() #'() (enum-type #hash(("A" . 1) ("B" . 2))))
(rule-body '#hash(("V1" . 1) ("V2" . 2) ("V3" . 3)) #'() (union-type "tag" "my-other-type" #hash(("V1" . ("acc" . "my-type")) ("V2" . ("acc2" . "my-type-2")) ("V3" . "void"))))
(rule-body  '#hash() #'() (xdr-struct-type "my-struct" '(("A" . "my-type") ("B" . "my-int"))))
|#
; deps returns the dependencies used in the rule body for type t
(define (deps t)
  ; NOTE Here we assume all 'else cases have been removed from unions
  ; NOTE We need the sym-table to look up the values of constants. TODO If we had defined symbols for them instead, then we wouldn't need that.
  (let ([res
  (match t
    ["void" null]
    [s #:when (string? s)
       (list s)]
    ; Opaque fixed-length array. Represented by a bitvector.
    [(opaque-fixed-length-array-type nbytes) null]
    ; Fixed length array. Represented by a vector.
    [(fixed-length-array-type elem-type size) (deps elem-type)]
    [(enum-type values) null]
    [(fixed-length-array-type type length) (deps type)]
    [(variable-length-array-type type max-length) (deps type)]
    [(union-type tag tag-type variants)
     ; Variants can in principle refer to enum constants defined inline in the tag type, but we don't support inline tag types.
     ; The type of a variant can however be an inline type specification.
     (begin
       (if (not (string? tag-type)) (error "we do not support inline tag types") (void))
       (let* ([rec-deps
               (apply set-union
                      (dict-map variants
                                (λ (k v) (deps (variant-type v)))))]
              [tag-type-dep
               (if (member tag-type '("int" "unsigned int"))
                   '()
                   (list tag-type))]
              [all-deps (set-union tag-type-dep rec-deps)])
         all-deps))]
    [(struct* xdr-struct-type ([fields `((,_ . ,spec*) ...)]))
     (let ([all-deps (apply set-union (map deps spec*))])
       all-deps)]
    [_ null])]) res))

(define (type-rep sym-table t)
  (if (base-type? t)
      t
      (hash-ref sym-table t)))

(define (xdr-types->grammar sym-table stx-context type)
  (let* ([sym-table (replace-else sym-table)]
         [type-deps
          (let deps/rec ([t (hash-ref sym-table type)])
            (let* ([t-deps (filter (λ (t) (not (base-type? t))) (deps t))]
                   [deps-deps
                    (map (λ (u)
                           (if (equal? (hash-ref sym-table u) t)
                               null ; don't recurse if we have a recursive type
                               (deps/rec (hash-ref sym-table u)))) t-deps)])
              (apply set-union (set-add deps-deps t-deps))))]
         [rule (λ (name t) #`(#,(rule-id name) #,(rule-body stx-context t)))]
         [bodys (cons (rule type (type-rep sym-table type)) (set-map type-deps (λ (t) (rule t (type-rep sym-table t)))))])
    #`(define-grammar (#,(format-id stx-context "~a" "the-grammar")) #,@bodys)))

;(xdr-types->grammar '#hash() #'() (fixed-length-array-type (opaque-fixed-length-array-type 32) 3))
;(xdr-types->grammar  '#hash(("some-type" . "int")) #'() (fixed-length-array-type "some-type" 3))
;(xdr-types->grammar  '#hash() #'() (enum-type #hash(("A" . 1) ("B" . 2))))
;(xdr-types->grammar '#hash(("V1" . 1) ("V2" . 2) ("V3" . 3)) #'() (union-type "tag" "my-other-type" #hash(("V1" . ("acc" . "my-type")) ("V2" . ("acc2" . "my-type-2")) ("V3" . "void"))))
;(xdr-types->grammar  '#hash() #'() (xdr-struct-type "my-struct" '(("A" . "my-type") ("B" . "my-int"))))

(module+ test
  (provide xdr-types->grammar/test)
  (define-test-suite xdr-types->grammar/test
    (test-case
     "xdr-types->grammar does not throw exceptions"
     (check-not-exn
      (λ ()
        (xdr-types->grammar test-sym-table #'() "PublicKey"))))))

; TODO generate a Rosette grammar for this:
#;(xdr-types->grammar
 (stellar-symbol-table)
 #'()
 "TransactionEnvelope")

;(test-grammar)