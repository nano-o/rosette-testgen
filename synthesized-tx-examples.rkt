#lang rosette

(require "Stellar-grammar.rkt")

(provide (all-defined-out))

(define example-1
  #'(define input-tx
      (:union:
       (bv ENVELOPE_TYPE_TX 32)
       (TransactionV1Envelope
        (Transaction
         (:union:
          (bv KEY_TYPE_MUXED_ED25519 32)
          (MuxedAccount::med25519
           (bv #x0000000000000000 64)
           (:byte-array:
            (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))))
         (bv #x00000000 32)
         (bv #x0000000000000000 64)
         (:union: (bv FALSE 32) null)
         (:union:
          (bv MEMO_RETURN 32)
          (:byte-array:
           (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
         (vector
          (Operation
           (:union: (bv FALSE 32) null)
           (:union:
            (bv CREATE_ACCOUNT 32)
            (CreateAccountOp
             (:union:
              (bv PUBLIC_KEY_TYPE_ED25519 32)
              (:byte-array:
               (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
             (bv #x0000000000000000 64))))
          (Operation
           (:union: (bv FALSE 32) null)
           (:union:
            (bv PATH_PAYMENT_STRICT_SEND 32)
            (PathPaymentStrictSendOp
             (:union: (bv ASSET_TYPE_NATIVE 32) null)
             (bv #x0000000000000000 64)
             (:union:
              (bv KEY_TYPE_MUXED_ED25519 32)
              (MuxedAccount::med25519
               (bv #x0000000000000000 64)
               (:byte-array:
                (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))))
             (:union: (bv ASSET_TYPE_NATIVE 32) null)
             (bv #x0000000000000000 64)
             (vector
              (:union: (bv ASSET_TYPE_NATIVE 32) null)
              (:union: (bv ASSET_TYPE_NATIVE 32) null))))))
         (:union: (bv 0 32) null))
        (vector
         (DecoratedSignature
          (:byte-array: (bv #x00000000 32))
          (vector (bv #x00 8) (bv #x00 8)))
         (DecoratedSignature
          (:byte-array: (bv #x00000000 32))
          (vector (bv #x00 8) (bv #x00 8))))))))

(define example-2
  #'(define test-case
      (TestCase
       (LedgerHeader
        (bv #x00000000 32)
        (:byte-array:
         (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
        (StellarValue
         (:byte-array:
          (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
         (bv #x0000000000000000 64)
         (vector (vector (bv #x00 8) (bv #x00 8)) (vector (bv #x00 8) (bv #x00 8)))
         (:union:
          (bv STELLAR_VALUE_SIGNED 32)
          (LedgerCloseValueSignature
           (:union:
            (bv PUBLIC_KEY_TYPE_ED25519 32)
            (:byte-array:
             (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
           (vector (bv #x00 8) (bv #x00 8)))))
        (:byte-array:
         (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
        (:byte-array:
         (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
        (bv #x00000000 32)
        (bv #x0000000000000000 64)
        (bv #x0000000000000000 64)
        (bv #x00000000 32)
        (bv #x0000000000000000 64)
        (bv #x00000064 32)
        (bv #x004c4b40 32)
        (bv #x00000000 32)
        (list
         (:byte-array:
          (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
         (:byte-array:
          (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
         (:byte-array:
          (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
         (:byte-array:
          (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
        (:union:
         (bv 1 32)
         (LedgerHeaderExtensionV1 (bv #x00000000 32) (:union: (bv 0 32) null))))
       (vector
        (LedgerEntry
         (bv #x00000000 32)
         (:union:
          (bv ACCOUNT 32)
          (AccountEntry
           (:union:
            (bv PUBLIC_KEY_TYPE_ED25519 32)
            (:byte-array:
             (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
           (bv #x0000000000000000 64)
           (bv #x0000000000000000 64)
           (bv #x00000000 32)
           (:union: (bv FALSE 32) null)
           (bv #x00000000 32)
           (vector (bv #x00 8) (bv #x00 8))
           (:byte-array: (bv #x00000000 32))
           (vector
            (Signer
             (:union:
              (bv SIGNER_KEY_TYPE_HASH_X 32)
              (:byte-array:
               (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
             (bv #x00000000 32))
            (Signer
             (:union:
              (bv SIGNER_KEY_TYPE_HASH_X 32)
              (:byte-array:
               (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
             (bv #x00000000 32)))
           (:union:
            (bv 1 32)
            (AccountEntryExtensionV1
             (Liabilities (bv #x0000000000000000 64) (bv #x0000000000000000 64))
             (:union:
              (bv 2 32)
              (AccountEntryExtensionV2
               (bv #x00000000 32)
               (bv #x00000000 32)
               (vector (:union: (bv FALSE 32) null) (:union: (bv FALSE 32) null))
               (:union: (bv 0 32) null)))))))
         (:union:
          (bv 1 32)
          (LedgerEntryExtensionV1
           (:union: (bv FALSE 32) null)
           (:union: (bv 0 32) null))))
        (LedgerEntry
         (bv #x00000000 32)
         (:union:
          (bv ACCOUNT 32)
          (AccountEntry
           (:union:
            (bv PUBLIC_KEY_TYPE_ED25519 32)
            (:byte-array:
             (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
           (bv #x0000000000000000 64)
           (bv #x0000000000000000 64)
           (bv #x00000000 32)
           (:union: (bv FALSE 32) null)
           (bv #x00000000 32)
           (vector (bv #x00 8) (bv #x00 8))
           (:byte-array: (bv #x00000000 32))
           (vector
            (Signer
             (:union:
              (bv SIGNER_KEY_TYPE_HASH_X 32)
              (:byte-array:
               (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
             (bv #x00000000 32))
            (Signer
             (:union:
              (bv SIGNER_KEY_TYPE_HASH_X 32)
              (:byte-array:
               (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
             (bv #x00000000 32)))
           (:union:
            (bv 1 32)
            (AccountEntryExtensionV1
             (Liabilities (bv #x0000000000000000 64) (bv #x0000000000000000 64))
             (:union:
              (bv 2 32)
              (AccountEntryExtensionV2
               (bv #x00000000 32)
               (bv #x00000000 32)
               (vector (:union: (bv FALSE 32) null) (:union: (bv FALSE 32) null))
               (:union: (bv 0 32) null)))))))
         (:union:
          (bv 1 32)
          (LedgerEntryExtensionV1
           (:union: (bv FALSE 32) null)
           (:union: (bv 0 32) null)))))
       (vector
        (:union:
         (bv ENVELOPE_TYPE_TX 32)
         (TransactionV1Envelope
          (Transaction
           (:union:
            (bv KEY_TYPE_MUXED_ED25519 32)
            (MuxedAccount::med25519
             (bv #x0000000000000000 64)
             (:byte-array:
              (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))))
           (bv #x00000000 32)
           (bv #x0000000000000000 64)
           (:union: (bv FALSE 32) null)
           (:union:
            (bv MEMO_RETURN 32)
            (:byte-array:
             (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
           (vector
            (Operation
             (:union: (bv FALSE 32) null)
             (:union:
              (bv CREATE_ACCOUNT 32)
              (CreateAccountOp
               (:union:
                (bv PUBLIC_KEY_TYPE_ED25519 32)
                (:byte-array:
                 (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
               (bv #x0000000000000000 64)))))
           (:union: (bv 0 32) null))
          (vector
           (DecoratedSignature
            (:byte-array: (bv #x00000000 32))
            (vector (bv #x00 8) (bv #x00 8)))
           (DecoratedSignature
            (:byte-array: (bv #x00000000 32))
            (vector (bv #x00 8) (bv #x00 8))))))))))

(define example-3
  #'(define my-tx
      (Transaction
       (:union:
        (bv KEY_TYPE_MUXED_ED25519 32)
        (MuxedAccount::med25519
         (bv #x0000000000000000 64)
         (:byte-array:
          (bv
           29458565313587576488605812219632678825768279426807042594960959184304126581667
           256))))
       (bv #x00000000 32)
       (bv #x0000000000000000 64)
       (:union: (bv FALSE 32) null)
       (:union:
        (bv MEMO_RETURN 32)
        (:byte-array:
         (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
       (vector
        (Operation
         (:union: (bv FALSE 32) null)
         (:union:
          (bv CREATE_ACCOUNT 32)
          (CreateAccountOp
           (:union:
            (bv PUBLIC_KEY_TYPE_ED25519 32)
            (:byte-array:
             (bv
              29458565313587576488605812219632678825768279426807042594960959184304126581667
              256)))
           (bv #x0000000000000000 64)))))
       (:union: (bv 0 32) null))))