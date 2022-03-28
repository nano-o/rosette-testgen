#lang reader "x-txrep.rkt"

Transaction.operations._len = 1
TestCase.ledgerEntries._len = 2
TestCase.transactionEnvelopes._len = 1
TransactionV1Envelope.signatures._len = 0 ; for now we'll sign externally
pubkey MuxedAccount.ed25519 in
  GAD2EJUGXNW7YHD7QBL5RLHNFHL35JD4GXLRBZVWPSDACIMMLVC7DOY3
  GBASB5IEQQHYEVWJXTG6HVQR62FNASTOXMEGL4UOUQVNKDLR3BN2HIJL