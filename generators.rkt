#lang racket

; Provides generators for the path explorer macro.
; We use generators to enumerate paths in a tree.
; The tree in question is supposed to be the control-flow graph of a program, which is assumed to be acyclic.
; A path explorer visits nodes of a program tree; at each node, it calls the generator g with argument n where n is the fanout of the node.
; The generator returns a number indicating which branch (0 to n) the path explorer should take.
; When the path explorer reaches a leaf node, it calls the generator with argument 0.

(require racket/generator rackunit)

(provide constant-gen exhaustive-gen random-gen list-gen generator-tests)
 
; we'll use a generator to produce numbers that encode which branch to take.
; for example, if we encounter a conditional with 3 branches we'll ask the generator for a number between 0 and 2 included.

; a generator that always returns the same branch
(define (constant-gen i)
  (generator (n)
    (let loop ([m n])
      (loop (yield (modulo i m))))))

; this generator allows enumerating all possible paths in a control-flow tree
(define (exhaustive-gen)
  (define (node-pos l i)
    (- (length l) i))
  (check-equal? (list-ref '(1 2 3) (node-pos '(1 2 3) 1)) 3)
  (define (pop-complete path)
    (if (empty? path)
        '()
        (let ([last (car path)])
          (if (equal? (car last) (- (cdr last) 1))
              (pop-complete (cdr path))
              (cons (cons (+ 1 (caar path)) (cdar path)) (cdr path))))))
  (check-equal? (pop-complete (list  (cons 2 3) (cons 1 2) (cons 0 2))) (list (cons 1 2)))
  (define (incr-node n)
    (cons (+ (car n) 1) (cdr n)))
  (generator (n) ; n = 0 signifies we reached the end of a path
             (let loop ([m n] [path '()] [pos 1])
               (cond
                 [(equal? m 0) ; we reached a leaf at the last call; pos is one after
                  (let ([branch (caar path)] [max (- (cdar path) 1)])
                    (cond
                      [(< branch max) ; leaf is not fully explored
                       (let ([new-m (yield 0)]) ; dummy 0, does not matter
                         (loop
                          new-m
                          (list-set path (node-pos path (- pos 1)) `(,(+ 1 (caar path)) . ,(cdar path))) ; increment branch count of last node
                          1))] ; set pos back to 1
                      [else ; current branch is complete
                       (let ([new-path (pop-complete path)])
                         (if (empty? new-path)
                             (begin (yield -1) (error "this exhaustive generator has already finished"))
                             (let ([new-m (yield 0)])  ; dummy 0, does not matter
                               (loop new-m new-path 1))))]))] ; pop completed nodes, increase previous by one, and set pos back to 1
                 [(< (length path) pos) ; never explored
                    (loop (yield 0) (cons (cons 0 m) path) (+ pos 1))]
                 [(<= pos (length path)) ; we have to explore further
                  (let ([current (list-ref path (node-pos path pos))])
                    (begin
                      (invariant-assertion (=/c m) (cdr current))
                      (loop (yield (car current))
                            path
                            (+ pos 1))))])))) ; increment position

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

; tests

(define-test-suite generator-tests
  (test-case
   "constant-gen test"
   (define test-constant-gen (constant-gen 5))
   (check-equal? (test-constant-gen 1) 0)
   (check-equal? (test-constant-gen 6) 5))
  
  (test-case
   "exhaustive-gen test 1"
   (define test-exhaustive-gen (exhaustive-gen))
   (check-equal? (test-exhaustive-gen 3) 0)
   (check-equal? (test-exhaustive-gen 1) 0)
   (check-equal? (test-exhaustive-gen 0) 0)
   (check-equal? (test-exhaustive-gen 3) 1)
   (check-equal? (test-exhaustive-gen 0) 0)
   (check-equal? (test-exhaustive-gen 3) 2)
   (check-equal? (test-exhaustive-gen 0) -1)) ; -1 indicates we're done
  
  (test-case
   "exhaustive-gen test 2"
   (define test-exhaustive-gen-2 (exhaustive-gen))
   (check-equal? (test-exhaustive-gen-2 2) 0)
   (check-equal? (test-exhaustive-gen-2 3) 0)
   (check-equal? (test-exhaustive-gen-2 0) 0)
   (check-equal? (test-exhaustive-gen-2 2) 0)
   (check-equal? (test-exhaustive-gen-2 3) 1)
   (check-equal? (test-exhaustive-gen-2 0) 0)
   (check-equal? (test-exhaustive-gen-2 2) 0)
   (check-equal? (test-exhaustive-gen-2 3) 2)
   (check-equal? (test-exhaustive-gen-2 0) 0)
   (check-equal? (test-exhaustive-gen-2 2) 1)
   (check-equal? (test-exhaustive-gen-2 0) -1)) ; -1 indicates we're done

  (test-case
   "list-gen"
   (define test-list-gen (list-gen (list 0 1 5)))
   (check-equal? (test-list-gen 3) 0)
   (check-equal? (test-list-gen 3) 1)
   (check-exn exn:fail? (thunk (test-list-gen 3)))))