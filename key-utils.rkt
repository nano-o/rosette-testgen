#lang racket

(require
  (only-in rosette bv integer->bitvector bitvector extract concat bveq)
  (only-in list-util zip))
(provide strkey->bv)

; NOTE
; don't use the bv package, it's buggy:
; (bveq (bv #x3f0c34bf93adf121 64)
;       (bv #x3f0c34bf93adf121 64))
; ;=> #f


(define value-encoding
  (zip
   '(#\A #\B #\C #\D #\E #\F #\G #\H #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R #\S #\T #\U #\V #\W #\X #\Y #\Z #\2 #\3 #\4 #\5 #\6 #\7)
   (range 32)))

(define (char->bv c)
  (integer->bitvector (dict-ref value-encoding c) (bitvector 5)))

(define (strkey->bv k)
  (extract (- 280 9) 16
           (apply concat
                  (map char->bv (string->list k)))))

(module+ test
  (require rackunit)
  (define/provide-test-suite strkey->bv/test
    (test-case
     "example from https://github.com/stellar/stellar-protocol/blob/master/ecosystem/sep-0023.md"
     (begin
       (define test-strkey "GA7QYNF7SOWQ3GLR2BGMZEHXAVIRZA4KVWLTJJFC7MGXUA74P7UJVSGZ")
       (check-equal?
        (bveq
         (strkey->bv test-strkey)
         (bv #x3f0c34bf93ad0d9971d04ccc90f705511c838aad9734a4a2fb0d7a03fc7fe89a 256))
        #t)))))