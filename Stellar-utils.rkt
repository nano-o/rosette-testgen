#lang rosette

(require
  "Stellar-grammar-merge-sponsored-demo.rkt"
  rosette/lib/destruct)

; TODO couldn't we just generate the grammar here?

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