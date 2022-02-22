#lang racket

(require
  racket/match racket/syntax racket/generator racket/hash
  "xdr-compiler.rkt" ;"guile-ast-example.rkt"
  "util.rkt"
  #;(for-template rosette rosette/lib/synthax))
(provide xdr-types->grammar)

(module+ test
  (require rackunit)
  (provide test-sym-table test-grammar test-sym-table-2))

; TODO generate a Rosette grammar for this:
#; (hash-ref
 (stellar-symbol-table)
 "TransactionEnvelope")

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
         (enum ("PUBLIC_KEY_TYPE_ED25519" 0) ("OTHER_PUBLIC_KEY_TYPE" 1) ("ANOTHER_PUBLIC_KEY_TYPE" 2) ("THREE" 3) ("FOUR" 4)))
       (define-type
         "PublicKey"
         (union (case ("type" "PublicKeyType")
                  (("PUBLIC_KEY_TYPE_ED25519") ("ed25519" "uint256"))
                  (("OTHER_PUBLIC_KEY_TYPE") ("array2" "my-array"))
                  (("ANOTHER_PUBLIC_KEY_TYPE") ("myint" "int"))
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
; TODO What about nested enums? Not used in Stellar
(define (with-enum-consts sym-table)
  (let ([enum-consts
         (apply hash-union
          (hash-map sym-table
                    (λ (k v)
                      (match v
                        [(struct* enum-type ([values vs])) vs]
                        [_ '#hash()]))))])
    (hash-union sym-table enum-consts)))

(module+ test
  (provide with-enum-consts/test)
  (define-test-suite with-enum-consts/test
    (test-case
     "with-enum-consts"
     (check-equal?
      (with-enum-consts test-sym-table)
      '#hash(("ANOTHER_PUBLIC_KEY_TYPE" . 2)
             ("FALSE" . 0)
             ("FOUR" . 4)
             ("OTHER_PUBLIC_KEY_TYPE" . 1)
             ("PUBLIC_KEY_TYPE_ED25519" . 0)
             ("PublicKey"
              .
              #s(union-type
                 "type"
                 "PublicKeyType"
                 #hash(("PUBLIC_KEY_TYPE_ED25519" . ("ed25519" . "uint256"))
                       ("OTHER_PUBLIC_KEY_TYPE" . ("array2" . "my-array"))
                       ("ANOTHER_PUBLIC_KEY_TYPE" . ("myint" . "int"))
                       (else . "void"))))
             ("PublicKeyType"
              .
              #s(enum-type
                 #hash(("PUBLIC_KEY_TYPE_ED25519" . 0)
                       ("OTHER_PUBLIC_KEY_TYPE" . 1)
                       ("ANOTHER_PUBLIC_KEY_TYPE" . 2)
                       ("THREE" . 3)
                       ("FOUR" . 4))))
             ("THREE" . 3)
             ("TRUE" . 1)
             ("bool" . #s(enum-type #hash(("TRUE" . 1) ("FALSE" . 0))))
             ("my-array" . #s(fixed-length-array-type "uint256" 2))
             ("uint256" . #s(opaque-fixed-length-array-type 32)))))))

; replace else variants in unions by enumerating all tag values covered by the else case.
(define (replace-else sym-table)
  (define (replace-else-in t) ; t is a type representation
    (match t
      [(struct* union-type ([tag-name tag] [tag-type tag-type] [variants variants])) ; we assume tag-type is an enum type and all tag values are given by id (not literal values)
       (begin
         (dict-for-each variants (λ (k v) (if (number? k) (error "literal tag values not supported") (void))))
         (let ([has-else? (ormap (λ (kv) (eq? 'else (car kv))) (dict->list variants))])
           (if has-else?
               (match-let* ([(struct* enum-type ([values (hash-table (id* _) ...)])) (hash-ref sym-table tag-type)] ; all enum values (no 'else here)
                            [(hash-table (tag-id* _) ...) variants]) ; tags appearing in the union (may contain 'else)
                 (let* ([missing-ids (set-subtract id* (set-subtract tag-id* '(else)))]
                        [else-decl (dict-ref variants 'else)]
                        [old-variants (dict-remove variants 'else)]; without else
                        [new-variants (make-immutable-hash (map (λ (m) `(,m . ,else-decl)) missing-ids))])
                   (union-type tag tag-type (hash-union old-variants new-variants))))
               t)))]
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
          #hash(("PUBLIC_KEY_TYPE_ED25519" . ("ed25519" . "uint256"))
                ("OTHER_PUBLIC_KEY_TYPE" . ("array2" . "my-array"))
                ("ANOTHER_PUBLIC_KEY_TYPE" . ("myint" . "int"))
                ("FOUR" . "void")
                ("THREE" . "void")))))
    
    (test-case
     "literal tag value"
     (check-exn exn:fail?
                (λ () (replace-else (parse-ast test-ast-literal-tag-value)))))))

; TODO make definitions for constants (including enum values) and struct types

; extract type from enum variant spec
(define (variant-type v)
  (match v
    [`(,_ . ,t) t]
    ["void" "void"]
    [_ (error "v should be a pair or \"void\"")]
  ))

; body-deps returns a rule body for the type t and a list of types whose rules the body depends on.
(define (body-deps sym-table t)
  ; NOTE Here we assume all 'else cases have been removed from unions
  ; NOTE We need the sym-table to look up the values of constants. TODO If we had defined symbols for them instead, then we wouldn't need that.
  (match t
    ["void" (list #'null)]
    ["int" (list #'(?? (bitvector 32)))]
    ["unsigned-int" (list #'(?? (bitvector 32)))]
    ["hyper" (list #'(?? (bitvector 64)))]
    ["unsigned-hyper" (list #'(?? (bitvector 64)))]
    [s #:when (string? s)
       (cons (rule-hole s) (list s))]
    ; Opaque fixed-length array. Represented by a bitvector.
    [`(opaque-fixed-length-array . ,nbytes)
     (list #`(?? (bitvector #,(* nbytes 8))))]
    ; Fixed length array. Represented by a vector.
    ; TODO would it be better to create a rule for the element type if it's an inline type?
    [`(fixed-length-array ,elem-type . ,size)
     (match-let* ([`(,elem-body . ,deps) (body-deps sym-table elem-type)]
                  [body #`(vector
                           #,@(for/list ([i (in-range size)]) elem-body))])
       (cons body deps))]
    [`(enum (,_ . ,v*) ...)
     (let* ([bvs (map (λ (w) #`(bv #,w (bitvector 32))) v*)])
       (list #`(choose #,@bvs)))]
    [`(union (,tag . ,tag-type) ,variants)
     ; Variants can in principle refer to enum constants defined inline in the tag type, but we don't support inline tag types.
     ; The type of a variant can however be an inline type specification.
     (begin
       (if (not (string? tag-type)) (error "we do not support inline tag types") (void))
       (let* ([vs-body-deps ; a dict mapping tag-identifier to '(body . deps)
               (dict-map variants ;'(tag-value accessor . type) where type is not void, or '(tag-value . void)
                         (λ (k v) (cons k (body-deps sym-table (variant-type v)))))]
              [tag-type-dep 
               (if (member tag-type '("int" "unsigned int"))
                   '()
                   (list tag-type))]
              [recursive-deps (apply set-union (dict-map vs-body-deps (λ (k v) (cdr v))))]
              [deps (set-union tag-type-dep recursive-deps)]
              [bodys (map (match-lambda [`(,k ,b . ,d)
                                         #`(cons (bv #,(hash-ref sym-table k) (bitvector 32)) #,b)])
                          (dict->list vs-body-deps))]
              [body #`(choose #,@bodys)])
         `(,body . ,deps)))]
    ; struct TODO
    ; Here we need to generate a Racket struct type too; we'll do that in another pass
    [`(struct (,_ . ,spec*) ...)
     (match-let*
         ([`((,body* . ,deps*) ...) (map ((curry body-deps) sym-table) spec*)]
          [all-deps (apply set-union deps*)]
          [struct-name #'TODO]
          ; TODO we need the name of the struct! Doesn't really fit in the current architecture...
          ; We could create names for anonymous structs and add those names to the struct repr (in a previous pass).
          ; That seems like the easiest short-term solution.
          ; But then we might want to do similar stuff for enums and unions.
          ; TODO we need the right syntax context for the struct name.
          [b #`(#,struct-name #,@body*)])
       `(,b . ,all-deps))]))

; a few tests
(body-deps '#hash() '(fixed-length-array (opaque-fixed-length-array . 32) . 3))
(body-deps  '#hash() '(fixed-length-array "some-type" . 3))
(body-deps  '#hash() '(enum ("A" . 1) ("B" . 2)))
(body-deps '#hash(("V1" . 1) ("V2" . 2) ("V3" . 3)) '(union ("tag" . "my-other-type") #hash(("V1" . ("acc" . "my-type")) ("V2" . ("acc2" . "my-type-2")) ("V3" . "void"))))
(body-deps  '#hash() '(struct ("A" . "my-type") ("B" . "my-int")))

(define (xdr-types->grammar sym-table type) null)

(module+ test
  (define (test-grammar)
    (xdr-types->grammar test-sym-table "PublicKey")))

;(test-grammar)