#lang nanopass

(require racket/hash)
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

#|
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
        ((add ,[Expr : e i -> r0] ,[Expr : e2 i -> r1]) (+ (+ r0 r1) 1))
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

; next we normalize union specs

(define-language L1
  (extends L0)
  (Union-Case-Spec (union-case-spec)
                   (- ((v* ...) decl)
                      (else decl))
                   (+ (v decl))))

(define (multi-alist->alist m-alist)
  (let ([kvs
         (for/list ([k (caar m-alist)])
           `(,k . ,(cdar m-alist)))])
    (if (null? (cdr m-alist))
        kvs    
        `(,@kvs ,@(multi-alist->alist (cdr m-alist))))))


(define (replace-else tag-decl*)
  (let* ([tags (dict-keys tag-decl*)]
         [tag-decl2*
          (if (set-member? tags 'else)
              (let* ([other-tags (set-remove tags 'else)]
                     [else-tags '("TODO")]
                     [else-tag-decl* (for/list ([t else-tags])
                                       `(,t . ,(dict-ref tag-decl* 'else)))])
                (append (dict-remove tag-decl* 'else) else-tag-decl*))
              tag-decl*)])
    tag-decl2*))

(define-pass normalize-unions : L0 (ir) -> L1 ()
  (Union-Case-Spec : Union-Case-Spec (ir) -> * ()
                   (((,v* ...) ,[decl]) (for/list ([v v*])
                                        `(,v . ,decl)))
                   ((else ,decl) `((else . ,decl))))
  (Union-Spec : Union-Spec (ir) -> Union-Spec ()
              ((case (,i1 ,i2) ,[Union-Case-Spec : -> * alist*] ...)
               (let* ([tag-decl2* (replace-else (apply append alist*))]
                      [tag* (map car tag-decl2*)]
                      [decl* (map cdr tag-decl2*)])
                 `(case (,i1 ,i2) (,tag* ,decl*) ...)))))

(normalize-unions (L0-parser test-1))