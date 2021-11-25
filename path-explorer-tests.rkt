#lang rosette

(require rackunit "./path-explorer.rkt" rosette/lib/destruct syntax/macro-testing)

(define-with-path-explorer (test-if i) (if (<= 0 i) (if (<= 1 i) 'strict-pos 'zero) 'neg))
(define-symbolic i integer?)
(let ([model (solve (test-if-path-explorer (constant-gen 1) i))])
  (check-equal? (evaluate i model) -1))

(clear-terms!)

(define-with-path-explorer (test-cond i)
  (cond [(< 0 i) 'strict-pos]
        [(equal? 0 i) 'zero]
        [(> 0 i) 'neg]))
(let ([model (solve (test-cond-path-explorer (constant-gen 1) i))])
  (check-equal? (evaluate i model) 0))

(clear-terms!)

(define-with-path-explorer (test-cond-else i)
  (cond [(< 0 i) 'strict-pos]
        [(equal? 0 i) 'zero]
        [else 'neg]))

(let ([model (solve (test-cond-else-path-explorer (constant-gen 1) i))])
  (check-equal? (evaluate i model) 0))
(let ([model (solve (test-cond-else-path-explorer (constant-gen 2) i))])
  (check-equal? (< (evaluate i model) 0) #t))

(clear-terms!)

(struct s1 (x))
(struct s2 (y))
(define-with-path-explorer (test-destruct s)
  (destruct s
            [(s1 a) "foo"]
            [(s2 b) "bar"]
            #;[_ (assert #f)]))

(define-symbolic x boolean?)
(define in (if x (s1 0) (s2 0)))

(let ([model (solve (test-destruct-path-explorer (constant-gen 1) in))])
  (check-equal? (evaluate x model) #f))

; TODO test lambda etc. and test with definition with nested conditionals
