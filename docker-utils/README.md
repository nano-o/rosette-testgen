* To serialize a transaction in guile-rpc scheme format (e.g. transaction.scm) to base64 binary representation:

```
cat transaction.scm | docker run -i --rm CONTAINER_ID serialize.sh "TransactionEnvelope"
```

* To read an XDR specification (e.g. Stellar.x) and compile it to a sexp that can be read by the Racket tool:

```
cat Stellar.x | docker run -i --rm CONTAINER_ID xdr_spec_to_sexp.sh
```

* To run stc:

```
docker run -i --rm CONTAINER_ID stc
```
