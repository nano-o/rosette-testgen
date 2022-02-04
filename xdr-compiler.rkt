#lang racket

; This module reads a sequence of define-type terms and produce a symbol table. Each symbol corresponds to an XDR type, enum value, or constant, and is bound to its description.

(provide define-type (all-from-out racket))

(require
  syntax/parse/define macro-debugger/stepper
  (for-syntax racket/syntax))

(begin-for-syntax
  (define-syntax-class base-type
    [pattern (~or* "int" "unsigned int" "hyper" "unsigned hyper" "bool")])
  (define-syntax-class string/symbol
    [pattern t:string
             #:attr symbol (format-id #'t "~a" (syntax-e #'t))])
  (define-syntax-class (string/prefix-symbol prefix)
    [pattern t:string
             #:attr symbol (format-id #'t "~a:~a" prefix (syntax-e #'t))])
  (define-splicing-syntax-class base-type-binding
    [pattern (~seq t:string/symbol b:base-type)
             #:attr symbol #'t.symbol
             #:attr base-type (format-id #'b "~a" (syntax-e #'b))])
  (define-splicing-syntax-class opaque-fixed-length-array
    [pattern (~seq t:string/symbol ((~literal fixed-length-array) "opaque" nbits:nat))
             #:attr symbol #'t.symbol])
  (define-syntax-class constant
    [pattern n:number
             #:attr value #'n]
    [pattern s:string/symbol
             #:fail-when (not (identifier-binding #'s.symbol)) (format "~a is not defined" (syntax-e #'s))
             #:attr value #'s.symbol])
  (define-syntax-class union-variant-spec ; TODO: can be "void"
    [pattern ((c:constant) (accessor:string t:string/symbol))
             #:attr type #'t.symbol
             #:attr tag #'c.value])
  (define-splicing-syntax-class union-spec
    [pattern (~seq t:string/symbol
                   ((~literal union)
                    ((~literal case) (tag-accessor:string type:string/symbol)
             v0:union-variant-spec ...)))
             #:attr variants #'((v0.tag v0.accessor v0.type) ...)
             #:attr symbol #'t.symbol
             #:attr tag-type #'type.symbol]))

; the define-type macro:
(define-syntax-parser define-type
  ; base types
  [(_ b:base-type-binding)
   #'(define b.symbol 'b.base-type)]
  ; opaque array
  [(_ arr:opaque-fixed-length-array)
   #'(define arr.symbol '(opaque-array arr.nbits))]
  ; enum
  ; defines a symbol for each value (prefixed by the enum-type name) and a symbol for the enum type
  [(_ t:string/symbol ((~literal enum) [(~var name0 (string/prefix-symbol (syntax->datum #'t))) val0:constant] ...))
   #'(begin
       (define name0.symbol val0.value) ...
       (define t.symbol '(enum name0.symbol ...)))]
  ; union
  [(_ u:union-spec)
   #'(define u.symbol
       '(union (u.tag-accessor u.tag-type) u.variants))])
  ; TODO: struct

(define-syntax-parser define-constant
  [(_ s:string/symbol c:constant)
   #'(define s.symbol c.value)])

; tests
(define-type "test-type" (fixed-length-array "opaque" 32))
(define-constant "test-constant" 0)
(define-type "test-enum" (enum ["test-0" "test-constant"] ["test-1" 1] ["test-2" 2]))
(define-type "test-union" (union (case ("test-union-tag" "test-enum") (("test-enum:test-0") ("x" "test-type")))))