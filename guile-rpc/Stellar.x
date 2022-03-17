typedef opaque Hash[32];
typedef opaque uint256[32];

typedef unsigned int uint32;
typedef int int32;

typedef unsigned hyper uint64;
typedef hyper int64;

enum CryptoKeyType
{
    KEY_TYPE_ED25519 = 0,
    KEY_TYPE_PRE_AUTH_TX = 1,
    KEY_TYPE_HASH_X = 2,
    KEY_TYPE_MUXED_ED25519 = 0x100
};

enum PublicKeyType
{
    PUBLIC_KEY_TYPE_ED25519 = 0
};

enum SignerKeyType
{
    SIGNER_KEY_TYPE_ED25519 = 0,
    SIGNER_KEY_TYPE_PRE_AUTH_TX = 1,
    SIGNER_KEY_TYPE_HASH_X = 2
};

union PublicKey switch (PublicKeyType type)
{
case PUBLIC_KEY_TYPE_ED25519:
    uint256 ed25519;
};

union SignerKey switch (SignerKeyType type)
{
case SIGNER_KEY_TYPE_ED25519:
    uint256 ed25519;
case SIGNER_KEY_TYPE_PRE_AUTH_TX:
    /* SHA-256 Hash of TransactionSignaturePayload structure */
    uint256 preAuthTx;
case SIGNER_KEY_TYPE_HASH_X:
    /* Hash of random 256 bit preimage X */
    uint256 hashX;
};

typedef opaque Signature<64>;

typedef opaque SignatureHint[4];

typedef PublicKey NodeID;

struct Curve25519Secret
{
    opaque key[32];
};

struct Curve25519Public
{
    opaque key[32];
};

struct HmacSha256Key
{
    opaque key[32];
};

struct HmacSha256Mac
{
    opaque mac[32];
};
typedef opaque Value<>;

struct SCPBallot
{
    uint32 counter;
    Value value;
};

enum SCPStatementType
{
    SCP_ST_PREPARE = 0,
    SCP_ST_CONFIRM = 1,
    SCP_ST_EXTERNALIZE = 2,
    SCP_ST_NOMINATE = 3
};

struct SCPNomination
{
    Hash quorumSetHash;
    Value votes<>;
    Value accepted<>;
};

struct SCPStatement
{
    NodeID nodeID;
    uint64 slotIndex;

    union switch (SCPStatementType type)
    {
    case SCP_ST_PREPARE:
        struct
        {
            Hash quorumSetHash;
            SCPBallot ballot;
            SCPBallot* prepared;
            SCPBallot* preparedPrime;
            uint32 nC;
            uint32 nH;
        } prepare;
    case SCP_ST_CONFIRM:
        struct
        {
            SCPBallot ballot;
            uint32 nPrepared;
            uint32 nCommit;
            uint32 nH;
            Hash quorumSetHash;
        } confirm;
    case SCP_ST_EXTERNALIZE:
        struct
        {
            SCPBallot commit;
            uint32 nH;
            Hash commitQuorumSetHash;
        } externalize;
    case SCP_ST_NOMINATE:
        SCPNomination nominate;
    }
    pledges;
};

struct SCPEnvelope
{
    SCPStatement statement;
    Signature signature;
};

struct SCPQuorumSet
{
    uint32 threshold;
    NodeID validators<>;
    SCPQuorumSet innerSets<>;
};
typedef opaque UpgradeType<128>;

enum StellarValueType
{
    STELLAR_VALUE_BASIC = 0,
    STELLAR_VALUE_SIGNED = 1
};

struct LedgerCloseValueSignature
{
    NodeID nodeID;
    Signature signature;
};

/* StellarValue is the value used by SCP to reach consensus on a given ledger
 */
struct StellarValue
{
    Hash txSetHash;
    TimePoint closeTime;

    UpgradeType upgrades<6>;

    union switch (StellarValueType v)
    {
    case STELLAR_VALUE_BASIC:
        void;
    case STELLAR_VALUE_SIGNED:
        LedgerCloseValueSignature lcValueSignature;
    }
    ext;
};

const MASK_LEDGER_HEADER_FLAGS = 0x7;

enum LedgerHeaderFlags
{
    DISABLE_LIQUIDITY_POOL_TRADING_FLAG = 0x1,
    DISABLE_LIQUIDITY_POOL_DEPOSIT_FLAG = 0x2,
    DISABLE_LIQUIDITY_POOL_WITHDRAWAL_FLAG = 0x4
};

struct LedgerHeaderExtensionV1
{
    uint32 flags;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

/* The LedgerHeader is the highest level structure representing the
 * state of a ledger, cryptographically linked to previous ledgers.
 */
struct LedgerHeader
{
    uint32 ledgerVersion;
    Hash previousLedgerHash;
    StellarValue scpValue;
    Hash txSetResultHash;
    Hash bucketListHash;

    uint32 ledgerSeq;

    int64 totalCoins;

    int64 feePool;
    uint32 inflationSeq;

    uint64 idPool;

    uint32 baseFee;
    uint32 baseReserve;

    uint32 maxTxSetSize;

    Hash skipList[4];

    union switch (int v)
    {
    case 0:
        void;
    case 1:
        LedgerHeaderExtensionV1 v1;
    }
    ext;
};

/* Ledger upgrades
note that the `upgrades` field from StellarValue is normalized such that
it only contains one entry per LedgerUpgradeType, and entries are sorted
in ascending order
*/
enum LedgerUpgradeType
{
    LEDGER_UPGRADE_VERSION = 1,
    LEDGER_UPGRADE_BASE_FEE = 2,
    LEDGER_UPGRADE_MAX_TX_SET_SIZE = 3,
    LEDGER_UPGRADE_BASE_RESERVE = 4,
    LEDGER_UPGRADE_FLAGS = 5
};

union LedgerUpgrade switch (LedgerUpgradeType type)
{
case LEDGER_UPGRADE_VERSION:
    uint32 newLedgerVersion;
case LEDGER_UPGRADE_BASE_FEE:
    uint32 newBaseFee;
case LEDGER_UPGRADE_MAX_TX_SET_SIZE:
    uint32 newMaxTxSetSize;
case LEDGER_UPGRADE_BASE_RESERVE:
    uint32 newBaseReserve;
case LEDGER_UPGRADE_FLAGS:
    uint32 newFlags;
};

/* Entries used to define the bucket list */
enum BucketEntryType
{
    METAENTRY =
        -1,
    LIVEENTRY = 0,
    DEADENTRY = 1,
    INITENTRY = 2
};

struct BucketMetadata
{
    uint32 ledgerVersion;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

union BucketEntry switch (BucketEntryType type)
{
case LIVEENTRY:
case INITENTRY:
    LedgerEntry liveEntry;

case DEADENTRY:
    LedgerKey deadEntry;
case METAENTRY:
    BucketMetadata metaEntry;
};

struct TransactionSet
{
    Hash previousLedgerHash;
    TransactionEnvelope txs<>;
};

struct TransactionResultPair
{
    Hash transactionHash;
    TransactionResult result;
};

struct TransactionResultSet
{
    TransactionResultPair results<>;
};


struct TransactionHistoryEntry
{
    uint32 ledgerSeq;
    TransactionSet txSet;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

struct TransactionHistoryResultEntry
{
    uint32 ledgerSeq;
    TransactionResultSet txResultSet;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

struct LedgerHeaderHistoryEntry
{
    Hash hash;
    LedgerHeader header;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};


struct LedgerSCPMessages
{
    uint32 ledgerSeq;
    SCPEnvelope messages<>;
};

struct SCPHistoryEntryV0
{
    SCPQuorumSet quorumSets<>;
    LedgerSCPMessages ledgerMessages;
};

union SCPHistoryEntry switch (int v)
{
case 0:
    SCPHistoryEntryV0 v0;
};



enum LedgerEntryChangeType
{
    LEDGER_ENTRY_CREATED = 0,
    LEDGER_ENTRY_UPDATED = 1,
    LEDGER_ENTRY_REMOVED = 2,
    LEDGER_ENTRY_STATE = 3
};

union LedgerEntryChange switch (LedgerEntryChangeType type)
{
case LEDGER_ENTRY_CREATED:
    LedgerEntry created;
case LEDGER_ENTRY_UPDATED:
    LedgerEntry updated;
case LEDGER_ENTRY_REMOVED:
    LedgerKey removed;
case LEDGER_ENTRY_STATE:
    LedgerEntry state;
};

typedef LedgerEntryChange LedgerEntryChanges<>;

struct OperationMeta
{
    LedgerEntryChanges changes;
};

struct TransactionMetaV1
{
    LedgerEntryChanges txChanges;
    OperationMeta operations<>;
};

struct TransactionMetaV2
{
    LedgerEntryChanges txChangesBefore;
    OperationMeta operations<>;
    LedgerEntryChanges txChangesAfter;
};

union TransactionMeta switch (int v)
{
case 0:
    OperationMeta operations<>;
case 1:
    TransactionMetaV1 v1;
case 2:
    TransactionMetaV2 v2;
};

struct TransactionResultMeta
{
    TransactionResultPair result;
    LedgerEntryChanges feeProcessing;
    TransactionMeta txApplyProcessing;
};

struct UpgradeEntryMeta
{
    LedgerUpgrade upgrade;
    LedgerEntryChanges changes;
};

struct LedgerCloseMetaV0
{
    LedgerHeaderHistoryEntry ledgerHeader;
    TransactionSet txSet;

