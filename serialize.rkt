#lang racket

(require
  syntax/parse racket/syntax
  binaryio/integer
  pretty-format
  syntax/to-string
  "Stellar-inline-2.rkt"
  "synthesized-tx-examples.rkt")

; We serialize synthesized transactions and ledger entries to the representation expected by the guile-rpc library

(define (racket->guile-rpc stx) ; generate-forms produces syntax objects
  (syntax-parse stx
    [((~datum define) _ d:xdr-rep) #'d.out]))

; we need the current namespace to do reflection on structs with eval
(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))
(define (struct? id)
  (and
   (identifier-binding id)
   (struct-type? (eval-syntax id ns))))

(define-syntax-class xdr-rep
  #:datum-literals (bv vector null bitvector :union: :byte-array:)
  [pattern (:union: tag:xdr-rep val:xdr-rep)
           #:attr out #`(cons tag.out val.out)]
  [pattern (:byte-array: (bv n:number size:number))
           ; opaque fixed-sized array -> list of bytes
           #:attr out #`(bytes->list (integer->bytes n size #f #t))] ; unsigned big-endian
  [pattern (bv v:xdr-rep n:number)
           #:attr out #`v.out]
  [pattern (vector e*:xdr-rep ...)
           ; variable-size array
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
  [pattern i:id
           ; here we need to replace all "_" characters by "-"
           #:attr out #`'#,(format-id #'() "~a" (string-replace (syntax->string #'(i)) "_" "-"))])

(println (eval-syntax (racket->guile-rpc example-1) ns))
;(racket->guile-rpc example-1)