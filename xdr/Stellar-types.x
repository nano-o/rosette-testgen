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