    TransactionResultMeta txProcessing<>;

    UpgradeEntryMeta upgradesProcessing<>;

    SCPHistoryEntry scpInfo<>;
};

union LedgerCloseMeta switch (int v)
{
case 0:
    LedgerCloseMetaV0 v0;
};
typedef PublicKey AccountID;
typedef opaque Thresholds[4];
typedef string string32<32>;
typedef string string64<64>;
typedef int64 SequenceNumber;
typedef uint64 TimePoint;
typedef opaque DataValue<64>;
typedef Hash PoolID;

typedef opaque AssetCode4[4];

typedef opaque AssetCode12[12];

enum AssetType
{
    ASSET_TYPE_NATIVE = 0,
    ASSET_TYPE_CREDIT_ALPHANUM4 = 1,
    ASSET_TYPE_CREDIT_ALPHANUM12 = 2,
    ASSET_TYPE_POOL_SHARE = 3
};

union AssetCode switch (AssetType type)
{
case ASSET_TYPE_CREDIT_ALPHANUM4:
    AssetCode4 assetCode4;

case ASSET_TYPE_CREDIT_ALPHANUM12:
    AssetCode12 assetCode12;

};

struct AlphaNum4
{
    AssetCode4 assetCode;
    AccountID issuer;
};

struct AlphaNum12
{
    AssetCode12 assetCode;
    AccountID issuer;
};

union Asset switch (AssetType type)
{
case ASSET_TYPE_NATIVE:
    void;

case ASSET_TYPE_CREDIT_ALPHANUM4:
    AlphaNum4 alphaNum4;

case ASSET_TYPE_CREDIT_ALPHANUM12:
    AlphaNum12 alphaNum12;

};

struct Price
{
    int32 n;
    int32 d;
};

struct Liabilities
{
    int64 buying;
    int64 selling;
};

enum ThresholdIndexes
{
    THRESHOLD_MASTER_WEIGHT = 0,
    THRESHOLD_LOW = 1,
    THRESHOLD_MED = 2,
    THRESHOLD_HIGH = 3
};

enum LedgerEntryType
{
    ACCOUNT = 0,
    TRUSTLINE = 1,
    OFFER = 2,
    DATA = 3,
    CLAIMABLE_BALANCE = 4,
    LIQUIDITY_POOL = 5
};

struct Signer
{
    SignerKey key;
    uint32 weight;
};

enum AccountFlags
{

    AUTH_REQUIRED_FLAG = 0x1,
    AUTH_REVOCABLE_FLAG = 0x2,
    AUTH_IMMUTABLE_FLAG = 0x4,
    AUTH_CLAWBACK_ENABLED_FLAG = 0x8
};

const MASK_ACCOUNT_FLAGS = 0x7;
const MASK_ACCOUNT_FLAGS_V17 = 0xF;

const MAX_SIGNERS = 20;

typedef AccountID* SponsorshipDescriptor;

struct AccountEntryExtensionV2
{
    uint32 numSponsored;
    uint32 numSponsoring;
    SponsorshipDescriptor signerSponsoringIDs<MAX_SIGNERS>;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

struct AccountEntryExtensionV1
{
    Liabilities liabilities;

    union switch (int v)
    {
    case 0:
        void;
    case 2:
        AccountEntryExtensionV2 v2;
    }
    ext;
};

/* AccountEntry

    Main entry representing a user in Stellar. All transactions are
    performed using an account.

    Other ledger entries created require an account.

*/
struct AccountEntry
{
    AccountID accountID;
    int64 balance;
    SequenceNumber seqNum;
    uint32 numSubEntries;
    AccountID* inflationDest;
    uint32 flags;

    string32 homeDomain;

    Thresholds thresholds;

    Signer signers<MAX_SIGNERS>;

    union switch (int v)
    {
    case 0:
        void;
    case 1:
        AccountEntryExtensionV1 v1;
    }
    ext;
};

/* TrustLineEntry
    A trust line represents a specific trust relationship with
    a credit/issuer (limit, authorization)
    as well as the balance.
*/

enum TrustLineFlags
{
    AUTHORIZED_FLAG = 1,
    AUTHORIZED_TO_MAINTAIN_LIABILITIES_FLAG = 2,
    TRUSTLINE_CLAWBACK_ENABLED_FLAG = 4
};

const MASK_TRUSTLINE_FLAGS = 1;
const MASK_TRUSTLINE_FLAGS_V13 = 3;
const MASK_TRUSTLINE_FLAGS_V17 = 7;

enum LiquidityPoolType
{
    LIQUIDITY_POOL_CONSTANT_PRODUCT = 0
};

union TrustLineAsset switch (AssetType type)
{
case ASSET_TYPE_NATIVE:
    void;

case ASSET_TYPE_CREDIT_ALPHANUM4:
    AlphaNum4 alphaNum4;

case ASSET_TYPE_CREDIT_ALPHANUM12:
    AlphaNum12 alphaNum12;

case ASSET_TYPE_POOL_SHARE:
    PoolID liquidityPoolID;

};

struct TrustLineEntryExtensionV2
{
    int32 liquidityPoolUseCount;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

struct TrustLineEntry
{
    AccountID accountID;
    TrustLineAsset asset;
    int64 balance;

    int64 limit;
    uint32 flags;

    union switch (int v)
    {
    case 0:
        void;
    case 1:
        struct
        {
            Liabilities liabilities;

            union switch (int v)
            {
            case 0:
                void;
            case 2:
                TrustLineEntryExtensionV2 v2;
            }
            ext;
        } v1;
    }
    ext;
};

enum OfferEntryFlags
{
    PASSIVE_FLAG = 1
};

const MASK_OFFERENTRY_FLAGS = 1;

/* OfferEntry
    An offer is the building block of the offer book, they are automatically
    claimed by payments when the price set by the owner is met.

    For example an Offer is selling 10A where 1A is priced at 1.5B

*/
struct OfferEntry
{
    AccountID sellerID;
    int64 offerID;
    Asset selling;
    Asset buying;
    int64 amount;

