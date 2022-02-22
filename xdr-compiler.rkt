#lang racket

; The guile-rpc parser transforms an XDR file into a list of define-type and define-constant s-exprs.
; This module provides macros that turn such an AST into a more useful, symbol-table-like data structure.

; Note that we do not handle the all possible guile-rpc ASTs, but only a super-set of those that appear in Stellar's XDR files.
; Notably, this does not support recursive XDR types.

(provide parse-ast
         ; TODO is there a better way to export those structs?
         (struct-out opaque-fixed-length-array-type)
         (struct-out opaque-variable-length-array-type)
         (struct-out fixed-length-array-type)
         (struct-out variable-length-array-type)
         (struct-out string-type)
         (struct-out enum-type)
         (struct-out struct-type)
         (struct-out union-type))

(require
  syntax/parse
  racket/hash list-util
  "util.rkt"
  rackunit)

(module+ test
  (require rackunit)
  (provide ks-v-assoc->hash/test parse-ast/test))

(define (ks-v->alist ks-v)
  (define (flatten-ks-v ks v)
    (for/list ([k ks])
      `(,k . ,v)))
  (flatten-one-level
   (for/list ([p ks-v])
     (match-let
       ([`(,ks . ,v) p])
       (flatten-ks-v ks v)))))

(module+ test
  (define-test-suite ks-v-assoc->hash/test
    (check-equal?
     (ks-v->alist
      '(((a b) . c) ((d) . e)))
     '((a . c) (b . c) (d . e)))))

(define (add-scope scope str)
  (if scope (format "~a:~a" scope str) str))

(define base-types
  (list "int" "unsigned int" "hyper" "unsigned hyper" "double" "quadruple" "float"))
(define (base-type? t)
  (member t base-types))

; struct types to represent XDR types
(struct opaque-fixed-length-array-type (length)  #:prefab)
(struct opaque-variable-length-array-type (max-length)  #:prefab)
(struct fixed-length-array-type (type length)  #:prefab)
(struct variable-length-array-type (type max-length)  #:prefab)
(struct string-type (length) #:prefab)
(struct enum-type (values) #:prefab)
(struct struct-type (name fields) #:prefab)
(struct union-type (tag-name tag-type variants) #:prefab)


; We assume that only top-level type and constant definition can subsequently be reffered to.
; We also assume that there are no constant-name clashes even if we merge all scopes.
; First pass just puts all top-level declarations into a hash map and does some minor processing.
(define (ns-name->string ns name)
  (let ([strs (append ns (list name))])
    (string-join strs "::")))
(define (syntax->string stx)
  (syntax-parse stx
    [s:string (syntax-e #'s)]))
(define-syntax-class base-type
  #:description "a base type"
  [pattern t:string
           #:fail-when (not (base-type? (syntax-e #'t))) (format "not a base type: ~a" (syntax-e #'t))
           #:attr repr (syntax->string #'t)])
(define-syntax-class identifier
  #:description "an identifier"
  [pattern i:string
           #:attr repr (syntax->string #'i)])
(define-syntax-class constant
  #:description "a constant"
  [pattern (~or*
            (~and (~var n number) (~bind [repr (syntax-e #'n)]))
            (~and (~var i identifier) (~bind [repr (attribute i.repr)])))])
; opaque fixed-length array
(define-syntax-class opaque-fixed-length-array
  #:description "an opaque fixed-length array"
  [pattern ((~datum fixed-length-array) "opaque" (~var nbytes constant))
           #:attr repr (opaque-fixed-length-array-type (syntax-e #'nbytes))])
(define max-array-len 4294967295)
; opaque variable-length array
(define-syntax-class opaque-variable-length-array
  #:description "an opaque variable-length array"
  [pattern ((~datum variable-length-array) "opaque" (~or* (~var nbytes constant) #f))
           #:attr repr (opaque-variable-length-array-type (if (attribute nbytes) (syntax-e #'nbytes) max-array-len))])
; fixed-length array
(define-syntax-class fixed-length-array
  #:description "a fixed-length array"
  [pattern ((~datum fixed-length-array) (~or* elem-type:identifier elem-type:base-type) n:constant) ; nested type specification in elem-type not supported
           #:fail-when (equal? (syntax-e #'elem-type) "opaque") "should be non-opaque"
           #:attr repr (fixed-length-array-type (attribute elem-type.repr) (syntax-e #'n))])
; variable-length array
(define-syntax-class variable-length-array
  #:description "a variable-length array"
  [pattern ((~datum variable-length-array) (~or* elem-type:identifier elem-type:base-type) (~or* (~var n constant) #f))  ; nested type specification in elem-type not supported
           #:fail-when (equal? (syntax-e #'elem-type) "opaque")  "should be non-opaque"
           #:attr repr (variable-length-array-type (attribute elem-type.repr) (if (attribute n) (syntax-e #'n) max-array-len))])
; all arrays
(define-syntax-class array
  #:description "an array"
  [pattern (~or* a:opaque-fixed-length-array a:opaque-variable-length-array a:fixed-length-array a:variable-length-array)
           #:attr repr (attribute a.repr)])
; string
(define-syntax-class xdr-string
  [pattern ((~datum string) (~var nbytes constant))
           #:attr repr (string-type (syntax-e #'nbytes))])
; one variant of a union:
(define-syntax-class (case-spec namespace)
  #:description "a case specification inside a union-type specification"
  [pattern ((~or* ((~var tag-val* constant) ...) (~datum else)) (~or* (~var d (type-decl namespace)) d:void-decl)) ; NOTE here we must support inline type declarations which occur in Stellar XDR (except enum, which doesn't occur in Stellar)
           #:fail-when (and (not (string? (attribute d.repr))) (enum-type? (attribute d.repr))) "inline enum-type declaration not supported"
           ; #:do ((if (and (not (string? (attribute d.repr))) (eq? (car (attribute d.repr)) 'struct)) (println (format " struct: ~a" (attribute d.repr))) (void)))
           ; #:fail-when (and (attribute tag-val) (ormap number? (map syntax-e (syntax->list #'(tag-val ...))))) "xx"
           #:attr repr (let ([vals (if (attribute tag-val*) (attribute tag-val*.repr) '(else))])
                         (if (equal? (syntax-e #'d) "void")
                             `(,vals . "void")
                             (let ([accessor (if (attribute d.symbol) (attribute d.symbol) 'void)]
                                   [type-repr (attribute d.repr)])
                               `(,vals ,accessor . ,type-repr))))])
; a union specification:
(define-syntax-class (union-spec namespace)
  #:description "a union-type specification"
  [pattern ((~datum union)
            ((~datum case) (~var tag-decl (type-decl namespace))
                           (~var v* (case-spec namespace)) ...))
           #:fail-when (not (string? (attribute tag-decl.repr))) "inline type specification in union tag-type is not supported"; NOTE: in theory the tag type could be an inline type specification but we exclude this case for now
           #:fail-when (and (base-type? (attribute tag-decl.repr)) (member '(else) (map car (attribute v*.repr)))) "int or unsigned int as tag type not supported when there is an else variant"
           #:attr repr (union-type (attribute tag-decl.symbol) (attribute tag-decl.repr) (ks-v->alist (attribute v*.repr)))])
; struct
(define-syntax-class (struct-spec namespace name)
  #:description "a struct-type specification"
  [pattern ((~datum struct) (~var d* (type-decl namespace)) ...)
           #:attr repr (struct-type name (zip (attribute d*.symbol) (attribute d*.repr)))]) ; NOTE the order is important
; enum
(define-syntax-class (enum-spec namespace)
  #:description "an enum-type specification"
  [pattern ((~datum enum) (ident*:identifier v*:number) ...) ; NOTE the only supported enum values are literal constants
           #:attr repr (enum-type (zip (attribute ident*.repr) (map syntax-e (syntax->list #'(v* ...)))))])
; arbitrary type declaration:
(define-splicing-syntax-class (splicing-type-decl namespace)
  #:description "a spliced type declaration"
  [pattern (~commit (~seq (~and s:string (~bind [new-namespace (cons (syntax-e #'s) namespace)]))
                 (~or* t:base-type
                       t:identifier
                       t:array
                       t:xdr-string
                       (~var t (union-spec (attribute new-namespace)))
                       (~var t (struct-spec (attribute new-namespace) (ns-name->string namespace (syntax-e #'s))))
                       (~var t (enum-spec (attribute new-namespace))))))
           #:attr symbol (syntax->string #'s)
           #:attr repr  (attribute t.repr)])
(define-syntax-class void-decl
  [pattern "void"
           #:attr repr "void"])
(define-syntax-class (type-decl namespace)
  #:description "a type declaration"
  [pattern ((~var d (splicing-type-decl namespace)))
           #:fail-when (enum-type? (attribute d.repr)) "nested enum type not supported"
           #:attr repr (attribute d.repr)
           #:attr symbol (attribute d.symbol)])
; define-type:
(define-syntax-class type-def
  #:description "the definition of a type"
  [pattern (~commit ((~datum define-type) (~var d (splicing-type-decl null))))
           #:attr kv `(,(attribute d.symbol) . ,(attribute d.repr))])
; define-constant:
(define-syntax-class const-def
  #:description "the definition of a constant"
  [pattern ((~datum define-constant) s:identifier n:number) ; TODO: n could be another constant
           #:attr kv `(,(attribute s.repr) . ,(syntax-e #'n))])
; a sequence of definitions:
(define-syntax-class defs
  #:description "a sequence of definitions of types and constants"
  [pattern ((~or* d*:type-def d*:const-def) ...)
           #:attr h (hash-union bool (make-immutable-hash (attribute d*.kv)))])
(define bool ; bool is pre-defined
  (hash "bool"  (enum-type '(("TRUE" . 1) ("FALSE" . 0)))))

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
      '#hash(("bool" . #s(enum-type (("TRUE" . 1) ("FALSE" . 0))))
             ("my-array" . #s(fixed-length-array-type "uint256" 2))
       ("uint256" . #s(opaque-fixed-length-array-type 32)))))

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
      '#hash(("PublicKey"
              .
              #s(union-type
                 "type"
                 "PublicKeyType"
                 (("PUBLIC_KEY_TYPE_ED25519" "ed25519" . "uint256")
                  ("SOMETHING" "ed25519" . "uint256")
                  ("OTHER_PUBLIC_KEY_TYPE" "array2" . "my-array")
                  ("TAG" . "void")
                  (else "my-int" . "int"))))
             ("PublicKeyType"
              .
              #s(enum-type
                 (("PUBLIC_KEY_TYPE_ED25519" . 0) ("OTHER_PUBLIC_KEY_TYPE" . 1))))
             ("bool" . #s(enum-type (("TRUE" . 1) ("FALSE" . 0))))
             ("my-array" . #s(fixed-length-array-type "uint256" 2))
             ("uint256" . #s(opaque-fixed-length-array-type 32)))))
   
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
      '#hash(("bool" . #s(enum-type (("TRUE" . 1) ("FALSE" . 0)))) ("my-int" . "int"))))
   
    (test-case
     "bool"
     (check-equal?
      (parse-ast
       #'((define-type
            "my-bool" "bool")
          (define-type
            "my-bool-again" "bool")))
      '#hash(("bool" . #s(enum-type (("TRUE" . 1) ("FALSE" . 0)))) ("my-bool" . "bool") ("my-bool-again" . "bool"))))
      
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
      '#hash(("AlphaNum4"
              .
              #s(struct-type
                 "AlphaNum4"
                 (("assetCode" . "AssetCode4")
                  ("issuer" . "AccountID")
                  ("array" . #s(opaque-fixed-length-array-type 32)))))
             ("bool" . #s(enum-type (("TRUE" . 1) ("FALSE" . 0)))))))
           
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