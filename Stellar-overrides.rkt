#lang racket

(provide overrides)

(define keys
  '(key-set
    "GA57G3YN5GEA5AF7YI2ZMNCKKAOQNAPYGDDIAVGSH7ILWRET6Y76SEIP"
    "GCNC3APR4XB64E7XADGU5JJFS7J2WYVJRKU73TYATQXW3LRSPGCIN2PJ"))

(define overrides
  `((("Transaction" "operations") len . 1)
    (("TestCase" "ledgerEntries") len . 2)
    (("TestCase" "transactionEnvelopes") len . 1)
    (("TransactionV1Envelope" "signatures") len . 0)
    (("MuxedAccount" "ed25519") ,@keys)
    (("MuxedAccount" "med25519" "ed25519") ,@keys)
    (("PublicKey" "ed25519") ,@keys)
    (("SignerKey" "ed25519") ,@keys)))