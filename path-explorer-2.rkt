#lang rosette

(require
  (for-syntax syntax/parse racket/syntax)
  macro-debugger/expand
  racket/stxparam "./generators.rkt" syntax/parse)

;(provide (for-syntax define/path-explorer) all-paths (for-syntax debug?))

(define-syntax-parameter the-generator (lambda (stx) (raise-syntax-error (syntax-e stx) "can only be used inside path-explorer")))

; now let's write a macro that takes a racket definition and creates a Rosette program that follows the path given by a generator

(begin-for-syntax
  (define debug? #t)

  (define (explorer-id x)
    (format-id x "~a/path-explorer" x))

  ; Now we define a syntax class that synthesize the path-explorer version of a function's body.
  ; The syntax class should match a subset of Racket expressions that we want to use in our specifications.
  ; TODO report an error if something's not supported
  ; NOTE we need to be careful about evaluation order, essentially mimicking CPS

  ; synthesize debug printout
  (define (print-branch i c)
    (let ([str (format "branch number ~a with condition ~a" i (syntax->datum c))])
      (if debug?
          #`((println #,(datum->syntax #'() str)))
          #'())))

  (define-syntax-class (has-path-explorer)
    (pattern x:id #:when (identifier-binding (explorer-id #'x))))

  (define-syntax-class ex
    #:description "an expression amenable to path-exploration"
    [pattern ((~or (~literal let) (~literal let*)) bindings body:ex)
             ; TODO: recurse in the bindings
             #:attr res #`(let bindings body.res)]
    [pattern e:if-expr
             #:attr res #'e.res]
    [pattern (fn:has-path-explorer arg0:ex ...)
             #:attr res #`(#,(explorer-id #'fn) the-generator arg0.res ...)]
    [pattern (fn:id arg0:ex ...)
             #:attr res #'(fn arg0.res ...)]
    [pattern (~or _:id _:number)
             #:attr res this-syntax])

  (define-syntax-class if-expr
    #:description "an if expression"
    [pattern ((~literal if) cond:ex then:ex else:ex)
             #:attr res #`(let ([c cond.res] ; NOTE it's important to evaluate cond.expr first
                                [i (the-generator 2)])
                            (if (equal? i 0)
                                (begin
                                  #,@(print-branch 0 #'cond)
                                  (assume c)
                                  then.res)
                                (begin
                                  #,@(print-branch 1 #'(not cond))
                                  (assume (not c))
                                  else.res)))]))

(define-syntax (define/path-explorer stx)
  (syntax-parse stx
    [(_ (name:id arg0:id ...) body:ex)
     (if debug? (println (format "synthesizing ~a/path-explorer" (syntax->datum #'name))) (void)) ; this runs at compile-time
     #`(begin
         (define (#,(explorer-id #'name) gen arg0 ...)
           (syntax-parameterize ([the-generator (make-rename-transformer #'gen)])
             body.res))
         (define (name arg0 ...)
           body))]))

;(pretty-display (syntax->datum
;(expand-only #'
;             (begin
(define/path-explorer (test-2 x)
  (if (< x 3)
      (+ x 1)
      (- x 1)))
(define/path-explorer (test x)
  (if (< (test-2 x) 0)
      (void)
      (void)))
;) (list #'define-with-path-explorer #'path-explorer))))

; all-paths return a stream of solutions
(define (all-paths prog) ; prog must take a generator as argument
  (define gen (exhaustive-gen))
  (define (go)
    (let ([solution
           (solve (prog gen))])
      (begin
        (displayln (format "End of execution path; SAT: ~a" (sat? solution)))
        (if (equal? (gen 0) 0) (stream-cons solution (go)) (stream-cons solution empty-stream)))))
  (go))

(define-symbolic x integer?)
(for ([m (stream->list (all-paths (λ (gen) (test/path-explorer gen x))))])
  (displayln m))