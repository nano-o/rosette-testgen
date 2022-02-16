#lang racket

(require
  racket/match racket/syntax racket/generator racket/hash
  "xdr-compiler.rkt" ;"guile-ast-example.rkt"
  (for-template rosette rosette/lib/synthax))
(provide xdr-types->grammar)

(module+ test
  (require rackunit)
  (provide test-sym-table test-grammar))

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
         (enum ("PUBLIC_KEY_TYPE_ED25519" 0) ("OTHER_PUBLIC_KEY_TYPE" 1) ("ANOTHER_PUBLIC_KEY_TYPE" 2)))
       (define-type
         "PublicKey"
         (union (case ("type" "PublicKeyType")
                  (("PUBLIC_KEY_TYPE_ED25519") ("ed25519" "uint256"))
                  (("OTHER_PUBLIC_KEY_TYPE") ("array2" "my-array"))
                  (("ANOTHER_PUBLIC_KEY_TYPE") ("myint" "int"))
                  (else "void"))))))

  (define test-sym-table
    (parse-ast test-ast)))

(define (hash-merge h . rest)
  (apply hash-union h rest
         #:combine (λ (v1 v2)
                     (if (not (equal? v1 v2))
                         (error "cannot merge hash maps with conflicting keys")
                         v1))))

(module+ test
  (define-test-suite hash-merge/test
    (test-case
     "successful merge"
     (check-equal?
      (let ([h1 '#hash(('a . 'b) ('e . 'f))]
            [h2 '#hash(('a . 'b) ('c . 'd))])
        (hash-merge h1 h2))
      '#hash(('a . 'b) ('c . 'd) ('e . 'f))))
    (test-case
     "successful multiple merges"
     (check-equal?
      (let ([h1 '#hash(('a . 'b) ('e . 'f))]
            [h2 '#hash(('a . 'b) ('c . 'd))]
            [h3 '#hash(('c . 'd) ('g . 'h))])
        (hash-merge h1 h2 h3))
      '#hash(('a . 'b) ('c . 'd) ('e . 'f) ('g . 'h))))
    (test-case
     "failed merge"
     (check-exn exn:fail?
                (λ () 
                  (let ([h1 '#hash(('a . 'b))]
                        [h2 '#hash(('a . 'c))])
                    (hash-merge h1 h2)))))))

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

; body-depss returns a rule body for the type t and a list of types whose rules the body depends on.
(define (body-deps t)
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
     (match-let* ([(cons elem-body deps) (body-deps elem-type)]
                  [body #`(vector
                           #,@(for/list ([i (in-range size)]) elem-body))])
       (cons body deps))]
    [`(enum ,kv ...)
     (let* ([vs (map cdr kv)]
            [bvs (map (λ (v) #`(bv #,v (bitvector 32))) vs)])
       (list #`(choose #,@bvs)))]
    [`(union (,tag . ,tag-type) ,variants)
     ; Variants can in principle refer to enum constants defined inline in tag-type, but we don't support that inline tag-types.
     ; The type of a variant can however be an inline type specification.
     (begin
       (if (not (string? tag-type)) (error "we do not support inline tag types") (void))
       ; variant accessor -> body dependencies
       (let* ([vs-body-deps (make-immutable-hash
                        (hash-map variants ;'(tag-value accessor . type) where type is not void, or '(tag-value . void)
                                  (λ (k v) (if (eq? (cdr v) void)
                                               (list (car v) #'())
                                               (cons (car v) (body-deps (cdr v)))))))]
             [deps (append
                    (if (member tag-type '("int" "unsigned int"))
                        '()
                        (list tag-type))
                    (flatten (hash-map
                              vs-body-deps
                              (λ (k v)
                                (if (pair? v)
                                    (cdr v)
                                    '())))))])
         `(#'() . ,deps)))]))

; a few tests
(body-deps '(fixed-length-array (opaque-fixed-length-array . 32) . 3))
(body-deps '(fixed-length-array "some-type" . 3))
(body-deps '(enum ("A" . 1) ("B" . 2)))
(body-deps '(union ("tag" . "my-other-type") #hash(("V1" . ("acc" . "my-type")) ("V2" . ("acc2" . "my-type-2")))))

(define (xdr-types->grammar sym-table type) null)

(module+ test
  (define (test-grammar)
    (xdr-types->grammar test-sym-table "PublicKey")))

;(test-grammar)