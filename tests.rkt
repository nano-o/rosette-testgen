#lang racket

(require (submod "xdr-compiler.rkt" test) "guile-ast-example.rkt" "generators.rkt"
         rackunit/text-ui)

;(run-tests generator-tests)
(run-tests parse-ast/test)
;(run-tests ks-v-assoc->hash/test)
;(run-tests hash-merge/test)
(run-tests parse-stellar-xdr/test)