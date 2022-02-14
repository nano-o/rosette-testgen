#lang racket

(provide test-grammar)
(require
  racket/match racket/syntax racket/generator
  "xdr-compiler.rkt" ;"guile-ast-example.rkt"
  (for-template rosette rosette/lib/synthax))

; TODO generate a Rosette grammar for this:
#; (hash-ref
 (stellar-symbol-table)
 "TransactionEnvelope")

; a simpler example:
(define test-ast
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
                (("PUBLIC_KEY_TYPE_ED25519") ("ed25519" "uint256")))))))

(define test-sym-table
  (parse-asts test-ast))

; Produce a syntax object defining a Rosette grammar
; Note that we need a syntax-object to use as context, provided by the macro calling this, otherwise g will be out of scope for the code that follows.
; Looks like it's better to postpone using define-grammar to the macro that will use xdr-types->grammar
#;(define (xdr-types->grammar stx-context sym-table type)
  (define (the-grammar t)
    #`[my-rule (?? (bitvector 32))])
  #`(define-grammar (#,(format-id stx-context "g")) #,(the-grammar type)))

(define (xdr-types->grammar sym-table type)
  (define get-index (generator ()
                      (let loop ([index 0])
                        (yield index)
                        (loop (+ index 1)))))
  (define (rule-id str)
    ; Rosette seems to be relying on source location information to create symbolic variable names.
    ; Since we want all grammar holes to be independent, we need to use a unique location each time.
    (format-id #f "~a-rule" str #:source (make-srcloc (format "~a-rule:~a" str (get-index)) 1 0 1 0)))
  ; Next we define a few helper functions to build grammar rules for various types.
  ; Fixed-size, non-opaque arrays are represented by vectors.
  (define (fixed-size-array type size)
    #`(vector
       #,@(datum->syntax
           #'()
           (for/list ([i (in-range size)])
             #`(#,(rule-id type))))))
  ; Enum values are represented by 32-bit words:
  (define (enum-values vs)
    (let ([values
           (map ((curry hash-ref) sym-table) vs)])
      (map (λ (v) #`(bv #,v (bitvector 32))) values)))
  ; We are going to accumulate rules in a mutable hash table
  (define rules (make-hash)) ; mutable hash table with equal? comparison
  (define (add-rule key r)
    (if (not (hash-has-key? rules key))
               (hash-set! rules key r) (void)))
  ; The main procedure:
  (define (make-rules t)
    (let ([rule-name (rule-id t)])
      (match (hash-ref sym-table t)
        ; Opaque fixed-length array. Represented by a bitvector.
        [`(opaque-fixed-length-array ,nbytes)
         (add-rule (syntax-e rule-name)
                   #`[#,rule-name (?? (bitvector #,(* nbytes 8)))])]
        ; Fixed length array. Represented by a vector.
        [`(fixed-length-array ,elem-type ,size)
         (let ([top-rule #`[#,rule-name #,(fixed-size-array elem-type size)]])
           (begin
             (add-rule (syntax-e rule-name) top-rule)
             (make-rules elem-type)))]
        ; Enum. Represented by a bitvector of size 32.
        [`(enum ,vs)
         (add-rule (syntax-e rule-name)
                   #`[#,rule-name (choose #,@(enum-values vs))])]
        ; union:
        #;[`(union ,tag-type ,variants)
         ; TODO: do we need one rule per variant and a big choose rule with all the variants? Seems so.
         ; The "else" case is a problem, and it looks like we're going to have to emit a validity predicate for that (then we'll assume this predicate holds before symbolic execution).
         #`([#,rule-name (list #,(rule-id tag-type) )])])))
  (begin
    (make-rules type)
    ; return a syntax object consisting of a list of rules, starting with the rule for type
    (let* ([top-key (syntax-e (rule-id type))]
          [top-rule (hash-ref rules top-key)]
          [rest (map (curry cdr) (filter (λ (kv) (not (equal? (car kv) top-key))) (hash->list rules)))])
      #`(#,top-rule #,@rest))))

(define (test-grammar)
  (xdr-types->grammar test-sym-table "my-array"))