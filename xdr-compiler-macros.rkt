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
