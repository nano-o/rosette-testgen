#lang racket

; TODO rename this file

(require
  shell/pipeline
  "to-guile-rpc.rkt"
  "Stellar-overrides.rkt"
  "strkey-utils.rkt")
(provide serialize-tx serialize-ledger pretty-print-test)

(define docker-image "testgen-utils:latest")

(define (pretty-print-test ledger tx-envelope)
 ; here we could serialize then use xdrpp to print the result
 'TODO)

; -i has to be quoted or Racket reads it as a complex number:
(define docker-run-prefix `(docker run "-i" --rm ,docker-image))

(define (xdr/guile-rpc->base64 datum type)
  (run-subprocess-pipeline/out
   `(,(λ () (write datum))) ; write as datum that can be read back by a guile script
   `(,@docker-run-prefix serialize.sh ,type)))

; Sign a transaction using stc in a ephemeral docker container
(define (sign base64-tx private-key)
  (let ([output
          (run-subprocess-pipeline/out
           `(,(λ () (printf "~a" base64-tx)))
           `(,@docker-run-prefix sign.sh ,private-key))])
    (string-trim output "\n")))

(define (defn->base64 defn type)
  (let ([guile-rep
         (defn->guile-rpc/xdr defn)])
    (xdr/guile-rpc->base64 guile-rep type)))

(define (sign-all tx/base64 signers/bv keys)
  (for/fold ([acc tx/base64])
            ([k/bv signers/bv])
    (sign acc (get-private-key keys k/bv))))

(define (serialize-tx tx-defn signers)
  (let ([tx/base64 (defn->base64 tx-defn "TransactionEnvelope")])
    (sign-all tx/base64 signers pub-priv-dict)))

(define (serialize-ledger ledger-defn)
  (defn->base64 ledger-defn "TestLedger"))

(module+ test
  (require rackunit)
  (define keys
  '(("GCNC3APR4XB64E7XADGU5JJFS7J2WYVJRKU73TYATQXW3LRSPGCIN2PJ" . "SAQ33Q6B22DXMYUXXYGUUIO56YBRAAY47KTYJ4J55MW5J3TYYZFU4N4J")
    ("GA57G3YN5GEA5AF7YI2ZMNCKKAOQNAPYGDDIAVGSH7ILWRET6Y76SEIP" . "SCYRMXBWVYYI2XAU5PJ6MDDEUVKNJGJJVQKEBZLS4WK6NL7OHKC6OBLP")
    ("GAWHIZOTTEDZDRPXIJPMPHPDPNW3NKSYMNJX7SMNCTMKATQQVX6VJFNV" . "SCI3M6F4CNX6A4RBPGZDJDYZGZSEF7ILYZJRT2FMXH3IYEQAHGYPWSBU")))
  (define signers
    '("GCNC3APR4XB64E7XADGU5JJFS7J2WYVJRKU73TYATQXW3LRSPGCIN2PJ" "GAWHIZOTTEDZDRPXIJPMPHPDPNW3NKSYMNJX7SMNCTMKATQQVX6VJFNV"))
  (define scm-tx '(ENVELOPE-TYPE-TX ((KEY-TYPE-ED25519 44 116 101 211 153 7 145 197 247 66 94 199 157 227 123 109 182 170 88 99 83 127 201 141 20 216 160 78 16 173 253 84) 0 0 (FALSE . void) (MEMO-RETURN 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0) #(((FALSE . void) (CREATE-ACCOUNT (PUBLIC-KEY-TYPE-ED25519 154 45 129 241 229 195 238 19 247 0 205 78 165 37 151 211 171 98 169 138 169 253 207 0 156 47 109 174 50 121 132 134) 10000000))) (0 . void)) #()))
  (define/provide-test-suite sign/test
    (test-case
     "serialize and sign a transaction"
     ; some test data
     (define priv "SCI3M6F4CNX6A4RBPGZDJDYZGZSEF7ILYZJRT2FMXH3IYEQAHGYPWSBU")
     (define signed-tx "AAAAAgAAAAAsdGXTmQeRxfdCXsed43tttqpYY1N/yY0U2KBOEK39VAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAmi2B8eXD7hP3AM1OpSWX06tiqYqp/c8AnC9trjJ5hIYAAAAAAJiWgAAAAAAAAAABEK39VAAAAECtyD3qqWTm7SQ52uvlofetjivROnBB4baD66iUpOjSNlva+YKEFW6QP0CYm4rO9y8T6eWemJbEInUjUnZn9NoL")
     (check-equal?
      (sign (xdr/guile-rpc->base64 scm-tx "TransactionEnvelope") priv) signed-tx))
    (test-case
     "serialize and sign all"
     (define signed "AAAAAgAAAAAsdGXTmQeRxfdCXsed43tttqpYY1N/yY0U2KBOEK39VAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAmi2B8eXD7hP3AM1OpSWX06tiqYqp/c8AnC9trjJ5hIYAAAAAAJiWgAAAAAAAAAACMnmEhgAAAEDGPvS6/iK65PPq7tk/2dCKmJ5y1dvKW5c+ZRE+yl0roP95gnxk7hyTc3ot7Ndvx9JowiljBAg1Wh7LOZ5Z+FwIEK39VAAAAECtyD3qqWTm7SQ52uvlofetjivROnBB4baD66iUpOjSNlva+YKEFW6QP0CYm4rO9y8T6eWemJbEInUjUnZn9NoL")
     (check-equal?
      (sign-all (xdr/guile-rpc->base64 scm-tx "TransactionEnvelope") (map strkey->bv signers) keys)
      signed))))
