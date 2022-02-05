#lang racket

; This module provides macros define-type and define-constant.
; Those macros define symbols for each defined type and constant.
; Each symbol corresponds to an XDR type or constant (including enum values) and is bound to its description.

; Note that we create names containing ":". This should be okay as per RFC45906, which states that the only special character allowed in XDR identifiers is "_".
; See https://datatracker.ietf.org/doc/html/rfc4506#section-6.2

(provide define-type define-constant bool bool:TRUE bool:FALSE (all-from-out racket))

(require
  syntax/parse/define macro-debugger/stepper rackunit
  (for-syntax racket/syntax))

(begin-for-syntax
  ; matches a string t, creates the identifier 't
  (define-syntax-class identifier
    [pattern t:string
             #:attr repr (format-id #'t "~a" (syntax-e #'t))])
  (define base-types
    (list "int" "unsigned int" "hyper" "unsigned hyper" "double" "quadruple" "float"))
  (define (base-type? t)
    (member t base-types))
  ; a base type:
  (define-syntax-class base-type
    [pattern t:identifier
             #:fail-when (not (base-type? (syntax-e #'t))) (format "not a base type: ~a" (syntax-e #'t))
             #:attr repr #'t.repr])
  ; matches either a literal constant or an string t, in which case it creates the identifier 'scope:t if scope is not #f and otherwise 't:
  (define-syntax-class (constant scope)
    [pattern n:number ; TODO: hex numbers
             #:attr repr #'n]
    [pattern (~var s (scoped-identifier scope)) ; TODO: can we check it's a constant?
             #:fail-when (not (identifier-binding #'s.repr)) (format "~a is not defined" (syntax-e #'s.repr))
             #:attr repr #'s.repr])
  ; opaque fixed-length array
  (define-syntax-class opaque-fixed-length-array
    [pattern ((~literal fixed-length-array) "opaque" (~var nbytes (constant #f)))
             #:attr repr #'(opaque-array nbytes.repr)])
  ; opaque variable-length array
  (define-syntax-class opaque-variable-length-array
    [pattern ((~literal variable-length-array) "opaque" (~var nbytes (constant #f)))
             #:attr repr #'(opaque-variable-length-array nbytes.repr)])
  ; variable-length array
  (define-syntax-class variable-length-array
    [pattern ((~literal variable-length-array) elem-type:identifier (~var nbytes (constant #f)))
             #:attr repr #'(variable-length-array elem-type.repr nbytes.repr)])
  ; string
  (define-syntax-class xdr-string
    [pattern ((~literal string) (~var nbytes (constant #f)))
             #:attr repr #'(string nbytes.repr)])
  ; either a base type, a type identifier, or an array
  (define-syntax-class simple-type
    [pattern (~or* t:base-type t:opaque-fixed-length-array t:opaque-variable-length-array t:variable-length-array t:identifier t:xdr-string)
             #:attr repr #'t.repr])
  ; matches a string t, creates the identifier 'scope:t:
  (define-syntax-class (scoped-identifier scope)
    [pattern t:string
             #:attr repr (if
                          (or (not scope) (base-type? scope))
                          (format-id #'t "~a" (syntax-e #'t))
                          (format-id #'t "~a:~a" scope (syntax-e #'t)))])
  ; one variant of a union:
  (define-syntax-class (union-variant-spec scope)
    [pattern (((~var c (constant scope))) (accessor:string t:identifier))
             #:attr repr #'(c.repr (accessor t.repr))]
    [pattern (((~var c (constant scope))) "void")
            #:attr repr #'(c.repr void)])
  ; a union specification:
  (define-syntax-class union-spec
    [pattern ((~literal union)
              ((~literal case) (tag-accessor:string type:identifier)
                               (~var v0 (union-variant-spec (syntax->datum #'type))) ...))
             #:attr repr #'(union (tag-accessor type.repr) (v0.repr ...))]))

(define-syntax-parser define-constant
  [(_ s:identifier (~var c (constant #f)))
   #'(define s.repr c.repr)])

(define-syntax-parser define-type
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
(define bool:TRUE 0)
(define bool:FALSE 1)
(define bool '(enum bool:TRUE bool:FALSE))

; tests
(begin 
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