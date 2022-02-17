#lang racket

; The guile-rpc parser transforms an XDR file into a list of define-type and define-constant s-exprs.
; This module provides macros that turn such an AST into a more useful, symbol-table-like data structure.

; Note that we do not handle the all possible guile-rpc ASTs, but only a super-set of those that appear in Stellar's XDR files.
; Notable, this does not support recursive XDR types.

(provide parse-ast)

(require
  syntax/parse
  racket/hash list-util
  rackunit)

(module+ test
  (require rackunit)
  (provide ks-v-assoc->hash/test parse-ast/test))

; First pass: a recursive syntax class, defs, that builds a symbol table where symbols are strings.
; Each symbol is a type name or constant name and maps to a representation of the type or constant.
; The symbol for a types t1 that is a direct child of t2 is "t1:t2"
; This should be okay as per RFC45906, which states that the only special character allowed in XDR identifiers is "_".
; See https://datatracker.ietf.org/doc/html/rfc4506#section-6.2

; TODO Think about what we want in the type representations. We'll use this to generate Rosette grammars, but also to generate infrastructure to make it convenient to write a spec of the transaction-processing code.

(define (ks-v-assoc->hash ks-v-assoc)
  (define (ks-v->hash ks-v)
    (for/hash ([k (car ks-v)])
      (values k (cdr ks-v))))
  (for/fold ([h (hash)])
            ([ks-v ks-v-assoc])
    (hash-union h (ks-v->hash ks-v))))

