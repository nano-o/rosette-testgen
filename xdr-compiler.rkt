#lang racket

; This module provides macros define-type and define-constant.
; Those macros define symbols for each defined type and constant.
; Each symbol corresponds to an XDR type or constant (including enum values) and is bound to its description.

; Note that we create names containing ":". This should be okay as per RFC45906, which states that the only special character allowed in XDR identifiers is "_".
; See https://datatracker.ietf.org/doc/html/rfc4506#section-6.2

(provide define-type (all-from-out racket))

(require
  syntax/parse/define macro-debugger/stepper rackunit
  (for-syntax racket/syntax))

(begin-for-syntax
  (define base-types (list "int" "unsigned int" "hyper" "unsigned hyper" "bool" "double" "quadruple" "float"))
  (define (base-type? t)
    (member t base-types))
  (define-syntax-class base-type
    [pattern t:string/symbol
             #:fail-when (not (base-type? (syntax-e #'t))) (format "not a base type: ~a" (syntax-e #'t))
             #:attr symbol #'t.symbol])
  (define-syntax-class string/symbol
    [pattern t:string
             #:attr symbol (format-id #'t "~a" (syntax-e #'t))])
  (define-syntax-class (string/scoped-symbol scope)
    [pattern t:string
             #:attr symbol (if scope (format-id #'t "~a:~a" scope (syntax-e #'t)) (format-id #'t "~a" (syntax-e #'t)))])
  (define-syntax-class opaque-fixed-length-array
    [pattern ((~literal fixed-length-array) "opaque" nbits:nat)])
  (define-syntax-class opaque-variable-length-array
    [pattern ((~literal variable-length-array) "opaque" nbits:nat)])
  (define-syntax-class (constant scope)
    [pattern n:number
             #:attr value #'n]
    [pattern (~var s (string/scoped-symbol scope))
             #:fail-when (not (identifier-binding #'s.symbol)) (format "~a is not defined" (syntax-e #'s.symbol))
             #:attr value #'s.symbol])
  (define-syntax-class (union-variant-spec scope)
    [pattern (((~var c (constant scope))) (accessor:string t:string/symbol))
             #:attr descr #'(c.value (accessor t.symbol))]
    [pattern (((~var c (constant scope))) ("void"))
            #:attr descr #'(c.value 'void)])
  (define-syntax-class union-spec
    [pattern ((~literal union)
              ((~literal case) (tag-accessor:string type:string/symbol)
                               (~var v0 (union-variant-spec (syntax->datum #'type))) ...))
             #:attr variants #'(v0.descr ...)
             #:attr tag-type #'type.symbol]))

(define-syntax-parser define-constant
  [(_ s:string/symbol (~var c (constant #f)))
   #'(define s.symbol c.value)])

(define-syntax-parser define-type
  ; base types
  [(_ t:string/symbol b:base-type)
   #'(define t.symbol 'b.symbol)]
  ; type alias
  [(_ t1:string/symbol t2:string/symbol)
   #'(define t1.symbol 't2.symbol)]
  ; fixed-length opaque array
  [(_ t:string/symbol a:opaque-fixed-length-array)
   #'(define t.symbol '(opaque-array a.nbits))]
  ; variable-length opaque array
  [(_ t:string/symbol a:opaque-variable-length-array)
   #'(define t.symbol '(opaque-variable-array a.nbits))]
  ; enum
  ; defines a symbol for each value (prefixed by the enum-type name) and a symbol for the enum type
  [(_ t:string/symbol ((~literal enum) [(~var name0 (string/scoped-symbol (syntax->datum #'t))) (~var val0 (constant #f))] ...))
   #'(begin
       (define name0.symbol val0.value) ...
       (define t.symbol '(enum name0.symbol ...)))]
  ; union
  [(_ t:string/symbol u:union-spec)
   #'(define t.symbol
       '(union (u.tag-accessor u.tag-type) u.variants))]
  ; struct
  [(_ t:string/symbol ((~literal struct) (accessor0:string type0:string/symbol) ...))
   #'(define t.symbol
       '(struct (accessor0 type0.symbol) ...))])

; tests
(begin 
  (define-type "my-int" "int")
  (check-equal? my-int 'int)
  (define-type "test-type" (fixed-length-array "opaque" 32))
  (check-equal? test-type (list 'opaque-array 32))
  (define-type "test-type-2" "test-type")
  (check-equal? test-type-2 'test-type)
  (define-constant "test-constant" 0)
  (check-equal? test-constant 0)
  (define-type "test-enum" (enum ["test-0" "test-constant"] ["test-1" 1] ["test-2" 2]))
  (check-equal? test-enum '(enum test-enum:test-0 test-enum:test-1 test-enum:test-2))
  (define-type "test-union" (union (case ("test-union-tag" "test-enum") (("test-0") ("x" "test-type")) (("test-1") ("void")))))
  (check-equal? test-union '(union ("test-union-tag" test-enum) ((test-enum:test-0 ("x" test-type)) (test-enum:test-1 'void))))
  (define-type "test-struct" (struct ("member1" "test-type") ("member2" "bool")))
  (check-equal? test-struct '(struct ("member1" test-type) ("member2" bool))))