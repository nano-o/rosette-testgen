#lang rosette


(require
  "path-explorer.rkt"
  "generate-tests.rkt"
  "Stellar-utils.rkt"
  rosette/lib/destruct
  (only-in list-util zip)
  macro-debugger/expand)

(define symbolic-ledger
  (the-grammar #:depth 9 #:start TestLedger-rule))
(define symbolic-tx-envelope
  (the-grammar #:depth 15 #:start TransactionEnvelope-rule))
(define symbols
  (set-union (symbolics symbolic-tx-envelope) (symbolics symbolic-ledger)))

; Here the goal is to test various scenarios in which an account is merged with another account and there are some sponsored-reserve relationship involved.
; The tests will consist of a single ACCOUNT_MERGE operation.
; The variable part of the test is the ledger state in which this operation is applied and the contents of the ACCOUNT_MERGE operation.

; NOTE: see Stellar-overrides.rkt for constraints on array sizes (e.g. num sponsors)

; First, we establish some base assumptions.
(define (account-okay? account-entry ledger-header)
  (and
   ; seq-num is 1:
   (bveq (AccountEntry-seqNum account-entry) (bv 1 64))
   ; master key has threshold 1
   (bveq (thresholds-ref (AccountEntry-thresholds account-entry) 0) (bv 1 8))
   ; numSubEntries equals the number of signers (in this case 1)
   (bveq (AccountEntry-numSubEntries account-entry) (bv 1 32))
   ; balance is sufficient to pay the fee for one operation and maintain the base reserve:
   (bveq (AccountEntry-balance account-entry)
          (to-uint64
           (bvadd
            (LedgerHeader-baseFee ledger-header)
            (min-balance/32 ledger-header 1)))))) ; 1 sub-entry

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
        ; it has a v1 extension:
        (bveq (:union:-tag (LedgerEntry-ext e)) (bv 1 32))
        ; sponsoring ID is not self:
        (let ([entry-sponsor (LedgerEntryExtensionV1-sponsoringID (:union:-value (LedgerEntry-ext e)))]
              [account-id (AccountEntry-accountID (:union:-value (LedgerEntry-data e)))])
          (if (bveq (:union:-tag entry-sponsor) (bv 1 32)) ; if it has a non-null sponsor
              (not (PublicKey-equal?
                    (:union:-value entry-sponsor)
                    account-id))
              #t))
        ; satisfies the account-okay? predicate:
        (account-okay? (:union:-value (LedgerEntry-data e)) ledger-header)))
     ledger-entries)
    ; there are no duplicate accounts in the ledger:
    (not (duplicate-accounts? ledger-entries))
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
               ; sequence number is 2:
               (bveq seq-num (bv 2 64))
               ; not muxed:
               (bveq (:union:-tag src) (bv KEY_TYPE_ED25519 32))
               ; the source account exists:
               (account-exists? ledger-entries (account-ed25519/bv src))
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
    ; we have version 14 or 18:
    (let ([version (LedgerHeader-ledgerVersion ledger-header)])
      (if (bveq version (bv 14 32))
          (assume #t)
          (if 
           (bveq version (bv 18 32))
           (assume #t)
           (assume #f))))
    ; ledger entries may or may not have a sponsor:
    (for-each
     (λ (e) ; NOTE: we assumed they all have a v1 extension
       (let ([ext (:union:-value (LedgerEntry-ext e))])
         (if
          (bveq
           (:union:-tag (LedgerEntryExtensionV1-sponsoringID ext))
           (bv 0 32))
          (assume #t)
          (assume #t))))
     ledger-entries)
    (let* ([tx-src (source-account/bv tx-envelope)]
           [tx (TransactionV1Envelope-tx (:union:-value tx-envelope))]
           [op (vector-ref-bv (Transaction-operations tx) (bv 0 1))]
           [dst (account-ed25519/bv (:union:-value (Operation-body op)))])
      (if (bveq tx-src dst)
          ACCOUNT_MERGE_MALFORMED
          (if (not (account-exists? ledger-entries dst))
              ACCOUNT_MERGE_NO_ACCOUNT
              'TODO)))))

(define/path-explorer (test-spec test-ledger test-tx-envelope)
  (let ([test-header (TestLedger-ledgerHeader test-ledger)]
        [test-entries (vector->list (TestLedger-ledgerEntries test-ledger))])
    (begin
     (establish-preconditions test-header test-entries test-tx-envelope)
     (test-case test-header test-entries test-tx-envelope))))

(define (run-test t)
  (match-let* ([(list tl tx) t])
    (test-spec tl tx)))

(define (go)
  (compute-solutions
   (λ (gen) (test-spec/path-explorer gen symbolic-ledger symbolic-tx-envelope))
   symbols)
  (define ts (get-test-inputs))
  (displayln (format "there are ~a test cases" (length ts)))
  (for ([(i t)  (in-dict (zip (range (length ts)) ts))])
    (let ([output (run-test t)])
      (displayln (format "test number ~a returned ~a" i output)))
    (newline))
  (create-test-files)
  (displayln (format "finished generating ~a tests" (length ts))))