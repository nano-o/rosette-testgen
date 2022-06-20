#lang rosette
(provide (all-defined-out))
(require rosette/lib/synthax lens lens/data/struct)
(begin
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
    (struct RevokeSponsorshipOp (tag value) #:transparent)
    (define-struct-lenses RevokeSponsorshipOp)
    (struct AssetCode (tag value) #:transparent)
    (define-struct-lenses AssetCode)
    (struct Claimant (tag value) #:transparent)
    (define-struct-lenses Claimant)
    (struct ClaimableBalanceEntryExtensionV1 (ext flags) #:transparent)
    (define-struct-lenses ClaimableBalanceEntryExtensionV1)
    (struct AllowTrustResult (tag value) #:transparent)
    (define-struct-lenses AllowTrustResult)
    (struct AlphaNum12 (assetCode issuer) #:transparent)
    (define-struct-lenses AlphaNum12)
    (struct Memo (tag value) #:transparent)
    (define-struct-lenses Memo)
    (struct
     ClaimOfferAtom
     (sellerID offerID assetSold amountSold assetBought amountBought)
     #:transparent)
    (define-struct-lenses ClaimOfferAtom)
    (struct TransactionV1Envelope (tx signatures) #:transparent)
    (define-struct-lenses TransactionV1Envelope)
    (struct LedgerHeaderExtensionV1::ext (tag value) #:transparent)
    (define-struct-lenses LedgerHeaderExtensionV1::ext)
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
    (define-struct-lenses AccountEntry)
    (struct TrustLineEntry::ext::v1::ext (tag value) #:transparent)
    (define-struct-lenses TrustLineEntry::ext::v1::ext)
    (struct SetTrustLineFlagsResult (tag value) #:transparent)
    (define-struct-lenses SetTrustLineFlagsResult)
    (struct Transaction::ext (tag value) #:transparent)
    (define-struct-lenses Transaction::ext)
    (struct InnerTransactionResultPair (transactionHash result) #:transparent)
    (define-struct-lenses InnerTransactionResultPair)
    (struct LiquidityPoolEntry (liquidityPoolID body) #:transparent)
    (define-struct-lenses LiquidityPoolEntry)
    (struct LedgerKey::claimableBalance (balanceID) #:transparent)
    (define-struct-lenses LedgerKey::claimableBalance)
    (struct StellarValue (txSetHash closeTime upgrades ext) #:transparent)
    (define-struct-lenses StellarValue)
    (struct ChangeTrustResult (tag value) #:transparent)
    (define-struct-lenses ChangeTrustResult)
    (struct ClawbackClaimableBalanceResult (tag value) #:transparent)
    (define-struct-lenses ClawbackClaimableBalanceResult)
    (struct ClaimableBalanceEntry::ext (tag value) #:transparent)
    (define-struct-lenses ClaimableBalanceEntry::ext)
    (struct
     CreatePassiveSellOfferOp
     (selling buying amount price)
     #:transparent)
    (define-struct-lenses CreatePassiveSellOfferOp)
    (struct LedgerKey::account (accountID) #:transparent)
    (define-struct-lenses LedgerKey::account)
    (struct CreateClaimableBalanceOp (asset amount claimants) #:transparent)
    (define-struct-lenses CreateClaimableBalanceOp)
    (struct FeeBumpTransaction::ext (tag value) #:transparent)
    (define-struct-lenses FeeBumpTransaction::ext)
    (struct
     PathPaymentStrictSendOp
     (sendAsset sendAmount destination destAsset destMin path)
     #:transparent)
    (define-struct-lenses PathPaymentStrictSendOp)
    (struct TimeBounds (minTime maxTime) #:transparent)
    (define-struct-lenses TimeBounds)
    (struct ManageOfferSuccessResult (offersClaimed offer) #:transparent)
    (define-struct-lenses ManageOfferSuccessResult)
    (struct TransactionV0::ext (tag value) #:transparent)
    (define-struct-lenses TransactionV0::ext)
    (struct AccountEntry::ext (tag value) #:transparent)
    (define-struct-lenses AccountEntry::ext)
    (struct Operation::body (tag value) #:transparent)
    (define-struct-lenses Operation::body)
    (struct TransactionResult::ext (tag value) #:transparent)
    (define-struct-lenses TransactionResult::ext)
    (struct DataEntry (accountID dataName dataValue ext) #:transparent)
    (define-struct-lenses DataEntry)
    (struct
     ManageBuyOfferOp
     (selling buying buyAmount price offerID)
     #:transparent)
    (define-struct-lenses ManageBuyOfferOp)
    (struct PathPaymentStrictSendResult::success (offers last) #:transparent)
    (define-struct-lenses PathPaymentStrictSendResult::success)
    (struct
     Transaction
     (sourceAccount fee seqNum timeBounds memo operations ext)
     #:transparent)
    (define-struct-lenses Transaction)
    (struct Signer (key weight) #:transparent)
    (define-struct-lenses Signer)
    (struct
     TrustLineEntry
     (accountID asset balance limit flags ext)
     #:transparent)
    (define-struct-lenses TrustLineEntry)
    (struct BeginSponsoringFutureReservesOp (sponsoredID) #:transparent)
    (define-struct-lenses BeginSponsoringFutureReservesOp)
    (struct TrustLineEntryExtensionV2::ext (tag value) #:transparent)
    (define-struct-lenses TrustLineEntryExtensionV2::ext)
    (struct
     ClaimableBalanceEntry
     (balanceID claimants asset amount ext)
     #:transparent)
    (define-struct-lenses ClaimableBalanceEntry)
    (struct InflationResult (tag value) #:transparent)
    (define-struct-lenses InflationResult)
    (struct LiquidityPoolWithdrawResult (tag value) #:transparent)
    (define-struct-lenses LiquidityPoolWithdrawResult)
    (struct StellarValue::ext (tag value) #:transparent)
    (define-struct-lenses StellarValue::ext)
    (struct LedgerEntry (lastModifiedLedgerSeq data ext) #:transparent)
    (define-struct-lenses LedgerEntry)
    (struct PaymentOp (destination asset amount) #:transparent)
    (define-struct-lenses PaymentOp)
    (struct CreateAccountResult (tag value) #:transparent)
    (define-struct-lenses CreateAccountResult)
    (struct
     LiquidityPoolEntry::body::constantProduct
     (params reserveA reserveB totalPoolShares poolSharesTrustLineCount)
     #:transparent)
    (define-struct-lenses LiquidityPoolEntry::body::constantProduct)
    (struct ManageOfferSuccessResult::offer (tag value) #:transparent)
    (define-struct-lenses ManageOfferSuccessResult::offer)
    (struct BeginSponsoringFutureReservesResult (tag value) #:transparent)
    (define-struct-lenses BeginSponsoringFutureReservesResult)
    (struct ClaimClaimableBalanceOp (balanceID) #:transparent)
    (define-struct-lenses ClaimClaimableBalanceOp)
    (struct SimplePaymentResult (destination asset amount) #:transparent)
    (define-struct-lenses SimplePaymentResult)
    (struct LedgerKey::trustLine (accountID asset) #:transparent)
    (define-struct-lenses LedgerKey::trustLine)
    (struct BumpSequenceResult (tag value) #:transparent)
    (define-struct-lenses BumpSequenceResult)
    (struct AllowTrustOp (trustor asset authorize) #:transparent)
    (define-struct-lenses AllowTrustOp)
    (struct ClaimAtom (tag value) #:transparent)
    (define-struct-lenses ClaimAtom)
    (struct LedgerKey (tag value) #:transparent)
    (define-struct-lenses LedgerKey)
    (struct LiquidityPoolDepositResult (tag value) #:transparent)
    (define-struct-lenses LiquidityPoolDepositResult)
    (struct ManageDataResult (tag value) #:transparent)
    (define-struct-lenses ManageDataResult)
    (struct BumpSequenceOp (bumpTo) #:transparent)
    (define-struct-lenses BumpSequenceOp)
    (struct TrustLineEntry::ext::v1 (liabilities ext) #:transparent)
    (define-struct-lenses TrustLineEntry::ext::v1)
    (struct ManageBuyOfferResult (tag value) #:transparent)
    (define-struct-lenses ManageBuyOfferResult)
    (struct Operation (sourceAccount body) #:transparent)
    (define-struct-lenses Operation)
    (struct
     AccountEntryExtensionV2
     (numSponsored numSponsoring signerSponsoringIDs ext)
     #:transparent)
    (define-struct-lenses AccountEntryExtensionV2)
    (struct TransactionResult::result (tag value) #:transparent)
    (define-struct-lenses TransactionResult::result)
    (struct TransactionResult (feeCharged result ext) #:transparent)
    (define-struct-lenses TransactionResult)
    (struct LedgerKey::liquidityPool (liquidityPoolID) #:transparent)
    (define-struct-lenses LedgerKey::liquidityPool)
    (struct EndSponsoringFutureReservesResult (tag value) #:transparent)
    (define-struct-lenses EndSponsoringFutureReservesResult)
    (struct
     SetTrustLineFlagsOp
     (trustor asset clearFlags setFlags)
     #:transparent)
    (define-struct-lenses SetTrustLineFlagsOp)
    (struct
     LiquidityPoolDepositOp
     (liquidityPoolID maxAmountA maxAmountB minPrice maxPrice)
     #:transparent)
    (define-struct-lenses LiquidityPoolDepositOp)
    (struct ChangeTrustAsset (tag value) #:transparent)
    (define-struct-lenses ChangeTrustAsset)
    (struct LedgerHeaderExtensionV1 (flags ext) #:transparent)
    (define-struct-lenses LedgerHeaderExtensionV1)
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
    (define-struct-lenses LedgerHeader)
    (struct LedgerKey::offer (sellerID offerID) #:transparent)
    (define-struct-lenses LedgerKey::offer)
    (struct Claimant::v0 (destination predicate) #:transparent)
    (define-struct-lenses Claimant::v0)
    (struct AccountEntryExtensionV2::ext (tag value) #:transparent)
    (define-struct-lenses AccountEntryExtensionV2::ext)
    (struct OperationResult::tr (tag value) #:transparent)
    (define-struct-lenses OperationResult::tr)
    (struct LiquidityPoolEntry::body (tag value) #:transparent)
    (define-struct-lenses LiquidityPoolEntry::body)
    (struct
     ClaimOfferAtomV0
     (sellerEd25519 offerID assetSold amountSold assetBought amountBought)
     #:transparent)
    (define-struct-lenses ClaimOfferAtomV0)
    (struct ClawbackClaimableBalanceOp (balanceID) #:transparent)
    (define-struct-lenses ClawbackClaimableBalanceOp)
    (struct RevokeSponsorshipResult (tag value) #:transparent)
    (define-struct-lenses RevokeSponsorshipResult)
    (struct InflationPayout (destination amount) #:transparent)
    (define-struct-lenses InflationPayout)
    (struct OfferEntry::ext (tag value) #:transparent)
    (define-struct-lenses OfferEntry::ext)
    (struct
     PathPaymentStrictReceiveOp
     (sendAsset sendMax destination destAsset destAmount path)
     #:transparent)
    (define-struct-lenses PathPaymentStrictReceiveOp)
    (struct ClaimPredicate (tag value) #:transparent)
    (define-struct-lenses ClaimPredicate)
    (struct
     LiquidityPoolConstantProductParameters
     (assetA assetB fee)
     #:transparent)
    (define-struct-lenses LiquidityPoolConstantProductParameters)
    (struct ClawbackResult (tag value) #:transparent)
    (define-struct-lenses ClawbackResult)
    (struct Ledger (header entries) #:transparent)
    (define-struct-lenses Ledger)
    (struct ClawbackOp (asset from amount) #:transparent)
    (define-struct-lenses ClawbackOp)
    (struct LedgerEntryExtensionV1 (sponsoringID ext) #:transparent)
    (define-struct-lenses LedgerEntryExtensionV1)
    (struct LedgerCloseValueSignature (nodeID signature) #:transparent)
    (define-struct-lenses LedgerCloseValueSignature)
    (struct
     LiquidityPoolWithdrawOp
     (liquidityPoolID amount minAmountA minAmountB)
     #:transparent)
    (define-struct-lenses LiquidityPoolWithdrawOp)
    (struct ManageDataOp (dataName dataValue) #:transparent)
    (define-struct-lenses ManageDataOp)
    (struct ClaimClaimableBalanceResult (tag value) #:transparent)
    (define-struct-lenses ClaimClaimableBalanceResult)
    (struct DataEntry::ext (tag value) #:transparent)
    (define-struct-lenses DataEntry::ext)
    (struct TransactionV0Envelope (tx signatures) #:transparent)
    (define-struct-lenses TransactionV0Envelope)
    (struct LedgerEntry::data (tag value) #:transparent)
    (define-struct-lenses LedgerEntry::data)
    (struct SignerKey (tag value) #:transparent)
    (define-struct-lenses SignerKey)
    (struct ManageSellOfferResult (tag value) #:transparent)
    (define-struct-lenses ManageSellOfferResult)
    (struct AlphaNum4 (assetCode issuer) #:transparent)
    (define-struct-lenses AlphaNum4)
    (struct LedgerEntryExtensionV1::ext (tag value) #:transparent)
    (define-struct-lenses LedgerEntryExtensionV1::ext)
    (struct SetOptionsResult (tag value) #:transparent)
    (define-struct-lenses SetOptionsResult)
    (struct MuxedAccount (tag value) #:transparent)
    (define-struct-lenses MuxedAccount)
    (struct
     PathPaymentStrictReceiveResult::success
     (offers last)
     #:transparent)
    (define-struct-lenses PathPaymentStrictReceiveResult::success)
    (struct CreateClaimableBalanceResult (tag value) #:transparent)
    (define-struct-lenses CreateClaimableBalanceResult)
    (struct InnerTransactionResult::ext (tag value) #:transparent)
    (define-struct-lenses InnerTransactionResult::ext)
    (struct
     ClaimLiquidityAtom
     (liquidityPoolID assetSold amountSold assetBought amountBought)
     #:transparent)
    (define-struct-lenses ClaimLiquidityAtom)
    (struct AccountMergeResult (tag value) #:transparent)
    (define-struct-lenses AccountMergeResult)
    (struct
     OfferEntry
     (sellerID offerID selling buying amount price flags ext)
     #:transparent)
    (define-struct-lenses OfferEntry)
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
    (define-struct-lenses SetOptionsOp)
    (struct LiquidityPoolParameters (tag value) #:transparent)
    (define-struct-lenses LiquidityPoolParameters)
    (struct PathPaymentStrictSendResult (tag value) #:transparent)
    (define-struct-lenses PathPaymentStrictSendResult)
    (struct LedgerKey::data (accountID dataName) #:transparent)
    (define-struct-lenses LedgerKey::data)
    (struct Price (n d) #:transparent)
    (define-struct-lenses Price)
    (struct LedgerHeader::ext (tag value) #:transparent)
    (define-struct-lenses LedgerHeader::ext)
    (struct FeeBumpTransactionEnvelope (tx signatures) #:transparent)
    (define-struct-lenses FeeBumpTransactionEnvelope)
    (struct LedgerEntry::ext (tag value) #:transparent)
    (define-struct-lenses LedgerEntry::ext)
    (struct PublicKey (tag value) #:transparent)
    (define-struct-lenses PublicKey)
    (struct InnerTransactionResult (feeCharged result ext) #:transparent)
    (define-struct-lenses InnerTransactionResult)
    (struct Asset (tag value) #:transparent)
    (define-struct-lenses Asset)
    (struct FeeBumpTransaction (feeSource fee innerTx ext) #:transparent)
    (define-struct-lenses FeeBumpTransaction)
    (struct TrustLineEntry::ext (tag value) #:transparent)
    (define-struct-lenses TrustLineEntry::ext)
    (struct RevokeSponsorshipOp::signer (accountID signerKey) #:transparent)
    (define-struct-lenses RevokeSponsorshipOp::signer)
    (struct PaymentResult (tag value) #:transparent)
    (define-struct-lenses PaymentResult)
    (struct AccountEntryExtensionV1::ext (tag value) #:transparent)
    (define-struct-lenses AccountEntryExtensionV1::ext)
    (struct PathPaymentStrictReceiveResult (tag value) #:transparent)
    (define-struct-lenses PathPaymentStrictReceiveResult)
    (struct OperationResult (tag value) #:transparent)
    (define-struct-lenses OperationResult)
    (struct TransactionEnvelope (tag value) #:transparent)
    (define-struct-lenses TransactionEnvelope)
    (struct AccountEntryExtensionV1 (liabilities ext) #:transparent)
    (define-struct-lenses AccountEntryExtensionV1)
    (struct
     ManageSellOfferOp
     (selling buying amount price offerID)
     #:transparent)
    (define-struct-lenses ManageSellOfferOp)
    (struct DecoratedSignature (hint signature) #:transparent)
    (define-struct-lenses DecoratedSignature)
    (struct CreateAccountOp (destination startingBalance) #:transparent)
    (define-struct-lenses CreateAccountOp)
    (struct TrustLineAsset (tag value) #:transparent)
    (define-struct-lenses TrustLineAsset)
    (struct ChangeTrustOp (line limit) #:transparent)
    (define-struct-lenses ChangeTrustOp)
    (struct InnerTransactionResult::result (tag value) #:transparent)
    (define-struct-lenses InnerTransactionResult::result)
    (struct ClaimableBalanceEntryExtensionV1::ext (tag value) #:transparent)
    (define-struct-lenses ClaimableBalanceEntryExtensionV1::ext)
    (struct MuxedAccount::med25519 (id ed25519) #:transparent)
    (define-struct-lenses MuxedAccount::med25519)
    (struct
     TrustLineEntryExtensionV2
     (liquidityPoolUseCount ext)
     #:transparent)
    (define-struct-lenses TrustLineEntryExtensionV2)
    (struct FeeBumpTransaction::innerTx (tag value) #:transparent)
    (define-struct-lenses FeeBumpTransaction::innerTx)
    (struct ClaimableBalanceID (tag value) #:transparent)
    (define-struct-lenses ClaimableBalanceID)
    (struct Liabilities (buying selling) #:transparent)
    (define-struct-lenses Liabilities)
    (struct
     TransactionV0
     (sourceAccountEd25519 fee seqNum timeBounds memo operations ext)
     #:transparent)
    (define-struct-lenses TransactionV0)
    (struct -byte-array (value) #:transparent)
    (define-struct-lenses -byte-array)
    (struct -optional (present value) #:transparent)
    (define-struct-lenses -optional)
    (define (Claimant-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (Claimant-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32))
                         ((λ (d)
                            (and ((λ (d)
                                    (or ((λ (d) (Claimant::v0? d)) d)
                                        (raise-user-error
                                         (format
                                          (string-append
                                           "invalid "
                                           "struct type Claimant::v0"
                                           ": ~a")
                                          d))))
                                  d)
                                 ((λ (d)
                                    (AccountID-valid?
                                     (Claimant::v0-destination d)))
                                  d)
                                 ((λ (d)
                                    (ClaimPredicate-valid?
                                     (Claimant::v0-predicate d)))
                                  d)))
                          value))))))
               (c (Claimant-tag d) (Claimant-value d)))))
       data))
    (define (ClaimableBalanceEntryExtensionV1-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ClaimableBalanceEntryExtensionV1? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ClaimableBalanceEntryExtensionV1"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (ClaimableBalanceEntryExtensionV1::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c
                           (ClaimableBalanceEntryExtensionV1::ext-tag d)
                           (ClaimableBalanceEntryExtensionV1::ext-value d)))))
                  (ClaimableBalanceEntryExtensionV1-ext d)))
               d)
              ((λ (d)
                 (uint32-valid? (ClaimableBalanceEntryExtensionV1-flags d)))
               d)))
       data))
    (define (ChangeTrustResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5 -6 -7 -8)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (SponsorshipDescriptor-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (-optional-present d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 1 32)) (AccountID-valid? value)))
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value))))))
               (c (-optional-present d) (-optional-value d)))))
       data))
    (define (AllowTrustResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (AllowTrustResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -6 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c (AllowTrustResult-tag d) (AllowTrustResult-value d)))))
       data))
    (define (AssetCode12-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and (-byte-array? d) ((bitvector 96) (-byte-array-value d))))
              d)
             (raise-user-error
              (format
               (string-append "invalid " "fixed-length array" ": ~a")
               d))))
       data))
    (define (Memo-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (Memo-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 1 32))
                         ((λ (d)
                            (or ((λ (d)
                                   (and (vector? d) (<= (vector-length d) 28)))
                                 d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "string" ": ~a")
                                  d))))
                          value)))
                  (λ (tag value)
                    (and (bveq tag (bv 2 32)) (uint64-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 3 32)) (Hash-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 4 32)) (Hash-valid? value))))))
               (c (Memo-tag d) (Memo-value d)))))
       data))
    (define (AlphaNum12-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (AlphaNum12? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type AlphaNum12"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (AssetCode12-valid? (AlphaNum12-assetCode d))) d)
              ((λ (d) (AccountID-valid? (AlphaNum12-issuer d))) d)))
       data))
    (define (LedgerEntryType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 1 2 3 4 5))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (RevokeSponsorshipOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (RevokeSponsorshipOp-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32)) (LedgerKey-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 1 32))
                         ((λ (d)
                            (and ((λ (d)
                                    (or ((λ (d)
                                           (RevokeSponsorshipOp::signer? d))
                                         d)
                                        (raise-user-error
                                         (format
                                          (string-append
                                           "invalid "
                                           "struct type RevokeSponsorshipOp::signer"
                                           ": ~a")
                                          d))))
                                  d)
                                 ((λ (d)
                                    (AccountID-valid?
                                     (RevokeSponsorshipOp::signer-accountID
                                      d)))
                                  d)
                                 ((λ (d)
                                    (SignerKey-valid?
                                     (RevokeSponsorshipOp::signer-signerKey
                                      d)))
                                  d)))
                          value))))))
               (c (RevokeSponsorshipOp-tag d) (RevokeSponsorshipOp-value d)))))
       data))
    (define (AssetCode-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (AssetCode-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 1 32)) (AssetCode4-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 2 32)) (AssetCode12-valid? value))))))
               (c (AssetCode-tag d) (AssetCode-value d)))))
       data))
    (define (ClaimOfferAtom-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ClaimOfferAtom? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ClaimOfferAtom"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (AccountID-valid? (ClaimOfferAtom-sellerID d))) d)
              ((λ (d) (int64-valid? (ClaimOfferAtom-offerID d))) d)
              ((λ (d) (Asset-valid? (ClaimOfferAtom-assetSold d))) d)
              ((λ (d) (int64-valid? (ClaimOfferAtom-amountSold d))) d)
              ((λ (d) (Asset-valid? (ClaimOfferAtom-assetBought d))) d)
              ((λ (d) (int64-valid? (ClaimOfferAtom-amountBought d))) d)))
       data))
    (define (CreateAccountResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 -1 -2 -3 -4))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (TransactionV1Envelope-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (TransactionV1Envelope? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type TransactionV1Envelope"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (Transaction-valid? (TransactionV1Envelope-tx d))) d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when 20 (<= (vector-length d) 20))
                                (for/and
                                 ((e (in-vector d)))
                                 (DecoratedSignature-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (TransactionV1Envelope-signatures d)))
               d)))
       data))
    (define (SetTrustLineFlagsResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (SetTrustLineFlagsResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (SetTrustLineFlagsResult-tag d)
                (SetTrustLineFlagsResult-value d)))))
       data))
    (define (LiquidityPoolWithdrawResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (InnerTransactionResultPair-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (InnerTransactionResultPair? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type InnerTransactionResultPair"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 (Hash-valid? (InnerTransactionResultPair-transactionHash d)))
               d)
              ((λ (d)
                 (InnerTransactionResult-valid?
                  (InnerTransactionResultPair-result d)))
               d)))
       data))
    (define (ManageBuyOfferResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5 -6 -7 -8 -9 -10 -11 -12)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (AccountEntry-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (AccountEntry? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type AccountEntry"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (AccountID-valid? (AccountEntry-accountID d))) d)
              ((λ (d) (int64-valid? (AccountEntry-balance d))) d)
              ((λ (d) (SequenceNumber-valid? (AccountEntry-seqNum d))) d)
              ((λ (d) (uint32-valid? (AccountEntry-numSubEntries d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (AccountID-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (AccountEntry-inflationDest d)))
               d)
              ((λ (d) (uint32-valid? (AccountEntry-flags d))) d)
              ((λ (d) (string32-valid? (AccountEntry-homeDomain d))) d)
              ((λ (d) (Thresholds-valid? (AccountEntry-thresholds d))) d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when 20 (<= (vector-length d) 20))
                                (for/and
                                 ((e (in-vector d)))
                                 (Signer-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (AccountEntry-signers d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (AccountEntry::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (AccountEntryExtensionV1-valid? value))))))
                          (c
                           (AccountEntry::ext-tag d)
                           (AccountEntry::ext-value d)))))
                  (AccountEntry-ext d)))
               d)))
       data))
    (define (LiquidityPoolEntry-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (LiquidityPoolEntry? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type LiquidityPoolEntry"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (PoolID-valid? (LiquidityPoolEntry-liquidityPoolID d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (LiquidityPoolEntry::body-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32))
                                    ((λ (d)
                                       (and ((λ (d)
                                               (or ((λ (d)
                                                      (LiquidityPoolEntry::body::constantProduct?
                                                       d))
                                                    d)
                                                   (raise-user-error
                                                    (format
                                                     (string-append
                                                      "invalid "
                                                      "struct type LiquidityPoolEntry::body::constantProduct"
                                                      ": ~a")
                                                     d))))
                                             d)
                                            ((λ (d)
                                               (LiquidityPoolConstantProductParameters-valid?
                                                (LiquidityPoolEntry::body::constantProduct-params
                                                 d)))
                                             d)
                                            ((λ (d)
                                               (int64-valid?
                                                (LiquidityPoolEntry::body::constantProduct-reserveA
                                                 d)))
                                             d)
                                            ((λ (d)
                                               (int64-valid?
                                                (LiquidityPoolEntry::body::constantProduct-reserveB
                                                 d)))
                                             d)
                                            ((λ (d)
                                               (int64-valid?
                                                (LiquidityPoolEntry::body::constantProduct-totalPoolShares
                                                 d)))
                                             d)
                                            ((λ (d)
                                               (int64-valid?
                                                (LiquidityPoolEntry::body::constantProduct-poolSharesTrustLineCount
                                                 d)))
                                             d)))
                                     value))))))
                          (c
                           (LiquidityPoolEntry::body-tag d)
                           (LiquidityPoolEntry::body-value d)))))
                  (LiquidityPoolEntry-body d)))
               d)))
       data))
    (define (CreatePassiveSellOfferOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (CreatePassiveSellOfferOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type CreatePassiveSellOfferOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (Asset-valid? (CreatePassiveSellOfferOp-selling d))) d)
              ((λ (d) (Asset-valid? (CreatePassiveSellOfferOp-buying d))) d)
              ((λ (d) (int64-valid? (CreatePassiveSellOfferOp-amount d))) d)
              ((λ (d) (Price-valid? (CreatePassiveSellOfferOp-price d))) d)))
       data))
    (define (ClawbackClaimableBalanceResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (ClawbackClaimableBalanceResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (ClawbackClaimableBalanceResult-tag d)
                (ClawbackClaimableBalanceResult-value d)))))
       data))
    (define (CreateClaimableBalanceOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (CreateClaimableBalanceOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type CreateClaimableBalanceOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (Asset-valid? (CreateClaimableBalanceOp-asset d))) d)
              ((λ (d) (int64-valid? (CreateClaimableBalanceOp-amount d))) d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when 10 (<= (vector-length d) 10))
                                (for/and
                                 ((e (in-vector d)))
                                 (Claimant-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (CreateClaimableBalanceOp-claimants d)))
               d)))
       data))
    (define (StellarValue-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (StellarValue? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type StellarValue"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (Hash-valid? (StellarValue-txSetHash d))) d)
              ((λ (d) (TimePoint-valid? (StellarValue-closeTime d))) d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when 6 (<= (vector-length d) 6))
                                (for/and
                                 ((e (in-vector d)))
                                 (UpgradeType-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (StellarValue-upgrades d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (StellarValue::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (LedgerCloseValueSignature-valid?
                                     value))))))
                          (c
                           (StellarValue::ext-tag d)
                           (StellarValue::ext-value d)))))
                  (StellarValue-ext d)))
               d)))
       data))
    (define (ChangeTrustResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (ChangeTrustResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -8 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -7 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -6 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c (ChangeTrustResult-tag d) (ChangeTrustResult-value d)))))
       data))
    (define (ManageOfferSuccessResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ManageOfferSuccessResult? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ManageOfferSuccessResult"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when #f (<= (vector-length d) #f))
                                (for/and
                                 ((e (in-vector d)))
                                 (ClaimAtom-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (ManageOfferSuccessResult-offersClaimed d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (ManageOfferSuccessResult::offer-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32))
                                    (OfferEntry-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (OfferEntry-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 2 32)) (null? value))))))
                          (c
                           (ManageOfferSuccessResult::offer-tag d)
                           (ManageOfferSuccessResult::offer-value d)))))
                  (ManageOfferSuccessResult-offer d)))
               d)))
       data))
    (define (RevokeSponsorshipResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (PoolID-valid? data) (Hash-valid? data))
    (define (OperationResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5 -6)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (PathPaymentStrictSendOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (PathPaymentStrictSendOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type PathPaymentStrictSendOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (Asset-valid? (PathPaymentStrictSendOp-sendAsset d))) d)
              ((λ (d) (int64-valid? (PathPaymentStrictSendOp-sendAmount d))) d)
              ((λ (d)
                 (MuxedAccount-valid? (PathPaymentStrictSendOp-destination d)))
               d)
              ((λ (d) (Asset-valid? (PathPaymentStrictSendOp-destAsset d))) d)
              ((λ (d) (int64-valid? (PathPaymentStrictSendOp-destMin d))) d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when 5 (<= (vector-length d) 5))
                                (for/and
                                 ((e (in-vector d)))
                                 (Asset-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (PathPaymentStrictSendOp-path d)))
               d)))
       data))
    (define (TimeBounds-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (TimeBounds? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type TimeBounds"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (TimePoint-valid? (TimeBounds-minTime d))) d)
              ((λ (d) (TimePoint-valid? (TimeBounds-maxTime d))) d)))
       data))
    (define (string64-valid? data)
      ((λ (d)
         (or ((λ (d) (and (vector? d) (<= (vector-length d) 64))) d)
             (raise-user-error
              (format (string-append "invalid " "string" ": ~a") d))))
       data))
    (define (ManageDataResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 -1 -2 -3 -4))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (DataEntry-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (DataEntry? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type DataEntry"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (AccountID-valid? (DataEntry-accountID d))) d)
              ((λ (d) (string64-valid? (DataEntry-dataName d))) d)
              ((λ (d) (DataValue-valid? (DataEntry-dataValue d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (DataEntry::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c
                           (DataEntry::ext-tag d)
                           (DataEntry::ext-value d)))))
                  (DataEntry-ext d)))
               d)))
       data))
    (define (TransactionResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v
                        (list
                         1
                         0
                         -1
                         -2
                         -3
                         -4
                         -5
                         -6
                         -7
                         -8
                         -9
                         -10
                         -11
                         -12
                         -13
                         -14)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (ManageBuyOfferOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ManageBuyOfferOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ManageBuyOfferOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (Asset-valid? (ManageBuyOfferOp-selling d))) d)
              ((λ (d) (Asset-valid? (ManageBuyOfferOp-buying d))) d)
              ((λ (d) (int64-valid? (ManageBuyOfferOp-buyAmount d))) d)
              ((λ (d) (Price-valid? (ManageBuyOfferOp-price d))) d)
              ((λ (d) (int64-valid? (ManageBuyOfferOp-offerID d))) d)))
       data))
    (define (PathPaymentStrictSendResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5 -6 -7 -8 -9 -10 -11 -12)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (DataValue-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and (vector? d)
                     (when 64 (<= (vector-length d) 64))
                     (for/and
                      ((e (in-vector d)))
                      ((λ (d)
                         (or ((bitvector 8) d)
                             (raise-user-error
                              (format
                               (string-append "invalid " "opaque" ": ~a")
                               d))))
                       e))))
              d)
             (raise-user-error
              (format
               (string-append "invalid " "variable-length array" ": ~a")
               d))))
       data))
    (define (SetOptionsResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5 -6 -7 -8 -9 -10)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (PublicKeyType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (LiquidityPoolWithdrawResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (LiquidityPoolWithdrawResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (LiquidityPoolWithdrawResult-tag d)
                (LiquidityPoolWithdrawResult-value d)))))
       data))
    (define (PaymentResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5 -6 -7 -8 -9)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (Transaction-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (Transaction? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type Transaction"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (MuxedAccount-valid? (Transaction-sourceAccount d))) d)
              ((λ (d) (uint32-valid? (Transaction-fee d))) d)
              ((λ (d) (SequenceNumber-valid? (Transaction-seqNum d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (TimeBounds-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (Transaction-timeBounds d)))
               d)
              ((λ (d) (Memo-valid? (Transaction-memo d))) d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when 100 (<= (vector-length d) 100))
                                (for/and
                                 ((e (in-vector d)))
                                 (Operation-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (Transaction-operations d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (Transaction::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c
                           (Transaction::ext-tag d)
                           (Transaction::ext-value d)))))
                  (Transaction-ext d)))
               d)))
       data))
    (define (Signer-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (Signer? d)) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "struct type Signer" ": ~a")
                       d))))
               d)
              ((λ (d) (SignerKey-valid? (Signer-key d))) d)
              ((λ (d) (uint32-valid? (Signer-weight d))) d)))
       data))
    (define (TrustLineEntry-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (TrustLineEntry? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type TrustLineEntry"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (AccountID-valid? (TrustLineEntry-accountID d))) d)
              ((λ (d) (TrustLineAsset-valid? (TrustLineEntry-asset d))) d)
              ((λ (d) (int64-valid? (TrustLineEntry-balance d))) d)
              ((λ (d) (int64-valid? (TrustLineEntry-limit d))) d)
              ((λ (d) (uint32-valid? (TrustLineEntry-flags d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (TrustLineEntry::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    ((λ (d)
                                       (and ((λ (d)
                                               (or ((λ (d)
                                                      (TrustLineEntry::ext::v1?
                                                       d))
                                                    d)
                                                   (raise-user-error
                                                    (format
                                                     (string-append
                                                      "invalid "
                                                      "struct type TrustLineEntry::ext::v1"
                                                      ": ~a")
                                                     d))))
                                             d)
                                            ((λ (d)
                                               (Liabilities-valid?
                                                (TrustLineEntry::ext::v1-liabilities
                                                 d)))
                                             d)
                                            ((λ (d)
                                               ((λ (d)
                                                  (and ((λ (d)
                                                          (or ((bitvector 32)
                                                               d)
                                                              (raise-user-error
                                                               (format
                                                                (string-append
                                                                 "invalid "
                                                                 "union tag"
                                                                 ": ~a")
                                                                d))))
                                                        (TrustLineEntry::ext::v1::ext-tag
                                                         d))
                                                       (for/or
                                                        ((c
                                                          (list
                                                           (λ (tag value)
                                                             (and (bveq
                                                                   tag
                                                                   (bv 0 32))
                                                                  (null?
                                                                   value)))
                                                           (λ (tag value)
                                                             (and (bveq
                                                                   tag
                                                                   (bv 2 32))
                                                                  (TrustLineEntryExtensionV2-valid?
                                                                   value))))))
                                                        (c
                                                         (TrustLineEntry::ext::v1::ext-tag
                                                          d)
                                                         (TrustLineEntry::ext::v1::ext-value
                                                          d)))))
                                                (TrustLineEntry::ext::v1-ext
                                                 d)))
                                             d)))
                                     value))))))
                          (c
                           (TrustLineEntry::ext-tag d)
                           (TrustLineEntry::ext-value d)))))
                  (TrustLineEntry-ext d)))
               d)))
       data))
    (define (BeginSponsoringFutureReservesOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (BeginSponsoringFutureReservesOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type BeginSponsoringFutureReservesOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 (AccountID-valid?
                  (BeginSponsoringFutureReservesOp-sponsoredID d)))
               d)))
       data))
    (define (string32-valid? data)
      ((λ (d)
         (or ((λ (d) (and (vector? d) (<= (vector-length d) 32))) d)
             (raise-user-error
              (format (string-append "invalid " "string" ": ~a") d))))
       data))
    (define (LedgerEntry-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (LedgerEntry? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type LedgerEntry"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (uint32-valid? (LedgerEntry-lastModifiedLedgerSeq d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (LedgerEntry::data-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32))
                                    (AccountEntry-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (TrustLineEntry-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 2 32))
                                    (OfferEntry-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 3 32))
                                    (DataEntry-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 4 32))
                                    (ClaimableBalanceEntry-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 5 32))
                                    (LiquidityPoolEntry-valid? value))))))
                          (c
                           (LedgerEntry::data-tag d)
                           (LedgerEntry::data-value d)))))
                  (LedgerEntry-data d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (LedgerEntry::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (LedgerEntryExtensionV1-valid? value))))))
                          (c
                           (LedgerEntry::ext-tag d)
                           (LedgerEntry::ext-value d)))))
                  (LedgerEntry-ext d)))
               d)))
       data))
    (define (ClawbackResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 -1 -2 -3 -4))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (PaymentOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (PaymentOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type PaymentOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (MuxedAccount-valid? (PaymentOp-destination d))) d)
              ((λ (d) (Asset-valid? (PaymentOp-asset d))) d)
              ((λ (d) (int64-valid? (PaymentOp-amount d))) d)))
       data))
    (define (ClaimableBalanceEntry-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ClaimableBalanceEntry? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ClaimableBalanceEntry"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 (ClaimableBalanceID-valid?
                  (ClaimableBalanceEntry-balanceID d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when 10 (<= (vector-length d) 10))
                                (for/and
                                 ((e (in-vector d)))
                                 (Claimant-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (ClaimableBalanceEntry-claimants d)))
               d)
              ((λ (d) (Asset-valid? (ClaimableBalanceEntry-asset d))) d)
              ((λ (d) (int64-valid? (ClaimableBalanceEntry-amount d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (ClaimableBalanceEntry::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (ClaimableBalanceEntryExtensionV1-valid?
                                     value))))))
                          (c
                           (ClaimableBalanceEntry::ext-tag d)
                           (ClaimableBalanceEntry::ext-value d)))))
                  (ClaimableBalanceEntry-ext d)))
               d)))
       data))
    (define (InflationResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (InflationResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32))
                         ((λ (d)
                            (or ((λ (d)
                                   (and (vector? d)
                                        (when #f (<= (vector-length d) #f))
                                        (for/and
                                         ((e (in-vector d)))
                                         (InflationPayout-valid? e))))
                                 d)
                                (raise-user-error
                                 (format
                                  (string-append
                                   "invalid "
                                   "variable-length array"
                                   ": ~a")
                                  d))))
                          value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c (InflationResult-tag d) (InflationResult-value d)))))
       data))
    (define (CreateAccountResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (CreateAccountResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c (CreateAccountResult-tag d) (CreateAccountResult-value d)))))
       data))
    (define (ClaimantType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (UpgradeType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and (vector? d)
                     (when 128 (<= (vector-length d) 128))
                     (for/and
                      ((e (in-vector d)))
                      ((λ (d)
                         (or ((bitvector 8) d)
                             (raise-user-error
                              (format
                               (string-append "invalid " "opaque" ": ~a")
                               d))))
                       e))))
              d)
             (raise-user-error
              (format
               (string-append "invalid " "variable-length array" ": ~a")
               d))))
       data))
    (define (Signature-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and (vector? d)
                     (when 64 (<= (vector-length d) 64))
                     (for/and
                      ((e (in-vector d)))
                      ((λ (d)
                         (or ((bitvector 8) d)
                             (raise-user-error
                              (format
                               (string-append "invalid " "opaque" ": ~a")
                               d))))
                       e))))
              d)
             (raise-user-error
              (format
               (string-append "invalid " "variable-length array" ": ~a")
               d))))
       data))
    (define (SetTrustLineFlagsResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (BeginSponsoringFutureReservesResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (BeginSponsoringFutureReservesResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (BeginSponsoringFutureReservesResult-tag d)
                (BeginSponsoringFutureReservesResult-value d)))))
       data))
    (define (ClaimClaimableBalanceOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ClaimClaimableBalanceOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ClaimClaimableBalanceOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 (ClaimableBalanceID-valid?
                  (ClaimClaimableBalanceOp-balanceID d)))
               d)))
       data))
    (define (LiquidityPoolDepositResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5 -6 -7)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (SignerKeyType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 1 2))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (EndSponsoringFutureReservesResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 -1))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (AssetType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 1 2 3))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (SimplePaymentResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (SimplePaymentResult? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type SimplePaymentResult"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (AccountID-valid? (SimplePaymentResult-destination d)))
               d)
              ((λ (d) (Asset-valid? (SimplePaymentResult-asset d))) d)
              ((λ (d) (int64-valid? (SimplePaymentResult-amount d))) d)))
       data))
    (define (BumpSequenceResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (BumpSequenceResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c (BumpSequenceResult-tag d) (BumpSequenceResult-value d)))))
       data))
    (define (ClaimAtomType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 1 2))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (AllowTrustOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (AllowTrustOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type AllowTrustOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (AccountID-valid? (AllowTrustOp-trustor d))) d)
              ((λ (d) (AssetCode-valid? (AllowTrustOp-asset d))) d)
              ((λ (d) (uint32-valid? (AllowTrustOp-authorize d))) d)))
       data))
    (define (ClaimableBalanceIDType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (ClaimAtom-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (ClaimAtom-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32)) (ClaimOfferAtomV0-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 1 32)) (ClaimOfferAtom-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 2 32))
                         (ClaimLiquidityAtom-valid? value))))))
               (c (ClaimAtom-tag d) (ClaimAtom-value d)))))
       data))
    (define (LedgerKey-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (LedgerKey-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32))
                         ((λ (d)
                            (and ((λ (d)
                                    (or ((λ (d) (LedgerKey::account? d)) d)
                                        (raise-user-error
                                         (format
                                          (string-append
                                           "invalid "
                                           "struct type LedgerKey::account"
                                           ": ~a")
                                          d))))
                                  d)
                                 ((λ (d)
                                    (AccountID-valid?
                                     (LedgerKey::account-accountID d)))
                                  d)))
                          value)))
                  (λ (tag value)
                    (and (bveq tag (bv 1 32))
                         ((λ (d)
                            (and ((λ (d)
                                    (or ((λ (d) (LedgerKey::trustLine? d)) d)
                                        (raise-user-error
                                         (format
                                          (string-append
                                           "invalid "
                                           "struct type LedgerKey::trustLine"
                                           ": ~a")
                                          d))))
                                  d)
                                 ((λ (d)
                                    (AccountID-valid?
                                     (LedgerKey::trustLine-accountID d)))
                                  d)
                                 ((λ (d)
                                    (TrustLineAsset-valid?
                                     (LedgerKey::trustLine-asset d)))
                                  d)))
                          value)))
                  (λ (tag value)
                    (and (bveq tag (bv 2 32))
                         ((λ (d)
                            (and ((λ (d)
                                    (or ((λ (d) (LedgerKey::offer? d)) d)
                                        (raise-user-error
                                         (format
                                          (string-append
                                           "invalid "
                                           "struct type LedgerKey::offer"
                                           ": ~a")
                                          d))))
                                  d)
                                 ((λ (d)
                                    (AccountID-valid?
                                     (LedgerKey::offer-sellerID d)))
                                  d)
                                 ((λ (d)
                                    (int64-valid?
                                     (LedgerKey::offer-offerID d)))
                                  d)))
                          value)))
                  (λ (tag value)
                    (and (bveq tag (bv 3 32))
                         ((λ (d)
                            (and ((λ (d)
                                    (or ((λ (d) (LedgerKey::data? d)) d)
                                        (raise-user-error
                                         (format
                                          (string-append
                                           "invalid "
                                           "struct type LedgerKey::data"
                                           ": ~a")
                                          d))))
                                  d)
                                 ((λ (d)
                                    (AccountID-valid?
                                     (LedgerKey::data-accountID d)))
                                  d)
                                 ((λ (d)
                                    (string64-valid?
                                     (LedgerKey::data-dataName d)))
                                  d)))
                          value)))
                  (λ (tag value)
                    (and (bveq tag (bv 4 32))
                         ((λ (d)
                            (and ((λ (d)
                                    (or ((λ (d)
                                           (LedgerKey::claimableBalance? d))
                                         d)
                                        (raise-user-error
                                         (format
                                          (string-append
                                           "invalid "
                                           "struct type LedgerKey::claimableBalance"
                                           ": ~a")
                                          d))))
                                  d)
                                 ((λ (d)
                                    (ClaimableBalanceID-valid?
                                     (LedgerKey::claimableBalance-balanceID
                                      d)))
                                  d)))
                          value)))
                  (λ (tag value)
                    (and (bveq tag (bv 5 32))
                         ((λ (d)
                            (and ((λ (d)
                                    (or ((λ (d) (LedgerKey::liquidityPool? d))
                                         d)
                                        (raise-user-error
                                         (format
                                          (string-append
                                           "invalid "
                                           "struct type LedgerKey::liquidityPool"
                                           ": ~a")
                                          d))))
                                  d)
                                 ((λ (d)
                                    (PoolID-valid?
                                     (LedgerKey::liquidityPool-liquidityPoolID
                                      d)))
                                  d)))
                          value))))))
               (c (LedgerKey-tag d) (LedgerKey-value d)))))
       data))
    (define (LiquidityPoolDepositResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (LiquidityPoolDepositResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -7 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -6 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (LiquidityPoolDepositResult-tag d)
                (LiquidityPoolDepositResult-value d)))))
       data))
    (define (ManageDataResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (ManageDataResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c (ManageDataResult-tag d) (ManageDataResult-value d)))))
       data))
    (define (BumpSequenceOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (BumpSequenceOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type BumpSequenceOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (SequenceNumber-valid? (BumpSequenceOp-bumpTo d))) d)))
       data))
    (define (Thresholds-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and (-byte-array? d) ((bitvector 32) (-byte-array-value d))))
              d)
             (raise-user-error
              (format
               (string-append "invalid " "fixed-length array" ": ~a")
               d))))
       data))
    (define (AccountID-valid? data) (PublicKey-valid? data))
    (define (ManageBuyOfferResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (ManageBuyOfferResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32))
                         (ManageOfferSuccessResult-valid? value)))
                  (λ (tag value) (and (bveq tag (bv -12 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -11 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -10 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -9 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -8 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -7 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -6 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (ManageBuyOfferResult-tag d)
                (ManageBuyOfferResult-value d)))))
       data))
    (define (InflationResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 -1))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (SignatureHint-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and (-byte-array? d) ((bitvector 32) (-byte-array-value d))))
              d)
             (raise-user-error
              (format
               (string-append "invalid " "fixed-length array" ": ~a")
               d))))
       data))
    (define (CreateClaimableBalanceResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (int64-valid? data)
      ((λ (d)
         (or ((bitvector 64) d)
             (raise-user-error
              (format (string-append "invalid " "hyper" ": ~a") d))))
       data))
    (define (Operation-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (Operation? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type Operation"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (MuxedAccount-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (Operation-sourceAccount d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (Operation::body-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32))
                                    (CreateAccountOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (PaymentOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 2 32))
                                    (PathPaymentStrictReceiveOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 3 32))
                                    (ManageSellOfferOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 4 32))
                                    (CreatePassiveSellOfferOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 5 32))
                                    (SetOptionsOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 6 32))
                                    (ChangeTrustOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 7 32))
                                    (AllowTrustOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 8 32))
                                    (MuxedAccount-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 9 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 10 32))
                                    (ManageDataOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 11 32))
                                    (BumpSequenceOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 12 32))
                                    (ManageBuyOfferOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 13 32))
                                    (PathPaymentStrictSendOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 14 32))
                                    (CreateClaimableBalanceOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 15 32))
                                    (ClaimClaimableBalanceOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 16 32))
                                    (BeginSponsoringFutureReservesOp-valid?
                                     value)))
                             (λ (tag value)
                               (and (bveq tag (bv 17 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 18 32))
                                    (RevokeSponsorshipOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 19 32))
                                    (ClawbackOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 20 32))
                                    (ClawbackClaimableBalanceOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 21 32))
                                    (SetTrustLineFlagsOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 22 32))
                                    (LiquidityPoolDepositOp-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 23 32))
                                    (LiquidityPoolWithdrawOp-valid? value))))))
                          (c
                           (Operation::body-tag d)
                           (Operation::body-value d)))))
                  (Operation-body d)))
               d)))
       data))
    (define (OperationType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v
                        (list
                         0
                         1
                         2
                         3
                         4
                         5
                         6
                         7
                         8
                         9
                         10
                         11
                         12
                         13
                         14
                         15
                         16
                         17
                         18
                         19
                         20
                         21
                         22
                         23)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (MemoType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 1 2 3 4))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (SequenceNumber-valid? data) (int64-valid? data))
    (define (PathPaymentStrictReceiveResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5 -6 -7 -8 -9 -10 -11 -12)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (AccountEntryExtensionV2-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (AccountEntryExtensionV2? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type AccountEntryExtensionV2"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (uint32-valid? (AccountEntryExtensionV2-numSponsored d)))
               d)
              ((λ (d)
                 (uint32-valid? (AccountEntryExtensionV2-numSponsoring d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when 20 (<= (vector-length d) 20))
                                (for/and
                                 ((e (in-vector d)))
                                 (SponsorshipDescriptor-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (AccountEntryExtensionV2-signerSponsoringIDs d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (AccountEntryExtensionV2::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c
                           (AccountEntryExtensionV2::ext-tag d)
                           (AccountEntryExtensionV2::ext-value d)))))
                  (AccountEntryExtensionV2-ext d)))
               d)))
       data))
    (define (TransactionResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (TransactionResult? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type TransactionResult"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (int64-valid? (TransactionResult-feeCharged d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (TransactionResult::result-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (InnerTransactionResultPair-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -13 32))
                                    (InnerTransactionResultPair-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32))
                                    ((λ (d)
                                       (or ((λ (d)
                                              (and (vector? d)
                                                   (when #f
                                                     (<= (vector-length d) #f))
                                                   (for/and
                                                    ((e (in-vector d)))
                                                    (OperationResult-valid?
                                                     e))))
                                            d)
                                           (raise-user-error
                                            (format
                                             (string-append
                                              "invalid "
                                              "variable-length array"
                                              ": ~a")
                                             d))))
                                     value)))
                             (λ (tag value)
                               (and (bveq tag (bv -1 32))
                                    ((λ (d)
                                       (or ((λ (d)
                                              (and (vector? d)
                                                   (when #f
                                                     (<= (vector-length d) #f))
                                                   (for/and
                                                    ((e (in-vector d)))
                                                    (OperationResult-valid?
                                                     e))))
                                            d)
                                           (raise-user-error
                                            (format
                                             (string-append
                                              "invalid "
                                              "variable-length array"
                                              ": ~a")
                                             d))))
                                     value)))
                             (λ (tag value)
                               (and (bveq tag (bv -14 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -12 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -11 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -10 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -9 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -8 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -7 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -6 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -5 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -4 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -3 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -2 32)) (null? value))))))
                          (c
                           (TransactionResult::result-tag d)
                           (TransactionResult::result-value d)))))
                  (TransactionResult-result d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (TransactionResult::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c
                           (TransactionResult::ext-tag d)
                           (TransactionResult::ext-value d)))))
                  (TransactionResult-ext d)))
               d)))
       data))
    (define (EnvelopeType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 1 2 3 4 5 6 7))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (ClaimOfferAtomV0-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ClaimOfferAtomV0? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ClaimOfferAtomV0"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (uint256-valid? (ClaimOfferAtomV0-sellerEd25519 d))) d)
              ((λ (d) (int64-valid? (ClaimOfferAtomV0-offerID d))) d)
              ((λ (d) (Asset-valid? (ClaimOfferAtomV0-assetSold d))) d)
              ((λ (d) (int64-valid? (ClaimOfferAtomV0-amountSold d))) d)
              ((λ (d) (Asset-valid? (ClaimOfferAtomV0-assetBought d))) d)
              ((λ (d) (int64-valid? (ClaimOfferAtomV0-amountBought d))) d)))
       data))
    (define (ClawbackClaimableBalanceOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ClawbackClaimableBalanceOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ClawbackClaimableBalanceOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 (ClaimableBalanceID-valid?
                  (ClawbackClaimableBalanceOp-balanceID d)))
               d)))
       data))
    (define (int32-valid? data)
      ((λ (d)
         (or ((bitvector 32) d)
             (raise-user-error
              (format (string-append "invalid " "int" ": ~a") d))))
       data))
    (define (RevokeSponsorshipResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (RevokeSponsorshipResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (RevokeSponsorshipResult-tag d)
                (RevokeSponsorshipResult-value d)))))
       data))
    (define (ClaimPredicateType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 1 2 3 4 5))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (LiquidityPoolType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (uint32-valid? data)
      ((λ (d)
         (or ((bitvector 32) d)
             (raise-user-error
              (format (string-append "invalid " "int" ": ~a") d))))
       data))
    (define (RevokeSponsorshipType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 1))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (EndSponsoringFutureReservesResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (EndSponsoringFutureReservesResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (EndSponsoringFutureReservesResult-tag d)
                (EndSponsoringFutureReservesResult-value d)))))
       data))
    (define (SetTrustLineFlagsOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (SetTrustLineFlagsOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type SetTrustLineFlagsOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (AccountID-valid? (SetTrustLineFlagsOp-trustor d))) d)
              ((λ (d) (Asset-valid? (SetTrustLineFlagsOp-asset d))) d)
              ((λ (d) (uint32-valid? (SetTrustLineFlagsOp-clearFlags d))) d)
              ((λ (d) (uint32-valid? (SetTrustLineFlagsOp-setFlags d))) d)))
       data))
    (define (LiquidityPoolDepositOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (LiquidityPoolDepositOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type LiquidityPoolDepositOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 (PoolID-valid? (LiquidityPoolDepositOp-liquidityPoolID d)))
               d)
              ((λ (d) (int64-valid? (LiquidityPoolDepositOp-maxAmountA d))) d)
              ((λ (d) (int64-valid? (LiquidityPoolDepositOp-maxAmountB d))) d)
              ((λ (d) (Price-valid? (LiquidityPoolDepositOp-minPrice d))) d)
              ((λ (d) (Price-valid? (LiquidityPoolDepositOp-maxPrice d))) d)))
       data))
    (define (ChangeTrustAsset-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (ChangeTrustAsset-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 1 32)) (AlphaNum4-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 2 32)) (AlphaNum12-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 3 32))
                         (LiquidityPoolParameters-valid? value))))))
               (c (ChangeTrustAsset-tag d) (ChangeTrustAsset-value d)))))
       data))
    (define (LedgerHeaderExtensionV1-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (LedgerHeaderExtensionV1? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type LedgerHeaderExtensionV1"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (uint32-valid? (LedgerHeaderExtensionV1-flags d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (LedgerHeaderExtensionV1::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c
                           (LedgerHeaderExtensionV1::ext-tag d)
                           (LedgerHeaderExtensionV1::ext-value d)))))
                  (LedgerHeaderExtensionV1-ext d)))
               d)))
       data))
    (define (LedgerHeader-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (LedgerHeader? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type LedgerHeader"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (uint32-valid? (LedgerHeader-ledgerVersion d))) d)
              ((λ (d) (Hash-valid? (LedgerHeader-previousLedgerHash d))) d)
              ((λ (d) (StellarValue-valid? (LedgerHeader-scpValue d))) d)
              ((λ (d) (Hash-valid? (LedgerHeader-txSetResultHash d))) d)
              ((λ (d) (Hash-valid? (LedgerHeader-bucketListHash d))) d)
              ((λ (d) (uint32-valid? (LedgerHeader-ledgerSeq d))) d)
              ((λ (d) (int64-valid? (LedgerHeader-totalCoins d))) d)
              ((λ (d) (int64-valid? (LedgerHeader-feePool d))) d)
              ((λ (d) (uint32-valid? (LedgerHeader-inflationSeq d))) d)
              ((λ (d) (uint64-valid? (LedgerHeader-idPool d))) d)
              ((λ (d) (uint32-valid? (LedgerHeader-baseFee d))) d)
              ((λ (d) (uint32-valid? (LedgerHeader-baseReserve d))) d)
              ((λ (d) (uint32-valid? (LedgerHeader-maxTxSetSize d))) d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (list? d)
                                (equal? (length d) 4)
                                (for/and ((e d)) (Hash-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "fixed-length array"
                           ": ~a")
                          d))))
                  (LedgerHeader-skipList d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (LedgerHeader::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (LedgerHeaderExtensionV1-valid? value))))))
                          (c
                           (LedgerHeader::ext-tag d)
                           (LedgerHeader::ext-value d)))))
                  (LedgerHeader-ext d)))
               d)))
       data))
    (define (CryptoKeyType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 1 2 256))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (ManageOfferEffect-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 1 2))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (TransactionV0Envelope-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (TransactionV0Envelope? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type TransactionV0Envelope"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (TransactionV0-valid? (TransactionV0Envelope-tx d))) d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when 20 (<= (vector-length d) 20))
                                (for/and
                                 ((e (in-vector d)))
                                 (DecoratedSignature-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (TransactionV0Envelope-signatures d)))
               d)))
       data))
    (define (InflationPayout-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (InflationPayout? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type InflationPayout"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (AccountID-valid? (InflationPayout-destination d))) d)
              ((λ (d) (int64-valid? (InflationPayout-amount d))) d)))
       data))
    (define (PathPaymentStrictReceiveOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (PathPaymentStrictReceiveOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type PathPaymentStrictReceiveOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (Asset-valid? (PathPaymentStrictReceiveOp-sendAsset d)))
               d)
              ((λ (d) (int64-valid? (PathPaymentStrictReceiveOp-sendMax d))) d)
              ((λ (d)
                 (MuxedAccount-valid?
                  (PathPaymentStrictReceiveOp-destination d)))
               d)
              ((λ (d) (Asset-valid? (PathPaymentStrictReceiveOp-destAsset d)))
               d)
              ((λ (d) (int64-valid? (PathPaymentStrictReceiveOp-destAmount d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when 5 (<= (vector-length d) 5))
                                (for/and
                                 ((e (in-vector d)))
                                 (Asset-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (PathPaymentStrictReceiveOp-path d)))
               d)))
       data))
    (define (ClawbackResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (ClawbackResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c (ClawbackResult-tag d) (ClawbackResult-value d)))))
       data))
    (define (Ledger-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (Ledger? d)) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "struct type Ledger" ": ~a")
                       d))))
               d)
              ((λ (d) (LedgerHeader-valid? (Ledger-header d))) d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when #f (<= (vector-length d) #f))
                                (for/and
                                 ((e (in-vector d)))
                                 (LedgerEntry-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (Ledger-entries d)))
               d)))
       data))
    (define (ClawbackOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ClawbackOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ClawbackOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (Asset-valid? (ClawbackOp-asset d))) d)
              ((λ (d) (MuxedAccount-valid? (ClawbackOp-from d))) d)
              ((λ (d) (int64-valid? (ClawbackOp-amount d))) d)))
       data))
    (define (ClaimPredicate-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (ClaimPredicate-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 4 32)) (int64-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 5 32)) (int64-valid? value))))))
               (c (ClaimPredicate-tag d) (ClaimPredicate-value d)))))
       data))
    (define (LiquidityPoolConstantProductParameters-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (LiquidityPoolConstantProductParameters? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type LiquidityPoolConstantProductParameters"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 (Asset-valid?
                  (LiquidityPoolConstantProductParameters-assetA d)))
               d)
              ((λ (d)
                 (Asset-valid?
                  (LiquidityPoolConstantProductParameters-assetB d)))
               d)
              ((λ (d)
                 (int32-valid? (LiquidityPoolConstantProductParameters-fee d)))
               d)))
       data))
    (define (NodeID-valid? data) (PublicKey-valid? data))
    (define (ClawbackClaimableBalanceResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 -1 -2 -3))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (LedgerEntryExtensionV1-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (LedgerEntryExtensionV1? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type LedgerEntryExtensionV1"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 (SponsorshipDescriptor-valid?
                  (LedgerEntryExtensionV1-sponsoringID d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (LedgerEntryExtensionV1::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c
                           (LedgerEntryExtensionV1::ext-tag d)
                           (LedgerEntryExtensionV1::ext-value d)))))
                  (LedgerEntryExtensionV1-ext d)))
               d)))
       data))
    (define (LedgerCloseValueSignature-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (LedgerCloseValueSignature? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type LedgerCloseValueSignature"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (NodeID-valid? (LedgerCloseValueSignature-nodeID d))) d)
              ((λ (d)
                 (Signature-valid? (LedgerCloseValueSignature-signature d)))
               d)))
       data))
    (define (LiquidityPoolWithdrawOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (LiquidityPoolWithdrawOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type LiquidityPoolWithdrawOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 (PoolID-valid? (LiquidityPoolWithdrawOp-liquidityPoolID d)))
               d)
              ((λ (d) (int64-valid? (LiquidityPoolWithdrawOp-amount d))) d)
              ((λ (d) (int64-valid? (LiquidityPoolWithdrawOp-minAmountA d))) d)
              ((λ (d) (int64-valid? (LiquidityPoolWithdrawOp-minAmountB d)))
               d)))
       data))
    (define (ManageDataOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ManageDataOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ManageDataOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (string64-valid? (ManageDataOp-dataName d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (DataValue-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (ManageDataOp-dataValue d)))
               d)))
       data))
    (define (ClaimClaimableBalanceResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (ClaimClaimableBalanceResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (ClaimClaimableBalanceResult-tag d)
                (ClaimClaimableBalanceResult-value d)))))
       data))
    (define (uint256-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and (-byte-array? d) ((bitvector 256) (-byte-array-value d))))
              d)
             (raise-user-error
              (format
               (string-append "invalid " "fixed-length array" ": ~a")
               d))))
       data))
    (define (AllowTrustResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5 -6)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (SetOptionsResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (SetOptionsResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -10 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -9 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -8 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -7 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -6 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c (SetOptionsResult-tag d) (SetOptionsResult-value d)))))
       data))
    (define (MuxedAccount-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (MuxedAccount-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32)) (uint256-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 256 32))
                         ((λ (d)
                            (and ((λ (d)
                                    (or ((λ (d) (MuxedAccount::med25519? d)) d)
                                        (raise-user-error
                                         (format
                                          (string-append
                                           "invalid "
                                           "struct type MuxedAccount::med25519"
                                           ": ~a")
                                          d))))
                                  d)
                                 ((λ (d)
                                    (uint64-valid?
                                     (MuxedAccount::med25519-id d)))
                                  d)
                                 ((λ (d)
                                    (uint256-valid?
                                     (MuxedAccount::med25519-ed25519 d)))
                                  d)))
                          value))))))
               (c (MuxedAccount-tag d) (MuxedAccount-value d)))))
       data))
    (define (AlphaNum4-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (AlphaNum4? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type AlphaNum4"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (AssetCode4-valid? (AlphaNum4-assetCode d))) d)
              ((λ (d) (AccountID-valid? (AlphaNum4-issuer d))) d)))
       data))
    (define (BumpSequenceResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 -1))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (SignerKey-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (SignerKey-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32)) (uint256-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 1 32)) (uint256-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 2 32)) (uint256-valid? value))))))
               (c (SignerKey-tag d) (SignerKey-value d)))))
       data))
    (define (ManageSellOfferResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (ManageSellOfferResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32))
                         (ManageOfferSuccessResult-valid? value)))
                  (λ (tag value) (and (bveq tag (bv -12 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -11 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -10 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -9 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -8 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -7 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -6 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (ManageSellOfferResult-tag d)
                (ManageSellOfferResult-value d)))))
       data))
    (define (LiquidityPoolParameters-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (LiquidityPoolParameters-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32))
                         (LiquidityPoolConstantProductParameters-valid?
                          value))))))
               (c
                (LiquidityPoolParameters-tag d)
                (LiquidityPoolParameters-value d)))))
       data))
    (define (PathPaymentStrictSendResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (PathPaymentStrictSendResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32))
                         ((λ (d)
                            (and ((λ (d)
                                    (or ((λ (d)
                                           (PathPaymentStrictSendResult::success?
                                            d))
                                         d)
                                        (raise-user-error
                                         (format
                                          (string-append
                                           "invalid "
                                           "struct type PathPaymentStrictSendResult::success"
                                           ": ~a")
                                          d))))
                                  d)
                                 ((λ (d)
                                    ((λ (d)
                                       (or ((λ (d)
                                              (and (vector? d)
                                                   (when #f
                                                     (<= (vector-length d) #f))
                                                   (for/and
                                                    ((e (in-vector d)))
                                                    (ClaimAtom-valid? e))))
                                            d)
                                           (raise-user-error
                                            (format
                                             (string-append
                                              "invalid "
                                              "variable-length array"
                                              ": ~a")
                                             d))))
                                     (PathPaymentStrictSendResult::success-offers
                                      d)))
                                  d)
                                 ((λ (d)
                                    (SimplePaymentResult-valid?
                                     (PathPaymentStrictSendResult::success-last
                                      d)))
                                  d)))
                          value)))
                  (λ (tag value)
                    (and (bveq tag (bv -9 32)) (Asset-valid? value)))
                  (λ (tag value) (and (bveq tag (bv -12 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -11 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -10 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -8 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -7 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -6 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (PathPaymentStrictSendResult-tag d)
                (PathPaymentStrictSendResult-value d)))))
       data))
    (define (TimePoint-valid? data) (uint64-valid? data))
    (define (ManageSellOfferResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5 -6 -7 -8 -9 -10 -11 -12)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (Price-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (Price? d)) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "struct type Price" ": ~a")
                       d))))
               d)
              ((λ (d) (int32-valid? (Price-n d))) d)
              ((λ (d) (int32-valid? (Price-d d))) d)))
       data))
    (define (AccountMergeResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5 -6 -7)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (Hash-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and (-byte-array? d) ((bitvector 256) (-byte-array-value d))))
              d)
             (raise-user-error
              (format
               (string-append "invalid " "fixed-length array" ": ~a")
               d))))
       data))
    (define (CreateClaimableBalanceResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (CreateClaimableBalanceResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32))
                         (ClaimableBalanceID-valid? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (CreateClaimableBalanceResult-tag d)
                (CreateClaimableBalanceResult-value d)))))
       data))
    (define (StellarValueType-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 1))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (ClaimLiquidityAtom-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ClaimLiquidityAtom? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ClaimLiquidityAtom"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (PoolID-valid? (ClaimLiquidityAtom-liquidityPoolID d)))
               d)
              ((λ (d) (Asset-valid? (ClaimLiquidityAtom-assetSold d))) d)
              ((λ (d) (int64-valid? (ClaimLiquidityAtom-amountSold d))) d)
              ((λ (d) (Asset-valid? (ClaimLiquidityAtom-assetBought d))) d)
              ((λ (d) (int64-valid? (ClaimLiquidityAtom-amountBought d))) d)))
       data))
    (define (AccountMergeResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (AccountMergeResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32)) (int64-valid? value)))
                  (λ (tag value) (and (bveq tag (bv -7 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -6 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c (AccountMergeResult-tag d) (AccountMergeResult-value d)))))
       data))
    (define (OfferEntry-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (OfferEntry? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type OfferEntry"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (AccountID-valid? (OfferEntry-sellerID d))) d)
              ((λ (d) (int64-valid? (OfferEntry-offerID d))) d)
              ((λ (d) (Asset-valid? (OfferEntry-selling d))) d)
              ((λ (d) (Asset-valid? (OfferEntry-buying d))) d)
              ((λ (d) (int64-valid? (OfferEntry-amount d))) d)
              ((λ (d) (Price-valid? (OfferEntry-price d))) d)
              ((λ (d) (uint32-valid? (OfferEntry-flags d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (OfferEntry::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c
                           (OfferEntry::ext-tag d)
                           (OfferEntry::ext-value d)))))
                  (OfferEntry-ext d)))
               d)))
       data))
    (define (SetOptionsOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (SetOptionsOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type SetOptionsOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (AccountID-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (SetOptionsOp-inflationDest d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (uint32-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (SetOptionsOp-clearFlags d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (uint32-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (SetOptionsOp-setFlags d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (uint32-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (SetOptionsOp-masterWeight d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (uint32-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (SetOptionsOp-lowThreshold d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (uint32-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (SetOptionsOp-medThreshold d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (uint32-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (SetOptionsOp-highThreshold d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (string32-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (SetOptionsOp-homeDomain d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (Signer-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (SetOptionsOp-signer d)))
               d)))
       data))
    (define (AssetCode4-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and (-byte-array? d) ((bitvector 32) (-byte-array-value d))))
              d)
             (raise-user-error
              (format
               (string-append "invalid " "fixed-length array" ": ~a")
               d))))
       data))
    (define (FeeBumpTransactionEnvelope-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (FeeBumpTransactionEnvelope? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type FeeBumpTransactionEnvelope"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 (FeeBumpTransaction-valid? (FeeBumpTransactionEnvelope-tx d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when 20 (<= (vector-length d) 20))
                                (for/and
                                 ((e (in-vector d)))
                                 (DecoratedSignature-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (FeeBumpTransactionEnvelope-signatures d)))
               d)))
       data))
    (define (InnerTransactionResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (InnerTransactionResult? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type InnerTransactionResult"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (int64-valid? (InnerTransactionResult-feeCharged d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (InnerTransactionResult::result-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32))
                                    ((λ (d)
                                       (or ((λ (d)
                                              (and (vector? d)
                                                   (when #f
                                                     (<= (vector-length d) #f))
                                                   (for/and
                                                    ((e (in-vector d)))
                                                    (OperationResult-valid?
                                                     e))))
                                            d)
                                           (raise-user-error
                                            (format
                                             (string-append
                                              "invalid "
                                              "variable-length array"
                                              ": ~a")
                                             d))))
                                     value)))
                             (λ (tag value)
                               (and (bveq tag (bv -1 32))
                                    ((λ (d)
                                       (or ((λ (d)
                                              (and (vector? d)
                                                   (when #f
                                                     (<= (vector-length d) #f))
                                                   (for/and
                                                    ((e (in-vector d)))
                                                    (OperationResult-valid?
                                                     e))))
                                            d)
                                           (raise-user-error
                                            (format
                                             (string-append
                                              "invalid "
                                              "variable-length array"
                                              ": ~a")
                                             d))))
                                     value)))
                             (λ (tag value)
                               (and (bveq tag (bv -2 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -3 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -4 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -5 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -6 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -7 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -8 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -9 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -10 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -11 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -12 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv -14 32)) (null? value))))))
                          (c
                           (InnerTransactionResult::result-tag d)
                           (InnerTransactionResult::result-value d)))))
                  (InnerTransactionResult-result d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (InnerTransactionResult::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c
                           (InnerTransactionResult::ext-tag d)
                           (InnerTransactionResult::ext-value d)))))
                  (InnerTransactionResult-ext d)))
               d)))
       data))
    (define (bool-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 1 0))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (PublicKey-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (PublicKey-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32)) (uint256-valid? value))))))
               (c (PublicKey-tag d) (PublicKey-value d)))))
       data))
    (define (Asset-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (Asset-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 1 32)) (AlphaNum4-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 2 32)) (AlphaNum12-valid? value))))))
               (c (Asset-tag d) (Asset-value d)))))
       data))
    (define (FeeBumpTransaction-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (FeeBumpTransaction? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type FeeBumpTransaction"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (MuxedAccount-valid? (FeeBumpTransaction-feeSource d)))
               d)
              ((λ (d) (int64-valid? (FeeBumpTransaction-fee d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (FeeBumpTransaction::innerTx-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 2 32))
                                    (TransactionV1Envelope-valid? value))))))
                          (c
                           (FeeBumpTransaction::innerTx-tag d)
                           (FeeBumpTransaction::innerTx-value d)))))
                  (FeeBumpTransaction-innerTx d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (FeeBumpTransaction::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c
                           (FeeBumpTransaction::ext-tag d)
                           (FeeBumpTransaction::ext-value d)))))
                  (FeeBumpTransaction-ext d)))
               d)))
       data))
    (define (BeginSponsoringFutureReservesResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or ((v (list 0 -1 -2 -3))) (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data))
    (define (PaymentResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (PaymentResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -9 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -8 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -7 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -6 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c (PaymentResult-tag d) (PaymentResult-value d)))))
       data))
    (define (uint64-valid? data)
      ((λ (d)
         (or ((bitvector 64) d)
             (raise-user-error
              (format (string-append "invalid " "hyper" ": ~a") d))))
       data))
    (define (CreateAccountOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (CreateAccountOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type CreateAccountOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (AccountID-valid? (CreateAccountOp-destination d))) d)
              ((λ (d) (int64-valid? (CreateAccountOp-startingBalance d))) d)))
       data))
    (define (TrustLineAsset-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (TrustLineAsset-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value) (and (bveq tag (bv 0 32)) (null? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 1 32)) (AlphaNum4-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 2 32)) (AlphaNum12-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 3 32)) (PoolID-valid? value))))))
               (c (TrustLineAsset-tag d) (TrustLineAsset-value d)))))
       data))
    (define (ChangeTrustOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ChangeTrustOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ChangeTrustOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (ChangeTrustAsset-valid? (ChangeTrustOp-line d))) d)
              ((λ (d) (int64-valid? (ChangeTrustOp-limit d))) d)))
       data))
    (define (PathPaymentStrictReceiveResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (PathPaymentStrictReceiveResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32))
                         ((λ (d)
                            (and ((λ (d)
                                    (or ((λ (d)
                                           (PathPaymentStrictReceiveResult::success?
                                            d))
                                         d)
                                        (raise-user-error
                                         (format
                                          (string-append
                                           "invalid "
                                           "struct type PathPaymentStrictReceiveResult::success"
                                           ": ~a")
                                          d))))
                                  d)
                                 ((λ (d)
                                    ((λ (d)
                                       (or ((λ (d)
                                              (and (vector? d)
                                                   (when #f
                                                     (<= (vector-length d) #f))
                                                   (for/and
                                                    ((e (in-vector d)))
                                                    (ClaimAtom-valid? e))))
                                            d)
                                           (raise-user-error
                                            (format
                                             (string-append
                                              "invalid "
                                              "variable-length array"
                                              ": ~a")
                                             d))))
                                     (PathPaymentStrictReceiveResult::success-offers
                                      d)))
                                  d)
                                 ((λ (d)
                                    (SimplePaymentResult-valid?
                                     (PathPaymentStrictReceiveResult::success-last
                                      d)))
                                  d)))
                          value)))
                  (λ (tag value)
                    (and (bveq tag (bv -9 32)) (Asset-valid? value)))
                  (λ (tag value) (and (bveq tag (bv -12 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -11 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -10 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -8 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -7 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -6 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c
                (PathPaymentStrictReceiveResult-tag d)
                (PathPaymentStrictReceiveResult-value d)))))
       data))
    (define (OperationResult-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (OperationResult-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32))
                         ((λ (d)
                            (and ((λ (d)
                                    (or ((bitvector 32) d)
                                        (raise-user-error
                                         (format
                                          (string-append
                                           "invalid "
                                           "union tag"
                                           ": ~a")
                                          d))))
                                  (OperationResult::tr-tag d))
                                 (for/or
                                  ((c
                                    (list
                                     (λ (tag value)
                                       (and (bveq tag (bv 0 32))
                                            (CreateAccountResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 1 32))
                                            (PaymentResult-valid? value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 2 32))
                                            (PathPaymentStrictReceiveResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 3 32))
                                            (ManageSellOfferResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 4 32))
                                            (ManageSellOfferResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 5 32))
                                            (SetOptionsResult-valid? value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 6 32))
                                            (ChangeTrustResult-valid? value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 7 32))
                                            (AllowTrustResult-valid? value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 8 32))
                                            (AccountMergeResult-valid? value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 9 32))
                                            (InflationResult-valid? value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 10 32))
                                            (ManageDataResult-valid? value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 11 32))
                                            (BumpSequenceResult-valid? value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 12 32))
                                            (ManageBuyOfferResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 13 32))
                                            (PathPaymentStrictSendResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 14 32))
                                            (CreateClaimableBalanceResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 15 32))
                                            (ClaimClaimableBalanceResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 16 32))
                                            (BeginSponsoringFutureReservesResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 17 32))
                                            (EndSponsoringFutureReservesResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 18 32))
                                            (RevokeSponsorshipResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 19 32))
                                            (ClawbackResult-valid? value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 20 32))
                                            (ClawbackClaimableBalanceResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 21 32))
                                            (SetTrustLineFlagsResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 22 32))
                                            (LiquidityPoolDepositResult-valid?
                                             value)))
                                     (λ (tag value)
                                       (and (bveq tag (bv 23 32))
                                            (LiquidityPoolWithdrawResult-valid?
                                             value))))))
                                  (c
                                   (OperationResult::tr-tag d)
                                   (OperationResult::tr-value d)))))
                          value)))
                  (λ (tag value) (and (bveq tag (bv -6 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -5 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -4 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -3 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -2 32)) (null? value)))
                  (λ (tag value) (and (bveq tag (bv -1 32)) (null? value))))))
               (c (OperationResult-tag d) (OperationResult-value d)))))
       data))
    (define (TransactionEnvelope-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (TransactionEnvelope-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32))
                         (TransactionV0Envelope-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 2 32))
                         (TransactionV1Envelope-valid? value)))
                  (λ (tag value)
                    (and (bveq tag (bv 5 32))
                         (FeeBumpTransactionEnvelope-valid? value))))))
               (c (TransactionEnvelope-tag d) (TransactionEnvelope-value d)))))
       data))
    (define (AccountEntryExtensionV1-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (AccountEntryExtensionV1? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type AccountEntryExtensionV1"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 (Liabilities-valid? (AccountEntryExtensionV1-liabilities d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (AccountEntryExtensionV1::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 2 32))
                                    (AccountEntryExtensionV2-valid? value))))))
                          (c
                           (AccountEntryExtensionV1::ext-tag d)
                           (AccountEntryExtensionV1::ext-value d)))))
                  (AccountEntryExtensionV1-ext d)))
               d)))
       data))
    (define (ManageSellOfferOp-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (ManageSellOfferOp? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type ManageSellOfferOp"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (Asset-valid? (ManageSellOfferOp-selling d))) d)
              ((λ (d) (Asset-valid? (ManageSellOfferOp-buying d))) d)
              ((λ (d) (int64-valid? (ManageSellOfferOp-amount d))) d)
              ((λ (d) (Price-valid? (ManageSellOfferOp-price d))) d)
              ((λ (d) (int64-valid? (ManageSellOfferOp-offerID d))) d)))
       data))
    (define (DecoratedSignature-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (DecoratedSignature? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type DecoratedSignature"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (SignatureHint-valid? (DecoratedSignature-hint d))) d)
              ((λ (d) (Signature-valid? (DecoratedSignature-signature d))) d)))
       data))
    (define (Liabilities-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (Liabilities? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type Liabilities"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (int64-valid? (Liabilities-buying d))) d)
              ((λ (d) (int64-valid? (Liabilities-selling d))) d)))
       data))
    (define (TransactionV0-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (TransactionV0? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type TransactionV0"
                        ": ~a")
                       d))))
               d)
              ((λ (d) (uint256-valid? (TransactionV0-sourceAccountEd25519 d)))
               d)
              ((λ (d) (uint32-valid? (TransactionV0-fee d))) d)
              ((λ (d) (SequenceNumber-valid? (TransactionV0-seqNum d))) d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (-optional-present d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 1 32))
                                    (TimeBounds-valid? value)))
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c (-optional-present d) (-optional-value d)))))
                  (TransactionV0-timeBounds d)))
               d)
              ((λ (d) (Memo-valid? (TransactionV0-memo d))) d)
              ((λ (d)
                 ((λ (d)
                    (or ((λ (d)
                           (and (vector? d)
                                (when 100 (<= (vector-length d) 100))
                                (for/and
                                 ((e (in-vector d)))
                                 (Operation-valid? e))))
                         d)
                        (raise-user-error
                         (format
                          (string-append
                           "invalid "
                           "variable-length array"
                           ": ~a")
                          d))))
                  (TransactionV0-operations d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (TransactionV0::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c
                           (TransactionV0::ext-tag d)
                           (TransactionV0::ext-value d)))))
                  (TransactionV0-ext d)))
               d)))
       data))
    (define (TrustLineEntryExtensionV2-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((λ (d) (TrustLineEntryExtensionV2? d)) d)
                     (raise-user-error
                      (format
                       (string-append
                        "invalid "
                        "struct type TrustLineEntryExtensionV2"
                        ": ~a")
                       d))))
               d)
              ((λ (d)
                 (int32-valid?
                  (TrustLineEntryExtensionV2-liquidityPoolUseCount d)))
               d)
              ((λ (d)
                 ((λ (d)
                    (and ((λ (d)
                            (or ((bitvector 32) d)
                                (raise-user-error
                                 (format
                                  (string-append "invalid " "union tag" ": ~a")
                                  d))))
                          (TrustLineEntryExtensionV2::ext-tag d))
                         (for/or
                          ((c
                            (list
                             (λ (tag value)
                               (and (bveq tag (bv 0 32)) (null? value))))))
                          (c
                           (TrustLineEntryExtensionV2::ext-tag d)
                           (TrustLineEntryExtensionV2::ext-value d)))))
                  (TrustLineEntryExtensionV2-ext d)))
               d)))
       data))
    (define (ClaimableBalanceID-valid? data)
      ((λ (d)
         (and ((λ (d)
                 (or ((bitvector 32) d)
                     (raise-user-error
                      (format
                       (string-append "invalid " "union tag" ": ~a")
                       d))))
               (ClaimableBalanceID-tag d))
              (for/or
               ((c
                 (list
                  (λ (tag value)
                    (and (bveq tag (bv 0 32)) (Hash-valid? value))))))
               (c (ClaimableBalanceID-tag d) (ClaimableBalanceID-value d)))))
       data))
    (define (ClaimClaimableBalanceResultCode-valid? data)
      ((λ (d)
         (or ((λ (d)
                (and ((bitvector 32) d)
                     (for/or
                      ((v (list 0 -1 -2 -3 -4 -5)))
                      (bveq d (bv v 32)))))
              d)
             (raise-user-error
              (format (string-append "invalid " "enum" ": ~a") d))))
       data)))
  (define-grammar
   (the-grammar)
   (Claimant-rule
    (Claimant
     (bv CLAIMANT_TYPE_V0 32)
     (Claimant::v0 (AccountID-rule) (ClaimPredicate-rule))))
   (ClaimableBalanceEntryExtensionV1-rule
    (ClaimableBalanceEntryExtensionV1
     (ClaimableBalanceEntryExtensionV1::ext (bv 0 32) null)
     (uint32-rule)))
   (ChangeTrustResultCode-rule
    (choose
     CHANGE_TRUST_SUCCESS
     CHANGE_TRUST_MALFORMED
     CHANGE_TRUST_NO_ISSUER
     CHANGE_TRUST_INVALID_LIMIT
     CHANGE_TRUST_LOW_RESERVE
     CHANGE_TRUST_SELF_NOT_ALLOWED
     CHANGE_TRUST_TRUST_LINE_MISSING
     CHANGE_TRUST_CANNOT_DELETE
     CHANGE_TRUST_NOT_AUTH_MAINTAIN_LIABILITIES))
   (SponsorshipDescriptor-rule
    (choose
     (-optional (bv TRUE 32) (AccountID-rule))
     (-optional (bv FALSE 32) null)))
   (AllowTrustResult-rule
    (choose
     (AllowTrustResult (bv ALLOW_TRUST_SUCCESS 32) null)
     (AllowTrustResult (bv ALLOW_TRUST_LOW_RESERVE 32) null)
     (AllowTrustResult (bv ALLOW_TRUST_SELF_NOT_ALLOWED 32) null)
     (AllowTrustResult (bv ALLOW_TRUST_CANT_REVOKE 32) null)
     (AllowTrustResult (bv ALLOW_TRUST_TRUST_NOT_REQUIRED 32) null)
     (AllowTrustResult (bv ALLOW_TRUST_NO_TRUST_LINE 32) null)
     (AllowTrustResult (bv ALLOW_TRUST_MALFORMED 32) null)))
   (AssetCode12-rule (-byte-array (?? (bitvector 96))))
   (Memo-rule
    (choose
     (Memo (bv MEMO_NONE 32) null)
     (Memo
      (bv MEMO_TEXT 32)
      (vector (?? (bitvector 8)) (?? (bitvector 8)) (?? (bitvector 8))))
     (Memo (bv MEMO_ID 32) (uint64-rule))
     (Memo (bv MEMO_HASH 32) (Hash-rule))
     (Memo (bv MEMO_RETURN 32) (Hash-rule))))
   (AlphaNum12-rule (AlphaNum12 (AssetCode12-rule) (AccountID-rule)))
   (LedgerEntryType-rule
    (choose ACCOUNT TRUSTLINE OFFER DATA CLAIMABLE_BALANCE LIQUIDITY_POOL))
   (RevokeSponsorshipOp-rule
    (choose
     (RevokeSponsorshipOp
      (bv REVOKE_SPONSORSHIP_LEDGER_ENTRY 32)
      (LedgerKey-rule))
     (RevokeSponsorshipOp
      (bv REVOKE_SPONSORSHIP_SIGNER 32)
      (RevokeSponsorshipOp::signer (AccountID-rule) (SignerKey-rule)))))
   (AssetCode-rule
    (choose
     (AssetCode (bv ASSET_TYPE_CREDIT_ALPHANUM4 32) (AssetCode4-rule))
     (AssetCode (bv ASSET_TYPE_CREDIT_ALPHANUM12 32) (AssetCode12-rule))))
   (ClaimOfferAtom-rule
    (ClaimOfferAtom
     (AccountID-rule)
     (int64-rule)
     (Asset-rule)
     (int64-rule)
     (Asset-rule)
     (int64-rule)))
   (CreateAccountResultCode-rule
    (choose
     CREATE_ACCOUNT_SUCCESS
     CREATE_ACCOUNT_MALFORMED
     CREATE_ACCOUNT_UNDERFUNDED
     CREATE_ACCOUNT_LOW_RESERVE
     CREATE_ACCOUNT_ALREADY_EXIST))
   (TransactionV1Envelope-rule
    (TransactionV1Envelope (Transaction-rule) (vector)))
   (SetTrustLineFlagsResult-rule
    (choose
     (SetTrustLineFlagsResult (bv SET_TRUST_LINE_FLAGS_SUCCESS 32) null)
     (SetTrustLineFlagsResult (bv SET_TRUST_LINE_FLAGS_LOW_RESERVE 32) null)
     (SetTrustLineFlagsResult (bv SET_TRUST_LINE_FLAGS_INVALID_STATE 32) null)
     (SetTrustLineFlagsResult (bv SET_TRUST_LINE_FLAGS_CANT_REVOKE 32) null)
     (SetTrustLineFlagsResult (bv SET_TRUST_LINE_FLAGS_NO_TRUST_LINE 32) null)
     (SetTrustLineFlagsResult (bv SET_TRUST_LINE_FLAGS_MALFORMED 32) null)))
   (LiquidityPoolWithdrawResultCode-rule
    (choose
     LIQUIDITY_POOL_WITHDRAW_SUCCESS
     LIQUIDITY_POOL_WITHDRAW_MALFORMED
     LIQUIDITY_POOL_WITHDRAW_NO_TRUST
     LIQUIDITY_POOL_WITHDRAW_UNDERFUNDED
     LIQUIDITY_POOL_WITHDRAW_LINE_FULL
     LIQUIDITY_POOL_WITHDRAW_UNDER_MINIMUM))
   (InnerTransactionResultPair-rule
    (InnerTransactionResultPair (Hash-rule) (InnerTransactionResult-rule)))
   (ManageBuyOfferResultCode-rule
    (choose
     MANAGE_BUY_OFFER_SUCCESS
     MANAGE_BUY_OFFER_MALFORMED
     MANAGE_BUY_OFFER_SELL_NO_TRUST
     MANAGE_BUY_OFFER_BUY_NO_TRUST
     MANAGE_BUY_OFFER_SELL_NOT_AUTHORIZED
     MANAGE_BUY_OFFER_BUY_NOT_AUTHORIZED
     MANAGE_BUY_OFFER_LINE_FULL
     MANAGE_BUY_OFFER_UNDERFUNDED
     MANAGE_BUY_OFFER_CROSS_SELF
     MANAGE_BUY_OFFER_SELL_NO_ISSUER
     MANAGE_BUY_OFFER_BUY_NO_ISSUER
     MANAGE_BUY_OFFER_NOT_FOUND
     MANAGE_BUY_OFFER_LOW_RESERVE))
   (AccountEntry-rule
    (AccountEntry
     (AccountID-rule)
     (int64-rule)
     (SequenceNumber-rule)
     (uint32-rule)
     (choose
      (-optional (bv TRUE 32) (AccountID-rule))
      (-optional (bv FALSE 32) null))
     (uint32-rule)
     (string32-rule)
     (Thresholds-rule)
     (vector (Signer-rule))
     (choose
      (AccountEntry::ext (bv 0 32) null)
      (AccountEntry::ext (bv 1 32) (AccountEntryExtensionV1-rule)))))
   (LiquidityPoolEntry-rule
    (LiquidityPoolEntry
     (PoolID-rule)
     (LiquidityPoolEntry::body
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
     (ClawbackClaimableBalanceResult
      (bv CLAWBACK_CLAIMABLE_BALANCE_SUCCESS 32)
      null)
     (ClawbackClaimableBalanceResult
      (bv CLAWBACK_CLAIMABLE_BALANCE_NOT_CLAWBACK_ENABLED 32)
      null)
     (ClawbackClaimableBalanceResult
      (bv CLAWBACK_CLAIMABLE_BALANCE_NOT_ISSUER 32)
      null)
     (ClawbackClaimableBalanceResult
      (bv CLAWBACK_CLAIMABLE_BALANCE_DOES_NOT_EXIST 32)
      null)))
   (CreateClaimableBalanceOp-rule
    (CreateClaimableBalanceOp
     (Asset-rule)
     (int64-rule)
     (vector (Claimant-rule) (Claimant-rule) (Claimant-rule))))
   (StellarValue-rule
    (StellarValue
     (Hash-rule)
     (TimePoint-rule)
     (vector (UpgradeType-rule) (UpgradeType-rule) (UpgradeType-rule))
     (choose
      (StellarValue::ext (bv STELLAR_VALUE_BASIC 32) null)
      (StellarValue::ext
       (bv STELLAR_VALUE_SIGNED 32)
       (LedgerCloseValueSignature-rule)))))
   (ChangeTrustResult-rule
    (choose
     (ChangeTrustResult (bv CHANGE_TRUST_SUCCESS 32) null)
     (ChangeTrustResult
      (bv CHANGE_TRUST_NOT_AUTH_MAINTAIN_LIABILITIES 32)
      null)
     (ChangeTrustResult (bv CHANGE_TRUST_CANNOT_DELETE 32) null)
     (ChangeTrustResult (bv CHANGE_TRUST_TRUST_LINE_MISSING 32) null)
     (ChangeTrustResult (bv CHANGE_TRUST_SELF_NOT_ALLOWED 32) null)
     (ChangeTrustResult (bv CHANGE_TRUST_LOW_RESERVE 32) null)
     (ChangeTrustResult (bv CHANGE_TRUST_INVALID_LIMIT 32) null)
     (ChangeTrustResult (bv CHANGE_TRUST_NO_ISSUER 32) null)
     (ChangeTrustResult (bv CHANGE_TRUST_MALFORMED 32) null)))
   (ManageOfferSuccessResult-rule
    (ManageOfferSuccessResult
     (vector (ClaimAtom-rule) (ClaimAtom-rule) (ClaimAtom-rule))
     (choose
      (ManageOfferSuccessResult::offer
       (bv MANAGE_OFFER_CREATED 32)
       (OfferEntry-rule))
      (ManageOfferSuccessResult::offer
       (bv MANAGE_OFFER_UPDATED 32)
       (OfferEntry-rule))
      (ManageOfferSuccessResult::offer (bv MANAGE_OFFER_DELETED 32) null))))
   (RevokeSponsorshipResultCode-rule
    (choose
     REVOKE_SPONSORSHIP_SUCCESS
     REVOKE_SPONSORSHIP_DOES_NOT_EXIST
     REVOKE_SPONSORSHIP_NOT_SPONSOR
     REVOKE_SPONSORSHIP_LOW_RESERVE
     REVOKE_SPONSORSHIP_ONLY_TRANSFERABLE
     REVOKE_SPONSORSHIP_MALFORMED))
   (PoolID-rule (Hash-rule))
   (OperationResultCode-rule
    (choose
     opINNER
     opBAD_AUTH
     opNO_ACCOUNT
     opNOT_SUPPORTED
     opTOO_MANY_SUBENTRIES
     opEXCEEDED_WORK_LIMIT
     opTOO_MANY_SPONSORING))
   (PathPaymentStrictSendOp-rule
    (PathPaymentStrictSendOp
     (Asset-rule)
     (int64-rule)
     (MuxedAccount-rule)
     (Asset-rule)
     (int64-rule)
     (vector (Asset-rule) (Asset-rule) (Asset-rule))))
   (TimeBounds-rule (TimeBounds (TimePoint-rule) (TimePoint-rule)))
   (string64-rule
    (vector (?? (bitvector 8)) (?? (bitvector 8)) (?? (bitvector 8))))
   (ManageDataResultCode-rule
    (choose
     MANAGE_DATA_SUCCESS
     MANAGE_DATA_NOT_SUPPORTED_YET
     MANAGE_DATA_NAME_NOT_FOUND
     MANAGE_DATA_LOW_RESERVE
     MANAGE_DATA_INVALID_NAME))
   (DataEntry-rule
    (DataEntry
     (AccountID-rule)
     (string64-rule)
     (DataValue-rule)
     (DataEntry::ext (bv 0 32) null)))
   (TransactionResultCode-rule
    (choose
     txFEE_BUMP_INNER_SUCCESS
     txSUCCESS
     txFAILED
     txTOO_EARLY
     txTOO_LATE
     txMISSING_OPERATION
     txBAD_SEQ
     txBAD_AUTH
     txINSUFFICIENT_BALANCE
     txNO_ACCOUNT
     txINSUFFICIENT_FEE
     txBAD_AUTH_EXTRA
     txINTERNAL_ERROR
     txNOT_SUPPORTED
     txFEE_BUMP_INNER_FAILED
     txBAD_SPONSORSHIP))
   (ManageBuyOfferOp-rule
    (ManageBuyOfferOp
     (Asset-rule)
     (Asset-rule)
     (int64-rule)
     (Price-rule)
     (int64-rule)))
   (PathPaymentStrictSendResultCode-rule
    (choose
     PATH_PAYMENT_STRICT_SEND_SUCCESS
     PATH_PAYMENT_STRICT_SEND_MALFORMED
     PATH_PAYMENT_STRICT_SEND_UNDERFUNDED
     PATH_PAYMENT_STRICT_SEND_SRC_NO_TRUST
     PATH_PAYMENT_STRICT_SEND_SRC_NOT_AUTHORIZED
     PATH_PAYMENT_STRICT_SEND_NO_DESTINATION
     PATH_PAYMENT_STRICT_SEND_NO_TRUST
     PATH_PAYMENT_STRICT_SEND_NOT_AUTHORIZED
     PATH_PAYMENT_STRICT_SEND_LINE_FULL
     PATH_PAYMENT_STRICT_SEND_NO_ISSUER
     PATH_PAYMENT_STRICT_SEND_TOO_FEW_OFFERS
     PATH_PAYMENT_STRICT_SEND_OFFER_CROSS_SELF
     PATH_PAYMENT_STRICT_SEND_UNDER_DESTMIN))
   (DataValue-rule
    (vector (?? (bitvector 8)) (?? (bitvector 8)) (?? (bitvector 8))))
   (SetOptionsResultCode-rule
    (choose
     SET_OPTIONS_SUCCESS
     SET_OPTIONS_LOW_RESERVE
     SET_OPTIONS_TOO_MANY_SIGNERS
     SET_OPTIONS_BAD_FLAGS
     SET_OPTIONS_INVALID_INFLATION
     SET_OPTIONS_CANT_CHANGE
     SET_OPTIONS_UNKNOWN_FLAG
     SET_OPTIONS_THRESHOLD_OUT_OF_RANGE
     SET_OPTIONS_BAD_SIGNER
     SET_OPTIONS_INVALID_HOME_DOMAIN
     SET_OPTIONS_AUTH_REVOCABLE_REQUIRED))
   (PublicKeyType-rule PUBLIC_KEY_TYPE_ED25519)
   (LiquidityPoolWithdrawResult-rule
    (choose
     (LiquidityPoolWithdrawResult (bv LIQUIDITY_POOL_WITHDRAW_SUCCESS 32) null)
     (LiquidityPoolWithdrawResult
      (bv LIQUIDITY_POOL_WITHDRAW_UNDER_MINIMUM 32)
      null)
     (LiquidityPoolWithdrawResult
      (bv LIQUIDITY_POOL_WITHDRAW_LINE_FULL 32)
      null)
     (LiquidityPoolWithdrawResult
      (bv LIQUIDITY_POOL_WITHDRAW_UNDERFUNDED 32)
      null)
     (LiquidityPoolWithdrawResult
      (bv LIQUIDITY_POOL_WITHDRAW_NO_TRUST 32)
      null)
     (LiquidityPoolWithdrawResult
      (bv LIQUIDITY_POOL_WITHDRAW_MALFORMED 32)
      null)))
   (PaymentResultCode-rule
    (choose
     PAYMENT_SUCCESS
     PAYMENT_MALFORMED
     PAYMENT_UNDERFUNDED
     PAYMENT_SRC_NO_TRUST
     PAYMENT_SRC_NOT_AUTHORIZED
     PAYMENT_NO_DESTINATION
     PAYMENT_NO_TRUST
     PAYMENT_NOT_AUTHORIZED
     PAYMENT_LINE_FULL
     PAYMENT_NO_ISSUER))
   (Transaction-rule
    (Transaction
     (MuxedAccount-rule)
     (uint32-rule)
     (SequenceNumber-rule)
     (choose
      (-optional (bv TRUE 32) (TimeBounds-rule))
      (-optional (bv FALSE 32) null))
     (Memo-rule)
     (vector (Operation-rule))
     (Transaction::ext (bv 0 32) null)))
   (Signer-rule (Signer (SignerKey-rule) (uint32-rule)))
   (TrustLineEntry-rule
    (TrustLineEntry
     (AccountID-rule)
     (TrustLineAsset-rule)
     (int64-rule)
     (int64-rule)
     (uint32-rule)
     (choose
      (TrustLineEntry::ext (bv 0 32) null)
      (TrustLineEntry::ext
       (bv 1 32)
       (TrustLineEntry::ext::v1
        (Liabilities-rule)
        (choose
         (TrustLineEntry::ext::v1::ext (bv 0 32) null)
         (TrustLineEntry::ext::v1::ext
          (bv 2 32)
          (TrustLineEntryExtensionV2-rule))))))))
   (BeginSponsoringFutureReservesOp-rule
    (BeginSponsoringFutureReservesOp (AccountID-rule)))
   (string32-rule
    (vector (?? (bitvector 8)) (?? (bitvector 8)) (?? (bitvector 8))))
   (LedgerEntry-rule
    (LedgerEntry
     (uint32-rule)
     (choose
      (LedgerEntry::data (bv ACCOUNT 32) (AccountEntry-rule))
      (LedgerEntry::data (bv TRUSTLINE 32) (TrustLineEntry-rule))
      (LedgerEntry::data (bv OFFER 32) (OfferEntry-rule))
      (LedgerEntry::data (bv DATA 32) (DataEntry-rule))
      (LedgerEntry::data
       (bv CLAIMABLE_BALANCE 32)
       (ClaimableBalanceEntry-rule))
      (LedgerEntry::data (bv LIQUIDITY_POOL 32) (LiquidityPoolEntry-rule)))
     (choose
      (LedgerEntry::ext (bv 0 32) null)
      (LedgerEntry::ext (bv 1 32) (LedgerEntryExtensionV1-rule)))))
   (ClawbackResultCode-rule
    (choose
     CLAWBACK_SUCCESS
     CLAWBACK_MALFORMED
     CLAWBACK_NOT_CLAWBACK_ENABLED
     CLAWBACK_NO_TRUST
     CLAWBACK_UNDERFUNDED))
   (PaymentOp-rule (PaymentOp (MuxedAccount-rule) (Asset-rule) (int64-rule)))
   (ClaimableBalanceEntry-rule
    (ClaimableBalanceEntry
     (ClaimableBalanceID-rule)
     (vector (Claimant-rule) (Claimant-rule) (Claimant-rule))
     (Asset-rule)
     (int64-rule)
     (choose
      (ClaimableBalanceEntry::ext (bv 0 32) null)
      (ClaimableBalanceEntry::ext
       (bv 1 32)
       (ClaimableBalanceEntryExtensionV1-rule)))))
   (InflationResult-rule
    (choose
     (InflationResult
      (bv INFLATION_SUCCESS 32)
      (vector
       (InflationPayout-rule)
       (InflationPayout-rule)
       (InflationPayout-rule)))
     (InflationResult (bv INFLATION_NOT_TIME 32) null)))
   (CreateAccountResult-rule
    (choose
     (CreateAccountResult (bv CREATE_ACCOUNT_SUCCESS 32) null)
     (CreateAccountResult (bv CREATE_ACCOUNT_ALREADY_EXIST 32) null)
     (CreateAccountResult (bv CREATE_ACCOUNT_LOW_RESERVE 32) null)
     (CreateAccountResult (bv CREATE_ACCOUNT_UNDERFUNDED 32) null)
     (CreateAccountResult (bv CREATE_ACCOUNT_MALFORMED 32) null)))
   (ClaimantType-rule CLAIMANT_TYPE_V0)
   (UpgradeType-rule
    (vector (?? (bitvector 8)) (?? (bitvector 8)) (?? (bitvector 8))))
   (Signature-rule
    (vector (?? (bitvector 8)) (?? (bitvector 8)) (?? (bitvector 8))))
   (SetTrustLineFlagsResultCode-rule
    (choose
     SET_TRUST_LINE_FLAGS_SUCCESS
     SET_TRUST_LINE_FLAGS_MALFORMED
     SET_TRUST_LINE_FLAGS_NO_TRUST_LINE
     SET_TRUST_LINE_FLAGS_CANT_REVOKE
     SET_TRUST_LINE_FLAGS_INVALID_STATE
     SET_TRUST_LINE_FLAGS_LOW_RESERVE))
   (BeginSponsoringFutureReservesResult-rule
    (choose
     (BeginSponsoringFutureReservesResult
      (bv BEGIN_SPONSORING_FUTURE_RESERVES_SUCCESS 32)
      null)
     (BeginSponsoringFutureReservesResult
      (bv BEGIN_SPONSORING_FUTURE_RESERVES_RECURSIVE 32)
      null)
     (BeginSponsoringFutureReservesResult
      (bv BEGIN_SPONSORING_FUTURE_RESERVES_ALREADY_SPONSORED 32)
      null)
     (BeginSponsoringFutureReservesResult
      (bv BEGIN_SPONSORING_FUTURE_RESERVES_MALFORMED 32)
      null)))
   (ClaimClaimableBalanceOp-rule
    (ClaimClaimableBalanceOp (ClaimableBalanceID-rule)))
   (LiquidityPoolDepositResultCode-rule
    (choose
     LIQUIDITY_POOL_DEPOSIT_SUCCESS
     LIQUIDITY_POOL_DEPOSIT_MALFORMED
     LIQUIDITY_POOL_DEPOSIT_NO_TRUST
     LIQUIDITY_POOL_DEPOSIT_NOT_AUTHORIZED
     LIQUIDITY_POOL_DEPOSIT_UNDERFUNDED
     LIQUIDITY_POOL_DEPOSIT_LINE_FULL
     LIQUIDITY_POOL_DEPOSIT_BAD_PRICE
     LIQUIDITY_POOL_DEPOSIT_POOL_FULL))
   (SignerKeyType-rule
    (choose
     SIGNER_KEY_TYPE_ED25519
     SIGNER_KEY_TYPE_PRE_AUTH_TX
     SIGNER_KEY_TYPE_HASH_X))
   (EndSponsoringFutureReservesResultCode-rule
    (choose
     END_SPONSORING_FUTURE_RESERVES_SUCCESS
     END_SPONSORING_FUTURE_RESERVES_NOT_SPONSORED))
   (AssetType-rule
    (choose
     ASSET_TYPE_NATIVE
     ASSET_TYPE_CREDIT_ALPHANUM4
     ASSET_TYPE_CREDIT_ALPHANUM12
     ASSET_TYPE_POOL_SHARE))
   (SimplePaymentResult-rule
    (SimplePaymentResult (AccountID-rule) (Asset-rule) (int64-rule)))
   (BumpSequenceResult-rule
    (choose
     (BumpSequenceResult (bv BUMP_SEQUENCE_SUCCESS 32) null)
     (BumpSequenceResult (bv BUMP_SEQUENCE_BAD_SEQ 32) null)))
   (ClaimAtomType-rule
    (choose
     CLAIM_ATOM_TYPE_V0
     CLAIM_ATOM_TYPE_ORDER_BOOK
     CLAIM_ATOM_TYPE_LIQUIDITY_POOL))
   (AllowTrustOp-rule
    (AllowTrustOp (AccountID-rule) (AssetCode-rule) (uint32-rule)))
   (ClaimableBalanceIDType-rule CLAIMABLE_BALANCE_ID_TYPE_V0)
   (ClaimAtom-rule
    (choose
     (ClaimAtom (bv CLAIM_ATOM_TYPE_V0 32) (ClaimOfferAtomV0-rule))
     (ClaimAtom (bv CLAIM_ATOM_TYPE_ORDER_BOOK 32) (ClaimOfferAtom-rule))
     (ClaimAtom
      (bv CLAIM_ATOM_TYPE_LIQUIDITY_POOL 32)
      (ClaimLiquidityAtom-rule))))
   (LedgerKey-rule
    (choose
     (LedgerKey (bv ACCOUNT 32) (LedgerKey::account (AccountID-rule)))
     (LedgerKey
      (bv TRUSTLINE 32)
      (LedgerKey::trustLine (AccountID-rule) (TrustLineAsset-rule)))
     (LedgerKey (bv OFFER 32) (LedgerKey::offer (AccountID-rule) (int64-rule)))
     (LedgerKey
      (bv DATA 32)
      (LedgerKey::data (AccountID-rule) (string64-rule)))
     (LedgerKey
      (bv CLAIMABLE_BALANCE 32)
      (LedgerKey::claimableBalance (ClaimableBalanceID-rule)))
     (LedgerKey
      (bv LIQUIDITY_POOL 32)
      (LedgerKey::liquidityPool (PoolID-rule)))))
   (LiquidityPoolDepositResult-rule
    (choose
     (LiquidityPoolDepositResult (bv LIQUIDITY_POOL_DEPOSIT_SUCCESS 32) null)
     (LiquidityPoolDepositResult (bv LIQUIDITY_POOL_DEPOSIT_POOL_FULL 32) null)
     (LiquidityPoolDepositResult (bv LIQUIDITY_POOL_DEPOSIT_BAD_PRICE 32) null)
     (LiquidityPoolDepositResult (bv LIQUIDITY_POOL_DEPOSIT_LINE_FULL 32) null)
     (LiquidityPoolDepositResult
      (bv LIQUIDITY_POOL_DEPOSIT_UNDERFUNDED 32)
      null)
     (LiquidityPoolDepositResult
      (bv LIQUIDITY_POOL_DEPOSIT_NOT_AUTHORIZED 32)
      null)
     (LiquidityPoolDepositResult (bv LIQUIDITY_POOL_DEPOSIT_NO_TRUST 32) null)
     (LiquidityPoolDepositResult
      (bv LIQUIDITY_POOL_DEPOSIT_MALFORMED 32)
      null)))
   (ManageDataResult-rule
    (choose
     (ManageDataResult (bv MANAGE_DATA_SUCCESS 32) null)
     (ManageDataResult (bv MANAGE_DATA_INVALID_NAME 32) null)
     (ManageDataResult (bv MANAGE_DATA_LOW_RESERVE 32) null)
     (ManageDataResult (bv MANAGE_DATA_NAME_NOT_FOUND 32) null)
     (ManageDataResult (bv MANAGE_DATA_NOT_SUPPORTED_YET 32) null)))
   (BumpSequenceOp-rule (BumpSequenceOp (SequenceNumber-rule)))
   (Thresholds-rule (-byte-array (?? (bitvector 32))))
   (AccountID-rule (PublicKey-rule))
   (ManageBuyOfferResult-rule
    (choose
     (ManageBuyOfferResult
      (bv MANAGE_BUY_OFFER_SUCCESS 32)
      (ManageOfferSuccessResult-rule))
     (ManageBuyOfferResult (bv MANAGE_BUY_OFFER_LOW_RESERVE 32) null)
     (ManageBuyOfferResult (bv MANAGE_BUY_OFFER_NOT_FOUND 32) null)
     (ManageBuyOfferResult (bv MANAGE_BUY_OFFER_BUY_NO_ISSUER 32) null)
     (ManageBuyOfferResult (bv MANAGE_BUY_OFFER_SELL_NO_ISSUER 32) null)
     (ManageBuyOfferResult (bv MANAGE_BUY_OFFER_CROSS_SELF 32) null)
     (ManageBuyOfferResult (bv MANAGE_BUY_OFFER_UNDERFUNDED 32) null)
     (ManageBuyOfferResult (bv MANAGE_BUY_OFFER_LINE_FULL 32) null)
     (ManageBuyOfferResult (bv MANAGE_BUY_OFFER_BUY_NOT_AUTHORIZED 32) null)
     (ManageBuyOfferResult (bv MANAGE_BUY_OFFER_SELL_NOT_AUTHORIZED 32) null)
     (ManageBuyOfferResult (bv MANAGE_BUY_OFFER_BUY_NO_TRUST 32) null)
     (ManageBuyOfferResult (bv MANAGE_BUY_OFFER_SELL_NO_TRUST 32) null)
     (ManageBuyOfferResult (bv MANAGE_BUY_OFFER_MALFORMED 32) null)))
   (InflationResultCode-rule (choose INFLATION_SUCCESS INFLATION_NOT_TIME))
   (SignatureHint-rule (-byte-array (?? (bitvector 32))))
   (CreateClaimableBalanceResultCode-rule
    (choose
     CREATE_CLAIMABLE_BALANCE_SUCCESS
     CREATE_CLAIMABLE_BALANCE_MALFORMED
     CREATE_CLAIMABLE_BALANCE_LOW_RESERVE
     CREATE_CLAIMABLE_BALANCE_NO_TRUST
     CREATE_CLAIMABLE_BALANCE_NOT_AUTHORIZED
     CREATE_CLAIMABLE_BALANCE_UNDERFUNDED))
   (int64-rule (?? (bitvector 64)))
   (Operation-rule
    (Operation
     (choose
      (-optional (bv TRUE 32) (MuxedAccount-rule))
      (-optional (bv FALSE 32) null))
     (choose
      (Operation::body (bv CREATE_ACCOUNT 32) (CreateAccountOp-rule))
      (Operation::body (bv PAYMENT 32) (PaymentOp-rule))
      (Operation::body
       (bv PATH_PAYMENT_STRICT_RECEIVE 32)
       (PathPaymentStrictReceiveOp-rule))
      (Operation::body (bv MANAGE_SELL_OFFER 32) (ManageSellOfferOp-rule))
      (Operation::body
       (bv CREATE_PASSIVE_SELL_OFFER 32)
       (CreatePassiveSellOfferOp-rule))
      (Operation::body (bv SET_OPTIONS 32) (SetOptionsOp-rule))
      (Operation::body (bv CHANGE_TRUST 32) (ChangeTrustOp-rule))
      (Operation::body (bv ALLOW_TRUST 32) (AllowTrustOp-rule))
      (Operation::body (bv ACCOUNT_MERGE 32) (MuxedAccount-rule))
      (Operation::body (bv INFLATION 32) null)
      (Operation::body (bv MANAGE_DATA 32) (ManageDataOp-rule))
      (Operation::body (bv BUMP_SEQUENCE 32) (BumpSequenceOp-rule))
      (Operation::body (bv MANAGE_BUY_OFFER 32) (ManageBuyOfferOp-rule))
      (Operation::body
       (bv PATH_PAYMENT_STRICT_SEND 32)
       (PathPaymentStrictSendOp-rule))
      (Operation::body
       (bv CREATE_CLAIMABLE_BALANCE 32)
       (CreateClaimableBalanceOp-rule))
      (Operation::body
       (bv CLAIM_CLAIMABLE_BALANCE 32)
       (ClaimClaimableBalanceOp-rule))
      (Operation::body
       (bv BEGIN_SPONSORING_FUTURE_RESERVES 32)
       (BeginSponsoringFutureReservesOp-rule))
      (Operation::body (bv END_SPONSORING_FUTURE_RESERVES 32) null)
      (Operation::body (bv REVOKE_SPONSORSHIP 32) (RevokeSponsorshipOp-rule))
      (Operation::body (bv CLAWBACK 32) (ClawbackOp-rule))
      (Operation::body
       (bv CLAWBACK_CLAIMABLE_BALANCE 32)
       (ClawbackClaimableBalanceOp-rule))
      (Operation::body (bv SET_TRUST_LINE_FLAGS 32) (SetTrustLineFlagsOp-rule))
      (Operation::body
       (bv LIQUIDITY_POOL_DEPOSIT 32)
       (LiquidityPoolDepositOp-rule))
      (Operation::body
       (bv LIQUIDITY_POOL_WITHDRAW 32)
       (LiquidityPoolWithdrawOp-rule)))))
   (OperationType-rule
    (choose
     CREATE_ACCOUNT
     PAYMENT
     PATH_PAYMENT_STRICT_RECEIVE
     MANAGE_SELL_OFFER
     CREATE_PASSIVE_SELL_OFFER
     SET_OPTIONS
     CHANGE_TRUST
     ALLOW_TRUST
     ACCOUNT_MERGE
     INFLATION
     MANAGE_DATA
     BUMP_SEQUENCE
     MANAGE_BUY_OFFER
     PATH_PAYMENT_STRICT_SEND
     CREATE_CLAIMABLE_BALANCE
     CLAIM_CLAIMABLE_BALANCE
     BEGIN_SPONSORING_FUTURE_RESERVES
     END_SPONSORING_FUTURE_RESERVES
     REVOKE_SPONSORSHIP
     CLAWBACK
     CLAWBACK_CLAIMABLE_BALANCE
     SET_TRUST_LINE_FLAGS
     LIQUIDITY_POOL_DEPOSIT
     LIQUIDITY_POOL_WITHDRAW))
   (MemoType-rule (choose MEMO_NONE MEMO_TEXT MEMO_ID MEMO_HASH MEMO_RETURN))
   (SequenceNumber-rule (int64-rule))
   (PathPaymentStrictReceiveResultCode-rule
    (choose
     PATH_PAYMENT_STRICT_RECEIVE_SUCCESS
     PATH_PAYMENT_STRICT_RECEIVE_MALFORMED
     PATH_PAYMENT_STRICT_RECEIVE_UNDERFUNDED
     PATH_PAYMENT_STRICT_RECEIVE_SRC_NO_TRUST
     PATH_PAYMENT_STRICT_RECEIVE_SRC_NOT_AUTHORIZED
     PATH_PAYMENT_STRICT_RECEIVE_NO_DESTINATION
     PATH_PAYMENT_STRICT_RECEIVE_NO_TRUST
     PATH_PAYMENT_STRICT_RECEIVE_NOT_AUTHORIZED
     PATH_PAYMENT_STRICT_RECEIVE_LINE_FULL
     PATH_PAYMENT_STRICT_RECEIVE_NO_ISSUER
     PATH_PAYMENT_STRICT_RECEIVE_TOO_FEW_OFFERS
     PATH_PAYMENT_STRICT_RECEIVE_OFFER_CROSS_SELF
     PATH_PAYMENT_STRICT_RECEIVE_OVER_SENDMAX))
   (AccountEntryExtensionV2-rule
    (AccountEntryExtensionV2
     (uint32-rule)
     (uint32-rule)
     (vector (SponsorshipDescriptor-rule))
     (AccountEntryExtensionV2::ext (bv 0 32) null)))
   (TransactionResult-rule
    (TransactionResult
     (int64-rule)
     (choose
      (TransactionResult::result
       (bv txFEE_BUMP_INNER_SUCCESS 32)
       (InnerTransactionResultPair-rule))
      (TransactionResult::result
       (bv txFEE_BUMP_INNER_FAILED 32)
       (InnerTransactionResultPair-rule))
      (TransactionResult::result
       (bv txSUCCESS 32)
       (vector
        (OperationResult-rule)
        (OperationResult-rule)
        (OperationResult-rule)))
      (TransactionResult::result
       (bv txFAILED 32)
       (vector
        (OperationResult-rule)
        (OperationResult-rule)
        (OperationResult-rule)))
      (TransactionResult::result (bv txBAD_SPONSORSHIP 32) null)
      (TransactionResult::result (bv txNOT_SUPPORTED 32) null)
      (TransactionResult::result (bv txINTERNAL_ERROR 32) null)
      (TransactionResult::result (bv txBAD_AUTH_EXTRA 32) null)
      (TransactionResult::result (bv txINSUFFICIENT_FEE 32) null)
      (TransactionResult::result (bv txNO_ACCOUNT 32) null)
      (TransactionResult::result (bv txINSUFFICIENT_BALANCE 32) null)
      (TransactionResult::result (bv txBAD_AUTH 32) null)
      (TransactionResult::result (bv txBAD_SEQ 32) null)
      (TransactionResult::result (bv txMISSING_OPERATION 32) null)
      (TransactionResult::result (bv txTOO_LATE 32) null)
      (TransactionResult::result (bv txTOO_EARLY 32) null))
     (TransactionResult::ext (bv 0 32) null)))
   (EnvelopeType-rule
    (choose
     ENVELOPE_TYPE_TX_V0
     ENVELOPE_TYPE_SCP
     ENVELOPE_TYPE_TX
     ENVELOPE_TYPE_AUTH
     ENVELOPE_TYPE_SCPVALUE
     ENVELOPE_TYPE_TX_FEE_BUMP
     ENVELOPE_TYPE_OP_ID
     ENVELOPE_TYPE_POOL_REVOKE_OP_ID))
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
     (RevokeSponsorshipResult (bv REVOKE_SPONSORSHIP_SUCCESS 32) null)
     (RevokeSponsorshipResult (bv REVOKE_SPONSORSHIP_MALFORMED 32) null)
     (RevokeSponsorshipResult
      (bv REVOKE_SPONSORSHIP_ONLY_TRANSFERABLE 32)
      null)
     (RevokeSponsorshipResult (bv REVOKE_SPONSORSHIP_LOW_RESERVE 32) null)
     (RevokeSponsorshipResult (bv REVOKE_SPONSORSHIP_NOT_SPONSOR 32) null)
     (RevokeSponsorshipResult (bv REVOKE_SPONSORSHIP_DOES_NOT_EXIST 32) null)))
   (ClaimPredicateType-rule
    (choose
     CLAIM_PREDICATE_UNCONDITIONAL
     CLAIM_PREDICATE_AND
     CLAIM_PREDICATE_OR
     CLAIM_PREDICATE_NOT
     CLAIM_PREDICATE_BEFORE_ABSOLUTE_TIME
     CLAIM_PREDICATE_BEFORE_RELATIVE_TIME))
   (LiquidityPoolType-rule LIQUIDITY_POOL_CONSTANT_PRODUCT)
   (uint32-rule (?? (bitvector 32)))
   (RevokeSponsorshipType-rule
    (choose REVOKE_SPONSORSHIP_LEDGER_ENTRY REVOKE_SPONSORSHIP_SIGNER))
   (EndSponsoringFutureReservesResult-rule
    (choose
     (EndSponsoringFutureReservesResult
      (bv END_SPONSORING_FUTURE_RESERVES_SUCCESS 32)
      null)
     (EndSponsoringFutureReservesResult
      (bv END_SPONSORING_FUTURE_RESERVES_NOT_SPONSORED 32)
      null)))
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
     (ChangeTrustAsset (bv ASSET_TYPE_NATIVE 32) null)
     (ChangeTrustAsset (bv ASSET_TYPE_CREDIT_ALPHANUM4 32) (AlphaNum4-rule))
     (ChangeTrustAsset (bv ASSET_TYPE_CREDIT_ALPHANUM12 32) (AlphaNum12-rule))
     (ChangeTrustAsset
      (bv ASSET_TYPE_POOL_SHARE 32)
      (LiquidityPoolParameters-rule))))
   (LedgerHeaderExtensionV1-rule
    (LedgerHeaderExtensionV1
     (uint32-rule)
     (LedgerHeaderExtensionV1::ext (bv 0 32) null)))
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
      (LedgerHeader::ext (bv 0 32) null)
      (LedgerHeader::ext (bv 1 32) (LedgerHeaderExtensionV1-rule)))))
   (CryptoKeyType-rule
    (choose
     KEY_TYPE_ED25519
     KEY_TYPE_PRE_AUTH_TX
     KEY_TYPE_HASH_X
     KEY_TYPE_MUXED_ED25519))
   (ManageOfferEffect-rule
    (choose MANAGE_OFFER_CREATED MANAGE_OFFER_UPDATED MANAGE_OFFER_DELETED))
   (TransactionV0Envelope-rule
    (TransactionV0Envelope
     (TransactionV0-rule)
     (vector
      (DecoratedSignature-rule)
      (DecoratedSignature-rule)
      (DecoratedSignature-rule))))
   (InflationPayout-rule (InflationPayout (AccountID-rule) (int64-rule)))
   (PathPaymentStrictReceiveOp-rule
    (PathPaymentStrictReceiveOp
     (Asset-rule)
     (int64-rule)
     (MuxedAccount-rule)
     (Asset-rule)
     (int64-rule)
     (vector (Asset-rule) (Asset-rule) (Asset-rule))))
   (ClawbackResult-rule
    (choose
     (ClawbackResult (bv CLAWBACK_SUCCESS 32) null)
     (ClawbackResult (bv CLAWBACK_UNDERFUNDED 32) null)
     (ClawbackResult (bv CLAWBACK_NO_TRUST 32) null)
     (ClawbackResult (bv CLAWBACK_NOT_CLAWBACK_ENABLED 32) null)
     (ClawbackResult (bv CLAWBACK_MALFORMED 32) null)))
   (Ledger-rule
    (Ledger
     (LedgerHeader-rule)
     (vector (LedgerEntry-rule) (LedgerEntry-rule) (LedgerEntry-rule))))
   (ClawbackOp-rule (ClawbackOp (Asset-rule) (MuxedAccount-rule) (int64-rule)))
   (ClaimPredicate-rule
    (choose
     (ClaimPredicate (bv CLAIM_PREDICATE_UNCONDITIONAL 32) null)
     (ClaimPredicate (bv CLAIM_PREDICATE_BEFORE_ABSOLUTE_TIME 32) (int64-rule))
     (ClaimPredicate
      (bv CLAIM_PREDICATE_BEFORE_RELATIVE_TIME 32)
      (int64-rule))))
   (LiquidityPoolConstantProductParameters-rule
    (LiquidityPoolConstantProductParameters
     (Asset-rule)
     (Asset-rule)
     (int32-rule)))
   (NodeID-rule (PublicKey-rule))
   (ClawbackClaimableBalanceResultCode-rule
    (choose
     CLAWBACK_CLAIMABLE_BALANCE_SUCCESS
     CLAWBACK_CLAIMABLE_BALANCE_DOES_NOT_EXIST
     CLAWBACK_CLAIMABLE_BALANCE_NOT_ISSUER
     CLAWBACK_CLAIMABLE_BALANCE_NOT_CLAWBACK_ENABLED))
   (LedgerEntryExtensionV1-rule
    (LedgerEntryExtensionV1
     (SponsorshipDescriptor-rule)
     (LedgerEntryExtensionV1::ext (bv 0 32) null)))
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
      (-optional (bv TRUE 32) (DataValue-rule))
      (-optional (bv FALSE 32) null))))
   (ClaimClaimableBalanceResult-rule
    (choose
     (ClaimClaimableBalanceResult (bv CLAIM_CLAIMABLE_BALANCE_SUCCESS 32) null)
     (ClaimClaimableBalanceResult
      (bv CLAIM_CLAIMABLE_BALANCE_NOT_AUTHORIZED 32)
      null)
     (ClaimClaimableBalanceResult
      (bv CLAIM_CLAIMABLE_BALANCE_NO_TRUST 32)
      null)
     (ClaimClaimableBalanceResult
      (bv CLAIM_CLAIMABLE_BALANCE_LINE_FULL 32)
      null)
     (ClaimClaimableBalanceResult
      (bv CLAIM_CLAIMABLE_BALANCE_CANNOT_CLAIM 32)
      null)
     (ClaimClaimableBalanceResult
      (bv CLAIM_CLAIMABLE_BALANCE_DOES_NOT_EXIST 32)
      null)))
   (uint256-rule (-byte-array (?? (bitvector 256))))
   (AllowTrustResultCode-rule
    (choose
     ALLOW_TRUST_SUCCESS
     ALLOW_TRUST_MALFORMED
     ALLOW_TRUST_NO_TRUST_LINE
     ALLOW_TRUST_TRUST_NOT_REQUIRED
     ALLOW_TRUST_CANT_REVOKE
     ALLOW_TRUST_SELF_NOT_ALLOWED
     ALLOW_TRUST_LOW_RESERVE))
   (SetOptionsResult-rule
    (choose
     (SetOptionsResult (bv SET_OPTIONS_SUCCESS 32) null)
     (SetOptionsResult (bv SET_OPTIONS_AUTH_REVOCABLE_REQUIRED 32) null)
     (SetOptionsResult (bv SET_OPTIONS_INVALID_HOME_DOMAIN 32) null)
     (SetOptionsResult (bv SET_OPTIONS_BAD_SIGNER 32) null)
     (SetOptionsResult (bv SET_OPTIONS_THRESHOLD_OUT_OF_RANGE 32) null)
     (SetOptionsResult (bv SET_OPTIONS_UNKNOWN_FLAG 32) null)
     (SetOptionsResult (bv SET_OPTIONS_CANT_CHANGE 32) null)
     (SetOptionsResult (bv SET_OPTIONS_INVALID_INFLATION 32) null)
     (SetOptionsResult (bv SET_OPTIONS_BAD_FLAGS 32) null)
     (SetOptionsResult (bv SET_OPTIONS_TOO_MANY_SIGNERS 32) null)
     (SetOptionsResult (bv SET_OPTIONS_LOW_RESERVE 32) null)))
   (MuxedAccount-rule
    (choose
     (MuxedAccount
      (bv KEY_TYPE_ED25519 32)
      (choose
       (-byte-array
        (bv
         27116568372071399150679884524377785017401495491953668406345645362053937250281
         256))
       (-byte-array
        (bv
         69736583646561049586200909007537786632846103483503068943043955570139607958662
         256))
       (-byte-array
        (bv
         20107422378223680793318253626581655234449074639411281108518901311494939344212
         256))
       (-byte-array
        (bv
         49166209458710071424414736409196130673409488517642576509960436728726704682176
         256))
       (-byte-array
        (bv
         108205676556803834101400802467028767347767640515723398855284276626900440813927
         256))
       (-byte-array
        (bv
         861552171907965830364671092981349518775669485223791125500364470386207689445
         256))))
     (MuxedAccount
      (bv KEY_TYPE_MUXED_ED25519 32)
      (MuxedAccount::med25519
       (uint64-rule)
       (choose
        (-byte-array
         (bv
          27116568372071399150679884524377785017401495491953668406345645362053937250281
          256))
        (-byte-array
         (bv
          69736583646561049586200909007537786632846103483503068943043955570139607958662
          256))
        (-byte-array
         (bv
          20107422378223680793318253626581655234449074639411281108518901311494939344212
          256))
        (-byte-array
         (bv
          49166209458710071424414736409196130673409488517642576509960436728726704682176
          256))
        (-byte-array
         (bv
          108205676556803834101400802467028767347767640515723398855284276626900440813927
          256))
        (-byte-array
         (bv
          861552171907965830364671092981349518775669485223791125500364470386207689445
          256)))))))
   (AlphaNum4-rule (AlphaNum4 (AssetCode4-rule) (AccountID-rule)))
   (BumpSequenceResultCode-rule
    (choose BUMP_SEQUENCE_SUCCESS BUMP_SEQUENCE_BAD_SEQ))
   (SignerKey-rule
    (choose
     (SignerKey
      (bv SIGNER_KEY_TYPE_ED25519 32)
      (choose
       (-byte-array
        (bv
         27116568372071399150679884524377785017401495491953668406345645362053937250281
         256))
       (-byte-array
        (bv
         69736583646561049586200909007537786632846103483503068943043955570139607958662
         256))
       (-byte-array
        (bv
         20107422378223680793318253626581655234449074639411281108518901311494939344212
         256))
       (-byte-array
        (bv
         49166209458710071424414736409196130673409488517642576509960436728726704682176
         256))
       (-byte-array
        (bv
         108205676556803834101400802467028767347767640515723398855284276626900440813927
         256))
       (-byte-array
        (bv
         861552171907965830364671092981349518775669485223791125500364470386207689445
         256))))
     (SignerKey (bv SIGNER_KEY_TYPE_PRE_AUTH_TX 32) (uint256-rule))
     (SignerKey (bv SIGNER_KEY_TYPE_HASH_X 32) (uint256-rule))))
   (ManageSellOfferResult-rule
    (choose
     (ManageSellOfferResult
      (bv MANAGE_SELL_OFFER_SUCCESS 32)
      (ManageOfferSuccessResult-rule))
     (ManageSellOfferResult (bv MANAGE_SELL_OFFER_LOW_RESERVE 32) null)
     (ManageSellOfferResult (bv MANAGE_SELL_OFFER_NOT_FOUND 32) null)
     (ManageSellOfferResult (bv MANAGE_SELL_OFFER_BUY_NO_ISSUER 32) null)
     (ManageSellOfferResult (bv MANAGE_SELL_OFFER_SELL_NO_ISSUER 32) null)
     (ManageSellOfferResult (bv MANAGE_SELL_OFFER_CROSS_SELF 32) null)
     (ManageSellOfferResult (bv MANAGE_SELL_OFFER_UNDERFUNDED 32) null)
     (ManageSellOfferResult (bv MANAGE_SELL_OFFER_LINE_FULL 32) null)
     (ManageSellOfferResult (bv MANAGE_SELL_OFFER_BUY_NOT_AUTHORIZED 32) null)
     (ManageSellOfferResult (bv MANAGE_SELL_OFFER_SELL_NOT_AUTHORIZED 32) null)
     (ManageSellOfferResult (bv MANAGE_SELL_OFFER_BUY_NO_TRUST 32) null)
     (ManageSellOfferResult (bv MANAGE_SELL_OFFER_SELL_NO_TRUST 32) null)
     (ManageSellOfferResult (bv MANAGE_SELL_OFFER_MALFORMED 32) null)))
   (LiquidityPoolParameters-rule
    (LiquidityPoolParameters
     (bv LIQUIDITY_POOL_CONSTANT_PRODUCT 32)
     (LiquidityPoolConstantProductParameters-rule)))
   (PathPaymentStrictSendResult-rule
    (choose
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_SUCCESS 32)
      (PathPaymentStrictSendResult::success
       (vector (ClaimAtom-rule) (ClaimAtom-rule) (ClaimAtom-rule))
       (SimplePaymentResult-rule)))
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_NO_ISSUER 32)
      (Asset-rule))
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_UNDER_DESTMIN 32)
      null)
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_OFFER_CROSS_SELF 32)
      null)
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_TOO_FEW_OFFERS 32)
      null)
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_LINE_FULL 32)
      null)
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_NOT_AUTHORIZED 32)
      null)
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_NO_TRUST 32)
      null)
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_NO_DESTINATION 32)
      null)
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_SRC_NOT_AUTHORIZED 32)
      null)
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_SRC_NO_TRUST 32)
      null)
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_UNDERFUNDED 32)
      null)
     (PathPaymentStrictSendResult
      (bv PATH_PAYMENT_STRICT_SEND_MALFORMED 32)
      null)))
   (TimePoint-rule (uint64-rule))
   (ManageSellOfferResultCode-rule
    (choose
     MANAGE_SELL_OFFER_SUCCESS
     MANAGE_SELL_OFFER_MALFORMED
     MANAGE_SELL_OFFER_SELL_NO_TRUST
     MANAGE_SELL_OFFER_BUY_NO_TRUST
     MANAGE_SELL_OFFER_SELL_NOT_AUTHORIZED
     MANAGE_SELL_OFFER_BUY_NOT_AUTHORIZED
     MANAGE_SELL_OFFER_LINE_FULL
     MANAGE_SELL_OFFER_UNDERFUNDED
     MANAGE_SELL_OFFER_CROSS_SELF
     MANAGE_SELL_OFFER_SELL_NO_ISSUER
     MANAGE_SELL_OFFER_BUY_NO_ISSUER
     MANAGE_SELL_OFFER_NOT_FOUND
     MANAGE_SELL_OFFER_LOW_RESERVE))
   (Price-rule (Price (int32-rule) (int32-rule)))
   (AccountMergeResultCode-rule
    (choose
     ACCOUNT_MERGE_SUCCESS
     ACCOUNT_MERGE_MALFORMED
     ACCOUNT_MERGE_NO_ACCOUNT
     ACCOUNT_MERGE_IMMUTABLE_SET
     ACCOUNT_MERGE_HAS_SUB_ENTRIES
     ACCOUNT_MERGE_SEQNUM_TOO_FAR
     ACCOUNT_MERGE_DEST_FULL
     ACCOUNT_MERGE_IS_SPONSOR))
   (Hash-rule (-byte-array (?? (bitvector 256))))
   (CreateClaimableBalanceResult-rule
    (choose
     (CreateClaimableBalanceResult
      (bv CREATE_CLAIMABLE_BALANCE_SUCCESS 32)
      (ClaimableBalanceID-rule))
     (CreateClaimableBalanceResult
      (bv CREATE_CLAIMABLE_BALANCE_UNDERFUNDED 32)
      null)
     (CreateClaimableBalanceResult
      (bv CREATE_CLAIMABLE_BALANCE_NOT_AUTHORIZED 32)
      null)
     (CreateClaimableBalanceResult
      (bv CREATE_CLAIMABLE_BALANCE_NO_TRUST 32)
      null)
     (CreateClaimableBalanceResult
      (bv CREATE_CLAIMABLE_BALANCE_LOW_RESERVE 32)
      null)
     (CreateClaimableBalanceResult
      (bv CREATE_CLAIMABLE_BALANCE_MALFORMED 32)
      null)))
   (StellarValueType-rule (choose STELLAR_VALUE_BASIC STELLAR_VALUE_SIGNED))
   (ClaimLiquidityAtom-rule
    (ClaimLiquidityAtom
     (PoolID-rule)
     (Asset-rule)
     (int64-rule)
     (Asset-rule)
     (int64-rule)))
   (AccountMergeResult-rule
    (choose
     (AccountMergeResult (bv ACCOUNT_MERGE_SUCCESS 32) (int64-rule))
     (AccountMergeResult (bv ACCOUNT_MERGE_IS_SPONSOR 32) null)
     (AccountMergeResult (bv ACCOUNT_MERGE_DEST_FULL 32) null)
     (AccountMergeResult (bv ACCOUNT_MERGE_SEQNUM_TOO_FAR 32) null)
     (AccountMergeResult (bv ACCOUNT_MERGE_HAS_SUB_ENTRIES 32) null)
     (AccountMergeResult (bv ACCOUNT_MERGE_IMMUTABLE_SET 32) null)
     (AccountMergeResult (bv ACCOUNT_MERGE_NO_ACCOUNT 32) null)
     (AccountMergeResult (bv ACCOUNT_MERGE_MALFORMED 32) null)))
   (OfferEntry-rule
    (OfferEntry
     (AccountID-rule)
     (int64-rule)
     (Asset-rule)
     (Asset-rule)
     (int64-rule)
     (Price-rule)
     (uint32-rule)
     (OfferEntry::ext (bv 0 32) null)))
   (SetOptionsOp-rule
    (SetOptionsOp
     (choose
      (-optional (bv TRUE 32) (AccountID-rule))
      (-optional (bv FALSE 32) null))
     (choose
      (-optional (bv TRUE 32) (uint32-rule))
      (-optional (bv FALSE 32) null))
     (choose
      (-optional (bv TRUE 32) (uint32-rule))
      (-optional (bv FALSE 32) null))
     (choose
      (-optional (bv TRUE 32) (uint32-rule))
      (-optional (bv FALSE 32) null))
     (choose
      (-optional (bv TRUE 32) (uint32-rule))
      (-optional (bv FALSE 32) null))
     (choose
      (-optional (bv TRUE 32) (uint32-rule))
      (-optional (bv FALSE 32) null))
     (choose
      (-optional (bv TRUE 32) (uint32-rule))
      (-optional (bv FALSE 32) null))
     (choose
      (-optional (bv TRUE 32) (string32-rule))
      (-optional (bv FALSE 32) null))
     (choose
      (-optional (bv TRUE 32) (Signer-rule))
      (-optional (bv FALSE 32) null))))
   (AssetCode4-rule (-byte-array (?? (bitvector 32))))
   (FeeBumpTransactionEnvelope-rule
    (FeeBumpTransactionEnvelope
     (FeeBumpTransaction-rule)
     (vector
      (DecoratedSignature-rule)
      (DecoratedSignature-rule)
      (DecoratedSignature-rule))))
   (InnerTransactionResult-rule
    (InnerTransactionResult
     (int64-rule)
     (choose
      (InnerTransactionResult::result
       (bv txSUCCESS 32)
       (vector
        (OperationResult-rule)
        (OperationResult-rule)
        (OperationResult-rule)))
      (InnerTransactionResult::result
       (bv txFAILED 32)
       (vector
        (OperationResult-rule)
        (OperationResult-rule)
        (OperationResult-rule)))
      (InnerTransactionResult::result (bv txTOO_EARLY 32) null)
      (InnerTransactionResult::result (bv txTOO_LATE 32) null)
      (InnerTransactionResult::result (bv txMISSING_OPERATION 32) null)
      (InnerTransactionResult::result (bv txBAD_SEQ 32) null)
      (InnerTransactionResult::result (bv txBAD_AUTH 32) null)
      (InnerTransactionResult::result (bv txINSUFFICIENT_BALANCE 32) null)
      (InnerTransactionResult::result (bv txNO_ACCOUNT 32) null)
      (InnerTransactionResult::result (bv txINSUFFICIENT_FEE 32) null)
      (InnerTransactionResult::result (bv txBAD_AUTH_EXTRA 32) null)
      (InnerTransactionResult::result (bv txINTERNAL_ERROR 32) null)
      (InnerTransactionResult::result (bv txNOT_SUPPORTED 32) null)
      (InnerTransactionResult::result (bv txBAD_SPONSORSHIP 32) null))
     (InnerTransactionResult::ext (bv 0 32) null)))
   (bool-rule (choose TRUE FALSE))
   (PublicKey-rule
    (PublicKey
     (bv PUBLIC_KEY_TYPE_ED25519 32)
     (choose
      (-byte-array
       (bv
        27116568372071399150679884524377785017401495491953668406345645362053937250281
        256))
      (-byte-array
       (bv
        69736583646561049586200909007537786632846103483503068943043955570139607958662
        256))
      (-byte-array
       (bv
        20107422378223680793318253626581655234449074639411281108518901311494939344212
        256))
      (-byte-array
       (bv
        49166209458710071424414736409196130673409488517642576509960436728726704682176
        256))
      (-byte-array
       (bv
        108205676556803834101400802467028767347767640515723398855284276626900440813927
        256))
      (-byte-array
       (bv
        861552171907965830364671092981349518775669485223791125500364470386207689445
        256)))))
   (Asset-rule
    (choose
     (Asset (bv ASSET_TYPE_NATIVE 32) null)
     (Asset (bv ASSET_TYPE_CREDIT_ALPHANUM4 32) (AlphaNum4-rule))
     (Asset (bv ASSET_TYPE_CREDIT_ALPHANUM12 32) (AlphaNum12-rule))))
   (FeeBumpTransaction-rule
    (FeeBumpTransaction
     (MuxedAccount-rule)
     (int64-rule)
     (FeeBumpTransaction::innerTx
      (bv ENVELOPE_TYPE_TX 32)
      (TransactionV1Envelope-rule))
     (FeeBumpTransaction::ext (bv 0 32) null)))
   (BeginSponsoringFutureReservesResultCode-rule
    (choose
     BEGIN_SPONSORING_FUTURE_RESERVES_SUCCESS
     BEGIN_SPONSORING_FUTURE_RESERVES_MALFORMED
     BEGIN_SPONSORING_FUTURE_RESERVES_ALREADY_SPONSORED
     BEGIN_SPONSORING_FUTURE_RESERVES_RECURSIVE))
   (PaymentResult-rule
    (choose
     (PaymentResult (bv PAYMENT_SUCCESS 32) null)
     (PaymentResult (bv PAYMENT_NO_ISSUER 32) null)
     (PaymentResult (bv PAYMENT_LINE_FULL 32) null)
     (PaymentResult (bv PAYMENT_NOT_AUTHORIZED 32) null)
     (PaymentResult (bv PAYMENT_NO_TRUST 32) null)
     (PaymentResult (bv PAYMENT_NO_DESTINATION 32) null)
     (PaymentResult (bv PAYMENT_SRC_NOT_AUTHORIZED 32) null)
     (PaymentResult (bv PAYMENT_SRC_NO_TRUST 32) null)
     (PaymentResult (bv PAYMENT_UNDERFUNDED 32) null)
     (PaymentResult (bv PAYMENT_MALFORMED 32) null)))
   (uint64-rule (?? (bitvector 64)))
   (CreateAccountOp-rule (CreateAccountOp (AccountID-rule) (int64-rule)))
   (TrustLineAsset-rule
    (choose
     (TrustLineAsset (bv ASSET_TYPE_NATIVE 32) null)
     (TrustLineAsset (bv ASSET_TYPE_CREDIT_ALPHANUM4 32) (AlphaNum4-rule))
     (TrustLineAsset (bv ASSET_TYPE_CREDIT_ALPHANUM12 32) (AlphaNum12-rule))
     (TrustLineAsset (bv ASSET_TYPE_POOL_SHARE 32) (PoolID-rule))))
   (ChangeTrustOp-rule (ChangeTrustOp (ChangeTrustAsset-rule) (int64-rule)))
   (PathPaymentStrictReceiveResult-rule
    (choose
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_SUCCESS 32)
      (PathPaymentStrictReceiveResult::success
       (vector (ClaimAtom-rule) (ClaimAtom-rule) (ClaimAtom-rule))
       (SimplePaymentResult-rule)))
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_NO_ISSUER 32)
      (Asset-rule))
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_OVER_SENDMAX 32)
      null)
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_OFFER_CROSS_SELF 32)
      null)
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_TOO_FEW_OFFERS 32)
      null)
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_LINE_FULL 32)
      null)
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_NOT_AUTHORIZED 32)
      null)
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_NO_TRUST 32)
      null)
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_NO_DESTINATION 32)
      null)
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_SRC_NOT_AUTHORIZED 32)
      null)
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_SRC_NO_TRUST 32)
      null)
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_UNDERFUNDED 32)
      null)
     (PathPaymentStrictReceiveResult
      (bv PATH_PAYMENT_STRICT_RECEIVE_MALFORMED 32)
      null)))
   (OperationResult-rule
    (choose
     (OperationResult
      (bv opINNER 32)
      (choose
       (OperationResult::tr (bv CREATE_ACCOUNT 32) (CreateAccountResult-rule))
       (OperationResult::tr (bv PAYMENT 32) (PaymentResult-rule))
       (OperationResult::tr
        (bv PATH_PAYMENT_STRICT_RECEIVE 32)
        (PathPaymentStrictReceiveResult-rule))
       (OperationResult::tr
        (bv MANAGE_SELL_OFFER 32)
        (ManageSellOfferResult-rule))
       (OperationResult::tr
        (bv CREATE_PASSIVE_SELL_OFFER 32)
        (ManageSellOfferResult-rule))
       (OperationResult::tr (bv SET_OPTIONS 32) (SetOptionsResult-rule))
       (OperationResult::tr (bv CHANGE_TRUST 32) (ChangeTrustResult-rule))
       (OperationResult::tr (bv ALLOW_TRUST 32) (AllowTrustResult-rule))
       (OperationResult::tr (bv ACCOUNT_MERGE 32) (AccountMergeResult-rule))
       (OperationResult::tr (bv INFLATION 32) (InflationResult-rule))
       (OperationResult::tr (bv MANAGE_DATA 32) (ManageDataResult-rule))
       (OperationResult::tr (bv BUMP_SEQUENCE 32) (BumpSequenceResult-rule))
       (OperationResult::tr
        (bv MANAGE_BUY_OFFER 32)
        (ManageBuyOfferResult-rule))
       (OperationResult::tr
        (bv PATH_PAYMENT_STRICT_SEND 32)
        (PathPaymentStrictSendResult-rule))
       (OperationResult::tr
        (bv CREATE_CLAIMABLE_BALANCE 32)
        (CreateClaimableBalanceResult-rule))
       (OperationResult::tr
        (bv CLAIM_CLAIMABLE_BALANCE 32)
        (ClaimClaimableBalanceResult-rule))
       (OperationResult::tr
        (bv BEGIN_SPONSORING_FUTURE_RESERVES 32)
        (BeginSponsoringFutureReservesResult-rule))
       (OperationResult::tr
        (bv END_SPONSORING_FUTURE_RESERVES 32)
        (EndSponsoringFutureReservesResult-rule))
       (OperationResult::tr
        (bv REVOKE_SPONSORSHIP 32)
        (RevokeSponsorshipResult-rule))
       (OperationResult::tr (bv CLAWBACK 32) (ClawbackResult-rule))
       (OperationResult::tr
        (bv CLAWBACK_CLAIMABLE_BALANCE 32)
        (ClawbackClaimableBalanceResult-rule))
       (OperationResult::tr
        (bv SET_TRUST_LINE_FLAGS 32)
        (SetTrustLineFlagsResult-rule))
       (OperationResult::tr
        (bv LIQUIDITY_POOL_DEPOSIT 32)
        (LiquidityPoolDepositResult-rule))
       (OperationResult::tr
        (bv LIQUIDITY_POOL_WITHDRAW 32)
        (LiquidityPoolWithdrawResult-rule))))
     (OperationResult (bv opTOO_MANY_SPONSORING 32) null)
     (OperationResult (bv opEXCEEDED_WORK_LIMIT 32) null)
     (OperationResult (bv opTOO_MANY_SUBENTRIES 32) null)
     (OperationResult (bv opNOT_SUPPORTED 32) null)
     (OperationResult (bv opNO_ACCOUNT 32) null)
     (OperationResult (bv opBAD_AUTH 32) null)))
   (TransactionEnvelope-rule
    (choose
     (TransactionEnvelope
      (bv ENVELOPE_TYPE_TX_V0 32)
      (TransactionV0Envelope-rule))
     (TransactionEnvelope
      (bv ENVELOPE_TYPE_TX 32)
      (TransactionV1Envelope-rule))
     (TransactionEnvelope
      (bv ENVELOPE_TYPE_TX_FEE_BUMP 32)
      (FeeBumpTransactionEnvelope-rule))))
   (AccountEntryExtensionV1-rule
    (AccountEntryExtensionV1
     (Liabilities-rule)
     (choose
      (AccountEntryExtensionV1::ext (bv 0 32) null)
      (AccountEntryExtensionV1::ext
       (bv 2 32)
       (AccountEntryExtensionV2-rule)))))
   (ManageSellOfferOp-rule
    (ManageSellOfferOp
     (Asset-rule)
     (Asset-rule)
     (int64-rule)
     (Price-rule)
     (int64-rule)))
   (DecoratedSignature-rule
    (DecoratedSignature (SignatureHint-rule) (Signature-rule)))
   (Liabilities-rule (Liabilities (int64-rule) (int64-rule)))
   (TransactionV0-rule
    (TransactionV0
     (uint256-rule)
     (uint32-rule)
     (SequenceNumber-rule)
     (choose
      (-optional (bv TRUE 32) (TimeBounds-rule))
      (-optional (bv FALSE 32) null))
     (Memo-rule)
     (vector (Operation-rule) (Operation-rule) (Operation-rule))
     (TransactionV0::ext (bv 0 32) null)))
   (TrustLineEntryExtensionV2-rule
    (TrustLineEntryExtensionV2
     (int32-rule)
     (TrustLineEntryExtensionV2::ext (bv 0 32) null)))
   (ClaimableBalanceID-rule
    (ClaimableBalanceID (bv CLAIMABLE_BALANCE_ID_TYPE_V0 32) (Hash-rule)))
   (ClaimClaimableBalanceResultCode-rule
    (choose
     CLAIM_CLAIMABLE_BALANCE_SUCCESS
     CLAIM_CLAIMABLE_BALANCE_DOES_NOT_EXIST
     CLAIM_CLAIMABLE_BALANCE_CANNOT_CLAIM
     CLAIM_CLAIMABLE_BALANCE_LINE_FULL
     CLAIM_CLAIMABLE_BALANCE_NO_TRUST
     CLAIM_CLAIMABLE_BALANCE_NOT_AUTHORIZED))))
