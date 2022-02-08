#lang racket

; The guile-rpc parser transforms an XDR file into a list of define-type and define-constant s-exprs.
; This module provides macros that turn such an AST into a more useful, symbol-table-like data structure.

; Note that we do not handle the all possible guile-rpc ASTs, but only a super-set of those that appear when parsing Stellar's XDR files.

#;(provide define-type define-constant bool bool:TRUE bool:FALSE (all-from-out racket))

(provide parse-asts)

(require
  syntax/parse syntax/parse/define racket/syntax rackunit macro-debugger/stepper
  #;(for-syntax racket/syntax))

; First pass: a recursive syntax class, type-decl, that just matches and guile-rpc AST type declaration
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
    [pattern (((~var c constant)) (accessor:string (~or* string _:type-decl)))]
    [pattern (((~var c constant)) "void")])
  ; a union specification:
  (define-syntax-class union
    [pattern ((~literal union)
              ((~literal case) (tag-accessor:string type:string) ; TODO type could be an in-line type declaration
                               (~var v0 union-variant)) ...)])
  ; struct
  (define-syntax-class struct
    [pattern ((~literal struct) (accessor0:string type0:type-decl) ...)])
  ; enum
  (define-syntax-class enum
    [pattern ((~literal enum) (t:string v:constant) ...)])
  ; arbitrary type declaration
  (define-splicing-syntax-class splicing-type-decl
    [pattern (~seq s:string (~or* t:array t:xdr-string t:union t:struct t:enum))])
  (define-syntax-class type-decl
    [pattern (s:string (~or* t:array t:xdr-string t:union t:struct t:enum))])
  (define-syntax-class type-def
    [pattern ((~literal define-type) d:splicing-type-decl)])
  (define-syntax-class const-def
    [pattern ((~literal define-constant) s:string c:constant)])
  (define-syntax-class defs
    [pattern ((~or* _:type-def _:const-def) ...)]))

; tests
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

(define (parse-asts stx)
  (syntax-parse stx 
    [defs #t]))

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