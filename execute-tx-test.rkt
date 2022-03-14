#lang rosette

(require
  "Stellar-inline-2.rkt"
  "path-explorer-2.rkt"
  rosette/lib/synthax
  syntax/to-string
  macro-debugger/stepper
  macro-debugger/expand)

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
; Maybe it would be better to restrict ourselves to a few keys which are known to be valid/invalid

;(pretty-display (syntax->datum
;(expand-only #'
;             (begin
(define/path-explorer (account-exists? ledger account-id)
  (if (null? ledger)
      #f
      (or
       (let* ([ledger-entry (car ledger)]
              [type (union-tag (LedgerEntry-data ledger-entry))])
         (and (equal? type (bv ACCOUNT 32))
              (let* ([account-entry (union-value (LedgerEntry-data ledger-entry))]
                     [id (AccountEntry-accountID account-entry)])
                (equal? id account-id))))
       (account-exists? (cdr ledger) account-id)
       )))

(define/path-explorer (execute-tx ledger time tx-envelope)
  ; We must check that accounts still have enough reserve after execution
  ; How are sequence numbers used? Seems like a transaction must use a sequence number one above its source account
  ; What about time bounds?
  (begin
    ; Assume we only have account entries in the ledger
    (assume (andmap
              (λ (e) (equal? (union-tag (LedgerEntry-data e)) (bv ACCOUNT 32)))
            ledger))
    ; Assume we have a create-account transaction:
    (assume (equal? (union-tag tx-envelope) (bv ENVELOPE_TYPE_TX 32)))
    (let* ([tx (TransactionV1Envelope-tx (union-value tx-envelope))]
           [op (vector-ref-bv (Transaction-operations tx) (bv 0 1))]
           [op-type (union-tag (Operation-body op))]
           [account-id (CreateAccountOp-destination (union-value (Operation-body op)))] ; a public key
           )
      (begin
        (assume (equal? op-type (bv CREATE_ACCOUNT 32)))
        (if (account-exists? ledger account-id)
            (list CREATE_ACCOUNT_ALREADY_EXIST)
            (list CREATE_ACCOUNT_SUCCESS))))))
;) (list #'define/path-explorer))))

(define input-tx (the-grammar #:depth 7 #:start TransactionEnvelope-rule))

; A ledger is a list of ledger entries
(define ledger-depth 4)
(define input-ledger
  (list
   (the-grammar #:depth ledger-depth #:start LedgerEntry-rule)
   (the-grammar #:depth ledger-depth #:start LedgerEntry-rule)))

;(all-paths (λ (gen) (execute-tx-path-explorer gen input-ledger null input-tx)))

(define solution-list (stream->list (all-paths (λ (gen) (execute-tx/path-explorer gen input-ledger null input-tx)))))

(for ([s solution-list])
  (if (sat? s)
      (let* ([syms (set-union (symbolics input-tx) (symbolics input-ledger))]
             [complete-sol (complete-solution s syms)])
        (map (λ (f) (pretty-display (syntax->datum f))) (generate-forms complete-sol)))
      (displayln "unsat")))
