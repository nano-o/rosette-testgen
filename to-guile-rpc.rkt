#lang racket

(require
  syntax/parse
  racket/syntax
  binaryio/integer
  syntax/to-string
  (only-in rosette bv bitvector bv? bitvector->natural bitvector->bits)
  "Stellar-grammar.rkt"
  "synthesized-tx-examples.rkt")

(provide defn->guile-rpc/xdr)

; We serialize synthesized transactions and ledger entries to the representation expected by the guile-rpc library
; TODO might be easier to eval the received syntax and then use match on the resulting datum
; NOTE that guile-rpc expects symbols for enum constants, and not numbers

; we need the current namespace to do reflection on structs with eval
(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))

(define (struct? id)
  (and
   (identifier-binding id)
   (struct-type? (eval-syntax id ns))))

(define (defn->guile-rpc/xdr stx)
  ; stx is supposed to be the output of generate-forms.
  ; generate-forms produces syntax objects with no bindings, so we do a syntax->datum->syntax round-trip to re-interpret stuff.
  (syntax-parse (datum->syntax #'() (syntax->datum stx))
    [((~datum define) _ d:xdr-rep)
     (eval-syntax #'d.out ns)]))

(define (integer->bytelist val nbytes)
  (bytes->list (integer->bytes val nbytes #f #t)))

(define-syntax-class xdr-rep
  #:literals (list bv vector null bitvector :union: :byte-array:)
  [pattern (:union: tag:xdr-rep val:xdr-rep)
           #:attr out #'(cons tag.out val.out)]
  [pattern (:byte-array: (bv val:number size:number))
           ; opaque fixed-sized array -> list of bytes
           #:attr out #'(integer->bytelist val (/ size 8))] ; unsigned big-endian
  [pattern (:byte-array: bv-literal)
           #:when (bv? (syntax-e #'bv-literal))
           ; opaque fixed-sized array -> list of bytes
           #:attr out (let* ([the-bv (syntax-e #'bv-literal)]
                             [val (bitvector->natural the-bv)]
                             [nbytes (/ (length (bitvector->bits the-bv)) 8)])
                        #`(integer->bytelist #,val #,nbytes))] ; unsigned big-endian
  ; bv not wrapped in :byte-array: are ints or hypers, to be serialized to just a literal number
  [pattern (bv v:xdr-rep n:number)
           #:attr out #`v.out]
  [pattern bv-literal
           #:when (bv? (syntax-e #'bv-literal))
           #:attr out #`#,(bitvector->natural (syntax-e #'bv-literal))]
  [pattern (vector e*:xdr-rep ...)
           ; variable-size array
           #:attr out #'`#(,e*.out ...)]
  [pattern (struct-name:id e*:xdr-rep ...)
           #:when (let ([type-id (format-id #'() "struct:~a" #'struct-name)])
                    (and
                     (identifier-binding type-id)
                     (struct-type? (eval-syntax type-id ns))))
           #:attr out #'`(,e*.out ...)]
  [pattern (list e*:xdr-rep ...+)
           ; fixed-size array
           #:attr out #'`(,e*.out ...)]
  [pattern n:number
           #:attr out #'n]
  [pattern null
           #:attr out #''void]
  [pattern i:id
           ; here we need to replace all "_" characters by "-"
           #:attr out #`'#,(format-id #'() "~a" (string-replace (syntax->string #'(i)) "_" "-"))])

(module+ test
  (require rackunit)
  (define example-1
    (let ([my-bv-32 (bv 0 32)]
          [my-bv-256 (bv 0 256)])
      #`(define my-tx
          (:union:
           (bv ENVELOPE_TYPE_TX 32)
           (TransactionV1Envelope
            (Transaction
             (:union:
              (bv KEY_TYPE_MUXED_ED25519 32)
              (MuxedAccount::med25519
               (bv #x0000000000000000 64)
               (:byte-array:
                (bv
                 29458565313587576488605812219632678825768279426807042594960959184304126581667
                 256))))
             #,my-bv-32
             (bv #x0000000000000000 64)
             (:union: (bv FALSE 32) null)
             (:union:
              (bv MEMO_RETURN 32)
              (:byte-array:
               #,my-bv-256))
             (vector
              (Operation
               (:union: (bv FALSE 32) null)
               (:union:
                (bv CREATE_ACCOUNT 32)
                (CreateAccountOp
                 (:union:
                  (bv PUBLIC_KEY_TYPE_ED25519 32)
                  (:byte-array:
                   (bv
                    29458565313587576488605812219632678825768279426807042594960959184304126581667
                    256)))
                 (bv #x0000000000000000 64)))))
             (:union: (bv 0 32) null))
            (vector))))))
    (define/provide-test-suite serialize/test
      (test-case
       "serialize transaction"
       (check-equal?
        (defn->guile-rpc/xdr example-1)
        '(ENVELOPE-TYPE-TX
          ((KEY-TYPE-MUXED-ED25519 0 (65 32 245 4 132 15 130 86 201 188 205 227 214 17 246 138 208 74 110 187 8 101 242 142 164 42 213 13 113 216 91 163))
           0
           0
           (FALSE . void)
           (MEMO-RETURN 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
           #(((FALSE . void) (CREATE-ACCOUNT (PUBLIC-KEY-TYPE-ED25519 65 32 245 4 132 15 130 86 201 188 205 227 214 17 246 138 208 74 110 187 8 101 242 142 164 42 213 13 113 216 91 163) 0)))
           (0 . void))
          #())))))