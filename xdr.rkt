#lang rosette

(require racket/include)
(require (for-syntax syntax/parse racket/syntax) macro-debugger/stepper)

#;(define-for-syntax base-types
  (list "bool" "int" "unsigned int" "hyper" "unsigned hyper" "double" "quadruple" "float"))

; a bitvector type needs a type predicate and a constructor
(define-syntax (make-bv-type stx)
  (syntax-parse stx
    [(_ name:id nbits:number)
     (with-syntax ([type-pred (format-id #'name "~a?" #'name)]) ; NOTE: we need the lexical context of #'name and not stx if this macro is to be used inside anoother macro...
     #`(begin
         (define type-pred (bitvector nbits))
         (define (#,(format-id #'name "~a" #'name) val) (bv val type-pred))))]))

(define-syntax (define-type stx)
  (syntax-parse stx
    ; opaque fixe-length arrays
    [(_ typename:string ((~literal fixed-length-array) "opaque" nbits:nat))
     (with-syntax ([type-id (format-id stx "~a" (syntax-e #'typename))])
       #'(make-bv-type type-id nbits))]
    ; int
    [(_ typename:string "int")
     (with-syntax ([type-id (format-id stx "~a" (syntax-e #'typename))])
       #'(make-bv-type type-id 32))]
    ; unsigned int
    ; TODO: would be nice to remember it's unsigned and not allow signed operations
    [(_ typename:string "unsigned int")
     (with-syntax ([type-id (format-id stx "~a" (syntax-e #'typename))])
       #'(make-bv-type type-id 32))]
    ; hyper
    [(_ typename:string "hyper")
     (with-syntax ([type-id (format-id stx "~a" (syntax-e #'typename))])
       #'(make-bv-type type-id 64))]
    ; unsigned hyper
    [(_ typename:string "unsigned hyper")
     (with-syntax ([type-id (format-id stx "~a" (syntax-e #'typename))])
       #'(make-bv-type type-id 64))]))

#;(include (file "./Stellar.xdr.scm"))

(define-type
    "Hash"
    (fixed-length-array "opaque" 32))
(define-type "int32" "int")

(Hash 1)
(int32 0)