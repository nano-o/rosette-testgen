#lang rosette

(require
  "Stellar.rkt"
  rosette/lib/synthax
  syntax/parse
  rackunit)

(define symbolic-ledger
  (the-grammar #:depth 9 #:start TestLedger-rule))
(define symbolic-tx-envelope
  (the-grammar #:depth 15 #:start TransactionEnvelope-rule))
(define syms
  (set-union (symbolics symbolic-tx-envelope) (symbolics symbolic-ledger)))

(define (display-solution s)
  (if (sat? s)
    (for ([f (generate-forms s)])
         (pretty-display (syntax->datum f)))
    (displayln "unsat")))

(define sol
  (complete-solution
    (solve (assume #t)) syms))

(display-solution sol)

;; Now check validity:

(define-namespace-anchor a)

(define ns (namespace-anchor->namespace a))

(define (interpret stx)
  (eval-syntax (datum->syntax #'() (syntax->datum stx)) ns))

(define (defn/stx->datum defn)
  (syntax-parse defn
    [(define _ d) (interpret #'d)]))

(define forms
  (for/list ([f (generate-forms sol)])
    (defn/stx->datum f)))

(define test-ledger (car forms))
(define test-tx-envelope (cadr forms))

(test-case
  "valid?"
  (check-equal? (TestLedger-valid? test-ledger) #t)
  (check-equal? (TransactionEnvelope-valid? test-tx-envelope) #t))
