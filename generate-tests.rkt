#lang rosette

(require
  "serialize.rkt"
  "path-explorer.rkt"
  "Stellar-utils.rkt"
  rosette/lib/synthax
  syntax/parse
  racket/stream
  (only-in list-util zip))

(provide lazy-run-tests lazy-create-test-files create-test-files display-test-inputs compute-solutions serialize-tests get-test-inputs)

(define test-output-dir
  "./generated-tests/")
(define to-bin
  (string-append test-output-dir "to_bin.sh"))
(define pretty-print
  (string-append test-output-dir "pretty_print.sh"))

(define solutions null)

(define (compute-solutions spec symbols)
  (when (null? solutions)
   ; (let sols ([strm (all-paths spec symbols)])
    ; )
    (set! solutions
          (stream->list (all-paths spec symbols)))))

(define (display-solution s)
  (if (sat? s)
    (for ([f (generate-forms s)])
         (pretty-display (syntax->datum f)))
    (displayln "unsat")))

; display the synthesized tests inputs (for debugging):
(define (display-test-inputs)
  (for ([s solutions]
        #:when (sat? s))
   (display-solution s))
  (displayln (format "There are ~a paths" (length solutions)))
  (displayln (format "There are ~a feasible paths" (length (filter sat? solutions)))))

; we need the current namespace for eval
(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))
(define (interpret stx)
  (eval-syntax (datum->syntax #'() (syntax->datum stx)) ns))
(define (defn/stx->datum defn)
  (syntax-parse defn
    [(define _ d) (interpret #'d)]))

(define (get-test-inputs)
 ; returns a datum describing the test case
  (for/list ([s solutions]
             #:when (sat? s))
    (for/list ([f (generate-forms s)])
      (defn/stx->datum f))))

(define (serialize-test s)
  ; s must be a SAT solution
  (match-let* ([(list l-defn tx-defn) (generate-forms s)]
               [tx (defn/stx->datum tx-defn)]
               [src (source-account/bv256 tx)])
    `((test-ledger . ,(serialize-ledger l-defn))
      (test-tx . ,(serialize-tx tx-defn (list src)))))) ; we sign with the source account by default

(define (serialize-tests)
  (for/list ([s solutions]
             #:when (sat? s))
   (serialize-test s)))

(define (create-test-files)
  (let ([tests (serialize-tests)])
    (for ([test (zip (range (length tests)) tests)])
      (match-let ([`(,i . ,test-inputs) test])
        (begin
          (with-output-to-file (apply string-append `(,test-output-dir "test-" ,(number->string i) "-ledger.base64"))
            #:exists 'replace
            (λ () (printf "~a" (dict-ref test-inputs 'test-ledger))))
          (with-output-to-file (apply string-append `(,test-output-dir "test-" ,(number->string i) "-tx.base64"))
            #:exists 'replace
            (λ () (printf "~a" (dict-ref test-inputs 'test-tx))))
          (subprocess #f #f #f to-bin)
          (subprocess #f #f #f pretty-print)))))) ; this will return file-stream ports; should they be closed?

(define base64-to-bin
  (string-append test-output-dir "base64_to_bin.sh"))
(define print-test
  (string-append test-output-dir "print.sh"))
(define output-log-file
  (string-append test-output-dir "log.out"))


(define (create-test-file i s)
  (define (ledger-file i)
    (apply string-append `(,test-output-dir "test-" ,(number->string i) "-ledger.base64")))
  (define (tx-file i)
    (apply string-append `(,test-output-dir "test-" ,(number->string i) "-tx.base64")))
  (let* ([t (serialize-test s)]
         [ledger-file (ledger-file i)]
         [tx-file (tx-file i)])
    (begin
      (with-output-to-file ledger-file
                           #:exists 'replace
                           (λ () (printf "~a" (dict-ref t 'test-ledger))))
      (with-output-to-file tx-file
                           #:exists 'replace
                           (λ () (printf "~a" (dict-ref t 'test-tx))))
      (with-output-to-file output-log-file
                           #:exists 'replace
                           (λ ()
                              (parameterize ([current-error-port (current-output-port)])
                                (system* base64-to-bin ledger-file)
                                (system* base64-to-bin tx-file)
                                (system* print-test (number->string i)))))
      (displayln (format "created test file ~a" i)))))

; run a test using a running docker container
; we have to copy the test file, then call core

(define docker-run-prefix `(docker exec d8f6e446390))
(define mounted-dir-path "/home/nano/Documents/stellar-core-docker/misc/")

(define (run-test i)
  (define (ledger-file-base64 i)
    (apply string-append `(,test-output-dir "test-" ,(number->string i) "-ledger.base64")))
  (define (tx-file-base64 i)
    (apply string-append `(,test-output-dir "test-" ,(number->string i) "-tx.base64")))
  (define container-misc "/home/user/misc/")
  (define (ledger-file-bin i)
    (apply string-append `(,test-output-dir "test-" ,(number->string i) "-ledger.bin")))
  (define (tx-file-bin i)
    (apply string-append `(,test-output-dir "test-" ,(number->string i) "-tx.bin")))
  (define (ledger-file-container-bin i)
    (apply string-append `(,container-misc "test-" ,(number->string i) "-ledger.bin")))
  (define (tx-file-container-bin i)
    (apply string-append `(,container-misc "test-" ,(number->string i) "-tx.bin")))
  (define base64-to-bin
    (string-append test-output-dir "base64_to_bin.sh"))
  (system (format "~a ~a" base64-to-bin (ledger-file-base64 i)))
  (system (format "~a ~a" base64-to-bin (tx-file-base64 i)))
  (system (format "cp ~a ~a" (ledger-file-bin i) mounted-dir-path))
  (system (format "cp ~a ~a" (tx-file-bin i) mounted-dir-path))
  (let* ([output-file (format "out-~a.txt" (number->string i))]
         [command (format "docker exec -i ad8f6e446390 bash -c \"/home/user/bin/stellar-core run-model-based-test ~a ~a 2> /home/user/misc/~a\"" (ledger-file-container-bin i) (tx-file-container-bin i) output-file)])
    (begin
      ; (displayln command)
      (system command))))

(define (lazy-create-test-files spec symbols)
 (let* ([all-solutions (all-paths spec symbols)]
        [sat-solutions (stream-filter sat? all-solutions)])
   (for ([s (in-stream sat-solutions)]
         [i (in-naturals 0)])
    (create-test-file i s))))

(define (lazy-run-tests spec symbols)
 (let* ([all-solutions (all-paths spec symbols)]
        [sat-solutions (stream-filter sat? all-solutions)])
   (for ([s (in-stream sat-solutions)]
         [i (in-naturals 0)])
    (create-test-file i s)
    (run-test i))))
