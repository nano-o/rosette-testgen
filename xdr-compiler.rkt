#lang racket

; The guile-rpc parser transforms an XDR file into a list of define-type and define-constant s-exprs.
; This module provides macros that turn such an AST into a more useful, symbol-table-like data structure.

; Note that we do not handle the all possible guile-rpc ASTs, but only a super-set of those that appear in Stellar's XDR files.

(provide parse-asts)

(require
  syntax/parse syntax/parse/define racket/syntax
  racket/hash
  rackunit macro-debugger/stepper
  #;(for-syntax racket/syntax))

; First pass: a recursive syntax class, defs, that builds a symbol table.
; Each symbol is a type name and maps to the description of the type
; The symbol for a types t1 that is a direct child of t2 is t1:t2
; This should be okay as per RFC45906, which states that the only special character allowed in XDR identifiers is "_".
; See https://datatracker.ietf.org/doc/html/rfc4506#section-6.2

(begin
  (define (add-scope scope str)
    (if scope (format "~a:~a" scope str) str))
  (define-syntax-class constant
    [pattern (~or* n:number s:string)])
  ; opaque fixed-length array
  (define-syntax-class opaque-fixed-length-array
    [pattern ((~datum fixed-length-array) "opaque" (~var nbytes constant))])
  ; opaque variable-length array
  (define-syntax-class opaque-variable-length-array
    [pattern ((~datum variable-length-array) "opaque" (~var nbytes constant))])
  ; fixed-length array
  (define-syntax-class fixed-length-array
    [pattern ((~datum fixed-length-array) elem-type:string constant)]) ; TODO seems that elem-type can be an arbitrary, in-line, anonymous type
  ; variable-length array
  (define-syntax-class variable-length-array
    [pattern ((~datum variable-length-array) elem-type:string constant)]) ; TODO seems that elem-type can be an arbitrary, in-line, anonymous type
  ; all arrays
  (define-syntax-class array
    [pattern (~or* a:opaque-fixed-length-array a:opaque-variable-length-array a:fixed-length-array a:variable-length-array)])
  ; string
  (define-syntax-class xdr-string
    [pattern ((~datum string) (~var nbytes constant))])
  ; one variant of a union:
  (define-syntax-class union-variant
    #:description "a variant inside a union-type specification"
    [pattern (((~var c constant)) (accessor:string (~or* string _:(type-decl "TODO"))))]
    [pattern (((~var c constant)) "void")])
  ; a union specification:
  (define-syntax-class union
    #:description "a union-type specification"
    [pattern ((~datum union)
              ((~datum case) (tag-accessor:string type:string) ; TODO type could be an in-line type declaration
                               (~var v0 union-variant)) ...)])
  ; struct
  (define-syntax-class (struct-spec type-name)
    #:description "a struct-type specification"
    [pattern ((~datum struct) d0:(type-decl type-name) ...)
             #:attr sym-table (hash) ; TODO
             #:attr repr '()]) ; TODO
  ; enum
  (define-syntax-class (enum-spec scope)
    #:description "an enum-type specification, optionally within a scope"
    [pattern ((~datum enum) (t0:string v0:constant) ...)
             ; create one symbol for each enum value:
             #:attr sym-table (for/hash ([k (syntax-e #'(t0 ...))]
                                         [v (syntax-e #'(v0 ...))])
                                (values (add-scope scope k) v))
             ; representation is a list of symbols:
             #:attr repr (map ((curry add-scope) scope) (syntax-e #'(t0 ...)))])
  ; arbitrary spliced type declaration:
  ; TODO: only used in type-decl, so could be inlined there
  (define-splicing-syntax-class splicing-type-decl
    #:description "a spliced type declaration"
    [pattern (~seq (~var s string) (~or* t:array t:xdr-string t:union (~var t (struct-spec (syntax-e #'s))) (~var t (enum-spec (syntax-e #'s)))))
             #:attr sym-table (hash (syntax-e #'s) "t.repr")])
  ; arbitrary type declaration:
  (define-syntax-class (type-decl scope)
    #:description "a type declaration, optionally within a scope"
    [pattern (s:string (~or* t:array t:xdr-string t:union (~var t (struct-spec (syntax-e #'s))) (~var t (enum-spec (syntax-e #'s)))))
             #:attr repr (add-scope scope (syntax-e #'s))
             #:attr sym-table (hash (attribute repr) "t.repr")])
  ; define-type:
  (define-syntax-class type-def
    #:description "the definition of a type"
    [pattern ((~datum define-type) d:splicing-type-decl)
             #:attr sym-table (attribute d.sym-table)])
  ; define-constant:
  (define-syntax-class const-def
    #:description "the definition of a constant"
    [pattern ((~datum define-constant) s:string c:constant)
             #:attr sym-table (hash (syntax-e #'s) (syntax-e #'c))])
  ; a sequence of definitions:
  ; TODO: couldn't figure out how to use an ellipsis here
  (define-splicing-syntax-class splicing-defs
    #:description "a spliced sequence of definitions of type and constants"
    [pattern (~seq (~or* d0:type-def d0:const-def) ds:splicing-defs)
             #:attr sym-table (hash-union (attribute d0.sym-table) (attribute ds.sym-table))]
    [pattern (~seq (~or* d0:type-def d0:const-def))
             #:attr sym-table (attribute d0.sym-table)])
  (define-syntax-class defs
    #:description "a sequence of definitions of types and constants"
    [pattern ((~or* d:type-def d:const-def) ...)
             #:attr sym-table (apply hash-union (attribute d.sym-table))]))

(define-syntax-class my-string
  [pattern s:string
           #:attr a (syntax-e #'s)])
(define-syntax-class my-strings
  [pattern (s0:my-string ...)
           #:attr a (attribute s0.a)])
(define (test stx)
  (syntax-parse stx
    [strs:my-strings (attribute strs.a)]))
(test #'("hello" "world" ".")) ; TODO is this working?

(define (parse-asts stx)
  (syntax-parse stx 
    [ds:defs (attribute ds.sym-table)]))
(parse-asts
 #'((define-constant "MASK_ACCOUNT_FLAGS" 7)
    (define-constant "MASK_ACCOUNT_FLAGS_AGAIN" 8)))
; tests
#;(begin
  (define (parse-ast stx)
    (syntax-parse stx 
      [(~or* _:type-def _:const-def) #t]))
  (parse-ast
   #'(define-type "uint32" "unsigned int"))
  (check-equal?
   (parse-ast
    #'(define-type
        "uint256"
        (fixed-length-array "opaque" 32)))
   #t)
  (check-equal?
   (parse-ast
    #'(define-type
        "PublicKeyType"
        (enum ("PUBLIC_KEY_TYPE_ED25519" 0))))
   #t)
  (check-equal?
   (parse-ast
    #'(define-type
        "PublicKey"
        (union (case ("type" "PublicKeyType")
                 (("PUBLIC_KEY_TYPE_ED25519")
                  ("ed25519" "uint256"))))))
   #t)

  (parse-asts
   #'((define-type
        "uint256"
        (fixed-length-array "opaque" 32))
      (define-type
        "PublicKeyType"
        (enum ("PUBLIC_KEY_TYPE_ED25519" 0)))))

  (check-equal?
   (hash-ref
    (parse-asts
     #'((define-constant "MASK_ACCOUNT_FLAGS" 7)))
    "MASK_ACCOUNT_FLAGS")
   7)
  (parse-asts
   #'((define-constant "MASK_ACCOUNT_FLAGS" 7)
      (define-constant "MASK_ACCOUNT_FLAGS_AGAIN" 8)))
  ; See also ./guile-ast-example.rkt
)
; bool is predefined
#|
(define bool:TRUE 0)
(define bool:FALSE 1)
(define bool '(enum bool:TRUE bool:FALSE))
|#

; tests
#;(begin 
  (define-type "my-int" "int")
  (check-equal? my-int 'int)
  (define-type "test-type" (fixed-length-array "opaque" 32))
  (check-equal? test-type '(opaque-array 32))
  (define-type "test-type-2" "test-type")
  (check-equal? test-type-2 'test-type)
  (define-constant "test-constant" 0)
  (check-equal? test-constant 0)
  (define-type "test-enum" (enum ["test-0" "test-constant"] ["test-1" 1] ["test-2" 2]))
  (check-equal? test-enum '(enum test-enum:test-0 test-enum:test-1 test-enum:test-2))
  (define-type "test-union" (union (case ("test-union-tag" "test-enum") (("test-0") ("x" "test-type")) (("test-1") "void"))))
  (check-equal? test-union '(union ("test-union-tag" test-enum) ((test-enum:test-0 ("x" test-type)) (test-enum:test-1 void))))
  (define-type "test-struct" (struct ("member1" "test-type") ("member2" "bool")))
  (check-equal? test-struct '(struct ("member1" test-type) ("member2" bool))))