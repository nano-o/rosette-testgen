#lang racket

(require
  racket/pretty
  racket/set
  "grammar-generator.rkt" "read-datums.rkt" "Stellar-overrides.rkt")

(define Stellar-xdr-types
  (read-datums "./Stellar.xdr-types"))
(define grammar
  (xdr-types->grammar-datum Stellar-xdr-types overrides (set "TestCase" "TestCaseResult")))

(define o (open-output-string))
(fprintf o "#lang rosette\n")
(pretty-write '(require rosette/lib/synthax) o)
(pretty-write '(provide (all-defined-out)) o)
(pretty-write grammar o)

; write to file
(with-output-to-file "Stellar-grammar.rkt"
  #:exists 'replace
  (λ ()
    (printf (get-output-string o))))