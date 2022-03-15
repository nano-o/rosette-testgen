#lang racket

(require
  (submod "generators.rkt" test)
  rackunit/text-ui)

(define (get-test-exports m)
  (let-values ([(val syn)
                (module->exports
                 (make-resolved-module-path `(,(path->complete-path (string->path m)) test)))])
    (match val
      [`((0 (,e ()) ...)) e])))

; we need the current namespace for eval:
(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))

(define (run-all m)
  (for ([test (get-test-exports m)])
    (if (regexp-match (regexp ".*/test$") (symbol->string test))
        (begin
          (println (format "running test: ~a" (symbol->string test)))
          (run-tests (eval test ns)))
        (void))))

; run all tests
(run-all "generators.rkt")