#lang rosette

(require
  "path-explorer.rkt"
  "generate-tests.rkt"
  "Stellar-utils.rkt"
  rosette/lib/destruct
  ;racket/trace
  (only-in list-util zip)
  macro-debugger/expand)

(define symbolic-ledger
  (the-grammar #:depth 9 #:start TestLedger-rule))
(define symbolic-tx-envelope
  (the-grammar #:depth 15 #:start TransactionEnvelope-rule))
(define symbols
  (set-union (symbolics symbolic-tx-envelope) (symbolics symbolic-ledger)))

; Here the goal is to test various scenarios in which an account is merged with another account and there are some sponsorhip relationships involved.
; The tests will consist of a single ACCOUNT_MERGE operation.
; The variable part of the test is the ledger state in which this operation is applied and the contents of the ACCOUNT_MERGE operation.

; NOTE: see Stellar-overrides.rkt for constraints on array sizes (e.g. num signers is set to 1)

; First, we establish some base assumptions.
(define (account-okay? ledger-entry ledger-header ledger-entries)
  (let* ([account-entry (:union:-value (LedgerEntry-data ledger-entry))]
         [account-id/bv256 (pubkey->bv256 (AccountEntry-accountID account-entry))])
    (and
      ; version is 14:
      (let ([version (LedgerHeader-ledgerVersion ledger-header)])
        (bveq version (bv 14 32)))
      ; seq-num is 1:
      (bveq (AccountEntry-seqNum account-entry) (bv 1 64))
      ; master key has threshold 1
      (bveq (thresholds-ref (AccountEntry-thresholds account-entry) 0) (bv 1 8))
      ; has a v2 extension:
      (account-entry-has-v2-ext? account-entry)
      ; entry is valid:
      (entry-valid? ledger-entry ledger-entries ledger-header)
      ; balance is equal to reserve requirements plus fee:
      (bveq (AccountEntry-balance account-entry)
            (bv->bv64
              (bvadd
                (LedgerHeader-baseFee ledger-header)
                (min-balance/bv32 account-id/bv256 ledger-entries ledger-header)))))))

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
        ; satisfies the account-okay? predicate:
        (account-okay? e ledger-header ledger-entries)))
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
               (account-exists? (muxed-account->bv256 src) ledger-entries)
               ; no time bounds:
               (bveq (:union:-tag time-bounds) (bv 0 32))
               ; fee is equal to base fee:
               (bveq fee (LedgerHeader-baseFee ledger-header))
               ; we have an ACCOUNT_MERGE operation:
               (let ([op (vector-ref-bv (Transaction-operations tx) (bv 0 1))])
                 (destruct op
                   [(Operation src body)
                    (and
                     ; no src account in the op (is this is optional?):
                     (opt-null? src)
                     ; it's an ACCOUNT_MERGE operation:
                     (bveq (:union:-tag body) (bv ACCOUNT_MERGE 32)))])))])]))]))))

(define/path-explorer (test-case ledger-header ledger-entries tx-envelope)
  (begin
    ; ledger entries may or may not have a sponsor:
    (for-each
     ; TODO syntax for this kind of stuff
      (λ (e)
         (let ([ext (:union:-value (LedgerEntry-ext e))])
           (if
             (bveq
               (:union:-tag (LedgerEntryExtensionV1-sponsoringID ext))
               (bv 0 32))
             (assume #t)
             (assume #t))))
      ledger-entries)
    (let* ([tx-src (source-account/bv256 tx-envelope)]
           [tx (TransactionV1Envelope-tx (:union:-value tx-envelope))]
           [op (vector-ref-bv (Transaction-operations tx) (bv 0 1))]
           [dst (muxed-account->bv256 (:union:-value (Operation-body op)))])
      (if (bveq tx-src dst)
        ACCOUNT_MERGE_MALFORMED
        (if (not (account-exists? dst ledger-entries))
          ACCOUNT_MERGE_NO_ACCOUNT
          (if (not (bveq (num-sponsoring tx-src ledger-entries) (bv 0 32)))
            ACCOUNT_MERGE_IS_SPONSOR
            ; TODO now check if the destination is sponsoring any subentry (if so we'd need to modify numSponsoring)
            'TODO))))))

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
  (begin
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
    (displayln (format "finished generating ~a tests" (length ts)))))

; (go)
