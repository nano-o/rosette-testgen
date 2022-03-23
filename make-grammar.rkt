#lang racket

; provides the make-grammar macro
; TODO not sure how to interface with x-txrep.

(require (for-syntax "grammar-generator.rkt" "read-datums.rkt" "txrep-test.rkt" racket/set) syntax/parse/define)

(provide make-grammar)

(define-syntax-parser make-grammar
  [(_ (~seq #:xdr-types file:string) (~seq #:types t*:string ...))
   (let* ([xdr-types (read-datums (syntax-e #'file))]
         [max-depth-hash (max-depth xdr-types)])
     (for ([t (syntax->datum #'(t* ...))])
       (displayln (format "max-depth for type ~a is ~a" t (hash-ref max-depth-hash t))))
     ; overrides is provided by txrep-test.rkt:
      (xdr-types->grammar xdr-types overrides this-syntax (list->set (syntax->datum #'(t* ...)))))])