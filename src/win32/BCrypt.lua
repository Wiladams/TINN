

local ffi = require "ffi"
local bit = require "bit"
local band = bit.band

require("ntstatus");
local core_string = require("core_string_l1_1_0");

local L = core_string.toUnicode;

local BCLib = ffi.load("Bcrypt.dll");


local BCRYPT_MAKE_INTERFACE_VERSION = function(major,minor)
	return {band(0xff, major), band(0xff, minor)}
end



local BCrypt = {

    -- Flags to BCryptGenRandom
    BCRYPT_RNG_USE_ENTROPY_IN_BUFFER   = 0x00000001;
    BCRYPT_USE_SYSTEM_PREFERRED_RNG    = 0x00000002;


    BCRYPT_SUCCESS = function (Status)
	   return Status >= 0
    end;

--[[
//
// BCRYPT_OBJECT_ALIGNMENT must be a power of 2
// We align all our internal data structures to 16 to
// allow fast XMM memory accesses.
// BCrypt callers do not need to take any alignment precautions.
//
 BCRYPT_OBJECT_ALIGNMENT    16
--]]



-- DeriveKey KDF Types

 BCRYPT_KDF_HASH                     = L"HASH";
 BCRYPT_KDF_HMAC                     = L"HMAC";
 BCRYPT_KDF_TLS_PRF                  = L"TLS_PRF";
 BCRYPT_KDF_SP80056A_CONCAT          = L"SP800_56A_CONCAT";

--[[
//
// DeriveKey KDF BufferTypes
//
// For BCRYPT_KDF_HASH and BCRYPT_KDF_HMAC operations, there may be an arbitrary
// number of KDF_SECRET_PREPEND and KDF_SECRET_APPEND buffertypes in the
// parameter list.  The BufferTypes are processed in order of appearence
// within the parameter list.
//
--]]
 KDF_HASH_ALGORITHM      = 0x0;
 KDF_SECRET_PREPEND      = 0x1;
 KDF_SECRET_APPEND       = 0x2;
 KDF_HMAC_KEY            = 0x3;
 KDF_TLS_PRF_LABEL       = 0x4;
 KDF_TLS_PRF_SEED        = 0x5;
 KDF_SECRET_HANDLE       = 0x6;
 KDF_TLS_PRF_PROTOCOL    = 0x7;
 KDF_ALGORITHMID         = 0x8;
 KDF_PARTYUINFO          = 0x9;
 KDF_PARTYVINFO          = 0xA;
 KDF_SUPPPUBINFO         = 0xB;
 KDF_SUPPPRIVINFO        = 0xC;

--[[
//
// DeriveKey Flags:
//
// KDF_USE_SECRET_AS_HMAC_KEY_FLAG causes the secret agreement to serve also
// as the HMAC key.  If this flag is used, the KDF_HMAC_KEY parameter should
// NOT be specified.
//
--]]
 KDF_USE_SECRET_AS_HMAC_KEY_FLAG = 0x1;


 BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO_VERSION = 1;

 BCRYPT_AUTH_MODE_CHAIN_CALLS_FLAG   = 0x00000001;
 BCRYPT_AUTH_MODE_IN_PROGRESS_FLAG   = 0x00000002;
--[[
 BCRYPT_INIT_AUTH_MODE_INFO(_AUTH_INFO_STRUCT_)    \
            RtlZeroMemory((&_AUTH_INFO_STRUCT_), sizeof(BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO));  \
            (_AUTH_INFO_STRUCT_).cbSize = sizeof(BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO);          \
            (_AUTH_INFO_STRUCT_).dwInfoVersion = BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO_VERSION;
--]]

-- BCrypt String Properties


-- BCrypt(Import/Export)Key BLOB types
 BCRYPT_OPAQUE_KEY_BLOB      = L"OpaqueKeyBlob";
 BCRYPT_KEY_DATA_BLOB        = L"KeyDataBlob";
 BCRYPT_AES_WRAP_KEY_BLOB    = L"Rfc3565KeyWrapBlob";

-- BCryptGetProperty strings
 BCRYPT_OBJECT_LENGTH        = L"ObjectLength";
 BCRYPT_ALGORITHM_NAME       = L"AlgorithmName";
 BCRYPT_PROVIDER_HANDLE      = L"ProviderHandle";
 BCRYPT_CHAINING_MODE        = L"ChainingMode";
 BCRYPT_BLOCK_LENGTH         = L"BlockLength";
 BCRYPT_KEY_LENGTH           = L"KeyLength";
 BCRYPT_KEY_OBJECT_LENGTH    = L"KeyObjectLength";
 BCRYPT_KEY_STRENGTH         = L"KeyStrength";
 BCRYPT_KEY_LENGTHS          = L"KeyLengths";
 BCRYPT_BLOCK_SIZE_LIST      = L"BlockSizeList";
 BCRYPT_EFFECTIVE_KEY_LENGTH = L"EffectiveKeyLength";
 BCRYPT_HASH_LENGTH          = L"HashDigestLength";
 BCRYPT_HASH_OID_LIST        = L"HashOIDList";
 BCRYPT_PADDING_SCHEMES      = L"PaddingSchemes";
 BCRYPT_SIGNATURE_LENGTH     = L"SignatureLength";
 BCRYPT_HASH_BLOCK_LENGTH    = L"HashBlockLength";
 BCRYPT_AUTH_TAG_LENGTH      = L"AuthTagLength";
 BCRYPT_PRIMITIVE_TYPE       = L"PrimitiveType";
 BCRYPT_IS_KEYED_HASH        = L"IsKeyedHash";

-- BCryptSetProperty strings
 BCRYPT_INITIALIZATION_VECTOR   = L"IV";


-- Property Strings
 BCRYPT_CHAIN_MODE_NA       = L"ChainingModeN/A";
 BCRYPT_CHAIN_MODE_CBC      = L"ChainingModeCBC";
 BCRYPT_CHAIN_MODE_ECB      = L"ChainingModeECB";
 BCRYPT_CHAIN_MODE_CFB      = L"ChainingModeCFB";
 BCRYPT_CHAIN_MODE_CCM      = L"ChainingModeCCM";
 BCRYPT_CHAIN_MODE_GCM      = L"ChainingModeGCM";

-- Supported RSA Padding Types
 BCRYPT_SUPPORTED_PAD_ROUTER    = 0x00000001;
 BCRYPT_SUPPORTED_PAD_PKCS1_ENC = 0x00000002;
 BCRYPT_SUPPORTED_PAD_PKCS1_SIG = 0x00000004;
 BCRYPT_SUPPORTED_PAD_OAEP      = 0x00000008;
 BCRYPT_SUPPORTED_PAD_PSS       = 0x00000010;


--      BCrypt Flags


 BCRYPT_PROV_DISPATCH       = 0x00000001;  -- BCryptOpenAlgorithmProvider

 BCRYPT_BLOCK_PADDING       = 0x00000001;  -- BCryptEncrypt/Decrypt

-- RSA padding schemes
 BCRYPT_PAD_NONE            = 0x00000001;
 BCRYPT_PAD_PKCS1           = 0x00000002;  -- BCryptEncrypt/Decrypt BCryptSignHash/VerifySignature
 BCRYPT_PAD_OAEP            = 0x00000004;  -- BCryptEncrypt/Decrypt
 BCRYPT_PAD_PSS             = 0x00000008;  -- BCryptSignHash/VerifySignature


 BCRYPTBUFFER_VERSION       = 0;


-- Structures used to represent key blobs.


 BCRYPT_PUBLIC_KEY_BLOB      = L"PUBLICBLOB";
 BCRYPT_PRIVATE_KEY_BLOB     = L"PRIVATEBLOB";

--[[
 The BCRYPT_RSAPUBLIC_BLOB and BCRYPT_RSAPRIVATE_BLOB blob types are used
 to transport plaintext RSA keys. These blob types will be supported by
 all RSA primitive providers.
 The BCRYPT_RSAPRIVATE_BLOB includes the following values:
 Public Exponent
 Modulus
 Prime1
 Prime2
--]]
 BCRYPT_RSAPUBLIC_BLOB       = L"RSAPUBLICBLOB";
 BCRYPT_RSAPRIVATE_BLOB      = L"RSAPRIVATEBLOB";
 LEGACY_RSAPUBLIC_BLOB       = L"CAPIPUBLICBLOB";
 LEGACY_RSAPRIVATE_BLOB      = L"CAPIPRIVATEBLOB";

 BCRYPT_RSAPUBLIC_MAGIC      =0x31415352;  -- RSA1
 BCRYPT_RSAPRIVATE_MAGIC     =0x32415352;  -- RSA2

 BCRYPT_NO_KEY_VALIDATION    =0x00000008;

--[[
 The BCRYPT_RSAFULLPRIVATE_BLOB blob type is used to transport
 plaintext private RSA keys.  It includes the following values:
 Public Exponent
 Modulus
 Prime1
 Prime2
 Private Exponent mod (Prime1 - 1)
 Private Exponent mod (Prime2 - 1)
 Inverse of Prime2 mod Prime1
 PrivateExponent
--]]
 BCRYPT_RSAFULLPRIVATE_BLOB      =L"RSAFULLPRIVATEBLOB";

 BCRYPT_RSAFULLPRIVATE_MAGIC     =0x33415352;  -- RSA3

-- The BCRYPT_ECCPUBLIC_BLOB and BCRYPT_ECCPRIVATE_BLOB blob types are used
-- to transport plaintext ECC keys. These blob types will be supported by
-- all ECC primitive providers.
 BCRYPT_ECCPUBLIC_BLOB           =L"ECCPUBLICBLOB";
 BCRYPT_ECCPRIVATE_BLOB          =L"ECCPRIVATEBLOB";

 BCRYPT_ECDH_PUBLIC_P256_MAGIC   =0x314B4345;  -- ECK1
 BCRYPT_ECDH_PRIVATE_P256_MAGIC  =0x324B4345;  -- ECK2
 BCRYPT_ECDH_PUBLIC_P384_MAGIC   =0x334B4345;  -- ECK3
 BCRYPT_ECDH_PRIVATE_P384_MAGIC  =0x344B4345;  -- ECK4
 BCRYPT_ECDH_PUBLIC_P521_MAGIC   =0x354B4345;  -- ECK5
 BCRYPT_ECDH_PRIVATE_P521_MAGIC  =0x364B4345;  -- ECK6

 BCRYPT_ECDSA_PUBLIC_P256_MAGIC  =0x31534345;  -- ECS1
 BCRYPT_ECDSA_PRIVATE_P256_MAGIC =0x32534345;  -- ECS2
 BCRYPT_ECDSA_PUBLIC_P384_MAGIC  =0x33534345;  -- ECS3
 BCRYPT_ECDSA_PRIVATE_P384_MAGIC =0x34534345;  -- ECS4
 BCRYPT_ECDSA_PUBLIC_P521_MAGIC  =0x35534345;  -- ECS5
 BCRYPT_ECDSA_PRIVATE_P521_MAGIC =0x36534345;  -- ECS6

-- The BCRYPT_DH_PUBLIC_BLOB and BCRYPT_DH_PRIVATE_BLOB blob types are used
-- to transport plaintext DH keys. These blob types will be supported by
-- all DH primitive providers.
 BCRYPT_DH_PUBLIC_BLOB          = L"DHPUBLICBLOB";
 BCRYPT_DH_PRIVATE_BLOB         = L"DHPRIVATEBLOB";
 LEGACY_DH_PUBLIC_BLOB          = L"CAPIDHPUBLICBLOB";
 LEGACY_DH_PRIVATE_BLOB         = L"CAPIDHPRIVATEBLOB";

 BCRYPT_DH_PUBLIC_MAGIC         = 0x42504844;  -- DHPB
 BCRYPT_DH_PRIVATE_MAGIC        = 0x56504844;  -- DHPV

-- Property Strings for DH
 BCRYPT_DH_PARAMETERS           = L"DHParameters";

 BCRYPT_DH_PARAMETERS_MAGIC     = 0x4d504844;  -- DHPM

-- The BCRYPT_DSA_PUBLIC_BLOB and BCRYPT_DSA_PRIVATE_BLOB blob types are used
-- to transport plaintext DSA keys. These blob types will be supported by
-- all DSA primitive providers.
 BCRYPT_DSA_PUBLIC_BLOB         = L"DSAPUBLICBLOB";
 BCRYPT_DSA_PRIVATE_BLOB        = L"DSAPRIVATEBLOB";
 LEGACY_DSA_PUBLIC_BLOB         = L"CAPIDSAPUBLICBLOB";
 LEGACY_DSA_PRIVATE_BLOB        = L"CAPIDSAPRIVATEBLOB";
 LEGACY_DSA_V2_PUBLIC_BLOB      = L"V2CAPIDSAPUBLICBLOB";
 LEGACY_DSA_V2_PRIVATE_BLOB     = L"V2CAPIDSAPRIVATEBLOB";

 BCRYPT_DSA_PUBLIC_MAGIC        = 0x42505344;  -- DSPB
 BCRYPT_DSA_PRIVATE_MAGIC       = 0x56505344;  -- DSPV

 BCRYPT_KEY_DATA_BLOB_MAGIC      = 0x4d42444b; --Key Data Blob Magic (KDBM)

 BCRYPT_KEY_DATA_BLOB_VERSION1   = 0x1;

-- Property Strings for DSA
 BCRYPT_DSA_PARAMETERS       = L"DSAParameters";

 BCRYPT_DSA_PARAMETERS_MAGIC = 0x4d505344;  -- DSPM





-- Microsoft built-in providers.

 MS_PRIMITIVE_PROVIDER                   = L"Microsoft Primitive Provider";

-- Common algorithm identifiers.

 BCRYPT_RSA_ALGORITHM                    = L"RSA";
 BCRYPT_RSA_SIGN_ALGORITHM               = L"RSA_SIGN";

 BCRYPT_DH_ALGORITHM                     = L"DH";

 BCRYPT_DSA_ALGORITHM                    = L"DSA";
 BCRYPT_RC2_ALGORITHM                    = L"RC2";
 BCRYPT_RC4_ALGORITHM                    = L"RC4";


 BCRYPT_AES_ALGORITHM                    = L"AES";
 BCRYPT_AES_GMAC_ALGORITHM               = L"AES-GMAC";

 BCRYPT_DES_ALGORITHM                    = L"DES";
 BCRYPT_DESX_ALGORITHM                   = L"DESX";
 BCRYPT_3DES_ALGORITHM                   = L"3DES";
 BCRYPT_3DES_112_ALGORITHM               = L"3DES_112";


 BCRYPT_MD2_ALGORITHM                    = L"MD2";
 BCRYPT_MD4_ALGORITHM                    = L"MD4";
 BCRYPT_MD5_ALGORITHM                    = L"MD5";

 BCRYPT_SHA1_ALGORITHM                   = L"SHA1";
 BCRYPT_SHA256_ALGORITHM                 = L"SHA256";
 BCRYPT_SHA384_ALGORITHM                 = L"SHA384";
 BCRYPT_SHA512_ALGORITHM                 = L"SHA512";

 BCRYPT_ECDSA_P256_ALGORITHM             = L"ECDSA_P256";
 BCRYPT_ECDSA_P384_ALGORITHM             = L"ECDSA_P384";
 BCRYPT_ECDSA_P521_ALGORITHM             = L"ECDSA_P521";
 BCRYPT_ECDH_P256_ALGORITHM              = L"ECDH_P256";
 BCRYPT_ECDH_P384_ALGORITHM              = L"ECDH_P384";
 BCRYPT_ECDH_P521_ALGORITHM              = L"ECDH_P521";

 BCRYPT_RNG_ALGORITHM                    = L"RNG";
 BCRYPT_RNG_FIPS186_DSA_ALGORITHM        = L"FIPS186DSARNG";
 BCRYPT_RNG_DUAL_EC_ALGORITHM            = L"DUALECRNG";


-- Interfaces


 BCRYPT_CIPHER_INTERFACE                = 0x00000001;
 BCRYPT_HASH_INTERFACE                  = 0x00000002;
 BCRYPT_ASYMMETRIC_ENCRYPTION_INTERFACE = 0x00000003;
 BCRYPT_SECRET_AGREEMENT_INTERFACE      = 0x00000004;
 BCRYPT_SIGNATURE_INTERFACE             = 0x00000005;
 BCRYPT_RNG_INTERFACE                   = 0x00000006;

 BCRYPT_ALG_HANDLE_HMAC_FLAG    = 0x00000008;

-- AlgOperations flags for use with BCryptEnumAlgorithms()
 BCRYPT_CIPHER_OPERATION                = 0x00000001;
 BCRYPT_HASH_OPERATION                  = 0x00000002;
 BCRYPT_ASYMMETRIC_ENCRYPTION_OPERATION = 0x00000004;
 BCRYPT_SECRET_AGREEMENT_OPERATION      = 0x00000008;
 BCRYPT_SIGNATURE_OPERATION             = 0x00000010;
 BCRYPT_RNG_OPERATION                   = 0x00000020;


-- Flags for use with BCryptGetProperty and BCryptSetProperty
 BCRYPT_PUBLIC_KEY_FLAG                 = 0x00000001;
 BCRYPT_PRIVATE_KEY_FLAG                = 0x00000002;








BCRYPT_IS_INTERFACE_VERSION_COMPATIBLE = function(loader, provider)
    return (loader.MajorVersion <= provider.MajorVersion)
end;

--
-- Primitive provider interfaces.
--
BCRYPT_CIPHER_INTERFACE_VERSION_1  					= BCRYPT_MAKE_INTERFACE_VERSION(1,0);
BCRYPT_HASH_INTERFACE_VERSION_1   					= BCRYPT_MAKE_INTERFACE_VERSION(1,0);
BCRYPT_ASYMMETRIC_ENCRYPTION_INTERFACE_VERSION_1   	= BCRYPT_MAKE_INTERFACE_VERSION(1,0);
BCRYPT_SECRET_AGREEMENT_INTERFACE_VERSION_1  		= BCRYPT_MAKE_INTERFACE_VERSION(1,0);
BCRYPT_SIGNATURE_INTERFACE_VERSION_1   				= BCRYPT_MAKE_INTERFACE_VERSION(1,0);
BCRYPT_RNG_INTERFACE_VERSION_1   					= BCRYPT_MAKE_INTERFACE_VERSION(1,0);


--[[
	CryptoConfig Definitions
--]]

-- Interface registration flags
 CRYPT_MIN_DEPENDENCIES     = (0x00000001);
 CRYPT_PROCESS_ISOLATE      = (0x00010000); -- User-mode only

-- Processor modes supported by a provider
--
-- (Valid for BCryptQueryProviderRegistration and BCryptResolveProviders):
--
CRYPT_UM                   = (0x00000001);    -- User mode only
CRYPT_KM                   = (0x00000002);    -- Kernel mode only
CRYPT_MM                   = (0x00000003);    -- Multi-mode: Must support BOTH UM and KM
--
-- (Valid only for BCryptQueryProviderRegistration):
--
CRYPT_ANY                  = (0x00000004);    -- Wildcard: Either UM, or KM, or both


-- Write behavior flags
CRYPT_OVERWRITE            = (0x00000001);

-- Configuration tables
CRYPT_LOCAL                = (0x00000001);
CRYPT_DOMAIN               = (0x00000002);

-- Context configuration flags
CRYPT_EXCLUSIVE            = (0x00000001);
CRYPT_OVERRIDE             = (0x00010000); -- Enterprise table only

-- Resolution and enumeration flags
CRYPT_ALL_FUNCTIONS        = (0x00000001);
CRYPT_ALL_PROVIDERS        = (0x00000002);

-- Priority list positions
CRYPT_PRIORITY_TOP         = (0x00000000);
CRYPT_PRIORITY_BOTTOM      = (0xFFFFFFFF);

-- Default system-wide context
CRYPT_DEFAULT_CONTEXT      = L"Default";

	Lib = BCLib;

}





