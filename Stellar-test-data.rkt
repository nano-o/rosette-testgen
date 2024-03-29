#lang racket

(provide (all-defined-out))
(require
  (only-in rosette bv)
  "Stellar.rkt"
  rackunit)

(define my-ledger-header
 (LedgerHeader
     (bv #x0000000e 32)
     (-byte-array
      (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
     (StellarValue
      (-byte-array
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (bv #x0000000000000000 64)
      (vector)
      (StellarValue::ext
       (bv #x00000000 32)
       null))
     (-byte-array
      (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
     (-byte-array
      (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
     (bv #x00000001 32)
     (bv #x0000000000000000 64)
     (bv #x0000000000000000 64)
     (bv #x00000000 32)
     (bv #x0000000000000000 64)
     (bv #x00000064 32)
     (bv #x004c4b40 32)
     (bv #x00000000 32)
     (list
      (-byte-array
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (-byte-array
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (-byte-array
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (-byte-array
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
     (LedgerHeader::ext
      (bv #x00000000 32)
      null)))

(check-true (LedgerHeader-valid? my-ledger-header))

(define my-account
  (LedgerEntry
    (bv 0 32)
    (LedgerEntry::data
      (bv ACCOUNT 32)
      (AccountEntry
        (PublicKey
          (bv #x00000000 32)
          (-byte-array
            (bv 0 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000000 64)
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
    (LedgerEntry::ext (bv 0 32) null)))

(check-true (LedgerEntry-valid? my-account))

(define my-ledger
  (Ledger my-ledger-header (vector my-account)))
(check-true (Ledger-valid? my-ledger))

(define my-tx-envelope
  (TransactionEnvelope
    (bv ENVELOPE_TYPE_TX 32)
    (TransactionV1Envelope
      (Transaction
        (MuxedAccount
          (bv KEY_TYPE_MUXED_ED25519 32)
          (MuxedAccount::med25519
            (bv #x0000000000000000 64)
            (-byte-array (bv 0 256))))
        (bv 100 32)
        (bv #x0000000000000001 64)
        (-optional (bv FALSE 32) null)
        (Memo
          (bv MEMO_RETURN 32)
          (-byte-array (bv 0 256)))
        (vector
          (Operation
            (-optional (bv FALSE 32) null)
            (Operation::body
              (bv CREATE_ACCOUNT 32)
              (CreateAccountOp
                (PublicKey
                  (bv PUBLIC_KEY_TYPE_ED25519 32)
                  (-byte-array
                    (bv
                      29458565313587576488605812219632678825768279426807042594960959184304126581667
                      256)))
                (bv #x0000000000000000 64)))))
        (Transaction::ext (bv 0 32) null))
      (vector))))

(check-true (TransactionEnvelope-valid? my-tx-envelope))
