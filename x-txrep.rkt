#lang racket
(require
  syntax/strip-context
  parser-tools/lex
  (prefix-in : parser-tools/lex-sre)
  megaparsack
  syntax/readerr)

(provide read-syntax) ; meant to be used as a reader language

; The eXtented txrep language
; creates a module that provides `overrides`

; TODO parse more robustly (e.g. what about comments?)
; TODO enable specifying a set of value for a given type

(define-empty-tokens infix-op (gets in))
(define-tokens id (xdr-id))
(define-tokens data (pubkey))

; a Stellar public key (base 32 and must start with G).
; See https://stellar.stackexchange.com/a/261
(define-lex-abbrev pubkey (:: "G" (:= 55 (:or (:/ "A" "Z") (:/ "2" "7")))))

(define lexer
  (lexer-src-pos
   [":=" (token-gets)]
   ["in" (token-in)]
   [pubkey (token-pubkey lexeme)]
   [(:&
     (:+ (:or alphabetic numeric "_"))
     (complement pubkey))
    (token-xdr-id lexeme)]))

(define (parse-overrides port)
  void) 

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