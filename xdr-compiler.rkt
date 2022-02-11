#lang racket

; The guile-rpc parser transforms an XDR file into a list of define-type and define-constant s-exprs.
; This module provides macros that turn such an AST into a more useful, symbol-table-like data structure.

; Note that we do not handle the all possible guile-rpc ASTs, but only a super-set of those that appear in Stellar's XDR files.

(provide parse-asts ks-v-assoc->hash-tests parse-asts-tests)

(require
  syntax/parse syntax/parse/define racket/syntax
  racket/hash list-util
  rackunit)

; First pass: a recursive syntax class, defs, that builds a symbol table where symbols are strings.
; Each symbol is a type name and maps to the description of the type
; The symbol for a types t1 that is a direct child of t2 is "t1:t2"
; This should be okay as per RFC45906, which states that the only special character allowed in XDR identifiers is "_".
; See https://datatracker.ietf.org/doc/html/rfc4506#section-6.2

; TODO Second pass that checks for references to undefined stuff

(define (ks-v-assoc->hash ks-v-assoc)
  (define (ks-v->hash ks-v)
    (for/hash ([k (car ks-v)])
      (values k (cdr ks-v))))
  (for/fold ([h (hash)])
            ([ks-v ks-v-assoc])
    (hash-union h (ks-v->hash ks-v))))

