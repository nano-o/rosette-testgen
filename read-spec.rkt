#lang racket

(provide read-spec)

(define (read-all in)
  (let ([d (read in)])
    (if (equal? d eof)
        null
        (cons d (read-all in)))))

(define (read-spec file-name)
  (call-with-input-file file-name
    (lambda (in)
      (read-all in))))