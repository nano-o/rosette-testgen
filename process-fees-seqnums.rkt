#lang errortrace rosette

(require
  "Stellar.rkt"
  "Stellar-utils.rkt"
  lens unstable/lens
  data/either data/monad data/applicative)

(provide
  (all-defined-out))

(define/contract (check-valid tx ledger)
  ;; This checks whether a single transaction is valid
  ;; See https://developers.stellar.org/docs/glossary/transactions/#validity-of-a-transaction
  (->
    TransactionEnvelope?
    Ledger?
    (either/c (bitvector 32) AccountEntry?)) ; in case of failure, result is a TransactionResultCode
  (define account-id
    (tx-envelope-src-account tx))
  (define account-entry
    (findf-account-entry account-id (Ledger-entries ledger)))
  (do
    ;; If the source account does not exist, fail with txNO_ACCOUNT.
    [a <- (cond
            [(not account-entry)
             (failure (enum-value txNO_ACCOUNT))]
            [else
              (success
                (LedgerEntry::data-value (LedgerEntry-data account-entry)))])]
    ;; If the fee is below the minimum fee, fail with txINSUFFICIENT_FEE
    (cond
      [(bvult (tx-envelope-fee tx) (minimum-fee (Ledger-header ledger) tx))
       (failure (enum-value txINSUFFICIENT_FEE))]
      [else
        (success null)])
    ;; If the sequence number is incorrect, fail with txBAD_SEQ
    (cond
      [(not
         (bveq
           (tx-envelope-seqnum tx)
           (bvadd
             (AccountEntry-seqNum a)
             (bv 1 64))))
        (failure (enum-value txBAD_SEQ))]
      [else
       (success a)])))

;; Precondition: tx is valid in the ledger
(define/contract (process-fee-seqnum ledger tx)
  (->
    Ledger?
    TransactionEnvelope?
    (*list/c LedgerEntry?))
  (define account-lens
    (make-account-lens/account-entry (tx-envelope-src-account tx)))
  (define fee
    (minimum-fee (Ledger-header ledger) tx))
  (lens-transform/list
    (Ledger-entries ledger)
    (lens-compose
      AccountEntry-seqNum-lens
      account-lens)
    (λ (n) (bvadd n (bv 1 64)))
    (lens-compose
      AccountEntry-balance-lens
      account-lens)
    (λ (n) (bvsub n (zero-extend fee (bitvector 64))))))

;; Process the transaction envelopes one by one, updating the ledger state and potentially marking transactions as failed.
(define/contract (process-fees-seqnums ledger tx-envelopes)
  (-> Ledger? (*list/c TransactionEnvelope?) (*list/c TransactionResult?))
  'todo)
