#lang racket

(require "xdr-compiler.rkt" "guile-ast-example.rkt" "generators.rkt"
         rackunit/text-ui)

(run-tests generator-tests)
(run-tests compiler-tests)
(run-tests ks-v-assoc->hash-tests)
(run-tests stellar-xdr-tests)