(module+ test
  (define-test-suite ks-v-assoc->hash/test
    (check-equal?
     (ks-v-assoc->hash
      '(((a b) . c) ((d) . e)))
     #hash((a . c) (b . c) (d . e)))))

(define (add-scope scope str)
  (if scope (format "~a:~a" scope str) str))

(define base-types
  (list "int" "unsigned int" "hyper" "unsigned hyper" "double" "quadruple" "float"))
(define (base-type? t)
  (member t base-types))

; Another try.
; We assume that only top-level type and constant definition can subsequently be reffered to, except when an enum is defined inside the specification of a tagged union.
; We also assume that there are no constant-name clashes even if we merge all scopes.
; First pass just puts all top-level declarations into a hash map and does some minor processing.
; TODO Second pass that resolves everything
(define (syntax->symbol stx)
  (syntax-parse stx
    [s:string (syntax-e #'s)]))
(define-syntax-class base-type
  #:description "a base type"
  [pattern t:string
           #:fail-when (not (base-type? (syntax-e #'t))) (format "not a base type: ~a" (syntax-e #'t))
           #:attr repr (syntax->symbol #'t)])
(define-syntax-class identifier
  #:description "an identifier"
  [pattern i:string
           #:attr repr (syntax->symbol #'i)])
(define-syntax-class constant
  #:description "a constant"
  [pattern (~or*
            (~and (~var n number) (~bind [repr (syntax-e #'n)]))
            (~and (~var i identifier) (~bind [repr (attribute i.repr)])))])
; opaque fixed-length array
(define-syntax-class opaque-fixed-length-array
  #:description "an opaque fixed-length array"
  [pattern ((~datum fixed-length-array) "opaque" (~var nbytes constant))
           #:attr repr `(opaque-fixed-length-array . ,(syntax-e #'nbytes))])
; opaque variable-length array
(define-syntax-class opaque-variable-length-array
  #:description "an opaque variable-length array"
  [pattern ((~datum variable-length-array) "opaque" (~var nbytes constant))
           #:attr repr `(opaque-variable-length-array . ,(syntax-e #'nbytes))])
; fixed-length array
(define-syntax-class fixed-length-array
  #:description "a fixed-length array"
  [pattern ((~datum fixed-length-array) (~or* elem-type:identifier elem-type:base-type) (~var n constant)) ; TODO elem-type could be a nested type specification
           #:fail-when (equal? (syntax-e #'elem-type) "opaque") "should be non-opaque"
           #:attr repr `(fixed-length-array ,(attribute elem-type.repr) . ,(syntax-e #'n))])
; variable-length array
(define-syntax-class variable-length-array
  #:description "a variable-length array"
  [pattern ((~datum variable-length-array) (~or* elem-type:identifier elem-type:base-type) constant)  ; TODO elem-type could be a nested type specification
           #:fail-when (equal? (syntax-e #'elem-type) "opaque")  "should be non-opaque"
           #:attr repr `(variable-length-array ,(attribute elem-type.repr) . ,(syntax-e #'nbytes))])
; all arrays
(define-syntax-class array
  #:description "an array"
  [pattern (~or* a:opaque-fixed-length-array a:opaque-variable-length-array a:fixed-length-array a:variable-length-array)
           #:attr repr (attribute a.repr)])
; string
(define-syntax-class xdr-string
  [pattern ((~datum string) (~var nbytes constant))
           #:attr repr (list 'string (syntax-e #'nbytes))])
; one variant of a union:
(define-syntax-class case-spec
  #:description "a case specification inside a union-type specification"
  [pattern ((~or* ((~var tag-val constant) ...) (~datum else)) (~or* d:type-decl d:void)) ; NOTE here we must support inline type declarations (occurs in Stellar XDR)
           #:fail-when (and (not (string? (attribute d.repr))) (eq? (car (attribute d.repr)) 'enum)) "inline enum-type declaration not supported"
           #:attr repr (let ([vals (if (attribute tag-val) (attribute tag-val.repr) '(else))])
                         (if (equal? (syntax-e #'d) "void")
                             `(,vals . "void")
                             (let ([accessor (if (attribute d.symbol) (attribute d.symbol) 'void)]
                                   [type-repr (attribute d.repr)])
                               `(,vals ,accessor . ,type-repr))))])
; a union specification:
(define-syntax-class union-spec
  #:description "a union-type specification"
  [pattern ((~datum union)
            ((~datum case) (~var tag-decl type-decl)
                           (~var v case-spec) ...))
           #:fail-when (not (string? (attribute tag-decl.repr))) "inline type specification in union tag-type is not supported"; TODO: in theory the tag type could be an inline type specification but we exclude this case for now
           #:fail-when (and (base-type? (attribute tag-decl.repr)) (member '(else) (map car (attribute v.repr)))) "int or unsigned int as tag type not supported when there is an else variant"
           #:attr repr `(union (,(attribute tag-decl.symbol) . ,(attribute tag-decl.repr)) ,(ks-v-assoc->hash (attribute v.repr)))])
; struct
(define-syntax-class struct-spec
  #:description "a struct-type specification"
  [pattern ((~datum struct) (~var d type-decl) ...)
           #:attr repr `(struct ,(zip (attribute d.symbol) (attribute d.repr)))]) ; this is a list because we need to preserve the order
; enum
(define-syntax-class enum-spec
  #:description "an enum-type specification"
  [pattern ((~datum enum) (ident:identifier v:number) ...) ; TODO v0 could be any constant
           #:attr repr `(enum ,@(zip (attribute ident.repr) (map syntax-e (syntax->list #'(v ...)))))])
; arbitrary type declaration:
(define-splicing-syntax-class splicing-type-decl
  #:description "a spliced type declaration"
  [pattern (~commit (~seq s:string #;(~fail #:when (equal? (syntax-e #'s) "void")) ; void thing needed?
                 (~or* t:base-type
                       t:identifier
                       t:array
                       t:xdr-string
                       t:union-spec
                       t:struct-spec
                       t:enum-spec)))
           #:attr symbol (syntax->symbol #'s)
           #:attr repr  (attribute t.repr)])
(define-syntax-class void
  [pattern "void"
           #:attr repr "void"])
(define-syntax-class type-decl
  #:description "a type declaration"
  [pattern (d:splicing-type-decl)
           #:attr repr (attribute d.repr)
           #:attr symbol (attribute d.symbol)])
; define-type:
(define-syntax-class type-def
  #:description "the definition of a type"
  [pattern (~commit ((~datum define-type) d:splicing-type-decl))
           #:attr kv `(,(attribute d.symbol) . ,(attribute d.repr))])
; define-constant:
(define-syntax-class const-def
  #:description "the definition of a constant"
  [pattern ((~datum define-constant) s:identifier n:number) ; TODO: n could be another constant
           #:attr kv `(,(attribute s.repr) . ,(syntax-e #'n))])
; a sequence of definitions:
(define-syntax-class defs
  #:description "a sequence of definitions of types and constants"
  [pattern ((~or* d:type-def d:const-def) ...)
           #:attr h (hash-union bool (make-immutable-hash (attribute d.kv)))])
(define bool ; bool is pre-defined
  (hash "bool"  '(enum ("TRUE" . 1) ("FALSE" . 0))))

(define (parse-ast stx)
  (syntax-parse stx
    [s:defs (attribute s.h)]))

;tests
(module+ test
  (define-test-suite parse-ast/test
    (test-case
     "Opaque array with non-primitive element type"
     (check-equal?
      (parse-ast
       #'((define-type
            "uint256"
            (fixed-length-array "opaque" 32))
          (define-type
            "my-array"
            (fixed-length-array "uint256" 2))))
      '#hash(("bool" . (enum ("TRUE" . 1) ("FALSE" . 0))) ("my-array" . (fixed-length-array "uint256" . 2)) ("uint256" . (opaque-fixed-length-array . 32)))))

    (test-case
     "XDR union"
     (check-equal?
      (parse-ast
       #'((define-type
            "uint256"
            (fixed-length-array "opaque" 32))
          (define-type
            "my-array"
            (fixed-length-array "uint256" 2))
          (define-type
            "PublicKeyType"
            (enum ("PUBLIC_KEY_TYPE_ED25519" 0) ("OTHER_PUBLIC_KEY_TYPE" 1)))
          (define-type
            "PublicKey"
            (union (case ("type" "PublicKeyType")
                     (("PUBLIC_KEY_TYPE_ED25519" "SOMETHING") ("ed25519" "uint256"))
                     (("OTHER_PUBLIC_KEY_TYPE") ("array2" "my-array"))
                     (("TAG") "void")
                     (else ("my-int" "int")))))))
      '#hash(("PublicKey" . (union ("type" . "PublicKeyType")
                                   #hash((else . ("my-int" . "int"))
                                         ("OTHER_PUBLIC_KEY_TYPE" . ("array2" . "my-array"))
                                         ("PUBLIC_KEY_TYPE_ED25519" . ("ed25519" . "uint256"))
                                         ("SOMETHING" . ("ed25519" . "uint256"))
                                         ("TAG" . "void"))))
             ("PublicKeyType" . (enum ("PUBLIC_KEY_TYPE_ED25519" . 0) ("OTHER_PUBLIC_KEY_TYPE" . 1)))
             ("bool" . (enum ("TRUE" . 1) ("FALSE" . 0)))
             ("my-array" . (fixed-length-array "uint256" . 2))
             ("uint256" . (opaque-fixed-length-array . 32)))))
   
    (test-case
     "XDR union, int tag, and else variant"
     (check-exn exn:fail?
                (λ ()
                  (parse-ast
                   #'((define-type
                        "test-union" (union (case ("type" "int") (else "void")))))))))

    (test-case
     "Enum referring to other enum"
     (check-exn exn:fail?
                (λ ()
                  (parse-ast
                   #'((define-type
                        "enum-1"
                        (enum ("val-1" 1) ("val-2" 2)))
                      (define-type
                        "enum-2"
                        (enum ("x" "val-1") ("y" "val-2"))))))))

    (test-case
     "int"
     (check-equal?
      (parse-ast
       #'((define-type
            "my-int" "int")))
      '#hash(("bool" . (enum ("TRUE" . 1) ("FALSE" . 0))) ("my-int" . "int"))))
   
    (test-case
     "bool"
     (check-equal?
      (parse-ast
       #'((define-type
            "my-bool" "bool")
          (define-type
            "my-bool-again" "bool")))
      '#hash(("bool" . (enum ("TRUE" . 1) ("FALSE" . 0))) ("my-bool" . "bool") ("my-bool-again" . "bool"))))
      
    (test-case
     "struct"
     (check-equal?
      (parse-ast
       #'((define-type
            "AlphaNum4"
            (struct
              ("assetCode" "AssetCode4")
              ("issuer" "AccountID")
              ("array" (fixed-length-array "opaque" 32))))))
      '#hash(("AlphaNum4" . (struct (
                                     ("assetCode" . "AssetCode4")
                                     ("issuer" . "AccountID")
                                     ("array" opaque-fixed-length-array . 32))))
             ("bool" . (enum ("TRUE" . 1) ("FALSE" . 0))))))
           
    (test-case
     "Check that no exceptions are thrown"
     (check-not-exn
      (λ ()
        (parse-ast
         #'((define-type
              "ManageOfferSuccessResult"
              (struct
                ("offersClaimed"
                 (variable-length-array "ClaimAtom" #f))
                ("offer"
                 (union (case ("effect" "ManageOfferEffect")
                          (("MANAGE_OFFER_CREATED" "MANAGE_OFFER_UPDATED")
                           ("offer" "OfferEntry"))
                          (else "void"))))))))))

     (check-not-exn
      (λ ()
        (parse-ast
         #'((define-type
              "CreateAccountResult"
              (union (case ("code" "CreateAccountResultCode")
                       (("CREATE_ACCOUNT_SUCCESS") "void")
                       (else "void"))))))))
     (check-not-exn
      (λ ()
        (parse-ast
         #'((define-type
              "AlphaNum12"
              (struct
                ("assetCode" "AssetCode12")
                ("issuer" "AccountID")))
            (define-type
              "Asset"
              (union (case ("type" "AssetType")
                       (("ASSET_TYPE_NATIVE") "void"))))))))
     (check-not-exn
      (λ ()
        (parse-ast
         #'((define-constant "MASK_ACCOUNT_FLAGS" 7)
            (define-constant "MASK_ACCOUNT_FLAGS_AGAIN" 8)))))

     (check-not-exn
      (λ ()
        (parse-ast
         #'((define-type
              "uint256"
              (fixed-length-array "opaque" 32))))))
     (check-not-exn
      (λ ()
        (parse-ast
         #'((define-type
              "AlphaNum4"
              (struct
                ("assetCode" "AssetCode4")
                ("issuer" "AccountID")))))))

     (check-not-exn
      (λ ()
        (parse-ast
         #'((define-type
              "PublicKeyType"
              (enum ("PUBLIC_KEY_TYPE_ED25519" 0)))))))

     (check-not-exn
      (λ ()
        (parse-ast
         #'((define-type
              "PublicKey"
              (union (case ("type" "PublicKeyType")
                       (("PUBLIC_KEY_TYPE_ED25519")
                        ("ed25519" "uint256")))))))))
     (check-not-exn
      (λ ()
        (parse-ast
         #'((define-type "uint32" "unsigned int")))))

     (check-not-exn
      (λ ()
        (parse-ast
         #'((define-type
              "uint256"
              (fixed-length-array "opaque" 32))))))

     (check-not-exn
      (λ ()
        (parse-ast
         #'((define-type
              "uint256"
              (fixed-length-array "opaque" 32))
            (define-type
              "PublicKeyType"
              (enum ("PUBLIC_KEY_TYPE_ED25519" 0))))))))))

; See also ./guile-ast-example.rkt