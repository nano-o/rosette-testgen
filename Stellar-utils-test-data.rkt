#lang rosette

(require 
  "Stellar-grammar-merge-sponsored-demo.rkt")
(provide (all-defined-out))

(define test-1
  (list
   (TestLedger
    (LedgerHeader
     (bv #x0000000e 32)
     (:byte-array:
      (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
     (StellarValue
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (bv #x0000000000000000 64)
      (vector
       (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
       (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
       (vector (bv #x00 8) (bv #x00 8) (bv #x00 8)))
      (:union:
       (bv #x00000001 32)
       (LedgerCloseValueSignature
        (:union:
         (bv #x00000000 32)
         (:byte-array:
          (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8)))))
     (:byte-array:
      (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
     (:byte-array:
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
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
     (:union:
      (bv #x00000001 32)
      (LedgerHeaderExtensionV1
       (bv #x00000000 32)
       (:union: (bv #x00000000 32) '()))))
    (vector
     (LedgerEntry
      (bv #x00000000 32)
      (:union:
       (bv #x00000000 32)
       (AccountEntry
        (:union:
         (bv #x00000000 32)
         (:byte-array:
          (bv #x3bf36f0de9880e80bfc23596344a501d0681f830c68054d23fd0bb4493f63fe9 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000001 64)
        (bv #x00000001 32)
        (:union: (bv #x00000000 32) '())
        (bv #x00000000 32)
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
        (:byte-array: (bv #x01000000 32))
        (vector
         (Signer
          (:union:
           (bv #x00000002 32)
           (:byte-array:
            (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
          (bv #x00000001 32)))
        (:union:
         (bv #x00000001 32)
         (AccountEntryExtensionV1
          (Liabilities
           (bv #x0000000000000000 64)
           (bv #x0000000000000000 64))
          (:union:
           (bv #x00000002 32)
           (AccountEntryExtensionV2
            (bv #x00000000 32)
            (bv #x00000000 32)
            (vector (:union: (bv #x00000000 32) '()))
            (:union: (bv #x00000000 32) '())))))))
      (:union:
       (bv #x00000001 32)
       (LedgerEntryExtensionV1
        (:union: (bv #x00000000 32) '())
        (:union: (bv #x00000000 32) '()))))
     (LedgerEntry
      (bv #x00000000 32)
      (:union:
       (bv #x00000000 32)
       (AccountEntry
        (:union:
         (bv #x00000000 32)
         (:byte-array:
          (bv #x2c7465d3990791c5f7425ec79de37b6db6aa5863537fc98d14d8a04e10adfd54 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000001 64)
        (bv #x00000001 32)
        (:union: (bv #x00000000 32) '())
        (bv #x00000000 32)
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
        (:byte-array: (bv #x01000000 32))
        (vector
         (Signer
          (:union:
           (bv #x00000002 32)
           (:byte-array:
            (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
          (bv #x00000001 32)))
        (:union:
         (bv #x00000001 32)
         (AccountEntryExtensionV1
          (Liabilities
           (bv #x0000000000000000 64)
           (bv #x0000000000000000 64))
          (:union:
           (bv #x00000002 32)
           (AccountEntryExtensionV2
            (bv #x00000000 32)
            (bv #x00000000 32)
            (vector (:union: (bv #x00000000 32) '()))
            (:union: (bv #x00000000 32) '())))))))
      (:union:
       (bv #x00000001 32)
       (LedgerEntryExtensionV1
        (:union: (bv #x00000000 32) '())
        (:union: (bv #x00000000 32) '()))))
     (LedgerEntry
      (bv #x00000000 32)
      (:union:
       (bv #x00000000 32)
       (AccountEntry
        (:union:
         (bv #x00000000 32)
         (:byte-array:
          (bv #x6cb316a14d65cedf9d804e9ee570b2492cf7b01532f487199d5eba313590f4c0 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000001 64)
        (bv #x00000001 32)
        (:union: (bv #x00000000 32) '())
        (bv #x00000000 32)
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
        (:byte-array: (bv #x01000000 32))
        (vector
         (Signer
          (:union:
           (bv #x00000002 32)
           (:byte-array:
            (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
          (bv #x00000001 32)))
        (:union:
         (bv #x00000001 32)
         (AccountEntryExtensionV1
          (Liabilities
           (bv #x0000000000000000 64)
           (bv #x0000000000000000 64))
          (:union:
           (bv #x00000002 32)
           (AccountEntryExtensionV2
            (bv #x00000000 32)
            (bv #x00000000 32)
            (vector (:union: (bv #x00000000 32) '()))
            (:union: (bv #x00000000 32) '())))))))
      (:union:
       (bv #x00000001 32)
       (LedgerEntryExtensionV1
        (:union:
         (bv #x00000001 32)
         (:union:
          (bv #x00000000 32)
          (:byte-array:
           (bv #x9a2d81f1e5c3ee13f700cd4ea52597d3ab62a98aa9fdcf009c2f6dae32798486 256))))
        (:union: (bv #x00000000 32) '()))))))
   (:union:
    (bv #x00000002 32)
    (TransactionV1Envelope
     (Transaction
      (:union:
       (bv #x00000000 32)
       (:byte-array:
        (bv #x3bf36f0de9880e80bfc23596344a501d0681f830c68054d23fd0bb4493f63fe9 256)))
      (bv #x00000064 32)
      (bv #x0000000000000002 64)
      (:union: (bv #x00000000 32) '())
      (:union:
       (bv #x00000004 32)
       (:byte-array:
        (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
      (vector
       (Operation
        (:union: (bv #x00000000 32) '())
        (:union:
         (bv #x00000008 32)
         (:union:
          (bv #x00000100 32)
          (MuxedAccount::med25519
           (bv #x0000000000000000 64)
           (:byte-array:
            (bv #x3bf36f0de9880e80bfc23596344a501d0681f830c68054d23fd0bb4493f63fe9 256)))))))
      (:union: (bv #x00000000 32) '()))
     '#()))))
(define test-2
  (list
   (TestLedger
    (LedgerHeader
     (bv #x0000000e 32)
     (:byte-array: (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
     (StellarValue
      (:byte-array: (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (bv #x0000000000000000 64)
      (vector
       (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
       (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
       (vector (bv #x00 8) (bv #x00 8) (bv #x00 8)))
      (:union:
       (bv #x00000001 32)
       (LedgerCloseValueSignature
        (:union:
         (bv #x00000000 32)
         (:byte-array: (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8)))))
     (:byte-array: (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
     (:byte-array: (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
     (bv #x00000001 32)
     (bv #x0000000000000000 64)
     (bv #x0000000000000000 64)
     (bv #x00000000 32)
     (bv #x0000000000000000 64)
     (bv #x00000064 32)
     (bv #x004c4b40 32)
     (bv #x00000000 32)
     (list
      (:byte-array: (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (:byte-array: (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (:byte-array: (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (:byte-array: (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
     (:union: (bv #x00000001 32) (LedgerHeaderExtensionV1 (bv #x00000000 32) (:union: (bv #x00000000 32) '()))))
    (vector
     (LedgerEntry
      (bv #x00000000 32)
      (:union:
       (bv #x00000000 32)
       (AccountEntry
        (:union:
         (bv #x00000000 32)
         (:byte-array: (bv #x6cb316a14d65cedf9d804e9ee570b2492cf7b01532f487199d5eba313590f4c0 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000001 64)
        (bv #x00000001 32)
        (:union: (bv #x00000000 32) '())
        (bv #x00000000 32)
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
        (:byte-array: (bv #x01000000 32))
        (vector
         (Signer
          (:union:
           (bv #x00000000 32)
           (:byte-array: (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
          (bv #x00000001 32)))
        (:union:
         (bv #x00000001 32)
         (AccountEntryExtensionV1
          (Liabilities (bv #x0000000000000000 64) (bv #x0000000000000000 64))
          (:union:
           (bv #x00000002 32)
           (AccountEntryExtensionV2
            (bv #x00000000 32)
            (bv #x00000002 32)
            (vector
             (:union:
              (bv #x00000001 32)
              (:union:
               (bv #x00000000 32)
               (:byte-array: (bv #x6cb316a14d65cedf9d804e9ee570b2492cf7b01532f487199d5eba313590f4c0 256)))))
            (:union: (bv #x00000000 32) '())))))))
      (:union:
       (bv #x00000001 32)
       (LedgerEntryExtensionV1
        (:union:
         (bv #x00000001 32)
         (:union:
          (bv #x00000000 32)
          (:byte-array: (bv #x9a2d81f1e5c3ee13f700cd4ea52597d3ab62a98aa9fdcf009c2f6dae32798486 256))))
        (:union: (bv #x00000000 32) '()))))
     (LedgerEntry
      (bv #x00000000 32)
      (:union:
       (bv #x00000000 32)
       (AccountEntry
        (:union:
         (bv #x00000000 32)
         (:byte-array: (bv #x3bf36f0de9880e80bfc23596344a501d0681f830c68054d23fd0bb4493f63fe9 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000001 64)
        (bv #x00000001 32)
        (:union: (bv #x00000000 32) '())
        (bv #x00000000 32)
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
        (:byte-array: (bv #x01000000 32))
        (vector
         (Signer
          (:union:
           (bv #x00000000 32)
           (:byte-array: (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
          (bv #x00000001 32)))
        (:union:
         (bv #x00000001 32)
         (AccountEntryExtensionV1
          (Liabilities (bv #x0000000000000000 64) (bv #x0000000000000000 64))
          (:union:
           (bv #x00000002 32)
           (AccountEntryExtensionV2
            (bv #x00000000 32)
            (bv #x00000002 32)
            (vector
             (:union:
              (bv #x00000001 32)
              (:union:
               (bv #x00000000 32)
               (:byte-array: (bv #x3bf36f0de9880e80bfc23596344a501d0681f830c68054d23fd0bb4493f63fe9 256)))))
            (:union: (bv #x00000000 32) '())))))))
      (:union:
       (bv #x00000001 32)
       (LedgerEntryExtensionV1
        (:union:
         (bv #x00000001 32)
         (:union:
          (bv #x00000000 32)
          (:byte-array: (bv #x6cb316a14d65cedf9d804e9ee570b2492cf7b01532f487199d5eba313590f4c0 256))))
        (:union: (bv #x00000000 32) '()))))
     (LedgerEntry
      (bv #x00000000 32)
      (:union:
       (bv #x00000000 32)
       (AccountEntry
        (:union:
         (bv #x00000000 32)
         (:byte-array: (bv #x9a2d81f1e5c3ee13f700cd4ea52597d3ab62a98aa9fdcf009c2f6dae32798486 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000001 64)
        (bv #x00000001 32)
        (:union: (bv #x00000000 32) '())
        (bv #x00000000 32)
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
        (:byte-array: (bv #x01000000 32))
        (vector
         (Signer
          (:union:
           (bv #x00000000 32)
           (:byte-array: (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
          (bv #x00000001 32)))
        (:union:
         (bv #x00000001 32)
         (AccountEntryExtensionV1
          (Liabilities (bv #x0000000000000000 64) (bv #x0000000000000000 64))
          (:union:
           (bv #x00000002 32)
           (AccountEntryExtensionV2
            (bv #x00000000 32)
            (bv #x00000001 32)
            (vector
             (:union:
              (bv #x00000001 32)
              (:union:
               (bv #x00000000 32)
               (:byte-array: (bv #x3bf36f0de9880e80bfc23596344a501d0681f830c68054d23fd0bb4493f63fe9 256)))))
            (:union: (bv #x00000000 32) '())))))))
      (:union:
       (bv #x00000001 32)
       (LedgerEntryExtensionV1
        (:union:
         (bv #x00000001 32)
         (:union:
          (bv #x00000000 32)
          (:byte-array: (bv #x2c7465d3990791c5f7425ec79de37b6db6aa5863537fc98d14d8a04e10adfd54 256))))
        (:union: (bv #x00000000 32) '()))))))
   (:union:
    (bv #x00000002 32)
    (TransactionV1Envelope
     (Transaction
      (:union:
       (bv #x00000000 32)
       (:byte-array: (bv #x6cb316a14d65cedf9d804e9ee570b2492cf7b01532f487199d5eba313590f4c0 256)))
      (bv #x00000064 32)
      (bv #x0000000000000002 64)
      (:union: (bv #x00000000 32) '())
      (:union:
       (bv #x00000004 32)
       (:byte-array: (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
      (vector
       (Operation
        (:union: (bv #x00000000 32) '())
        (:union:
         (bv #x00000008 32)
         (:union:
          (bv #x00000000 32)
          (:byte-array: (bv #x6cb316a14d65cedf9d804e9ee570b2492cf7b01532f487199d5eba313590f4c0 256))))))
      (:union: (bv #x00000000 32) '()))
     '#()))))
(define test-3
  (list
   (TestLedger
    (LedgerHeader
     (bv #x0000000e 32)
     (:byte-array:
      (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
     (StellarValue
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (bv #x0000000000000000 64)
      (vector
       (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
       (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
       (vector (bv #x00 8) (bv #x00 8) (bv #x00 8)))
      (:union:
       (bv #x00000001 32)
       (LedgerCloseValueSignature
        (:union:
         (bv #x00000000 32)
         (:byte-array:
          (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8)))))
     (:byte-array:
      (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
     (:byte-array:
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
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
     (:union:
      (bv #x00000001 32)
      (LedgerHeaderExtensionV1 (bv #x00000000 32) (:union: (bv #x00000000 32) '()))))
    (vector
     (LedgerEntry
      (bv #x00000000 32)
      (:union:
       (bv #x00000000 32)
       (AccountEntry
        (:union:
         (bv #x00000000 32)
         (:byte-array:
          (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000001 64)
        (bv #x00000001 32)
        (:union: (bv #x00000000 32) '())
        (bv #x00000000 32)
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
        (:byte-array: (bv #x01000000 32))
        (vector
         (Signer
          (:union:
           (bv #x00000000 32)
           (:byte-array:
            (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
          (bv #x00000001 32)))
        (:union:
         (bv #x00000001 32)
         (AccountEntryExtensionV1
          (Liabilities (bv #x0000000000000000 64) (bv #x0000000000000000 64))
          (:union:
           (bv #x00000002 32)
           (AccountEntryExtensionV2
            (bv #x00000000 32)
            (bv #x00000000 32)
            (vector
             (:union:
              (bv #x00000001 32)
              (:union:
               (bv #x00000000 32)
               (:byte-array:
                (bv #x9a2d81f1e5c3ee13f700cd4ea52597d3ab62a98aa9fdcf009c2f6dae32798486 256)))))
            (:union: (bv #x00000000 32) '())))))))
      (:union:
       (bv #x00000001 32)
       (LedgerEntryExtensionV1
        (:union: (bv #x00000000 32) '())
        (:union: (bv #x00000000 32) '()))))
     (LedgerEntry
      (bv #x00000000 32)
      (:union:
       (bv #x00000000 32)
       (AccountEntry
        (:union:
         (bv #x00000000 32)
         (:byte-array:
          (bv #x9a2d81f1e5c3ee13f700cd4ea52597d3ab62a98aa9fdcf009c2f6dae32798486 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000001 64)
        (bv #x00000001 32)
        (:union: (bv #x00000000 32) '())
        (bv #x00000000 32)
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
        (:byte-array: (bv #x01000000 32))
        (vector
         (Signer
          (:union:
           (bv #x00000000 32)
           (:byte-array:
            (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
          (bv #x00000001 32)))
        (:union:
         (bv #x00000001 32)
         (AccountEntryExtensionV1
          (Liabilities (bv #x0000000000000000 64) (bv #x0000000000000000 64))
          (:union:
           (bv #x00000002 32)
           (AccountEntryExtensionV2
            (bv #x00000001 32)
            (bv #x00000000 32)
            (vector (:union: (bv #x00000000 32) '()))
            (:union: (bv #x00000000 32) '())))))))
      (:union:
       (bv #x00000001 32)
       (LedgerEntryExtensionV1
        (:union:
         (bv #x00000001 32)
         (:union:
          (bv #x00000000 32)
          (:byte-array:
           (bv #x6cb316a14d65cedf9d804e9ee570b2492cf7b01532f487199d5eba313590f4c0 256))))
        (:union: (bv #x00000000 32) '()))))
     (LedgerEntry
      (bv #x00000000 32)
      (:union:
       (bv #x00000000 32)
       (AccountEntry
        (:union:
         (bv #x00000000 32)
         (:byte-array:
          (bv #x6cb316a14d65cedf9d804e9ee570b2492cf7b01532f487199d5eba313590f4c0 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000001 64)
        (bv #x00000001 32)
        (:union: (bv #x00000000 32) '())
        (bv #x00000000 32)
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
        (:byte-array: (bv #x01000000 32))
        (vector
         (Signer
          (:union:
           (bv #x00000000 32)
           (:byte-array:
            (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
          (bv #x00000001 32)))
        (:union:
         (bv #x00000001 32)
         (AccountEntryExtensionV1
          (Liabilities (bv #x0000000000000000 64) (bv #x0000000000000000 64))
          (:union:
           (bv #x00000002 32)
           (AccountEntryExtensionV2
            (bv #x00000001 32)
            (bv #x00000000 32)
            (vector
             (:union:
              (bv #x00000001 32)
              (:union:
               (bv #x00000000 32)
               (:byte-array:
                (bv #x9a2d81f1e5c3ee13f700cd4ea52597d3ab62a98aa9fdcf009c2f6dae32798486 256)))))
            (:union: (bv #x00000000 32) '())))))))
      (:union:
       (bv #x00000001 32)
       (LedgerEntryExtensionV1
        (:union:
         (bv #x00000001 32)
         (:union:
          (bv #x00000000 32)
          (:byte-array:
           (bv #x9a2d81f1e5c3ee13f700cd4ea52597d3ab62a98aa9fdcf009c2f6dae32798486 256))))
        (:union: (bv #x00000000 32) '()))))))
   (:union:
    (bv #x00000002 32)
    (TransactionV1Envelope
     (Transaction
      (:union:
       (bv #x00000000 32)
       (:byte-array:
        (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
      (bv #x00000064 32)
      (bv #x0000000000000002 64)
      (:union: (bv #x00000000 32) '())
      (:union:
       (bv #x00000004 32)
       (:byte-array:
        (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
      (vector
       (Operation
        (:union: (bv #x00000000 32) '())
        (:union:
         (bv #x00000008 32)
         (:union:
          (bv #x00000100 32)
          (MuxedAccount::med25519
           (bv #x0000000000000000 64)
           (:byte-array:
            (bv #x9a2d81f1e5c3ee13f700cd4ea52597d3ab62a98aa9fdcf009c2f6dae32798486 256)))))))
      (:union: (bv #x00000000 32) '()))
     '#()))))
(define test-4
  (list
   (TestLedger
    (LedgerHeader
     (bv #x0000000e 32)
     (:byte-array:
      (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
     (StellarValue
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (bv #x0000000000000000 64)
      (vector
       (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
       (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
       (vector (bv #x00 8) (bv #x00 8) (bv #x00 8)))
      (:union:
       (bv #x00000001 32)
       (LedgerCloseValueSignature
        (:union:
         (bv #x00000000 32)
         (:byte-array:
          (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8)))))
     (:byte-array:
      (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
     (:byte-array:
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
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
      (:byte-array:
       (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
     (:union:
      (bv #x00000001 32)
      (LedgerHeaderExtensionV1 (bv #x00000000 32) (:union: (bv #x00000000 32) '()))))
    (vector
     (LedgerEntry
      (bv #x00000000 32)
      (:union:
       (bv #x00000000 32)
       (AccountEntry
        (:union:
         (bv #x00000000 32)
         (:byte-array:
          (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000001 64)
        (bv #x00000001 32)
        (:union: (bv #x00000000 32) '())
        (bv #x00000000 32)
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
        (:byte-array: (bv #x01000000 32))
        (vector
         (Signer
          (:union:
           (bv #x00000000 32)
           (:byte-array:
            (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
          (bv #x00000001 32)))
        (:union:
         (bv #x00000001 32)
         (AccountEntryExtensionV1
          (Liabilities (bv #x0000000000000000 64) (bv #x0000000000000000 64))
          (:union:
           (bv #x00000002 32)
           (AccountEntryExtensionV2
            (bv #x00000000 32)
            (bv #x00000000 32)
            (vector (:union: (bv #x00000000 32) '()))
            (:union: (bv #x00000000 32) '())))))))
      (:union:
       (bv #x00000001 32)
       (LedgerEntryExtensionV1
        (:union: (bv #x00000000 32) '())
        (:union: (bv #x00000000 32) '()))))
     (LedgerEntry
      (bv #x00000000 32)
      (:union:
       (bv #x00000000 32)
       (AccountEntry
        (:union:
         (bv #x00000000 32)
         (:byte-array:
          (bv #x2c7465d3990791c5f7425ec79de37b6db6aa5863537fc98d14d8a04e10adfd54 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000001 64)
        (bv #x00000001 32)
        (:union: (bv #x00000000 32) '())
        (bv #x00000000 32)
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
        (:byte-array: (bv #x01000000 32))
        (vector
         (Signer
          (:union:
           (bv #x00000000 32)
           (:byte-array:
            (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
          (bv #x00000001 32)))
        (:union:
         (bv #x00000001 32)
         (AccountEntryExtensionV1
          (Liabilities (bv #x0000000000000000 64) (bv #x0000000000000000 64))
          (:union:
           (bv #x00000002 32)
           (AccountEntryExtensionV2
            (bv #x00000000 32)
            (bv #x00000000 32)
            (vector (:union: (bv #x00000000 32) '()))
            (:union: (bv #x00000000 32) '())))))))
      (:union:
       (bv #x00000001 32)
       (LedgerEntryExtensionV1
        (:union: (bv #x00000000 32) '())
        (:union: (bv #x00000000 32) '()))))
     (LedgerEntry
      (bv #x00000000 32)
      (:union:
       (bv #x00000000 32)
       (AccountEntry
        (:union:
         (bv #x00000000 32)
         (:byte-array:
          (bv #x6cb316a14d65cedf9d804e9ee570b2492cf7b01532f487199d5eba313590f4c0 256)))
        (bv #x0000000003938764 64)
        (bv #x0000000000000001 64)
        (bv #x00000001 32)
        (:union: (bv #x00000000 32) '())
        (bv #x00000000 32)
        (vector (bv #x00 8) (bv #x00 8) (bv #x00 8))
        (:byte-array: (bv #x01000000 32))
        (vector
         (Signer
          (:union:
           (bv #x00000000 32)
           (:byte-array:
            (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))
          (bv #x00000001 32)))
        (:union:
         (bv #x00000001 32)
         (AccountEntryExtensionV1
          (Liabilities (bv #x0000000000000000 64) (bv #x0000000000000000 64))
          (:union:
           (bv #x00000002 32)
           (AccountEntryExtensionV2
            (bv #x00000001 32)
            (bv #x00000000 32)
            (vector (:union: (bv #x00000000 32) '()))
            (:union: (bv #x00000000 32) '())))))))
      (:union:
       (bv #x00000001 32)
       (LedgerEntryExtensionV1
        (:union:
         (bv #x00000001 32)
         (:union:
          (bv #x00000000 32)
          (:byte-array:
           (bv #x2c7465d3990791c5f7425ec79de37b6db6aa5863537fc98d14d8a04e10adfd54 256))))
        (:union: (bv #x00000000 32) '()))))))
   (:union:
    (bv #x00000002 32)
    (TransactionV1Envelope
     (Transaction
      (:union:
       (bv #x00000000 32)
       (:byte-array:
        (bv #x6cb316a14d65cedf9d804e9ee570b2492cf7b01532f487199d5eba313590f4c0 256)))
      (bv #x00000064 32)
      (bv #x0000000000000002 64)
      (:union: (bv #x00000000 32) '())
      (:union:
       (bv #x00000004 32)
       (:byte-array:
        (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
      (vector
       (Operation
        (:union: (bv #x00000000 32) '())
        (:union:
         (bv #x00000008 32)
         (:union:
          (bv #x00000100 32)
          (MuxedAccount::med25519
           (bv #x0000000000000000 64)
           (:byte-array:
            (bv #x01e79f0a26dbcc02c6d420c9f2c680c8a7d6abcecec9f56505049e0b0f7f0ae5 256)))))))
      (:union: (bv #x00000000 32) '()))
     '#()))))
(define tests (list test-1 test-2 test-3 test-4))