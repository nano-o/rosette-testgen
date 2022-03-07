#lang racket

(require syntax/parse)

; We serialize synthesized transactions and ledger entries to the representation expected by the guile-rpc library

; Example:
(define tx-1
  #'(define input-tx
      (cons
       (bv ENVELOPE_TYPE_TX (bitvector 32))
       (TransactionV1Envelope
        (Transaction
         (cons
          (bv KEY_TYPE_ED25519 (bitvector 32))
          (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
         (bv #x00000000 32)
         (bv #x0000000000000000 64)
         (cons (bv FALSE (bitvector 32)) null)
         (cons (bv MEMO_NONE (bitvector 32)) null)
         (vector
          (Operation
           (cons (bv FALSE (bitvector 32)) null)
           (cons
            (bv CREATE_ACCOUNT (bitvector 32))
            (CreateAccountOp
             (choose
              (cons
               (bv PUBLIC_KEY_TYPE_ED25519 (bitvector 32))
               (bv #x0000000000000000000000000000000000000000000000000000000000000000 256)))
             (bv #x0000000000000000 64)))))
         (choose (cons (bv 0 (bitvector 32)) null)))
        (vector
         (DecoratedSignature
          (bv #x00000000 32)
          (cons
           64
           (bv #x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 512))))))))

(define (racket->guile-rpc stx) ; generate-forms produces syntax objects
  (syntax-parse stx
    [((~datum define) _ d:xdr-rep) #'d.out]))

; TODO we cannot tell integers from opaque arrays...

(define-syntax-class xdr-rep
  #:datum-literals (cons bv vector null bitvector)
  [pattern (cons (bv i:id (bitvector n:number)) val:xdr-rep)
           #:attr out #`(cons 'i val.out)]
  [pattern (cons tag:xdr-rep val:xdr-rep)
           #:attr out #'(cons tag.out val.out)]
  [pattern (bv v:number n:number)
           #:attr out #''(bv v n)]
  [pattern (bv v:number (bitvector n:number))
           #:attr out #''(bv v n)]
  [pattern (vector e*:xdr-rep ...)
           #:attr out #'`#(,e*.out ...)]
  [pattern (struct-name:id e*:xdr-rep ...)
           #:attr out #'`(,e*.out ...)]
  [pattern null
           #:attr out #''void]
  [pattern n:number
           #:attr out #'n]
  [pattern (e*:xdr-rep ...)
           #:attr out #'`(,e*.out ...)])

(syntax->datum (racket->guile-rpc tx-1))