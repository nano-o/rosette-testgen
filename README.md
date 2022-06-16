This is a collection of utilities (in the form of Racket programs, shell scripts, and Docker infrastructure) to support model-based testing of the transaction-processing code in stellar-core.

Features:
* Compile an XDR specification to Racket definitions (constants and struct types).
* Generate a Rosette grammar that can be used to create symbolic data adhering to the XDR specification.
