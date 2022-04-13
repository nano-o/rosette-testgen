#lang rosette

; TODO it would be nice to have a rudimentary type checker (e.g. for bv length).
; TODO The make-grammar macro does not work. For now we write the generated grammar to a file instead.
; TODO use non-determinism for possible error codes.
; We could use a monad for that (with tx-level return code, op-level return codes (maybe a map from op to return codes), and a state.
; Does Rosette support the required primitives (seems so, it has map and flatten on lists)
; Or maybe we just use plain state? set! is lifted...

; NOTE: pick the right grammar in Stellar-utils.rkt

(require
  "Stellar-utils.rkt"
  ;(for-syntax "grammar-generator.rkt" "read-datums.rkt" "Stellar-overrides.rkt" syntax/parse)
  "path-explorer.rkt"
  "generate-tests.rkt"
  (only-in list-util zip)
  macro-debugger/expand)

#;(define-for-syntax Stellar-xdr-types
  (read-datums "./Stellar.xdr-types"))

#;(define-syntax (generate-grammar stx)
  (syntax-parse stx
    [((~literal generate-grammar))
     (xdr-types->grammar
      Stellar-xdr-types
      overrides
      stx
      (set "TransactionEnvelope" "TestLedger" "TestCaseResult"))]))

#;(generate-grammar)

; 10 millon stroops = 1 XLM
(define (xlm->stroop x)
  (* x 10000000))

(define (min-balance lh) ; first approximation
  ; baseReserve is a unint32
  ; balances are int64
  (bvmul (zero-extend (LedgerHeader-baseReserve lh) (bitvector 64)) (bv 2 64)))

(define (thresholds-ref t n) ; n between 0 and 3
  (let ([b (:byte-array:-value t)]
        ; total size is 32 bits
        [i (- 31 (* n 8))]
        [j (- 32 (* (+ n 1) 8))])
    (extract i j b)))

