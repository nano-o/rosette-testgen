#lang nanopass

(require
  racket/hash
  "Stellar-nanopass.rkt"
  list-util
  racket/syntax)

(provide (all-defined-out))
 ;L0-parser normalize-unions has-nested-enum? make-consts-hashmap)

(define-language L0
  (terminals
   (identifier (i))
   (constant (c))
   (value (v)) ; an identifier or a constant
   (void (void)))
  (XDR-Spec ()
            (def* ...))
  (Def (def) ; definition
       (define-type i type-spec)
       (define-constant i c))
  (Decl (decl)
        void
        (i type-spec))
  (Spec (type-spec)
        i
        (string c)
        (variable-length-array type-spec (maybe v))
        (fixed-length-array type-spec v)
        (enum (i* c*) ...)
        (struct decl* ...)
        (union union-spec))
  (Union-Spec (union-spec) ; NOTE cannot inline in Spec because of the "case" symbol
              (case (i1 i2)
                union-case-spec* ...))
  (Union-Case-Spec (union-case-spec)
                   ((v* ...) decl)
                   (else decl)))

(define constant? number?)
(define identifier? string?)
(define (value? o) (or (constant? o) (identifier? o)))
(define (value-or-false? o) (or (constant? o) (identifier? o) (equal? o #f)))
(define (void? x) (equal? x "void"))

(define-parser L0-parser L0)

(define test-0 '((define-type "t" (union (case ("tag" "type") (("X") ("x" "tx")) (else ("y" "Y")))))))
(L0-parser test-0)

(define test-1
  '((define-type "test-union"
     (union (case ("tagname" "tagtype")
              (("A") ("c" (union (case ("tagname-2" "tagtype-2") (("X" "Y") ("x" "T"))))))
              (("B" "C") ("d" "int")))))
    (define-type "test-struct"
      (struct ("t1" (union (case ("tagname-3" "tagtype-3") (("F" "G") ("y" "T")))))))))

(L0-parser test-1)

; does not work:
; (define-language-node-counter L0-counter L0)

(define Stellar-L0 (L0-parser the-ast))

#| Example with inputs:
(define-language
  Lsrc
  (terminals (number (n)))
  (Expr (e)
        n
        (add e0 e1)
        (sub e0 e1)))

(define-pass
  eval-src : Lsrc (ir i) -> * ()
  (Expr : Expr (ir i) -> * ()
        (,n n)
        ((add ,[Expr : e i -> r0] ,[Expr : e2 i -> r1]) (+ (+ r0 r1) i))
        ((sub ,[Expr : e i -> r0] ,[Expr : e2 i -> r1]) (- r0 r1)))
  (Expr ir i))

(define-parser Lsrc-parser Lsrc)
(eval-src (Lsrc-parser '(add 1 1)) 1)
|#

; throws an exception if there are any nested enums
; NOTE we produce L0 to allow the framework to synthesis most of the rules
(define-pass throw-if-nested-enum : L0 (ir) -> L0 ()
  (Def : Def (ir) -> Def ()
       ; a top-level enum: 
       ((define-type ,i (enum (,i* ,c*) ...)) ir))
  (Spec : Spec (ir) -> Spec ()
        ((enum (,i* ,c*) ...)
         (error "enums defined inside other types are not supported"))))

(define (has-nested-enum? l0)
  (with-handlers ([exn:fail? (λ (exn) #t)])
    (begin
      (throw-if-nested-enum l0)
      #f)))

(println (has-nested-enum? (L0-parser test-1)))

(define test-2
  '((define-type "test-struct"
      (struct ("t1" (enum ("A" 1)))))))

(define test-3
  '((define-type "t1" (enum ("A" 1)))))

(println (has-nested-enum? (L0-parser test-2)))
(println (has-nested-enum? (L0-parser test-3)))


; returns a hashmap mapping top-level enum symbols and constants to values
(define-pass make-consts-hashmap : L0 (ir) -> * ()
  (XDR-Spec : XDR-Spec (ir) -> * ()
            ((,[Def : def -> h*] ...)
             (apply hash-union h*)))
  (Def : Def (ir) -> * ()
        ((define-type ,i ,[Spec : type-spec -> h]) h)
        ((define-constant ,i ,c) (hash i c)))
  (Spec : Spec (ir) -> * ()
        ((enum (,i* ,c*) ...)
         (for/hash ([i i*] [c c*])
           (values i c)))
        (else (hash))))

(define test-4
  '((define-type "test-enum" (enum ("A" 1) ("B" 2))) (define-constant "C" 3)))

(make-consts-hashmap (L0-parser test-3))

; Make constant definitions:

(define (constant-definitions stx h)
  ; expects a hashmap mapping identifiers to values
  (let ([defs
          (for/list ([(k v) (in-dict h)])
            #`(define #,(format-id stx k) #,v))])
    #`(#,@defs)))

(define Stellar-const-defs (constant-definitions #'() (make-consts-hashmap Stellar-L0)))

; Here we collect top-level enum definitions
; Returns an alist
(define-pass enum-defs : L0 (ir) -> * ()
  (XDR-Spec : XDR-Spec (ir) -> * ()
            ((,[Def : -> l*] ...) (apply append l*)))
  (Def : Def (ir) -> * ()
        ((define-type ,i (enum (,i* ,c*) ...)) `((,i . ,(zip i* c*))))
        (else '()))
  (append
   (XDR-Spec ir)
   '(("bool" . (("TRUE" . 1) ("FALSE" . 0)))))) ; bool is implicit

(define Stellar-enum-defs (enum-defs Stellar-L0))

; next we normalize union specs

(define-language L1
  (extends L0)
  (Union-Case-Spec (union-case-spec)
                   (- ((v* ...) decl)
                      (else decl))
                   (+ (v decl))))

(define (replace-else tag-decl* enum-type)
  (let* ([tags (dict-keys tag-decl*)]
         [all-tags (dict-keys enum-type)]
         [tag-decl2*
          (let* ([other-tags (set-remove tags 'else)]
                 [else-tags (set-subtract all-tags other-tags)]
                 [else-tag-decl* (for/list ([t else-tags])
                                   `(,t . ,(dict-ref tag-decl* 'else)))])
            (append (dict-remove tag-decl* 'else) else-tag-decl*))])
    tag-decl2*))

(define-pass normalize-unions : L0 (ir enum-dict) -> L1 ()
  (Union-Case-Spec : Union-Case-Spec (ir) -> * ()
                   (((,v* ...) ,[decl]) (for/list ([v v*])
                                          `(,v . ,decl)))
                   ((else ,decl) `((else . ,decl))))
  (Union-Spec : Union-Spec (ir) -> Union-Spec ()
              ((case (,i1 ,i2) ,[Union-Case-Spec : union-case-spec -> * alist*] ...)
               (let* ([tag-decl* (apply append alist*)]
                      [_ (when (and
                                (dict-has-key? enum-dict i2) ; tag type is an enum type
                                (ormap number? (dict-keys tag-decl*)))
                           (error (format "numeric tag values not allowed in a union tagged by an enum type in: ~a" ir)))]
                      [tag-decl2*
                       (if (dict-has-key? tag-decl* 'else)
                           (replace-else tag-decl* (dict-ref enum-dict i2))
                           tag-decl*)]
                      [tag* (map car tag-decl2*)]
                      [decl* (map cdr tag-decl2*)])
                 `(case (,i1 ,i2) (,tag* ,decl*) ...)))))

(define test-5
  '((define-type "my-enum" (enum ("A" 0) ("B" 1)))
    (define-type "my-union" (union (case ("tag" "my-enum") (("A") ("i" "int")) ((1) ("j" "int")))))))
(let* ([test-5-L0 (L0-parser test-5)]
      [test-5-enums (enum-defs test-5-L0)])
  (with-handlers ([exn:fail? (λ (exn) (println "okay"))])
    (normalize-unions test-5-L0 test-5-enums)))

(define Stellar-L1 (normalize-unions Stellar-L0 Stellar-enum-defs))

; Next:
; generate rules and struct-type defs

(define-language L2
  ; add path of a struct in the type hierarchy
  ; this is to generate unique Racket struct names that represent struct types
  (extends L1)
  (terminals
   (+ (path (p))))
  (Spec (type-spec)
        (- (struct decl* ...))
        (+ (struct p decl* ...))))

(define path? list?)

(define-pass add-path : L1 (ir) -> L2 ()
  (Def : Def (ir) -> Def ()
       ((define-type ,i ,[Spec : type-spec0 (list i) -> type-spec1])
        `(define-type ,i ,type-spec1)))
  (Decl : Decl (ir p) -> Decl ()) ; NOTE processors with inputs are not auto-generated, but their body is
  (Spec : Spec (ir p) -> Spec ()
        ((struct ,[Decl : decl0 p -> decl1] ...) `(struct ,(cdr p) ,decl1 ...)))
  (Union-Spec : Union-Spec (ir p) -> Union-Spec ())
  (Union-Case-Spec : Union-Case-Spec (ir p) -> Union-Case-Spec ()))

(add-path Stellar-L1)