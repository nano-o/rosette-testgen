#lang errortrace rosette

; NOTE In vim, let vim-racket set the filetype to sweet-exp, then set syntax=scheme.
; This way no lispy plugins are loaded and we get sane indentation (also scheme syntax supports #;)
; Also configure YCM for the sweet-exp filetype

(provide
  (all-defined-out))

(require
  "Stellar.rkt"
  infix
  unstable/lens)

;; TODO a macro that erases `define/contract` (Rosette doesn't support it)

(define/contract (enum-value v)
  (-> number? (bitvector 32))
  (bv v 32))

; 10 millon stroops = 1 XLM
(define/contract (xlm->stroop x)
  (-> number? number?)
  (* x 10000000))

(define/contract (bv-size bv)
  (-> bv? number?)
  (length (bitvector->bits bv)))

(define/contract (bv->bv64 bitvect)
  (-> (and/c bv? (λ (bv) (<= (bv-size bv) 64))) (bitvector 64))
  (zero-extend (bitvect (bitvector 64))))

(define/contract (opt-non-null? x)
  (-> -optional? boolean?)
  (bveq (-optional-present x) (enum-value 1)))

(define/contract (opt-null? x)
  (-> -optional? boolean?)
  (bveq (-optional-present x) (enum-value 0)))

(define/contract (tx-envelope-src-account tx)
  (-> TransactionEnvelope? (bitvector 256))
  (cond
    [(bveq (TransactionEnvelope-tag tx) (enum-value ENVELOPE_TYPE_TX_V0))
     (lens-view~> tx TransactionEnvelope-value-lens TransactionV0Envelope-tx-lens TransactionV0-sourceAccountEd25519-lens)]
    [(bveq (TransactionEnvelope-tag tx) (enum-value ENVELOPE_TYPE_TX))
     (muxed-account->bv256 (lens-view~> tx TransactionEnvelope-value-lens TransactionV1Envelope-tx-lens Transaction-sourceAccount-lens))]
    [(bveq (TransactionEnvelope-tag tx) (enum-value ENVELOPE_TYPE_TX_FEE_BUMP))
     (muxed-account->bv256 (lens-view~> tx TransactionEnvelope-value-lens FeeBumpTransactionEnvelope-tx-lens FeeBumpTransaction-innerTx-lens TransactionV1Envelope-tx-lens Transaction-sourceAccount-lens))]))

(define/contract (tx-envelope-seqnum tx)
  (-> TransactionEnvelope? (bitvector 64))
  (cond
    [(bveq (TransactionEnvelope-tag tx) (enum-value ENVELOPE_TYPE_TX_V0))
     (lens-view~> tx TransactionEnvelope-value-lens TransactionV0Envelope-tx-lens TransactionV0-seqNum-lens)]
    [(bveq (TransactionEnvelope-tag tx) (enum-value ENVELOPE_TYPE_TX))
     (lens-view~> tx TransactionEnvelope-value-lens TransactionV1Envelope-tx-lens Transaction-seqNum-lens)]
    [(bveq (TransactionEnvelope-tag tx) (enum-value ENVELOPE_TYPE_TX_FEE_BUMP))
     (lens-view~> tx TransactionEnvelope-value-lens FeeBumpTransactionEnvelope-tx-lens FeeBumpTransaction-innerTx-lens TransactionV1Envelope-tx-lens Transaction-seqNum-lens)]))

(define/contract (muxed-account->bv256 muxed-account)
  (-> MuxedAccount? (bitvector 256))
  (define tag (MuxedAccount-tag muxed-account))
  (define value (MuxedAccount-value muxed-account))
  (cond
    [(bveq tag (enum-value KEY_TYPE_ED25519))
     (-byte-array-value value)]
    [(bveq tag (enum-value KEY_TYPE_MUXED_ED25519))
     (-byte-array-value (MuxedAccount::med25519-ed25519 value))]
    [else
      (error (format "tag of ~a not in enum range" muxed-account))]))

(define/contract (source-account/bv256 tx-envelope)
  ; returns the ed25519 public key of this account (as a bitvector)
  (-> TransactionEnvelope? (bitvector 256))
  (define tag (TransactionEnvelope-tag tx-envelope))
  (define val (TransactionEnvelope-value tx-envelope))
  (cond
    [(bveq tag (enum-value ENVELOPE_TYPE_TX))
     (define src (lens-view~> val TransactionV1Envelope-tx-lens Transaction-sourceAccount-lens))
     (muxed-account->bv256  src)]
    [else
      (error (format "tag not supported in: ~a" tx-envelope))]))

(define/contract (entry-type e)
  (-> LedgerEntry? (bitvector 32)); TODO create predicates for enum types?
  (lens-view~> e LedgerEntry-data-lens LedgerEntry::data-tag-lens))

(define/contract (account-entry? e) ; is this ledger entry an account entry?
  (-> LedgerEntry? boolean?)
  (bveq (entry-type e) (enum-value ACCOUNT)))
; Thresholds are an opaque array; because we represent opaque arrays with flat bitvectors, it's a bit harder to access the components
; TODO: why not use vectors of bytes?
(define (thresholds-ref t n) ; n between 0 and 3
  (define b (-byte-array-value t)) ; total size is 32 bits
  (define i ($ "31-n*8")) ;(- 31 (* n 8)))
  (define j ($ "32-(n+1)*8")) ; (- 32 (* ( n 1) 8)))
  (extract i j b))

(define/contract (master-key-threshold account-entry) ; get the master key threshold
  (-> AccountEntry? (bitvector 8))
  (thresholds-ref (AccountEntry-thresholds account-entry) 0))

(define/contract (pubkey->bv256 pubkey)
  (-> PublicKey? (bitvector 256))
  (-byte-array-value (PublicKey-value pubkey)))

(define/contract (account-entry-for? ledger-entry account-id/bv256)
  (-> LedgerEntry? (bitvector 256) boolean?)
  ; true iff the ledger entry is an account entry with the given account ID.
  (define account-entry (LedgerEntry::data-value (LedgerEntry-data ledger-entry)))
  (define entry-id/bv256 (pubkey->bv256 (AccountEntry-accountID account-entry)))
  (and
    (account-entry? ledger-entry)
    (bveq entry-id/bv256 account-id/bv256)))

(define/contract (findf-account-entry account-id/bv256 ledger-entries)
  (-> (bitvector 256) (*list/c LedgerEntry?) (or/c LedgerEntry? boolean?))
  (define predicate (λ (e) (account-entry-for? e account-id/bv256)))
  (findf predicate ledger-entries)) ; returns false if not found

