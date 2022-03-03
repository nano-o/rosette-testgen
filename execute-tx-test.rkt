#lang rosette

(require
  "Stellar-inline.rkt"
  "path-explorer.rkt"
  rosette/lib/synthax
  syntax/to-string
  macro-debugger/stepper)

; 10 millon stroop = 1 XLM
(define (xlm->stroop x)
  (* x 10000000))

; Base fee in stroops
; 100 stroops or 0.00001 XLM
; This fee is per operation
; For now we'll assume that all operations cost the base fee (i.e. no surge pricing)
(define base-fee 100)
(define base-reserve (xlm->stroop 0.5))
(define (min-balance ledger account)
  ; for now there are no account entries
  (* 2 base-reserve))

; Next write a spec that covers at least create account
; Then write the serializer
; Finally execute the thing

; TODO what's a valid address in Stellar?
(define (valid-public-key? pk)
  #t)
; Maybe it would be better to restrict ourselves to a few keys which are know to be valid/invalid

(define-with-path-explorer (execute-tx ledger time tx-envelope)
  ; We must check that accounts still have enough reserve after execution
  ; How are sequence numbers used? Seems like a transaction must a a sequence number one above its source account
  ; What about time bounds?
  (begin
    ; Assume we have a create-account transaction:
    (assume (equal? (car tx-envelope) (bv ENVELOPE_TYPE_TX 32)))
    (let* ([tx (TransactionV1Envelope-tx (cdr tx-envelope))]
           [op (vector-ref-bv (Transaction-operations tx) (bv 0 1))]
           [op-type (car (Operation-body op))]
           [account-id (CreateAccountOp-destination (cdr (Operation-body op)))] ; a public key
           )
      (begin
        (assume (equal? op-type (bv CREATE_ACCOUNT (bitvector 32))))
        ; check whether the account already exists
        ))))

#|(define-with-path-explorer (account-exists? ledger account-id)
  ; account-id is an AccountID union
  (if (null? ledger )
      #f
      (
|#
(define input-tx (TransactionEnvelope-grammar #:depth 8))
; TODO: what's an appropriate depth? Maybe compute the min depth needed when unfolding recursive types only once.

; A ledger is a list of ledger entries
; For now, let's start with a single entry
(define input-ledger
  `(,(LedgerEntry-grammar #:depth 6)))

(define solution-list (stream->list (all-paths (λ (gen) (execute-tx-path-explorer gen input-ledger null input-tx)))))

(for ([s solution-list])
  (if (sat? s)
      (let* ([syms (set-union (symbolics input-tx) (symbolics input-ledger))]
             [complete-sol (complete-solution s syms)])
        (map (λ (f) (pretty-display (syntax->datum f))) (generate-forms complete-sol)))
      (displayln "unsat")))