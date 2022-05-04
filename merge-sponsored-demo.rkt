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
    (bveq (LedgerHeader-ledgerVersion ledger-header) (bv 14 32)) ; version is 14
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
               ; TODO a seq-num-valid? predicate
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

(define/path-explorer
  (merge-entries src/bv256 dst/bv256 ledger-entries)
  ; here we assume that all conditions for the operation to be successful are met
  ; iterate over all entries and remove sponsoring relationships
  ; then add the src balance to the dst
  ; For now we'll just write down the control structure (so we can explore all paths) but do nothing.
  (map
    (λ (e)
       (let* ([account-entry (:union:-value (LedgerEntry-data e))]
              [current-entry-id/bv256 (pubkey->bv256 (AccountEntry-accountID account-entry))])
         (if (bveq current-entry-id/bv256 src/bv256)
           (void) ; current-entry is the one we want to delete
           (begin
             ; add balance fs current-entry is the destination
             (if (bveq current-entry-id/bv256 dst/bv256)
               (void)
               (void))
             ; now adjust num-sponsoring
             (let* ([src-entry (find-account-entry src/bv256 ledger-entries)]
                    [sponsors? (sponsors? current-entry-id/bv256 src-entry)]
                    [num-sponsored-signers (num-signers-sponsored-by-in current-entry-id/bv256 src-entry)])
               (begin
                 (if sponsors?
                   (void) ; subtract 2 from num-sponsoring
                   (void))
                 (if (bvugt num-sponsored-signers (bv 0 32))
                   (void) ; subtract num-sponsored-signers from num-sponsoring
                   (void))))))))
    ledger-entries))

(define/path-explorer (test-case ledger-header ledger-entries tx-envelope)
  ; TODO return the new ledger entries
  (let* ([tx-src/bv256 (source-account/bv256 tx-envelope)]
         [tx (TransactionV1Envelope-tx (:union:-value tx-envelope))]
         [op (vector-ref-bv (Transaction-operations tx) (bv 0 1))]
         [dst/bv256 (muxed-account->bv256 (:union:-value (Operation-body op)))])
    ; TODO first we must charge the tx fee
    ; Then if no error we must merge the accounts
    (if (bveq tx-src/bv256 dst/bv256)
      ACCOUNT_MERGE_MALFORMED
      (if (not (account-exists? dst/bv256 ledger-entries))
        ACCOUNT_MERGE_NO_ACCOUNT
        (if (not (bveq (num-sponsoring tx-src/bv256 ledger-entries) (bv 0 32)))
          ACCOUNT_MERGE_IS_SPONSOR
          (begin
            (merge-entries tx-src/bv256 dst/bv256 ledger-entries)
            ACCOUNT_MERGE_SUCCESS)))))) ; NOTE there are many unsat paths

(define (crash-precondition ledger-header ledger-entries tx-envelope)
  ; here we assert that the dst sponsors the src entry
  (let* ([tx-src/bv256 (source-account/bv256 tx-envelope)]
         [src-entry (find-account-entry tx-src/bv256 ledger-entries)]
         [tx (TransactionV1Envelope-tx (:union:-value tx-envelope))]
         [op (vector-ref-bv (Transaction-operations tx) (bv 0 1))]
         [dst/bv256 (muxed-account->bv256 (:union:-value (Operation-body op)))])
   (assume
    (and
      (not (bveq tx-src/bv256 dst/bv256))
      (account-exists? dst/bv256 ledger-entries)
      (bveq (num-sponsoring tx-src/bv256 ledger-entries) (bv 0 32))
      (sponsors? dst/bv256 src-entry)))))

(define/path-explorer (test-spec-crash test-ledger test-tx-envelope)
  (let ([test-header (TestLedger-ledgerHeader test-ledger)]
        [test-entries (vector->list (TestLedger-ledgerEntries test-ledger))])
    (begin
     (establish-preconditions test-header test-entries test-tx-envelope)
     (crash-precondition test-header test-entries test-tx-envelope))))

(define/path-explorer (test-spec test-ledger test-tx-envelope)
  (let ([test-header (TestLedger-ledgerHeader test-ledger)]
        [test-entries (vector->list (TestLedger-ledgerEntries test-ledger))])
    (begin
     (establish-preconditions test-header test-entries test-tx-envelope)
     (test-case test-header test-entries test-tx-envelope))))

(define (run-test t)
  (match-let* ([(list tl tx) t])
    (test-spec tl tx)))

(define (lazy-go)
 (lazy-run-tests
   (λ (gen) (test-spec-crash/path-explorer gen symbolic-ledger symbolic-tx-envelope))
   symbols))

; TODO something should fail if the dst is sponsoring the src

(define (go)
 ; TODO generate tests lazyly...
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