    /* price for this offer:
        price of A in terms of B
        price=AmountB/AmountA=priceNumerator/priceDenominator
        price is after fees
    */
    Price price;
    uint32 flags;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

/* DataEntry
    Data can be attached to accounts.
*/
struct DataEntry
{
    AccountID accountID;
    string64 dataName;
    DataValue dataValue;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

enum ClaimPredicateType
{
    CLAIM_PREDICATE_UNCONDITIONAL = 0,
    CLAIM_PREDICATE_AND = 1,
    CLAIM_PREDICATE_OR = 2,
    CLAIM_PREDICATE_NOT = 3,
    CLAIM_PREDICATE_BEFORE_ABSOLUTE_TIME = 4,
    CLAIM_PREDICATE_BEFORE_RELATIVE_TIME = 5
};

union ClaimPredicate switch (ClaimPredicateType type)
{
case CLAIM_PREDICATE_UNCONDITIONAL:
    void;
case CLAIM_PREDICATE_AND:
    ClaimPredicate andPredicates<2>;
case CLAIM_PREDICATE_OR:
    ClaimPredicate orPredicates<2>;
case CLAIM_PREDICATE_NOT:
    ClaimPredicate* notPredicate;
case CLAIM_PREDICATE_BEFORE_ABSOLUTE_TIME:
    int64 absBefore;
case CLAIM_PREDICATE_BEFORE_RELATIVE_TIME:
    int64 relBefore;
};

enum ClaimantType
{
    CLAIMANT_TYPE_V0 = 0
};

union Claimant switch (ClaimantType type)
{
case CLAIMANT_TYPE_V0:
    struct
    {
        AccountID destination;
        ClaimPredicate predicate;
    } v0;
};

enum ClaimableBalanceIDType
{
    CLAIMABLE_BALANCE_ID_TYPE_V0 = 0
};

union ClaimableBalanceID switch (ClaimableBalanceIDType type)
{
case CLAIMABLE_BALANCE_ID_TYPE_V0:
    Hash v0;
};

enum ClaimableBalanceFlags
{
    CLAIMABLE_BALANCE_CLAWBACK_ENABLED_FLAG = 0x1
};

const MASK_CLAIMABLE_BALANCE_FLAGS = 0x1;

struct ClaimableBalanceEntryExtensionV1
{
    union switch (int v)
    {
    case 0:
        void;
    }
    ext;

    uint32 flags;
};

struct ClaimableBalanceEntry
{
    ClaimableBalanceID balanceID;

    Claimant claimants<10>;

    Asset asset;

    int64 amount;

    union switch (int v)
    {
    case 0:
        void;
    case 1:
        ClaimableBalanceEntryExtensionV1 v1;
    }
    ext;
};

struct LiquidityPoolConstantProductParameters
{
    Asset assetA;
    Asset assetB;
    int32 fee;
};

struct LiquidityPoolEntry
{
    PoolID liquidityPoolID;

    union switch (LiquidityPoolType type)
    {
    case LIQUIDITY_POOL_CONSTANT_PRODUCT:
        struct
        {
            LiquidityPoolConstantProductParameters params;

            int64 reserveA;
            int64 reserveB;
            int64 totalPoolShares;
            int64 poolSharesTrustLineCount;
        } constantProduct;
    }
    body;
};

struct LedgerEntryExtensionV1
{
    SponsorshipDescriptor sponsoringID;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

struct LedgerEntry
{
    uint32 lastModifiedLedgerSeq;

    union switch (LedgerEntryType type)
    {
    case ACCOUNT:
        AccountEntry account;
    case TRUSTLINE:
        TrustLineEntry trustLine;
    case OFFER:
        OfferEntry offer;
    case DATA:
        DataEntry data;
    case CLAIMABLE_BALANCE:
        ClaimableBalanceEntry claimableBalance;
    case LIQUIDITY_POOL:
        LiquidityPoolEntry liquidityPool;
    }
    data;

    union switch (int v)
    {
    case 0:
        void;
    case 1:
        LedgerEntryExtensionV1 v1;
    }
    ext;
};

union LedgerKey switch (LedgerEntryType type)
{
case ACCOUNT:
    struct
    {
        AccountID accountID;
    } account;

case TRUSTLINE:
    struct
    {
        AccountID accountID;
        TrustLineAsset asset;
    } trustLine;

case OFFER:
    struct
    {
        AccountID sellerID;
        int64 offerID;
    } offer;

case DATA:
    struct
    {
        AccountID accountID;
        string64 dataName;
    } data;

case CLAIMABLE_BALANCE:
    struct
    {
        ClaimableBalanceID balanceID;
    } claimableBalance;

case LIQUIDITY_POOL:
    struct
    {
        PoolID liquidityPoolID;
    } liquidityPool;
};

enum EnvelopeType
{
    ENVELOPE_TYPE_TX_V0 = 0,
    ENVELOPE_TYPE_SCP = 1,
    ENVELOPE_TYPE_TX = 2,
    ENVELOPE_TYPE_AUTH = 3,
    ENVELOPE_TYPE_SCPVALUE = 4,
    ENVELOPE_TYPE_TX_FEE_BUMP = 5,
    ENVELOPE_TYPE_OP_ID = 6,
    ENVELOPE_TYPE_POOL_REVOKE_OP_ID = 7
};
union LiquidityPoolParameters switch (LiquidityPoolType type)
{
case LIQUIDITY_POOL_CONSTANT_PRODUCT:
    LiquidityPoolConstantProductParameters constantProduct;
};

union MuxedAccount switch (CryptoKeyType type)
{
case KEY_TYPE_ED25519:
    uint256 ed25519;
case KEY_TYPE_MUXED_ED25519:
    struct
    {
        uint64 id;
        uint256 ed25519;
    } med25519;
};

struct DecoratedSignature
{
    SignatureHint hint;
    Signature signature;
};

enum OperationType
{
    CREATE_ACCOUNT = 0,
    PAYMENT = 1,
    PATH_PAYMENT_STRICT_RECEIVE = 2,
    MANAGE_SELL_OFFER = 3,
    CREATE_PASSIVE_SELL_OFFER = 4,
    SET_OPTIONS = 5,
    CHANGE_TRUST = 6,
    ALLOW_TRUST = 7,
    ACCOUNT_MERGE = 8,
    INFLATION = 9,
    MANAGE_DATA = 10,
    BUMP_SEQUENCE = 11,
    MANAGE_BUY_OFFER = 12,
    PATH_PAYMENT_STRICT_SEND = 13,
    CREATE_CLAIMABLE_BALANCE = 14,
    CLAIM_CLAIMABLE_BALANCE = 15,
    BEGIN_SPONSORING_FUTURE_RESERVES = 16,
    END_SPONSORING_FUTURE_RESERVES = 17,
    REVOKE_SPONSORSHIP = 18,
    CLAWBACK = 19,
    CLAWBACK_CLAIMABLE_BALANCE = 20,
    SET_TRUST_LINE_FLAGS = 21,
    LIQUIDITY_POOL_DEPOSIT = 22,
    LIQUIDITY_POOL_WITHDRAW = 23
};

/* CreateAccount
Creates and funds a new account with the specified starting balance.

Threshold: med

Result: CreateAccountResult

*/
struct CreateAccountOp
{
    AccountID destination;
    int64 startingBalance;
};

/* Payment

    Send an amount in specified asset to a destination account.

    Threshold: med

    Result: PaymentResult
*/
struct PaymentOp
{
    MuxedAccount destination;
    Asset asset;
    int64 amount;
};

/* PathPaymentStrictReceive

send an amount to a destination account through a path.
(up to sendMax, sendAsset)
(X0, Path[0]) .. (Xn, Path[n])
(destAmount, destAsset)

Threshold: med

Result: PathPaymentStrictReceiveResult
*/
struct PathPaymentStrictReceiveOp
{
    Asset sendAsset;
    int64 sendMax;

    MuxedAccount destination;
    Asset destAsset;
    int64 destAmount;

    Asset path<5>;
};

/* PathPaymentStrictSend

send an amount to a destination account through a path.
(sendMax, sendAsset)
(X0, Path[0]) .. (Xn, Path[n])
(at least destAmount, destAsset)

Threshold: med

Result: PathPaymentStrictSendResult
*/
struct PathPaymentStrictSendOp
{
    Asset sendAsset;
    int64 sendAmount;

