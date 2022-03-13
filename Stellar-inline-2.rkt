#lang rosette

(require rosette/lib/synthax)

(provide (all-defined-out))

(begin
  (define ASSET_TYPE_CREDIT_ALPHANUM12 2)
  (define CHANGE_TRUST_TRUST_LINE_MISSING -6)
  (define txFAILED -1)
  (define SET_OPTIONS 5)
  (define CREATE_ACCOUNT_SUCCESS 0)
  (define MANAGE_BUY_OFFER_LOW_RESERVE -12)
  (define CREATE_CLAIMABLE_BALANCE_NO_TRUST -3)
  (define PAYMENT_SRC_NOT_AUTHORIZED -4)
  (define MANAGE_BUY_OFFER_UNDERFUNDED -7)
  (define CREATE_ACCOUNT 0)
  (define CLAIM_CLAIMABLE_BALANCE_LINE_FULL -3)
  (define LIQUIDITY_POOL_DEPOSIT_SUCCESS 0)
  (define ENVELOPE_TYPE_SCPVALUE 4)
  (define CREATE_CLAIMABLE_BALANCE_NOT_AUTHORIZED -4)
  (define CLAIM_PREDICATE_UNCONDITIONAL 0)
  (define ENVELOPE_TYPE_TX_V0 0)
  (define SET_OPTIONS_SUCCESS 0)
  (define ALLOW_TRUST_LOW_RESERVE -6)
  (define MASK_ACCOUNT_FLAGS 7)
  (define INFLATION_NOT_TIME -1)
  (define CREATE_ACCOUNT_MALFORMED -1)
  (define CHANGE_TRUST_MALFORMED -1)
  (define CREATE_ACCOUNT_LOW_RESERVE -3)
  (define CREATE_CLAIMABLE_BALANCE_LOW_RESERVE -2)
  (define CLAWBACK_NO_TRUST -3)
  (define CHANGE_TRUST_NO_ISSUER -2)
  (define opTOO_MANY_SPONSORING -6)
  (define CLAIM_ATOM_TYPE_ORDER_BOOK 1)
  (define REVOKE_SPONSORSHIP_ONLY_TRANSFERABLE -4)
  (define SET_TRUST_LINE_FLAGS_SUCCESS 0)
  (define PATH_PAYMENT_STRICT_RECEIVE_NO_ISSUER -9)
  (define AUTH_IMMUTABLE_FLAG 4)
  (define LIQUIDITY_POOL_CONSTANT_PRODUCT 0)
  (define CLAWBACK_CLAIMABLE_BALANCE_NOT_CLAWBACK_ENABLED -3)
  (define ENVELOPE_TYPE_AUTH 3)
  (define CLAIM_CLAIMABLE_BALANCE 15)
  (define CLAWBACK_NOT_CLAWBACK_ENABLED -2)
  (define CHANGE_TRUST_SUCCESS 0)
  (define CLAIM_CLAIMABLE_BALANCE_SUCCESS 0)
  (define ACCOUNT_MERGE_SUCCESS 0)
  (define PATH_PAYMENT_STRICT_RECEIVE_UNDERFUNDED -2)
  (define PATH_PAYMENT_STRICT_RECEIVE_NO_DESTINATION -5)
  (define ACCOUNT_MERGE_DEST_FULL -6)
  (define MANAGE_BUY_OFFER_CROSS_SELF -8)
  (define ACCOUNT_MERGE_NO_ACCOUNT -2)
  (define ALLOW_TRUST_TRUST_NOT_REQUIRED -3)
  (define PATH_PAYMENT_STRICT_SEND_OFFER_CROSS_SELF -11)
  (define SET_OPTIONS_BAD_SIGNER -8)
  (define CREATE_ACCOUNT_UNDERFUNDED -2)
  (define REVOKE_SPONSORSHIP_LEDGER_ENTRY 0)
  (define MANAGE_SELL_OFFER_BUY_NO_TRUST -3)
  (define AUTHORIZED_TO_MAINTAIN_LIABILITIES_FLAG 2)
  (define opINNER 0)
  (define KEY_TYPE_MUXED_ED25519 256)
  (define CLAIM_CLAIMABLE_BALANCE_NOT_AUTHORIZED -5)
  (define MANAGE_BUY_OFFER_SELL_NOT_AUTHORIZED -4)
  (define CLAIMANT_TYPE_V0 0)
  (define SET_OPTIONS_INVALID_INFLATION -4)
  (define txNO_ACCOUNT -8)
  (define MASK_ACCOUNT_FLAGS_V17 15)
  (define TRUSTLINE 1)
  (define PATH_PAYMENT_STRICT_RECEIVE_TOO_FEW_OFFERS -10)
  (define BUMP_SEQUENCE_BAD_SEQ -1)
  (define ACCOUNT_MERGE_MALFORMED -1)
  (define SET_TRUST_LINE_FLAGS_LOW_RESERVE -5)
  (define SET_OPTIONS_CANT_CHANGE -5)
  (define MASK_CLAIMABLE_BALANCE_FLAGS 1)
  (define SET_OPTIONS_INVALID_HOME_DOMAIN -9)
  (define MASK_OFFERENTRY_FLAGS 1)
  (define CLAWBACK_CLAIMABLE_BALANCE_NOT_ISSUER -2)
  (define MANAGE_BUY_OFFER 12)
  (define REVOKE_SPONSORSHIP_NOT_SPONSOR -2)
  (define PAYMENT_UNDERFUNDED -2)
  (define PATH_PAYMENT_STRICT_RECEIVE_SRC_NOT_AUTHORIZED -4)
  (define MEMO_HASH 3)
  (define ENVELOPE_TYPE_OP_ID 6)
  (define MASK_TRUSTLINE_FLAGS_V17 7)
  (define MANAGE_DATA 10)
  (define MEMO_ID 2)
  (define PATH_PAYMENT_STRICT_RECEIVE_SUCCESS 0)
  (define PATH_PAYMENT_STRICT_RECEIVE 2)
  (define PAYMENT_NOT_AUTHORIZED -7)
  (define MANAGE_BUY_OFFER_NOT_FOUND -11)
  (define CLAIM_PREDICATE_NOT 3)
  (define MANAGE_BUY_OFFER_BUY_NO_TRUST -3)
  (define ALLOW_TRUST_SUCCESS 0)
  (define MANAGE_SELL_OFFER_BUY_NO_ISSUER -10)
  (define MAX_SIGNERS 20)
  (define opEXCEEDED_WORK_LIMIT -5)
  (define SET_OPTIONS_LOW_RESERVE -1)
  (define CREATE_CLAIMABLE_BALANCE_UNDERFUNDED -5)
  (define CHANGE_TRUST 6)
  (define PATH_PAYMENT_STRICT_RECEIVE_NO_TRUST -6)
  (define TRUSTLINE_CLAWBACK_ENABLED_FLAG 4)
  (define CHANGE_TRUST_CANNOT_DELETE -7)
  (define INFLATION 9)
  (define ENVELOPE_TYPE_TX_FEE_BUMP 5)
  (define PATH_PAYMENT_STRICT_SEND_SUCCESS 0)
  (define MASK_TRUSTLINE_FLAGS_V13 3)
  (define PATH_PAYMENT_STRICT_RECEIVE_MALFORMED -1)
  (define LIQUIDITY_POOL_DEPOSIT_NO_TRUST -2)
  (define CREATE_CLAIMABLE_BALANCE_MALFORMED -1)
  (define MANAGE_SELL_OFFER_SELL_NOT_AUTHORIZED -4)
  (define AUTH_REVOCABLE_FLAG 2)
  (define PATH_PAYMENT_STRICT_SEND_SRC_NO_TRUST -3)
  (define ALLOW_TRUST_SELF_NOT_ALLOWED -5)
  (define CLAWBACK 19)
  (define PASSIVE_FLAG 1)
  (define REVOKE_SPONSORSHIP_LOW_RESERVE -3)
  (define PAYMENT_NO_ISSUER -9)
  (define MANAGE_SELL_OFFER_SUCCESS 0)
  (define CLAIM_CLAIMABLE_BALANCE_CANNOT_CLAIM -2)
  (define PATH_PAYMENT_STRICT_RECEIVE_OFFER_CROSS_SELF -11)
  (define REVOKE_SPONSORSHIP_SIGNER 1)
  (define LIQUIDITY_POOL_DEPOSIT_BAD_PRICE -6)
  (define CLAIMABLE_BALANCE 4)
  (define MEMO_TEXT 1)
  (define MANAGE_SELL_OFFER_SELL_NO_ISSUER -9)
  (define MEMO_NONE 0)
  (define ENVELOPE_TYPE_POOL_REVOKE_OP_ID 7)
  (define txSUCCESS 0)
  (define CLAWBACK_CLAIMABLE_BALANCE 20)
  (define KEY_TYPE_ED25519 0)
  (define ALLOW_TRUST_NO_TRUST_LINE -2)
  (define CREATE_PASSIVE_SELL_OFFER 4)
  (define PAYMENT_SRC_NO_TRUST -3)
  (define PATH_PAYMENT_STRICT_RECEIVE_SRC_NO_TRUST -3)
  (define ACCOUNT_MERGE_IMMUTABLE_SET -3)
  (define txINSUFFICIENT_FEE -9)
  (define MANAGE_DATA_INVALID_NAME -4)
  (define MANAGE_BUY_OFFER_SUCCESS 0)
  (define txFEE_BUMP_INNER_FAILED -13)
  (define PATH_PAYMENT_STRICT_RECEIVE_LINE_FULL -8)
  (define MANAGE_BUY_OFFER_LINE_FULL -6)
  (define CLAWBACK_SUCCESS 0)
  (define ASSET_TYPE_NATIVE 0)
  (define opTOO_MANY_SUBENTRIES -4)
  (define LIQUIDITY_POOL_WITHDRAW 23)
  (define PATH_PAYMENT_STRICT_SEND_UNDERFUNDED -2)
  (define txNOT_SUPPORTED -12)
  (define CLAIM_CLAIMABLE_BALANCE_NO_TRUST -4)
  (define ACCOUNT_MERGE_IS_SPONSOR -7)
  (define SET_OPTIONS_TOO_MANY_SIGNERS -2)
  (define PATH_PAYMENT_STRICT_SEND_SRC_NOT_AUTHORIZED -4)
  (define txBAD_AUTH -6)
  (define MANAGE_DATA_NAME_NOT_FOUND -2)
  (define PATH_PAYMENT_STRICT_SEND_NO_ISSUER -9)
  (define PATH_PAYMENT_STRICT_SEND_NO_TRUST -6)
  (define ACCOUNT_MERGE_SEQNUM_TOO_FAR -5)
  (define MANAGE_DATA_NOT_SUPPORTED_YET -1)
  (define CHANGE_TRUST_LOW_RESERVE -4)
  (define CLAWBACK_UNDERFUNDED -4)
  (define SET_TRUST_LINE_FLAGS_MALFORMED -1)
  (define PAYMENT_NO_DESTINATION -5)
  (define REVOKE_SPONSORSHIP_SUCCESS 0)
  (define AUTH_REQUIRED_FLAG 1)
  (define PATH_PAYMENT_STRICT_SEND_LINE_FULL -8)
  (define MANAGE_SELL_OFFER_BUY_NOT_AUTHORIZED -5)
  (define txBAD_SEQ -5)
  (define MANAGE_BUY_OFFER_BUY_NO_ISSUER -10)
  (define MANAGE_SELL_OFFER_LOW_RESERVE -12)
  (define PUBLIC_KEY_TYPE_ED25519 0)
  (define CLAIM_PREDICATE_OR 2)
  (define CLAIM_PREDICATE_BEFORE_ABSOLUTE_TIME 4)
  (define SET_TRUST_LINE_FLAGS_INVALID_STATE -4)
  (define BEGIN_SPONSORING_FUTURE_RESERVES 16)
  (define LIQUIDITY_POOL_DEPOSIT_UNDERFUNDED -4)
  (define REVOKE_SPONSORSHIP_DOES_NOT_EXIST -1)
  (define opNOT_SUPPORTED -3)
  (define PATH_PAYMENT_STRICT_SEND_TOO_FEW_OFFERS -10)
  (define AUTH_CLAWBACK_ENABLED_FLAG 8)
  (define LIQUIDITY_POOL 5)
  (define THRESHOLD_MASTER_WEIGHT 0)
  (define PATH_PAYMENT_STRICT_RECEIVE_OVER_SENDMAX -12)
  (define CHANGE_TRUST_NOT_AUTH_MAINTAIN_LIABILITIES -8)
  (define PATH_PAYMENT_STRICT_SEND_UNDER_DESTMIN -12)
  (define MANAGE_OFFER_UPDATED 1)
  (define THRESHOLD_LOW 1)
  (define BEGIN_SPONSORING_FUTURE_RESERVES_MALFORMED -1)
  (define MASK_TRUSTLINE_FLAGS 1)
  (define PATH_PAYMENT_STRICT_SEND_NOT_AUTHORIZED -7)
  (define LIQUIDITY_POOL_DEPOSIT_MALFORMED -1)
  (define LIQUIDITY_POOL_WITHDRAW_LINE_FULL -4)
  (define txMISSING_OPERATION -4)
  (define LIQUIDITY_POOL_WITHDRAW_NO_TRUST -2)
  (define LIQUIDITY_POOL_WITHDRAW_UNDERFUNDED -3)
  (define txTOO_EARLY -2)
  (define SET_TRUST_LINE_FLAGS_CANT_REVOKE -3)
  (define MANAGE_SELL_OFFER_UNDERFUNDED -7)
  (define MANAGE_BUY_OFFER_SELL_NO_TRUST -2)
  (define MANAGE_SELL_OFFER_SELL_NO_TRUST -2)
  (define END_SPONSORING_FUTURE_RESERVES_NOT_SPONSORED -1)
  (define PATH_PAYMENT_STRICT_RECEIVE_NOT_AUTHORIZED -7)
  (define LIQUIDITY_POOL_WITHDRAW_SUCCESS 0)
  (define CLAIM_PREDICATE_BEFORE_RELATIVE_TIME 5)
  (define MANAGE_SELL_OFFER_CROSS_SELF -8)
  (define LIQUIDITY_POOL_DEPOSIT_NOT_AUTHORIZED -3)
  (define LIQUIDITY_POOL_DEPOSIT_LINE_FULL -5)
  (define KEY_TYPE_PRE_AUTH_TX 1)
  (define THRESHOLD_MED 2)
  (define ALLOW_TRUST 7)
  (define MANAGE_BUY_OFFER_SELL_NO_ISSUER -9)
  (define MANAGE_SELL_OFFER 3)
  (define KEY_TYPE_HASH_X 2)
  (define BEGIN_SPONSORING_FUTURE_RESERVES_SUCCESS 0)
  (define PAYMENT_LINE_FULL -8)
  (define THRESHOLD_HIGH 3)
  (define opNO_ACCOUNT -2)
  (define PATH_PAYMENT_STRICT_SEND 13)
  (define SET_OPTIONS_BAD_FLAGS -3)
  (define ASSET_TYPE_CREDIT_ALPHANUM4 1)
  (define CLAIMABLE_BALANCE_CLAWBACK_ENABLED_FLAG 1)
  (define CHANGE_TRUST_INVALID_LIMIT -3)
  (define CLAIM_CLAIMABLE_BALANCE_DOES_NOT_EXIST -1)
  (define CLAWBACK_CLAIMABLE_BALANCE_DOES_NOT_EXIST -1)
  (define MANAGE_SELL_OFFER_NOT_FOUND -11)
  (define ASSET_TYPE_POOL_SHARE 3)
  (define INFLATION_SUCCESS 0)
  (define MEMO_RETURN 4)
  (define CLAIM_ATOM_TYPE_LIQUIDITY_POOL 2)
  (define CREATE_CLAIMABLE_BALANCE_SUCCESS 0)
  (define CLAWBACK_CLAIMABLE_BALANCE_SUCCESS 0)
  (define SET_OPTIONS_UNKNOWN_FLAG -6)
  (define END_SPONSORING_FUTURE_RESERVES_SUCCESS 0)
  (define BEGIN_SPONSORING_FUTURE_RESERVES_ALREADY_SPONSORED -2)
  (define AUTHORIZED_FLAG 1)
  (define BUMP_SEQUENCE_SUCCESS 0)
  (define txINSUFFICIENT_BALANCE -7)
  (define MANAGE_DATA_SUCCESS 0)
  (define MAX_OPS_PER_TX 100)
  (define MANAGE_BUY_OFFER_BUY_NOT_AUTHORIZED -5)
  (define PAYMENT_NO_TRUST -6)
  (define txINTERNAL_ERROR -11)
  (define BEGIN_SPONSORING_FUTURE_RESERVES_RECURSIVE -3)
  (define DATA 3)
  (define MANAGE_SELL_OFFER_MALFORMED -1)
  (define MANAGE_OFFER_DELETED 2)
  (define LIQUIDITY_POOL_WITHDRAW_UNDER_MINIMUM -5)
  (define ACCOUNT_MERGE 8)
  (define LIQUIDITY_POOL_DEPOSIT 22)
  (define LIQUIDITY_POOL_WITHDRAW_MALFORMED -1)
  (define ALLOW_TRUST_CANT_REVOKE -4)
  (define ACCOUNT_MERGE_HAS_SUB_ENTRIES -4)
  (define SIGNER_KEY_TYPE_HASH_X 2)
  (define CHANGE_TRUST_SELF_NOT_ALLOWED -5)
  (define MANAGE_BUY_OFFER_MALFORMED -1)
  (define CREATE_CLAIMABLE_BALANCE 14)
  (define CLAWBACK_MALFORMED -1)
  (define PAYMENT 1)
  (define REVOKE_SPONSORSHIP 18)
  (define ENVELOPE_TYPE_SCP 1)
  (define txTOO_LATE -3)
  (define txBAD_AUTH_EXTRA -10)
  (define opBAD_AUTH -1)
  (define REVOKE_SPONSORSHIP_MALFORMED -5)
  (define SET_TRUST_LINE_FLAGS 21)
  (define ENVELOPE_TYPE_TX 2)
  (define CLAIMABLE_BALANCE_ID_TYPE_V0 0)
  (define ALLOW_TRUST_MALFORMED -1)
  (define CLAIM_PREDICATE_AND 1)
  (define PAYMENT_MALFORMED -1)
  (define SET_TRUST_LINE_FLAGS_NO_TRUST_LINE -2)
  (define BUMP_SEQUENCE 11)
  (define MANAGE_OFFER_CREATED 0)
  (define SIGNER_KEY_TYPE_ED25519 0)
  (define SIGNER_KEY_TYPE_PRE_AUTH_TX 1)
  (define CLAIM_ATOM_TYPE_V0 0)
  (define END_SPONSORING_FUTURE_RESERVES 17)
  (define OFFER 2)
  (define SET_OPTIONS_THRESHOLD_OUT_OF_RANGE -7)
  (define ACCOUNT 0)
  (define MANAGE_DATA_LOW_RESERVE -3)
  (define PATH_PAYMENT_STRICT_SEND_MALFORMED -1)
  (define LIQUIDITY_POOL_FEE_V18 30)
  (define CREATE_ACCOUNT_ALREADY_EXIST -4)
  (define SET_OPTIONS_AUTH_REVOCABLE_REQUIRED -10)
  (define PAYMENT_SUCCESS 0)
  (define LIQUIDITY_POOL_DEPOSIT_POOL_FULL -7)
  (define txBAD_SPONSORSHIP -14)
  (define txFEE_BUMP_INNER_SUCCESS 1)
  (define MANAGE_SELL_OFFER_LINE_FULL -6)
  (define PATH_PAYMENT_STRICT_SEND_NO_DESTINATION -5)
  (struct ClaimableBalanceEntryExtensionV1 (ext flags) #:transparent)
  (struct AlphaNum12 (assetCode issuer) #:transparent)
  (struct TransactionV1Envelope (tx signatures) #:transparent)
  (struct
   AccountEntry
   (accountID
    balance
    seqNum
    numSubEntries
    inflationDest
    flags
    homeDomain
    thresholds
    signers
    ext)
   #:transparent)
  (struct LiquidityPoolEntry (liquidityPoolID body) #:transparent)
  (struct LedgerKey::claimableBalance (balanceID) #:transparent)
  (struct CreatePassiveSellOfferOp (selling buying amount price) #:transparent)
  (struct LedgerKey::account (accountID) #:transparent)
  (struct CreateClaimableBalanceOp (asset amount claimants) #:transparent)
  (struct
   PathPaymentStrictSendOp
   (sendAsset sendAmount destination destAsset destMin path)
   #:transparent)
  (struct TimeBounds (minTime maxTime) #:transparent)
  (struct DataEntry (accountID dataName dataValue ext) #:transparent)
  (struct
   ManageBuyOfferOp
   (selling buying buyAmount price offerID)
   #:transparent)
  (struct
   Transaction
   (sourceAccount fee seqNum timeBounds memo operations ext)
   #:transparent)
  (struct Signer (key weight) #:transparent)
  (struct
   TrustLineEntry
   (accountID asset balance limit flags ext)
   #:transparent)
  (struct BeginSponsoringFutureReservesOp (sponsoredID) #:transparent)
  (struct LedgerEntry (lastModifiedLedgerSeq data ext) #:transparent)
  (struct PaymentOp (destination asset amount) #:transparent)
  (struct
   ClaimableBalanceEntry
   (balanceID claimants asset amount ext)
   #:transparent)
  (struct
   LiquidityPoolEntry::body::constantProduct
   (params reserveA reserveB totalPoolShares poolSharesTrustLineCount)
   #:transparent)
  (struct ClaimClaimableBalanceOp (balanceID) #:transparent)
  (struct LedgerKey::trustLine (accountID asset) #:transparent)
  (struct AllowTrustOp (trustor asset authorize) #:transparent)
  (struct BumpSequenceOp (bumpTo) #:transparent)
  (struct TrustLineEntry::ext::v1 (liabilities ext) #:transparent)
  (struct Operation (sourceAccount body) #:transparent)
  (struct
   AccountEntryExtensionV2
   (numSponsored numSponsoring signerSponsoringIDs ext)
   #:transparent)
  (struct LedgerKey::offer (sellerID offerID) #:transparent)
  (struct Claimant::v0 (destination predicate) #:transparent)
  (struct LedgerKey::liquidityPool (liquidityPoolID) #:transparent)
  (struct
   SetTrustLineFlagsOp
   (trustor asset clearFlags setFlags)
   #:transparent)
  (struct ClawbackClaimableBalanceOp (balanceID) #:transparent)
  (struct
   LiquidityPoolDepositOp
   (liquidityPoolID maxAmountA maxAmountB minPrice maxPrice)
   #:transparent)
  (struct ClawbackOp (asset from amount) #:transparent)
  (struct
   LiquidityPoolConstantProductParameters
   (assetA assetB fee)
   #:transparent)
  (struct
   LiquidityPoolWithdrawOp
   (liquidityPoolID amount minAmountA minAmountB)
   #:transparent)
  (struct ManageDataOp (dataName dataValue) #:transparent)
  (struct
   PathPaymentStrictReceiveOp
   (sendAsset sendMax destination destAsset destAmount path)
   #:transparent)
  (struct TransactionV0Envelope (tx signatures) #:transparent)
  (struct LedgerEntryExtensionV1 (sponsoringID ext) #:transparent)
  (struct
   OfferEntry
   (sellerID offerID selling buying amount price flags ext)
   #:transparent)
  (struct
   SetOptionsOp
   (inflationDest
    clearFlags
    setFlags
    masterWeight
    lowThreshold
    medThreshold
    highThreshold
    homeDomain
    signer)
   #:transparent)
  (struct LedgerKey::data (accountID dataName) #:transparent)
  (struct Price (n d) #:transparent)
  (struct FeeBumpTransactionEnvelope (tx signatures) #:transparent)
  (struct FeeBumpTransaction (feeSource fee innerTx ext) #:transparent)
  (struct RevokeSponsorshipOp::signer (accountID signerKey) #:transparent)
  (struct
   ManageSellOfferOp
   (selling buying amount price offerID)
   #:transparent)
  (struct DecoratedSignature (hint signature) #:transparent)
  (struct AccountEntryExtensionV1 (liabilities ext) #:transparent)
  (struct CreateAccountOp (destination startingBalance) #:transparent)
  (struct ChangeTrustOp (line limit) #:transparent)
  (struct MuxedAccount::med25519 (id ed25519) #:transparent)
  (struct TrustLineEntryExtensionV2 (liquidityPoolUseCount ext) #:transparent)
  (struct Liabilities (buying selling) #:transparent)
  (struct
   TransactionV0
   (sourceAccountEd25519 fee seqNum timeBounds memo operations ext)
   #:transparent)
  (struct AlphaNum4 (assetCode issuer) #:transparent)
  (define-grammar
   (the-grammar)
   (Claimant-rule
    (choose
     (union
      (bv CLAIMANT_TYPE_V0 (?? (bitvector 32)))
      (Claimant (AccountID-rule) (ClaimPredicate-rule)))))
   (ClaimableBalanceEntryExtensionV1-rule
    (ClaimableBalanceEntryExtensionV1
     (choose (union (bv 0 (?? (bitvector 32))) null))
     (uint32-rule)))
   (SponsorshipDescriptor-rule
    (choose
     (union (bv TRUE (?? (bitvector 32))) (AccountID-rule))
     (union (bv FALSE (?? (bitvector 32))) null)))
   (AssetCode12-rule
    (list
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))))
   (AlphaNum12-rule (AlphaNum12 (AssetCode12-rule) (AccountID-rule)))
   (Memo-rule
    (choose
     (union (bv MEMO_NONE (?? (bitvector 32))) null)
     (union
      (bv MEMO_TEXT (?? (bitvector 32)))
      (vector (?? (bitvector 8)) (?? (bitvector 8))))
     (union (bv MEMO_ID (?? (bitvector 32))) (uint64-rule))
     (union (bv MEMO_HASH (?? (bitvector 32))) (Hash-rule))
     (union (bv MEMO_RETURN (?? (bitvector 32))) (Hash-rule))))
   (RevokeSponsorshipOp-rule
    (choose
     (union
      (bv REVOKE_SPONSORSHIP_LEDGER_ENTRY (?? (bitvector 32)))
      (LedgerKey-rule))
     (union
      (bv REVOKE_SPONSORSHIP_SIGNER (?? (bitvector 32)))
      (RevokeSponsorshipOp (AccountID-rule) (SignerKey-rule)))))
   (AssetCode-rule
    (choose
     (union
      (bv ASSET_TYPE_CREDIT_ALPHANUM4 (?? (bitvector 32)))
      (AssetCode4-rule))
     (union
      (bv ASSET_TYPE_CREDIT_ALPHANUM12 (?? (bitvector 32)))
      (AssetCode12-rule))))
   (TransactionV1Envelope-rule
    (TransactionV1Envelope
     (Transaction-rule)
     (vector (DecoratedSignature-rule) (DecoratedSignature-rule))))
   (AccountEntry-rule
    (AccountEntry
     (AccountID-rule)
     (int64-rule)
     (SequenceNumber-rule)
     (uint32-rule)
     (choose
      (union (bv TRUE (?? (bitvector 32))) (AccountID-rule))
      (union (bv FALSE (?? (bitvector 32))) null))
     (uint32-rule)
     (string32-rule)
     (Thresholds-rule)
     (vector (Signer-rule) (Signer-rule))
     (choose
      (union (bv 0 (?? (bitvector 32))) null)
      (union (bv 1 (?? (bitvector 32))) (AccountEntryExtensionV1-rule)))))
   (LiquidityPoolEntry-rule
    (LiquidityPoolEntry
     (PoolID-rule)
     (choose
      (union
       (bv LIQUIDITY_POOL_CONSTANT_PRODUCT (?? (bitvector 32)))
       (LiquidityPoolEntry
        (LiquidityPoolConstantProductParameters-rule)
        (int64-rule)
        (int64-rule)
        (int64-rule)
        (int64-rule))))))
   (CreatePassiveSellOfferOp-rule
    (CreatePassiveSellOfferOp
     (Asset-rule)
     (Asset-rule)
     (int64-rule)
     (Price-rule)))
   (CreateClaimableBalanceOp-rule
    (CreateClaimableBalanceOp
     (Asset-rule)
     (int64-rule)
     (vector (Claimant-rule) (Claimant-rule))))
   (PoolID-rule (Hash-rule))
   (PathPaymentStrictSendOp-rule
    (PathPaymentStrictSendOp
     (Asset-rule)
     (int64-rule)
     (MuxedAccount-rule)
     (Asset-rule)
     (int64-rule)
     (vector (Asset-rule) (Asset-rule))))
   (TimeBounds-rule (TimeBounds (TimePoint-rule) (TimePoint-rule)))
   (string64-rule (vector (?? (bitvector 8)) (?? (bitvector 8))))
   (DataEntry-rule
    (DataEntry
     (AccountID-rule)
     (string64-rule)
     (DataValue-rule)
     (choose (union (bv 0 (?? (bitvector 32))) null))))
   (ManageBuyOfferOp-rule
    (ManageBuyOfferOp
     (Asset-rule)
     (Asset-rule)
     (int64-rule)
     (Price-rule)
     (int64-rule)))
   (DataValue-rule (vector (?? (bitvector 8)) (?? (bitvector 8))))
   (PaymentOp-rule (PaymentOp (MuxedAccount-rule) (Asset-rule) (int64-rule)))
   (ClaimableBalanceEntry-rule
    (ClaimableBalanceEntry
     (ClaimableBalanceID-rule)
     (vector (Claimant-rule) (Claimant-rule))
     (Asset-rule)
     (int64-rule)
     (choose
      (union (bv 0 (?? (bitvector 32))) null)
      (union
       (bv 1 (?? (bitvector 32)))
       (ClaimableBalanceEntryExtensionV1-rule)))))
   (Transaction-rule
    (Transaction
     (MuxedAccount-rule)
     (uint32-rule)
     (SequenceNumber-rule)
     (choose
      (union (bv TRUE (?? (bitvector 32))) (TimeBounds-rule))
      (union (bv FALSE (?? (bitvector 32))) null))
     (Memo-rule)
     (vector (Operation-rule) (Operation-rule))
     (choose (union (bv 0 (?? (bitvector 32))) null))))
   (Signer-rule (Signer (SignerKey-rule) (uint32-rule)))
   (TrustLineEntry-rule
    (TrustLineEntry
     (AccountID-rule)
     (TrustLineAsset-rule)
     (int64-rule)
     (int64-rule)
     (uint32-rule)
     (choose
      (union (bv 0 (?? (bitvector 32))) null)
      (union
       (bv 1 (?? (bitvector 32)))
       (TrustLineEntry
        (Liabilities-rule)
        (choose
         (union (bv 0 (?? (bitvector 32))) null)
         (union
          (bv 2 (?? (bitvector 32)))
          (TrustLineEntryExtensionV2-rule))))))))
   (BeginSponsoringFutureReservesOp-rule
    (BeginSponsoringFutureReservesOp (AccountID-rule)))
   (string32-rule (vector (?? (bitvector 8)) (?? (bitvector 8))))
   (LedgerEntry-rule
    (LedgerEntry
     (uint32-rule)
     (choose
      (union (bv ACCOUNT (?? (bitvector 32))) (AccountEntry-rule))
      (union (bv TRUSTLINE (?? (bitvector 32))) (TrustLineEntry-rule))
      (union (bv OFFER (?? (bitvector 32))) (OfferEntry-rule))
      (union (bv DATA (?? (bitvector 32))) (DataEntry-rule))
      (union
       (bv CLAIMABLE_BALANCE (?? (bitvector 32)))
       (ClaimableBalanceEntry-rule))
      (union
       (bv LIQUIDITY_POOL (?? (bitvector 32)))
       (LiquidityPoolEntry-rule)))
     (choose
      (union (bv 0 (?? (bitvector 32))) null)
      (union (bv 1 (?? (bitvector 32))) (LedgerEntryExtensionV1-rule)))))
   (Signature-rule (vector (?? (bitvector 8)) (?? (bitvector 8))))
   (ClaimClaimableBalanceOp-rule
    (ClaimClaimableBalanceOp (ClaimableBalanceID-rule)))
   (AllowTrustOp-rule
    (AllowTrustOp (AccountID-rule) (AssetCode-rule) (uint32-rule)))
   (LedgerKey-rule
    (choose
     (union (bv ACCOUNT (?? (bitvector 32))) (LedgerKey (AccountID-rule)))
     (union
      (bv TRUSTLINE (?? (bitvector 32)))
      (LedgerKey (AccountID-rule) (TrustLineAsset-rule)))
     (union
      (bv OFFER (?? (bitvector 32)))
      (LedgerKey (AccountID-rule) (int64-rule)))
     (union
      (bv DATA (?? (bitvector 32)))
      (LedgerKey (AccountID-rule) (string64-rule)))
     (union
      (bv CLAIMABLE_BALANCE (?? (bitvector 32)))
      (LedgerKey (ClaimableBalanceID-rule)))
     (union
      (bv LIQUIDITY_POOL (?? (bitvector 32)))
      (LedgerKey (PoolID-rule)))))
   (BumpSequenceOp-rule (BumpSequenceOp (SequenceNumber-rule)))
   (Thresholds-rule
    (list
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))))
   (AccountID-rule (PublicKey-rule))
   (int64-rule (?? (bitvector 64)))
   (Operation-rule
    (Operation
     (choose
      (union (bv TRUE (?? (bitvector 32))) (MuxedAccount-rule))
      (union (bv FALSE (?? (bitvector 32))) null))
     (choose
      (union (bv CREATE_ACCOUNT (?? (bitvector 32))) (CreateAccountOp-rule))
      (union (bv PAYMENT (?? (bitvector 32))) (PaymentOp-rule))
      (union
       (bv PATH_PAYMENT_STRICT_RECEIVE (?? (bitvector 32)))
       (PathPaymentStrictReceiveOp-rule))
      (union
       (bv MANAGE_SELL_OFFER (?? (bitvector 32)))
       (ManageSellOfferOp-rule))
      (union
       (bv CREATE_PASSIVE_SELL_OFFER (?? (bitvector 32)))
       (CreatePassiveSellOfferOp-rule))
      (union (bv SET_OPTIONS (?? (bitvector 32))) (SetOptionsOp-rule))
      (union (bv CHANGE_TRUST (?? (bitvector 32))) (ChangeTrustOp-rule))
      (union (bv ALLOW_TRUST (?? (bitvector 32))) (AllowTrustOp-rule))
      (union (bv ACCOUNT_MERGE (?? (bitvector 32))) (MuxedAccount-rule))
      (union (bv INFLATION (?? (bitvector 32))) null)
      (union (bv MANAGE_DATA (?? (bitvector 32))) (ManageDataOp-rule))
      (union (bv BUMP_SEQUENCE (?? (bitvector 32))) (BumpSequenceOp-rule))
      (union (bv MANAGE_BUY_OFFER (?? (bitvector 32))) (ManageBuyOfferOp-rule))
      (union
       (bv PATH_PAYMENT_STRICT_SEND (?? (bitvector 32)))
       (PathPaymentStrictSendOp-rule))
      (union
       (bv CREATE_CLAIMABLE_BALANCE (?? (bitvector 32)))
       (CreateClaimableBalanceOp-rule))
      (union
       (bv CLAIM_CLAIMABLE_BALANCE (?? (bitvector 32)))
       (ClaimClaimableBalanceOp-rule))
      (union
       (bv BEGIN_SPONSORING_FUTURE_RESERVES (?? (bitvector 32)))
       (BeginSponsoringFutureReservesOp-rule))
      (union (bv END_SPONSORING_FUTURE_RESERVES (?? (bitvector 32))) null)
      (union
       (bv REVOKE_SPONSORSHIP (?? (bitvector 32)))
       (RevokeSponsorshipOp-rule))
      (union (bv CLAWBACK (?? (bitvector 32))) (ClawbackOp-rule))
      (union
       (bv CLAWBACK_CLAIMABLE_BALANCE (?? (bitvector 32)))
       (ClawbackClaimableBalanceOp-rule))
      (union
       (bv SET_TRUST_LINE_FLAGS (?? (bitvector 32)))
       (SetTrustLineFlagsOp-rule))
      (union
       (bv LIQUIDITY_POOL_DEPOSIT (?? (bitvector 32)))
       (LiquidityPoolDepositOp-rule))
      (union
       (bv LIQUIDITY_POOL_WITHDRAW (?? (bitvector 32)))
       (LiquidityPoolWithdrawOp-rule)))))
   (SignatureHint-rule
    (list
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))))
   (SequenceNumber-rule (int64-rule))
   (AccountEntryExtensionV2-rule
    (AccountEntryExtensionV2
     (uint32-rule)
     (uint32-rule)
     (vector (SponsorshipDescriptor-rule) (SponsorshipDescriptor-rule))
     (choose (union (bv 0 (?? (bitvector 32))) null))))
   (uint32-rule (?? (bitvector 32)))
   (SetTrustLineFlagsOp-rule
    (SetTrustLineFlagsOp
     (AccountID-rule)
     (Asset-rule)
     (uint32-rule)
     (uint32-rule)))
   (ClawbackClaimableBalanceOp-rule
    (ClawbackClaimableBalanceOp (ClaimableBalanceID-rule)))
   (int32-rule (?? (bitvector 32)))
   (LiquidityPoolDepositOp-rule
    (LiquidityPoolDepositOp
     (PoolID-rule)
     (int64-rule)
     (int64-rule)
     (Price-rule)
     (Price-rule)))
   (ChangeTrustAsset-rule
    (choose
     (union (bv ASSET_TYPE_NATIVE (?? (bitvector 32))) null)
     (union
      (bv ASSET_TYPE_CREDIT_ALPHANUM4 (?? (bitvector 32)))
      (AlphaNum4-rule))
     (union
      (bv ASSET_TYPE_CREDIT_ALPHANUM12 (?? (bitvector 32)))
      (AlphaNum12-rule))
     (union
      (bv ASSET_TYPE_POOL_SHARE (?? (bitvector 32)))
      (LiquidityPoolParameters-rule))))
   (PathPaymentStrictReceiveOp-rule
    (PathPaymentStrictReceiveOp
     (Asset-rule)
     (int64-rule)
     (MuxedAccount-rule)
     (Asset-rule)
     (int64-rule)
     (vector (Asset-rule) (Asset-rule))))
   (TransactionV0Envelope-rule
    (TransactionV0Envelope
     (TransactionV0-rule)
     (vector (DecoratedSignature-rule) (DecoratedSignature-rule))))
   (LedgerEntryExtensionV1-rule
    (LedgerEntryExtensionV1
     (SponsorshipDescriptor-rule)
     (choose (union (bv 0 (?? (bitvector 32))) null))))
   (ClawbackOp-rule (ClawbackOp (Asset-rule) (MuxedAccount-rule) (int64-rule)))
   (ClaimPredicate-rule
    (choose
     (union (bv CLAIM_PREDICATE_UNCONDITIONAL (?? (bitvector 32))) null)
     (union
      (bv CLAIM_PREDICATE_AND (?? (bitvector 32)))
      (vector (ClaimPredicate-rule) (ClaimPredicate-rule)))
     (union
      (bv CLAIM_PREDICATE_OR (?? (bitvector 32)))
      (vector (ClaimPredicate-rule) (ClaimPredicate-rule)))
     (union
      (bv CLAIM_PREDICATE_NOT (?? (bitvector 32)))
      (choose
       (union (bv TRUE (?? (bitvector 32))) (ClaimPredicate-rule))
       (union (bv FALSE (?? (bitvector 32))) null)))
     (union
      (bv CLAIM_PREDICATE_BEFORE_ABSOLUTE_TIME (?? (bitvector 32)))
      (int64-rule))
     (union
      (bv CLAIM_PREDICATE_BEFORE_RELATIVE_TIME (?? (bitvector 32)))
      (int64-rule))))
   (LiquidityPoolConstantProductParameters-rule
    (LiquidityPoolConstantProductParameters
     (Asset-rule)
     (Asset-rule)
     (int32-rule)))
   (LiquidityPoolWithdrawOp-rule
    (LiquidityPoolWithdrawOp
     (PoolID-rule)
     (int64-rule)
     (int64-rule)
     (int64-rule)))
   (ManageDataOp-rule
    (ManageDataOp
     (string64-rule)
     (choose
      (union (bv TRUE (?? (bitvector 32))) (DataValue-rule))
      (union (bv FALSE (?? (bitvector 32))) null))))
   (AlphaNum4-rule (AlphaNum4 (AssetCode4-rule) (AccountID-rule)))
   (uint256-rule
    (list
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))))
   (SignerKey-rule
    (choose
     (union (bv SIGNER_KEY_TYPE_ED25519 (?? (bitvector 32))) (uint256-rule))
     (union
      (bv SIGNER_KEY_TYPE_PRE_AUTH_TX (?? (bitvector 32)))
      (uint256-rule))
     (union (bv SIGNER_KEY_TYPE_HASH_X (?? (bitvector 32))) (uint256-rule))))
   (MuxedAccount-rule
    (choose
     (union (bv KEY_TYPE_ED25519 (?? (bitvector 32))) (uint256-rule))
     (union
      (bv KEY_TYPE_MUXED_ED25519 (?? (bitvector 32)))
      (MuxedAccount (uint64-rule) (uint256-rule)))))
   (LiquidityPoolParameters-rule
    (choose
     (union
      (bv LIQUIDITY_POOL_CONSTANT_PRODUCT (?? (bitvector 32)))
      (LiquidityPoolConstantProductParameters-rule))))
   (TimePoint-rule (uint64-rule))
   (Price-rule (Price (int32-rule) (int32-rule)))
   (Hash-rule
    (list
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))))
   (OfferEntry-rule
    (OfferEntry
     (AccountID-rule)
     (int64-rule)
     (Asset-rule)
     (Asset-rule)
     (int64-rule)
     (Price-rule)
     (uint32-rule)
     (choose (union (bv 0 (?? (bitvector 32))) null))))
   (SetOptionsOp-rule
    (SetOptionsOp
     (choose
      (union (bv TRUE (?? (bitvector 32))) (AccountID-rule))
      (union (bv FALSE (?? (bitvector 32))) null))
     (choose
      (union (bv TRUE (?? (bitvector 32))) (uint32-rule))
      (union (bv FALSE (?? (bitvector 32))) null))
     (choose
      (union (bv TRUE (?? (bitvector 32))) (uint32-rule))
      (union (bv FALSE (?? (bitvector 32))) null))
     (choose
      (union (bv TRUE (?? (bitvector 32))) (uint32-rule))
      (union (bv FALSE (?? (bitvector 32))) null))
     (choose
      (union (bv TRUE (?? (bitvector 32))) (uint32-rule))
      (union (bv FALSE (?? (bitvector 32))) null))
     (choose
      (union (bv TRUE (?? (bitvector 32))) (uint32-rule))
      (union (bv FALSE (?? (bitvector 32))) null))
     (choose
      (union (bv TRUE (?? (bitvector 32))) (uint32-rule))
      (union (bv FALSE (?? (bitvector 32))) null))
     (choose
      (union (bv TRUE (?? (bitvector 32))) (string32-rule))
      (union (bv FALSE (?? (bitvector 32))) null))
     (choose
      (union (bv TRUE (?? (bitvector 32))) (Signer-rule))
      (union (bv FALSE (?? (bitvector 32))) null))))
   (AssetCode4-rule
    (list
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))
     (?? (bitvector 8))))
   (FeeBumpTransactionEnvelope-rule
    (FeeBumpTransactionEnvelope
     (FeeBumpTransaction-rule)
     (vector (DecoratedSignature-rule) (DecoratedSignature-rule))))
   (PublicKey-rule
    (choose
     (union (bv PUBLIC_KEY_TYPE_ED25519 (?? (bitvector 32))) (uint256-rule))))
   (Asset-rule
    (choose
     (union (bv ASSET_TYPE_NATIVE (?? (bitvector 32))) null)
     (union
      (bv ASSET_TYPE_CREDIT_ALPHANUM4 (?? (bitvector 32)))
      (AlphaNum4-rule))
     (union
      (bv ASSET_TYPE_CREDIT_ALPHANUM12 (?? (bitvector 32)))
      (AlphaNum12-rule))))
   (FeeBumpTransaction-rule
    (FeeBumpTransaction
     (MuxedAccount-rule)
     (int64-rule)
     (choose
      (union
       (bv ENVELOPE_TYPE_TX (?? (bitvector 32)))
       (TransactionV1Envelope-rule)))
     (choose (union (bv 0 (?? (bitvector 32))) null))))
   (uint64-rule (?? (bitvector 64)))
   (CreateAccountOp-rule (CreateAccountOp (AccountID-rule) (int64-rule)))
   (TrustLineAsset-rule
    (choose
     (union (bv ASSET_TYPE_NATIVE (?? (bitvector 32))) null)
     (union
      (bv ASSET_TYPE_CREDIT_ALPHANUM4 (?? (bitvector 32)))
      (AlphaNum4-rule))
     (union
      (bv ASSET_TYPE_CREDIT_ALPHANUM12 (?? (bitvector 32)))
      (AlphaNum12-rule))
     (union (bv ASSET_TYPE_POOL_SHARE (?? (bitvector 32))) (PoolID-rule))))
   (ChangeTrustOp-rule (ChangeTrustOp (ChangeTrustAsset-rule) (int64-rule)))
   (TransactionEnvelope-rule
    (choose
     (union
      (bv ENVELOPE_TYPE_TX_V0 (?? (bitvector 32)))
      (TransactionV0Envelope-rule))
     (union
      (bv ENVELOPE_TYPE_TX (?? (bitvector 32)))
      (TransactionV1Envelope-rule))
     (union
      (bv ENVELOPE_TYPE_TX_FEE_BUMP (?? (bitvector 32)))
      (FeeBumpTransactionEnvelope-rule))))
   (AccountEntryExtensionV1-rule
    (AccountEntryExtensionV1
     (Liabilities-rule)
     (choose
      (union (bv 0 (?? (bitvector 32))) null)
      (union (bv 2 (?? (bitvector 32))) (AccountEntryExtensionV2-rule)))))
   (ManageSellOfferOp-rule
    (ManageSellOfferOp
     (Asset-rule)
     (Asset-rule)
     (int64-rule)
     (Price-rule)
     (int64-rule)))
   (DecoratedSignature-rule
    (DecoratedSignature (SignatureHint-rule) (Signature-rule)))
   (ClaimableBalanceID-rule
    (choose
     (union
      (bv CLAIMABLE_BALANCE_ID_TYPE_V0 (?? (bitvector 32)))
      (Hash-rule))))
   (Liabilities-rule (Liabilities (int64-rule) (int64-rule)))
   (TransactionV0-rule
    (TransactionV0
     (uint256-rule)
     (uint32-rule)
     (SequenceNumber-rule)
     (choose
      (union (bv TRUE (?? (bitvector 32))) (TimeBounds-rule))
      (union (bv FALSE (?? (bitvector 32))) null))
     (Memo-rule)
     (vector (Operation-rule) (Operation-rule))
     (choose (union (bv 0 (?? (bitvector 32))) null))))
   (TrustLineEntryExtensionV2-rule
    (TrustLineEntryExtensionV2
     (int32-rule)
     (choose (union (bv 0 (?? (bitvector 32))) null))))))