-- From BCrypt.h







ffi.cdef[[
//
// BCrypt structs
//

typedef struct __BCRYPT_KEY_LENGTHS_STRUCT
{
    ULONG   dwMinLength;
    ULONG   dwMaxLength;
    ULONG   dwIncrement;
} BCRYPT_KEY_LENGTHS_STRUCT;

typedef BCRYPT_KEY_LENGTHS_STRUCT BCRYPT_AUTH_TAG_LENGTHS_STRUCT;

typedef struct _BCRYPT_OID
{
    ULONG   cbOID;
    PUCHAR  pbOID;
} BCRYPT_OID;

typedef struct _BCRYPT_OID_LIST
{
    ULONG       dwOIDCount;
    BCRYPT_OID  *pOIDs;
} BCRYPT_OID_LIST;

typedef struct _BCRYPT_PKCS1_PADDING_INFO
{
    LPCWSTR pszAlgId;
} BCRYPT_PKCS1_PADDING_INFO;

typedef struct _BCRYPT_PSS_PADDING_INFO
{
    LPCWSTR pszAlgId;
    ULONG   cbSalt;
} BCRYPT_PSS_PADDING_INFO;

typedef struct _BCRYPT_OAEP_PADDING_INFO
{
    LPCWSTR pszAlgId;
    PUCHAR   pbLabel;
    ULONG   cbLabel;
} BCRYPT_OAEP_PADDING_INFO;




typedef struct _BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO
{
    ULONG       cbSize;
    ULONG       dwInfoVersion;
    PUCHAR      pbNonce;
    ULONG       cbNonce;
    PUCHAR      pbAuthData;
    ULONG       cbAuthData;
    PUCHAR      pbTag;
    ULONG       cbTag;
    PUCHAR      pbMacContext;
    ULONG       cbMacContext;
    ULONG       cbAAD;
    ULONGLONG   cbData;
    ULONG       dwFlags;
} BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO, *PBCRYPT_AUTHENTICATED_CIPHER_MODE_INFO;





typedef struct _BCryptBuffer {
    ULONG   cbBuffer;             // Length of buffer, in bytes
    ULONG   BufferType;           // Buffer type
    PVOID   pvBuffer;             // Pointer to buffer
} BCryptBuffer, * PBCryptBuffer;

typedef struct _BCryptBufferDesc {
    ULONG   ulVersion;            // Version number
    ULONG   cBuffers;             // Number of buffers
    PBCryptBuffer pBuffers;       // Pointer to array of buffers
} BCryptBufferDesc, * PBCryptBufferDesc;


//
// Primitive handles
//

typedef PVOID BCRYPT_HANDLE;
typedef PVOID BCRYPT_ALG_HANDLE;
typedef PVOID BCRYPT_KEY_HANDLE;
typedef PVOID BCRYPT_HASH_HANDLE;
typedef PVOID BCRYPT_SECRET_HANDLE;





typedef struct _BCRYPT_KEY_BLOB
{
    ULONG   Magic;
} BCRYPT_KEY_BLOB;

typedef struct _BCRYPT_RSAKEY_BLOB
{
    ULONG   Magic;
    ULONG   BitLength;
    ULONG   cbPublicExp;
    ULONG   cbModulus;
    ULONG   cbPrime1;
    ULONG   cbPrime2;
} BCRYPT_RSAKEY_BLOB;

typedef struct _BCRYPT_ECCKEY_BLOB
{
    ULONG   dwMagic;
    ULONG   cbKey;
} BCRYPT_ECCKEY_BLOB, *PBCRYPT_ECCKEY_BLOB;

typedef struct _BCRYPT_DH_KEY_BLOB
{
    ULONG   dwMagic;
    ULONG   cbKey;
} BCRYPT_DH_KEY_BLOB, *PBCRYPT_DH_KEY_BLOB;

typedef struct _BCRYPT_DH_PARAMETER_HEADER
{
    ULONG           cbLength;
    ULONG           dwMagic;
    ULONG           cbKeyLength;
} BCRYPT_DH_PARAMETER_HEADER;

typedef struct _BCRYPT_DSA_KEY_BLOB
{
    ULONG   dwMagic;
    ULONG   cbKey;
    UCHAR   Count[4];
    UCHAR   Seed[20];
    UCHAR   q[20];
} BCRYPT_DSA_KEY_BLOB, *PBCRYPT_DSA_KEY_BLOB;

typedef struct _BCRYPT_KEY_DATA_BLOB_HEADER
{
    ULONG   dwMagic;
    ULONG   dwVersion;
    ULONG   cbKeyData;
} BCRYPT_KEY_DATA_BLOB_HEADER, *PBCRYPT_KEY_DATA_BLOB_HEADER;

typedef struct _BCRYPT_DSA_PARAMETER_HEADER
{
    ULONG           cbLength;
    ULONG           dwMagic;
    ULONG           cbKeyLength;
    UCHAR           Count[4];
    UCHAR           Seed[20];
    UCHAR           q[20];
} BCRYPT_DSA_PARAMETER_HEADER;


//
// Primitive algorithm provider functions.
//

NTSTATUS BCryptOpenAlgorithmProvider(BCRYPT_ALG_HANDLE   *phAlgorithm,
	LPCWSTR pszAlgId,
	LPCWSTR pszImplementation,
	ULONG   dwFlags);



// USE EXTREME CAUTION: editing comments that contain "certenrolls_*" tokens
// could break building CertEnroll idl files:
// certenrolls_begin -- BCRYPT_ALGORITHM_IDENTIFIER
typedef struct _BCRYPT_ALGORITHM_IDENTIFIER
{
    LPWSTR  pszName;
    ULONG   dwClass;
    ULONG   dwFlags;

} BCRYPT_ALGORITHM_IDENTIFIER;
// certenrolls_end


NTSTATUS BCryptEnumAlgorithms(
        ULONG   dwAlgOperations,
       ULONG   *pAlgCount,
       BCRYPT_ALGORITHM_IDENTIFIER **ppAlgList,
        ULONG   dwFlags);

typedef struct _BCRYPT_PROVIDER_NAME
{
    LPWSTR  pszProviderName;
} BCRYPT_PROVIDER_NAME;


NTSTATUS BCryptEnumProviders(
	LPCWSTR pszAlgId,
	ULONG   *pImplCount,
	BCRYPT_PROVIDER_NAME    **ppImplList,
	ULONG   dwFlags);

NTSTATUS BCryptGetProperty(BCRYPT_HANDLE   hObject,
	LPCWSTR pszProperty,
    PUCHAR   pbOutput,
	ULONG   cbOutput,
	ULONG   *pcbResult,
	ULONG   dwFlags);

NTSTATUS BCryptSetProperty(
    BCRYPT_HANDLE   hObject,
	LPCWSTR pszProperty,
    PUCHAR   pbInput,
	ULONG   cbInput,
	ULONG   dwFlags);

NTSTATUS BCryptCloseAlgorithmProvider(BCRYPT_ALG_HANDLE   hAlgorithm, ULONG   dwFlags);

void BCryptFreeBuffer(PVOID   pvBuffer);


//
// Primitive encryption functions.
//

NTSTATUS BCryptGenerateSymmetricKey(BCRYPT_ALG_HANDLE   hAlgorithm,
	BCRYPT_KEY_HANDLE   *phKey,
    PUCHAR   pbKeyObject,
    ULONG   cbKeyObject,
    PUCHAR   pbSecret,
    ULONG   cbSecret,
    ULONG   dwFlags);

NTSTATUS BCryptGenerateKeyPair(BCRYPT_ALG_HANDLE   hAlgorithm,
       BCRYPT_KEY_HANDLE   *phKey,
        ULONG   dwLength,
        ULONG   dwFlags);

NTSTATUS BCryptEncrypt(BCRYPT_KEY_HANDLE hKey,
    PUCHAR   pbInput,
	ULONG   cbInput,
	void    *pPaddingInfo,
    PUCHAR   pbIV,
	ULONG   cbIV,
    PUCHAR   pbOutput,
	ULONG   cbOutput,
	ULONG   *pcbResult,
	ULONG   dwFlags);



NTSTATUS BCryptDecrypt(BCRYPT_KEY_HANDLE   hKey,
    PUCHAR   pbInput,
	ULONG   cbInput,
	void    *pPaddingInfo,
    PUCHAR   pbIV,
	ULONG   cbIV,
    PUCHAR   pbOutput,
	ULONG   cbOutput,
	ULONG   *pcbResult,
	ULONG   dwFlags);



NTSTATUS BCryptExportKey(BCRYPT_KEY_HANDLE   hKey,
	BCRYPT_KEY_HANDLE   hExportKey,
	LPCWSTR pszBlobType,
    PUCHAR   pbOutput,
	ULONG   cbOutput,
	ULONG   *pcbResult,
	ULONG   dwFlags);



NTSTATUS BCryptImportKey(BCRYPT_ALG_HANDLE hAlgorithm,
	BCRYPT_KEY_HANDLE hImportKey,
	LPCWSTR pszBlobType,
	BCRYPT_KEY_HANDLE *phKey,
    PUCHAR   pbKeyObject,
	ULONG   cbKeyObject,
    PUCHAR   pbInput,
	ULONG   cbInput,
	ULONG   dwFlags);


NTSTATUS BCryptImportKeyPair(BCRYPT_ALG_HANDLE hAlgorithm,
	BCRYPT_KEY_HANDLE hImportKey,
	LPCWSTR pszBlobType,
	BCRYPT_KEY_HANDLE *phKey,
    PUCHAR   pbInput,
	ULONG   cbInput,
	ULONG   dwFlags);



NTSTATUS BCryptDuplicateKey(BCRYPT_KEY_HANDLE   hKey,
	BCRYPT_KEY_HANDLE   *phNewKey,
    PUCHAR   pbKeyObject,
	ULONG   cbKeyObject,
	ULONG   dwFlags);

NTSTATUS BCryptFinalizeKeyPair(BCRYPT_KEY_HANDLE   hKey, ULONG   dwFlags);

NTSTATUS BCryptDestroyKey(BCRYPT_KEY_HANDLE   hKey);

NTSTATUS BCryptDestroySecret(BCRYPT_SECRET_HANDLE   hSecret);

NTSTATUS BCryptSignHash(BCRYPT_KEY_HANDLE   hKey,
    void    *pPaddingInfo,
    PUCHAR   pbInput,
    ULONG   cbInput,
    PUCHAR   pbOutput,
    ULONG   cbOutput,
    ULONG   *pcbResult,
    ULONG   dwFlags);



NTSTATUS BCryptVerifySignature(BCRYPT_KEY_HANDLE   hKey,
	void    *pPaddingInfo,
    PUCHAR   pbHash,
	ULONG   cbHash,
    PUCHAR   pbSignature,
	ULONG   cbSignature,
	ULONG   dwFlags);



NTSTATUS BCryptSecretAgreement(
	BCRYPT_KEY_HANDLE       hPrivKey,
	BCRYPT_KEY_HANDLE       hPubKey,
	BCRYPT_SECRET_HANDLE    *phAgreedSecret,
	ULONG                   dwFlags);



NTSTATUS BCryptDeriveKey(
	BCRYPT_SECRET_HANDLE hSharedSecret,
	LPCWSTR              pwszKDF,
	BCryptBufferDesc     *pParameterList,
    PUCHAR pbDerivedKey,
	ULONG                cbDerivedKey,
	ULONG                *pcbResult,
	ULONG                dwFlags);


	typedef struct BCryptKey
	{
		BCRYPT_KEY_HANDLE Handle;
	}BCryptKey;
]]





