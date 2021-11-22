#lang rosette

(require racket/generator)
(require (for-syntax syntax/parse)
         syntax/parse/define)

; we'll use a generator to produce numbers that encode which branch to take
(define g (generator () 0))

; now let's write a macro that takes a program and creates a Rosette program that follows the path given by the generator
(define-syntax (define-path-explorer stx)
  (syntax-parse stx
    [(_ (name arg0 ...) body)
     #'(define (name arg0 ...)
         (path-explorer body))]))

(define-syntax (path-explorer stx)
  (syntax-parse stx
    [(_ (literal c then-branch else-branch)) ; TODO: how to match only the "real" if?
     #`(if (equal? (g) 0)
        (begin
         (assume c)
         then-branch)
        (begin
          (assume (! c))
          else-branch))]
    [(_ (x ...))
     #'(begin
         (println "ha")
         (x ...))]))

(define-symbolic b boolean?)
(define-path-explorer (test cond) (if cond #f #t))
(solve (test b))