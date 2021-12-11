#lang rosette

; TODO detect symbols that have a path-explorer already and call that
; TODO support struct methods implementing generic interfaces (i.e. find out all possible targets and branch on that)
; TODO is it worth trying to prune infeasible paths?
; TODO what about definitions comming from libraries?

(require (for-syntax syntax/parse racket/syntax)
         racket/generator rosette/lib/destruct racket/stxparam rackunit "./generators.rkt" syntax/parse)

(provide define-with-path-explorer)

(define-syntax-parameter g (lambda (stx) (raise-syntax-error (syntax-e stx) "can only be used inside path-explorer")))
; TODO it seem bad to define this globally when we're only going to use it internally in path-explorer
; it seems that we're only poluting this file though since we don't export g

; now let's write a macro that takes a racket definition and creates a Rosette program that follows the path given by a generator

(define-for-syntax (explorer-id x)
  (format-id x "~a-path-explorer" x))

(define-syntax (define-with-path-explorer stx)
  (syntax-parse stx
    [(_ (name:id arg0:id ...) body)
     #`(begin
         (define (#,(explorer-id #'name) gen arg0 ...)
           (syntax-parameterize ([g (make-rename-transformer #'gen)])
             (path-explorer body))) ; TODO should we just pass the generator to path-explorer? but then all recursive expansions of path-explorer have to get the gen
         (define (name arg0 ...)
           body))]))

(define (print-branch branch c)
  (println (format "branch ~a; assuming: ~a" branch c)))

(define-for-syntax debug? #t) ; TODO: should this be a syntax parameter? can we set! it?
;(define-syntax debug? #t) ; NOTE this works! seems that there's no clash because that's not the same level.

(define-syntax (path-explorer stx)
  (define (from-to i n)
    (if (<= i n) (cons i (from-to (+ i 1) n)) null))
  (define (syntax->string-list stx)
    (cons #'list (map (λ (x) (~a (syntax->datum x))) (syntax->list stx))))
  (define (print-branch-condition b c)
    (with-syntax ([c-string #`(quote #,(syntax->datum c))])
    (if debug?
        #`(print-branch #,b c-string)
        #'(values)))) ; TODO is there a better way to do nothing?
  (define (print-debug-info i)
    (if debug?
        (println i)
        (values)))
  (define-syntax-class (has-path-explorer)
    (pattern x:id #:when (identifier-binding (explorer-id #'x))))
  
  (syntax-parse stx
    #:track-literals ; per advice here:  https://school.racket-lang.org/2019/plan/tue-aft-lecture.html
    [(_ ((~datum if) c then-branch else-branch)) ; TODO what about recursing in the condition?
     (print-debug-info "if")
     #`(let ([branch (g 2)] [cond (path-explorer c)])
         (if (equal? branch 0)
             (begin
               #,(print-branch-condition #'branch #'c)
               (assume cond)
               (path-explorer then-branch))
             (begin
               #,(print-branch-condition #'branch #'(! c))
               (assume (! cond))
               (path-explorer else-branch))))]
    [(_ ((~datum cond) [c0 body0] ... [(~datum else) ~! else-body]))
     (print-debug-info "cond with else")
     (with-syntax ([how-many (length (syntax->list #'(c0 ... 'else)))]
                   [else-cond #`(! #,(datum->syntax #'else (cons #'or (syntax->list #'(c0 ...)))))])
       #`(let ([branch (g how-many)])
           (begin
             #,(print-branch-condition #'branch #`(list-ref #,(syntax->string-list #'(c0 ... else-cond)) branch))
             (assume (list-ref (list c0 ... else-cond) branch))
             (list-ref (list (path-explorer body0) ... (path-explorer else-body)) branch))))]
    [(_ ((~datum cond) [c0 body0] ...))
     (print-debug-info "cond")
     (with-syntax ([how-many (length (syntax->list #'(c0 ...)))])
       #`(let ([branch (g how-many)])
           (begin
             #,(print-branch-condition #'branch #`(list-ref #,(syntax->string-list #'(c0 ...)) branch))
             (assume (list-ref (list c0 ...) branch))
             (list-ref (list (path-explorer body0) ...) branch))))]
    [(_ ((~datum destruct) d [pat0 body0] ...))
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
    [(_ ((~datum lambda) (arg0 ...) body) (~do (print-debug-info "lambda"))) #'(lambda (arg0 ...) (path-explorer body))]
    [(_ ((~datum λ) (arg0 ...) body (~do (print-debug-info "λ")))) #'(lambda (arg0 ...) (path-explorer body))]
    [(_ (x:keyword arg0 ...) (~do (print-debug-info "keyword"))) #'(x arg0 ...)]
    [(_ ((~datum quote) arg0 ...) (~do (print-debug-info "quote"))) #'(quote arg0 ...)]
    [(_ (fn:has-path-explorer arg0 ...) (~do (print-debug-info "path-explorer application"))) #`(#,(explorer-id #'fn) (path-explorer arg0) ...)]
    [(_ (fn arg0 ...) (~do (print-debug-info "application"))) #'((path-explorer fn) (path-explorer arg0) ...)]
    [(_ x:integer (~do (print-debug-info "integer"))) #'x]
    [(_ x:boolean (~do (print-debug-info "integer"))) #'x]
    [(_ x:id (~do (print-debug-info "id"))) #'x]
    [(_ x (~do (print-debug-info "catch all case"))) #'x])) ; catch-all?

; tests

(define-with-path-explorer (test-if i) (if (<= 0 i) (if (<= 1 i) 'strict-pos 'zero) 'neg))
(define-with-path-explorer (test1 i) (if (equal? (test-if i) 'neg) 'neg 'pos))(define-symbolic i integer?)
(test1-path-explorer (constant-gen 0) 2)
#;(let ([model (solve (test1-path-explorer (constant-gen 0) i))])
  (check-equal? (< 0 (evaluate i model)) #t))
#|
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
|#

; TODO test lambda etc. and test with definition with nested conditionals