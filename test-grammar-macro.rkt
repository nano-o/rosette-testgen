#lang racket

(require rosette rosette/lib/synthax syntax/parse/define (for-syntax racket/syntax))

(define-grammar (g)
  (rule-1 (list (rule-2) (rule-2)))
  (rule-2 (?? (bitvector 32))))

(define two-ints (g #:depth 2))

(define sol
  (solve
   (begin
     (assume (bvuge (car two-ints) (bv 1 32)))
     (assume (bveq (cadr two-ints) (bv 2 32))))))

;(print-forms sol)

(define-syntax-parser gen-g2
  ([_] (let ([bv32-hole #'(?? (bitvector 32))])
         #`(define-grammar (#,(format-id this-syntax "g2"))
             (rule-1 (list (rule-2) (rule-2)))
             (rule-2 #,bv32-hole)))))

(gen-g2)

(define two-ints2 (g2 #:depth 2))

(define sol2
  (solve
   (begin
     (assume (not (bveq (cadr two-ints2) (car two-ints2)))))))

;(print-forms sol2)

(define-syntax-parser gen-g3
  ([_] (let ([bv32-hole #'(?? (bitvector 32))])
         #`(define-grammar (#,(format-id this-syntax "g3"))
             (rule-1 (list #,bv32-hole #,bv32-hole))))))

(gen-g3)

(define two-ints3 (g3 #:depth 1))

(define sol3
  (solve
   (begin
     (assume (not (bveq (cadr two-ints3) (car two-ints3)))))))

;(print-forms sol3)

(define-syntax-parser gen-g4
  ([_] (let ([bv32-hole #'(?? (bitvector 32))]
             [rule-2-hole #'(rule-2)])
         #`(define-grammar (#,(format-id this-syntax "g4"))
             (rule-1 (list #,rule-2-hole #,rule-2-hole))
             (rule-2 #,bv32-hole)))))

(gen-g4)

(define two-ints4 (g4 #:depth 2))

(define sol4
  (solve
   (begin
     (assume (not (bveq (cadr two-ints4) (car two-ints4)))))))

;(print-forms sol4)

(require 
  (for-syntax racket/generator))

(define-for-syntax get-index!
  (generator
   ()
   (let loop ([index 0])
     (yield index)
     (loop (+ index 1)))))

(define-syntax-parser gen-g5
  ([_] (let ([make-hole
              (λ ()
                #`(#,(format-id this-syntax "~a" "??" #:source (make-srcloc (format "generated-sloc:~a" (get-index!)) 1 0 1 0)) (bitvector 32)))])
         #`(define-grammar (#,(format-id this-syntax "g5"))
             (rule-1 (list #,(make-hole) #,(make-hole)))))))

(gen-g5)

(define two-ints5 (g5 #:depth 1))

(define sol5
  (solve
   (begin
     (assume (not (bveq (cadr two-ints5) (car two-ints5)))))))

(print-forms sol5)