(define-test-suite ks-v-assoc->hash-tests
  (check-equal?
   (ks-v-assoc->hash
    '((("MANAGE_OFFER_CREATED" "MANAGE_OFFER_UPDATED") . "offer:offer") ((else) . void)))
   #hash((else . void) ("MANAGE_OFFER_CREATED" . "offer:offer") ("MANAGE_OFFER_UPDATED" . "offer:offer"))))
       
(begin
  (define (add-scope scope str)
    (if scope (format "~a:~a" scope str) str))
  ; base types
  (define base-types
    (list "int" "unsigned int" "hyper" "unsigned hyper" "bool" "double" "quadruple" "float"))
  (define (base-type? t)
    (member t base-types))
  (define-syntax-class base-type
    #:description "a base type"
    [pattern t:string
             #:fail-when (not (base-type? (syntax-e #'t))) (format "not a base type: ~a" (syntax-e #'t))
             #:attr repr (syntax-e (format-id #'t "~a" (syntax-e #'t)))
             #:attr sym-table (hash)
             #:attr symbol (attribute repr)])
  (define-syntax-class constant
    #:description "a constant"
    [pattern (~or* n:number s:string)])
  (define-syntax-class symbol
    #:description "a type symbol"
    [pattern s:string
             #:attr repr (syntax-e #'s)
             #:attr symbol (attribute repr)
             #:attr sym-table (hash)])
  ; opaque fixed-length array
  (define-syntax-class opaque-fixed-length-array
    #:description "an opaque fixed-length array"
    [pattern ((~datum fixed-length-array) "opaque" (~var nbytes constant))
             #:attr repr (list 'opaque-fixed-length-array (syntax-e #'nbytes))
             #:attr sym-table (hash)])
  ; opaque variable-length array
  (define-syntax-class opaque-variable-length-array
    #:description "an opaque variable-length array"
    [pattern ((~datum variable-length-array) "opaque" (~var nbytes constant))
             #:attr repr (list 'opaque-variable-length-array (syntax-e #'nbytes))
             #:attr sym-table (hash)])
  ; fixed-length array
  (define-syntax-class fixed-length-array
    #:description "a fixed-length array"
    [pattern ((~datum fixed-length-array) (~or* elem-type:symbol elem-type:base-type) (~var n constant)) ; TODO elem-type could be a type specification
             #:fail-when (equal? (syntax-e #'elem-type) "opaque") "should be non-opaque"
             #:attr repr (list 'fixed-length-array (attribute elem-type.symbol) (syntax-e #'n))
             #:attr sym-table (hash)])
  ; variable-length array
  (define-syntax-class variable-length-array
    #:description "a variable-length array"
    [pattern ((~datum variable-length-array) (~or* elem-type:symbol elem-type:base-type) constant)  ; TODO elem-type could be a type specification
             #:fail-when (equal? (syntax-e #'elem-type) "opaque")  "should be non-opaque"
             #:attr repr (list 'variable-length-array (attribute elem-type.symbol) (syntax-e #'nbytes))
             #:attr sym-table (hash)])
  ; all arrays
  (define-syntax-class array
    #:description "an array"
    [pattern (~or* a:opaque-fixed-length-array a:opaque-variable-length-array a:fixed-length-array a:variable-length-array)
             #:attr repr (attribute a.repr)
             #:attr sym-table (attribute a.sym-table)])
  ; string
  (define-syntax-class xdr-string
    [pattern ((~datum string) (~var nbytes constant))
             #:attr sym-table (hash)
             #:attr repr (list 'string (syntax-e #'nbytes))]) ; TODO what about the scope to resolve the length name?
  ; one variant of a union:
  (define-syntax-class (case-spec scope)
    #:description "a case specification inside a union-type specification"
    [pattern ((~or* ((~var tag-val constant) ...) (~datum else)) (~var d (type-decl scope)))
             #:attr sym-table (attribute d.sym-table)
             #:attr symbol (attribute d.symbol)
             #:attr tag-value (if (attribute tag-val) (syntax->datum #'(tag-val ...)) '(else))])
  ; a union specification:
  (define-syntax-class (union-spec scope)
    #:description "a union-type specification"
    [pattern ((~datum union)
              ((~datum case) (~var tag-decl (type-decl scope))
                               (~var v (case-spec scope)) ...))
             #:attr sym-table (hash-union
                               (attribute tag-decl.sym-table)
                               (apply hash-union (attribute v.sym-table)))
             #:attr repr (list 'union-spec (attribute tag-decl.symbol) (ks-v-assoc->hash (zip (attribute v.tag-value) (attribute v.symbol))))])
  ; struct
  (define-syntax-class (struct-spec scope)
    #:description "a struct-type specification"
    [pattern ((~datum struct) (~var d (type-decl scope)) ...)
             #:attr sym-table (apply hash-union (attribute d.sym-table))
             #:attr repr (list 'struct (attribute d.symbol))]) ; this is a list
  ; enum
  (define-syntax-class (enum-spec scope)
    #:description "an enum-type specification"
    [pattern ((~datum enum) (t0:string v0:constant) ...)
             ; create one symbol for each enum value:
             #:attr sym-table (for/hash ([k (syntax->datum #'(t0 ...))]
                                         [v (syntax->datum #'(v0 ...))])
                                (values (add-scope scope k) v))
             ; representation is a list of symbols:
             #:attr repr (map ((curry add-scope) scope) (syntax->datum #'(t0 ...)))])
  ; arbitrary type declaration:
  (define-splicing-syntax-class (splicing-type-decl scope)
    #:description "a spliced type declaration, optionally within a scope"
    [pattern (~seq s:string (~fail #:when (equal? (syntax-e #'s) "void")) (~bind [inner-scope (add-scope scope (syntax-e #'s))])
                       (~or* t:base-type t:symbol t:array t:xdr-string (~var t (union-spec (attribute inner-scope))) (~var t (struct-spec (attribute inner-scope))) (~var t (enum-spec (attribute inner-scope)))))
             #:attr symbol (add-scope scope (syntax-e #'s))
             #:attr repr  (attribute symbol)
             #:attr sym-table (hash-union
                               (hash (attribute symbol) (attribute t.repr))
                               (attribute t.sym-table))])
  (define-syntax-class (type-decl scope)
    #:description "a type declaration, optionally within a scope"
    [pattern "void"
             ;#:attr repr 'void
             #:attr sym-table (hash)
             #:attr symbol 'void]
    [pattern ((~var d (splicing-type-decl scope)))
             ;#:attr repr (attribute d.repr)
             #:attr sym-table (attribute d.sym-table)
             #:attr symbol (attribute d.symbol)])
  ; define-type:
  (define-syntax-class type-def
    #:description "the definition of a type"
    [pattern ((~datum define-type) (~var d (splicing-type-decl #f)))
             #:attr sym-table (attribute d.sym-table)])
  ; define-constant:
  (define-syntax-class const-def
    #:description "the definition of a constant"
    [pattern ((~datum define-constant) s:string c:constant)
             #:attr sym-table (hash (syntax-e #'s) (syntax-e #'c))])
  ; a sequence of definitions:
  (define-syntax-class defs
    #:description "a sequence of definitions of types and constants"
    [pattern ((~commit (~or* d:type-def d:const-def)) ...) ; ~commit eliminates backtracking on already matched patterns upon failure, and does in all subpatterns (it seems)
             #:attr sym-table (apply hash-union (attribute d.sym-table))]))

(define (parse-asts stx)
  (syntax-parse stx
    [ds:defs (attribute ds.sym-table)]))

;tests
(define-test-suite parse-asts-tests
 (test-case
  "Check that no exceptions are thrown"
  (check-not-exn
   (λ ()
     (parse-asts
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
     (parse-asts
      #'((define-type
           "CreateAccountResult"
           (union (case ("code" "CreateAccountResultCode")
                    (("CREATE_ACCOUNT_SUCCESS") "void")
                    (else "void"))))))))
  (check-not-exn
   (λ ()
     (parse-asts
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
     (parse-asts
      #'((define-constant "MASK_ACCOUNT_FLAGS" 7)
         (define-constant "MASK_ACCOUNT_FLAGS_AGAIN" 8)))))

  (check-not-exn
   (λ ()
     (parse-asts
      #'((define-type
           "uint256"
           (fixed-length-array "opaque" 32))))))
  (check-not-exn
   (λ ()
     (parse-asts
      #'((define-type
           "AlphaNum4"
           (struct
             ("assetCode" "AssetCode4")
             ("issuer" "AccountID")))))))

  (check-not-exn
   (λ ()
     (parse-asts
      #'((define-type
           "PublicKeyType"
           (enum ("PUBLIC_KEY_TYPE_ED25519" 0)))))))

  (check-not-exn
   (λ ()
     (parse-asts
      #'((define-type
           "PublicKey"
           (union (case ("type" "PublicKeyType")
                    (("PUBLIC_KEY_TYPE_ED25519")
                     ("ed25519" "uint256")))))))))
  (check-not-exn
   (λ ()
     (parse-asts
      #'((define-type "uint32" "unsigned int")))))

  (check-not-exn
   (λ ()
     (parse-asts
      #'((define-type
           "uint256"
           (fixed-length-array "opaque" 32))))))

  (check-not-exn
   (λ ()
     (parse-asts
      #'((define-type
           "uint256"
           (fixed-length-array "opaque" 32))
         (define-type
           "PublicKeyType"
           (enum ("PUBLIC_KEY_TYPE_ED25519" 0)))))))))

; See also ./guile-ast-example.rkt