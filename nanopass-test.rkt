#lang nanopass

(require racket/hash)
(provide L0-parser normalize-unions)

; TODO language L1 where union cases have a single tag

(define-language L0
  (terminals
   (identifier (i))
   (constant (c))
   (identifier-or-constant (o))
   (identifier-or-constant-or-false (f))
   (void (void))
   (false (false)))
  (XDR-Spec ()
   (decl* ...))
  (Decl (decl) ; type declaration
   (define-type i type-spec)
   (define-constant i c))
  (Spec (type-spec)
    i
    (string c)
    (variable-length-array type-spec f)
    (fixed-length-array type-spec o)
    (enum (i* c*) ...)
    (struct (i* type-spec*) ...)
    (union union-spec))
  (Union-Spec (union-spec)
   (case (i1 i2)
     union-case-spec* ...))
  (Union-Case-Spec (union-case-spec)
   ((o* ...) (i type-spec))
   ((o* ...) void)
   (else (i type-spec))
   (else void)))

(define constant? number?)
(define identifier? string?)
(define (identifier-or-constant? o) (or (constant? o) (identifier? o)))
(define (identifier-or-constant-or-false? o) (or (constant? o) (identifier? o) (equal? o #f)))
(define (void? x) (equal? x "void"))

(define-parser L0-parser L0)

(define-language L1
  (extends L0)
  (Union-Case-Spec (union-case-spec)
   (- ((o* ...) (i type-spec))
      ((o* ...) void)
      (else (i type-spec))
      (else void))
   (+ (o (i type-spec))
      (o void))))

; returns a hashmap mapping enum symbols to values
; enums defined inside other types are ignored (it's not recursive)
(define-pass make-enum-hashmap : L0 (ir) -> * ()
  (XDR-Spec : XDR-Spec (ir) -> * ()
            ((,[Decl : -> h*] ...)  ; TODO why can Decl not be found automatically?
             (apply hash-union h*)))
  (Decl : Decl (ir) -> * ()
        ((define-type ,i ,[Spec : -> h]) h) ; TODO why can Spec not be found automatically?
        (else (hash)))
  (Spec : Spec (ir) -> * ()
        ((enum (,i* ,c*) ...)
         (for/hash ([i i*] [c c*])
           (values i c)))
        (else (hash))))

(define test-2
  '((define-type "test-enum" (enum ("A" 1) ("B" 2)))))

(make-enum-hashmap (L0-parser test-2))

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
              ((case (,i1 ,i2) ((,o** ...) (,i* ,[type-spec*])) ...)
               (let* ([tags (flatten o**)]
                      [malist
                       (for/list ([o* o**]
                                  [i i*]
                                  [type-spec type-spec*])
                         (cons o* (cons i type-spec)))]
                      [alist (multi-alist->alist malist)]
                      [tag* (map car alist)]
                      [acc* (map cadr alist)]
                      [t* (map cddr alist)])
                 `(case (,i1 ,i2) (,tag* (,acc* ,t*)) ...))))
  (XDR-Spec : XDR-Spec (ir) -> XDR-Spec ()))
   
(define test-1
  '((define-type "test-union"
     (union (case ("tagname" "tagtype")
              (("A") ("c" (union (case ("tagname-2" "tagtype-2") (("X" "Y") ("x" "T"))))))
              (("B" "C") ("d" "int")))))
    (define-type "test-struct"
      (struct ("t1" (union (case ("tagname-3" "tagtype-3") (("F" "G") ("y" "T")))))))))

(normalize-unions (L0-parser test-1))