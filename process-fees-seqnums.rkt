#lang errortrace rosette

(require
  "Stellar.rkt"
  "Stellar-utils.rkt"
  lens unstable/lens
  data/either data/monad data/applicative)

(provide
  (all-defined-out))

(define (check-valid tx ledger-header ledger-entries)
  ;; This checks whether a single transaction is valid
  ;; See https://developers.stellar.org/docs/glossary/transactions/#validity-of-a-transaction
  (->
    TransactionEnvelope?
    LedgerHeader?
    (*list/c LedgerEntry?)
    (either/c (bitvector 32) AccountEntry?)) ; in case of failure, result is a TransactionResultCode
  (define account-id
    (tx-envelope-src-account tx))
  (define account-entry
    (findf-account-entry account-id ledger-entries))
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
      [(bvult (tx-envelope-fee tx) (minimum-fee ledger-header tx))
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

;; Process a transaction in a ledger, returning an updated ledger and a result.
;; TODO this should assume that the validity check passed and only update sequence numbers and balances
;; So it seems the only possible error is an insufficient balance
(define (process-fee-seqnum tx ledger)
  ; (->
  ; TransactionEnvelope?
  ; (*list/c LedgerEntry?)
  ; (cons/c TransactionResult? (*list/c LedgerEntry?)))
  'todo)

;; Process the transaction envelopes one by one, updating the ledger state and potentially marking transactions as failed.
(define/contract (process-fees-seqnums ledger tx-envelopes)
  (-> TestLedger? (*list/c TransactionEnvelope?) (*list/c TransactionResult?))
  'todo)
