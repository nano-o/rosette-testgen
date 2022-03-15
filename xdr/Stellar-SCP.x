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
