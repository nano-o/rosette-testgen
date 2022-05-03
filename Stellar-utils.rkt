#lang rosette

(require
  "Stellar-grammar-merge-sponsored-demo.rkt"
  rosette/lib/destruct
  racket/trace)

; TODO couldn't we just generate the grammar here?
; TODO use a bv256 to identify accounts instead of passing sometimes a pubkey, sometimes an account entry, etc.

(provide (all-defined-out) (all-from-out "Stellar-grammar-merge-sponsored-demo.rkt"))

; 10 millon stroops = 1 XLM
(define (xlm->stroop x)
  (* x 10000000))

(define (bv->bv64 bitvect)
  (zero-extend bitvect (bitvector 64)))

(define (opt-non-null? x/optional)
  (bveq (:union:-tag x/optional) (bv 1 32)))
(define (opt-null? x/optional)
  (bveq (:union:-tag x/optional) (bv 0 32)))

(define (muxed-account->bv256 muxed-account)
  (destruct muxed-account
    [(:union: tag v)
     (if (bveq tag (bv KEY_TYPE_ED25519 32))
         (:byte-array:-value v)
         (if (bveq tag (bv KEY_TYPE_MUXED_ED25519 32))
             ; in this case, extract the ed25519 key
             (destruct v
               [(MuxedAccount::med25519 _ k) (:byte-array:-value k)])
             (assume #f)))])) ; unreachable

(define (source-account/bv256 tx-envelope)
  ; returns the ed25519 public key of this account (as a bitvector)
  (destruct tx-envelope
    [(:union: tag v)
     (if (bveq tag (bv ENVELOPE_TYPE_TX 32))
         (destruct v
           [(TransactionV1Envelope tx _)
            (destruct tx
                      [(Transaction src _ _ _ _ _ _)
                       (muxed-account->bv256 src)])])
         (assume #f))])) ; TODO only TransactionV1Envelope supported for now

(define (entry-type e)
  (:union:-tag (LedgerEntry-data e)))

(define (account-entry? e) ; is this ledger entry an account entry?
  (bveq (entry-type e) (bv ACCOUNT 32)))

(define (find-account-entry account-id/bv256 ledger-entries)
  ; returns false if not found
  (findf (λ (e) (account-entry-for? e account-id/bv256)) ledger-entries))

; Thresholds are an opaque array; because we chose to use flat bitvectors for, it's a bit harder to access the components
(define (thresholds-ref t n) ; n between 0 and 3
  (let ([b (:byte-array:-value t)]
        ; total size is 32 bits
        [i (- 31 (* n 8))]
        [j (- 32 (* (+ n 1) 8))])
    (extract i j b)))

(define (master-key-threshold account-entry) ; get the master key threshold
  (thresholds-ref (AccountEntry-thresholds account-entry) 0))

(define (account-entry-for? ledger-entry account-id/bv256)
  ; true iff the ledger entry is an account entry with the given account ID.
  (and (account-entry? ledger-entry)
       (let* ([account-entry (:union:-value (LedgerEntry-data ledger-entry))]
              [entry-id/bv256 (pubkey->bv256 (AccountEntry-accountID account-entry))])
         (bveq entry-id/bv256 account-id/bv256))))

(define (account-exists? account-id/bv256 ledger-entries)
  (let ([proc (λ (e) (account-entry-for? e account-id/bv256))])
    (ormap proc ledger-entries)))

(define (duplicate-accounts? ledger-entries)
  (if (empty? ledger-entries)
      #f
      (or
       ; the current entry appears in the tail of the list:
       (let* ([ledger-entry (car ledger-entries)])
         (and
          (account-entry? ledger-entry)
          (let* ([account-entry (:union:-value (LedgerEntry-data ledger-entry))]
                 [entry-id/bv256 (pubkey->bv256 (AccountEntry-accountID account-entry))])
            (account-exists? entry-id/bv256 (cdr ledger-entries)))))
       ; there are duplicates in the tail of the list:
       (duplicate-accounts? (cdr ledger-entries)))))

(define (PublicKey-equal? k1 k2)
  (bveq
   (:byte-array:-value (:union:-value k1))
   (:byte-array:-value (:union:-value k2))))

(define (ledger-entry-has-v1-ext? ledger-entry)
  (bveq
   (:union:-tag (LedgerEntry-ext ledger-entry))
   (bv 1 32)))

(define (pubkey->bv256 pubkey)
  (:byte-array:-value (:union:-value pubkey)))

(define (sponsors-entry? ledger-entry account-id/bv256)
  (and
   (ledger-entry-has-v1-ext? ledger-entry)
   (let* ([v1-ext (:union:-value (LedgerEntry-ext ledger-entry))]
          [sponsorship-descriptor (LedgerEntryExtensionV1-sponsoringID v1-ext)]
          [is-sponsored? (opt-non-null? sponsorship-descriptor)])
     (and
      is-sponsored?
      (let ([sponsor/bv256 (pubkey->bv256 (:union:-value sponsorship-descriptor))])
       (bveq account-id/bv256 sponsor/bv256))))))

(define (num-signers-sponsored-by sponsor-ids sponsor-id/bv256)
  ; sponsor-ids is a list of optional pub-keys
  (let ([proc
         (λ (s count)
           (let ([sponsoring?
                  (and (opt-non-null? s)
                       (bveq sponsor-id/bv256 (pubkey->bv256 (:union:-value s))))])
             (if sponsoring?
                 (bvadd (bv 1 32) count)
                 count)))])
    (foldl proc (bv 0 32) sponsor-ids)))

(define (account-entry-has-v2-ext? account-entry)
  (bveq (:union:-tag (AccountEntry-ext account-entry)) (bv 1 32))
  (let ([v1-ext (:union:-value (AccountEntry-ext account-entry))])
    (bveq (:union:-tag (AccountEntryExtensionV1-ext v1-ext)) (bv 2 32))))

(define (signer-sponsoring-ids account-entry)
  (if (account-entry-has-v2-ext? account-entry)
    (let* ([v1-ext (:union:-value (AccountEntry-ext account-entry))]
           [v2-ext (:union:-value (AccountEntryExtensionV1-ext v1-ext))])
      (vector->list (AccountEntryExtensionV2-signerSponsoringIDs v2-ext)))
    null))

(define (num-sponsoring-in-this-entry ledger-entry account-id/bv256)
  ; counts how many subentries of ledger-entry are sponsored by account-id
  (if (ledger-entry-has-v1-ext? ledger-entry)
    (let* ([v1-ext (:union:-value (LedgerEntry-ext ledger-entry))]
           [sponsoring-entry?
             (and
               (bveq (:union:-tag (LedgerEntryExtensionV1-sponsoringID v1-ext)) (bv 1 32))
               (bveq
                 (pubkey->bv256 (:union:-value (LedgerEntryExtensionV1-sponsoringID v1-ext)))
                 account-id/bv256))]
           [num-signers-sponsored
             (if (account-entry? ledger-entry)
               (let* ([account-entry (:union:-value (LedgerEntry-data ledger-entry))]
                      [sponsors (signer-sponsoring-ids account-entry)])
                (num-signers-sponsored-by sponsors account-id/bv256))
               (bv 0 32))])
      (if sponsoring-entry?
        (bvadd (bv 1 32) num-signers-sponsored)
        num-signers-sponsored))
    (bv 0 32)))

(define (num-sponsoring sponsor-id/bv256 ledger-entries)
  ; how many entries and sub-entries is sponsor-id sponsoring?
  ; we iterate over ledger entries and count
  (let ([proc
         (λ (e count)
           (let ([sponsors-entry?/bv32
                  (if (sponsors-entry? e sponsor-id/bv256)
                      (bv 1 32)
                      (bv 0 32))]
                 [sponsored-signers
                  (if (account-entry? e)
                      (let ([account-entry (:union:-value (LedgerEntry-data e))])
                        (if (account-entry-has-v2-ext? account-entry)
                            (let ([ids (signer-sponsoring-ids account-entry)])
                              (num-signers-sponsored-by ids sponsor-id/bv256))
                            (bv 0 32)))
                      (bv 0 32))])
             (bvadd count (bvadd sponsors-entry?/bv32 sponsored-signers))))])
    (foldl proc (bv 0 32) ledger-entries)))

(define (non-null-count l)
  ; NOTE using count would cause integer<->bv conversions, which is bad for solver performance
  ; TODO define count-bv...
  (let ([proc
         (λ (x/optional count)
           (if (opt-non-null? x/optional)
               (bvadd count (bv 1 32))
               count))])
    (foldl proc (bv 0 32) l)))

(define (num-sponsored-signers account-entry)
  (if (account-entry-has-v2-ext? account-entry)
      (let* ([sponsors (signer-sponsoring-ids account-entry)])
        (non-null-count sponsors))
      (bv 0 32)))

(define (num-sponsored ledger-entry)
  ; computes the numbers of sponsors that this ledger-entry has
  (let ([entry-sponsor ; 1 if entry is sponsored, 0 otherwise
         (if
          (and
           (ledger-entry-has-v1-ext? ledger-entry)
           (let ([v1-ext (:union:-value (LedgerEntry-ext ledger-entry))])
             (bveq (:union:-tag (LedgerEntryExtensionV1-sponsoringID v1-ext)) (bv 1 32))))
         (bv 1 32)
         (bv 0 32))]
        [sponsored-signers ; number of signers of this entry that are sponsored
         (if (account-entry? ledger-entry)
             (num-sponsored-signers (:union:-value (LedgerEntry-data ledger-entry)))
             (bv 0 32))])
    (bvadd entry-sponsor sponsored-signers)))

(define (signers-valid? account-entry ledger-entries)
  (andmap
   (λ (signer)
     (and
      ; TODO for now we require a key type of SIGNER_KEY_TYPE_ED25519:
      (bveq (:union:-tag (Signer-key signer)) (bv SIGNER_KEY_TYPE_ED25519 32))
      ; signer exists:
      (account-exists? (:byte-array:-value (:union:-value (Signer-key signer))) ledger-entries)
      ; signer cannot be self
      (not (PublicKey-equal? (Signer-key signer) (AccountEntry-accountID account-entry)))
      ; non-zero weight:
      (not (bveq (Signer-weight signer) (bv 0 32)))))
   (vector->list (AccountEntry-signers account-entry))))

(define (num-subentries-valid? account-entry ledger-entries)
  ; TODO count other types of subentries
  (let ([num-signers/bv32
         (vector-length-bv (AccountEntry-signers account-entry) (bitvector 32))])
    (bveq (AccountEntry-numSubEntries account-entry) num-signers/bv32)))

(define (sponsoring-data-valid? ledger-entry ledger-entries)
  (and
    (or
      (not (ledger-entry-has-v1-ext? ledger-entry))
      (let* ([v1-ext (:union:-value (LedgerEntry-ext ledger-entry))]
             [sponsored?
               (bveq (:union:-tag (LedgerEntryExtensionV1-sponsoringID v1-ext)) (bv 1 32))])
        (or (not sponsored?)
            (let ([sponsor
                    (:union:-value (LedgerEntryExtensionV1-sponsoringID v1-ext))])
              ; the entry's sponsor must exist:
              (account-exists? (:byte-array:-value (:union:-value sponsor)) ledger-entries)))))
    (or (not (account-entry? ledger-entry)) ; if it's an account entry:
        (let ([account-entry (:union:-value (LedgerEntry-data ledger-entry))])
          (or (not (account-entry-has-v2-ext? account-entry))
              (let* ([ext-v1 (:union:-value (AccountEntry-ext account-entry))]
                     [ext-v2 (:union:-value (AccountEntryExtensionV1-ext ext-v1))]
                     [sponsors (AccountEntryExtensionV2-signerSponsoringIDs ext-v2)]
                     [signers (AccountEntry-signers account-entry)]
                     [account-id/pubkey (AccountEntry-accountID account-entry)])
                (and
                  ; an account cannot sponsor itself:
                  (not (sponsors-entry? ledger-entry (pubkey->bv256 account-id/pubkey)))
                  ; numSponsored must be correct:
                  (bveq (num-sponsored ledger-entry) (AccountEntryExtensionV2-numSponsored ext-v2))
                  ; numSponsoring must be correct:
                  (bveq (num-sponsoring (pubkey->bv256 account-id/pubkey) ledger-entries) (AccountEntryExtensionV2-numSponsoring ext-v2))
                  ; we have as many sponsorshipDescriptors as signers:
                  (bveq (vector-length-bv signers (bitvector 32)) (vector-length-bv sponsors (bitvector 32)))
                  ; TODO can the sponsor of a signer be the signer itself?
                  ; signer sponsors must exist and the account cannot sponsor itself:
                  (andmap
                    (λ (sponsor)
                      (or
                        (opt-null? sponsor)
                        (let ([sponsor/bv256 (:byte-array:-value (:union:-value (:union:-value sponsor)))])
                          (and
                            (account-exists? sponsor/bv256 ledger-entries)
                            (not (PublicKey-equal? (:union:-value sponsor) account-id/pubkey))))))
                    (vector->list sponsors)))))))))


(define (num-subentries account-entry ledger-entries)
  ; TODO: count other types of subentries
  (let ([num-signers/bv32
          (vector-length-bv (AccountEntry-signers account-entry) (bitvector 32))])
    num-signers/bv32))

(define (min-balance/bv32 account-id/bv256 ledger-entries ledger-header)
  (let* ([ledger-entry (find-account-entry account-id/bv256 ledger-entries)]
         ; TODO what if it's not found?
         [base-reserve (LedgerHeader-baseReserve ledger-header)]
         [account-entry (:union:-value (LedgerEntry-data ledger-entry))]
         [num-subentries (num-subentries account-entry ledger-entries)]
         [num-sponsoring (num-sponsoring account-id/bv256 ledger-entries)]
         [num-sponsored (num-sponsored ledger-entry)])
    (bvmul
      base-reserve
      (bvsub
        (bvadd
          (bv 2 32)
          (bvadd
            num-subentries
            num-sponsoring
            ))
        num-sponsored))))

(define (entry-valid? ledger-entry ledger-entries ledger-header)
 ; TODO: test
  (and
    (sponsoring-data-valid? ledger-entry ledger-entries)
    (or
     (not (account-entry? ledger-entry))
     (let* ([account-entry (:union:-value (LedgerEntry-data ledger-entry))]
            [account-id/bv256 (pubkey->bv256 (AccountEntry-accountID account-entry))])
       (signers-valid? account-entry ledger-entries)
       (bvuge
         (AccountEntry-balance account-entry)
         (bv->bv64 (min-balance/bv32 account-id/bv256 ledger-entries ledger-header)))
       (num-subentries-valid? account-entry ledger-entries)))))

; tests:

(require racket/enter)
(define (enter-test)
  (enter! (submod "./Stellar-utils.rkt" test)))

(module+ test
  (require
    rackunit
    "Stellar-utils-test-data.rkt")

  ; first we define a few iteration primitives:

  (define (for-each-ledger-entry proc t)
    (let ([ledger-entries (vector->list (TestLedger-ledgerEntries (car t)))]
          [ledger-header (TestLedger-ledgerHeader (car t))])
      (for ([e ledger-entries])
        (proc e ledger-entries ledger-header))))

  (define (for-each-entry/list proc t)
    (let ([ledger-entries (vector->list (TestLedger-ledgerEntries (car t)))]
          [ledger-header (TestLedger-ledgerHeader (car t))])
      (for/list ([e ledger-entries])
        (proc e ledger-entries ledger-header))))

  (define (for-each-account-entry proc t)
    (let ([ledger-entries (vector->list (TestLedger-ledgerEntries (car t)))]
          [ledger-header (TestLedger-ledgerHeader (car t))])
      (for ([e ledger-entries]
            #:when (bveq (:union:-tag (LedgerEntry-data e)) (bv ACCOUNT 32)))
        (proc (:union:-value (LedgerEntry-data e)) ledger-entries ledger-header))))

  (define (for-each-account-entry/list proc t)
    (let ([ledger-entries (vector->list (TestLedger-ledgerEntries (car t)))]
          [ledger-header (TestLedger-ledgerHeader (car t))])
      (for/list ([e ledger-entries]
                 #:when (bveq (:union:-tag (LedgerEntry-data e)) (bv ACCOUNT 32)))
        (proc (:union:-value (LedgerEntry-data e)) ledger-entries ledger-header))))

  (define (num-sponsoring/list t)
    (for-each-account-entry/list
     (λ (account-entry ledger-entries ledger-header)
       (let ([account-id/pubkey (AccountEntry-accountID account-entry)])
          (num-sponsoring (pubkey->bv256 account-id/pubkey) ledger-entries)))
     t))

  (define (num-sponsored/list t)
    (for-each-entry/list
     (λ (e es _)
       (num-sponsored e))
     t))

  (define (check-signers-valid t)
    (for-each-account-entry
     (λ (account-entry ledger-entries ledger-header)
       (check-not-exn
        (λ () (signers-valid? account-entry ledger-entries))))
     t))

  (define (run-num-subentries-valid t)
    (for-each-account-entry
     (λ (account-entry ledger-entries ledger-header)
       (check-not-exn
        (λ () (num-subentries-valid? account-entry ledger-entries))))
    t))

  (check-equal?
   (num-sponsoring/list test-1)
   (list (bv #x00000000 32) (bv #x00000000 32) (bv #x00000000 32)))
  (check-equal?
   (num-sponsoring/list test-2)
   (list (bv #x00000002 32) (bv #x00000002 32) (bv #x00000001 32)))
  (check-equal?
   (num-sponsoring/list test-4)
   (list (bv #x00000000 32) (bv #x00000001 32) (bv #x00000000 32)))
  (check-equal?
   (num-sponsored/list test-1)
   (list (bv #x00000000 32) (bv #x00000000 32) (bv #x00000001 32)))
  (check-equal?
   (num-sponsored/list test-2)
   (list (bv #x00000002 32) (bv #x00000002 32) (bv #x00000002 32)))
  (check-equal?
   (num-sponsored/list test-3)
   (list (bv #x00000001 32) (bv #x00000001 32) (bv #x00000002 32)))

  (define (for-each-test proc)
    (for-each (λ (t) (proc t)) tests))

  (for-each-test check-signers-valid)
  (for-each-test run-num-subentries-valid)
  (for-each-test
   ((curry for-each-ledger-entry)
    (λ (ledger-entry ledger-entries _)
      (check-not-exn
       (λ ()
         (sponsoring-data-valid? ledger-entry ledger-entries))))))
  (for-each-test
   ((curry for-each-ledger-entry)
    (λ (ledger-entry ledger-entries ledger-header)
      (check-not-exn
       (λ ()
         (entry-valid? ledger-entry ledger-entries ledger-header))))))
  (for-each-test
   ((curry for-each-account-entry)
    (λ (account-entry ledger-entries ledger-header)
      (check-not-exn
       (λ ()
         (min-balance/bv32 (pubkey->bv256 (AccountEntry-accountID account-entry)) ledger-entries ledger-header))))))

  (for-each-test
   (λ (t)
      (let ([account-id/bv256 (pubkey->bv256 (AccountEntry-accountID (:union:-value (LedgerEntry-data (car (vector->list (TestLedger-ledgerEntries (car t))))))))])
        (for-each-ledger-entry
         (λ (ledger-entry ledger-entries ledger-header)
            (check-not-exn
              (λ ()
                 (num-sponsoring-in-this-entry ledger-entry account-id/bv256)
                 )))
         t)))))
