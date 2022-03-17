#lang racket
(require
  syntax/strip-context
  syntax/readerr)

#;(define (xdr-identifier? s)
  (regexp-match #rx"^[:alnum:][:alnum:_]*$" s))

(define (read-syntax path port)
  (define (parse-line l)
    (match-let ([(list xdr-path len) (map string-trim (string-split l "="))])
      `(,(string-split xdr-path ".") . ,(string->number len))))
  (let ([len-specs
         (filter (λ (x) (not (equal? x "")))
                 (for/list ([l (port->lines port)])
                   (if (equal? l "") l (parse-line l))))])
    (strip-context
     #`(module x-txrep-mod racket/base ; the module name seems irrelevant
         (provide spec)
         (define spec '#,len-specs)))))

(provide read-syntax)
    
  
