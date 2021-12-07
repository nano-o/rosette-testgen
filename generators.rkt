#lang racket

(require racket/generator rackunit)

(provide constant-gen exhaustive-gen random-gen list-gen)
 
; we'll use a generator to produce numbers that encode which branch to take.
; for example, if we encounter a conditional with 3 branches we'll ask the generator for a number between 0 and 2 included.
(define (constant-gen i)
  (generator (n)
    (let loop ([m n])
      (loop (yield (modulo i m))))))

(define test-constant-gen (constant-gen 5))
(check-equal? (test-constant-gen 1) 0)
(check-equal? (test-constant-gen 6) 5)

  
(define (exhaustive-gen)
  (define (node-pos l i)
    (- (length l) i))
  (check-equal? (list-ref '(1 2 3) (node-pos '(1 2 3) 1)) 3)
  (define (pop-complete path)
    (let ([last (car path)])
      (if (equal? (car last) (cdr last))
          (pop-complete (cdr path))
          path)))
  (check-equal? (pop-complete (list  (cons 2 2) (cons 1 1) (cons 1 2))) (list (cons 1 2)))
  (define (incr-node n)
    (cons (+ (car n) 1) (cdr n)))
  (generator (n) ; n = 0 signifies we reached the end of a path
             (let loop ([m n] [path '()] [pos 1])
               (cond
                 [(equal? m 0) ; we reached a leaf at the last call; pos is one after
                  (let ([branch (caar path)] [max (cdar path)])
                    (cond
                      [(< branch max) ; leaf is not fully explored
                       (let ([new-m (yield 0)]) ; dummy 0, does not matter
                         (loop new-m path 1))] ; keep path unchanged and set pos back to 1
                      [(equal? branch max) ; current branch is complete
                       (cond
                         [(equal? (length path) 1) (raise 0)] ; finished
                         [else
                          (let ([new-m (yield 0)]) ; dummy 0, does not matter
                            (loop new-m (pop-complete path) 1))])]))] ; pop the leaf, increase previous by one, and set pos back to 1; TODO recurse until finding an unexplored node
                 [(< (length path) pos) ; never explored
                    (loop (yield 0) (cons (cons 1 m) path) (+ pos 1))]
                 [(<= pos (length path)) ; we have to explore further
                  (let ([current (list-ref path (node-pos path pos))])
                    (loop (yield (car current))
                          (list-set path (node-pos path pos) (incr-node current)) ; increment current node
                          (+ pos 1)))])))) ; increment position

(define test-exhaustive-gen (exhaustive-gen))
(check-equal? (test-exhaustive-gen 3) 0)
(check-equal? (test-exhaustive-gen 1) 0)
(check-equal? (test-exhaustive-gen 0) 0)
(check-equal? (test-exhaustive-gen 3) 1)
(check-equal? (test-exhaustive-gen 0) 0)
(check-equal? (test-exhaustive-gen 3) 2)
(check-exn (λ (x) (equal? x 0)) (thunk (test-exhaustive-gen 0))) ; raises an exception when we're finished


(define random-gen ; TODO random is not in rosette/safe; is it okay to use it anyway?
  (generator (n)
             (let loop ([m n])
                 (loop (yield (random m))))))

(define (list-gen outputs-list)
  (generator (n) ;
             (let loop ([m n] [l outputs-list])
               (begin
                 (if (> (car l) m) (error (format "chosen branch ~a but we have only ~a branches" (car l) m)) (list))
                 (loop (yield (car l)) (append (cdr l) (list (car l))))))))
(define test-list-gen (list-gen (list 0 1 5)))
(check-equal? (test-list-gen 3) 0)
(check-equal? (test-list-gen 3) 1)
(check-exn exn:fail? (thunk (test-list-gen 3)))