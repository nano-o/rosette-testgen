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

; make-rules returns a rule body for the type t and a list of types whose rules the body depends on.
(define (make-rule t)
  (match t
    ["void" (cons #'null null)]
    ["int" (cons #'(?? (bitvector 32)) null)]
    ["unsigned-int" (cons #'(?? (bitvector 32)) null)]
    ["hyper" (cons #'(?? (bitvector 64)) null)]
    ["unsigned-hyper" (cons #'(?? (bitvector 64)) null)]
    [s #:when (string? s)
       (cons (rule-hole s) (list s))]
    ; Opaque fixed-length array. Represented by a bitvector.
    [`(opaque-fixed-length-array . ,nbytes)
     (cons #`(?? (bitvector #,(* nbytes 8))) null)]
    ; Fixed length array. Represented by a vector.
    ; TODO would it be better to create a rule for the element type if it's an inline type?
    [`(fixed-length-array ,elem-type . ,size)
     (match-let* ([(cons elem-body deps) (make-rule elem-type)]
                  [body #`(vector
                           #,@(for/list ([i (in-range size)]) elem-body))])
       (cons body deps))]
    [`(enum ,kv ...) 'TODO]))

; a few tests
(make-rule '(fixed-length-array (opaque-fixed-length-array . 32) . 3))
(cdr (make-rule '(fixed-length-array "some-type" . 3)))

(define (xdr-types->grammar sym-table type) null)

(module+ test
  (define (test-grammar)
    (xdr-types->grammar test-sym-table "PublicKey")))

;(test-grammar)