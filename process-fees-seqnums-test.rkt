#lang racket

(require
  "Stellar.rkt"
  "process-fees-seqnums.rkt"
  "Stellar-test-data.rkt"
  data/either
  rackunit)

; (check-true
  ; (success? (process-fee-seqnum my-tx-envelope (list my-account))))