ffi.cdef[[
//
// Primitive hashing functions.
//

NTSTATUS BCryptCreateHash(
    BCRYPT_ALG_HANDLE   hAlgorithm,
    BCRYPT_HASH_HANDLE  *phHash,
    PUCHAR   pbHashObject,
    ULONG   cbHashObject,
    PUCHAR   pbSecret,   // optional
    ULONG   cbSecret,   // optional
    ULONG   dwFlags);



NTSTATUS BCryptHashData(
    BCRYPT_HASH_HANDLE  hHash,
    PCUCHAR   pbInput,
	ULONG   cbInput,
	ULONG   dwFlags);



NTSTATUS BCryptFinishHash(
    BCRYPT_HASH_HANDLE hHash,
    PCUCHAR   pbOutput,
	ULONG   cbOutput,
	ULONG   dwFlags);



NTSTATUS BCryptDuplicateHash(
	BCRYPT_HASH_HANDLE  hHash,
	BCRYPT_HASH_HANDLE  *phNewHash,
    PUCHAR   pbHashObject,
	ULONG   cbHashObject,
	ULONG   dwFlags);


NTSTATUS BCryptDestroyHash(BCRYPT_HASH_HANDLE  hHash);

typedef struct {
	BCRYPT_HASH_HANDLE	Handle;
}BCryptHash;
]]





