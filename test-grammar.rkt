#lang rosette

(require
  rosette/lib/synthax  syntax/parse/define
  (for-syntax "grammar-generator.rkt"))

(define-syntax-parser make-test-grammar
  [(_ i:id)
   #`(define-grammar (i) #,@(test-grammar))])

(make-test-grammar g)

(define sol
  (synthesize
   #:forall '()
   #:guarantee (assert (equal? (g #:depth 2) (list (bv 2 256) (bv 1 256))))))

(generate-forms sol)