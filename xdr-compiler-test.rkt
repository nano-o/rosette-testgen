#lang errortrace racket

(require
  (for-syntax
    ; (only-in racket pretty-print)
    ; racket/set
    "xdr-compiler.rkt"
    (only-in "Stellar-overrides.rkt" overrides)
    (only-in racket/match match-define)
    "read-datums.rkt")
  (only-in rosette bv)
  rackunit)

(begin-for-syntax
  (define
    Stellar-xdr-types
    (read-datums "./Stellar.xdr-types"))
  (match-define
    `((types . ,types) (consts . ,consts))
    (preprocess-ir Stellar-xdr-types)))

(define-syntax (compile-xdr stx)
  (define the-syntax
    (xdr-types->racket
      stx
      consts
      types
      ; (list "TransactionEnvelope" "TestLedger" "TestCaseResult")))
      (list "AccountEntry")))
  the-syntax)

(compile-xdr)

(module+ test
  (define x/256 (-byte-array (bv 0 256)))

  (define my-pubkey (PublicKey (bv PUBLIC_KEY_TYPE_ED25519 32) x/256))

  (test-case
    "PublicKey-valid?"
    (check-true (PublicKey-valid? my-pubkey)))

  (define my-account-extension-v2
    (AccountEntryExtensionV2
      (bv #x00000000 32)
      (bv #x00000000 32)
      (vector (-optional (bv #x00000000 32) '()))
      (AccountEntryExtensionV2::ext (bv #x00000000 32) '())))

  (test-case
    "AccountEntryExtensionV2-valid?"
    (check-true (AccountEntryExtensionV2-valid? my-account-extension-v2)))

  (define my-account
    (AccountEntry
      (PublicKey
        (bv #x00000000 32)
        (-byte-array
          (bv #x3bf36f0de9880e80bfc23596344a501d0681f830c68054d23fd0bb4493f63fe9 256)))
      (bv #x0000000003938764 64)
      (bv #x0000000000000001 64)
      (bv #x00000001 32)
      (-optional (bv #x00000000 32) '())
      (bv #x00000000 32)
      (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
      (-byte-array (bv #x01000000 32))
      (vector
        (Signer
          (SignerKey
            (bv #x00000002 32)
            (-byte-array
              (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
          (bv #x00000001 32)))
      (AccountEntry::ext
        (bv #x00000001 32)
        (AccountEntryExtensionV1
          (Liabilities
            (bv #x0000000000000000 64)
            (bv #x0000000000000000 64))
          (AccountEntryExtensionV1::ext
            (bv #x00000002 32)
            (AccountEntryExtensionV2
              (bv #x00000000 32)
              (bv #x00000000 32)
              (vector (-optional (bv #x00000000 32) '()))
              (AccountEntryExtensionV2::ext (bv #x00000000 32) '())))))))

  (test-case
    "AccountEntry-valid?"
    (check-true (AccountEntry-valid? my-account))))