    MuxedAccount destination;
    Asset destAsset;
    int64 destMin;

    Asset path<5>;
};

/* Creates, updates or deletes an offer

Threshold: med

Result: ManageSellOfferResult

*/
struct ManageSellOfferOp
{
    Asset selling;
    Asset buying;
    int64 amount;
    Price price;

    int64 offerID;
};

/* Creates, updates or deletes an offer with amount in terms of buying asset

Threshold: med

Result: ManageBuyOfferResult

*/
struct ManageBuyOfferOp
{
    Asset selling;
    Asset buying;
    int64 buyAmount;
    Price price;

    int64 offerID;
};

/* Creates an offer that doesn't take offers of the same price

Threshold: med

Result: CreatePassiveSellOfferResult

*/
struct CreatePassiveSellOfferOp
{
    Asset selling;
    Asset buying;
    int64 amount;
    Price price;
};

/* Set Account Options

    updates "AccountEntry" fields.
    note: updating thresholds or signers requires high threshold

    Threshold: med or high

    Result: SetOptionsResult
*/
struct SetOptionsOp
{
    AccountID* inflationDest;

    uint32* clearFlags;
    uint32* setFlags;

    uint32* masterWeight;
    uint32* lowThreshold;
    uint32* medThreshold;
    uint32* highThreshold;

    string32* homeDomain;

    Signer* signer;
};

union ChangeTrustAsset switch (AssetType type)
{
case ASSET_TYPE_NATIVE:
    void;

case ASSET_TYPE_CREDIT_ALPHANUM4:
    AlphaNum4 alphaNum4;

case ASSET_TYPE_CREDIT_ALPHANUM12:
    AlphaNum12 alphaNum12;

case ASSET_TYPE_POOL_SHARE:
    LiquidityPoolParameters liquidityPool;

};

/* Creates, updates or deletes a trust line

    Threshold: med

    Result: ChangeTrustResult

*/
struct ChangeTrustOp
{
    ChangeTrustAsset line;

    int64 limit;
};

/* Updates the "authorized" flag of an existing trust line
   this is called by the issuer of the related asset.

   note that authorize can only be set (and not cleared) if
   the issuer account does not have the AUTH_REVOCABLE_FLAG set
   Threshold: low

   Result: AllowTrustResult
*/
struct AllowTrustOp
{
    AccountID trustor;
    AssetCode asset;

    uint32 authorize;
};

/* Inflation
    Runs inflation

Threshold: low

Result: InflationResult

*/

/* AccountMerge
    Transfers native balance to destination account.

    Threshold: high

    Result : AccountMergeResult
*/

/* ManageData
    Adds, Updates, or Deletes a key value pair associated with a particular
        account.

    Threshold: med

    Result: ManageDataResult
*/
struct ManageDataOp
{
    string64 dataName;
    DataValue* dataValue;
};

/* Bump Sequence

    increases the sequence to a given level

    Threshold: low

    Result: BumpSequenceResult
*/
struct BumpSequenceOp
{
    SequenceNumber bumpTo;
};

/* Creates a claimable balance entry

    Threshold: med

    Result: CreateClaimableBalanceResult
*/
struct CreateClaimableBalanceOp
{
    Asset asset;
    int64 amount;
    Claimant claimants<10>;
};

/* Claims a claimable balance entry

    Threshold: low

    Result: ClaimClaimableBalanceResult
*/
struct ClaimClaimableBalanceOp
{
    ClaimableBalanceID balanceID;
};

/* BeginSponsoringFutureReserves

    Establishes the is-sponsoring-future-reserves-for relationship between
    the source account and sponsoredID

    Threshold: med

    Result: BeginSponsoringFutureReservesResult
*/
struct BeginSponsoringFutureReservesOp
{
    AccountID sponsoredID;
};

/* EndSponsoringFutureReserves

    Terminates the current is-sponsoring-future-reserves-for relationship in
    which source account is sponsored

    Threshold: med

    Result: EndSponsoringFutureReservesResult
*/

/* RevokeSponsorship

    If source account is not sponsored or is sponsored by the owner of the
    specified entry or sub-entry, then attempt to revoke the sponsorship.
    If source account is sponsored, then attempt to transfer the sponsorship
    to the sponsor of source account.

    Threshold: med

    Result: RevokeSponsorshipResult
*/
enum RevokeSponsorshipType
{
    REVOKE_SPONSORSHIP_LEDGER_ENTRY = 0,
    REVOKE_SPONSORSHIP_SIGNER = 1
};

union RevokeSponsorshipOp switch (RevokeSponsorshipType type)
{
case REVOKE_SPONSORSHIP_LEDGER_ENTRY:
    LedgerKey ledgerKey;
case REVOKE_SPONSORSHIP_SIGNER:
    struct
    {
        AccountID accountID;
        SignerKey signerKey;
    } signer;
};

/* Claws back an amount of an asset from an account

    Threshold: med

    Result: ClawbackResult
*/
struct ClawbackOp
{
    Asset asset;
    MuxedAccount from;
    int64 amount;
};

/* Claws back a claimable balance

    Threshold: med

    Result: ClawbackClaimableBalanceResult
*/
struct ClawbackClaimableBalanceOp
{
    ClaimableBalanceID balanceID;
};

/* SetTrustLineFlagsOp

   Updates the flags of an existing trust line.
   This is called by the issuer of the related asset.

   Threshold: low

   Result: SetTrustLineFlagsResult
*/
struct SetTrustLineFlagsOp
{
    AccountID trustor;
    Asset asset;

    uint32 clearFlags;
    uint32 setFlags;
};

const LIQUIDITY_POOL_FEE_V18 = 30;

/* Deposit assets into a liquidity pool

    Threshold: med

    Result: LiquidityPoolDepositResult
*/
struct LiquidityPoolDepositOp
{
    PoolID liquidityPoolID;
    int64 maxAmountA;
    int64 maxAmountB;
    Price minPrice;
    Price maxPrice;
};

/* Withdraw assets from a liquidity pool

    Threshold: med

    Result: LiquidityPoolWithdrawResult
*/
struct LiquidityPoolWithdrawOp
{
    PoolID liquidityPoolID;
    int64 amount;
    int64 minAmountA;
    int64 minAmountB;
};

/* An operation is the lowest unit of work that a transaction does */
struct Operation
{
    MuxedAccount* sourceAccount;

