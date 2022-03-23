#lang reader "x-txrep.rkt"

Transaction.operations._len = 1
TestCase.ledgerEntries._len = 2
TestCase.transactionEnvelopes._len = 1
TransactionV1Envelope.signatures._len = 0 ; for now we'll sign externally