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
