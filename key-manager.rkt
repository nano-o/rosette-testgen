#lang racket

; Here the idea is to interact with a docker container:
; generate keys and store them in stc's DB, knowing we can then sign transactions with stc

(define docker-image "testgen-utils:latest")

(require shell/pipeline)

; starts a container and returns the container id
(define (start-container)
  (string-trim
   (run-subprocess-pipeline/out `(docker run "-i" "-d" ,docker-image))
   "\n"))

; Next, create and import keys with stc
(define (generate-keys n) 'todo)

; Sign a transaction with a key known to stc
(define (sign tx) 'todo)
  