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