; spec could be a function from ledger state to ledger state + codes,
; like a state monad, but a non-success code aborts the execution
(define (chain m1 m2)
  (λ (s)
    (let* ([res1 (m1 s)]
           [s1 (car res1)]
           [code1 (cdr res1)])
      (if (null? code1) ; no error, we continue
          (m2 s1)
          `(,s1 . ,code1)))))

(define (base-assumptions ledger-header ledger-entries tx-envelope)
  ; should return new ledger, tx-level code, op-level codes
  (assume (bveq (LedgerHeader-ledgerSeq ledger-header) (bv 1 32)))
  ; Base fee in stroops
  ; 100 stroops or 0.00001 XLM
  ; This fee is per operation
  (assume (bveq (LedgerHeader-baseFee ledger-header) (bv 100 32)))
  (assume (bveq (LedgerHeader-baseReserve ledger-header) (bv (xlm->stroop 0.5) 32))) ; base reserve of 0.5 XLM
  ; Assume we only have account entries in the ledger:
  (assume (andmap
           (λ (e) (and
                   (bveq (:union:-tag (LedgerEntry-data e)) (bv ACCOUNT 32))
                   (let ([account-entry (:union:-value (LedgerEntry-data e))])
                     (and
                      (bveq (AccountEntry-seqNum account-entry) (bv 1 64))
                      ; master key has weight 1 (that's what this says is the default: https://developers.stellar.org/docs/glossary/multisig/):
                      (bveq (thresholds-ref (AccountEntry-thresholds account-entry) 0) (bv 1 8))))))
           ledger-entries))
  ; TransactionEnvelope type:
  (assume (bveq (:union:-tag tx-envelope) (bv ENVELOPE_TYPE_TX 32)))
  (let ([tx (TransactionV1Envelope-tx (:union:-value tx-envelope))]
        [base-fee (LedgerHeader-baseFee ledger-header)])
    (assume (bveq (:union:-tag (Transaction-sourceAccount tx)) (bv KEY_TYPE_ED25519 32)))
    (assume (bveq (:union:-tag (Transaction-timeBounds tx)) (bv 0 32)))  ; no time bounds
    (assume (bvuge (Transaction-fee tx) base-fee))  ; assume fee is enough
    (assume (bveq (Transaction-seqNum tx) (bv 2 64)
                  #;(bvadd (bv 1 64) (zero-extend (LedgerHeader-ledgerSeq ledger-header) (bitvector 64))))))) ; set seqNum to 1 to make it valid

; When defining path explorers:
; - Make sure to only use forms that are supported by Rosette.
; - Make sure to understand which forms the path-explorer will consider to be nodes in the control-flow graph.

(define (account-entry-for? ledger-entry account-id)
  ; true iff the ledger entry is an account entry with the given account ID.
  (let* ([type (:union:-tag (LedgerEntry-data ledger-entry))])
    (and (equal? type (bv ACCOUNT 32))
         (let* ([account-entry (:union:-value (LedgerEntry-data ledger-entry))]
                [id/pubkey (AccountEntry-accountID account-entry)] ; that's a PublicKey
                [id (:union:-value id/pubkey)])
           (equal? id account-id)))))

(define (account-exists? ledger-entries account-id)
  ; account-id is a be a uint256
  ; ledger-entries is a list of entries
  (and
   (not (null? ledger-entries))
   (or
    (account-entry-for? (car ledger-entries) account-id)
    (account-exists? (cdr ledger-entries) account-id))))

(define (account-balance ledger-entries account-id)
  ; account-id must be a uint256
  (if (null? ledger-entries)
      (error "account not found")
      (let ([ledger-entry (car ledger-entries)])
        (if (account-entry-for? ledger-entry account-id)
            (let* ([account (:union:-value (LedgerEntry-data ledger-entry))])
              (AccountEntry-balance account))
            (account-balance (cdr ledger-entries) account-id)))))

; To debug:
;(pretty-display (syntax->datum
;(expand-only #'
;             (begin ...
(define/path-explorer (execute-create-account ledger-header ledger-entries tx-envelope)
  ; TODO add a separate list of signatures, which will just be public keys; then, upon serialization, call stc to sign for real.
  ; TODO Check time bounds. Compare to the ledger close time described in the ledger header
  ; TODO We need multiple return codes: for the transaction and the operations
  ; TODO Check sequence number: must be one above the sequence number in the account entry.
  (let* ([tx (TransactionV1Envelope-tx (:union:-value tx-envelope))]
         [seq-num (Transaction-seqNum tx)]
         [op (vector-ref-bv (Transaction-operations tx) (bv 0 1))] ; the first operation
         [op-type (:union:-tag (Operation-body op))])
    (begin
      ; Assume we have a create-account transaction:
      (assume (equal? op-type (bv CREATE_ACCOUNT 32)))
      (let ([new-account-id (:union:-value (CreateAccountOp-destination (:union:-value (Operation-body op))))]
            [starting-balance (CreateAccountOp-startingBalance (:union:-value (Operation-body op)))])
        (if (account-exists? ledger-entries new-account-id)
            (bv CREATE_ACCOUNT_ALREADY_EXIST 32)
            (let* ([source-account (Transaction-sourceAccount tx)]
                   [source-account-type (:union:-tag source-account)]
                   [base-fee (zero-extend (LedgerHeader-baseFee ledger-header) (bitvector 64))])
              (begin
                (assume (equal? source-account-type (bv KEY_TYPE_ED25519 32))) ; TODO it could also be KEY_TYPE_MUXED_ED25519
                (let ([source-account-id (:union:-value source-account)])
                  (if
                   (and
                    (account-exists? ledger-entries source-account-id)
                    (bvuge
                     (bvsub
                      (account-balance ledger-entries source-account-id)
                      (bvadd starting-balance base-fee))
                     (min-balance ledger-header)))
                   (if (bvsge starting-balance (min-balance ledger-header))
                       (bv CREATE_ACCOUNT_SUCCESS 32)
                       (bv CREATE_ACCOUNT_LOW_RESERVE 32))
                   (bv CREATE_ACCOUNT_UNDERFUNDED 32))))))))))
;(list #'define/path-explorer))))

; grammar depth (assuming there's no recursion) can be computed with the "max-depth" function in "grammar-generator.rkt"

(define test-ledger
  (the-grammar #:depth 9 #:start TestLedger-rule))
; TODO: why do we have a non-empty vc here?
; (println (vc))
(define test-tx
  (the-grammar #:depth 15 #:start TransactionEnvelope-rule))
(define symbols
  (set-union (symbolics test-tx) (symbolics test-ledger)))

(define (spec/path-explorer gen)
  (let ([ledger-header (TestLedger-ledgerHeader test-ledger)]
        [input-ledger (vector->list (TestLedger-ledgerEntries test-ledger))])
    (base-assumptions ledger-header input-ledger test-tx)
    (execute-create-account/path-explorer gen ledger-header input-ledger test-tx)))

(define (spec test-ledger test-tx)
  (let ([ledger-header (TestLedger-ledgerHeader test-ledger)]
        [input-ledger (vector->list (TestLedger-ledgerEntries test-ledger))])
    (base-assumptions ledger-header input-ledger test-tx)
    (execute-create-account ledger-header input-ledger test-tx)))

(define (run-test t)
  ; t should be a list consisting of a TestLedger and a TransactionEnvelope
  (match-let* ([(list tl tx) t])
    (spec tl tx)))

(require "Stellar-utils.rkt")
(define (go)
  (compute-solutions spec/path-explorer symbols)
  (define ts (get-test-inputs))
  (for ([(i t)  (in-dict (zip (range (length ts)) ts))])
    (let ([tx (cadr t)])
      (displayln (format "tx for test ~a is:\n ~a" i tx))
      (displayln (format "source account for test ~a is ~a" i (source-account tx))))
    (let ([output (run-test t)])
      (displayln (format "test number ~a returned ~a" i output)))
    (newline))
  (create-test-files))