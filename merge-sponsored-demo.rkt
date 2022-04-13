#lang rosette

(require
  "Stellar-grammar.rkt"
  "path-explorer.rkt"
  "generate-tests.rkt"
  "Stellar-utils.rkt")

; Here the goal is to test various scenarios in which an account is merged with another account and there are some sponsored-reserve relationship involved.
; The tests will consist of a single ACCOUNT_MERGE operation.
; The variable part of the test is the ledger state in which this operation is applied.

; First, we establish some base assumptions.
; TODO account entries have at most one sponsor.
; TODO account entries have at most one extra signer.
; TODO we have at most 3 different accounts.
; TODO protocol version is 14 or 18.
; TODO we have an ACCOUNT_MERGE transaction.
(define (establish-preconditions ledger-header ledger-entries tx-envelope)
  (assume
   (and
    ; ledger header
    (bveq (LedgerHeader-ledgerSeq ledger-header) (bv 1 32)) ; sequence number 1
    (bveq (LedgerHeader-baseFee ledger-header) (bv 100 32)) ; base fee is 100 stroops
    (bveq (LedgerHeader-baseReserve ledger-header) (bv (xlm->stroop 0.5) 32)) ; base reserve is 0.5 XLM
    (let ([version (LedgerHeader-ledgerVersion ledger-header)])
      (or ; we test both versions 14 and 18
       (bveq version (bv 14 32))
       (bveq version (bv 18 32))))
    ; ledger entries
    ; we only have account entries and they all have a seq-num of 1 and a master key wheight of 1:
    (let ([account-okay?
           (λ (account-entry)
             (and
              (bveq (AccountEntry-seqNum account-entry) (bv 1 64))
              (bveq (thresholds-ref (AccountEntry-thresholds account-entry) 0) (bv 1 8))))])
      (andmap
       (λ (e)
         (and 
          (bveq (entry-type e) (bv ACCOUNT 32)) ; it's an account entry
          (account-okay? (:union:-value (LedgerEntry-data e))))) ; satisfies the account-okay? predicate
       ledger-entries)))))


