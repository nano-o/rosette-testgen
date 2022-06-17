#lang errortrace rosette

(require
  "Stellar.rkt"
  "Stellar-utils.rkt"
  lens unstable/lens
  data/either data/monad data/applicative)

(provide
  (all-defined-out))

;; Process a transaction in a ledger, returning an updated ledger and a result.
;; TODO this should assume that the validity check passed and only update sequence numbers and balances
(define (process-fee-seqnum tx ledger)
  ; (->
  ; TransactionEnvelope?
  ; (*list/c LedgerEntry?)
  ; (cons/c TransactionResult? (*list/c LedgerEntry?)))
  (define account-id
    (tx-envelope-src-account tx))
  (define account-entry
    (findf-account-entry account-id ledger))
  (do
    ;; If the source account does not exist, fail with txNO_ACCOUNT
    ;; TODO this should be in the validity check, not here
    [a <- (cond
            [(not account-entry)
             (failure (enum-value txNO_ACCOUNT))]
            [else
              (success
                (LedgerEntry::data-value (LedgerEntry-data account-entry)))])]
    ;; If the sequence number is incorrect, fail with txBAD_SEQ
    ;; TODO same thing, this should be in the validity check, not here
    (cond
      [(bveq
         (tx-envelope-seqnum tx)
         (bvadd
           (AccountEntry-seqNum a)
           (bv 1 64)))
       (success a)]
      [else (failure (enum-value txBAD_SEQ))])))

;; Process the transaction envelopes one by one, updating the ledger state and potentially marking transactions as failed.
(define/contract (process-fees-seqnums ledger tx-envelopes)
  (-> TestLedger? (*list/c TransactionEnvelope?) (*list/c TransactionResult?))
  'todo)
