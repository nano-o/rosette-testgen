#lang racket

(require "xdr-compiler.rkt" "guile-ast-example.rkt" rackunit)

(run-test parse-asts-tests)
(run-test ks-v-assoc->hash-tests)
(run-test stellar-xdr-tests)