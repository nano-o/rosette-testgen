#lang rosette

(require (for-syntax syntax/parse racket/string racket/syntax)
         racket/generator syntax/parse/define rosette/lib/destruct racket/stxparam rackunit "./generators.rkt")
; TODO detect symbols that have a path-explorer already and call that
; TODO support struct methods implementing generic interfaces (i.e. find out all possible targets and branch on that)
; TODO is it worth trying to prune infeasible paths?
; TODO what about definitions comming from libraries?


(provide define-with-path-explorer)

(define-syntax-parameter g (lambda (stx) (raise-syntax-error (syntax-e stx) "can only be used inside path-explorer")))
; TODO it seem bad to define this globally when we're only going to use it internally in path-explorer
; it seems that we're only poluting this file though since we don't export g

; now let's write a macro that takes a racket definition and creates a Rosette program that follows the path given by a generator
(define-syntax (define-with-path-explorer stx)
  (syntax-parse stx
    [(_ (name:id arg0:id ...) body)
     (with-syntax ([explorer (format-id #'name "~a-path-explorer" #'name)])
       #'(begin
           (define (explorer gen arg0 ...)
             (syntax-parameterize ([g (make-rename-transformer #'gen)])
               (path-explorer body))) ; TODO should we just pass the generator to path-explorer? but then all recursive expansions of path-explorer have to get the gen
           (define (name arg0 ...)
             body)))]))

(define (print-branch branch c)
  (println (format "branch ~a; assuming: ~a" branch c)))

(define-for-syntax debug? #t) ; TODO: should this be a syntax parameter? can we set! it?
;(define-syntax debug? #t) ; NOTE this works! seems that there's no clash because that's not the same level.

(define-syntax (path-explorer stx) ; TODO detect symbols that have a path-explorer already and call that
  (define (from-to i n)
    (if (<= i n) (cons i (from-to (+ i 1) n)) null))
  (define (syntax->string-list stx)
    (cons #'list (map (λ (x) (~a (syntax->datum x))) (syntax->list stx))))
  (define (print-branch-condition b c)
    (if debug?
        #`(print-branch #,b #,c)
        #'(values))) ; TODO is there a better way to do nothing?
  (define (print-debug-info i)
    (if debug?
        (println i)
        (values)))
  
  (syntax-parse stx
    #:track-literals ; per advice here:  https://school.racket-lang.org/2019/plan/tue-aft-lecture.html
    [(_ ((~literal if) c then-branch else-branch)) ; TODO should we use ~literal or ~datum?
     (print-debug-info "if")
     #`(let ([branch (g 2)])
         (if (equal? branch 0)
             (begin
               #,(print-branch-condition #'branch #'c)
               (assume c)
               (path-explorer then-branch))
             (begin
               #,(print-branch-condition #'branch #'(! c))
               (assume (! c))
               (path-explorer else-branch))))]
    [(_ ((~literal cond) [c0 body0] ... [(~literal else) ~! else-body]))
     (print-debug-info "cond with else")
     (with-syntax ([how-many (length (syntax->list #'(c0 ... 'else)))]
                   [else-cond #`(! #,(datum->syntax #'else (cons #'or (syntax->list #'(c0 ...)))))])
       #`(let ([branch (g how-many)])
           (begin
             #,(print-branch-condition #'branch #`(list-ref #,(syntax->string-list #'(c0 ... else-cond)) branch))
             (assume (list-ref (list c0 ... else-cond) branch))
             (list-ref (list (path-explorer body0) ... (path-explorer else-body)) branch))))]
    [(_ ((~literal cond) [c0 body0] ...))
     (print-debug-info "cond")
     (with-syntax ([how-many (length (syntax->list #'(c0 ...)))])
       #`(let ([branch (g how-many)])
           (begin
             #,(print-branch-condition #'branch #`(list-ref #,(syntax->string-list #'(c0 ...)) branch))
             (assume (list-ref (list c0 ...) branch))
             (list-ref (list (path-explorer body0) ...) branch))))]
    [(_ ((~literal destruct) d [pat0 body0] ...))
     (print-debug-info "destruct")
     (with-syntax*
         ([how-many (length (syntax->list #'(pat0 ...)))]
          [indices (datum->syntax stx (from-to 0 (- (syntax->datum #'how-many) 1)))])
       (syntax-parse #'indices ; TODO this seems a bit contrived but it works
         [(i0 ...) 
         #`(let ([branch (g how-many)])
             (destruct d
               [pat0
                (if (equal? branch i0)
                    (begin
                      #,(print-branch-condition #'branch #`(list-ref #,(syntax->string-list #'(pat0 ...)) branch))
                      (path-explorer body0))
                    (assume #f))]
               ...))]))]
; TODO the following is messy
    [(_ ((~literal lambda) (arg0 ...) body) (~do (print-debug-info "lambda"))) #'(lambda (arg0 ...) (path-explorer body))]
    [(_ ((~literal λ) (arg0 ...) body (~do (print-debug-info "λ")))) #'(lambda (arg0 ...) (path-explorer body))]
    [(_ (x:keyword arg0 ...) (~do (print-debug-info "keyword"))) #'(x arg0 ...)]
    [(_ ((~literal quote) arg0 ...) (~do (print-debug-info "quote"))) #'(quote arg0 ...)]
    [(_ (x arg0 ...) (~do (print-debug-info "application"))) #'((path-explorer x) (path-explorer arg0) ...)]
    [(_ x (~do (print-debug-info "lone identifier or constant"))) #'x]))

; tests

(define-with-path-explorer (test-if i) (if (<= 0 i) (if (<= 1 i) 'strict-pos 'zero) 'neg))
(define-symbolic i integer?)
(let ([model (solve (test-if-path-explorer (constant-gen 0) i))])
  (check-equal? (< 0 (evaluate i model)) #t))

(define-with-path-explorer (test-cond i)
  (cond [(< 0 i) 'strict-pos]
        [(equal? 0 i) 'zero]
        [(> 0 i) 'neg]))
(let ([model (solve (test-cond-path-explorer (constant-gen 1) i))])
  (check-equal? (evaluate i model) 0))

(define-with-path-explorer (test-cond-else i)
  (cond [(< 0 i) 'strict-pos]
        [(equal? 0 i) 'zero]
        [else 'neg]))

(let ([model (solve (test-cond-else-path-explorer (constant-gen 1) i))])
  (check-equal? (evaluate i model) 0))
(let ([model (solve (test-cond-else-path-explorer (constant-gen 2) i))])
  (check-equal? (< (evaluate i model) 0) #t))

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