    union switch (OperationType type)
    {
    case CREATE_ACCOUNT:
        CreateAccountOp createAccountOp;
    case PAYMENT:
        PaymentOp paymentOp;
    case PATH_PAYMENT_STRICT_RECEIVE:
        PathPaymentStrictReceiveOp pathPaymentStrictReceiveOp;
    case MANAGE_SELL_OFFER:
        ManageSellOfferOp manageSellOfferOp;
    case CREATE_PASSIVE_SELL_OFFER:
        CreatePassiveSellOfferOp createPassiveSellOfferOp;
    case SET_OPTIONS:
        SetOptionsOp setOptionsOp;
    case CHANGE_TRUST:
        ChangeTrustOp changeTrustOp;
    case ALLOW_TRUST:
        AllowTrustOp allowTrustOp;
    case ACCOUNT_MERGE:
        MuxedAccount destination;
    case INFLATION:
        void;
    case MANAGE_DATA:
        ManageDataOp manageDataOp;
    case BUMP_SEQUENCE:
        BumpSequenceOp bumpSequenceOp;
    case MANAGE_BUY_OFFER:
        ManageBuyOfferOp manageBuyOfferOp;
    case PATH_PAYMENT_STRICT_SEND:
        PathPaymentStrictSendOp pathPaymentStrictSendOp;
    case CREATE_CLAIMABLE_BALANCE:
        CreateClaimableBalanceOp createClaimableBalanceOp;
    case CLAIM_CLAIMABLE_BALANCE:
        ClaimClaimableBalanceOp claimClaimableBalanceOp;
    case BEGIN_SPONSORING_FUTURE_RESERVES:
        BeginSponsoringFutureReservesOp beginSponsoringFutureReservesOp;
    case END_SPONSORING_FUTURE_RESERVES:
        void;
    case REVOKE_SPONSORSHIP:
        RevokeSponsorshipOp revokeSponsorshipOp;
    case CLAWBACK:
        ClawbackOp clawbackOp;
    case CLAWBACK_CLAIMABLE_BALANCE:
        ClawbackClaimableBalanceOp clawbackClaimableBalanceOp;
    case SET_TRUST_LINE_FLAGS:
        SetTrustLineFlagsOp setTrustLineFlagsOp;
    case LIQUIDITY_POOL_DEPOSIT:
        LiquidityPoolDepositOp liquidityPoolDepositOp;
    case LIQUIDITY_POOL_WITHDRAW:
        LiquidityPoolWithdrawOp liquidityPoolWithdrawOp;
    }
    body;
};

union HashIDPreimage switch (EnvelopeType type)
{
case ENVELOPE_TYPE_OP_ID:
    struct
    {
        AccountID sourceAccount;
        SequenceNumber seqNum;
        uint32 opNum;
    } operationID;
case ENVELOPE_TYPE_POOL_REVOKE_OP_ID:
    struct
    {
        AccountID sourceAccount;
        SequenceNumber seqNum;
        uint32 opNum;
        PoolID liquidityPoolID;
        Asset asset;
    } revokeID;
};

enum MemoType
{
    MEMO_NONE = 0,
    MEMO_TEXT = 1,
    MEMO_ID = 2,
    MEMO_HASH = 3,
    MEMO_RETURN = 4
};

union Memo switch (MemoType type)
{
case MEMO_NONE:
    void;
case MEMO_TEXT:
    string text<28>;
case MEMO_ID:
    uint64 id;
case MEMO_HASH:
    Hash hash;
case MEMO_RETURN:
    Hash retHash;
};

struct TimeBounds
{
    TimePoint minTime;
    TimePoint maxTime;
};

const MAX_OPS_PER_TX = 100;

struct TransactionV0
{
    uint256 sourceAccountEd25519;
    uint32 fee;
    SequenceNumber seqNum;
    TimeBounds* timeBounds;
    Memo memo;
    Operation operations<MAX_OPS_PER_TX>;
    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

struct TransactionV0Envelope
{
    TransactionV0 tx;
    /* Each decorated signature is a signature over the SHA256 hash of
     * a TransactionSignaturePayload */
    DecoratedSignature signatures<20>;
};

/* a transaction is a container for a set of operations
    - is executed by an account
    - fees are collected from the account
    - operations are executed in order as one ACID transaction
          either all operations are applied or none are
          if any returns a failing code
*/
struct Transaction
{
    MuxedAccount sourceAccount;

    uint32 fee;

    SequenceNumber seqNum;

    TimeBounds* timeBounds;

    Memo memo;

    Operation operations<MAX_OPS_PER_TX>;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

struct TransactionV1Envelope
{
    Transaction tx;
    /* Each decorated signature is a signature over the SHA256 hash of
     * a TransactionSignaturePayload */
    DecoratedSignature signatures<20>;
};

struct FeeBumpTransaction
{
    MuxedAccount feeSource;
    int64 fee;
    union switch (EnvelopeType type)
    {
    case ENVELOPE_TYPE_TX:
        TransactionV1Envelope v1;
    }
    innerTx;
    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

struct FeeBumpTransactionEnvelope
{
    FeeBumpTransaction tx;
    /* Each decorated signature is a signature over the SHA256 hash of
     * a TransactionSignaturePayload */
    DecoratedSignature signatures<20>;
};

/* A TransactionEnvelope wraps a transaction with signatures. */
union TransactionEnvelope switch (EnvelopeType type)
{
case ENVELOPE_TYPE_TX_V0:
    TransactionV0Envelope v0;
case ENVELOPE_TYPE_TX:
    TransactionV1Envelope v1;
case ENVELOPE_TYPE_TX_FEE_BUMP:
    FeeBumpTransactionEnvelope feeBump;
};

struct TransactionSignaturePayload
{
    Hash networkId;
    union switch (EnvelopeType type)
    {
    case ENVELOPE_TYPE_TX:
        Transaction tx;
    case ENVELOPE_TYPE_TX_FEE_BUMP:
        FeeBumpTransaction feeBump;
    }
    taggedTransaction;
};

/* Operation Results section */

enum ClaimAtomType
{
    CLAIM_ATOM_TYPE_V0 = 0,
    CLAIM_ATOM_TYPE_ORDER_BOOK = 1,
    CLAIM_ATOM_TYPE_LIQUIDITY_POOL = 2
};

struct ClaimOfferAtomV0
{
    uint256 sellerEd25519;
    int64 offerID;

    Asset assetSold;
    int64 amountSold;

    Asset assetBought;
    int64 amountBought;
};

struct ClaimOfferAtom
{
    AccountID sellerID;
    int64 offerID;

    Asset assetSold;
    int64 amountSold;

    Asset assetBought;
    int64 amountBought;
};

struct ClaimLiquidityAtom
{
    PoolID liquidityPoolID;

    Asset assetSold;
    int64 amountSold;

    Asset assetBought;
    int64 amountBought;
};

/* This result is used when offers are taken or liquidity is exchanged with a
   liquidity pool during an operation
*/
union ClaimAtom switch (ClaimAtomType type)
{
case CLAIM_ATOM_TYPE_V0:
    ClaimOfferAtomV0 v0;
case CLAIM_ATOM_TYPE_ORDER_BOOK:
    ClaimOfferAtom orderBook;
case CLAIM_ATOM_TYPE_LIQUIDITY_POOL:
    ClaimLiquidityAtom liquidityPool;
};

/******* CreateAccount Result ********/

enum CreateAccountResultCode
{
    CREATE_ACCOUNT_SUCCESS = 0,

    CREATE_ACCOUNT_MALFORMED = -1,
    CREATE_ACCOUNT_UNDERFUNDED = -2,
    CREATE_ACCOUNT_LOW_RESERVE =
        -3,
    CREATE_ACCOUNT_ALREADY_EXIST = -4
};

union CreateAccountResult switch (CreateAccountResultCode code)
{
case CREATE_ACCOUNT_SUCCESS:
    void;
default:
    void;
};

/******* Payment Result ********/

enum PaymentResultCode
{
    PAYMENT_SUCCESS = 0,

    PAYMENT_MALFORMED = -1,
    PAYMENT_UNDERFUNDED = -2,
    PAYMENT_SRC_NO_TRUST = -3,
    PAYMENT_SRC_NOT_AUTHORIZED = -4,
    PAYMENT_NO_DESTINATION = -5,
    PAYMENT_NO_TRUST = -6,
    PAYMENT_NOT_AUTHORIZED = -7,
    PAYMENT_LINE_FULL = -8,
    PAYMENT_NO_ISSUER = -9
};

union PaymentResult switch (PaymentResultCode code)
{
case PAYMENT_SUCCESS:
    void;
default:
    void;
};

/******* PathPaymentStrictReceive Result ********/

enum PathPaymentStrictReceiveResultCode
{
    PATH_PAYMENT_STRICT_RECEIVE_SUCCESS = 0,

