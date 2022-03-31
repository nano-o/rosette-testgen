#lang rosette

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
  ; baseReserve is a unint32
  ; balances are int64
  (bvmul (zero-extend (LedgerHeader-baseReserve lh) (bitvector 64)) (bv 2 64)))

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

(define (account-entry? ledger-entry account-id)
    (let* ([type (:union:-tag (LedgerEntry-data ledger-entry))])
      (and (equal? type (bv ACCOUNT 32))
           (let* ([account-entry (:union:-value (LedgerEntry-data ledger-entry))]
                  [id/pubkey (AccountEntry-accountID account-entry)] ; that's a PublicKey
                  [id (:union:-value id/pubkey)])
             (equal? id account-id)))))

(define (account-exists? ledger account-id)
  ; account-id must be a uint256
  (and (not (null? ledger))
       (or
        (account-entry? (car ledger) account-id)
        (account-exists? (cdr ledger) account-id))))
;)

(define (account-balance ledger account-id)
  ; account-id must be a uint256
  (if (null? ledger)
      (error "account does not exist")
      (let ([ledger-entry (car ledger)])
        (if (account-entry? ledger-entry account-id)
            (let* ([account (:union:-value (LedgerEntry-data ledger-entry))])
              (AccountEntry-balance account))
            (account-balance (cdr ledger) account-id)))))

; To debug:
;(pretty-display (syntax->datum
;(expand-only #'
;             (begin ...
(define/path-explorer (execute-create-account ledger-header ledger-entries current-time tx-envelope)
  (let* ([tx (TransactionV1Envelope-tx (:union:-value tx-envelope))]
         [op (vector-ref-bv (Transaction-operations tx) (bv 0 1))] ; the first operation
         [op-type (:union:-tag (Operation-body op))])
    (begin
      ; Assume we have a create-account transaction:
      (assume (equal? op-type (bv CREATE_ACCOUNT 32)))
      (let ([new-account-id (:union:-value (CreateAccountOp-destination (:union:-value (Operation-body op))))]
            [starting-balance (CreateAccountOp-startingBalance (:union:-value (Operation-body op)))])
        ; TODO in what order should the possible error conditions be checked?
        (if (account-exists? ledger-entries new-account-id)
            (bv CREATE_ACCOUNT_ALREADY_EXIST 32)
            (let* ([source-account (Transaction-sourceAccount tx)]
                   [source-account-type (:union:-tag source-account)]
                   [source-account-id (:union:-value source-account)]
                   [base-fee (zero-extend (LedgerHeader-baseFee ledger-header) (bitvector 64))])
              (begin
                (assume (equal? source-account-type (bv KEY_TYPE_ED25519 32))) ; TODO it could also be KEY_TYPE_MUXED_ED25519
                  ;(bvsge starting-balance (bv 0 64)))) ; just assume it for now. What error code should it be though?
                (if
                 (and
                  (account-exists? ledger-entries source-account-id)
                  (bvuge
                   (bvsub
                    (account-balance ledger-entries source-account-id)
                    (bvadd starting-balance base-fee))
                   (min-balance ledger-header)))
                 (if (bvsge starting-balance base-fee)
                     (bv CREATE_ACCOUNT_SUCCESS 32)
                     (bv CREATE_ACCOUNT_LOW_RESERVE 32))
                 (bv CREATE_ACCOUNT_UNDERFUNDED 32)))))))))
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

; display the synthesized tests inputs for debugging:
(define (display-test-inputs sols)
  (for ([s sols]
        #:when (sat? s))
    (for ([f (generate-forms s)])
      (begin
        (pretty-display (syntax->datum f))
        (serialize f))))
  (displayln (format "There are ~a paths" (length solutions)))
  (displayln (format "There are ~a feasible paths" (length (filter sat? solutions)))))

; TODO get test outputs

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