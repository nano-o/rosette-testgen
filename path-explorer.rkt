#lang rosette

(require racket/generator)
(require (for-syntax syntax/parse)
         syntax/parse/define)

; we'll use a generator to produce numbers that encode which branch to take
#;(define g
  (generator (n)
             (let loop ()
               (begin
                 (yield 0)
                 (loop)))))
(define g
  (generator (n)
             (let loop ()
               (begin
                 (yield (random n))
                 (loop)))))

; now let's write a macro that takes a program and creates a Rosette program that follows the path given by the generator
(define-syntax (define-path-explorer stx)
  (syntax-parse stx
    [(_ (name arg0 ...) body)
     #'(define (name arg0 ...)
         (path-explorer body))]))

; TODO better trace prints
(define-syntax (path-explorer stx)
  (syntax-parse stx
    #:literals (if cond)
    [(_ (if c then-branch else-branch))
     #'(let ([branch (g 2)])
         (if (equal? branch 0)
             (begin
               (println (format "branch ~a; assuming: ~a" branch (syntax->datum #'c)))
               (assume c)
               (path-explorer then-branch))
             (begin
               (println (format "branch ~a; assuming: ~a" branch #'(! c)))
               (assume (! c))
               (path-explorer else-branch))))]
; TODO is there a "default" mechanism for this?
    [(_ (x ...))
     #'(begin
         (x ...))]
    [(_ x)
     #'(begin
         x)]))

(define-symbolic i integer?)
(define-path-explorer (test i) (if (<= 0 i) (if (<= 1 i) 'strict-pos 'zero) 'neg))

;(test 0)


; this gives us an input that satisfies the path condition given by the generator.
(solve (test i))