    PATH_PAYMENT_STRICT_RECEIVE_MALFORMED = -1,
    PATH_PAYMENT_STRICT_RECEIVE_UNDERFUNDED =
        -2,
    PATH_PAYMENT_STRICT_RECEIVE_SRC_NO_TRUST =
        -3,
    PATH_PAYMENT_STRICT_RECEIVE_SRC_NOT_AUTHORIZED =
        -4,
    PATH_PAYMENT_STRICT_RECEIVE_NO_DESTINATION =
        -5,
    PATH_PAYMENT_STRICT_RECEIVE_NO_TRUST =
        -6,
    PATH_PAYMENT_STRICT_RECEIVE_NOT_AUTHORIZED =
        -7,
    PATH_PAYMENT_STRICT_RECEIVE_LINE_FULL =
        -8,
    PATH_PAYMENT_STRICT_RECEIVE_NO_ISSUER = -9,
    PATH_PAYMENT_STRICT_RECEIVE_TOO_FEW_OFFERS =
        -10,
    PATH_PAYMENT_STRICT_RECEIVE_OFFER_CROSS_SELF =
        -11,
    PATH_PAYMENT_STRICT_RECEIVE_OVER_SENDMAX = -12
};

struct SimplePaymentResult
{
    AccountID destination;
    Asset asset;
    int64 amount;
};

union PathPaymentStrictReceiveResult switch (
    PathPaymentStrictReceiveResultCode code)
{
case PATH_PAYMENT_STRICT_RECEIVE_SUCCESS:
    struct
    {
        ClaimAtom offers<>;
        SimplePaymentResult last;
    } success;
case PATH_PAYMENT_STRICT_RECEIVE_NO_ISSUER:
    Asset noIssuer;
default:
    void;
};

/******* PathPaymentStrictSend Result ********/

enum PathPaymentStrictSendResultCode
{
    PATH_PAYMENT_STRICT_SEND_SUCCESS = 0,

    PATH_PAYMENT_STRICT_SEND_MALFORMED = -1,
    PATH_PAYMENT_STRICT_SEND_UNDERFUNDED =
        -2,
    PATH_PAYMENT_STRICT_SEND_SRC_NO_TRUST =
        -3,
    PATH_PAYMENT_STRICT_SEND_SRC_NOT_AUTHORIZED =
        -4,
    PATH_PAYMENT_STRICT_SEND_NO_DESTINATION =
        -5,
    PATH_PAYMENT_STRICT_SEND_NO_TRUST =
        -6,
    PATH_PAYMENT_STRICT_SEND_NOT_AUTHORIZED =
        -7,
    PATH_PAYMENT_STRICT_SEND_LINE_FULL = -8,
    PATH_PAYMENT_STRICT_SEND_NO_ISSUER = -9,
    PATH_PAYMENT_STRICT_SEND_TOO_FEW_OFFERS =
        -10,
    PATH_PAYMENT_STRICT_SEND_OFFER_CROSS_SELF =
        -11,
    PATH_PAYMENT_STRICT_SEND_UNDER_DESTMIN = -12
};

union PathPaymentStrictSendResult switch (PathPaymentStrictSendResultCode code)
{
case PATH_PAYMENT_STRICT_SEND_SUCCESS:
    struct
    {
        ClaimAtom offers<>;
        SimplePaymentResult last;
    } success;
case PATH_PAYMENT_STRICT_SEND_NO_ISSUER:
    Asset noIssuer;
default:
    void;
};

/******* ManageSellOffer Result ********/

enum ManageSellOfferResultCode
{
    MANAGE_SELL_OFFER_SUCCESS = 0,

    MANAGE_SELL_OFFER_MALFORMED = -1,
    MANAGE_SELL_OFFER_SELL_NO_TRUST =
        -2,
    MANAGE_SELL_OFFER_BUY_NO_TRUST = -3,
    MANAGE_SELL_OFFER_SELL_NOT_AUTHORIZED = -4,
    MANAGE_SELL_OFFER_BUY_NOT_AUTHORIZED = -5,
    MANAGE_SELL_OFFER_LINE_FULL = -6,
    MANAGE_SELL_OFFER_UNDERFUNDED = -7,
    MANAGE_SELL_OFFER_CROSS_SELF =
        -8,
    MANAGE_SELL_OFFER_SELL_NO_ISSUER = -9,
    MANAGE_SELL_OFFER_BUY_NO_ISSUER = -10,

    MANAGE_SELL_OFFER_NOT_FOUND =
        -11,

    MANAGE_SELL_OFFER_LOW_RESERVE =
        -12
};

enum ManageOfferEffect
{
    MANAGE_OFFER_CREATED = 0,
    MANAGE_OFFER_UPDATED = 1,
    MANAGE_OFFER_DELETED = 2
};

struct ManageOfferSuccessResult
{
    ClaimAtom offersClaimed<>;

    union switch (ManageOfferEffect effect)
    {
    case MANAGE_OFFER_CREATED:
    case MANAGE_OFFER_UPDATED:
        OfferEntry offer;
    default:
        void;
    }
    offer;
};

union ManageSellOfferResult switch (ManageSellOfferResultCode code)
{
case MANAGE_SELL_OFFER_SUCCESS:
    ManageOfferSuccessResult success;
default:
    void;
};

/******* ManageBuyOffer Result ********/

enum ManageBuyOfferResultCode
{
    MANAGE_BUY_OFFER_SUCCESS = 0,

    MANAGE_BUY_OFFER_MALFORMED = -1,
    MANAGE_BUY_OFFER_SELL_NO_TRUST = -2,
    MANAGE_BUY_OFFER_BUY_NO_TRUST = -3,
    MANAGE_BUY_OFFER_SELL_NOT_AUTHORIZED = -4,
    MANAGE_BUY_OFFER_BUY_NOT_AUTHORIZED = -5,
    MANAGE_BUY_OFFER_LINE_FULL = -6,
    MANAGE_BUY_OFFER_UNDERFUNDED = -7,
    MANAGE_BUY_OFFER_CROSS_SELF = -8,
    MANAGE_BUY_OFFER_SELL_NO_ISSUER = -9,
    MANAGE_BUY_OFFER_BUY_NO_ISSUER = -10,

    MANAGE_BUY_OFFER_NOT_FOUND =
        -11,

