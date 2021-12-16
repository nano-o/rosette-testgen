#lang rosette/safe

; Goal: develop a basic model of transaction processing in Stellar.
; The model should be sufficient to generate tests for the create-account and payment operations.
; Also, develop a test harness that can take test inputs generated here and run them against the C++ implementation.

; TODO maybe we should stick to operations and exclude transactions

(require rosette/lib/destruct "./path-explorer.rkt" "./generators.rkt" (only-in racket for/list with-handlers for) racket/stream)

; model of the ledger

(define int64? (bitvector 64))
(define (int64 i)
  (bv i int64?))

(define accountID? (bitvector 256))
(define (accountID i)
  (bv i accountID?))

; a ledger has two components: a unary relation accounts that contains all existing accounts,
; and a function balances that assigns balances to existing accounts (non-existing accounts are by default assigned a 0 balance).
(struct ledger (accounts balances trustlines))

(define xlm (bv 0 (bitvector 1)))
(define usd (bv 1 (bitvector 1)))

(define empty-ledger
  (ledger
   (lambda (a) #f) ; no accounts
   (lambda (a) (int64 10))
   (lambda (account asset) (or (and (equal? account (accountID 0)) (equal? asset usd))))))

; transactions

(define max-ops-per-tx 100)
(struct transaction (source-account fee seq-num time-bounds memo operations)) ; TODO: can we use contracts on structs?
(struct decorated-signature (hint signature))

(define reserve (int64 1)) ; TODO what is the reserve?

; operations
(struct create-account (account starting-balance))
(define create-account-result-bits 3)
(define create-account-success (bv 0 (bitvector create-account-result-bits)))
(define create-account-already-exists (bv -4 (bitvector create-account-result-bits)))
(define create-account-low-reserve (bv -3 (bitvector create-account-result-bits)))

(struct payment-op (source destination amount))
(define payment-op-result-bits 5)  ; there is a -9 code
(define payment-success (bv 0 (bitvector payment-op-result-bits)))
(define payment-underfunded (bv -2 (bitvector payment-op-result-bits)))
(define payment-malformed (bv -1 (bitvector payment-op-result-bits)))
(define payment-no-destination (bv -5 (bitvector payment-op-result-bits)))

(define-symbolic flags (bitvector 1))

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
              [else ((ledger-balances l) acc)]))
          (ledger-trustlines l)))])]
    [(payment-op s d am)
     (cond
       [(and ((ledger-accounts l) s) ((ledger-accounts l) d) (bvsgt am (int64 0)) (begin (define-symbolic f (bitvector 1)) (exists (list f) ((ledger-trustlines l) d xlm f)))) ; accounts exist and amount is stricly positive and trustline exists
        (cons payment-success
              (ledger
               (ledger-accounts l)
               (λ (acc)
                 (cond
                   [(equal? acc s) (bvsub ((ledger-balances l) acc) am)]
                   [(equal? acc d) (bvadd ((ledger-balances l) acc) am)]
                   [else ((ledger-balances l) acc)]))
               (ledger-trustlines l)))]
       [(not ((ledger-accounts l) d)) ; destination account does not exist
        (cons payment-no-destination l)]
       [(bvsgt am (bvsub ((ledger-balances l) d) reserve)) ; not enough funds
        (cons payment-underfunded l)]
       [else (cons payment-malformed l)])]))
              


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
(define-symbolic tls (~> accountID? (bitvector 1) (bitvector 1) boolean?))
(define sym-ledger (ledger accnts bals tls))

;(test empty-ledger (create-account (accountID 0) (int64 2)) (accountID 1))

(define model
  (solve (test sym-ledger op x (list-gen (list 0 2 1)))))

model
((evaluate accnts model) (accountID 0))

(define model-list (stream->list (all-paths (λ (gen) (test sym-ledger op x gen)))))
(for ([m model-list])
  (println m))
(println (format "we made ~a queries" (length model-list)))
(define num-unsat (count unsat? model-list))
(println (format "~a queries were unsat" num-unsat))

; TODO how do we get a representation of models of uninterpreted functions? seems like we can apply them to symbolic values, like so:
(define model-1 (car model-list))
(define accnts-1 (evaluate accnts model-1))
(accnts-1 s)

; TODO it's great to synthesize ledgers, but how about synthesizing a sequence of operations that creates the ledger in question?

; TODO what about tracking what result should each test have? easy, just execute the model.