ffi.cdef[[
//
// Primitive random number generation.
//

NTSTATUS BCryptGenRandom(BCRYPT_ALG_HANDLE   hAlgorithm,
    PUCHAR  pbBuffer,
	ULONG   cbBuffer,
	ULONG   dwFlags);


//
// Primitive key derivation functions.
//

NTSTATUS BCryptDeriveKeyCapi(BCRYPT_HASH_HANDLE  hHash,
	BCRYPT_ALG_HANDLE   hTargetAlg,
    PUCHAR              pbDerivedKey,
	ULONG               cbDerivedKey,
	ULONG               dwFlags);



NTSTATUS BCryptDeriveKeyPBKDF2(
	BCRYPT_ALG_HANDLE   hPrf,
    PUCHAR              pbPassword,
	ULONG               cbPassword,
    PUCHAR              pbSalt,
	ULONG               cbSalt,
	ULONGLONG           cIterations,
    PUCHAR              pbDerivedKey,
	ULONG               cbDerivedKey,
	ULONG               dwFlags);


//
// Interface version control...
//
typedef struct _BCRYPT_INTERFACE_VERSION
{
    USHORT MajorVersion;
    USHORT MinorVersion;
} BCRYPT_INTERFACE_VERSION, *PBCRYPT_INTERFACE_VERSION;
]]