    MANAGE_BUY_OFFER_LOW_RESERVE = -12
};

union ManageBuyOfferResult switch (ManageBuyOfferResultCode code)
{
case MANAGE_BUY_OFFER_SUCCESS:
    ManageOfferSuccessResult success;
default:
    void;
};

/******* SetOptions Result ********/

enum SetOptionsResultCode
{
    SET_OPTIONS_SUCCESS = 0,
    SET_OPTIONS_LOW_RESERVE = -1,
    SET_OPTIONS_TOO_MANY_SIGNERS = -2,
    SET_OPTIONS_BAD_FLAGS = -3,
    SET_OPTIONS_INVALID_INFLATION = -4,
    SET_OPTIONS_CANT_CHANGE = -5,
    SET_OPTIONS_UNKNOWN_FLAG = -6,
    SET_OPTIONS_THRESHOLD_OUT_OF_RANGE = -7,
    SET_OPTIONS_BAD_SIGNER = -8,
    SET_OPTIONS_INVALID_HOME_DOMAIN = -9,
    SET_OPTIONS_AUTH_REVOCABLE_REQUIRED =
        -10
};

union SetOptionsResult switch (SetOptionsResultCode code)
{
case SET_OPTIONS_SUCCESS:
    void;
default:
    void;
};

/******* ChangeTrust Result ********/

enum ChangeTrustResultCode
{
    CHANGE_TRUST_SUCCESS = 0,
    CHANGE_TRUST_MALFORMED = -1,
    CHANGE_TRUST_NO_ISSUER = -2,
    CHANGE_TRUST_INVALID_LIMIT = -3,
    CHANGE_TRUST_LOW_RESERVE =
        -4,
    CHANGE_TRUST_SELF_NOT_ALLOWED = -5,
    CHANGE_TRUST_TRUST_LINE_MISSING = -6,
    CHANGE_TRUST_CANNOT_DELETE = -7,
    CHANGE_TRUST_NOT_AUTH_MAINTAIN_LIABILITIES = -8
};

union ChangeTrustResult switch (ChangeTrustResultCode code)
{
case CHANGE_TRUST_SUCCESS:
    void;
default:
    void;
};

/******* AllowTrust Result ********/

enum AllowTrustResultCode
{
    ALLOW_TRUST_SUCCESS = 0,
    ALLOW_TRUST_MALFORMED = -1,
    ALLOW_TRUST_NO_TRUST_LINE = -2,
    ALLOW_TRUST_TRUST_NOT_REQUIRED = -3,
    ALLOW_TRUST_CANT_REVOKE = -4,
    ALLOW_TRUST_SELF_NOT_ALLOWED = -5,
    ALLOW_TRUST_LOW_RESERVE = -6
};

union AllowTrustResult switch (AllowTrustResultCode code)
{
case ALLOW_TRUST_SUCCESS:
    void;
default:
    void;
};

/******* AccountMerge Result ********/

enum AccountMergeResultCode
{
    ACCOUNT_MERGE_SUCCESS = 0,
    ACCOUNT_MERGE_MALFORMED = -1,
    ACCOUNT_MERGE_NO_ACCOUNT = -2,
    ACCOUNT_MERGE_IMMUTABLE_SET = -3,
    ACCOUNT_MERGE_HAS_SUB_ENTRIES = -4,
    ACCOUNT_MERGE_SEQNUM_TOO_FAR = -5,
    ACCOUNT_MERGE_DEST_FULL = -6,
    ACCOUNT_MERGE_IS_SPONSOR = -7
};

union AccountMergeResult switch (AccountMergeResultCode code)
{
case ACCOUNT_MERGE_SUCCESS:
    int64 sourceAccountBalance;
default:
    void;
};

/******* Inflation Result ********/

enum InflationResultCode
{
    INFLATION_SUCCESS = 0,
    INFLATION_NOT_TIME = -1
};

struct InflationPayout
{
    AccountID destination;
    int64 amount;
};

union InflationResult switch (InflationResultCode code)
{
case INFLATION_SUCCESS:
    InflationPayout payouts<>;
default:
    void;
};

/******* ManageData Result ********/

enum ManageDataResultCode
{
    MANAGE_DATA_SUCCESS = 0,
    MANAGE_DATA_NOT_SUPPORTED_YET =
        -1,
    MANAGE_DATA_NAME_NOT_FOUND =
        -2,
    MANAGE_DATA_LOW_RESERVE = -3,
    MANAGE_DATA_INVALID_NAME = -4
};

union ManageDataResult switch (ManageDataResultCode code)
{
case MANAGE_DATA_SUCCESS:
    void;
default:
    void;
};

/******* BumpSequence Result ********/

enum BumpSequenceResultCode
{
    BUMP_SEQUENCE_SUCCESS = 0,
    BUMP_SEQUENCE_BAD_SEQ = -1
};

union BumpSequenceResult switch (BumpSequenceResultCode code)
{
case BUMP_SEQUENCE_SUCCESS:
    void;
default:
    void;
};

/******* CreateClaimableBalance Result ********/

enum CreateClaimableBalanceResultCode
{
    CREATE_CLAIMABLE_BALANCE_SUCCESS = 0,
    CREATE_CLAIMABLE_BALANCE_MALFORMED = -1,
    CREATE_CLAIMABLE_BALANCE_LOW_RESERVE = -2,
    CREATE_CLAIMABLE_BALANCE_NO_TRUST = -3,
    CREATE_CLAIMABLE_BALANCE_NOT_AUTHORIZED = -4,
    CREATE_CLAIMABLE_BALANCE_UNDERFUNDED = -5
};

union CreateClaimableBalanceResult switch (
    CreateClaimableBalanceResultCode code)
{
case CREATE_CLAIMABLE_BALANCE_SUCCESS:
    ClaimableBalanceID balanceID;
default:
    void;
};

/******* ClaimClaimableBalance Result ********/

enum ClaimClaimableBalanceResultCode
{
    CLAIM_CLAIMABLE_BALANCE_SUCCESS = 0,
    CLAIM_CLAIMABLE_BALANCE_DOES_NOT_EXIST = -1,
    CLAIM_CLAIMABLE_BALANCE_CANNOT_CLAIM = -2,
    CLAIM_CLAIMABLE_BALANCE_LINE_FULL = -3,
    CLAIM_CLAIMABLE_BALANCE_NO_TRUST = -4,
    CLAIM_CLAIMABLE_BALANCE_NOT_AUTHORIZED = -5

};

union ClaimClaimableBalanceResult switch (ClaimClaimableBalanceResultCode code)
{
case CLAIM_CLAIMABLE_BALANCE_SUCCESS:
    void;
default:
    void;
};

/******* BeginSponsoringFutureReserves Result ********/

enum BeginSponsoringFutureReservesResultCode
{
    BEGIN_SPONSORING_FUTURE_RESERVES_SUCCESS = 0,

    BEGIN_SPONSORING_FUTURE_RESERVES_MALFORMED = -1,
    BEGIN_SPONSORING_FUTURE_RESERVES_ALREADY_SPONSORED = -2,
    BEGIN_SPONSORING_FUTURE_RESERVES_RECURSIVE = -3
};

union BeginSponsoringFutureReservesResult switch (
    BeginSponsoringFutureReservesResultCode code)
{
case BEGIN_SPONSORING_FUTURE_RESERVES_SUCCESS:
    void;
default:
    void;
};

/******* EndSponsoringFutureReserves Result ********/

enum EndSponsoringFutureReservesResultCode
{
    END_SPONSORING_FUTURE_RESERVES_SUCCESS = 0,

    END_SPONSORING_FUTURE_RESERVES_NOT_SPONSORED = -1
};

union EndSponsoringFutureReservesResult switch (
    EndSponsoringFutureReservesResultCode code)
{
case END_SPONSORING_FUTURE_RESERVES_SUCCESS:
    void;
default:
    void;
};

/******* RevokeSponsorship Result ********/

enum RevokeSponsorshipResultCode
{
    REVOKE_SPONSORSHIP_SUCCESS = 0,

    REVOKE_SPONSORSHIP_DOES_NOT_EXIST = -1,
    REVOKE_SPONSORSHIP_NOT_SPONSOR = -2,
    REVOKE_SPONSORSHIP_LOW_RESERVE = -3,
    REVOKE_SPONSORSHIP_ONLY_TRANSFERABLE = -4,
    REVOKE_SPONSORSHIP_MALFORMED = -5
};

union RevokeSponsorshipResult switch (RevokeSponsorshipResultCode code)
{
case REVOKE_SPONSORSHIP_SUCCESS:
    void;
default:
    void;
};

/******* Clawback Result ********/

enum ClawbackResultCode
{
    CLAWBACK_SUCCESS = 0,

    CLAWBACK_MALFORMED = -1,
    CLAWBACK_NOT_CLAWBACK_ENABLED = -2,
    CLAWBACK_NO_TRUST = -3,
    CLAWBACK_UNDERFUNDED = -4
};

union ClawbackResult switch (ClawbackResultCode code)
{
case CLAWBACK_SUCCESS:
    void;
default:
    void;
};

/******* ClawbackClaimableBalance Result ********/

enum ClawbackClaimableBalanceResultCode
{
    CLAWBACK_CLAIMABLE_BALANCE_SUCCESS = 0,

    CLAWBACK_CLAIMABLE_BALANCE_DOES_NOT_EXIST = -1,
    CLAWBACK_CLAIMABLE_BALANCE_NOT_ISSUER = -2,
    CLAWBACK_CLAIMABLE_BALANCE_NOT_CLAWBACK_ENABLED = -3
};

union ClawbackClaimableBalanceResult switch (
    ClawbackClaimableBalanceResultCode code)
{
case CLAWBACK_CLAIMABLE_BALANCE_SUCCESS:
    void;
default:
    void;
};

/******* SetTrustLineFlags Result ********/

enum SetTrustLineFlagsResultCode
{
    SET_TRUST_LINE_FLAGS_SUCCESS = 0,

