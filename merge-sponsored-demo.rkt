#lang rosette


(require
  "path-explorer.rkt"
  "generate-tests.rkt"
  "Stellar-utils.rkt"
  rosette/lib/destruct
  (only-in list-util zip))

(define test-ledger
  (the-grammar #:depth 9 #:start TestLedger-rule))
(define test-tx-envelope
  (the-grammar #:depth 15 #:start TransactionEnvelope-rule))
(define symbols
  (set-union (symbolics test-tx-envelope) (symbolics test-ledger)))

; Here the goal is to test various scenarios in which an account is merged with another account and there are some sponsored-reserve relationship involved.
; The tests will consist of a single ACCOUNT_MERGE operation.
; The variable part of the test is the ledger state in which this operation is applied.

; NOTE: see Stellar-overrides.rkt for constraints on array sizes (e.g. num sponsors)

; First, we establish some base assumptions.
; TODO we have an ACCOUNT_MERGE transaction.

(define (account-okay? account-entry ledger-header)
  (and
   ; seq-num is 1:
   (bveq (AccountEntry-seqNum account-entry) (bv 1 64))
   ; master key has threshold 1
   (bveq (thresholds-ref (AccountEntry-thresholds account-entry) 0) (bv 1 8))
   ; balance is sufficient to pay the fee for one operation and maintain the base reserve:
   (bvuge (AccountEntry-balance account-entry)
          (to-uint64
           (bvadd
            (LedgerHeader-baseFee ledger-header)
            (min-balance/32 ledger-header))))))

(define (establish-preconditions ledger-header ledger-entries tx-envelope)
  (assume
   (and
    ; ledger header
    (bveq (LedgerHeader-ledgerSeq ledger-header) (bv 1 32)) ; sequence number 1
    (bveq (LedgerHeader-baseFee ledger-header) (bv 100 32)) ; base fee is 100 stroops
    (bveq (LedgerHeader-baseReserve ledger-header) (bv (xlm->stroop 0.5) 32)) ; base reserve is 0.5 XLM
    ; ledger entries
    (andmap 
     ; all entries satisfy the following:
     (λ (e)
       (and
        ; it's an account entry:
        (bveq (entry-type e) (bv ACCOUNT 32))
        ; satisfies the account-okay? predicate:
        (account-okay? (:union:-value (LedgerEntry-data e)) ledger-header))) 
     ledger-entries)
    ; the transaction
    (destruct tx-envelope
      [(:union: tag val)
       (and
        ; we have a TransactionV1Envelope:
        (bveq tag (bv ENVELOPE_TYPE_TX 32))
        (destruct val
          [(TransactionV1Envelope tx _)
           (destruct tx
             [(Transaction src fee seq-num time-bounds _ ops _)
              (and
               ; not muxed:
               (bveq (:union:-tag src) (bv KEY_TYPE_ED25519 32))
               ; no time bounds:
               (bveq (:union:-tag time-bounds) (bv 0 32))
               ; fee is equal to base fee:
               (bveq fee (LedgerHeader-baseFee ledger-header))
               ; we have an ACCOUNT_MERGE operation:
               (let ([op (vector-ref-bv (Transaction-operations tx) (bv 0 1))])
                 (destruct op
                   [(Operation src body)
                    (and
                     ; no src account in the op:
                     (bveq (:union:-tag src) (bv 0 32))
                     ; it's an ACCOUNT_MERGE operation:
                     (bveq (:union:-tag body) (bv ACCOUNT_MERGE 32)))])))])]))]))))

(define/path-explorer (test-case ledger-header ledger-entries tx-envelope)
  (begin
    (let ([version (LedgerHeader-ledgerVersion ledger-header)])
      (if ; TODO a better way to do this
       (or
        ; we test both versions 14 and 18:
        (bveq version (bv 14 32))
        (bveq version (bv 18 32)))
       (assume #t)
       (assume #f)))))

(define (test-spec gen)
  (let ([test-header (TestLedger-ledgerHeader test-ledger)]
        [test-entries (vector->list (TestLedger-ledgerEntries test-ledger))])
    (begin
     (establish-preconditions test-header test-entries test-tx-envelope)
     (test-case/path-explorer gen test-header test-entries test-tx-envelope))))

(define (go)
  (compute-solutions test-spec symbols)
  (display-test-inputs))