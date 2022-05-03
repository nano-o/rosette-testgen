#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "no test file specified"
  exit 1
fi

base64 -d $1 > ${1%.base64}.bin
