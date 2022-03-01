#lang rosette

(require
  "Stellar-inline.rkt"
  "path-explorer.rkt"
  rosette/lib/synthax
  syntax/to-string)

(define min-fee (bv 2 32)) ; TODO

(define-with-path-explorer (execute-tx ledger time tx)
  (if (equal? (car tx) (bv ENVELOPE_TYPE_TX 32))
      (if (bvuge (Transaction-fee (TransactionV1Envelope-tx (cdr tx))) min-fee) 'okay 'low-fee)
      (error "error")))

(define input-tx (TransactionEnvelope-grammar #:depth 6))

(define solution-list (stream->list (all-paths (λ (gen) (execute-tx-path-explorer gen null null input-tx)))))

(for ([s solution-list])
  (if (sat? s)
      (let ([complete-sol (complete-solution s (symbolics input-tx))])
        (map (λ (f) (pretty-display (syntax->datum f))) (generate-forms complete-sol)))
      (void)))

#|
(define sol
  (synthesize
   #:forall '()
   #:guarantee (assert (equal? (execute-tx null null (TransactionEnvelope-grammar #:depth 4)) 'okay))))

(generate-forms sol)
|#