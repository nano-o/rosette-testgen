#lang racket
(require
  syntax/strip-context
  parser-tools/lex
  (prefix-in : parser-tools/lex-sre)
  megaparsack
  megaparsack/parser-tools/lex
  syntax/readerr
  racket/trace
  data/monad
  data/applicative)

(provide read-syntax) ; meant to be used as a reader language

; The eXtented txrep language
; creates a module that provides `overrides`

; TODO parse more robustly (e.g. what about comments?)
; TODO enable specifying a set of value for a given type

(define-empty-tokens infix-op (gets in dot len))
(define-tokens id (xdr-id))
(define-tokens data (pubkey))

; a Stellar public key (base 32 and must start with G).
; See https://stellar.stackexchange.com/a/261
(define-lex-abbrev pubkey (:: "G" (:= 55 (:or (:/ "A" "Z") (:/ "2" "7")))))

(define lexer
  (lexer-src-pos
   [":=" (token-gets)]
   ["in" (token-in)]
   ["." (token-dot)]
   ["_len"(token-len)]
   [pubkey (token-pubkey lexeme)]
   [(:&
     (:: (:or alphabetic numeric)
         (:* (:or alphabetic numeric "_")))
     (complement pubkey))
    (token-xdr-id lexeme)]
   [(eof) eof]))

(define (run-lexer in)
    (port-count-lines! in)
    (let loop ([v (lexer in)])
      (cond [(void? (position-token-token v)) (loop (lexer in))]
            [(eof-object? (position-token-token v)) '()]
            [else (cons v (loop (lexer in)))])))


(define xdr-member/p
  (many/p (token/p 'xdr-id) #:sep (noncommittal/p (token/p 'dot))))
(define xdr-array-length/p
  (do [m <- xdr-member/p] (token/p 'dot) (token/p 'len) (pure m)))
(define len-override/p
  (do [m <- xdr-array-length/p] (token/p 'gets) (pure m)))
  
(parse-result! (parse-tokens xdr-member/p (run-lexer (open-input-string "a.b.c"))))
(parse-result! (parse-tokens xdr-array-length/p (run-lexer (open-input-string "a.b._len"))))
(parse-result! (parse-tokens len-override/p (run-lexer (open-input-string "a.b._len:="))))

(define (parse-overrides port)
  void)

(define (read-syntax path port)
  ; TODO set the lexer "file-path" parameter
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