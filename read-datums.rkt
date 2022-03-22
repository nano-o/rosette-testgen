#lang racket

; read a list of datums from a file
(provide read-datums)

(define (read-all in)
  (let ([d (read in)])
    (if (equal? d eof)
        null
        (cons d (read-all in)))))

(define (read-datums file-name)
  (call-with-input-file file-name
    (lambda (in)
      (read-all in))))