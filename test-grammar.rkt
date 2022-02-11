#lang rosette

(require
  rosette/lib/synthax  syntax/parse/define
  (for-syntax "grammar-generator.rkt" racket/syntax))

(define-syntax-parser make-test-grammar
  [(_ i:id)
   #`(define-grammar (i) #,@(test-grammar))])

#;(define-syntax (define-g stx)
  #`(define-grammar (#,(format-id stx "g")) #,@(test-grammar)))

(make-test-grammar g)


#;(define-grammar (g2) [my-array-rule (list (uint256-rule) (uint256-rule))] [uint256-rule (?? (bitvector 256))])

(define sol
  (synthesize
   #:forall '()
   #:guarantee (assert (equal? (g #:depth 2) (list (bv 2 256) (bv 1 256))))))

#;(define sol2
  (synthesize
   #:forall '()
   #:guarantee (assert (equal? (g2 #:depth 2) (list (bv 2 256) (bv 1 256))))))

(generate-forms sol)