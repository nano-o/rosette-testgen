#lang nanopass

(require racket/hash)
(provide L0-parser normalize-unions)

(define-language L0
  (terminals
   (identifier (i))
   (constant (c))
   (value (v)) ; an identifier or a constant
   (value-or-false (vf))
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
        (variable-length-array type-spec vf)
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

(define (contains-true? l)
  (not (null? (filter identity l))))

; check that we do not have any nested enums
; TODO lot of boilerplate here
; TODO maybe removing the output param allow synthesis?
(define-pass contains-nested-enums? : L0 (ir) -> * (b)
  (XDR-Spec : XDR-Spec (ir) -> * (b)
            ((,[b*] ...) (contains-true? b*)))
  (Def : Def (ir) -> * (b)
        ((define-type ,i (enum (,i* ,c*) ...)) #f)
        ((define-type ,i ,[b]) b)
        (else #f))
  (Decl : Decl (ir) -> * (b)
        ((,i ,[b]) b)
        (,void #f))
  (Spec : Spec (ir) -> * (b)
        ((variable-length-array ,[b] ,vf) b)
        ((fixed-length-array ,[b] ,v) b)
        ((enum (,i* ,c*) ...) #t)
        ((struct ,[b*] ...) (contains-true? b*))
        ((union ,[b]) b)
        (else #f))
  (Union-Spec : Union-Spec (ir) -> * (b)
              ((case (,i1 ,i2)
                ,[b*] ...) (contains-true? b*)))
  (Union-Case-Spec : Union-Case-Spec (ir) -> * (b)
                   (((,v* ...) ,[b]) b)
                   ((else ,[b]) b))
  (XDR-Spec ir))

(println (contains-nested-enums? (L0-parser test-1)))

(define test-2
  '((define-type "test-struct"
      (struct ("t1" (enum ("A" 1)))))))

(println (contains-nested-enums? (L0-parser test-2)))

(define-language L1
  (extends L0)
  (Union-Case-Spec (union-case-spec)
   (- ((v* ...) decl)
      (else decl))
   (+ (v decl))))

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

#;(define-pass make-consts-hashmap-2 : L0 (ir) -> * (h)
  (XDR-Spec : XDR-Spec (ir) -> * (h)
            ((,[Def : def -> * h*] ...)  ; TODO why can Def not be found automatically?
             (apply hash-union h*)))
  (Def : Def (ir) -> * (h)
        ((define-type ,i ,[Spec : type-spec -> * h]) h)
        ((define-constant ,i ,c) (hash i c)))
  (Decl : Decl (ir) -> * (h)
        (else (hash)))
  (Spec : Spec (ir) -> * (h)
        ((enum (,i* ,c*) ...)
         (for/hash ([i i*] [c c*])
           (values i c)))
        (else (hash)))
  (Union-Spec : Union-Spec (ir) -> * (h)
              (else (hash)))
  (Union-Case-Spec : Union-Case-Spec (ir) -> * (h)
                   (else (hash))))

(define test-3
  '((define-type "test-enum" (enum ("A" 1) ("B" 2))) (define-constant "C" 3)))

(make-consts-hashmap (L0-parser test-3))

#|
(println (make-enum-hashmap (L0-parser test-2)))
(define-pass replace-else : L0 (ir enums) -> L0 ()
  (Union-Spec : Union-Spec (ir) -> Union-Spec ()
              ((case (,i1 ,i2)
                 ((,o** ...) (,i* ,type-spec*)) ... (else (,i ,type-spec)))
               (let* ([])
                 `(case (,i1 ,i2) 
                    ((,o** ...) (,i* ,type-spec*)) ...)))))

(define test-3
  '((define-type "test-union"
      (union (case ("tagname" "tagtype")
               (("A") ("x" "T")) (else ("y" "U")))))))

(replace-else (L0-parser test-3) null)
|#

(define (multi-alist->alist m-alist)
  (let ([kvs
         (for/list ([k (caar m-alist)])
           `(,k . ,(cdar m-alist)))])
    (if (null? (cdr m-alist))
        kvs    
        `(,@kvs ,@(multi-alist->alist (cdr m-alist))))))


(define-pass normalize-unions : L0 (ir) -> L1 ()
  (Union-Spec : Union-Spec (ir) -> Union-Spec ()
              ((case (,i1 ,i2) ((,v** ...) (,i* ,[type-spec*])) ...)
               (let* ([tags (flatten v**)]
                      [malist
                       (for/list ([v* v**]
                                  [i i*]
                                  [type-spec type-spec*])
                         (cons v* (cons i type-spec)))]
                      [alist (multi-alist->alist malist)]
                      [tag* (map car alist)]
                      [acc* (map cadr alist)]
                      [t* (map cddr alist)])
                 `(case (,i1 ,i2) (,tag* (,acc* ,t*)) ...))))
  (XDR-Spec : XDR-Spec (ir) -> XDR-Spec ()))

(normalize-unions (L0-parser test-1))