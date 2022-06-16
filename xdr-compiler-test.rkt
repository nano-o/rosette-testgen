#lang racket

(require
  "Stellar-compiler-macros.rkt"
  (only-in rosette bv)
  rackunit)

(compile-xdr+grammar "TestLedger" "TransactionEnvelope")

(module+ test
  (define x/256 (-byte-array (bv 0 256)))

  (define my-pubkey (+PublicKey (bv PUBLIC_KEY_TYPE_ED25519 32) x/256))

  (test-case
    "PublicKey-valid?"
    (check-true (PublicKey-valid? my-pubkey)))

  (define my-account-extension-v2
    ($AccountEntryExtensionV2
      (bv #x00000000 32)
      (bv #x00000000 32)
      (vector (-optional (bv #x00000000 32) '()))
      (+AccountEntryExtensionV2::ext (bv #x00000000 32) '())))

  (test-case
    "AccountEntryExtensionV2-valid?"
    (check-true (AccountEntryExtensionV2-valid? my-account-extension-v2)))

  (define my-account
    ($AccountEntry
      (+PublicKey
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
        ($Signer
          (+SignerKey
            (bv #x00000002 32)
            (-byte-array
              (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
          (bv #x00000001 32)))
      (+AccountEntry::ext
        (bv #x00000001 32)
        ($AccountEntryExtensionV1
          ($Liabilities
            (bv #x0000000000000000 64)
            (bv #x0000000000000000 64))
          (+AccountEntryExtensionV1::ext
            (bv #x00000002 32)
            ($AccountEntryExtensionV2
              (bv #x00000000 32)
              (bv #x00000000 32)
              (vector (-optional (bv #x00000000 32) '()))
              (+AccountEntryExtensionV2::ext (bv #x00000000 32) '())))))))

  (test-case
    "AccountEntry-valid?"
    (check-true (AccountEntry-valid? my-account)))

  (define my-tx
    (+TransactionEnvelope
      (bv ENVELOPE_TYPE_TX 32)
      ($TransactionV1Envelope
        ($Transaction
          (+MuxedAccount
            (bv KEY_TYPE_MUXED_ED25519 32)
            ($MuxedAccount::med25519
              (bv #x0000000000000000 64)
              (-byte-array
                (bv
                  29458565313587576488605812219632678825768279426807042594960959184304126581667
                  256))))
          (bv 0 32)
          (bv #x0000000000000000 64)
          (-optional (bv FALSE 32) null)
          (+Memo
            (bv MEMO_RETURN 32)
            (-byte-array (bv 0 256)))
          (vector
            ($Operation
              (-optional (bv FALSE 32) null)
              (+Operation::body
                (bv CREATE_ACCOUNT 32)
                ($CreateAccountOp
                  (+PublicKey
                    (bv PUBLIC_KEY_TYPE_ED25519 32)
                    (-byte-array
                      (bv
                        29458565313587576488605812219632678825768279426807042594960959184304126581667
                        256)))
                  (bv #x0000000000000000 64)))))
          (+Transaction::ext (bv 0 32) null))
        (vector))))

  (test-case
    "TransactionEnvelope-valid?")
    (check-true (TransactionEnvelope-valid? my-tx)))
