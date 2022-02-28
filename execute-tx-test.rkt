#lang rosette

(require
  "Stellar-inline.rkt"
  "path-explorer.rkt"
  rosette/lib/synthax)

(define min-fee (bv 2 32))

(define-with-path-explorer (execute-tx ledger time tx)
  (if (equal? (car tx) (bv ENVELOPE_TYPE_TX 32))
      (if (bvuge (Transaction-fee (TransactionV1Envelope-tx (cdr tx))) min-fee) 'okay 'low-fee)
      (error "error")))

(define model-list (stream->list (all-paths (λ (gen) (execute-tx-path-explorer gen null null (TransactionEnvelope-grammar #:depth 4))))))

(for ([m model-list])
  (println m))

#|
(define sol
  (synthesize
   #:forall '()
   #:guarantee (assert (equal? (execute-tx null null (TransactionEnvelope-grammar #:depth 4)) 'okay))))

(generate-forms sol)
|#