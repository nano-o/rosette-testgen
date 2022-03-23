#lang racket

; provides the make-grammar macro
; TODO not sure how to interface with x-txrep.
; TODO does not work with Rosette (see test)

(require
  (for-syntax "grammar-generator.rkt" "read-datums.rkt" "txrep-test.rkt" racket/set)
  syntax/parse/define)

(provide make-grammar)

(define-syntax-parser make-grammar
  [(_ (~seq #:xdr-types file:string) (~seq #:types t*:string ...))
   (let* ([xdr-types (read-datums (syntax-e #'file))]
         [max-depth-hash (max-depth xdr-types)])
     (for ([t (syntax->datum #'(t* ...))])
       (displayln (format "max-depth for type ~a is ~a" t (hash-ref max-depth-hash t))))
     ; overrides is provided by txrep-test.rkt:
      (xdr-types->grammar xdr-types overrides this-syntax (list->set (syntax->datum #'(t* ...)))))])

(module+ test
  (require
    rosette 
    rosette/lib/synthax)
  
  (make-grammar #:xdr-types "Stellar.xdr-types" #:types "TestCase")
  
  (define (base-assumptions ledger-header ledger-entries tx-envelope)
    (assume (and ; It seems that Rosette identifies all uint32s in this case, and so there's obviously no model (0 != 1)
             (equal? (LedgerHeader-ledgerSeq ledger-header) (bv 0 32))
             (equal? (LedgerHeader-baseFee ledger-header) (bv 1 32)))))
  
  (define test-case
    (the-grammar #:depth 16 #:start TestCase-rule))

  (define (assms-2 tc)
    (let ([ledger-header (TestCase-ledgerHeader test-case)]
          [input-ledger (vector->list (TestCase-ledgerEntries test-case))]
          [input-tx (vector-ref-bv (TestCase-transactionEnvelopes test-case) (bv 0 1))])
      (base-assumptions ledger-header input-ledger input-tx)))

  (let* ([sol (solve (assms-2 test-case))]
         [all-symbolics (symbolics test-case)]
         [complete-sol (complete-solution sol all-symbolics)])
    (pretty-display (syntax->datum (car (generate-forms complete-sol))))))