ffi.cdef[[
//////////////////////////////////////////////////////////////////////////////
// CryptoConfig Structures ///////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

//
// Provider Registration Structures
//

typedef struct _CRYPT_INTERFACE_REG
{
    ULONG dwInterface;
    ULONG dwFlags;

    ULONG cFunctions;
    PWSTR *rgpszFunctions;
}
CRYPT_INTERFACE_REG, *PCRYPT_INTERFACE_REG;

typedef struct _CRYPT_IMAGE_REG
{
    PWSTR pszImage;

    ULONG cInterfaces;
    PCRYPT_INTERFACE_REG *rgpInterfaces;
}
CRYPT_IMAGE_REG, *PCRYPT_IMAGE_REG;

typedef struct _CRYPT_PROVIDER_REG
{
    ULONG cAliases;
    PWSTR *rgpszAliases;

    PCRYPT_IMAGE_REG pUM;
    PCRYPT_IMAGE_REG pKM;
}
CRYPT_PROVIDER_REG, *PCRYPT_PROVIDER_REG;

typedef struct _CRYPT_PROVIDERS
{
    ULONG cProviders;
    PWSTR *rgpszProviders;
}
CRYPT_PROVIDERS, *PCRYPT_PROVIDERS;

//
// Context Configuration Structures
//

typedef struct _CRYPT_CONTEXT_CONFIG
{
    ULONG dwFlags;
    ULONG dwReserved;
}
CRYPT_CONTEXT_CONFIG, *PCRYPT_CONTEXT_CONFIG;

typedef struct _CRYPT_CONTEXT_FUNCTION_CONFIG
{
    ULONG dwFlags;
    ULONG dwReserved;
}
CRYPT_CONTEXT_FUNCTION_CONFIG, *PCRYPT_CONTEXT_FUNCTION_CONFIG;

typedef struct _CRYPT_CONTEXTS
{
    ULONG cContexts;
    PWSTR *rgpszContexts;
}
CRYPT_CONTEXTS, *PCRYPT_CONTEXTS;

typedef struct _CRYPT_CONTEXT_FUNCTIONS
{
    ULONG cFunctions;
    PWSTR *rgpszFunctions;
}
CRYPT_CONTEXT_FUNCTIONS, *PCRYPT_CONTEXT_FUNCTIONS;

typedef struct _CRYPT_CONTEXT_FUNCTION_PROVIDERS
{
    ULONG cProviders;
    PWSTR *rgpszProviders;
}
CRYPT_CONTEXT_FUNCTION_PROVIDERS, *PCRYPT_CONTEXT_FUNCTION_PROVIDERS;

//
// Provider Resolution Structures
//

typedef struct _CRYPT_PROPERTY_REF
{
    PWSTR pszProperty;

    ULONG cbValue;
    PUCHAR pbValue;
}
CRYPT_PROPERTY_REF, *PCRYPT_PROPERTY_REF;

typedef struct _CRYPT_IMAGE_REF
{
    PWSTR pszImage;
    ULONG dwFlags;
}
CRYPT_IMAGE_REF, *PCRYPT_IMAGE_REF;

typedef struct _CRYPT_PROVIDER_REF
{
    ULONG dwInterface;
    PWSTR pszFunction;
    PWSTR pszProvider;

    ULONG cProperties;
    PCRYPT_PROPERTY_REF *rgpProperties;

    PCRYPT_IMAGE_REF pUM;
    PCRYPT_IMAGE_REF pKM;
}
CRYPT_PROVIDER_REF, *PCRYPT_PROVIDER_REF;

typedef struct _CRYPT_PROVIDER_REFS
{
    ULONG cProviders;
    PCRYPT_PROVIDER_REF *rgpProviders;
}
CRYPT_PROVIDER_REFS, *PCRYPT_PROVIDER_REFS;



//////////////////////////////////////////////////////////////////////////////
// CryptoConfig Functions ////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////




NTSTATUS BCryptQueryProviderRegistration(LPCWSTR pszProvider,
    ULONG dwMode,
    ULONG dwInterface,
    ULONG* pcbBuffer,
    PCRYPT_PROVIDER_REG *ppBuffer);


NTSTATUS BCryptEnumRegisteredProviders(ULONG* pcbBuffer, PCRYPT_PROVIDERS *ppBuffer);

//
// Context Configuration Functions
//

NTSTATUS BCryptCreateContext(
     ULONG dwTable,
     LPCWSTR pszContext,
     PCRYPT_CONTEXT_CONFIG pConfig); // Optional


NTSTATUS BCryptDeleteContext(ULONG dwTable, LPCWSTR pszContext);


NTSTATUS BCryptEnumContexts(ULONG dwTable,
    ULONG* pcbBuffer,
    PCRYPT_CONTEXTS *ppBuffer);


NTSTATUS BCryptConfigureContext(ULONG dwTable,
     LPCWSTR pszContext,
     PCRYPT_CONTEXT_CONFIG pConfig);


NTSTATUS BCryptQueryContextConfiguration(ULONG dwTable,
    LPCWSTR pszContext,
    ULONG* pcbBuffer,
    PCRYPT_CONTEXT_CONFIG *ppBuffer);


NTSTATUS BCryptAddContextFunction(ULONG dwTable,
	LPCWSTR pszContext,
    ULONG dwInterface,
    LPCWSTR pszFunction,
    ULONG dwPosition);


NTSTATUS BCryptRemoveContextFunction(ULONG dwTable,
    LPCWSTR pszContext,
    ULONG dwInterface,
    LPCWSTR pszFunction);


NTSTATUS BCryptEnumContextFunctions(ULONG dwTable,
    LPCWSTR pszContext,
    ULONG dwInterface,
    ULONG* pcbBuffer,
    PCRYPT_CONTEXT_FUNCTIONS *ppBuffer);


NTSTATUS BCryptConfigureContextFunction(ULONG dwTable,
    LPCWSTR pszContext,
    ULONG dwInterface,
    LPCWSTR pszFunction,
    PCRYPT_CONTEXT_FUNCTION_CONFIG pConfig);


NTSTATUS BCryptQueryContextFunctionConfiguration(ULONG dwTable,
    LPCWSTR pszContext,
    ULONG dwInterface,
    LPCWSTR pszFunction,
    ULONG* pcbBuffer,
    PCRYPT_CONTEXT_FUNCTION_CONFIG *ppBuffer);


NTSTATUS BCryptEnumContextFunctionProviders(ULONG dwTable,
    LPCWSTR pszContext,
    ULONG dwInterface,
    LPCWSTR pszFunction,
    ULONG* pcbBuffer,
    PCRYPT_CONTEXT_FUNCTION_PROVIDERS *ppBuffer);


NTSTATUS BCryptSetContextFunctionProperty(ULONG dwTable,
    LPCWSTR pszContext,
    ULONG dwInterface,
    LPCWSTR pszFunction,
    LPCWSTR pszProperty,
    ULONG cbValue,
    PUCHAR pbValue);


NTSTATUS BCryptQueryContextFunctionProperty(ULONG dwTable,
    LPCWSTR pszContext,
    ULONG dwInterface,
    LPCWSTR pszFunction,
    LPCWSTR pszProperty,
    ULONG* pcbValue,
    PUCHAR *ppbValue);


//
// Configuration Change Notification Functions
//
NTSTATUS BCryptRegisterConfigChangeNotify(HANDLE *phEvent);

NTSTATUS BCryptUnregisterConfigChangeNotify(HANDLE hEvent);


//
// Provider Resolution Functions
//

NTSTATUS BCryptResolveProviders(
     LPCWSTR pszContext,
     ULONG dwInterface,
     LPCWSTR pszFunction,
     LPCWSTR pszProvider,
     ULONG dwMode,
     ULONG dwFlags,
     ULONG* pcbBuffer,
    PCRYPT_PROVIDER_REFS *ppBuffer);

//
// Miscellaneous queries about the crypto environment
//
NTSTATUS BCryptGetFipsAlgorithmMode(BOOLEAN *pfEnabled);
]]




ffi.cdef[[
typedef struct BCryptAlgorithm {
	BCRYPT_ALG_HANDLE Handle;
} BCryptAlgorithm
]]


return BCrypt

--[[

	The core definitions in this file come from the original
	Windows SDK file bcrypt.h, which contained the
	following copyright.

//+---------------------------------------------------------------------------
//
//  Microsoft Windows
//  Copyright (C) Microsoft Corporation, 2004.
//
//  File:       bcrypt.h
//
//  Contents:   Cryptographic Primitive API Prototypes and Definitions
//
//----------------------------------------------------------------------------
--]]