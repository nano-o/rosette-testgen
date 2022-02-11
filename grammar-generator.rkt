#lang racket

(provide test-grammar)
;(require "xdr-compiler.rkt" "guile-ast-example.rkt")
(require racket/syntax
  (for-template rosette rosette/lib/synthax))

; TODO generate a Rosette grammar for this:
#; (hash-ref
 (stellar-symbol-table)
 "TransactionEnvelope")

; TODO a simpler example:
(define test-ast
  #'((define-type
      "uint256"
      (fixed-length-array "opaque" 32))
    (define-type
      "PublicKeyType"
      (enum ("PUBLIC_KEY_TYPE_ED25519" 0)))
    (define-type
      "PublicKey"
      (union (case ("type" "PublicKeyType")
               (("PUBLIC_KEY_TYPE_ED25519") ("ed25519" "uint256")))))))

#;(define test-sym-table
  (parse-asts test-ast))

; Produce a syntax object defining a Rosette grammar
; Note that we need a syntax-object to use as context, provided by the macro calling this, otherwise g will be out of scope for the code that follows. 
#;(define (xdr-types->grammar stx-context sym-table type)
  (define (the-grammar t)
    #`[my-rule (?? (bitvector 32))])
  #`(define-grammar (#,(format-id stx-context "g")) #,(the-grammar type)))

; another version
(define (xdr-types->grammar sym-table type)
  (define (the-grammar t)
    #`[my-rule (?? (bitvector 32))])
  (the-grammar type))

(define (test-grammar)
  (xdr-types->grammar (hash) "PublicKey"))

#;(define-grammar (gg)
  [PublicKey-rule
   (cons 0 (uint256-rule))]
  [uint256-rule
   (?? (bitvector 32))])