This is a collection of utilities (in the form of Racket programs, shell scripts, and Docker infrastructure) to support model-based testing of the transaction-processing code in stellar-core.

# Features

* Compile an XDR specification to Racket definitions (constants and struct types).
* Generate a Rosette grammar that can be used to create symbolic data adhering to the XDR specification.
* Docker setup including a version of `core` that has a command called `run-model-based-test` which takes a ledger and a transaction envelope (as XDR encoded blobs)

# Dependencies on external tools

We use a few external tools, provided in a docker image.

## guile-rpc

We rely on guile-rpc s-expressions as intermediate representation for XDR. In other words, we use guile-rpc to parse XDR specs to an s-expression representation, and we encode to the same s-expression representation. The reason for this is to avoid writing a parser and a low-level encoder.

There is a docker image containing guile-rpc and a few wrapper scripts.

## stc

stc is the Stellar transaction compiler. We rely on stc to sign transactions.

## xdrpp

We rely on xdrpp to pretty-print XDR blobs.
