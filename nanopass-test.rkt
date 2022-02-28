#lang nanopass

(provide L0-parser pass-1)

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

(define (multi-alist->alist m-alist)
  (let ([kvs
         (for/list ([k (caar m-alist)])
           `(,k . ,(cdar m-alist)))])
    (if (null? (cdr m-alist))
        kvs    
        `(,@kvs ,@(multi-alist->alist (cdr m-alist))))))

(define-pass pass-1 : L0 (ir) -> L0 ()
  (Union-Spec : Union-Spec (ir) -> Union-Spec ()
   ((case (,i1 ,i2) ,union-case-spec* ...)
    (begin
      (let* ([alist
              (multi-alist->alist
               (map (λ (ucs)
                      (nanopass-case
                       (L0 Union-Case-Spec)
                       ucs
                       [((,o* ...) (,i ,type-spec))
                        (cons o* (cons i type-spec))]))
                    union-case-spec*))]
             [case-specs
              (for/list ([a alist])
                (in-context Union-Case-Spec `((,(car a)) (,(cadr a) ,(cddr a)))))])
        `(case (,i1 ,i2) ,case-specs ...)))))
  (XDR-Spec : XDR-Spec (ir) -> XDR-Spec ()))
   
(define test-union
  '((define-type "test-union"
     (union (case ("tagname" "tagtype")
              (("A") ("c" "int")) (("B" "C") ("d" "int")))))))

;(L0-parser test-union)

(pass-1 (L0-parser test-union))

#;(define base-types
  '("int" "unsigned int" "hyper" "unsigned hyper" "double" "quadruple" "float"))
#;(define base-type? (λ (t) (member t base-types)))