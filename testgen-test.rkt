#lang rosette

; TODO use a little language that extends txrep to specify constraints
; TODO it would be nice to have a rudimentary type checker (e.g. for bv length)
; TODO The make-grammar macro does not work. For now we write the generated grammar to a file instead.

(require
  "Stellar-grammar.rkt"
  "path-explorer.rkt"
  "serialize.rkt"
  rosette/lib/synthax
  syntax/to-string
  (only-in list-util zip)
  #;macro-debugger/stepper
  #;macro-debugger/expand)

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

; grammar depth (assuming there's no recursion) can be computed with the "max-depth" function in "grammar-generator.rkt"

(define test-ledger
  (the-grammar #:depth 9 #:start TestLedger-rule))
(define test-tx
  (the-grammar #:depth 15 #:start TransactionEnvelope-rule))

(define (spec gen)
  (let ([ledger-header (TestLedger-ledgerHeader test-ledger)]
        [input-ledger (vector->list (TestLedger-ledgerEntries test-ledger))])
    (base-assumptions ledger-header input-ledger test-tx)
    (execute-create-account/path-explorer gen ledger-header input-ledger null test-tx)))

(define solutions
  (let ([all-symbolics (set-union (symbolics test-tx) (symbolics test-ledger))])
    (for/list ([s
                (stream->list
                 (all-paths spec))])
      (complete-solution s all-symbolics))))

; display the synthesized tests inputs:
(for ([s solutions]
      #:when (sat? s))
  (for ([f (generate-forms s)])
    (begin
      (pretty-display (syntax->datum f))
      (serialize f))))

(define (serialize-tests sols)
  (for/list ([s sols]
             #:when (sat? s))
    (match-let ([(list l tx)
                 (for/list ([f (generate-forms s)])
                   (serialize (datum->syntax #'() (syntax->datum f))))])
      `((test-ledger . ,l)
        (test-tx . ,tx)))))

; write to "./generated-tests/"
(define (create-test-files)
  (let ([tests (serialize-tests solutions)])
    (for ([test (zip (range (length tests)) tests)])
      (match-let ([`(,i . ,test-inputs) test])
        (begin
          (with-output-to-file (apply string-append `("./generated-tests/test-" ,(number->string i) "-ledger.scm"))
            #:exists 'replace
            (λ () (write (dict-ref test-inputs 'test-ledger))))
          (with-output-to-file (apply string-append `("./generated-tests/test-" ,(number->string i) "-tx.scm"))
            #:exists 'replace
            (λ () (write (dict-ref test-inputs 'test-tx)))))))))