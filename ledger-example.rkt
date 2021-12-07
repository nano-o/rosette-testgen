#lang rosette/safe

(require rosette/lib/destruct "./path-explorer.rkt" "./generators.rkt")

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
(define create-account-result-bits 3)
(define create-account-success (bv 0 (bitvector create-account-result-bits)))
(define create-account-already-exists (bv -4 (bitvector create-account-result-bits)))
(define create-account-low-reserve (bv -3 (bitvector create-account-result-bits)))
(define reserve (int64 1)) ; TODO what is the reserve?

(struct payment-op (source destination amount))
(define payment-op-result-bits 5)  ; there is a -9 code
(define payment-success (bv 0 (bitvector payment-op-result-bits)))

; semantics
; exec-op returns a pair consisting of the new ledger and the result code
(define-with-path-explorer (exec-op op l)
  (destruct op
    [(create-account a b)
     (cond
       [((ledger-accounts l) a) ; already exists
        (cons create-account-already-exists l)]
       [(bvslt b reserve) ; initial balance below reserve
        (cons create-account-low-reserve l)]
       [else
        (cons
         create-account-success
         (ledger
          (λ (acc)
            (cond
              [(equal? acc a) #t]
              [else ((ledger-accounts l) acc)]))
          (λ (acc)
            (cond
              [(equal? acc a) b]
              [else ((ledger-balances l) acc)]))))])]
    [(payment-op s d am) ; TODO check that accounts exist!
     (cons payment-success
           (ledger
            (ledger-accounts l)
            (λ (acc)
              (cond
                [(equal? acc s) (bvsub ((ledger-balances l) acc) am)]
                [(equal? acc d) (bvadd ((ledger-balances l) acc) am)]
                [else ((ledger-balances l) acc)]))))]))


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

; here we define a test that that executes an operation on the empty ledger and then queries the balance of an account.
; we want it to take branch 0, then 2, then 1
; this means the the operation is a create-account operation (branch 0), that it does not fail (branch 2), and then that we query the balance of an account different from the one being created.
(define (test l op accnt gen)
  (let ([new-l (cdr (exec-op-path-explorer gen op l))])
    ((ledger-balances new-l) accnt)))

; no assert should fail here:
(test empty-ledger (create-account (accountID 0) (int64 2)) (accountID 1) (list-gen (list 0 2 1)))
; what we should see next is that b is false, the amount is at least 1, and x is not equal to s:
(solve (test empty-ledger op x (list-gen (list 0 2 1))))

(clear-vc!) ; TODO are vcs cleared after solve?

; because the ledger is just two functions and Rosette supports symbolic, uninterpreted functions, we can make the ledger state part of the symbolic inputs.
(define-symbolic  bals (~> accountID? int64?))
(define-symbolic accnts (~> accountID? boolean?))
(define sym-ledger (ledger accnts bals))

;(test empty-ledger (create-account (accountID 0) (int64 2)) (accountID 1))

(define model
  (solve (test sym-ledger op x (list-gen (list 0 2 1))) ))

model
((evaluate accnts model) (accountID 0))

(println "ha")

; exhaustive enumeration
(define gen (exhaustive-gen))
(solve (test sym-ledger op x gen))
(gen 0)
(solve (test sym-ledger op x gen))
(gen 0)
(solve (test sym-ledger op x gen))
(gen 0)
(solve (test sym-ledger op x gen))
(gen 0)
(solve (test sym-ledger op x gen))
(gen 0)
(solve (test sym-ledger op x gen))
(gen 0)
(solve (test sym-ledger op x gen))
(gen 0)
(solve (test sym-ledger op x gen))
(gen 0)
      
