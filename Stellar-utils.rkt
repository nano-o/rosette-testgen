#lang rosette

(require
  "Stellar-grammar.rkt"
  rosette/lib/destruct)

(provide (all-defined-out))

; 10 millon stroops = 1 XLM
(define (xlm->stroop x)
  (* x 10000000))

(define (source-account tx-envelope)
  ; returns the ed25519 public key of this account (as a bitvector)
  ; NOTE how verbose this is; could use some syntactic abstraction...
  (destruct tx-envelope
    [(:union: tag v)
     (cond
       [(bveq tag (bv ENVELOPE_TYPE_TX 32))
        (destruct v
          [(TransactionV1Envelope tx _)
           (destruct tx
             [(Transaction src _ _ _ _ _ _)
              (destruct src ; this is a MuxedAccount
                [(:union: tag v)
                 (cond
                   [(bveq tag (bv KEY_TYPE_ED25519 32)) v]
                   [(bveq tag (bv KEY_TYPE_MUXED_ED25519 32))
                    ; in this case, extract the ed25519 key
                    (destruct v
                      [(MuxedAccount::med25519 _ k) k])])])])])]
       [else (assume #f)])])) ; not supported

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