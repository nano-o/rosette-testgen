#lang racket

(require rackunit)
(provide flatten-one-level)

(define (flatten-one-level ll)
  (for/fold ([res null])
            ([l ll])
    (append res l)))

(module+ test
  (provide flatten-one-level/test)
  (define-test-suite flatten-one-level/test
    (test-case
     "flatten-one-level"
     (check-equal?
      (flatten-one-level '(((a . b) (c . d)) ((e . f))))
      '((a . b) (c . d) (e . f))))))