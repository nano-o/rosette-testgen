#lang racket

(require
  racket/pretty
  "xdr-compiler.rkt"
  "Stellar-overrides.rkt")

(define output-file "./Stellar.rkt")

(define defs+grammar
  (guile-xdr->racket+grammar
    #'()
    "./Stellar.xdr-types"
    '("TransactionEnvelope" "TestLedger" "TestCaseResult")
    overrides))

; write to file
(with-output-to-file output-file
  #:exists 'replace
  (thunk
    (begin
      (printf "#lang rosette\n")
      (pretty-write '(provide (all-defined-out)))
      (pretty-write '(require rosette/lib/synthax lens lens/data/struct))
      (pretty-write (syntax->datum defs+grammar)))))
