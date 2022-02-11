#lang racket

(provide test-grammar)
(require
  racket/match racket/syntax
  "xdr-compiler.rkt" ;"guile-ast-example.rkt"
  (for-template rosette rosette/lib/synthax))

; TODO generate a Rosette grammar for this:
#; (hash-ref
 (stellar-symbol-table)
 "TransactionEnvelope")

; a simpler example:
(define test-ast
  #'((define-type
       "uint256"
       (fixed-length-array "opaque" 32))
     (define-type
       "my-array"
       (fixed-length-array "uint256" 2))
     (define-type
       "PublicKeyType"
       (enum ("PUBLIC_KEY_TYPE_ED25519" 0)))
     (define-type
       "PublicKey"
       (union (case ("type" "PublicKeyType")
                (("PUBLIC_KEY_TYPE_ED25519") ("ed25519" "uint256")))))))

(define test-sym-table
  (parse-asts test-ast))

; Produce a syntax object defining a Rosette grammar
; Note that we need a syntax-object to use as context, provided by the macro calling this, otherwise g will be out of scope for the code that follows.
; Looks like it's better to postpone using define-grammar to the macro that will use xdr-types->grammar
#;(define (xdr-types->grammar stx-context sym-table type)
  (define (the-grammar t)
    #`[my-rule (?? (bitvector 32))])
  #`(define-grammar (#,(format-id stx-context "g")) #,(the-grammar type)))

; Builds a syntax object containing a list of grammar rules
(define (xdr-types->grammar sym-table type)
  (define (rule-id str [index 0])
    ; Rosette seems to be relying on source location information.
    ; Since we want all grammar holes to be independent, we need to use a unique location each time.
    (format-id #f "~a-rule" str #:source (make-srcloc (format "~a-rule:~a" str index) 1 0 1 0)))
  (define (array type size)
    #`(list
       #,@(datum->syntax
          #'()
          (for/list ([i (in-range size)])
            #`(#,(rule-id type i))))))
  (define (the-grammar t)
    (match (hash-ref sym-table t)
      [`(opaque-fixed-length-array ,nbytes)
       #`([#,(rule-id t) (?? (bitvector #,(* nbytes 8)))])]
      [`(fixed-length-array ,elem-type ,size)
       (let ([top-rule #`[#,(rule-id t) #,(array elem-type size)]])
         #`(#,top-rule #,@(the-grammar elem-type)))]))
  (the-grammar type))

(define (test-grammar)
  (xdr-types->grammar test-sym-table "my-array"))