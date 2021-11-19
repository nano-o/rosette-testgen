#lang rosette/safe

(require rosette/lib/destruct)
(require rackunit)

(define int64? (bitvector 64))
(define (int64 i)
  (bv i int64?))

(define accountID? (bitvector 256))
(define (accountID i)
  (bv i accountID?))

; a ledger has two components: a unary relations accounts that contains all existing accounts,
; and a function balances that assigns balances to existing accounts (non-existing accounts are by default assigned a 0 balance).
(struct ledger (accounts balances))

(define empty-ledger
  (ledger
   (lambda (a) #f)
   (lambda (a) (int64 0))))

; operations
(struct create-account (account starting-balance))
(struct payment-op (source destination amount))

; semantics
; todo: use struct methods
(define (exec-op op l)
  (destruct op
    [(create-account a b)
     (ledger
      (lambda (acc)
        (cond
          [(equal? acc a) #t]
          [else ((ledger-accounts l) acc)]))
      (lambda (acc)
        (cond
          [(equal? acc a) b]
          [else ((ledger-balances l) acc)])))]
    [(payment-op s d am) ; todo: check that accounts exist!
     (ledger
      (lambda (acc) ((ledger-accounts l) acc))
      (lambda (acc)
        (cond
          [(equal? acc s) (bvsub ((ledger-balances l) acc) am)]
          [(equal? acc d) (bvadd ((ledger-balances l) acc) am)]
          [else ((ledger-balances l) acc)])))]))


(define (check-no-negative-balance src dst amnt acc)
  (let ([l (exec-op (payment-op src dst amnt) empty-ledger)])
    (begin
      (assert (bvsge ((ledger-balances l) acc) (int64 0))))))

;(check-no-negative-balance (accountID 0) (accountID 1) (int64 1) (accountID 0))

(define-symbolic s d x accountID?)
(define-symbolic a int64?)
(define cex
  (verify (begin
            (assume (equal? x s))
            (check-no-negative-balance s d a x))))