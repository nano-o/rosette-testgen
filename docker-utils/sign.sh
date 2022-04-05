#!/bin/sh
# Expects a private key in strkey format as single argument.
# Expects a transaction encoded in base64 on stdin.
echo $1 | stc -import-key "the-key"
cat | stc -sign -key "the-key" -c -
