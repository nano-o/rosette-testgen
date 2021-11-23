#lang rosette

(require racket/generator)
(require (for-syntax syntax/parse)
         syntax/parse/define)

; we'll use a generator to produce numbers that encode which branch to take
(define constant-gen-0
  (generator (n)
             (let loop ()
               (begin
                 (yield 0)
                 (loop)))))
(define random-gen
  (generator (n)
             (let loop ()
               (begin
                 (yield (random n))
                 (loop)))))

(define g random-gen)

; now let's write a macro that takes a program and creates a Rosette program that follows the path given by the generator
(define-syntax (define-path-explorer stx)
  (syntax-parse stx
    [(_ (name arg0 ...) body)
     #'(define (name arg0 ...)
         (path-explorer body))]))

(define (print-branch branch c)
  (println (format "branch ~a; assuming: ~a" branch c)))

(define-syntax (path-explorer stx)
  (syntax-parse stx
    #:literals (if cond)
    [(_ (if c then-branch else-branch))
     #'(let ([branch (g 2)])
         (if (equal? branch 0)
             (begin
               (print-branch branch (syntax->datum #'c)) ; TODO how to make this a macro?
               (assume c)
               (path-explorer then-branch))
             (begin
               (print-branch branch (syntax->datum #'(! c)))
               (assume (! c))
               (path-explorer else-branch))))]
    [(_ (cond ([c0 body0] ...)))
     (with-syntax ([how-many (length (syntax->list #'(c0 ...)))])
     #'(let ([branch (g how-many)])
         (begin
           (assume (list-ref (list c0 ...) branch))
           (list-ref (list body0 ...) branch))))]
; TODO is there a "default" mechanism for the following?
    [(_ (x ...)) #'(x ...)]
    [(_ x) #'x]))

(define-symbolic i integer?)

;(define-path-explorer (test-1 i) (if (<= 0 i) (if (<= 1 i) 'strict-pos 'zero) 'neg))

(define-path-explorer (test-2 i)
  (cond ([(< 0 i) 'strict-pos]
         [(equal? 0 i) 'zero]
         [(< i 0) 'neg])))

;(test-1 0)
;(test-2 0)


; this gives us an input that satisfies the path condition given by the generator.
;(solve (test-1 i))
(solve (test-2 i))

