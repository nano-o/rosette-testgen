#lang racket

(provide
  compile-xdr
  make-grammar
  compile-xdr+grammar)

(require
  syntax/parse/define
  (for-syntax
    "xdr-compiler.rkt"
    "Stellar-overrides.rkt"))

(define-syntax-parser
  compile-xdr
  [(_ type*:string ...)
   (guile-xdr->racket this-syntax "Stellar.xdr-types" (syntax->datum #'(type* ...)))])

(define-syntax-parser
  make-grammar
  [(_ type*:string ...)
   (guile-xdr->grammar this-syntax "Stellar.xdr-types"  (syntax->datum #'(type* ...)) overrides)])

(define-syntax-parser
  compile-xdr+grammar
  [(_ type*:string ...)
   (guile-xdr->racket+grammar this-syntax "Stellar.xdr-types"  (syntax->datum #'(type* ...)) overrides)])
