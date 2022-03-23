#lang rosette


(require "make-grammar.rkt" macro-debugger/expand macro-debugger/stepper)

;(pretty-display (syntax->datum
;(expand-only #'
(make-grammar #:xdr-types "Stellar.xdr-types" #:types "TestCase")
;(list #'make-grammar))))
(symbolics (the-grammar #:depth 16 #:start TestCase-rule))
