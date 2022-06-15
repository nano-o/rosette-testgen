#lang racket

(require
  racket/pretty
  "xdr-compiler.rkt"
  "read-datums.rkt"
  (only-in racket/match match-define)
  "Stellar-overrides.rkt")

(define Stellar-xdr-types
  (read-datums "./Stellar.xdr-types"))

  (match-define
    `((types . ,types) (consts . ,consts))
    (preprocess-ir Stellar-xdr-types))

(define grammar
  (xdr-types->grammar #'() consts types '("SCPQuorumSet" "TransactionEnvelope" "TestLedger" "TestCaseResult") overrides))

(define o (open-output-string))
(fprintf o "#lang rosette\n")
(pretty-write '(require rosette/lib/synthax) o)
(pretty-write '(provide (all-defined-out)) o)
(pretty-write (syntax->datum grammar) o)

; write to file
(with-output-to-file "/tmp/grammar.rkt"
  #:exists 'replace
  (λ ()
    (printf (get-output-string o))))
