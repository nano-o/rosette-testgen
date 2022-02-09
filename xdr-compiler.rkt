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
  (define-syntax-class constant
    [pattern (~or* n:number s:string)])
  ; opaque fixed-length array
  (define-syntax-class opaque-fixed-length-array
    [pattern ((~literal fixed-length-array) "opaque" (~var nbytes constant))])
  ; opaque variable-length array
  (define-syntax-class opaque-variable-length-array
    [pattern ((~literal variable-length-array) "opaque" (~var nbytes constant))])
  ; fixed-length array
  (define-syntax-class fixed-length-array
    [pattern ((~literal fixed-length-array) elem-type:string constant)]) ; TODO seems that elem-type can be an arbitrary, in-line, anonymous type
  ; variable-length array
  (define-syntax-class variable-length-array
    [pattern ((~literal variable-length-array) elem-type:string constant)]) ; TODO seems that elem-type can be an arbitrary, in-line, anonymous type
  ; all arrays
  (define-syntax-class array
    [pattern (~or* a:opaque-fixed-length-array a:opaque-variable-length-array a:fixed-length-array a:variable-length-array)])
  ; string
  (define-syntax-class xdr-string
    [pattern ((~literal string) (~var nbytes constant))])
  ; one variant of a union:
  (define-syntax-class union-variant
    #:description "a variant inside a union-type specification"
    [pattern (((~var c constant)) (accessor:string (~or* string _:(type-decl "TODO"))))]
    [pattern (((~var c constant)) "void")])
  ; a union specification:
  (define-syntax-class union
    #:description "a union-type specification"
    [pattern ((~literal union)
              ((~literal case) (tag-accessor:string type:string) ; TODO type could be an in-line type declaration
                               (~var v0 union-variant)) ...)])
  ; struct
  (define-syntax-class (struct-spec type-name)
    #:description "a struct-type specification"
    [pattern ((~literal struct) (accessor0:string type0:(type-spec type-name)) ...)])
  ; enum
  (define-syntax-class enum-spec
    #:description "an enum-type specification"
    [pattern ((~literal enum) (t:string v:constant) ...)])
  ; arbitrary spliced type declaration:
  ; TODO: only used in type-decl, so could be inline there
  (define-splicing-syntax-class splicing-type-decl
    #:description "a spliced type declaration"
    [pattern (~seq (~var s string) (~or* t:array t:xdr-string t:union (~var t (struct-spec (syntax-e #'s))) t:enum-spec))
             #:attr sym-table (hash (syntax-e #'s) "t.repr")])
  ; arbitrary type declaration:
  (define-syntax-class (type-decl scope)
    #:description "a type declaration, optionally within a scope"
    [pattern (s:string (~or* t:array t:xdr-string t:union (~var t (struct-spec (syntax-e #'s))) t:enum-spec))
             #:attr sym-table (hash (if scope (format "~a:~a" scope (syntax-e #'s)) "t.repr"))])
  ; define-type:
  (define-syntax-class type-def
    #:description "a type definition"
    [pattern ((~literal define-type) d:splicing-type-decl)
             #:attr sym-table (attribute d.sym-table)])
  ; define-constant:
  (define-syntax-class const-def
    #:description "a constant definition"
    [pattern ((~literal define-constant) s:string c:constant)
             #:attr sym-table (hash (syntax-e #'s) (syntax-e #'c))])
  ; a sequence of definitions:
  ; TODO: couldn't figure out how to use an ellipsis here
  (define-splicing-syntax-class splicing-defs
    #:description "a spliced sequence of type and constant definitions"
    [pattern (~seq (~or* d0:type-def d0:const-def) ds:splicing-defs)
             #:attr sym-table (hash-union (attribute d0.sym-table) (attribute ds.sym-table))]
    [pattern (~seq (~or* d0:type-def d0:const-def))
             #:attr sym-table (attribute d0.sym-table)])
  (define-syntax-class defs
    #:description "a sequence of type and constant definitions"
    [pattern ((~or* d0:type-def d0:const-def) ds:splicing-defs)
             #:attr sym-table (hash-union (attribute d0.sym-table) (attribute ds.sym-table))]
    [pattern ((~or* d0:type-def d0:const-def))
             #:attr sym-table (attribute d0.sym-table)]))

; tests
(define (parse-asts stx)
  (syntax-parse stx 
    [ds:defs (attribute ds.sym-table)]))
(define (parse-ast stx)
  (syntax-parse stx 
    [(~or* _:type-def _:const-def) #t]))
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
#;(parse-asts
   #'((define-constant "MASK_ACCOUNT_FLAGS" 7)
      (define-constant "MASK_ACCOUNT_FLAGS_AGAIN" 8)))
; See also ./guile-ast-example.rkt


#;(define-syntax-parser define-constant
  [(_ s:identifier (~var c constant))
   #'(define s.repr c.repr)])

#;(define-syntax-parser define-type
  ; simple types
  [(_ t1:identifier t2:simple-type)
   #'(define t1.repr 't2.repr)]
  ; base types
  [(_ t:identifier b:base-type)
   #'(define t.repr 'b.repr)]
  ; type alias
  [(_ t1:identifier t2:identifier)
   #'(define t1.repr 't2.repr)]
  ; fixed-length opaque array
  [(_ t:identifier a:opaque-fixed-length-array)
   #'(define t.repr a.repr)]
  ; variable-length opaque array
  [(_ t:identifier a:opaque-variable-length-array)
   #'(define t.repr '(opaque-variable-array a.nbytes))]
  ; enum
  ; defines a symbol for each value (prefixed by the enum-type name) and a repr for the enum type
  [(_ t:identifier ((~literal enum) [(~var name0 (scoped-identifier (syntax->datum #'t))) (~var val0 (constant #f))] ...))
   #'(begin
       (define name0.repr val0.repr) ...
       (define t.repr '(enum name0.repr ...)))]
  ; union
  [(_ t:identifier u:union-spec)
   #'(define t.repr 'u.repr)]
  ; struct
  [(_ t:identifier ((~literal struct) (accessor0:string type0:simple-type) ...)) ; TODO: all types can be nested, not just simple ones...
   #'(define t.repr
       '(struct (accessor0 type0.repr) ...))])

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