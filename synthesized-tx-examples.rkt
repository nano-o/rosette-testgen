#lang rosette

(require "Stellar-grammar.rkt")

(provide example-1)

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