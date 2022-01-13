#lang rosette

; Goal: develop a basic model of transaction processing in Stellar.
; The model should be sufficient to generate tests for the create-account and payment operations.
; Also, develop a test harness that can take test inputs generated here and run them against the C++ implementation.

; TODO maybe we should stick to operations and exclude transactions

; TODO generate data model from XDR?

; TODO take integer overflows into account.

;(require rosette/lib/destruct "./path-explorer.rkt" "./generators.rkt" (only-in racket for/list with-handlers for) racket/stream)
(require rosette/lib/destruct "./path-explorer.rkt" "./generators.rkt")
(require (for-syntax syntax/parse racket/syntax) syntax/parse macro-debugger/stepper (only-in racket for/fold))
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
(make-bv-type account-ID 256)
(make-bv-type sequence-number 256)
(make-bv-type signer-key 256)
(make-bv-type asset 32) ; AssetCode4

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

(make-enum account-flag ([auth-required #x1] [auth-revocable #x2] [immutable #x4] [clawback-enabled #x8]))

; The content of a ledger
; To remain solver friendly, we represent everything with relations and functions (like in Alloy)
; TODO write a macro that takes a bunch of structs and generates a relational representation.
; TODO a function that reconstructs said structs from Rosette solutions
; TODO serialization of ledgers and transactions to XDR for consumption by core

; Why are we not taking the SQL approach? E.g. a relation describing accounts.
; We have basic types, structs, and tagged unions to deal with.
; How do we deal with tagged unions? A tagged union could be represented by a relation with that has fields for all members, and the tag indicates which should be ignored.

; We have the following types of entries: account, trustline, offer, data, claimable-balance, and liquidity-pool
; For now, let's exclude liquidity-prool and maybe data and claimable-balance. That leaves use with account, trustline, and offer

; one possibility is to take an SQL-like approach:
(struct ledger-1
  (account
   trustline
   offer))

(define init-ledger-1 ; a root account with 1000 lumens
  (ledger-1
   (λ (account-ID balance seq-num num-sub-entries flags) (and (equal? account-ID 0) (equal? balance 1000) (equal? seq-num 0)))
   (λ (account-ID asset-type-tag asset-type-value balance limit) #f) ; in XDR, asset-type is a tagged union
   (λ (seller-ID offer-ID selling-asset-type-tag selling-asset-type-value buying-asset-type-tag buying-asset-type-value amount price flags) #f)
   ))

; the problem with this approach is that transaction-processing code will be clumsy

; another approach is to use functions as much as possible
(struct ledger
  (account ; (~> account-ID? boolean?)
   account-balance ; in stroops
   account-seq-num
   ;account-num-sub-sentries
   ;account-flags
   ;trustline ; (~> account-id asset? boolean?) ; TODO can an account have multiple trustlines for the same asset? We could state conjectures like that and generate tests to check
   ;trustline-balance
   ;trustline-limit
   ))
   
; operations
(struct create-account (destination starting-balance))
(make-enum create-account-result-code ([success 0] [already-exists -4] [low-reserve -3] [underfunded -2]))

; NOTE no muxed accounts
(struct payment-op (destination asset amount))
(make-enum payment-result-code ([success 0]  [malformed -1] [underfunded -2] [src-no-trust -3] [no-destination -5] [line-full -8])) ; TODO and more

(struct change-trust-op (line limit)) ; line is an asset

; transactions

(struct transaction
  (source-account
   fee
   seq-num
   operation)) ; only one operation for now

(define (lumen x) (bvmul x (int64 10000000))) ; one lumen is 10 million stroops
(define reserve (lumen (int64 1)))
(define subentry-reserve (int64 5000000)) ; .5 lumen

(define-with-path-explorer (apply-create-account l src dest sbal)
  (cond
    [((ledger-account l) dest) ; already exists
     (cons create-account-result-code-already-exists l)]
    [(bvslt sbal reserve) ; initial balance below reserve
     (cons create-account-result-code-low-reserve l)]
    [(bvslt ((ledger-account-balance l) src) sbal) ; src does not have enough funds
     (cons create-account-result-code-underfunded l)]
    [else
     (cons
      create-account-result-code-success
      (ledger
       (λ (acc)
         (cond
           [(equal? acc dest) #t] ; dest is now created
           [else ((ledger-account l) acc)])) ; TODO syntax for updates
       (λ (acc)
         (cond
           [(equal? acc dest) sbal] ; dest has sbal starting balance
           [else ((ledger-account-balance l) acc)]))
       (ledger-account-seq-num l)))]))

(define-with-path-explorer (apply-operation src op l)
  (destruct op
    [(create-account a b)
    (apply-create-account l src a b)]))

(define-with-path-explorer (apply-transaction tx l)
  (apply-operation (transaction-source-account tx) (transaction-operation tx) l))

#;(expand/step #'(define-with-path-explorer (apply-transaction tx l)
  (apply-operation (transaction-source-account tx) (transaction-operation tx) l)))

; concrete inputs

(define concrete-ledger
  (ledger
   (λ (acc) (bveq acc (account-ID 0)))
   (λ (acc) (if (bveq acc (account-ID 0)) (int64 100000000) (int64 0)))
   (λ (acc) (sequence-number 0))))
(define concrete-tx (transaction (account-ID 0) (int64 100000000) (sequence-number 0) (create-account (account-ID 1) (int64 10000000))))
(apply-transaction concrete-tx concrete-ledger)

;(solve (apply-transaction-path-explorer (constant-gen 3) concrete-tx concrete-ledger))

; symbolic inputs

(define-symbolic src-acc dst-acc account-ID?)
(define-symbolic fee sbal int64?)
(define-symbolic seq-num sequence-number?)
(define-symbolic sym-ledger-account (~> account-ID? boolean?))
(define-symbolic sym-ledger-account-balance (~> account-ID? int64?))
(define-symbolic sym-ledger-account-seq-num (~> account-ID? sequence-number?))

(define tx (transaction src-acc fee seq-num (create-account dst-acc sbal)))
(define l (ledger sym-ledger-account sym-ledger-account-balance sym-ledger-account-seq-num))


(define model-list (stream->list (all-paths (λ (gen) (apply-transaction-path-explorer gen tx l)))))
(for ([m model-list])
  (println m))
(println (format "we made ~a queries" (length model-list)))
(define num-unsat (count unsat? model-list))
(println (format "~a queries were unsat" num-unsat))