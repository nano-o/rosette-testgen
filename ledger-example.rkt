#lang rosette/safe

(require rosette/lib/destruct "./path-explorer.rkt")

(define int64? (bitvector 64))
(define (int64 i)
  (bv i int64?))

(define accountID? (bitvector 256))
(define (accountID i)
  (bv i accountID?))

; a ledger has two components: a unary relation accounts that contains all existing accounts,
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
(define-with-path-explorer (exec-op op l)
  (destruct op
    [(create-account a b)
     (ledger
      (λ (acc)
        (cond
          [(equal? acc a) #t]
          [else ((ledger-accounts l) acc)]))
      (λ (acc)
        (cond
          [(equal? acc a) b]
          [else ((ledger-balances l) acc)])))]
    [(payment-op s d am) ; TODO check that accounts exist!
     (ledger
      (ledger-accounts l)
      (λ (acc)
        (cond
          [(equal? acc s) (bvsub ((ledger-balances l) acc) am)]
          [(equal? acc d) (bvadd ((ledger-balances l) acc) am)]
          [else ((ledger-balances l) acc)])))]))


#;(define (check-no-negative-balance src dst amnt acc)
  (let ([l (exec-op (payment-op src dst amnt) empty-ledger)])
    (begin
      (assert (bvsge ((ledger-balances l) acc) (int64 0))))))

;(check-no-negative-balance (accountID 0) (accountID 1) (int64 1) (accountID 0))

(define-symbolic s d x accountID?)
(define-symbolic a int64?)
#;(define cex
  (verify (begin
            (assume (equal? x s))
            (check-no-negative-balance s d a x))))

(define-symbolic b boolean?)
(define op
  (if b (payment-op s d a) (create-account s a)))

(define (test op accnt)
  (let ([l (exec-op-path-explorer random-gen op empty-ledger)])
    ((ledger-balances l) accnt)))

;(test (payment-op (accountID 0) (accountID 1) (int64 1)) (accountID 0))
(solve (test op x))