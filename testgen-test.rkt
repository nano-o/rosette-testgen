#lang rosette

; TODO use a little language that extends txrep to specify constraints
; TODO it would be nice to have a rudimentary type checker (e.g. for bv length)

(require
  "make-grammar.rkt"
  ;"Stellar-grammar.rkt"
  "path-explorer.rkt"
  rosette/lib/synthax
  syntax/to-string
  #;macro-debugger/stepper
  #;macro-debugger/expand)

(make-grammar #:xdr-types "Stellar.xdr-types" #:types "TestCase")

; 10 millon stroops = 1 XLM
(define (xlm->stroop x)
  (* x 10000000))

(define (min-balance lh) ; first approximation
  (* 2 (LedgerHeader-baseReserve lh)))

(define (base-assumptions ledger-header ledger-entries tx-envelope)
  (assume (equal? (LedgerHeader-ledgerSeq ledger-header) (bv 0 32)))
  ; Base fee in stroops
  ; 100 stroops or 0.00001 XLM
  ; This fee is per operation
  (assume (equal? (LedgerHeader-baseFee ledger-header) (bv 100 32)))
  (assume (equal? (LedgerHeader-baseReserve ledger-header) (bv (xlm->stroop 0.5) 32))) ; base reserve of 0.5 XLM
  ; Assume we only have account entries in the ledger
  (assume (andmap
           (λ (e) (equal? (:union:-tag (LedgerEntry-data e)) (bv ACCOUNT 32)))
           ledger-entries))
  ; TransactionEnvelope type:
  (assume (equal? (:union:-tag tx-envelope) (bv ENVELOPE_TYPE_TX 32))))

; When defining path explorers:
; - Make sure to only use forms that are supported by Rosette.
; - Make sure to understand which forms the path-explorer will consider to be nodes in the control-flow graph.

;(pretty-display (syntax->datum
;(expand-only #'
;             (begin
(define/path-explorer (account-exists? ledger account-id)
  (if (null? ledger)
      #f
      (or
       (let* ([ledger-entry (car ledger)]
              [type (:union:-tag (LedgerEntry-data ledger-entry))])
         (and (equal? type (bv ACCOUNT 32))
              (let* ([account-entry (:union:-value (LedgerEntry-data ledger-entry))]
                     [id (AccountEntry-accountID account-entry)])
                (equal? id account-id))))
       (account-exists? (cdr ledger) account-id)
       )))

(define/path-explorer (execute-create-account ledger-header ledger-entries current-time tx-envelope)
  ; We must check that accounts still have enough reserve after execution
  ; How are sequence numbers used? Seems like a transaction must use a sequence number one above its source account
  ; What about time bounds?
  (let* ([tx (TransactionV1Envelope-tx (:union:-value tx-envelope))]
         [op (vector-ref-bv (Transaction-operations tx) (bv 0 1))]
         [op-type (:union:-tag (Operation-body op))]
         [account-id (CreateAccountOp-destination (:union:-value (Operation-body op)))] ; a public key
         )
    (begin
      ; Assume we have a create-account transaction:
      (assume (equal? op-type (bv CREATE_ACCOUNT 32)))
      (if (account-exists? ledger-entries account-id)
          (list CREATE_ACCOUNT_ALREADY_EXIST)
          (list CREATE_ACCOUNT_SUCCESS)))))
;) (list #'define/path-explorer))))

; grammar depth can be computed with the "max-depth" function in "nanopass-compiler.rkt"

(define test-case
  (the-grammar #:depth 16 #:start TestCase-rule))
  
(define (spec gen)
  (let ([ledger-header (TestCase-ledgerHeader test-case)]
        [input-ledger (vector->list (TestCase-ledgerEntries test-case))]
        [input-tx (vector-ref-bv (TestCase-transactionEnvelopes test-case) (bv 0 1))])
    (base-assumptions ledger-header input-ledger input-tx)
    (execute-create-account/path-explorer gen ledger-header input-ledger null input-tx)))

(define solution-list
  (stream->list
   (all-paths spec)))

(define all-symbolics (symbolics test-case))

(for ([s solution-list])
  (if (sat? s)
      (let* ([complete-sol (complete-solution s all-symbolics)])
        (map (λ (f) (pretty-display (syntax->datum f))) (generate-forms complete-sol)))
      (displayln "unsat")))