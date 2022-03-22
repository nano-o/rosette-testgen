(add-to-load-path "/home/user/guile-rpc/modules/")
(add-to-load-path "/home/user/")
(use-modules (rpc compiler)
             (rpc xdr)
             (rnrs bytevectors)
             (rnrs io ports)
             (jlib base64))

(if (not (equal? (length (command-line)) 3))
  (begin
    (display "Takes 2 arguments: a file containing the XDR specification and the XDR type to use.")
    (newline)
    (exit)))

(define type-defs
  (open-file (cadr (command-line)) "r"))
(define type-name
  (caddr (command-line)))
; (display (cadr (command-line)))
; (newline)
(define types (rpc-language->xdr-types type-defs))
(close-port type-defs)
(define type (assoc-ref types type-name))
(if (not type)
 (begin
   (display "type not found")
   (newline)
   (exit)))

; read data from stdin
(define scm-tx
  (read (current-input-port)))

(define size  (xdr-type-size type scm-tx))
(define bv (make-bytevector size))
(xdr-encode! bv 0 type scm-tx)
; (display bv)
; (newline)
; (define output-file
; (open-file (caddr (command-line)) "wb"))
; (put-bytevector output-file bv)
; (put-bytevector (current-output-port) bv)
(put-string (current-output-port) (base64-encode bv))
; (close-port output-file)
