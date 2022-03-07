#lang rosette

(require
  (for-syntax syntax/parse racket/syntax pretty-format)
  macro-debugger/expand
  racket/stxparam rackunit
  "./generators.rkt")

(provide define/path-explorer all-paths (for-syntax debug?))

(define-syntax-parameter the-generator (lambda (stx) (raise-syntax-error (syntax-e stx) "can only be used inside path-explorer")))

; now let's write a macro that takes a racket definition and creates a Rosette program that follows the path given by a generator

(begin-for-syntax
  (define debug? #t)
  
  ; First we rewrite "or", "and", "case" to "if" expressions
  (define-syntax-class l0
    #:description "the input language"
    [pattern ((~literal let) ([x*:id e*:l0] ...) body:l0)
             ; TODO: recurse in the bindings
             #:attr l1 #`(let ([x* e*.l1] ...) body.l1)]
    [pattern ((~literal let*) ([x*:id e*:l0] ...) body:l0)
             ; TODO: recurse in the bindings
             #:attr l1 #`(let* ([x* e*.l1] ...) body.l1)]
    [pattern ((~literal if) c:l0 then:l0 else:l0)
             #:attr l1 #'(if c.l1 then.l1 else.l1)]
    [pattern ((~literal or) e*:l0 ...)
             #:attr l1 (or->ifs (syntax->list #'(e* ...)))]
    [pattern ((~literal and) e*:l0 ...)
             #:attr l1 (and->ifs (syntax->list #'(e* ...)))]
    [pattern (fn:id arg0:l0 ...)
             #:attr l1 #'(fn arg0.l1 ...)]
    [pattern (~or _:id _:number _:boolean)
             #:attr l1 this-syntax]
    [pattern ((~literal assume) e:expr)
             ; assume expressions are left untouched
             #:attr l1 this-syntax])
  
  (define (or->ifs e*)
    (if (null? e*)
        #'#f
        (with-syntax
            ([rest (or->ifs (cdr e*))])
          #`(if #,(car e*)
                #t
                rest))))

  (define (and->ifs e*)
    (if (null? e*)
        #'#t
        (with-syntax
            ([rest (and->ifs (cdr e*))])
          #`(if #,(not (car e*))
                #f
                rest))))
  
  ; Next we synthesize path-explorer expressions

  ; a set containing the function names that have a path explorer
  (define fn-with-explorer (mutable-set))
  
  (define (explorer-id x)
    (format-id x "~a/path-explorer" x))

  ; Now we define a syntax class that synthesize the path-explorer version of a function's body.
  ; The syntax class should match a subset of Racket expressions that we want to use in our specifications.
  ; TODO report an error if something's not supported.
  ; NOTE we need to be careful about evaluation order, essentially mimicking CPS.

  ; synthesize debug printout
  (define (print-branch i c)
    (let ([str (pretty-format "branch number ~a with condition ~a" i (syntax->datum c))])
      (if debug?
          #`((displayln #,(datum->syntax #'() str)))
          #'())))

  (define-syntax-class (has-path-explorer)
    [pattern x:id
             #:when (set-member? fn-with-explorer (syntax-e #'x))])

  (define-syntax-class l1
    ; TODO "and" and "or"
    #:description "an expression amenable to path-exploration"
    [pattern ((~literal let*) bindings body:l1)
             ; TODO: recurse in the bindings
             #:attr res #`(let* bindings body.res)]
    [pattern ((~literal let) bindings body:l1)
             ; TODO: recurse in the bindings
             #:attr res #`(let bindings body.res)]
    [pattern e:if-expr
             #:attr res #'e.res]
    [pattern (fn:has-path-explorer arg0:l1 ...)
             #:attr res #`(#,(explorer-id #'fn) the-generator arg0.res ...)]
    [pattern (fn:id arg0:l1 ...)
             #:attr res #'(fn arg0.res ...)]
    [pattern (~or _:id _:number _:boolean)
             #:attr res this-syntax]
    [pattern ((~literal assume) e:expr)
             ; assume expressions are left untouched
             #:attr res this-syntax])
    
  (define-syntax-class if-expr
    #:description "an if expression"
    [pattern ((~literal if) cond:l1 then:l1 else:l1)
             #:attr res #`(let ([c cond.res]) ; NOTE it's important to evaluate cond.expr first
                            (if (equal? (the-generator 2) 0)
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
    [(_ (name:id arg0:id ...) body:l0)
     (if debug? (println (format "synthesizing ~a/path-explorer" (syntax->datum #'name))) (void)) ; this runs at compile-time
     (set-add! fn-with-explorer (syntax-e #'name))
     (syntax-parse #'body.l1
       [e:l1
        #`(begin
            (define (#,(explorer-id #'name) gen arg0 ...)
              (syntax-parameterize ([the-generator (make-rename-transformer #'gen)])
                e.res))
            (define (name arg0 ...)
              body))])]))

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


(define-symbolic x integer?)
(for ([m (stream->list (all-paths (λ (gen) (test/path-explorer gen x))))])
  (displayln m))