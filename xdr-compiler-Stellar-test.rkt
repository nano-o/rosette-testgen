#lang errortrace racket

(require
  (for-syntax
    racket/set
    (only-in "xdr-compiler.rkt" xdr-types->racket)
    (only-in "Stellar-overrides.rkt" overrides)
    "read-datums.rkt")
  (only-in "xdr-compiler.rkt" valid?)
  "read-datums.rkt"
  (only-in "Stellar-overrides.rkt" overrides)
  (only-in rosette bv bveq)
  lens
  unstable/lens
  rackunit)

(define-for-syntax
  Stellar-xdr-types
  (read-datums "./Stellar.xdr-types"))
(define
  Stellar-xdr-types
  (read-datums "./Stellar.xdr-types"))

(define-syntax (compile-xdr stx)
  (xdr-types->racket
    Stellar-xdr-types
    overrides
    stx
    (set "TransactionEnvelope" "TestLedger" "TestCaseResult")))

(compile-xdr)

(define x/256 (-byte-array (bv 0 256)))
(define my-pubkey (PublicKey PUBLIC_KEY_TYPE_ED25519 x/256))
(define x-again (lens-view PublicKey-value-lens my-pubkey))
(check-true (bveq (-byte-array-value x/256) (-byte-array-value x-again)))
(check-true
  (bveq
    (lens-view -byte-array-value-lens x/256)
    (lens-view~> my-pubkey PublicKey-value-lens -byte-array-value-lens)))

(check-true (valid? Stellar-xdr-types overrides "PublicKey" my-pubkey))
