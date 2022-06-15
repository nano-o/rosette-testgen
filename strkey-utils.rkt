#lang racket

(require
  (only-in rosette bv integer->bitvector bitvector extract concat bveq)
  (only-in list-util zip))
(provide strkey->bv get-private-key)

;; NOTE
;; don't use the bv package, it's buggy:
;; (bveq (bv #x3f0c34bf93adf121 64)
;;       (bv #x3f0c34bf93adf121 64))
;; ;=> #f

;; Stellar's strkey relies on base32 encoding

(define value-encoding
  (make-hash
    (zip
      '(#\A #\B #\C #\D #\E #\F #\G #\H #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R #\S #\T #\U #\V #\W #\X #\Y #\Z #\2 #\3 #\4 #\5 #\6 #\7)
      (range 32))))

(define (base32-char? c)
  (hash-has-key? value-encoding c))

(define (strkey? k)
  (and
    (string? k)
    (equal? (string-length k) 56)
    (for/and ([c (in-string k)])
      (hash-has-key? value-encoding c))))

(define/contract (char->bv c)
  (-> base32-char? (bitvector 5))
  (integer->bitvector (dict-ref value-encoding c) (bitvector 5)))

(define/contract (strkey->bv k)
  (-> strkey? (bitvector 256))
  ; A strkey string consists of 56 characters, each encoding a 5-bit word.
  ; The first byte of the decoded bitvector encodes the key type and the last 2 bytes are checksum bytes.
  ; So, to obtain the key bits, we remove the first and last 2 bytes.
  ; Note that bit 0 is the least-significant bit in rosette's bitvector library.
  ; TODO: this is wrong for multiplexed addresses
  (define all-bits
    (apply concat (map char->bv (string->list k))))
  (extract (- 280 9) 16 all-bits))

(define/contract (get-private-key d pub/bv)
  (-> dict? (bitvector 256) strkey?)
  ; given a dict mapping public strkeys to private strkeys
  ; given a bitvector pub/bv of size 256
  ; return the corresponding private strkey
  (define res
    (for/list
      ([(pub/strkey priv/strkey) (in-dict d)]
       #:when (equal? (strkey->bv pub/strkey) pub/bv))
      priv/strkey))
  (match res
    [(list r) r]
    [else (error "no match or multiple matches")]))

(module+ test
  (require rackunit)
  (test-case
    "example from https://github.com/stellar/stellar-protocol/blob/master/ecosystem/sep-0023.md"
    (begin
      (define test-strkey "GA7QYNF7SOWQ3GLR2BGMZEHXAVIRZA4KVWLTJJFC7MGXUA74P7UJVSGZ")
      (check-equal?
        (bveq
          (strkey->bv test-strkey)
          (bv #x3f0c34bf93ad0d9971d04ccc90f705511c838aad9734a4a2fb0d7a03fc7fe89a 256))
        #t)))
  (test-case
    "get private-key"
    (define pub-priv-dict
      '(("GA57G3YN5GEA5AF7YI2ZMNCKKAOQNAPYGDDIAVGSH7ILWRET6Y76SEIP" . "SCYRMXBWVYYI2XAU5PJ6MDDEUVKNJGJJVQKEBZLS4WK6NL7OHKC6OBLP")
        ("GCNC3APR4XB64E7XADGU5JJFS7J2WYVJRKU73TYATQXW3LRSPGCIN2PJ" . "SAQ33Q6B22DXMYUXXYGUUIO56YBRAAY47KTYJ4J55MW5J3TYYZFU4N4J")
        ("GAWHIZOTTEDZDRPXIJPMPHPDPNW3NKSYMNJX7SMNCTMKATQQVX6VJFNV" . "SCI3M6F4CNX6A4RBPGZDJDYZGZSEF7ILYZJRT2FMXH3IYEQAHGYPWSBU")))
    (check-equal?
      (get-private-key pub-priv-dict (strkey->bv "GCNC3APR4XB64E7XADGU5JJFS7J2WYVJRKU73TYATQXW3LRSPGCIN2PJ"))
      "SAQ33Q6B22DXMYUXXYGUUIO56YBRAAY47KTYJ4J55MW5J3TYYZFU4N4J")))
