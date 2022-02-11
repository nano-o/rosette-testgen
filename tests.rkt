#lang racket

(require "xdr-compiler.rkt" "guile-ast-example.rkt" "generators.rkt"
         rackunit)

(run-test generator-tests)
(run-test parse-asts-tests)
(run-test ks-v-assoc->hash-tests)
(run-test stellar-xdr-tests)