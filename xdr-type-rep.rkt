#lang rosette

(require racket/match rosette/lib/synthax)

; Example guile-rpc AST:
(define ast
  #'((define-type
      "uint256"
      (fixed-length-array "opaque" 32))
    (define-type
      "PublicKeyType"
      (enum ("PUBLIC_KEY_TYPE_ED25519" 0)))
    (define-type
      "PublicKey"
      (union (case ("type" "PublicKeyType")
               (("PUBLIC_KEY_TYPE_ED25519")
                ("ed25519" "uint256")))))))

; Now we want a basic compiler that transforms this into a more friendly data-structure.
; E.g. type names become symbols that are bound to their type descriptor.
; This data structure will be used at compile-time.
; For example:
(define uint256 '(opaque-array 32))
(define PublicKeyType:PUBLIC_KEY_TYPE_ED25519 0)
(define PublicKeyType
  '(enum PublicKeyType:PUBLIC_KEY_TYPE_ED25519))
(define PublicKey
  '(union (type PublicKeyType)
          [PublicKeyType:PUBLIC_KEY_TYPE_ED25519 (PublicKey:ed25519 uint256)]))
; Is it better to use 

(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))
(eval 'PublicKeyType:PUBLIC_KEY_TYPE_ED25519 ns)

; Then, we'll need to produce a rosette grammar for a given type.
; Each type is a production
(define (type-rep->grammar-rules type)
  (match type
    [(list 'opaque-array n) #`(?? (bitvector #,n))]
    [(list 'enum val ...) #`(choose #,@(map (λ (x) (bv (eval x ns) 32)) val))]
    [(list 'union (list tag-name tag-type) variant ...)
     #`(choose
        #,@(map
            (match-lambda
              [(list tag (list field type))
               #`(cons #,(eval tag ns) #,(type-rep->grammar-rules (eval type ns)))]) ; TODO: here we need just the name of the rule; then add the rule after.
            variant))]))

; Let's try with a syntax class!

; This is the result we'd want:
(define-grammar (g)
  [PublicKey-rule
   (cons 0 (uint256-rule))]
  [uint256-rule
   (?? (bitvector 32))])

;(type-rep->grammar-rules PublicKey)

#;(define test
  (syntax->datum (type-rep->grammar-rules PublicKey)))

(define sol
  (synthesize
   #:forall '()
   #:guarantee (assert (equal? (g #:depth 2) (cons 0 (bv 1 32))))))

(generate-forms sol)