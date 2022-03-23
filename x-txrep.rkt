#lang racket
(require
  syntax/strip-context
  #;syntax/readerr)

(provide read-syntax) ; meant to be used as a reader language

; The eXtented txrep language
; creates a module that provides `overrides`

; TODO parse more robustly (e.g. what about comments?)
; TODO enable specifying a set of value for a given type

(define (parse-line l)
  (match-let ([(list xdr-path len) (map string-trim (string-split l "="))])
    `(,(string-split xdr-path ".") . ,(string->number len))))

(define (parse-overrides port)
  (filter (λ (x) (not (equal? x "")))
          (for/list ([l (port->lines port)])
            (if (equal? l "") l (parse-line l)))))

(define (read-syntax path port)
    (strip-context ; TODO why is this needed?
     #`(module x-txrep-mod racket/base ; the module name seems irrelevant
         (provide overrides)
         (define overrides '#,(parse-overrides port)))))

(module+ test
  (require rackunit)
  (define o (open-output-string))
  (fprintf
   o
   (apply string-append
          '(
            "Transaction.operations._len = 1\n"
            "TestCase.ledgerEntries._len = 2\n"
            "TestCase.transactionEnvelopes._len = 1\n"
            "TransactionV1Envelope.signatures._len = 0\n")))
  (define i (open-input-string (get-output-string o)))
  (define/provide-test-suite parse-overrides/test
    (test-case
     "basic test"
     (check-equal?
      (parse-overrides i)
      '((("Transaction" "operations" "_len") . 1)
        (("TestCase" "ledgerEntries" "_len") . 2)
        (("TestCase" "transactionEnvelopes" "_len") . 1)
        (("TransactionV1Envelope" "signatures" "_len") . 0))))))