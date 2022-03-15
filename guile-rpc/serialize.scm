(add-to-load-path "./guile-rpc/modules/")
(use-modules (rpc compiler)
             (rpc xdr)
             (rnrs bytevectors)
             (rnrs io ports))

(if (< (length (command-line)) 3)
 (exit))

(define type-defs
  (open-file (cadr (command-line)) "r"))
(display (cadr (command-line)))
(newline)
(define types (rpc-language->xdr-types type-defs))
(close-port type-defs)
(define type (cdr (assoc "TransactionEnvelope" types)))

(define data-def
  (open-file (caddr (command-line)) "r"))
(define scm-tx
  (read data-def))
; (display scm-tx)
; (newline)

(define size  (xdr-type-size type scm-tx))
(display "size")
(newline)
(display size)
(newline)

(define bv (make-bytevector size))
(xdr-encode! bv 0 type scm-tx)
(display bv)
(newline)
(define output-file
(open-file (cadddr (command-line)) "wb"))
(put-bytevector output-file bv)
(close-port output-file)
