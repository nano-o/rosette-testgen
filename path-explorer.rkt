#lang rosette

(require
  (for-syntax ;syntax/parse
              racket/syntax
              pretty-format)
  ;macro-debugger/expand
  racket/stxparam
  syntax/parse/define
  "./generators.rkt")

(provide define/path-explorer all-paths (for-syntax debug?))

(define-syntax-parameter the-generator (lambda (stx) (raise-syntax-error (syntax-e stx) "can only be used inside path-explorer")))

; We define macro that takes a racket definition and creates a Rosette program that follows the path given by a generator
; Should we allow non-determinism in the specs? No, because everything should be deterministic for SMR
; TODO it might make sense to restrict specs to a total fragment of Racket
; TODO it might be better to explicitly mark the control-flow nodes that are subject to exhaustive exploration
; e.g. we could have if/e, and/e, or/e etc. or wrap stuff in (explore ...)
; TODO this whole thing only works if we have no symbolic unions (e.g. if a list can have different length we're in trouble). This is because Rosette will execute the same code multiple times for each union member.
; TODO prune unsat paths; how? maybe just throw an exception and rosette will catch it and then do what? check what happens with `solve` when there is an exception.

(begin-for-syntax
  (define debug? #f)

  ; First we rewrite "or", "and", "case" to "if" expressions
  ; TODO support "cond"
  (define-syntax-class l0
    #:literals (begin let let* if or and assume case)
    #:description "the input language"
    [pattern (begin e*:l0 ...)
             #:attr l1 #`(begin e*.l1 ...)]
    [pattern (let ([x*:id e*:l0] ...) body*:l0 ...)
             #:attr l1 #`(let ([x* e*.l1] ...) body*.l1 ...)]
    [pattern (let* ([x*:id e*:l0] ...) body*:l0 ...)
             #:attr l1 #`(let* ([x* e*.l1] ...) body*.l1 ...)]
    [pattern (if c:l0 then:l0 else:l0)
             #:attr l1 #'(if c.l1 then.l1 else.l1)]
    [pattern (or e*:l0 ...)
             #:attr l1 (or->ifs (syntax->list #'(e*.l1 ...)))]
    [pattern (and e*:l0 ...)
             #:attr l1 (and->ifs (syntax->list #'(e*.l1 ...)))]
    [pattern (assume e:expr)
             ; assume expressions are left untouched
             #:attr l1 this-syntax]
    [pattern (case e:l0 [(d**:expr ...) body**:l0 ...] ...)
             #:attr l1 #'(case e.l1 [(d** ...) body**.l1 ...] ...)]
    [pattern (~or _:id _:number _:boolean)
             #:attr l1 this-syntax]
    [pattern (fn:id arg*:l0 ...)
             #:attr l1 #'(fn arg*.l1 ...)])

  ; NOTE with "and" and "or" we want to explore the structure of the formula

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
          #`(if (not #,(car e*))
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
    (let*
        ([i (if (not (syntax? i)) (datum->syntax #'() i) i)]
         [c (pretty-format "~a" (syntax->datum c))])
      (if debug?
          #`((displayln (format "branch number ~a with condition:\n~a" #,i #,(datum->syntax #'() c))))
          #'())))

  (define-syntax-class (has-path-explorer)
    [pattern x:id
             #:when (set-member? fn-with-explorer (syntax-e #'x))])

  (define-syntax-class l1
    #:description "an expression amenable to path-exploration"
    #:literals (begin let let* if or and assume case)
    #:commit ; no bactracking
    [pattern (begin e*:l1 ...)
             #:attr res #`(begin e*.res ...)]
    [pattern (let* ([x*:id e*:l1] ...) body:l1)
             #:attr res #`(let* ([x* e*.res] ...) body.res)]
    [pattern (let ([x*:id e*:l1] ...) body:l1)
             #:attr res #`(let ([x* e*.res] ...) body.res)]
    [pattern (if cond:l1 then:l1 else:l1)
             #:attr res #`(let ([c cond.res]) ; NOTE it's important to evaluate cond.res first
                            (if (equal? (the-generator 2) 0)
                                (begin
                                  #,@(print-branch 0 #'cond)
                                  (assume c)
                                  then.res)
                                (begin
                                  #,@(print-branch 1 #'(not cond))
                                  (assume (not c))
                                  else.res)))]
    [pattern (fn:has-path-explorer arg0:l1 ...)
             #:attr res #`(#,(explorer-id #'fn) the-generator arg0.res ...)]
    [pattern (case e:l1 [(d**:expr ...) body**:l1 ...] ...)
             #:attr res (let* ([res** (reverse
                                       (for/fold ([res null])
                                                 ([body* (syntax->list #'((body**.res ...) ...))]
                                                  [d* (syntax->list #'((d** ...) ...))])
                                         (let ([new-body*
                                                (with-syntax
                                                    ([(body ...) body*])
                                                  #`((assume (equal? #,(length res) i))
                                                     #,@(print-branch #'i #`(case #,d*))
                                                     body ...))])
                                           ; here it's interesting that "i" seems to be bound to the right thing (the i below)
                                           (cons new-body* res))))])
                          (with-syntax
                              ([((body.res** ...) ...) res**])
                            #`(let ([val e.res]
                                    [i (the-generator #,(length res**))])
                                (case val [(d** ...) body.res** ...] ...))))]
    [pattern (assume e:expr)
             ; assume expressions are left untouched
             #:attr res this-syntax]
    [pattern (~or _:id _:number _:boolean)
             #:attr res this-syntax]
    [pattern (fn:id arg0:l1 ...)
             #:attr res #'(fn arg0.res ...)]))

(define-syntax-parser define/path-explorer
  [(_ (name:id arg0:id ...) body:l0)
   (when debug?
     (begin
       (println (format "synthesizing ~a/path-explorer" (syntax->datum #'name))) ; this runs at compile-time
       #;(displayln "ouput of first pass:")
       #;(println (pretty-display (syntax->datum #'body.l1)))))
   (set-add! fn-with-explorer (syntax-e #'name))
   (syntax-parse #'body.l1
     [e:l1
      #;(displayln "ouput of second pass:")
      #;(println (pretty-display (syntax->datum #'e.res)))
      #`(begin
          (define (#,(explorer-id #'name) gen arg0 ...)
            (syntax-parameterize ([the-generator (make-rename-transformer #'gen)])
              e.res))
          (define (name arg0 ...)
            body))])])

(define-syntax-parser debug?
  [_ #`#,debug?])

; all-paths returns a stream of solutions
(define (all-paths prog symbols) ; prog must take a generator as argument
  (define gen (exhaustive-gen))
  (define (go)
    (let ([solution
           (complete-solution ; we need full solutions to generate test inputs
            (solve (prog gen))
            symbols)])
      (begin
        (when #t ;debug?
            (displayln (format "End of execution path; SAT: ~a" (sat? solution))))
        (if (equal? (gen 0) 0)
            (stream-cons solution (go))
            (stream-cons solution empty-stream)))))
  (go))

(module+ test
  (require rackunit)
  (define/provide-test-suite path-explorer/test
    (test-case
     "basic tests"
     (check-not-exn
      (λ ()
        (begin
          (define/path-explorer (test-2 x)
            (case (< x 3)
              [(#t) (+ x 1)]
              [(#f) (- x 1)]))
          (define/path-explorer (test x)
            (if (< (test-2 x) 0)
                (void)
                (void)))
          (define-symbolic x integer?)
          (for ([m (stream->list
                    (all-paths
                     (λ (gen) (test/path-explorer gen x))
                     (symbolics x)))])
            (displayln m))))))))
