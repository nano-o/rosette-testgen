#lang racket

(require syntax/parse racket/syntax "Stellar-inline.rkt")

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
             (cons
              (bv PUBLIC_KEY_TYPE_ED25519 (bitvector 32))
              (bv #x0000000000000000000000000000000000000000000000000000000000000000 256))
             (bv #x0000000000000000 64)))))
         (cons (bv 0 (bitvector 32)) null))
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
; In guile-rpc, fixed-length types are represented with lists while variable-length ones are represented with vectors.
; Enum values are also a problem. We could use Racket structs for those.
; Another solution is to use the type description to guide the translation.
(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))

(define-syntax-class xdr-rep
  #:datum-literals (cons bv vector null bitvector)
  [pattern (cons (bv i:id (bitvector n:number)) val:xdr-rep)
           #:attr out #`(cons 'i val.out)]
  [pattern (cons tag:xdr-rep val:xdr-rep)
           #:attr out #'(cons tag.out val.out)]
  [pattern (bv v:number (~or 32 64)) ; TODO hack
           #:attr out #'v]
  [pattern (bv v:number n:number)
           #:attr out #''(bv v n)] ; TODO vector of bytes
  [pattern (bv v:number (bitvector (~or 32 64)))
           #:attr out #'v]
  [pattern (bv v:number (bitvector n:number))
           #:attr out #''(bv v n)]
  [pattern (vector e*:xdr-rep ...)
           #:attr out #'`#(,e*.out ...)]
  [pattern (struct-name:id e*:xdr-rep ...)
           #:when (let ([type-id (format-id #'() "struct:~a" #'struct-name)])
                    (and
                     (identifier-binding type-id)
                     (struct-type? (eval-syntax type-id ns))))
           #:attr out #'`(,e*.out ...)]
  [pattern n:number
           #:attr out #'n]
  [pattern null
           #:attr out #''void]
  #;[pattern (e*:xdr-rep ...)
           #:do ((println (format "matched ~a" #'(e* ...))))
           #:attr out #'`(,e*.out ...)])

(eval-syntax (racket->guile-rpc tx-1) ns)