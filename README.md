This is a collection of utilities (in the form of Racket programs, shell scripts, and Docker infrastructure) to support model-based testing of the transaction-processing code in stellar-core.

`grammar-generator.rkt` takes an XDR specification (first processed by guile-rpc) and generates:
* Racket definitions (constants and struct types) corresponding to the XDR types.
* A Rosette grammar that can be used to create symbolic data adhering to the XDR specification.
