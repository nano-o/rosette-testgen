#lang racket

(require rackunit  racket/hash)
(provide flatten-one-level hash-merge)

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

(define (hash-merge h . rest)
  (apply hash-union h rest
         #:combine (λ (v1 v2)
                     (if (not (equal? v1 v2))
                         (error "cannot merge hash maps with conflicting keys")
                         v1))))

(module+ test
  (provide hash-merge/test)
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