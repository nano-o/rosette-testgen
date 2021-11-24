#lang rosette

(require (for-syntax syntax/parse racket/string racket/syntax)
         racket/generator syntax/parse/define rosette/lib/destruct racket/stxparam)

(provide constant-gen random-gen define-path-explorer)

; we'll use a generator to produce numbers that encode which branch to take.
; for example, if we encounter a conditional with 3 branches we'll ask the generator for a number between 0 and 2 included.
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

; now let's write a macro that takes a racket definition and creates a Rosette program that follows the path given by a generator
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
    #:literals (if cond destruct lambda λ else quote)
    [(_ (if c then-branch else-branch (~do (println "matched if"))))
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
    [(_ (cond [c0 body0] ... [else ~! (~do (println "matched cond with else")) (~fail "else is not supported") body-else]))
     null]
    [(_ (cond [c0 body0] ... (~do (println "matched cond"))))
     (with-syntax ([how-many (length (syntax->list #'(c0 ...)))])
     #'(let ([branch (g how-many)])
         (begin
           (print-branch branch "")
           (assume (list-ref (list c0 ...) branch))
           (list-ref (list (path-explorer body0) ...) branch))))]
    [(_ (destruct d [pat0 body0] ...) (~do (println "matched destruct")))
     (with-syntax*
         ([how-many (length (syntax->list #'(pat0 ...)))]
          [indices (datum->syntax stx (from-to 0 (- (syntax->datum #'how-many) 1)))])
       (syntax-parse #'indices ; TODO this seems a bit contrived but it works
         [(i0 ...) 
         #'(let ([branch (g how-many)])
             (destruct d [pat0 (if (equal? branch i0) (begin (print-branch branch "") (path-explorer body0)) (assume #f))] ...))]))]
; TODO the following is messy
    [(_ (lambda (arg0 ...) body) (~do (println "matched lambda"))) #'(lambda (arg0 ...) (path-explorer body))]
    [(_ (λ (arg0 ...) body (~do (println "matched λ")))) #'(lambda (arg0 ...) (path-explorer body))]
    [(_ (x:keyword arg0 ...) (~do (println "matched a keyword"))) #'(x arg0 ...)]
    [(_ (quote arg0 ...) (~do (println "matched quote"))) #'(quote arg0 ...)]
    [(_ (x arg0 ...) (~do (println "matched application"))) #'((path-explorer x) (path-explorer arg0) ...)]
    [(_ x (~do (println "matched lone identifier or constant"))) #'x]))