    SET_TRUST_LINE_FLAGS_MALFORMED = -1,
    SET_TRUST_LINE_FLAGS_NO_TRUST_LINE = -2,
    SET_TRUST_LINE_FLAGS_CANT_REVOKE = -3,
    SET_TRUST_LINE_FLAGS_INVALID_STATE = -4,
    SET_TRUST_LINE_FLAGS_LOW_RESERVE = -5
};

union SetTrustLineFlagsResult switch (SetTrustLineFlagsResultCode code)
{
case SET_TRUST_LINE_FLAGS_SUCCESS:
    void;
default:
    void;
};

/******* LiquidityPoolDeposit Result ********/

enum LiquidityPoolDepositResultCode
{
    LIQUIDITY_POOL_DEPOSIT_SUCCESS = 0,

    LIQUIDITY_POOL_DEPOSIT_MALFORMED = -1,
    LIQUIDITY_POOL_DEPOSIT_NO_TRUST = -2,
    LIQUIDITY_POOL_DEPOSIT_NOT_AUTHORIZED = -3,
    LIQUIDITY_POOL_DEPOSIT_UNDERFUNDED = -4,
    LIQUIDITY_POOL_DEPOSIT_LINE_FULL = -5,
    LIQUIDITY_POOL_DEPOSIT_BAD_PRICE = -6,
    LIQUIDITY_POOL_DEPOSIT_POOL_FULL = -7
};

union LiquidityPoolDepositResult switch (
    LiquidityPoolDepositResultCode code)
{
case LIQUIDITY_POOL_DEPOSIT_SUCCESS:
    void;
default:
    void;
};

/******* LiquidityPoolWithdraw Result ********/

enum LiquidityPoolWithdrawResultCode
{
    LIQUIDITY_POOL_WITHDRAW_SUCCESS = 0,

    LIQUIDITY_POOL_WITHDRAW_MALFORMED = -1,
    LIQUIDITY_POOL_WITHDRAW_NO_TRUST = -2,
    LIQUIDITY_POOL_WITHDRAW_UNDERFUNDED = -3,
    LIQUIDITY_POOL_WITHDRAW_LINE_FULL = -4,
    LIQUIDITY_POOL_WITHDRAW_UNDER_MINIMUM = -5
};

union LiquidityPoolWithdrawResult switch (
    LiquidityPoolWithdrawResultCode code)
{
case LIQUIDITY_POOL_WITHDRAW_SUCCESS:
    void;
default:
    void;
};

/* High level Operation Result */
enum OperationResultCode
{
    opINNER = 0,

    opBAD_AUTH = -1,
    opNO_ACCOUNT = -2,
    opNOT_SUPPORTED = -3,
    opTOO_MANY_SUBENTRIES = -4,
    opEXCEEDED_WORK_LIMIT = -5,
    opTOO_MANY_SPONSORING = -6
};

union OperationResult switch (OperationResultCode code)
{
case opINNER:
    union switch (OperationType type)
    {
    case CREATE_ACCOUNT:
        CreateAccountResult createAccountResult;
    case PAYMENT:
        PaymentResult paymentResult;
    case PATH_PAYMENT_STRICT_RECEIVE:
        PathPaymentStrictReceiveResult pathPaymentStrictReceiveResult;
    case MANAGE_SELL_OFFER:
        ManageSellOfferResult manageSellOfferResult;
    case CREATE_PASSIVE_SELL_OFFER:
        ManageSellOfferResult createPassiveSellOfferResult;
    case SET_OPTIONS:
        SetOptionsResult setOptionsResult;
    case CHANGE_TRUST:
        ChangeTrustResult changeTrustResult;
    case ALLOW_TRUST:
        AllowTrustResult allowTrustResult;
    case ACCOUNT_MERGE:
        AccountMergeResult accountMergeResult;
    case INFLATION:
        InflationResult inflationResult;
    case MANAGE_DATA:
        ManageDataResult manageDataResult;
    case BUMP_SEQUENCE:
        BumpSequenceResult bumpSeqResult;
    case MANAGE_BUY_OFFER:
        ManageBuyOfferResult manageBuyOfferResult;
    case PATH_PAYMENT_STRICT_SEND:
        PathPaymentStrictSendResult pathPaymentStrictSendResult;
    case CREATE_CLAIMABLE_BALANCE:
        CreateClaimableBalanceResult createClaimableBalanceResult;
    case CLAIM_CLAIMABLE_BALANCE:
        ClaimClaimableBalanceResult claimClaimableBalanceResult;
    case BEGIN_SPONSORING_FUTURE_RESERVES:
        BeginSponsoringFutureReservesResult beginSponsoringFutureReservesResult;
    case END_SPONSORING_FUTURE_RESERVES:
        EndSponsoringFutureReservesResult endSponsoringFutureReservesResult;
    case REVOKE_SPONSORSHIP:
        RevokeSponsorshipResult revokeSponsorshipResult;
    case CLAWBACK:
        ClawbackResult clawbackResult;
    case CLAWBACK_CLAIMABLE_BALANCE:
        ClawbackClaimableBalanceResult clawbackClaimableBalanceResult;
    case SET_TRUST_LINE_FLAGS:
        SetTrustLineFlagsResult setTrustLineFlagsResult;
    case LIQUIDITY_POOL_DEPOSIT:
        LiquidityPoolDepositResult liquidityPoolDepositResult;
    case LIQUIDITY_POOL_WITHDRAW:
        LiquidityPoolWithdrawResult liquidityPoolWithdrawResult;
    }
    tr;
default:
    void;
};

enum TransactionResultCode
{
    txFEE_BUMP_INNER_SUCCESS = 1,
    txSUCCESS = 0,

    txFAILED = -1,

    txTOO_EARLY = -2,
    txTOO_LATE = -3,
    txMISSING_OPERATION = -4,
    txBAD_SEQ = -5,

    txBAD_AUTH = -6,
    txINSUFFICIENT_BALANCE = -7,
    txNO_ACCOUNT = -8,
    txINSUFFICIENT_FEE = -9,
    txBAD_AUTH_EXTRA = -10,
    txINTERNAL_ERROR = -11,

    txNOT_SUPPORTED = -12,
    txFEE_BUMP_INNER_FAILED = -13,
    txBAD_SPONSORSHIP = -14
};

struct InnerTransactionResult
{
    int64 feeCharged;

    union switch (TransactionResultCode code)
    {
    case txSUCCESS:
    case txFAILED:
        OperationResult results<>;
    case txTOO_EARLY:
    case txTOO_LATE:
    case txMISSING_OPERATION:
    case txBAD_SEQ:
    case txBAD_AUTH:
    case txINSUFFICIENT_BALANCE:
    case txNO_ACCOUNT:
    case txINSUFFICIENT_FEE:
    case txBAD_AUTH_EXTRA:
    case txINTERNAL_ERROR:
    case txNOT_SUPPORTED:
    case txBAD_SPONSORSHIP:
        void;
    }
    result;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

struct InnerTransactionResultPair
{
    Hash transactionHash;
    InnerTransactionResult result;
};

struct TransactionResult
{
    int64 feeCharged;

    union switch (TransactionResultCode code)
    {
    case txFEE_BUMP_INNER_SUCCESS:
    case txFEE_BUMP_INNER_FAILED:
        InnerTransactionResultPair innerResultPair;
    case txSUCCESS:
    case txFAILED:
        OperationResult results<>;
    default:
        void;
    }
    result;

    union switch (int v)
    {
    case 0:
        void;
    }
    ext;
};

struct TestCase
{
    LedgerHeader ledgerHeader;
    LedgerEntry ledgerEntries<>;
    TransactionEnvelope transationEnvelopes<>;
    TransactionResult transactionResults<>;
    LedgerEntryChange ledgerChanges<>;
};
