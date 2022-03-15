#lang rosette

(require racket/include)
(require (for-syntax racket/syntax) syntax/parse/define macro-debugger/stepper)

; We start with a set of macros that give meaning to a parse tree produced by guile-rpc

; a bitvector type needs a type predicate and a constructor
(define-syntax-parse-rule (make-bv-type name:string nbits:number)
  #:with type-name (format-id #'name #:source #'name "~a" (syntax-e #'name))
  #:with type-pred (format-id #'name #:source #'name "~a?" (syntax-e #'name))
  (begin
    (define type-pred (bitvector nbits))
    (define (type-name val) (bv val type-pred))))

; enums are just 32-bit bitvectors; we define a type-predicate shorthand and symbols for each member, but no constructor
(define-syntax-parse-rule (make-enum-type name:string ([field0:string value0:number] ...)) ; NOTE must allow negative values
  #:with type-pred (format-id #'name #:source #'name "~a?" (syntax-e #'name))
  #:with (member0 ...) (map (λ (f) (format-id #'name #:source f "~a-~a" (syntax-e #'name) (syntax-e f))) (syntax->list #'(field0 ...)))
  ; NOTE: we need to prefix union-member names by the type name because it's a local scope according to the RFC
  (begin
    (define type-pred (bitvector 32))
    (define member0 (bv value0 type-pred)) ...))

(define-syntax-parse-rule (make-union-type typename:string ([tag-value0:string variant-name0:string variant-type0:string] ...))
  #:with type-pred (format-id #'typename #:source #'typename "~a?" (syntax-e #'typename))
  (begin
    (define (type-pred x) 

; TODO: unions
; A union is a pair of the form (tag, value)
; We probably need a case construct
; What about a type predicate?

(begin-for-syntax
  (define-syntax-class opaque-fixed-length-array
    [pattern (typename:string ((~literal fixed-length-array) "opaque" nbits:nat))])
  (define-syntax-class variant-spec
    [pattern ((tag-value:string) (variant-name:string variant-type:string))])
  (define-syntax-class union
    [pattern (typename:string
              ((~literal union)
               ((~literal case)
                (tag-name:string tag-type:string) v0:variant-spec ...)))
             #:attr variants #'((v0.tag-value v0.variant-name v0.variant-type) ...)]))

; the define-type macro:
(define-syntax-parser define-type
  ; int
  [(_ typename:string "int")
   #'(make-bv-type typename 32)]
  ; unsigned int
  ; TODO: would be nice to remember it's unsigned and not allow signed operations
  [(_ typename:string "unsigned int")
   #'(make-bv-type typename 32)]
  ; hyper
  [(_ typename:string "hyper")
   #'(make-bv-type typename 64)]
  ; unsigned hyper
  [(_ typename:string "unsigned hyper")
   #'(make-bv-type typename 64)]
  ; enum
  [(_ typename:string ((~literal enum) [name0:string val0:number] ...))
   #'(make-enum-type typename ([name0 val0] ...))]
  ; opaque fixed-length arrays
  [(_ . ofla:opaque-fixed-length-array)
   #'(make-bv-type ofla.typename ofla.nbits)]
  ; union
  [(_ . u:union)
   #'(display 'u.variants)]
  ; struct
  )

#;(include (file "./Stellar.xdr.scm"))

; test
(begin
  (define-type
    "Hash"
    (fixed-length-array "opaque" 32))
  (define-type "int32" "int")
  (define-type "uint64" "unsigned hyper")
  (define-type
      "CryptoKeyType"
      (enum ("KEY_TYPE_ED25519" 0)
            ("KEY_TYPE_PRE_AUTH_TX" 1)
            ("KEY_TYPE_HASH_X" 2)
            ("KEY_TYPE_MUXED_ED25519" 256)))
  (define-type
    "PublicKey"
    (union (case ("type" "PublicKeyType")
             (("PUBLIC_KEY_TYPE_ED25519")
              ("ed25519" "uint256")))))

  (Hash 1)
  (int32 0)
  (uint64 0)
  CryptoKeyType?
  CryptoKeyType-KEY_TYPE_ED25519
  CryptoKeyType-KEY_TYPE_HASH_X)