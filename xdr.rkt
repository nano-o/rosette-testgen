#lang rosette

(require racket/include)
(require (for-syntax syntax/parse racket/syntax) syntax/parse macro-debugger/stepper)
         
(define-for-syntax base-types
  (list "bool" "int" "unsigned int" "hyper" "unsigned hyper" "double" "quadruple" "float"))

; a bitvector type needs a type predicate and a constructor
(define-syntax (make-bv-type stx)
  (syntax-parse stx
    [(_ name:id nbits:number)
     (with-syntax ([type-pred (format-id stx "~a?" #'name)])
     #`(begin
         (define type-pred (bitvector nbits))
         (define (#,(format-id stx "~a" #'name) val) (bv val type-pred))))]))

(define-syntax (define-type stx)
  (syntax-parse stx
    [(_ type:string ((~literal fixed-length-array) "opaque" nbits:nat))
     (with-syntax ([type-id (format-id stx "~a" (syntax->datum #'type))])
       #'(make-bv-type type-id nbits))]))

#;(include (file "/home/nano/Documents/guile/Stellar.xdr.scm"))

(expand/step
 #'(define-type
     "Hash"
     (fixed-length-array "opaque" 32)))
