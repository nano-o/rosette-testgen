#lang rosette

(require rosette/lib/synthax)

(provide (all-defined-out))

(begin
  (define ASSET_TYPE_CREDIT_ALPHANUM12 2)
  (define txFAILED -1)
  (define SET_OPTIONS 5)
  (define CREATE_ACCOUNT_SUCCESS 0)
  (define MANAGE_BUY_OFFER_LOW_RESERVE -12)
  (define CREATE_CLAIMABLE_BALANCE_NO_TRUST -3)
  (define SCP_ST_NOMINATE 3)
  (define MANAGE_BUY_OFFER_UNDERFUNDED -7)
  (define CREATE_ACCOUNT 0)
  (define CLAIM_CLAIMABLE_BALANCE_LINE_FULL -3)
  (define LIQUIDITY_POOL_DEPOSIT_SUCCESS 0)
  (define CHANGE_TRUST_TRUST_LINE_MISSING -6)
  (define LEDGER_UPGRADE_BASE_RESERVE 4)
  (define ENVELOPE_TYPE_SCPVALUE 4)
  (define CREATE_CLAIMABLE_BALANCE_NOT_AUTHORIZED -4)
  (define CLAIM_PREDICATE_UNCONDITIONAL 0)
  (define STELLAR_VALUE_BASIC 0)
  (define PAYMENT_SRC_NOT_AUTHORIZED -4)
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
  (define ALLOW_TRUST_TRUST_NOT_REQUIRED -3)
  (define PATH_PAYMENT_STRICT_SEND_OFFER_CROSS_SELF -11)
  (define SET_OPTIONS_BAD_SIGNER -8)
  (define CREATE_ACCOUNT_UNDERFUNDED -2)
  (define REVOKE_SPONSORSHIP_LEDGER_ENTRY 0)
  (define MANAGE_SELL_OFFER_BUY_NO_TRUST -3)
  (define AUTHORIZED_TO_MAINTAIN_LIABILITIES_FLAG 2)
  (define opINNER 0)
  (define ACCOUNT_MERGE_NO_ACCOUNT -2)
  (define LEDGER_UPGRADE_BASE_FEE 2)
  (define KEY_TYPE_MUXED_ED25519 256)
  (define CLAIM_CLAIMABLE_BALANCE_NOT_AUTHORIZED -5)
  (define MANAGE_BUY_OFFER_SELL_NOT_AUTHORIZED -4)
  (define CLAIMANT_TYPE_V0 0)
  (define SET_OPTIONS_INVALID_INFLATION -4)
  (define txNO_ACCOUNT -8)
  (define MASK_ACCOUNT_FLAGS_V17 15)
  (define TRUSTLINE 1)
  (define PATH_PAYMENT_STRICT_RECEIVE_TOO_FEW_OFFERS -10)
  (define SCP_ST_EXTERNALIZE 2)
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
  (define CREATE_CLAIMABLE_BALANCE_MALFORMED -1)
  (define SCP_ST_CONFIRM 1)
  (define LIQUIDITY_POOL_DEPOSIT_NO_TRUST -2)
  (define MANAGE_SELL_OFFER_SELL_NOT_AUTHORIZED -4)
  (define AUTH_REVOCABLE_FLAG 2)
  (define PATH_PAYMENT_STRICT_SEND_SRC_NO_TRUST -3)
  (define ALLOW_TRUST_SELF_NOT_ALLOWED -5)
  (define CLAWBACK 19)
  (define PASSIVE_FLAG 1)
  (define REVOKE_SPONSORSHIP_LOW_RESERVE -3)
  (define INITENTRY 2)
  (define PAYMENT_NO_ISSUER -9)
  (define MANAGE_SELL_OFFER_SUCCESS 0)
  (define CLAIM_CLAIMABLE_BALANCE_CANNOT_CLAIM -2)
  (define PATH_PAYMENT_STRICT_RECEIVE_OFFER_CROSS_SELF -11)
  (define DEADENTRY 1)
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
  (define TRUE 1)
  (define MANAGE_DATA_INVALID_NAME -4)
  (define CLAIM_CLAIMABLE_BALANCE_NO_TRUST -4)
  (define ACCOUNT_MERGE_IS_SPONSOR -7)
  (define SET_OPTIONS_TOO_MANY_SIGNERS -2)
  (define PATH_PAYMENT_STRICT_SEND_SRC_NOT_AUTHORIZED -4)
  (define txBAD_AUTH -6)
  (define MANAGE_DATA_NAME_NOT_FOUND -2)
  (define PATH_PAYMENT_STRICT_SEND_NO_ISSUER -9)
  (define PATH_PAYMENT_STRICT_SEND_NO_TRUST -6)
  (define ACCOUNT_MERGE_SEQNUM_TOO_FAR -5)
  (define CHANGE_TRUST_LOW_RESERVE -4)
  (define SET_TRUST_LINE_FLAGS_MALFORMED -1)
  (define PAYMENT_NO_DESTINATION -5)
  (define MANAGE_DATA_NOT_SUPPORTED_YET -1)
  (define LIVEENTRY 0)
  (define MASK_LEDGER_HEADER_FLAGS 7)
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
  (define CLAWBACK_UNDERFUNDED -4)
  (define LEDGER_ENTRY_UPDATED 1)
  (define BEGIN_SPONSORING_FUTURE_RESERVES 16)
  (define LIQUIDITY_POOL_DEPOSIT_UNDERFUNDED -4)
  (define REVOKE_SPONSORSHIP_DOES_NOT_EXIST -1)
  (define PATH_PAYMENT_STRICT_SEND_TOO_FEW_OFFERS -10)
  (define AUTH_CLAWBACK_ENABLED_FLAG 8)
  (define LIQUIDITY_POOL 5)
  (define THRESHOLD_MASTER_WEIGHT 0)
  (define PATH_PAYMENT_STRICT_RECEIVE_OVER_SENDMAX -12)
  (define CHANGE_TRUST_NOT_AUTH_MAINTAIN_LIABILITIES -8)
  (define LEDGER_ENTRY_CREATED 0)
  (define opNOT_SUPPORTED -3)
  (define PATH_PAYMENT_STRICT_SEND_UNDER_DESTMIN -12)
  (define MANAGE_OFFER_UPDATED 1)
  (define THRESHOLD_LOW 1)
  (define STELLAR_VALUE_SIGNED 1)
  (define BEGIN_SPONSORING_FUTURE_RESERVES_MALFORMED -1)
  (define MASK_TRUSTLINE_FLAGS 1)
  (define PATH_PAYMENT_STRICT_SEND_NOT_AUTHORIZED -7)
  (define LIQUIDITY_POOL_DEPOSIT_MALFORMED -1)
  (define LIQUIDITY_POOL_WITHDRAW_LINE_FULL -4)
  (define txMISSING_OPERATION -4)
  (define LEDGER_ENTRY_STATE 3)
  (define LIQUIDITY_POOL_WITHDRAW_NO_TRUST -2)
  (define LIQUIDITY_POOL_WITHDRAW_UNDERFUNDED -3)
  (define LEDGER_UPGRADE_MAX_TX_SET_SIZE 3)
  (define LEDGER_ENTRY_REMOVED 2)
  (define DISABLE_LIQUIDITY_POOL_DEPOSIT_FLAG 2)
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
  (define DISABLE_LIQUIDITY_POOL_WITHDRAWAL_FLAG 4)
  (define DATA 3)
  (define LEDGER_UPGRADE_VERSION 1)
  (define SET_OPTIONS_UNKNOWN_FLAG -6)
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
  (define SCP_ST_PREPARE 0)
  (define FALSE 0)
  (define PAYMENT_MALFORMED -1)
  (define SET_TRUST_LINE_FLAGS_NO_TRUST_LINE -2)
  (define BUMP_SEQUENCE 11)
  (define MANAGE_OFFER_CREATED 0)
  (define SIGNER_KEY_TYPE_ED25519 0)
  (define SIGNER_KEY_TYPE_PRE_AUTH_TX 1)
  (define CLAIM_PREDICATE_AND 1)
  (define METAENTRY -1)
  (define CLAIM_ATOM_TYPE_V0 0)
  (define END_SPONSORING_FUTURE_RESERVES 17)
  (define OFFER 2)
  (define SET_OPTIONS_THRESHOLD_OUT_OF_RANGE -7)
  (define MANAGE_DATA_LOW_RESERVE -3)
  (define PATH_PAYMENT_STRICT_SEND_MALFORMED -1)
  (define LIQUIDITY_POOL_FEE_V18 30)
  (define LEDGER_UPGRADE_FLAGS 5)
  (define CREATE_ACCOUNT_ALREADY_EXIST -4)
  (define SET_OPTIONS_AUTH_REVOCABLE_REQUIRED -10)
  (define PAYMENT_SUCCESS 0)
  (define DISABLE_LIQUIDITY_POOL_TRADING_FLAG 1)
  (define ACCOUNT 0)
  (define LIQUIDITY_POOL_DEPOSIT_POOL_FULL -7)
  (define txBAD_SPONSORSHIP -14)
  (define txFEE_BUMP_INNER_SUCCESS 1)
  (define MANAGE_SELL_OFFER_LINE_FULL -6)
  (define PATH_PAYMENT_STRICT_SEND_NO_DESTINATION -5)
  (struct ClaimableBalanceEntryExtensionV1 (ext flags) #:transparent)
  (struct AlphaNum12 (assetCode issuer) #:transparent)
  (struct
   ClaimOfferAtom
   (sellerID offerID assetSold amountSold assetBought amountBought)
   #:transparent)
  (struct TransactionV1Envelope (tx signatures) #:transparent)
  (struct InnerTransactionResultPair (transactionHash result) #:transparent)
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
  (struct StellarValue (txSetHash closeTime upgrades ext) #:transparent)
  (struct CreatePassiveSellOfferOp (selling buying amount price) #:transparent)
  (struct LedgerKey::account (accountID) #:transparent)
  (struct CreateClaimableBalanceOp (asset amount claimants) #:transparent)
  (struct
   PathPaymentStrictSendOp
   (sendAsset sendAmount destination destAsset destMin path)
   #:transparent)
  (struct TimeBounds (minTime maxTime) #:transparent)
  (struct ManageOfferSuccessResult (offersClaimed offer) #:transparent)
  (struct DataEntry (accountID dataName dataValue ext) #:transparent)
  (struct
   ManageBuyOfferOp
   (selling buying buyAmount price offerID)
   #:transparent)
  (struct PathPaymentStrictSendResult::success (offers last) #:transparent)
  (struct
   TestCase
   (ledgerHeader ledgerEntries transactionEnvelopes)
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
  (struct SimplePaymentResult (destination asset amount) #:transparent)
  (struct LedgerKey::trustLine (accountID asset) #:transparent)
  (struct AllowTrustOp (trustor asset authorize) #:transparent)
  (struct BumpSequenceOp (bumpTo) #:transparent)
  (struct TrustLineEntry::ext::v1 (liabilities ext) #:transparent)
  (struct Operation (sourceAccount body) #:transparent)
  (struct
   AccountEntryExtensionV2
   (numSponsored numSponsoring signerSponsoringIDs ext)
   #:transparent)
  (struct TransactionResult (feeCharged result ext) #:transparent)
  (struct LedgerKey::liquidityPool (liquidityPoolID) #:transparent)
  (struct LedgerHeaderExtensionV1 (flags ext) #:transparent)
  (struct
   LedgerHeader
   (ledgerVersion
    previousLedgerHash
    scpValue
    txSetResultHash
    bucketListHash
    ledgerSeq
    totalCoins
    feePool
    inflationSeq
    idPool
    baseFee
    baseReserve
    maxTxSetSize
    skipList
    ext)
   #:transparent)
  (struct LedgerKey::offer (sellerID offerID) #:transparent)
  (struct Claimant::v0 (destination predicate) #:transparent)
  (struct
   ClaimOfferAtomV0
   (sellerEd25519 offerID assetSold amountSold assetBought amountBought)
   #:transparent)
  (struct
   SetTrustLineFlagsOp
   (trustor asset clearFlags setFlags)
   #:transparent)
  (struct ClawbackClaimableBalanceOp (balanceID) #:transparent)
  (struct
   LiquidityPoolDepositOp
   (liquidityPoolID maxAmountA maxAmountB minPrice maxPrice)
   #:transparent)
  (struct InflationPayout (destination amount) #:transparent)
  (struct
   PathPaymentStrictReceiveOp
   (sendAsset sendMax destination destAsset destAmount path)
   #:transparent)
  (struct ClawbackOp (asset from amount) #:transparent)
  (struct
   LiquidityPoolConstantProductParameters
   (assetA assetB fee)
   #:transparent)
  (struct LedgerEntryExtensionV1 (sponsoringID ext) #:transparent)
  (struct LedgerCloseValueSignature (nodeID signature) #:transparent)
  (struct
   LiquidityPoolWithdrawOp
   (liquidityPoolID amount minAmountA minAmountB)
   #:transparent)
  (struct ManageDataOp (dataName dataValue) #:transparent)
  (struct TransactionV0Envelope (tx signatures) #:transparent)
  (struct AlphaNum4 (assetCode issuer) #:transparent)
  (struct PathPaymentStrictReceiveResult::success (offers last) #:transparent)
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
  (struct
   ClaimLiquidityAtom
   (liquidityPoolID assetSold amountSold assetBought amountBought)
   #:transparent)
  (struct LedgerKey::data (accountID dataName) #:transparent)
  (struct Price (n d) #:transparent)
  (struct FeeBumpTransactionEnvelope (tx signatures) #:transparent)
  (struct InnerTransactionResult (feeCharged result ext) #:transparent)
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
  (struct TestCaseResult (transactionResults ledgerChanges) #:transparent)
  (struct Liabilities (buying selling) #:transparent)
  (struct
   TransactionV0
   (sourceAccountEd25519 fee seqNum timeBounds memo operations ext)
   #:transparent)
  (struct :byte-array: (value) #:transparent)
  (struct :union: (tag value) #:transparent)
  (define-grammar
   (the-grammar)
   (Claimant-rule
    (:union:
     (bv CLAIMANT_TYPE_V0 32)
     (Claimant::v0 (AccountID-rule) (ClaimPredicate-rule))))
   (ClaimableBalanceEntryExtensionV1-rule
    (ClaimableBalanceEntryExtensionV1 (:union: (bv 0 32) null) (uint32-rule)))
   (SponsorshipDescriptor-rule
    (choose
     (:union: (bv TRUE 32) (AccountID-rule))
     (:union: (bv FALSE 32) null)))
   (AllowTrustResult-rule
    (choose
     (:union: (bv ALLOW_TRUST_SUCCESS 32) null)
     (:union: (bv ALLOW_TRUST_LOW_RESERVE 32) null)
     (:union: (bv ALLOW_TRUST_SELF_NOT_ALLOWED 32) null)
     (:union: (bv ALLOW_TRUST_CANT_REVOKE 32) null)
     (:union: (bv ALLOW_TRUST_TRUST_NOT_REQUIRED 32) null)
     (:union: (bv ALLOW_TRUST_NO_TRUST_LINE 32) null)
     (:union: (bv ALLOW_TRUST_MALFORMED 32) null)))
   (AssetCode12-rule (:byte-array: (?? (bitvector 96))))
   (AlphaNum12-rule (AlphaNum12 (AssetCode12-rule) (AccountID-rule)))
   (Memo-rule
    (choose
     (:union: (bv MEMO_NONE 32) null)
     (:union: (bv MEMO_TEXT 32) (vector (?? (bitvector 8)) (?? (bitvector 8))))
     (:union: (bv MEMO_ID 32) (uint64-rule))
     (:union: (bv MEMO_HASH 32) (Hash-rule))
     (:union: (bv MEMO_RETURN 32) (Hash-rule))))
   (ClaimOfferAtom-rule
    (ClaimOfferAtom
     (AccountID-rule)
     (int64-rule)
     (Asset-rule)
     (int64-rule)
     (Asset-rule)
     (int64-rule)))
   (RevokeSponsorshipOp-rule
    (choose
     (:union: (bv REVOKE_SPONSORSHIP_LEDGER_ENTRY 32) (LedgerKey-rule))
     (:union:
      (bv REVOKE_SPONSORSHIP_SIGNER 32)
      (RevokeSponsorshipOp::signer (AccountID-rule) (SignerKey-rule)))))
   (AssetCode-rule
    (choose
     (:union: (bv ASSET_TYPE_CREDIT_ALPHANUM4 32) (AssetCode4-rule))
     (:union: (bv ASSET_TYPE_CREDIT_ALPHANUM12 32) (AssetCode12-rule))))
   (TransactionV1Envelope-rule
    (TransactionV1Envelope
     (Transaction-rule)
     (vector (DecoratedSignature-rule) (DecoratedSignature-rule))))
   (SetTrustLineFlagsResult-rule
    (choose
     (:union: (bv SET_TRUST_LINE_FLAGS_SUCCESS 32) null)
     (:union: (bv SET_TRUST_LINE_FLAGS_LOW_RESERVE 32) null)
     (:union: (bv SET_TRUST_LINE_FLAGS_INVALID_STATE 32) null)
     (:union: (bv SET_TRUST_LINE_FLAGS_CANT_REVOKE 32) null)
     (:union: (bv SET_TRUST_LINE_FLAGS_NO_TRUST_LINE 32) null)
     (:union: (bv SET_TRUST_LINE_FLAGS_MALFORMED 32) null)))
   (InnerTransactionResultPair-rule
    (InnerTransactionResultPair (Hash-rule) (InnerTransactionResult-rule)))
   (AccountEntry-rule
    (AccountEntry
     (AccountID-rule)
     (int64-rule)
     (SequenceNumber-rule)
     (uint32-rule)
     (choose
      (:union: (bv TRUE 32) (AccountID-rule))
      (:union: (bv FALSE 32) null))
     (uint32-rule)
     (string32-rule)
     (Thresholds-rule)
     (vector (Signer-rule) (Signer-rule))
     (choose
      (:union: (bv 0 32) null)
      (:union: (bv 1 32) (AccountEntryExtensionV1-rule)))))
   (LiquidityPoolEntry-rule
    (LiquidityPoolEntry
     (PoolID-rule)
     (:union:
      (bv LIQUIDITY_POOL_CONSTANT_PRODUCT 32)
      (LiquidityPoolEntry::body::constantProduct
       (LiquidityPoolConstantProductParameters-rule)
       (int64-rule)
       (int64-rule)
       (int64-rule)
       (int64-rule)))))
   (CreatePassiveSellOfferOp-rule
    (CreatePassiveSellOfferOp
     (Asset-rule)
     (Asset-rule)
     (int64-rule)
     (Price-rule)))
   (ClawbackClaimableBalanceResult-rule
    (choose
     (:union: (bv CLAWBACK_CLAIMABLE_BALANCE_SUCCESS 32) null)
     (:union: (bv CLAWBACK_CLAIMABLE_BALANCE_NOT_CLAWBACK_ENABLED 32) null)
     (:union: (bv CLAWBACK_CLAIMABLE_BALANCE_NOT_ISSUER 32) null)
     (:union: (bv CLAWBACK_CLAIMABLE_BALANCE_DOES_NOT_EXIST 32) null)))
   (CreateClaimableBalanceOp-rule
    (CreateClaimableBalanceOp
     (Asset-rule)
     (int64-rule)
     (vector (Claimant-rule) (Claimant-rule))))
   (LedgerEntryChange-rule
    (choose
     (:union: (bv LEDGER_ENTRY_CREATED 32) (LedgerEntry-rule))
     (:union: (bv LEDGER_ENTRY_UPDATED 32) (LedgerEntry-rule))
     (:union: (bv LEDGER_ENTRY_REMOVED 32) (LedgerKey-rule))
     (:union: (bv LEDGER_ENTRY_STATE 32) (LedgerEntry-rule))))
   (StellarValue-rule
    (StellarValue
     (Hash-rule)
     (TimePoint-rule)
     (vector (UpgradeType-rule) (UpgradeType-rule))
     (choose
      (:union: (bv STELLAR_VALUE_BASIC 32) null)
      (:union:
       (bv STELLAR_VALUE_SIGNED 32)
       (LedgerCloseValueSignature-rule)))))
   (ChangeTrustResult-rule
    (choose
     (:union: (bv CHANGE_TRUST_SUCCESS 32) null)
     (:union: (bv CHANGE_TRUST_NOT_AUTH_MAINTAIN_LIABILITIES 32) null)
     (:union: (bv CHANGE_TRUST_CANNOT_DELETE 32) null)
     (:union: (bv CHANGE_TRUST_TRUST_LINE_MISSING 32) null)
     (:union: (bv CHANGE_TRUST_SELF_NOT_ALLOWED 32) null)
     (:union: (bv CHANGE_TRUST_LOW_RESERVE 32) null)
     (:union: (bv CHANGE_TRUST_INVALID_LIMIT 32) null)
     (:union: (bv CHANGE_TRUST_NO_ISSUER 32) null)
     (:union: (bv CHANGE_TRUST_MALFORMED 32) null)))
   (ManageOfferSuccessResult-rule
    (ManageOfferSuccessResult
     (vector (ClaimAtom-rule) (ClaimAtom-rule))
     (choose
      (:union: (bv MANAGE_OFFER_CREATED 32) (OfferEntry-rule))
      (:union: (bv MANAGE_OFFER_UPDATED 32) (OfferEntry-rule))
      (:union: (bv MANAGE_OFFER_DELETED 32) null))))
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
     (:union: (bv 0 32) null)))
   (ManageBuyOfferOp-rule
    (ManageBuyOfferOp
     (Asset-rule)
     (Asset-rule)
     (int64-rule)
     (Price-rule)
     (int64-rule)))
   (TestCase-rule
    (TestCase
     (LedgerHeader-rule)
     (vector (LedgerEntry-rule) (LedgerEntry-rule))
     (vector (TransactionEnvelope-rule))))
   (DataValue-rule (vector (?? (bitvector 8)) (?? (bitvector 8))))
   (LiquidityPoolWithdrawResult-rule
    (choose
     (:union: (bv LIQUIDITY_POOL_WITHDRAW_SUCCESS 32) null)
     (:union: (bv LIQUIDITY_POOL_WITHDRAW_UNDER_MINIMUM 32) null)
     (:union: (bv LIQUIDITY_POOL_WITHDRAW_LINE_FULL 32) null)
     (:union: (bv LIQUIDITY_POOL_WITHDRAW_UNDERFUNDED 32) null)
     (:union: (bv LIQUIDITY_POOL_WITHDRAW_NO_TRUST 32) null)
     (:union: (bv LIQUIDITY_POOL_WITHDRAW_MALFORMED 32) null)))
   (PaymentOp-rule (PaymentOp (MuxedAccount-rule) (Asset-rule) (int64-rule)))
   (Transaction-rule
    (Transaction
     (MuxedAccount-rule)
     (uint32-rule)
     (SequenceNumber-rule)
     (choose
      (:union: (bv TRUE 32) (TimeBounds-rule))
      (:union: (bv FALSE 32) null))
     (Memo-rule)
     (vector (Operation-rule))
     (:union: (bv 0 32) null)))
   (Signer-rule (Signer (SignerKey-rule) (uint32-rule)))
   (TrustLineEntry-rule
    (TrustLineEntry
     (AccountID-rule)
     (TrustLineAsset-rule)
     (int64-rule)
     (int64-rule)
     (uint32-rule)
     (choose
      (:union: (bv 0 32) null)
      (:union:
       (bv 1 32)
       (TrustLineEntry::ext::v1
        (Liabilities-rule)
        (choose
         (:union: (bv 0 32) null)
         (:union: (bv 2 32) (TrustLineEntryExtensionV2-rule))))))))
   (BeginSponsoringFutureReservesOp-rule
    (BeginSponsoringFutureReservesOp (AccountID-rule)))
   (string32-rule (vector (?? (bitvector 8)) (?? (bitvector 8))))
   (LedgerEntry-rule
    (LedgerEntry
     (uint32-rule)
     (choose
      (:union: (bv ACCOUNT 32) (AccountEntry-rule))
      (:union: (bv TRUSTLINE 32) (TrustLineEntry-rule))
      (:union: (bv OFFER 32) (OfferEntry-rule))
      (:union: (bv DATA 32) (DataEntry-rule))
      (:union: (bv CLAIMABLE_BALANCE 32) (ClaimableBalanceEntry-rule))
      (:union: (bv LIQUIDITY_POOL 32) (LiquidityPoolEntry-rule)))
     (choose
      (:union: (bv 0 32) null)
      (:union: (bv 1 32) (LedgerEntryExtensionV1-rule)))))
   (ClaimableBalanceEntry-rule
    (ClaimableBalanceEntry
     (ClaimableBalanceID-rule)
     (vector (Claimant-rule) (Claimant-rule))
     (Asset-rule)
     (int64-rule)
     (choose
      (:union: (bv 0 32) null)
      (:union: (bv 1 32) (ClaimableBalanceEntryExtensionV1-rule)))))
   (InflationResult-rule
    (choose
     (:union:
      (bv INFLATION_SUCCESS 32)
      (vector (InflationPayout-rule) (InflationPayout-rule)))
     (:union: (bv INFLATION_NOT_TIME 32) null)))
   (CreateAccountResult-rule
    (choose
     (:union: (bv CREATE_ACCOUNT_SUCCESS 32) null)
     (:union: (bv CREATE_ACCOUNT_ALREADY_EXIST 32) null)
     (:union: (bv CREATE_ACCOUNT_LOW_RESERVE 32) null)
     (:union: (bv CREATE_ACCOUNT_UNDERFUNDED 32) null)
     (:union: (bv CREATE_ACCOUNT_MALFORMED 32) null)))
   (UpgradeType-rule (vector (?? (bitvector 8)) (?? (bitvector 8))))
   (Signature-rule (vector (?? (bitvector 8)) (?? (bitvector 8))))
   (BeginSponsoringFutureReservesResult-rule
    (choose
     (:union: (bv BEGIN_SPONSORING_FUTURE_RESERVES_SUCCESS 32) null)
     (:union: (bv BEGIN_SPONSORING_FUTURE_RESERVES_RECURSIVE 32) null)
     (:union: (bv BEGIN_SPONSORING_FUTURE_RESERVES_ALREADY_SPONSORED 32) null)
     (:union: (bv BEGIN_SPONSORING_FUTURE_RESERVES_MALFORMED 32) null)))
   (ClaimClaimableBalanceOp-rule
    (ClaimClaimableBalanceOp (ClaimableBalanceID-rule)))
   (SimplePaymentResult-rule
    (SimplePaymentResult (AccountID-rule) (Asset-rule) (int64-rule)))
   (BumpSequenceResult-rule
    (choose
     (:union: (bv BUMP_SEQUENCE_SUCCESS 32) null)
     (:union: (bv BUMP_SEQUENCE_BAD_SEQ 32) null)))
   (AllowTrustOp-rule
    (AllowTrustOp (AccountID-rule) (AssetCode-rule) (uint32-rule)))
   (ClaimAtom-rule
    (choose
     (:union: (bv CLAIM_ATOM_TYPE_V0 32) (ClaimOfferAtomV0-rule))
     (:union: (bv CLAIM_ATOM_TYPE_ORDER_BOOK 32) (ClaimOfferAtom-rule))
     (:union:
      (bv CLAIM_ATOM_TYPE_LIQUIDITY_POOL 32)
      (ClaimLiquidityAtom-rule))))
   (LedgerKey-rule
    (choose
     (:union: (bv ACCOUNT 32) (LedgerKey::account (AccountID-rule)))
     (:union:
      (bv TRUSTLINE 32)
      (LedgerKey::trustLine (AccountID-rule) (TrustLineAsset-rule)))
     (:union: (bv OFFER 32) (LedgerKey::offer (AccountID-rule) (int64-rule)))
     (:union: (bv DATA 32) (LedgerKey::data (AccountID-rule) (string64-rule)))
     (:union:
      (bv CLAIMABLE_BALANCE 32)
      (LedgerKey::claimableBalance (ClaimableBalanceID-rule)))
     (:union:
      (bv LIQUIDITY_POOL 32)
      (LedgerKey::liquidityPool (PoolID-rule)))))
   (LiquidityPoolDepositResult-rule
    (choose
     (:union: (bv LIQUIDITY_POOL_DEPOSIT_SUCCESS 32) null)
     (:union: (bv LIQUIDITY_POOL_DEPOSIT_POOL_FULL 32) null)
     (:union: (bv LIQUIDITY_POOL_DEPOSIT_BAD_PRICE 32) null)
     (:union: (bv LIQUIDITY_POOL_DEPOSIT_LINE_FULL 32) null)
     (:union: (bv LIQUIDITY_POOL_DEPOSIT_UNDERFUNDED 32) null)
     (:union: (bv LIQUIDITY_POOL_DEPOSIT_NOT_AUTHORIZED 32) null)
     (:union: (bv LIQUIDITY_POOL_DEPOSIT_NO_TRUST 32) null)
     (:union: (bv LIQUIDITY_POOL_DEPOSIT_MALFORMED 32) null)))
   (ManageDataResult-rule
    (choose
     (:union: (bv MANAGE_DATA_SUCCESS 32) null)
     (:union: (bv MANAGE_DATA_INVALID_NAME 32) null)
     (:union: (bv MANAGE_DATA_LOW_RESERVE 32) null)
     (:union: (bv MANAGE_DATA_NAME_NOT_FOUND 32) null)
     (:union: (bv MANAGE_DATA_NOT_SUPPORTED_YET 32) null)))
   (BumpSequenceOp-rule (BumpSequenceOp (SequenceNumber-rule)))
   (Thresholds-rule (:byte-array: (?? (bitvector 32))))
   (AccountID-rule (PublicKey-rule))
   (ManageBuyOfferResult-rule
    (choose
     (:union: (bv MANAGE_BUY_OFFER_SUCCESS 32) (ManageOfferSuccessResult-rule))
     (:union: (bv MANAGE_BUY_OFFER_LOW_RESERVE 32) null)
     (:union: (bv MANAGE_BUY_OFFER_NOT_FOUND 32) null)
     (:union: (bv MANAGE_BUY_OFFER_BUY_NO_ISSUER 32) null)
     (:union: (bv MANAGE_BUY_OFFER_SELL_NO_ISSUER 32) null)
     (:union: (bv MANAGE_BUY_OFFER_CROSS_SELF 32) null)
     (:union: (bv MANAGE_BUY_OFFER_UNDERFUNDED 32) null)
     (:union: (bv MANAGE_BUY_OFFER_LINE_FULL 32) null)
     (:union: (bv MANAGE_BUY_OFFER_BUY_NOT_AUTHORIZED 32) null)
     (:union: (bv MANAGE_BUY_OFFER_SELL_NOT_AUTHORIZED 32) null)
     (:union: (bv MANAGE_BUY_OFFER_BUY_NO_TRUST 32) null)
     (:union: (bv MANAGE_BUY_OFFER_SELL_NO_TRUST 32) null)
     (:union: (bv MANAGE_BUY_OFFER_MALFORMED 32) null)))
   (int64-rule (?? (bitvector 64)))
   (Operation-rule
    (Operation
     (choose
      (:union: (bv TRUE 32) (MuxedAccount-rule))
      (:union: (bv FALSE 32) null))
     (choose
      (:union: (bv CREATE_ACCOUNT 32) (CreateAccountOp-rule))
      (:union: (bv PAYMENT 32) (PaymentOp-rule))
      (:union:
       (bv PATH_PAYMENT_STRICT_RECEIVE 32)
       (PathPaymentStrictReceiveOp-rule))
      (:union: (bv MANAGE_SELL_OFFER 32) (ManageSellOfferOp-rule))
      (:union:
       (bv CREATE_PASSIVE_SELL_OFFER 32)
       (CreatePassiveSellOfferOp-rule))
      (:union: (bv SET_OPTIONS 32) (SetOptionsOp-rule))
      (:union: (bv CHANGE_TRUST 32) (ChangeTrustOp-rule))
      (:union: (bv ALLOW_TRUST 32) (AllowTrustOp-rule))
      (:union: (bv ACCOUNT_MERGE 32) (MuxedAccount-rule))
      (:union: (bv INFLATION 32) null)
      (:union: (bv MANAGE_DATA 32) (ManageDataOp-rule))
      (:union: (bv BUMP_SEQUENCE 32) (BumpSequenceOp-rule))
      (:union: (bv MANAGE_BUY_OFFER 32) (ManageBuyOfferOp-rule))
      (:union: (bv PATH_PAYMENT_STRICT_SEND 32) (PathPaymentStrictSendOp-rule))
      (:union:
       (bv CREATE_CLAIMABLE_BALANCE 32)
       (CreateClaimableBalanceOp-rule))
      (:union: (bv CLAIM_CLAIMABLE_BALANCE 32) (ClaimClaimableBalanceOp-rule))
      (:union:
       (bv BEGIN_SPONSORING_FUTURE_RESERVES 32)
       (BeginSponsoringFutureReservesOp-rule))
      (:union: (bv END_SPONSORING_FUTURE_RESERVES 32) null)
      (:union: (bv REVOKE_SPONSORSHIP 32) (RevokeSponsorshipOp-rule))
      (:union: (bv CLAWBACK 32) (ClawbackOp-rule))
      (:union:
       (bv CLAWBACK_CLAIMABLE_BALANCE 32)
       (ClawbackClaimableBalanceOp-rule))
      (:union: (bv SET_TRUST_LINE_FLAGS 32) (SetTrustLineFlagsOp-rule))
      (:union: (bv LIQUIDITY_POOL_DEPOSIT 32) (LiquidityPoolDepositOp-rule))
      (:union:
       (bv LIQUIDITY_POOL_WITHDRAW 32)
       (LiquidityPoolWithdrawOp-rule)))))
   (SignatureHint-rule (:byte-array: (?? (bitvector 32))))
   (SequenceNumber-rule (int64-rule))
   (AccountEntryExtensionV2-rule
    (AccountEntryExtensionV2
     (uint32-rule)
     (uint32-rule)
     (vector (SponsorshipDescriptor-rule) (SponsorshipDescriptor-rule))
     (:union: (bv 0 32) null)))
   (TransactionResult-rule
    (TransactionResult
     (int64-rule)
     (choose
      (:union:
       (bv txFEE_BUMP_INNER_SUCCESS 32)
       (InnerTransactionResultPair-rule))
      (:union:
       (bv txFEE_BUMP_INNER_FAILED 32)
       (InnerTransactionResultPair-rule))
      (:union:
       (bv txSUCCESS 32)
       (vector (OperationResult-rule) (OperationResult-rule)))
      (:union:
       (bv txFAILED 32)
       (vector (OperationResult-rule) (OperationResult-rule)))
      (:union: (bv txBAD_SPONSORSHIP 32) null)
      (:union: (bv txNOT_SUPPORTED 32) null)
      (:union: (bv txINTERNAL_ERROR 32) null)
      (:union: (bv txBAD_AUTH_EXTRA 32) null)
      (:union: (bv txINSUFFICIENT_FEE 32) null)
      (:union: (bv txNO_ACCOUNT 32) null)
      (:union: (bv txINSUFFICIENT_BALANCE 32) null)
      (:union: (bv txBAD_AUTH 32) null)
      (:union: (bv txBAD_SEQ 32) null)
      (:union: (bv txMISSING_OPERATION 32) null)
      (:union: (bv txTOO_LATE 32) null)
      (:union: (bv txTOO_EARLY 32) null))
     (:union: (bv 0 32) null)))
   (uint32-rule (?? (bitvector 32)))
   (ClaimOfferAtomV0-rule
    (ClaimOfferAtomV0
     (uint256-rule)
     (int64-rule)
     (Asset-rule)
     (int64-rule)
     (Asset-rule)
     (int64-rule)))
   (ClawbackClaimableBalanceOp-rule
    (ClawbackClaimableBalanceOp (ClaimableBalanceID-rule)))
   (int32-rule (?? (bitvector 32)))
   (RevokeSponsorshipResult-rule
    (choose
     (:union: (bv REVOKE_SPONSORSHIP_SUCCESS 32) null)
     (:union: (bv REVOKE_SPONSORSHIP_MALFORMED 32) null)
     (:union: (bv REVOKE_SPONSORSHIP_ONLY_TRANSFERABLE 32) null)
     (:union: (bv REVOKE_SPONSORSHIP_LOW_RESERVE 32) null)
     (:union: (bv REVOKE_SPONSORSHIP_NOT_SPONSOR 32) null)
     (:union: (bv REVOKE_SPONSORSHIP_DOES_NOT_EXIST 32) null)))
   (EndSponsoringFutureReservesResult-rule
    (choose
     (:union: (bv END_SPONSORING_FUTURE_RESERVES_SUCCESS 32) null)
     (:union: (bv END_SPONSORING_FUTURE_RESERVES_NOT_SPONSORED 32) null)))
   (SetTrustLineFlagsOp-rule
    (SetTrustLineFlagsOp
     (AccountID-rule)
     (Asset-rule)
     (uint32-rule)
     (uint32-rule)))
   (LiquidityPoolDepositOp-rule
    (LiquidityPoolDepositOp
     (PoolID-rule)
     (int64-rule)
     (int64-rule)
     (Price-rule)
     (Price-rule)))
   (ChangeTrustAsset-rule
    (choose
     (:union: (bv ASSET_TYPE_NATIVE 32) null)
     (:union: (bv ASSET_TYPE_CREDIT_ALPHANUM4 32) (AlphaNum4-rule))
     (:union: (bv ASSET_TYPE_CREDIT_ALPHANUM12 32) (AlphaNum12-rule))
     (:union: (bv ASSET_TYPE_POOL_SHARE 32) (LiquidityPoolParameters-rule))))
   (LedgerHeaderExtensionV1-rule
    (LedgerHeaderExtensionV1 (uint32-rule) (:union: (bv 0 32) null)))
   (LedgerHeader-rule
    (LedgerHeader
     (uint32-rule)
     (Hash-rule)
     (StellarValue-rule)
     (Hash-rule)
     (Hash-rule)
     (uint32-rule)
     (int64-rule)
     (int64-rule)
     (uint32-rule)
     (uint64-rule)
     (uint32-rule)
     (uint32-rule)
     (uint32-rule)
     (list (Hash-rule) (Hash-rule) (Hash-rule) (Hash-rule))
     (choose
      (:union: (bv 0 32) null)
      (:union: (bv 1 32) (LedgerHeaderExtensionV1-rule)))))
   (TransactionV0Envelope-rule
    (TransactionV0Envelope
     (TransactionV0-rule)
     (vector (DecoratedSignature-rule) (DecoratedSignature-rule))))
   (NodeID-rule (PublicKey-rule))
   (InflationPayout-rule (InflationPayout (AccountID-rule) (int64-rule)))
   (PathPaymentStrictReceiveOp-rule
    (PathPaymentStrictReceiveOp
     (Asset-rule)
     (int64-rule)
     (MuxedAccount-rule)
     (Asset-rule)
     (int64-rule)
     (vector (Asset-rule) (Asset-rule))))
   (ClawbackResult-rule
    (choose
     (:union: (bv CLAWBACK_SUCCESS 32) null)
     (:union: (bv CLAWBACK_UNDERFUNDED 32) null)
     (:union: (bv CLAWBACK_NO_TRUST 32) null)
     (:union: (bv CLAWBACK_NOT_CLAWBACK_ENABLED 32) null)
     (:union: (bv CLAWBACK_MALFORMED 32) null)))
   (ClawbackOp-rule (ClawbackOp (Asset-rule) (MuxedAccount-rule) (int64-rule)))
   (ClaimPredicate-rule
    (choose
     (:union: (bv CLAIM_PREDICATE_UNCONDITIONAL 32) null)
     (:union: (bv CLAIM_PREDICATE_BEFORE_ABSOLUTE_TIME 32) (int64-rule))
     (:union: (bv CLAIM_PREDICATE_BEFORE_RELATIVE_TIME 32) (int64-rule))))
   (LiquidityPoolConstantProductParameters-rule
    (LiquidityPoolConstantProductParameters
     (Asset-rule)
     (Asset-rule)
     (int32-rule)))
   (LedgerEntryExtensionV1-rule
    (LedgerEntryExtensionV1
     (SponsorshipDescriptor-rule)
     (:union: (bv 0 32) null)))
   (LedgerCloseValueSignature-rule
    (LedgerCloseValueSignature (NodeID-rule) (Signature-rule)))
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
      (:union: (bv TRUE 32) (DataValue-rule))
      (:union: (bv FALSE 32) null))))
   (ClaimClaimableBalanceResult-rule
    (choose
     (:union: (bv CLAIM_CLAIMABLE_BALANCE_SUCCESS 32) null)
     (:union: (bv CLAIM_CLAIMABLE_BALANCE_NOT_AUTHORIZED 32) null)
     (:union: (bv CLAIM_CLAIMABLE_BALANCE_NO_TRUST 32) null)
     (:union: (bv CLAIM_CLAIMABLE_BALANCE_LINE_FULL 32) null)
     (:union: (bv CLAIM_CLAIMABLE_BALANCE_CANNOT_CLAIM 32) null)
     (:union: (bv CLAIM_CLAIMABLE_BALANCE_DOES_NOT_EXIST 32) null)))
   (AlphaNum4-rule (AlphaNum4 (AssetCode4-rule) (AccountID-rule)))
   (uint256-rule (:byte-array: (?? (bitvector 256))))
   (SetOptionsResult-rule
    (choose
     (:union: (bv SET_OPTIONS_SUCCESS 32) null)
     (:union: (bv SET_OPTIONS_AUTH_REVOCABLE_REQUIRED 32) null)
     (:union: (bv SET_OPTIONS_INVALID_HOME_DOMAIN 32) null)
     (:union: (bv SET_OPTIONS_BAD_SIGNER 32) null)
     (:union: (bv SET_OPTIONS_THRESHOLD_OUT_OF_RANGE 32) null)
     (:union: (bv SET_OPTIONS_UNKNOWN_FLAG 32) null)
     (:union: (bv SET_OPTIONS_CANT_CHANGE 32) null)
     (:union: (bv SET_OPTIONS_INVALID_INFLATION 32) null)
     (:union: (bv SET_OPTIONS_BAD_FLAGS 32) null)
     (:union: (bv SET_OPTIONS_TOO_MANY_SIGNERS 32) null)
     (:union: (bv SET_OPTIONS_LOW_RESERVE 32) null)))
   (MuxedAccount-rule
    (choose
     (:union: (bv KEY_TYPE_ED25519 32) (uint256-rule))
     (:union:
      (bv KEY_TYPE_MUXED_ED25519 32)
      (MuxedAccount::med25519 (uint64-rule) (uint256-rule)))))
   (SignerKey-rule
    (choose
     (:union: (bv SIGNER_KEY_TYPE_ED25519 32) (uint256-rule))
     (:union: (bv SIGNER_KEY_TYPE_PRE_AUTH_TX 32) (uint256-rule))
     (:union: (bv SIGNER_KEY_TYPE_HASH_X 32) (uint256-rule))))
   (ManageSellOfferResult-rule
    (choose
     (:union:
      (bv MANAGE_SELL_OFFER_SUCCESS 32)
      (ManageOfferSuccessResult-rule))
     (:union: (bv MANAGE_SELL_OFFER_LOW_RESERVE 32) null)
     (:union: (bv MANAGE_SELL_OFFER_NOT_FOUND 32) null)
     (:union: (bv MANAGE_SELL_OFFER_BUY_NO_ISSUER 32) null)
     (:union: (bv MANAGE_SELL_OFFER_SELL_NO_ISSUER 32) null)
     (:union: (bv MANAGE_SELL_OFFER_CROSS_SELF 32) null)
     (:union: (bv MANAGE_SELL_OFFER_UNDERFUNDED 32) null)
     (:union: (bv MANAGE_SELL_OFFER_LINE_FULL 32) null)
     (:union: (bv MANAGE_SELL_OFFER_BUY_NOT_AUTHORIZED 32) null)
     (:union: (bv MANAGE_SELL_OFFER_SELL_NOT_AUTHORIZED 32) null)
     (:union: (bv MANAGE_SELL_OFFER_BUY_NO_TRUST 32) null)
     (:union: (bv MANAGE_SELL_OFFER_SELL_NO_TRUST 32) null)
     (:union: (bv MANAGE_SELL_OFFER_MALFORMED 32) null)))
   (LiquidityPoolParameters-rule
    (:union:
     (bv LIQUIDITY_POOL_CONSTANT_PRODUCT 32)
     (LiquidityPoolConstantProductParameters-rule)))
   (PathPaymentStrictSendResult-rule
    (choose
     (:union:
      (bv PATH_PAYMENT_STRICT_SEND_SUCCESS 32)
      (PathPaymentStrictSendResult::success
       (vector (ClaimAtom-rule) (ClaimAtom-rule))
       (SimplePaymentResult-rule)))
     (:union: (bv PATH_PAYMENT_STRICT_SEND_NO_ISSUER 32) (Asset-rule))
     (:union: (bv PATH_PAYMENT_STRICT_SEND_UNDER_DESTMIN 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_SEND_OFFER_CROSS_SELF 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_SEND_TOO_FEW_OFFERS 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_SEND_LINE_FULL 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_SEND_NOT_AUTHORIZED 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_SEND_NO_TRUST 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_SEND_NO_DESTINATION 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_SEND_SRC_NOT_AUTHORIZED 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_SEND_SRC_NO_TRUST 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_SEND_UNDERFUNDED 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_SEND_MALFORMED 32) null)))
   (TimePoint-rule (uint64-rule))
   (Price-rule (Price (int32-rule) (int32-rule)))
   (Hash-rule (:byte-array: (?? (bitvector 256))))
   (CreateClaimableBalanceResult-rule
    (choose
     (:union:
      (bv CREATE_CLAIMABLE_BALANCE_SUCCESS 32)
      (ClaimableBalanceID-rule))
     (:union: (bv CREATE_CLAIMABLE_BALANCE_UNDERFUNDED 32) null)
     (:union: (bv CREATE_CLAIMABLE_BALANCE_NOT_AUTHORIZED 32) null)
     (:union: (bv CREATE_CLAIMABLE_BALANCE_NO_TRUST 32) null)
     (:union: (bv CREATE_CLAIMABLE_BALANCE_LOW_RESERVE 32) null)
     (:union: (bv CREATE_CLAIMABLE_BALANCE_MALFORMED 32) null)))
   (ClaimLiquidityAtom-rule
    (ClaimLiquidityAtom
     (PoolID-rule)
     (Asset-rule)
     (int64-rule)
     (Asset-rule)
     (int64-rule)))
   (AccountMergeResult-rule
    (choose
     (:union: (bv ACCOUNT_MERGE_SUCCESS 32) (int64-rule))
     (:union: (bv ACCOUNT_MERGE_IS_SPONSOR 32) null)
     (:union: (bv ACCOUNT_MERGE_DEST_FULL 32) null)
     (:union: (bv ACCOUNT_MERGE_SEQNUM_TOO_FAR 32) null)
     (:union: (bv ACCOUNT_MERGE_HAS_SUB_ENTRIES 32) null)
     (:union: (bv ACCOUNT_MERGE_IMMUTABLE_SET 32) null)
     (:union: (bv ACCOUNT_MERGE_NO_ACCOUNT 32) null)
     (:union: (bv ACCOUNT_MERGE_MALFORMED 32) null)))
   (OfferEntry-rule
    (OfferEntry
     (AccountID-rule)
     (int64-rule)
     (Asset-rule)
     (Asset-rule)
     (int64-rule)
     (Price-rule)
     (uint32-rule)
     (:union: (bv 0 32) null)))
   (SetOptionsOp-rule
    (SetOptionsOp
     (choose
      (:union: (bv TRUE 32) (AccountID-rule))
      (:union: (bv FALSE 32) null))
     (choose (:union: (bv TRUE 32) (uint32-rule)) (:union: (bv FALSE 32) null))
     (choose (:union: (bv TRUE 32) (uint32-rule)) (:union: (bv FALSE 32) null))
     (choose (:union: (bv TRUE 32) (uint32-rule)) (:union: (bv FALSE 32) null))
     (choose (:union: (bv TRUE 32) (uint32-rule)) (:union: (bv FALSE 32) null))
     (choose (:union: (bv TRUE 32) (uint32-rule)) (:union: (bv FALSE 32) null))
     (choose (:union: (bv TRUE 32) (uint32-rule)) (:union: (bv FALSE 32) null))
     (choose
      (:union: (bv TRUE 32) (string32-rule))
      (:union: (bv FALSE 32) null))
     (choose
      (:union: (bv TRUE 32) (Signer-rule))
      (:union: (bv FALSE 32) null))))
   (AssetCode4-rule (:byte-array: (?? (bitvector 32))))
   (FeeBumpTransactionEnvelope-rule
    (FeeBumpTransactionEnvelope
     (FeeBumpTransaction-rule)
     (vector (DecoratedSignature-rule) (DecoratedSignature-rule))))
   (InnerTransactionResult-rule
    (InnerTransactionResult
     (int64-rule)
     (choose
      (:union:
       (bv txSUCCESS 32)
       (vector (OperationResult-rule) (OperationResult-rule)))
      (:union:
       (bv txFAILED 32)
       (vector (OperationResult-rule) (OperationResult-rule)))
      (:union: (bv txTOO_EARLY 32) null)
      (:union: (bv txTOO_LATE 32) null)
      (:union: (bv txMISSING_OPERATION 32) null)
      (:union: (bv txBAD_SEQ 32) null)
      (:union: (bv txBAD_AUTH 32) null)
      (:union: (bv txINSUFFICIENT_BALANCE 32) null)
      (:union: (bv txNO_ACCOUNT 32) null)
      (:union: (bv txINSUFFICIENT_FEE 32) null)
      (:union: (bv txBAD_AUTH_EXTRA 32) null)
      (:union: (bv txINTERNAL_ERROR 32) null)
      (:union: (bv txNOT_SUPPORTED 32) null)
      (:union: (bv txBAD_SPONSORSHIP 32) null))
     (:union: (bv 0 32) null)))
   (PublicKey-rule (:union: (bv PUBLIC_KEY_TYPE_ED25519 32) (uint256-rule)))
   (Asset-rule
    (choose
     (:union: (bv ASSET_TYPE_NATIVE 32) null)
     (:union: (bv ASSET_TYPE_CREDIT_ALPHANUM4 32) (AlphaNum4-rule))
     (:union: (bv ASSET_TYPE_CREDIT_ALPHANUM12 32) (AlphaNum12-rule))))
   (FeeBumpTransaction-rule
    (FeeBumpTransaction
     (MuxedAccount-rule)
     (int64-rule)
     (:union: (bv ENVELOPE_TYPE_TX 32) (TransactionV1Envelope-rule))
     (:union: (bv 0 32) null)))
   (PaymentResult-rule
    (choose
     (:union: (bv PAYMENT_SUCCESS 32) null)
     (:union: (bv PAYMENT_NO_ISSUER 32) null)
     (:union: (bv PAYMENT_LINE_FULL 32) null)
     (:union: (bv PAYMENT_NOT_AUTHORIZED 32) null)
     (:union: (bv PAYMENT_NO_TRUST 32) null)
     (:union: (bv PAYMENT_NO_DESTINATION 32) null)
     (:union: (bv PAYMENT_SRC_NOT_AUTHORIZED 32) null)
     (:union: (bv PAYMENT_SRC_NO_TRUST 32) null)
     (:union: (bv PAYMENT_UNDERFUNDED 32) null)
     (:union: (bv PAYMENT_MALFORMED 32) null)))
   (uint64-rule (?? (bitvector 64)))
   (CreateAccountOp-rule (CreateAccountOp (AccountID-rule) (int64-rule)))
   (TrustLineAsset-rule
    (choose
     (:union: (bv ASSET_TYPE_NATIVE 32) null)
     (:union: (bv ASSET_TYPE_CREDIT_ALPHANUM4 32) (AlphaNum4-rule))
     (:union: (bv ASSET_TYPE_CREDIT_ALPHANUM12 32) (AlphaNum12-rule))
     (:union: (bv ASSET_TYPE_POOL_SHARE 32) (PoolID-rule))))
   (ChangeTrustOp-rule (ChangeTrustOp (ChangeTrustAsset-rule) (int64-rule)))
   (PathPaymentStrictReceiveResult-rule
    (choose
     (:union:
      (bv PATH_PAYMENT_STRICT_RECEIVE_SUCCESS 32)
      (PathPaymentStrictReceiveResult::success
       (vector (ClaimAtom-rule) (ClaimAtom-rule))
       (SimplePaymentResult-rule)))
     (:union: (bv PATH_PAYMENT_STRICT_RECEIVE_NO_ISSUER 32) (Asset-rule))
     (:union: (bv PATH_PAYMENT_STRICT_RECEIVE_OVER_SENDMAX 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_RECEIVE_OFFER_CROSS_SELF 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_RECEIVE_TOO_FEW_OFFERS 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_RECEIVE_LINE_FULL 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_RECEIVE_NOT_AUTHORIZED 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_RECEIVE_NO_TRUST 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_RECEIVE_NO_DESTINATION 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_RECEIVE_SRC_NOT_AUTHORIZED 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_RECEIVE_SRC_NO_TRUST 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_RECEIVE_UNDERFUNDED 32) null)
     (:union: (bv PATH_PAYMENT_STRICT_RECEIVE_MALFORMED 32) null)))
   (OperationResult-rule
    (choose
     (:union:
      (bv opINNER 32)
      (choose
       (:union: (bv CREATE_ACCOUNT 32) (CreateAccountResult-rule))
       (:union: (bv PAYMENT 32) (PaymentResult-rule))
       (:union:
        (bv PATH_PAYMENT_STRICT_RECEIVE 32)
        (PathPaymentStrictReceiveResult-rule))
       (:union: (bv MANAGE_SELL_OFFER 32) (ManageSellOfferResult-rule))
       (:union: (bv CREATE_PASSIVE_SELL_OFFER 32) (ManageSellOfferResult-rule))
       (:union: (bv SET_OPTIONS 32) (SetOptionsResult-rule))
       (:union: (bv CHANGE_TRUST 32) (ChangeTrustResult-rule))
       (:union: (bv ALLOW_TRUST 32) (AllowTrustResult-rule))
       (:union: (bv ACCOUNT_MERGE 32) (AccountMergeResult-rule))
       (:union: (bv INFLATION 32) (InflationResult-rule))
       (:union: (bv MANAGE_DATA 32) (ManageDataResult-rule))
       (:union: (bv BUMP_SEQUENCE 32) (BumpSequenceResult-rule))
       (:union: (bv MANAGE_BUY_OFFER 32) (ManageBuyOfferResult-rule))
       (:union:
        (bv PATH_PAYMENT_STRICT_SEND 32)
        (PathPaymentStrictSendResult-rule))
       (:union:
        (bv CREATE_CLAIMABLE_BALANCE 32)
        (CreateClaimableBalanceResult-rule))
       (:union:
        (bv CLAIM_CLAIMABLE_BALANCE 32)
        (ClaimClaimableBalanceResult-rule))
       (:union:
        (bv BEGIN_SPONSORING_FUTURE_RESERVES 32)
        (BeginSponsoringFutureReservesResult-rule))
       (:union:
        (bv END_SPONSORING_FUTURE_RESERVES 32)
        (EndSponsoringFutureReservesResult-rule))
       (:union: (bv REVOKE_SPONSORSHIP 32) (RevokeSponsorshipResult-rule))
       (:union: (bv CLAWBACK 32) (ClawbackResult-rule))
       (:union:
        (bv CLAWBACK_CLAIMABLE_BALANCE 32)
        (ClawbackClaimableBalanceResult-rule))
       (:union: (bv SET_TRUST_LINE_FLAGS 32) (SetTrustLineFlagsResult-rule))
       (:union:
        (bv LIQUIDITY_POOL_DEPOSIT 32)
        (LiquidityPoolDepositResult-rule))
       (:union:
        (bv LIQUIDITY_POOL_WITHDRAW 32)
        (LiquidityPoolWithdrawResult-rule))))
     (:union: (bv opTOO_MANY_SPONSORING 32) null)
     (:union: (bv opEXCEEDED_WORK_LIMIT 32) null)
     (:union: (bv opTOO_MANY_SUBENTRIES 32) null)
     (:union: (bv opNOT_SUPPORTED 32) null)
     (:union: (bv opNO_ACCOUNT 32) null)
     (:union: (bv opBAD_AUTH 32) null)))
   (TransactionEnvelope-rule
    (choose
     (:union: (bv ENVELOPE_TYPE_TX_V0 32) (TransactionV0Envelope-rule))
     (:union: (bv ENVELOPE_TYPE_TX 32) (TransactionV1Envelope-rule))
     (:union:
      (bv ENVELOPE_TYPE_TX_FEE_BUMP 32)
      (FeeBumpTransactionEnvelope-rule))))
   (AccountEntryExtensionV1-rule
    (AccountEntryExtensionV1
     (Liabilities-rule)
     (choose
      (:union: (bv 0 32) null)
      (:union: (bv 2 32) (AccountEntryExtensionV2-rule)))))
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
    (:union: (bv CLAIMABLE_BALANCE_ID_TYPE_V0 32) (Hash-rule)))
   (TestCaseResult-rule
    (TestCaseResult
     (vector (TransactionResult-rule) (TransactionResult-rule))
     (vector (LedgerEntryChange-rule) (LedgerEntryChange-rule))))
   (Liabilities-rule (Liabilities (int64-rule) (int64-rule)))
   (TransactionV0-rule
    (TransactionV0
     (uint256-rule)
     (uint32-rule)
     (SequenceNumber-rule)
     (choose
      (:union: (bv TRUE 32) (TimeBounds-rule))
      (:union: (bv FALSE 32) null))
     (Memo-rule)
     (vector (Operation-rule) (Operation-rule))
     (:union: (bv 0 32) null)))
   (TrustLineEntryExtensionV2-rule
    (TrustLineEntryExtensionV2 (int32-rule) (:union: (bv 0 32) null)))))

;(the-grammar #:depth 7 #:start TestCase-rule)
;(the-grammar #:depth 7 #:start TransactionEnvelope-rule)