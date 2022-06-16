#lang racket

(require
  syntax/parse/define
  (for-syntax
    "xdr-compiler.rkt"))
(provide compile-xdr)

(define-syntax-parser
  compile-xdr
  [(_ file:string (type*:string ...))
   (guile-xdr->racket this-syntax (syntax-e #'file) (syntax->datum #'(type* ...)))])

(define-syntax-parser
  make-grammar
  [(_ file:string (type*:string ...) overrides:id)
   (guile-xdr->grammar this-syntax (syntax-e #'file) (syntax->datum #'(type* ...)) (syntax-e #'overrides))])

(define-syntax-parser
  compile-xdr+grammar
  [(_ file:string (type*:string ...) overrides:id)
   (guile-xdr->racket+grammar this-syntax (syntax-e #'file) (syntax->datum #'(type* ...)) (syntax-e #'overrides))])
