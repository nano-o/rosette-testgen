#lang rosette

(require (for-syntax syntax/parse racket/string racket/syntax)
         racket/generator syntax/parse/define rosette/lib/destruct racket/stxparam)

(provide constant-gen random-gen bitvector-gen list-gen define-with-path-explorer)

; we'll use a generator to produce numbers that encode which branch to take.
; for example, if we encounter a conditional with 3 branches we'll ask the generator for a number between 0 and 2 included.
(define (constant-gen i)
  (generator (n)
             (let loop ()
               (begin
                 (yield (modulo i n))
                 (loop)))))

(define random-gen ; TODO random is not in rosette/safe; is it okay to use it anyway?
  (generator (n)
             (let loop ()
               (begin
                 (yield (random n))
                 (loop)))))

(define (bitvector-gen bv-outputs)
  (generator (n)
             (let loop ([bv bv-outputs])
               (begin
                 (yield (bitvector->natural (extract (- n 1) 0 bv)))
                 (loop (rotate-right n bv))))))

(define (list-gen outputs-list)
  (generator (n)
             (let loop ([l outputs-list])
               (begin
                 (yield (car l))
                 (loop (append (cdr l) (list (car l))))))))

(define-syntax-parameter g (lambda (stx) (raise-syntax-error (syntax-e stx) "can only be used inside define-path-explorer"))) ; TODO should this go inside the define-with-path-explorer macro?

; now let's write a macro that takes a racket definition and creates a Rosette program that follows the path given by a generator
(define-syntax (define-with-path-explorer stx)
  (syntax-parse stx
    [(_ (name:id arg0:id ...) body)
     (with-syntax ([explorer (format-id #'name "~a-path-explorer" #'name)])
       #'(begin
           (define (explorer gen arg0 ...)
             (syntax-parameterize ([g (make-rename-transformer #'gen)])
               (path-explorer body))) ; TODO should we just pass the generator to path-explorer?
           (define (name arg0 ...)
             body)))]))

(define (print-branch branch c)
  (println (format "branch ~a; assuming: ~a" branch c)))

(define-syntax (path-explorer stx) ; TODO detect symbols that have a path-explorer already and call that
  (define (from-to i n)
    (if (<= i n) (cons i (from-to (+ i 1) n)) null))
  (syntax-parse stx
    [(_ ((~literal if) c then-branch else-branch (~do (println "matched if"))))
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
    [(_ ((~literal cond) [c0 body0] ... [(~literal else) ~! (~do (println "matched cond with else")) else-body]))
     (with-syntax ([how-many (length (syntax->list #'(c0 ... 'else)))]
                   [else-cond #`(! #,(datum->syntax #'else (cons #'or (syntax->list #'(c0 ...)))))])
       #'(let ([branch (g how-many)])
           (begin
             (print-branch branch "")
             (assume (list-ref (list c0 ... else-cond) branch))
             (list-ref (list (path-explorer body0) ... (path-explorer else-body)) branch))))]
    [(_ ((~literal cond) [c0 body0] ... (~do (println "matched cond"))))
     (with-syntax ([how-many (length (syntax->list #'(c0 ...)))])
       #'(let ([branch (g how-many)])
           (begin
             (print-branch branch "")
             (assume (list-ref (list c0 ...) branch))
             (list-ref (list (path-explorer body0) ...) branch))))]
    [(_ ((~literal destruct) d [pat0 body0] ...) (~do (println "matched destruct")))
     (with-syntax*
         ([how-many (length (syntax->list #'(pat0 ...)))]
          [indices (datum->syntax stx (from-to 0 (- (syntax->datum #'how-many) 1)))])
       (syntax-parse #'indices ; TODO this seems a bit contrived but it works
         [(i0 ...) 
         #'(let ([branch (g how-many)])
             (destruct d [pat0 (if (equal? branch i0) (begin (print-branch branch "") (path-explorer body0)) (assume #f))] ...))]))]
; TODO the following is messy
    [(_ ((~literal lambda) (arg0 ...) body) (~do (println "matched lambda"))) #'(lambda (arg0 ...) (path-explorer body))]
    [(_ ((~literal λ) (arg0 ...) body (~do (println "matched λ")))) #'(lambda (arg0 ...) (path-explorer body))]
    [(_ (x:keyword arg0 ...) (~do (println "matched a keyword"))) #'(x arg0 ...)]
    [(_ (quote arg0 ...) (~do (println "matched quote"))) #'(quote arg0 ...)]
    [(_ (x arg0 ...) (~do (println "matched application"))) #'((path-explorer x) (path-explorer arg0) ...)]
    [(_ x (~do (println "matched lone identifier or constant"))) #'x]))