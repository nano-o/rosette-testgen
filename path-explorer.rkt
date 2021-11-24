#lang rosette

(require (for-syntax syntax/parse racket/string racket/syntax)
         racket/generator syntax/parse/define rosette/lib/destruct racket/stxparam)

(provide constant-gen random-gen define-path-explorer)

; we'll use a generator to produce numbers that encode which branch to take
(define (constant-gen i)
  (generator (n)
             (let loop ()
               (begin
                 (yield (modulo i n))
                 (loop)))))

(define random-gen
  (generator (n)
             (let loop ()
               (begin
                 (yield (random n))
                 (loop)))))

(define-syntax-parameter g (lambda (stx) (raise-syntax-error (syntax-e stx) "can only be used inside define-path-explorer")))

; now let's write a macro that takes a program and creates a Rosette program that follows the path given by the generator
(define-syntax (define-path-explorer stx)
  (syntax-parse stx
    [(_ (name arg0 ...) body)
     (with-syntax ([explorer (format-id #'name "~a-path-explorer" #'name)])
       #'(begin
           (define (explorer gen arg0 ...)
             (syntax-parameterize ([g (make-rename-transformer #'gen)])
               (path-explorer body)))
           (define (name arg0 ...)
             body)))]))

(define (print-branch branch c)
  (println (format "branch ~a; assuming: ~a" branch c)))

(define-syntax (path-explorer stx)
  (define (from-to i n)
    (if (<= i n) (cons i (from-to (+ i 1) n)) null))
  (syntax-parse stx
    #:literals (if cond destruct)
    [(_ (if c then-branch else-branch))
     #'(let ([branch (g 2)])
         (if (equal? branch 0)
             (begin
               (print-branch branch (syntax->datum #'c))
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
           (print-branch branch "")
           (assume (list-ref (list c0 ...) branch))
           (list-ref (list body0 ...) (path-explorer branch)))))]
    [(_ (destruct d [pat0 body0] ...))
     (with-syntax*
         ([how-many (length (syntax->list #'(pat0 ...)))]
          [indices (datum->syntax stx (from-to 0 (- (syntax->datum #'how-many) 1)))])
       (syntax-parse #'indices ; TODO this seems a bit contrived but it works
         [(i0 ...) 
         #'(let ([branch (g how-many)])
             (destruct d [pat0 (if (equal? branch i0) (begin (print-branch branch "") (path-explorer body0)) (assume #f))] ...))]))]
; TODO is there a "default" mechanism for the following?
    [(_ (x ...)) #'(x ...)]
    [(_ x) #'x]))

; TODO tests

(define-path-explorer (test-if i) (if (<= 0 i) (if (<= 1 i) 'strict-pos 'zero) 'neg))

(define-path-explorer (test-cond i)
  (cond ([(< 0 i) 'strict-pos]
         [(equal? 0 i) 'zero]
         [(< i 0) 'neg])))

(struct s1 (x))
(struct s2 (y))
(define-path-explorer (test-destruct s)
  (destruct s
    [(s1 a) "foo"]
    [(s2 b) "bar"]
    #;[_ (assert #f)]))

;(test-if -1)
;(test-if-path-explorer random-gen -1)
;(test-cond 0)

; this gives us an input that satisfies the path condition given by the generator.
#;(begin
  (define-symbolic i integer?)
  (solve (test-if-path-explorer (constant-gen 1) i)))
#;(begin
  (define-symbolic x boolean?)
  (define in (if x (s1 0) (s2 0)))
  (solve (test-destruct-path-explorer random-gen in)))