#lang rosette

(require
  rosette/lib/synthax
  (for-syntax "grammar-generator.rkt" racket/syntax))

(define-syntax (define-g stx)
  #`(define-grammar (#,(format-id stx "g")) #,(test-grammar)))

(define-g)

(define sol
  (synthesize
   #:forall '()
   #:guarantee (assert (equal? (g #:depth 1) (bv 1 32)))))

(generate-forms sol)