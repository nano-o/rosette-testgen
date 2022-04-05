#lang racket

; TODO rename this file

(require shell/pipeline)
(provide sign tx/guile-rpc->base64  ledger/guile-rpc->base64)

(define docker-image "testgen-utils:latest")

; -i has to be quoted or Racket reads it as a complex number:
(define docker-run-prefix `(docker run "-i" --rm ,docker-image))

(define (xdr/guile-rpc->base64 datum type)
  (run-subprocess-pipeline/out
   `(,(λ () (write datum))) ; write as datum that can be read back by a guile script
   `(,@docker-run-prefix serialize.sh ,type)))

(define (tx/guile-rpc->base64 tx)
  (xdr/guile-rpc->base64 tx "TransactionEnvelope"))

(define (ledger/guile-rpc->base64 ledger)
  (xdr/guile-rpc->base64 ledger "TestLedger"))

; Sign a transaction using stc in a ephemeral docker container
(define (sign base64-tx private-key)
  (let ([output
          (run-subprocess-pipeline/out
           `(,(λ () (printf "~a" base64-tx)))
           `(,@docker-run-prefix sign.sh ,private-key))])
    (string-trim output "\n")))

(module+ test
  (require rackunit)
  (define/provide-test-suite sign/test
    (test-case
     "serialize and sign a transaction"
     ; some test data
     (define priv "SCI3M6F4CNX6A4RBPGZDJDYZGZSEF7ILYZJRT2FMXH3IYEQAHGYPWSBU")
     (define scm-tx '(ENVELOPE-TYPE-TX ((KEY-TYPE-ED25519 44 116 101 211 153 7 145 197 247 66 94 199 157 227 123 109 182 170 88 99 83 127 201 141 20 216 160 78 16 173 253 84) 0 0 (FALSE . void) (MEMO-RETURN 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0) #(((FALSE . void) (CREATE-ACCOUNT (PUBLIC-KEY-TYPE-ED25519 154 45 129 241 229 195 238 19 247 0 205 78 165 37 151 211 171 98 169 138 169 253 207 0 156 47 109 174 50 121 132 134) 10000000))) (0 . void)) #()))
     (define signed-tx "AAAAAgAAAAAsdGXTmQeRxfdCXsed43tttqpYY1N/yY0U2KBOEK39VAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAmi2B8eXD7hP3AM1OpSWX06tiqYqp/c8AnC9trjJ5hIYAAAAAAJiWgAAAAAAAAAABEK39VAAAAECgKT1XbANJwFUUG7wUc2szI6JrJNMWtWKCGoEkVBZHNSCpXUmFkyP5TiIADnQHaVGvM59ixpIqNE/YP6MMYu8D")
     (check-equal?
      (sign (tx/guile-rpc->base64 scm-tx) priv) signed-tx))))
      
