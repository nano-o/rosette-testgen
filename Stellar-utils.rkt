#lang rosette

(require
  "Stellar-grammar-merge-sponsored-demo.rkt"
  rosette/lib/destruct
  racket/trace)

; TODO couldn't we just generate the grammar here?
; TODO in the absence of type checking, we really need tests here.

(provide (all-defined-out) (all-from-out "Stellar-grammar-merge-sponsored-demo.rkt"))

; 10 millon stroops = 1 XLM
(define (xlm->stroop x)
  (* x 10000000))

(define (to-uint64 bitvect)
  (zero-extend bitvect (bitvector 64)))

(define (account-ed25519/bv muxed-account)
  (destruct muxed-account
    [(:union: tag v)
     (cond
       [(bveq tag (bv KEY_TYPE_ED25519 32)) (:byte-array:-value v)]
       [(bveq tag (bv KEY_TYPE_MUXED_ED25519 32))
        ; in this case, extract the ed25519 key
        (destruct v
          [(MuxedAccount::med25519 _ k) (:byte-array:-value k)])])]))
  
(define (source-account/bv tx-envelope)
  ; returns the ed25519 public key of this account (as a bitvector)
  (destruct tx-envelope
    [(:union: tag v)
     (cond
       [(bveq tag (bv ENVELOPE_TYPE_TX 32))
        (destruct v
          [(TransactionV1Envelope tx _)
           (destruct tx
             [(Transaction src _ _ _ _ _ _)
              (account-ed25519/bv src)])])]
       [else (assume #f)])])) ; only TransactionV1Envelope supported

(define (entry-type e)
  (:union:-tag (LedgerEntry-data e)))

(define (account-entry? e) ; is this ledger entry an account entry?
  (bveq (:union:-tag (LedgerEntry-data e)) (bv ACCOUNT 32)))

; Threshold are an opaque array; because we chose to use flat bitvectors for, it's a bit harder to access the components
(define (thresholds-ref t n) ; n between 0 and 3
  (let ([b (:byte-array:-value t)]
        ; total size is 32 bits
        [i (- 31 (* n 8))]
        [j (- 32 (* (+ n 1) 8))])
    (extract i j b)))

(define (master-key-threshold account-entry) ; get the master key threshold
  (thresholds-ref (AccountEntry-thresholds account-entry) 0))

(define (min-balance/32 lh num-subentries)
  ; for now: 2 times the base reserve
  ; baseReserve is a uint32
  ; we return a uint64 result
  (bvmul (LedgerHeader-baseReserve lh) (bvadd (bv 2 32) (bv num-subentries 32))))

(define (account-entry-for? ledger-entry account-id/bv)
  ; true iff the ledger entry is an account entry with the given account ID.
  (let ([type (:union:-tag (LedgerEntry-data ledger-entry))])
    (and (bveq type (bv ACCOUNT 32))
         (let* ([account-entry (:union:-value (LedgerEntry-data ledger-entry))]
                [entry-pubkey (AccountEntry-accountID account-entry)] ; that's a PublicKey
                [entry-id/bv (:byte-array:-value (:union:-value entry-pubkey))])
           (bveq entry-id/bv account-id/bv)))))

(define (account-exists? ledger-entries account-id/bv256)
  ; account-id is a uint256
  ; ledger-entries is a list of entries
  (and
   (not (null? ledger-entries))
   (or
    (account-entry-for? (car ledger-entries) account-id/bv256)
    (account-exists? (cdr ledger-entries) account-id/bv256))))

(define (duplicate-accounts? ledger-entries) ; n^2 runtime
  (if (null? ledger-entries)
      #f
      (or
       (let* ([ledger-entry (car ledger-entries)]
              [type (:union:-tag (LedgerEntry-data ledger-entry))])
         (and
          (bveq type (bv ACCOUNT 32))
          (let* ([account-entry (:union:-value (LedgerEntry-data ledger-entry))]
                 [entry-pubkey (AccountEntry-accountID account-entry)]
                 [entry-id/bv (:byte-array:-value (:union:-value entry-pubkey))])
            (account-exists? (cdr ledger-entries)  entry-id/bv))))
       (duplicate-accounts? (cdr ledger-entries)))))

(define (PublicKey-equal? k1 k2)
  (bveq
   (:byte-array:-value (:union:-value k1))
   (:byte-array:-value (:union:-value k2))))

(define (sponsors-entry? ledger-entry account-id/pubkey)
  (let ([has-ext-v1?
          (bveq
           (:union:-tag (LedgerEntry-ext ledger-entry))
           (bv 1 32))])
    (if has-ext-v1?
        (let* ([ext-v1 (:union:-value (LedgerEntry-ext ledger-entry))]
               [sponsorship-descriptor (LedgerEntryExtensionV1-sponsoringID ext-v1)]
               [is-sponsored? (bveq (:union:-tag sponsorship-descriptor) (bv 1 32))])
          (if is-sponsored?
              (PublicKey-equal? account-id/pubkey (:union:-value sponsorship-descriptor))
              #f))
        #f)))

(define (num-signers-sponsored-by ids sponsor-id/pubkey)
  (if (null? ids)
      (bv 0 32)
      (let* ([s (car ids)]
             [sponsoring?
              (and (bveq (:union:-tag s) (bv 1 32))
                   (PublicKey-equal? sponsor-id/pubkey (:union:-value s)))]
             [rest (num-signers-sponsored-by (cdr ids) sponsor-id/pubkey)])
        (if sponsoring? (bvadd (bv 1 32) rest) rest))))

(define (signer-sponsoring-ids account-entry) ; assuming is has a v2 extension
  (let* ([ext-v1 (:union:-value (AccountEntry-ext account-entry))]
         [ext-v2 (:union:-value (AccountEntryExtensionV1-ext ext-v1))])
  (AccountEntryExtensionV2-signerSponsoringIDs ext-v2)))

(define (account-has-v2? account-entry)
  (bveq (:union:-tag (AccountEntry-ext account-entry)) (bv 1 32))
  (let ([ext-v1 (:union:-value (AccountEntry-ext account-entry))])
    (bveq (:union:-tag (AccountEntryExtensionV1-ext ext-v1)) (bv 2 32))))

(define (num-sponsoring ledger-entries sponsor-id/pubkey)
  ; how many entries and sub-entries is sponsor-id sponsoring?
  (if (null? ledger-entries)
      (bv 0 32)
      (let* ([e (car ledger-entries)]
             [rest (num-sponsoring (cdr ledger-entries) sponsor-id/pubkey)]
             [account-entry (:union:-value (LedgerEntry-data e))]
             [n-in-this-entry
                (if (and
                     (account-entry? e)
                     (account-has-v2? account-entry))
                    (let* ([ids (vector->list (signer-sponsoring-ids account-entry))]
                           [n-sponsored-signers (num-signers-sponsored-by ids sponsor-id/pubkey)])
                      (if (sponsors-entry? e sponsor-id/pubkey)
                          (bvadd (bv 1 32) n-sponsored-signers)
                          n-sponsored-signers))
                    (bv 0 32))])
        (bvadd n-in-this-entry rest))))

(define (num-non-null union-list)
  (if (null? union-list)
      (bv 0 32)
      (bvadd
       (if (bveq (:union:-tag (car union-list)) (bv 1 32))
           (bv 1 32)
           (bv 0 32))
       (num-non-null (cdr union-list)))))
  
(define (num-sponsored-signers account-entry)
  (if (account-has-v2? account-entry)
      (let* ([ids (vector->list (signer-sponsoring-ids account-entry))])
        (num-non-null ids))
      (bv 0 32)))

(define (num-sponsored ledger-entry)
  (let ([entry-sponsor ; 0 or 1
         (if
          (and
           (bveq (:union:-tag (LedgerEntry-ext ledger-entry)) (bv 1 32)) ; has a v1 extension
           (let ([ext-v1 (:union:-value (LedgerEntry-ext ledger-entry))])
             (bveq (:union:-tag (LedgerEntryExtensionV1-sponsoringID ext-v1)) (bv 1 32))))
         (bv 1 32)
         (bv 0 32))]
        [sponsored-signers
         (if (account-entry? ledger-entry)
             (num-sponsored-signers (:union:-value (LedgerEntry-data ledger-entry)))
             (bv 0 32))])
    (bvadd entry-sponsor sponsored-signers)))

(require racket/enter)
(define (enter-test)
  (enter! (submod "./Stellar-utils.rkt" test)))

(module+ test
  (require rackunit)
  (define (compute-num-sponsoring t)
    (let ([ledger-entries (vector->list (TestLedger-ledgerEntries (car t)))])
      (for/list ([e ledger-entries]
                 #:when (bveq (:union:-tag (LedgerEntry-data e)) (bv ACCOUNT 32)))
        (let ([account-id/pubkey (AccountEntry-accountID (:union:-value (LedgerEntry-data e)))])
          (num-sponsoring ledger-entries account-id/pubkey)))))
  (define (compute-num-sponsored t)
    (let ([ledger-entries (vector->list (TestLedger-ledgerEntries (car t)))])
      (for/list ([e ledger-entries])
        (num-sponsored e))))
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
  (check-equal?
   (compute-num-sponsoring test-1)
   (list (bv #x00000000 32) (bv #x00000000 32) (bv #x00000000 32)))
  (check-equal?
   (compute-num-sponsoring test-2)
   (list (bv #x00000002 32) (bv #x00000002 32) (bv #x00000001 32)))
  (check-equal?
   (compute-num-sponsored test-1)
   (list (bv #x00000000 32) (bv #x00000000 32) (bv #x00000001 32)))
  (check-equal?
   (compute-num-sponsored test-2)
   (list (bv #x00000002 32) (bv #x00000002 32) (bv #x00000002 32)))
  (check-equal?
   (compute-num-sponsored test-3)
   (list (bv #x00000001 32) (bv #x00000001 32) (bv #x00000002 32)))(check-equal?
   (compute-num-sponsoring test-4)
   (list (bv #x00000000 32) (bv #x00000001 32) (bv #x00000000 32))))