#lang rosette/safe

; Goal: develop a basic model of transaction processing in Stellar.
; The model should be sufficient to generate tests for the create-account and payment operations.
; Also, develop a test harness that can take test inputs generated here and run them against the C++ implementation.

; TODO maybe we should stick to operations and exclude transactions

; TODO generate data model from XDR?

;(require rosette/lib/destruct "./path-explorer.rkt" "./generators.rkt" (only-in racket for/list with-handlers for) racket/stream)
(require (for-syntax syntax/parse racket/syntax) syntax/parse macro-debugger/stepper (only-in racket log exact-ceiling))
; model of the ledger

; a macro to make bitvector types
(define-syntax (make-bv-type stx)
  (syntax-parse stx
    [(_ name:id nbits:number)
     (with-syntax ([type-pred (format-id stx "~a?" #'name)])
     #`(begin
         (define type-pred (bitvector nbits))
         (define (#,(format-id stx "~a" #'name) i) (bv i type-pred))))]))

(make-bv-type int64 64)
(make-bv-type int32 32)
(make-bv-type account-id 256)
(make-bv-type sequence-number 256)
(make-bv-type signer-key 256)

(define-syntax (make-enum stx)
  (syntax-parse stx
    [(_ name:id ([field0:id value0:number] ...)) ; NOTE must accomodate negative values
     #;(define max-value (argmax identity (syntax->datum #'(value0 ...))))
     (with-syntax
         (#;[nbits (datum->syntax stx (exact-ceiling (log max-value 2)))] ; NOTE decided to just use 32 bits
          [nbits 32]
          [type-pred (format-id stx "~a-bv?" #'name)]
          [(member0 ...) (map (λ (f) (format-id stx "~a-~a" #'name f)) (syntax->list #'(field0 ...)))])
       #'(begin
           (define type-pred (bitvector nbits))
           (define member0 (bv value0 type-pred)) ...))]))

(make-enum account-flags ([auth-required #x1] [auth-revocable #x2] [immutable #x4] [clawback-enabled #x8]))

; the content of a ledger
; TODO: are we taking the functional-relational approach? If so, should we take inspiration from Ocelot?
; In the functional-relational approach, we use uninterpreted functions (to boolean, for relations) as much as possible because they are solvable types in Rosette
; One issue is that this will be very verbose. It would be nice to use a notation like in Alloy
; we have the following types of entries: account, trustline, offer, data, claimable-balance, and liquidity-pool
(struct ledger
  (accounts ; (~> account-id boolean)
   account-balance ; (~> account-id int64)
   account-seqNum ; (~> ccountID sequence-number)
   account-num-sub-entries ; (~> account-id int32)
   account-flags ; (~> account-id account-flags-bv)
   account-threshold-master
   account-threshold-low
   account-threshold-medium
   account-threshold-high
   account-signers ; (~> account-id key weight boolean)
   ))

; transactions

(define max-ops-per-tx 100)
(struct transaction (source-account fee seq-num time-bounds memo operations)) ; TODO: can we use contracts on structs?
(struct decorated-signature (hint signature))

(define reserve (int64 1)) ; TODO what is the reserve?

; operations
(struct create-account (account starting-balance))
(make-enum create-account-result ([success 0] [already-exists -4] [low-reserve -3]))

(struct payment-op (source destination amount))
(define payment-op-result-bits 5)  ; there is a -9 code
(define payment-success (bv 0 (bitvector payment-op-result-bits)))
(define payment-underfunded (bv -2 (bitvector payment-op-result-bits)))
(define payment-malformed (bv -1 (bitvector payment-op-result-bits)))
(define payment-no-destination (bv -5 (bitvector payment-op-result-bits)))