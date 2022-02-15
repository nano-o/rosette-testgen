#lang rosette

(require
  rosette/lib/synthax syntax/parse/define
  (for-syntax "xdr-compiler.rkt" "grammar-generator.rkt")
  macro-debugger/stepper)
  
(define-for-syntax test-ast
  #'((define-type
       "uint256"
       (fixed-length-array "opaque" 32))
     (define-type
       "my-array"
       (fixed-length-array "uint256" 2))
     (define-type
       "PublicKeyType"
       (enum ("PUBLIC_KEY_TYPE_ED25519" 0) ("OTHER_PUBLIC_KEY_TYPE" 1)))
     (define-type
       "PublicKey"
       (union (case ("type" "PublicKeyType")
                (("PUBLIC_KEY_TYPE_ED25519") ("ed25519" "uint256"))
                (("OTHER_PUBLIC_KEY_TYPE") ("array2" "my-array")))))))

(define-for-syntax (ast->grammar type)
  (let ([sym-table (parse-asts test-ast)])
    (xdr-types->grammar sym-table type)))
  
(define-syntax-parser make-grammar
  [(_ i:id t:string)
   #`(define-grammar (i) #,@(ast->grammar (syntax-e #'t)))])

#;(make-grammar g1 "my-array")

#;(define sol1
  (synthesize
   #:forall '()
   #:guarantee (assert (equal? (g1 #:depth 1) (vector (bv 2 256) (bv 1 256))))))

(make-grammar g2 "PublicKey")

(define sol2
  (synthesize
   #:forall '()
   #:guarantee (assert (equal? (g2 #:depth 6) (cons (bv 0 32) (bv 1 256))))))

(generate-forms sol2)
