local ffi = require "ffi"
local bit = require "bit"
local bor = bit.bor
local band = bit.band
local rshift = bit.rshift
local lshift = bit.lshift


local WTypes = require("WTypes");
local core_string = require("core_string_l1_1_0");
local errorhandling = require("core_errorhandling_l1_1_1");


local L = core_string.toUnicode;
local A = core_string.toAnsi;

local base64 = require "base64"
local MemoryStream = require "MemoryStream"
local BinaryStream = require "BinaryStream"


local Crypt32 = ffi.load("Crypt32");
local Advapi32 = ffi.load("Advapi32");
local Kernel32 = ffi.load("Kernel32");


ALG_TYPE_ANY = 0;
ALG_TYPE_BLOCK = lshift(3, 9);
ALG_CLASS_HASH = lshift(4, 13);
ALG_CLASS_DATA_ENCRYPT = lshift(3, 13);
ALG_SID_SHA1 = 4;
ALG_SID_3DES = 3;
ALG_SID_HMAC = 9;



local CERT_KEY_IDENTIFIER_PROP_ID = 20;

local MAX_SKI_LEN = 256;
local RPS_MAX_HASH_SIZE = 256;
local MAX_ENCRYPTED_KEY_SIZE = 1024;

local HP_ALGID = 1;
local HP_HASHVAL = 2;
local HP_HASHSIZE = 0x0004;
local HP_HMAC_INFO = 0x0005;


local CERT_STORE_OPEN_EXISTING_FLAG = 0x00004000;
local CERT_STORE_READONLY_FLAG = 0x00008000;
local CERT_SYSTEM_STORE_LOCAL_MACHINE_ID = 2;
local CERT_SYSTEM_STORE_LOCATION_SHIFT = 16;
local CERT_SYSTEM_STORE_LOCAL_MACHINE = lshift(CERT_SYSTEM_STORE_LOCAL_MACHINE_ID, CERT_SYSTEM_STORE_LOCATION_SHIFT);


--[[
Certificate comparison functions
--]]
local CERT_COMPARE_MASK           =0xFFFF
local CERT_COMPARE_SHIFT          =16

local CERT_COMPARE_ANY            =0
local CERT_COMPARE_SHA1_HASH      =1
local CERT_COMPARE_NAME           =2
local CERT_COMPARE_ATTR           =3
local CERT_COMPARE_MD5_HASH       =4
local CERT_COMPARE_PROPERTY       =5
local CERT_COMPARE_PUBLIC_KEY     =6
local CERT_COMPARE_HASH           =CERT_COMPARE_SHA1_HASH
local CERT_COMPARE_NAME_STR_A     =7
local CERT_COMPARE_NAME_STR_W     =8
local CERT_COMPARE_KEY_SPEC       =9
local CERT_COMPARE_ENHKEY_USAGE   =10
local CERT_COMPARE_CTL_USAGE      =CERT_COMPARE_ENHKEY_USAGE
local CERT_COMPARE_SUBJECT_CERT   =11
local CERT_COMPARE_ISSUER_OF      =12
local CERT_COMPARE_EXISTING       =13
local CERT_COMPARE_SIGNATURE_HASH =14
local CERT_COMPARE_KEY_IDENTIFIER =15
local CERT_COMPARE_CERT_ID        =16
local CERT_COMPARE_CROSS_CERT_DIST_POINTS =17
local CERT_COMPARE_PUBKEY_MD5_HASH =18
local CERT_COMPARE_SUBJECT_INFO_ACCESS =19





		 --byte[] ENC_DATA_STRING = new ASCIIEncoding().GetBytes("Encryption");
		 --byte[] KHASH_DATA_STRING = new ASCIIEncoding().GetBytes("Key Hash");



local PKCS5_PADDING = 1;


local SIMPLEBLOB = 0x1;
local PRIVATEKEYBLOB = 0x7;

local PP_ENUMALGS_EX = 22;

--[[
  Predefined X509 certificate data structures that can be encoded / decoded.
--]]

 CRYPT_ENCODE_DECODE_NONE            = nil
 X509_CERT                           = ffi.cast("LPCSTR", 1);
 X509_CERT_TO_BE_SIGNED              = ffi.cast("LPCSTR", 2);
 X509_CERT_CRL_TO_BE_SIGNED          = ffi.cast("LPCSTR", 3);
 X509_CERT_REQUEST_TO_BE_SIGNED      = ffi.cast("LPCSTR", 4);
 X509_EXTENSIONS                     = ffi.cast("LPCSTR", 5);
 X509_NAME_VALUE                     = ffi.cast("LPCSTR", 6);
 X509_NAME                           = ffi.cast("LPCSTR", 7);
 X509_PUBLIC_KEY_INFO                = ffi.cast("LPCSTR", 8);



local WinCrypt = {
	NTE_BAD_LEN				= 0x80090004;
	NTE_BAD_DATA			= 0x80090005;
	NTE_BAD_SIGNATURE		= 0x80090006;
	NTE_BAD_VER				= 0x80090007;
	NTE_BAD_ALGID           = 0x80090008;
	NTE_BAD_TYPE			= 0x8009000A;
	NTE_BAD_KEYSET			= 0x80090016;

	NTE_NO_KEY				= 0x8009000D;

	CRYPT_E_NOT_FOUND		= 0x80092004;
	CRYPT_E_SELF_SIGNED		= 0x80092007;
	CRYPT_E_NO_KEY_PROPERTY	= 0x8009200B;

	CRYPT_FIRST 			= 1;
	CRYPT_VERIFYCONTEXT 	= 0xF0000000;

	-- dwFlags for PFXImportCertStore
	CRYPT_EXPORTABLE			= 0x00000001;  -- CryptImportKey dwFlags
	CRYPT_USER_PROTECTED		= 0x00000002;  -- CryptImportKey dwFlags
	PKCS12_INCLUDE_EXTENDED_PROPERTIES = 0x0010;
	CRYPT_MACHINE_KEYSET		= 0x00000020;  -- CryptAcquireContext dwFlags
	PKCS12_PREFER_CNG_KSP       = 0x00000100;  -- prefer using CNG KSP
	PKCS12_ALWAYS_CNG_KSP       = 0x00000200;  -- always use CNG KSP
	CRYPT_USER_KEYSET           = 0x00001000;
	PKCS12_ALLOW_OVERWRITE_KEY  = 0x00004000;  -- allow overwrite existing key
	PKCS12_NO_PERSIST_KEY       = 0x00008000;  -- key will not be persisted
	PKCS12_IMPORT_RESERVED_MASK = 0xffff0000;


	CRYPT_NEWKEYSET = 8;


	-- dwFlag definitions for CryptSetProviderEx and CryptGetDefaultProvider
	CRYPT_MACHINE_DEFAULT   = 0x00000001;
	CRYPT_USER_DEFAULT      = 0x00000002;
	CRYPT_DELETE_DEFAULT    = 0x00000004;

	CALG_SHA1 = bor(ALG_CLASS_HASH, ALG_TYPE_ANY, ALG_SID_SHA1);
	CALG_3DES = bor(ALG_CLASS_DATA_ENCRYPT, ALG_TYPE_BLOCK, ALG_SID_3DES);
	CALG_HMAC = bor(ALG_CLASS_HASH, ALG_TYPE_ANY, ALG_SID_HMAC);

	PROV_RSA_FULL          = 1;
	PROV_RSA_SIG           = 2;
	PROV_DSS               = 3;
	PROV_FORTEZZA          = 4;
	PROV_MS_EXCHANGE       = 5;
	PROV_SSL               = 6;
	PROV_RSA_SCHANNEL      = 12;
	PROV_DSS_DH            = 13;
	PROV_EC_ECDSA_SIG      = 14;
	PROV_EC_ECNRA_SIG      = 15;
	PROV_EC_ECDSA_FULL     = 16;
	PROV_EC_ECNRA_FULL     = 17;
	PROV_DH_SCHANNEL       = 18;
	PROV_SPYRUS_LYNKS      = 20;
	PROV_RNG               = 21;
	PROV_INTEL_SEC         = 22;
	PROV_REPLACE_OWF       = 23;
	PROV_RSA_AES           = 24;

	-- Provider Friendly Names
	MS_DEF_PROV			= "Microsoft Base Cryptographic Provider v1.0";
	MS_DEF_PROV_W		= L"Microsoft Base Cryptographic Provider v1.0";

	MS_ENH_RSA_AES_PROV	= "Microsoft Enhanced RSA and AES Cryptographic Provider";

	MS_ENHANCED_PROV_A  = "Microsoft Enhanced Cryptographic Provider v1.0";
	MS_ENHANCED_PROV_W  = L"Microsoft Enhanced Cryptographic Provider v1.0";

	MS_SCARD_PROV_A		= "Microsoft Base Smart Card Crypto Provider";
	MS_SCARD_PROV_W		= L"Microsoft Base Smart Card Crypto Provider";




	AT_KEYEXCHANGE = 1;

	X509_ASN_ENCODING = 1;
	PKCS_7_ASN_ENCODING = 0x00010000;


	PLAINTEXTKEYBLOB = 0x8;
	CUR_BLOB_VERSION = 2;

	CRYPT_ACQUIRE_SILENT_FLAG = 0x00000040;
	CRYPT_ACQUIRE_COMPARE_KEY_FLAG = 0x00000004;

	CRYPT_DECRYPT_RSA_NO_PADDING_CHECK	= 0x00000020;	-- 32
	CRYPT_OAEP							= 0x00000040;	-- 64

	--[[
		dwFindType
	--]]
	CERT_FIND_ANY 		= lshift(CERT_COMPARE_ANY, CERT_COMPARE_SHIFT);
	CERT_FIND_PUBLIC_KEY = lshift(CERT_COMPARE_PUBLIC_KEY, CERT_COMPARE_SHIFT);


	--  Extension Object Identifiers
	szOID_AUTHORITY_KEY_IDENTIFIER  = "2.5.29.1";
	szOID_KEY_ATTRIBUTES            = "2.5.29.2";
	szOID_CERT_POLICIES_95          = "2.5.29.3";
	szOID_KEY_USAGE_RESTRICTION     = "2.5.29.4";
	szOID_SUBJECT_ALT_NAME          = "2.5.29.7";
	szOID_ISSUER_ALT_NAME           = "2.5.29.8";
	szOID_BASIC_CONSTRAINTS         = "2.5.29.10";
	szOID_KEY_USAGE                 = "2.5.29.15";
	szOID_PRIVATEKEY_USAGE_PERIOD   = "2.5.29.16";
	szOID_BASIC_CONSTRAINTS2        = "2.5.29.19";

	szOID_CERT_POLICIES             = "2.5.29.32";
	szOID_ANY_CERT_POLICY           = "2.5.29.32.0";
	szOID_INHIBIT_ANY_POLICY        = "2.5.29.54";

	szOID_AUTHORITY_KEY_IDENTIFIER2 = "2.5.29.35";
	szOID_SUBJECT_KEY_IDENTIFIER    = "2.5.29.14";
	szOID_SUBJECT_ALT_NAME2         = "2.5.29.17";
	szOID_ISSUER_ALT_NAME2          = "2.5.29.18";
	szOID_CRL_REASON_CODE           = "2.5.29.21";
	szOID_REASON_CODE_HOLD          = "2.5.29.23";
	szOID_CRL_DIST_POINTS           = "2.5.29.31";
	szOID_ENHANCED_KEY_USAGE        = "2.5.29.37";

	szOID_ANY_ENHANCED_KEY_USAGE    = "2.5.29.37.0";

	-- szOID_CRL_NUMBER -- Base CRLs only.  Monotonically increasing sequence
	-- number for each CRL issued by a CA.
	szOID_CRL_NUMBER                = "2.5.29.20";

	-- szOID_DELTA_CRL_INDICATOR -- Delta CRLs only.  Marked critical.
	-- Contains the minimum base CRL Number that can be used with a delta CRL.
	szOID_DELTA_CRL_INDICATOR       = "2.5.29.27";
	szOID_ISSUING_DIST_POINT        = "2.5.29.28";

	-- szOID_FRESHEST_CRL -- Base CRLs only.  Formatted identically to a CDP
	-- extension that holds URLs to fetch the delta CRL.
	szOID_FRESHEST_CRL              = "2.5.29.46";
	szOID_NAME_CONSTRAINTS          = "2.5.29.30";

	-- Note on 1/1/2000 szOID_POLICY_MAPPINGS was changed from "2.5.29.5";
	szOID_POLICY_MAPPINGS           = "2.5.29.33";
	szOID_LEGACY_POLICY_MAPPINGS    = "2.5.29.5";
	szOID_POLICY_CONSTRAINTS        = "2.5.29.36";



	-- Following are the definitions of various algorithm object identifiers
	-- RSA
	szOID_RSA              = "1.2.840.113549";
	szOID_PKCS             = "1.2.840.113549.1";
	szOID_RSA_HASH         = "1.2.840.113549.2";
	szOID_RSA_ENCRYPT      = "1.2.840.113549.3";

	szOID_RSA_RSA          = "1.2.840.113549.1.1.1";
	szOID_RSA_MD2RSA       = "1.2.840.113549.1.1.2";
	szOID_RSA_MD4RSA       = "1.2.840.113549.1.1.3";
	szOID_RSA_MD5RSA       = "1.2.840.113549.1.1.4";
	szOID_RSA_SHA1RSA      = "1.2.840.113549.1.1.5";
	szOID_RSA_SETOAEP_RSA  = "1.2.840.113549.1.1.6";






	sz_CERT_STORE_PROV_SYSTEM = "System";


	-- CryptSetKeyParam
	CRYPT_MODE_CBC = 1;

	KP_IV = 1;
	KP_PADDING = 3;
	KP_MODE = 4;
	KP_ALGID = 7;
	KP_BLOCKLEN = 8;
	KP_KEYLEN = 9;

}


ffi.cdef[[
typedef void *			HCERTSTORE;
typedef void *			HCRYPTPROV;
typedef HCRYPTPROV	*	PHCRYPTPROV;
typedef void *			HCRYPTKEY;
typedef void *			HCRYPTHASH;
typedef void *			HCRYPTPROV_OR_NCRYPT_KEY_HANDLE;

typedef uint32_t ALG_ID;

]]

ffi.cdef[[
//+-------------------------------------------------------------------------
//  CRYPTOAPI BLOB definitions
//--------------------------------------------------------------------------

typedef struct _CRYPTOAPI_BLOB {
	DWORD   cbData;
    BYTE    *pbData;
} CRYPT_INTEGER_BLOB, *PCRYPT_INTEGER_BLOB,
CRYPT_UINT_BLOB, *PCRYPT_UINT_BLOB,
CRYPT_OBJID_BLOB, *PCRYPT_OBJID_BLOB,
CERT_NAME_BLOB, *PCERT_NAME_BLOB,
CERT_RDN_VALUE_BLOB, *PCERT_RDN_VALUE_BLOB,
CERT_BLOB, *PCERT_BLOB,
CRL_BLOB, *PCRL_BLOB,
DATA_BLOB, *PDATA_BLOB,
CRYPT_DATA_BLOB, *PCRYPT_DATA_BLOB,
CRYPT_HASH_BLOB, *PCRYPT_HASH_BLOB,
CRYPT_DIGEST_BLOB, *PCRYPT_DIGEST_BLOB,
CRYPT_DER_BLOB, *PCRYPT_DER_BLOB,
CRYPT_ATTR_BLOB, *PCRYPT_ATTR_BLOB;

//+-------------------------------------------------------------------------
//  In a CRYPT_BIT_BLOB the last byte may contain 0-7 unused bits. Therefore, the
//  overall bit length is cbData * 8 - cUnusedBits.
//--------------------------------------------------------------------------
typedef struct _CRYPT_BIT_BLOB {
    DWORD   cbData;
    BYTE    *pbData;
    DWORD   cUnusedBits;
} CRYPT_BIT_BLOB, *PCRYPT_BIT_BLOB;
]]

ffi.cdef[[
//+-------------------------------------------------------------------------
//  Type used for any algorithm
//
//  Where the Parameters CRYPT_OBJID_BLOB is in its encoded representation. For most
//  algorithm types, the Parameters CRYPT_OBJID_BLOB is NULL (Parameters.cbData = 0).
//--------------------------------------------------------------------------
typedef struct _CRYPT_ALGORITHM_IDENTIFIER {
    LPSTR               pszObjId;
    CRYPT_OBJID_BLOB    Parameters;
} CRYPT_ALGORITHM_IDENTIFIER, *PCRYPT_ALGORITHM_IDENTIFIER;

]]

ffi.cdef[[
// Advapi32
BOOL CryptAcquireContextW(HCRYPTPROV *phProv, LPCTSTR pszContainer, LPCTSTR pszProvider, DWORD dwProvType, DWORD dwFlags);
BOOL CryptAcquireContextA(HCRYPTPROV *phProv, LPCTSTR pszContainer, LPCTSTR pszProvider, DWORD dwProvType, DWORD dwFlags);
BOOL CryptGetUserKey(HCRYPTPROV hProv, DWORD dwKeySpec, HCRYPTKEY *phUserKey);
BOOL CryptImportKey(HCRYPTPROV hProv, BYTE *pbData, DWORD dwDataLen, HCRYPTKEY hPubKey, DWORD dwFlags, HCRYPTKEY *phKey);
BOOL CryptGenKey(HCRYPTPROV hProv, ALG_ID Algid, DWORD dwFlags, HCRYPTKEY *phKey);
BOOL CryptGetDefaultProviderA(DWORD dwProvType, DWORD *pdwReserved, DWORD dwFlags, LPTSTR pszProvName, DWORD *pcbProvName);

// Key related
BOOL CryptDecrypt(HCRYPTKEY hKey, HCRYPTHASH hHash, BOOL Final, DWORD dwFlags, BYTE *pbData, DWORD *pdwDataLen);
BOOL CryptDestroyKey(HCRYPTKEY hKey);
BOOL CryptSetKeyParam(HCRYPTKEY hKey, DWORD dwParam, const BYTE *pbData, DWORD dwFlags);

/*
	bool CryptCreateHash(IntPtr hProv, uint Algid, IntPtr hKey, uint dwFlags, out IntPtr phHash);
	bool CryptDestroyHash(IntPtr hHash);
	bool CryptHashData(IntPtr hHash, byte[] pbData, uint dwDataLen, uint dwFlags);
	bool CryptGetHashParam(IntPtr hHash, uint dwParam, IntPtr pbData, out uint pdwDataLen, uint dwFlags);
	bool CryptSetHashParam(IntPtr hHash, uint dwParam, byte[] pbData, uint dwFlags);
	bool CryptDuplicateHash(IntPtr hHash, IntPtr pdwReserved, uint dwFlags, out IntPtr phHash);

	bool CryptVerifySignature(IntPtr hHash, byte[] pbSignature, uint dwSigLen, IntPtr hPubKey, string sDescription, uint dwFlags);
	bool CryptGetUserKey(IntPtr hProv, uint dwKeySpec, out IntPtr phUserKe);
	bool CryptDeriveKey(IntPtr hProv, uint Algid, IntPtr hBaseData, uint dwFlags, out IntPtr phKey);
	bool CryptGetKeyParam(IntPtr hKey, uint dwParam, out uint pbData, out uint pdwDataLen, uint dwFlags);
	bool CryptDuplicateKey(IntPtr hKey, IntPtr pdwReserved, uint dwFlags, out IntPtr phKey);
	bool CryptImportKey(IntPtr hProv, byte[] pbData, uint dwDataLen, IntPtr hPubKey, uint dwFlags, out IntPtr phKey);
	bool CryptExportKey(IntPtr hKey, IntPtr hExpKey, uint dwBlobType, uint dwFlags, IntPtr pbData, out uint pdwDataLen);

	bool CryptGetProvParam(IntPtr hProv, uint dwParam, IntPtr pbData, out uint pdwDataLen, uint dwFlags);
	bool CryptGenRandom(IntPtr hProv, uint dwLen, IntPtr pbBuffer);
*/
]]

ffi.cdef[[
typedef struct {
	HCRYPTKEY	Handle;
} CryptoKey, *PCryptoKey;

]];

CryptoKey = ffi.typeof("CryptoKey");
CryptoKey_mt = {
	__gc = function(self)
		-- close the handle
		Advapi32.CryptDestroyKey(self.Handle);
	end,

	__new = function(ct, handle)
		if not handle then return nil end

		return ffi.new(ct, handle);
	end,

	__index = {
		SetParameter = function(self, dwParam, pbData, dwFlags)
			dwParam = dwParam or nil
			pbData = pbData or nil
			dwFlags = dwFlags or 0

			assert(dwParam, "CryptoKey(), no Parameter specified.")

			local dataptr = ffi.cast("const uint8_t *", pbData);
			local err = Advapi32.CryptSetKeyParam(self.Handle, dwParam, dataptr, dwFlags);

			if err ~= 0 then
				return true
			end

			return false, errorhandling.GetLastError();
		end,

		SetIv = function(self, iv)
			local success, err = self:SetParameter(WinCrypt.KP_IV, iv);

			if (not success) then
				assert(false, string.format("Could not set key Iv."));
			end

			return true

		end,

		SetMode = function(self, mode)
			local modev = ffi.new("int32_t[1]", mode);
			local success, err = self:SetParameter(WinCrypt.KP_MODE, modev);

			if (not success) then
				assert(false, string.format("Could not set key mode: %d.",mode));
			end

			return true
		end,

		Decrypt = function(self, pbData, dataLen)
			local hasher = nil
			local Final = true
			local dwFlags = 0
			local pdwDataLen = ffi.new("int32_t[1]", dataLen);

			local err = Advapi32.CryptDecrypt(self.Handle, hasher, Final, dwFlags, pbData, pdwDataLen);

			if err ~= 0 then
				return pdwDataLen[0]
			end

			return nil, errorhandling.GetLastError();
		end,
	},
}
CryptoKey = ffi.metatype(CryptoKey, CryptoKey_mt);


function CryptGetDefaultProvider(dwProvType)
	dwProvType = dwProvType or WinCrypt.PROV_RSA_FULL;
	local dwFlags = WinCrypt.CRYPT_USER_DEFAULT;
	local pszProvName = nil;
	local pcbProvName = ffi.new("int32_t[1]")

	-- first get the size of buffer
	local err = Advapi32.CryptGetDefaultProviderA(dwProvType, nil, dwFlags, pszProvName, pcbProvName);

	if err == 0 then
		return nil, errorhandling.GetLastError();
	end

	-- Now we have the size, so allocate buffer
	-- and retrieve string
	pszProvName = ffi.new("uint8_t[?]", pcbProvName[0]);
	err = Advapi32.CryptGetDefaultProviderA(dwProvType, nil, dwFlags, pszProvName, pcbProvName);

	if err == 0 then
		return nil, errorhandling.GetLastError();
	end

	return ffi.string(pszProvName, pcbProvName[0]-1);
end

ffi.cdef[[
//+-------------------------------------------------------------------------
//  Public Key Info
//
//  The PublicKey is the encoded representation of the information as it is
//  stored in the bit string
//--------------------------------------------------------------------------
typedef struct _CERT_PUBLIC_KEY_INFO {
    CRYPT_ALGORITHM_IDENTIFIER    Algorithm;
    CRYPT_BIT_BLOB                PublicKey;
} CERT_PUBLIC_KEY_INFO, *PCERT_PUBLIC_KEY_INFO;
]]

ffi.cdef[[
typedef struct _CERT_OTHER_NAME {
    LPSTR               pszObjId;
    CRYPT_OBJID_BLOB    Value;
} CERT_OTHER_NAME, *PCERT_OTHER_NAME;


typedef struct _CERT_ALT_NAME_ENTRY {
    DWORD   dwAltNameChoice;
    union {                                             // certenrolls_skip
        PCERT_OTHER_NAME            pOtherName;         // 1
        LPWSTR                      pwszRfc822Name;     // 2  (encoded IA5)
        LPWSTR                      pwszDNSName;        // 3  (encoded IA5)
        // Not implemented          x400Address;        // 4
        CERT_NAME_BLOB              DirectoryName;      // 5
        // Not implemented          pEdiPartyName;      // 6
        LPWSTR                      pwszURL;            // 7  (encoded IA5)
        CRYPT_DATA_BLOB             IPAddress;          // 8  (Octet String)
        LPSTR                       pszRegisteredID;    // 9  (Object Identifer)
    } DUMMYUNIONNAME;                                   // certenrolls_skip
} CERT_ALT_NAME_ENTRY, *PCERT_ALT_NAME_ENTRY;


typedef struct _CERT_ALT_NAME_INFO {
    DWORD                   cAltEntry;
    PCERT_ALT_NAME_ENTRY    rgAltEntry;
} CERT_ALT_NAME_INFO, *PCERT_ALT_NAME_INFO;

typedef struct _CERT_AUTHORITY_KEY_ID2_INFO {
    CRYPT_DATA_BLOB     KeyId;
    CERT_ALT_NAME_INFO  AuthorityCertIssuer;    // Optional, set cAltEntry
                                                // to 0 to omit.
    CRYPT_INTEGER_BLOB  AuthorityCertSerialNumber;
} CERT_AUTHORITY_KEY_ID2_INFO, *PCERT_AUTHORITY_KEY_ID2_INFO;

typedef struct _CERT_POLICY_ID {
    DWORD                   cCertPolicyElementId;
    LPSTR                   *rgpszCertPolicyElementId;  // pszObjId
} CERT_POLICY_ID, *PCERT_POLICY_ID;


//+-------------------------------------------------------------------------
//  Type used for an extension to an encoded content
//
//  Where the Value's CRYPT_OBJID_BLOB is in its encoded representation.
//--------------------------------------------------------------------------
typedef struct _CERT_EXTENSION {
    LPSTR               pszObjId;
    BOOL                fCritical;
    CRYPT_OBJID_BLOB    Value;
} CERT_EXTENSION, *PCERT_EXTENSION;

typedef const CERT_EXTENSION* PCCERT_EXTENSION;

]]


CERT_POLICY_ID = ffi.typeof("CERT_POLICY_ID");
CERT_POLICY_ID_mt = {
	__tostring = function(self)
		print("POLICY_ID, ID: ", self.cCertPolicyElementId, ffi.cast("char *", self.rgpszCertPolicyElementId));
		return string.format("ID: %d", self.cCertPolicyElementId);
	end,

	__index = {
	},
}
CERT_POLICY_ID = ffi.metatype(CERT_POLICY_ID, CERT_POLICY_ID_mt);


ExtensionList = {
	[WinCrypt.szOID_KEY_USAGE] = function(ext, objid)
		--print("-- KEY_USAGE");
		local idptr = ffi.cast("PCERT_POLICY_ID", ext.Value.pbData);

		return idptr
	end,

	[WinCrypt.szOID_SUBJECT_KEY_IDENTIFIER] = function(ext, objid)
		--print("SUBJECT_KEY_IDENTIFIER");
		return ext.Value.pbData, ext.Value.cbData
	end,

	[WinCrypt.szOID_AUTHORITY_KEY_IDENTIFIER2] = function(ext, objid)
		--print("AUTHORITY_KEY_IDENTIFIER2");
		local idptr = ffi.cast("PCERT_AUTHORITY_KEY_ID2_INFO", ext.Value.pbData);

		return idptr
	end,

}

CERT_EXTENSION = ffi.typeof("CERT_EXTENSION")
CERT_EXTENSION_mt = {
	__tostring = function(self)
		return string.format("ID: %s  Critical: %s", self:GetObjId(), tostring(self:GetCritical()));
	end,

	__index = {
		GetCritical = function(self)
			return self.fCritical ~= 0;
		end,

		GetObjId = function(self)
			return ffi.string(self.pszObjId)
		end,

		DecodeBlob = function(self)
			local decoded, size = CryptDecodeObject(X509_NAME, self.Value.pbData, self.Value.cbEncoded)
			return decoded, size
		end,

		GetBlob = function(self)
			local func = ExtensionList[self:GetObjId()]

			if not func then return nil end

			return func(self, self:GetObjId());
		end,
	},
}
CERT_EXTENSION = ffi.metatype(CERT_EXTENSION, CERT_EXTENSION_mt);

ffi.cdef[[
//+-------------------------------------------------------------------------
//  Information stored in a certificate
//
//  The Issuer, Subject, Algorithm, PublicKey and Extension BLOBs are the
//  encoded representation of the information.
//--------------------------------------------------------------------------
typedef struct _CERT_INFO {
    DWORD                       dwVersion;
    CRYPT_INTEGER_BLOB          SerialNumber;
    CRYPT_ALGORITHM_IDENTIFIER  SignatureAlgorithm;
    CERT_NAME_BLOB              Issuer;
    FILETIME                    NotBefore;
    FILETIME                    NotAfter;
    CERT_NAME_BLOB              Subject;
    CERT_PUBLIC_KEY_INFO        SubjectPublicKeyInfo;
    CRYPT_BIT_BLOB              IssuerUniqueId;
    CRYPT_BIT_BLOB              SubjectUniqueId;
    DWORD                       cExtension;
    PCERT_EXTENSION             rgExtension;
} CERT_INFO, *PCERT_INFO;
]]


ffi.cdef[[
//+-------------------------------------------------------------------------
//  Certificate context.
//
//  A certificate context contains both the encoded and decoded representation
//  of a certificate. A certificate context returned by a cert store function
//  must be freed by calling the CertFreeCertificateContext function. The
//  CertDuplicateCertificateContext function can be called to make a duplicate
//  copy (which also must be freed by calling CertFreeCertificateContext).
//--------------------------------------------------------------------------
typedef struct _CERT_CONTEXT {
    DWORD                   dwCertEncodingType;
    BYTE                    *pbCertEncoded;
    DWORD                   cbCertEncoded;
    PCERT_INFO              pCertInfo;
    HCERTSTORE              hCertStore;
} CERT_CONTEXT, *PCERT_CONTEXT;

typedef const CERT_CONTEXT *PCCERT_CONTEXT;
]]

ffi.cdef[[
// Crypt32
	PCCERT_CONTEXT CertCreateCertificateContext(DWORD dwCertEncodingType, const BYTE *pbCertEncoded, DWORD cbCertEncoded);
	PCCERT_CONTEXT CertFindCertificateInStore(HCERTSTORE hCertStore, DWORD dwCertEncodingType, DWORD dwFindFlags, DWORD dwFindType, const void *pvFindPara, PCCERT_CONTEXT pPrevCertContext);

	BOOL CertFreeCertificateContext(PCCERT_CONTEXT pCertContext);
	BOOL CertGetStoreProperty(HCERTSTORE hCertStore, DWORD dwPropId, void *pvData, DWORD *pcbData);
	BOOL CertCloseStore(HCERTSTORE hCertStore, DWORD dwFlags);
	PCCERT_CONTEXT CertEnumCertificatesInStore(HCERTSTORE hCertStore, PCCERT_CONTEXT pPrevCertContext);

	BOOL CryptDecodeObject(DWORD dwCertEncodingType, LPCSTR lpszStructType, const BYTE *pbEncoded, DWORD cbEncoded, DWORD dwFlags, void *pvStructInfo, DWORD *pcbStructInfo);

	BOOL CryptImportPublicKeyInfo(HCRYPTPROV hCryptProv, DWORD dwCertEncodingType, PCERT_PUBLIC_KEY_INFO pInfo, HCRYPTKEY *phKey);
	BOOL CryptAcquireCertificatePrivateKey(PCCERT_CONTEXT pCert, DWORD dwFlags, void *pvReserved,
		HCRYPTPROV_OR_NCRYPT_KEY_HANDLE *phCryptProvOrNCryptKey,
		DWORD *pdwKeySpec,
		BOOL *pfCallerFreeProvOrNCryptKey);

	HCERTSTORE PFXImportCertStore(CRYPT_DATA_BLOB *pPFX, LPCWSTR szPassword, DWORD dwFlags);
	BOOL PFXIsPFXBlob(CRYPT_DATA_BLOB *pPFX);

/*
	bool CertGetCertificateContextProperty(IntPtr pCertContext, uint dwPropId, IntPtr pvData, out uint pcbData);
	intptr CertOpenStore(string lpszStoreProvider, uint dwMsgAndCertEncodingType, IntPtr hCryptProv, uint dwFlags, IntPtr pvPara);
*/
]]



CRYPTOAPI_BLOB = ffi.typeof("struct _CRYPTOAPI_BLOB");
CRYPTOAPI_BLOB_mt = {
	--__tostring = function(self)
	--	return base64.decode(self.pbData);
	--end,
}
ffi.metatype(CRYPTOAPI_BLOB, CRYPTOAPI_BLOB_mt);


ffi.cdef[[
typedef struct _CERT_RDN_ATTR {
  LPSTR               pszObjId;
  DWORD               dwValueType;
  CERT_RDN_VALUE_BLOB Value;
} CERT_RDN_ATTR, *PCERT_RDN_ATTR;

typedef struct _CERT_RDN {
  DWORD          cRDNAttr;
  PCERT_RDN_ATTR rgRDNAttr;
} CERT_RDN, *PCERT_RDN;

typedef struct _CERT_NAME_INFO {
  DWORD     cRDN;
  PCERT_RDN rgRDN;
} CERT_NAME_INFO, *PCERT_NAME_INFO;
]]

ffi.cdef[[

typedef struct _PUBLICKEYSTRUC {
  BYTE   bType;
  BYTE   bVersion;
  WORD   reserved;
  ALG_ID aiKeyAlg;
} BLOBHEADER, PUBLICKEYSTRUC;
]]

BLOBHEADER = ffi.typeof("BLOBHEADER");



local function CryptDecodeObject(lpszStructType, pbEncoded, cbEncoded, dwFlags)
	local dwFlags = dwFlags or 0
	local pvStructInfo = nil
	local pcbStructInfo = ffi.new("DWORD[1]")

	-- call first to see what size we need
	local err = Crypt32.CryptDecodeObject(bor(WinCrypt.X509_ASN_ENCODING, WinCrypt.PKCS_7_ASN_ENCODING),
		lpszStructType,
		pbEncoded,
		cbEncoded,
		dwFlags,
		pvStructInfo,
		pcbStructInfo);

	if err == 0 then
		return nil, errorhandling.GetLastError();
	end

	-- allocate an appropriately sized buffer
	local structSize = pcbStructInfo[0];
	pvStructInfo = ffi.new("uint8_t[?]", structSize);

	-- call again with the right sized buffer
	local err = Crypt32.CryptDecodeObject(bor(WinCrypt.X509_ASN_ENCODING, WinCrypt.PKCS_7_ASN_ENCODING),
		lpszStructType,
		pbEncoded,
		cbEncoded,
		dwFlags,
		pvStructInfo,
		pcbStructInfo);

	if err == 0 then
		return nil, errorhandling.GetLastError();
	end

	return pvStructInfo, pcbStructInfo[0];
end

local function GetX509_NAME(decoded, size)
	if not decoded then
		return decoded, size
	end

	local nameInfo = ffi.cast("PCERT_NAME_INFO", decoded);
	--print("GetX509_NAME(): ", nameInfo.cRDN);

	if nameInfo.cRDN < 1 then
		return nil, "eof"
	end

	local strPtr = nameInfo.rgRDN[0].rgRDNAttr.Value.pbData
	local strLen = nameInfo.rgRDN[0].rgRDNAttr.Value.cbData
	local str = ffi.string(strPtr, strLen);

	return str;
end



CERT_INFO = ffi.typeof("CERT_INFO")
CERT_INFO_mt = {
	__index = {
		GetIssuer = function(self)
			local pbEncoded = self.Issuer.pbData
			local cbEncoded = self.Issuer.cbData

			local decoded, size = CryptDecodeObject(X509_NAME, pbEncoded, cbEncoded)

			return GetX509_NAME(decoded, size)
		end,

		GetPublicKey = function(self)
			--print("-- CERT_INFO:GetPublicKey()");

			local winerr
			local phKey = ffi.new("HCRYPTKEY[1]")
			local pkiptr = ffi.cast("PCERT_PUBLIC_KEY_INFO", self.SubjectPublicKeyInfo);

			--print("SPKI: ", self.SubjectPublicKeyInfo);
			--print("PKI Ptr: ", pkiptr)
			
			-- First, try to get the key, using default provider
			local tempProv, err = CryptoProvider.Open(WinCrypt.MS_ENHANCED_PROV_A, WinCrypt.PROV_RSA_FULL);
			if tempProv then
				phKey, winerr = tempProv:ImportPublicKey(pkiptr);

				if (phKey) then
					return phKey, winerr
				end
				print("-- CERT_INFO:GetPublicKey(), failed ImportPublicKey ", string.format("0x%x",winerr));

			end

			--print("-- CERT_INFO:GetPublicKey(), failed CryptoProvider.Open(): ", string.format("0x%x",err));


			-- That didn't work, so try again with a Diffie Hellman Provider
			tempProv = CryptoProvider.Open(WinCrypt.MS_ENHANCED_PROV_A, WinCrypt.PROV_DSS_DH);
			phKey, winerr = tempProv:ImportPublicKey(pkiptr);


			if (phKey) then
				return phKey, winerr
			end
			--print("-- CERT_INFO:GetPublicKey(): ", phKey, string.format("0x%x",winerr));

			return phKey, winerr;
		end,

		GetSignatureAlgorithm = function(self)
			return ffi.string(self.SignatureAlgorithm.pszObjId);
		end,

		GetSubject = function(self)
			local pbEncoded = self.Subject.pbData
			local cbEncoded = self.Subject.cbData

			local decoded, size = CryptDecodeObject(X509_NAME, pbEncoded, cbEncoded)

			return GetX509_NAME(decoded, size)
		end,

		GetVersion = function(self)
			return self.dwVersion;
		end,

		Print = function(self)
			local pbData = self.SignatureAlgorithm.Parameters.pbData;
			local cbData = self.SignatureAlgorithm.Parameters.cbData;

			print("-- CERT_INFO --");
			print("Issuer: ", self:GetIssuer());
			print("Subject: ", self:GetSubject());
			print("Signature Algorithm: ", self:GetSignatureAlgorithm());
			print("Signature Params: ", bytestohex(pbData, cbData));
			print("Subject Key Identifier: ", self.SubjectPublicKeyInfo);
		end,
	},
}
ffi.metatype(CERT_INFO, CERT_INFO_mt)



function CryptAcquireContext(pszContainer, pszProvider, dwProvType, dwFlags)
	local dwFlags = dwFlags or 0
	local phProv = ffi.new("HCRYPTPROV[1]");

	local err = Advapi32.CryptAcquireContextA(phProv, pszContainer, pszProvider, dwProvType, dwFlags)

	if err ~= 0 then
		return phProv[0];
	end

	err = errorhandling.GetLastError();
	if (err == NTE_BAD_KEYSET) then
		err = Advapi32.CryptAcquireContextA(phProv, pszContainer, pszProvider, dwProvType, bor(dwFlags, WinCrypt.CRYPT_NEWKEYSET));

		if err == 0 then
			return nil, errorhandling.GetLastError();
		end
	end

	--print("CryptAcquireContext(), failed initial acquisition: ", string.format("0x%x",err));
	
	return phProv[0];
end



--[[
	Decoding Reference: http://msdn.microsoft.com/en-us/library/windows/desktop/aa381955(v=vs.85).aspx

--]]

CertificateContext = {}
CertificateContext_mt = {
	__index = CertificateContext;
}

CertificateContext.new = function(cContext)
	local obj = {}

	
	obj.Context = cContext

	setmetatable(obj, CertificateContext_mt)

--print("CertificateContext.new() - BEGIN");

	obj.Subject = cContext.pCertInfo:GetSubject();
	obj.Issuer = cContext.pCertInfo:GetIssuer();
	
--print("Subject : ", obj.Subject);
--print("Issuer: ", obj.Issuer);

	obj.PrivateKey = obj:GetPrivateKey();
	obj.PublicKey = cContext.pCertInfo:GetPublicKey();
	obj.SignatureAlgorithm = cContext.pCertInfo:GetSignatureAlgorithm();

--print("CertificateContext.new() - END");
	
	return obj
end

CertificateContext.Open = function(b64encoded)
	local decodedbytes = base64.decode(b64encoded)
	local certEncoding = bor(WinCrypt.X509_ASN_ENCODING, WinCrypt.PKCS_7_ASN_ENCODING)
	local cContext = Crypt32.CertCreateCertificateContext(certEncoding , decodedbytes, #decodedbytes)

	return CertificateContext.new(cContext);
end

CertificateContext.Free = function(self)
	Crypt32.CertFreeCertificateContext(self.Context);
end

CertificateContext.GetPrivateKey = function(self)
	local phCryptProvOrNCryptKey = ffi.new("HCRYPTPROV_OR_NCRYPT_KEY_HANDLE[1]");
	local pdwKeySpec = ffi.new("DWORD[1]");
	local pfCallerFreeProv = ffi.new("BOOL[1]");

--print("CertificateContext.GetPrivateKey() - BEGIN ")

	--	bor(WinCrypt.CRYPT_ACQUIRE_SILENT_FLAG, WinCrypt.CRYPT_ACQUIRE_COMPARE_KEY_FLAG),
	local err = Crypt32.CryptAcquireCertificatePrivateKey(self.Context,
		bor(WinCrypt.CRYPT_ACQUIRE_SILENT_FLAG),
		nil,
		phCryptProvOrNCryptKey,
		pdwKeySpec,
		pfCallerFreeProv)

	if err == 0 then
		local winerr = errorhandling.GetLastError();
		print("CertificateContext:GetPrivateKey(), ERROR: ", string.format("0x%x",winerr));

		return nil, winerr
	end

	self.PrivateCryptProv = CryptoProvider.new(phCryptProvOrNCryptKey[0]);
	self.PrivateKeySpec = pdwKeySpec[0];
	self.FreePrivateProvider = pfCallerFreeProv[0];

	-- Logger.Log("Verifying private key parameters.", Logger.CreateExtra("Private Key Spec", privateKeySpec));
	--print("Private Key Spec: ", self.PrivateKeySpec);
	if (self.PrivateKeySpec ~= WinCrypt.AT_KEYEXCHANGE) then
		assert(false, "Private key spec must be AT_KEYEXCHANGE.");
	end

	-- Logger.Log("Importing certificate's private key.");
	local hUserKey = self.PrivateCryptProv:GetUserKey(self.PrivateKeySpec);
--print("CertificateContext:GetPrivateKey(), hUserKey: ", hUserKey);

	return hUserKey;
end

CertificateContext.Print = function(self)
	print("-- CertificateContext --");
	print("Issuer: ", self.Issuer);
	print("Subject: ", self.Subject);
	print("Signature Algorithm: ", self.SignatureAlgorithm);

	print("Public Key: ", self.PublicKey);
	print("Private Key: ", self.PrivateKey);
end


CryptoProvider = {}
CryptoProvider_mt = {
	__index = CryptoProvider;
}

function CryptoProvider.new(handle)
	local obj = {
		Handle = handle;
	}

	setmetatable(obj, CryptoProvider_mt);

	return obj;
end

function CryptoProvider.Open(cName, cType, flags)

	cName = cName or WinCrypt.MS_DEF_PROV;
	cType = cType or WinCrypt.PROV_RSA_FULL;
	flags = flags or 0

	--cName = cName or WinCrypt.MS_ENH_RSA_AES_PROV;
	--cName = cName or WinCrypt.MS_ENHANCED_PROV_A
	--cType = cType or WinCrypt.PROV_RSA_AES;
	--cType = cType or WinCrypt.PROV_RSA_FULL;
	--flags = flags or WinCrypt.CRYPT_VERIFYCONTEXT

	-- if (!CryptAcquireContext(out cryptProvider, "", cryptProviderName, cryptProviderType, CRYPT_VERIFYCONTEXT))
	local tempProv, err = CryptAcquireContext(nil, cName, cType, flags)

	if not tempProv then
		return nil, err
	end

	return CryptoProvider.new(tempProv);
end

function CryptoProvider.GetUserKey(self, KeySpec)
	local phUserKey = ffi.new("HCRYPTKEY[1]");
	local err = Advapi32.CryptGetUserKey(self.Handle, KeySpec, phUserKey)
	if (err == 0) then
		local winerr = errorhandling.GetLastError();
		assert(false, "CryptoProvider.GetUserKey(), Failed to get key for certificate: "..winerr);
		--if (TicketCracker.ToUInt32(Marshal.GetLastWin32Error()) != Crypto.NTE_NO_KEY)
		--	throw new CryptException("Failed to get user key for certificate " + certName + ".", Marshal.GetLastWin32Error());
	end

	return phUserKey[0];
end

function CryptoProvider.ImportKey(self, pbBlob, cbBlob, hPubKey, dwFlags)
--print("-- CryptoProvider.ImportKey(): ", pbBlob, cbBlob);
	dwFlags = dwFlags or 0
	local phKey = ffi.new("HCRYPTKEY[1]");

	local err = Advapi32.CryptImportKey(self.Handle, pbBlob, cbBlob, hPubKey, dwFlags, phKey);

	if err == 0 then
		return nil, errorhandling.GetLastError();
	end

	return phKey[0];
end

function CryptoProvider.ImportRawKey(self, derivedKey, derivedKeyLen, algId, importFlags)
	importFlags = importFlags or 0

--print("-- CryptoProvider.ImportRawKey(), AlgId: ", string.format("0x%x",algId));

	local result = nil;
	local privateKey = nil;
	local keyBlob = nil;
	local tempKey = nil;
	local keyLen = nil;
	local sessionBlob = nil;

	local versionInfo = OSVERSIONINFO();
--	print("OS: ", versionInfo.dwMajorVersion, versionInfo.dwMinorVersion);

	assert(((versionInfo.dwMajorVersion > 5) or (versionInfo.dwMajorVersion == 5 and versionInfo.dwMinorVersion >= 1)), "version too low");


	local blobLength = 12+derivedKeyLen;
	local blob = ffi.new("uint8_t[?]", blobLength);
	local mstream = MemoryStream.Open(blob, blobLength, blobLength)
	mstream:Seek(0);
	local bstream = BinaryStream.new(mstream);

	bstream:WriteByte(WinCrypt.PLAINTEXTKEYBLOB);
	bstream:WriteByte(WinCrypt.CUR_BLOB_VERSION);
	bstream:WriteInt16(0);
	bstream:WriteInt32(algId);
	bstream:WriteInt32(derivedKeyLen);
	bstream.Stream:WriteBytes(derivedKey, derivedKeyLen);

--	print("-- ImportRawKey:");

	-- Logger.Log("Importing raw encryption key utilizing constructed key blob.", Logger.CreateExtra("Key Blob", blob));
	local result, err = self:ImportKey(blob, blobLength, nil, importFlags)

	if (not result) then
		assert(false, "Could not import raw key: "..string.format("0x%x", errorhandling.GetLastError()));
	end

	return CryptoKey(result);
end



-- pkiptr = PCERT_PUBLIC_KEY_INFO
function CryptoProvider.ImportPublicKey(self, pkiptr)
	local phKey = ffi.new("HCRYPTKEY[1]")
	local err = Crypt32.CryptImportPublicKeyInfo(self.Handle,
		bor(WinCrypt.X509_ASN_ENCODING, WinCrypt.PKCS_7_ASN_ENCODING),
		pkiptr,
		phKey);

	if (err == 0) then
		return nil, errorhandling.GetLastError();
	end

	return phKey[0];
end

CryptoProvider.DefaultProvider = CryptoProvider.Open();





ffi.cdef[[
typedef struct CertificateStore {
	HCERTSTORE	Handle;
} CertificateStore;
]]

-- Cert Store Property IDs
local CERT_STORE_LOCALIZED_NAME_PROP_ID  = 0x1000;


local function PFXImport(filename)
--print("PFXImport: ", filename);
	-- open up the file
	local fs = io.open(filename, "rb");
	assert(fs, "Could not open file: "..filename);

	local filebytes = fs:read("*a");
	fs:close();

	-- copy the contents to the blob
	-- Allocate a blob object
	local pfxblob = ffi.new("CRYPT_DATA_BLOB")
	pfxblob.cbData = #filebytes
	pfxblob.pbData = ffi.new("uint8_t[?]", pfxblob.cbData);
	ffi.copy(pfxblob.pbData, filebytes, pfxblob.cbData);

	-- Determine if it is in fact a proper pfx blob
	local isBlob = WinCrypt.Crypt32.PFXIsPFXBlob(pfxblob) ~= 0;
	assert(isBlob, "File: "..filename.." is NOT a PFX Blob.");

	-- Create the cert store
	local szPassword = L"password";
	--local dwFlags = bor(WinCrypt.CRYPT_EXPORTABLE, WinCrypt.PKCS12_INCLUDE_EXTENDED_PROPERTIES);
	local dwFlags = bor(WinCrypt.CRYPT_EXPORTABLE);
	--local dwFlags = 0;

	local hStore = WinCrypt.Crypt32.PFXImportCertStore(pfxblob, szPassword, dwFlags);
	if hStore == nil then
		local winerr = WinCrypt.Kernel32.GetLastError()
		print("hStore == NIL: ", winerr);
		return nil, winerr
	end

	return hStore, pfxblob
end


CertificateStore = ffi.typeof("CertificateStore");
CertificateStore_mt = {
	__gc = function(self)
		print("GC: CertificateStore");
		local dwFlags = 0
		WinCrypt.Crypt32.CertCloseStore(self.Handle, dwFlags)
	end,

	__new = function(ct, arg)
--print("__new(), CertificateStore: ", arg);
		local handle

		if type(arg) == "string" then
			handle = PFXImport(arg)
		else
			handle = arg
		end

		local obj = ffi.new(ct);
		obj.Handle = handle;

		return obj
	end,

	__index = {
		-- Iterator
		Certificates = function(self)
			local cContext = nil;

			return function()
				cContext = Crypt32.CertEnumCertificatesInStore(self.Handle, cContext);
				if cContext ~= nil then
					return CertificateContext.new(cContext)
				end

				return nil
			end
		end,

		FindCertificate = function(self, key)
			local certEncoding = bor(WinCrypt.X509_ASN_ENCODING, WinCrypt.PKCS_7_ASN_ENCODING)
			local dwFindFlags = 0
			local dwFindType = WinCrypt.CERT_FIND_ANY
			local pvFindPara = nil
			local pPrevCertContext = nil

			local cContext = WinCrypt.Crypt32.CertFindCertificateInStore(self.Handle, certEncoding, dwFindFlags, dwFindType,pvFindPara, pPrevCertContext);

			return CertificateContext.new(cContext);
		end,

		GetProperty = function(self, dwPropId)
			local pcbData = ffi.new("DWORD[1]", 1024);
			--local buff = ffi.new("uint8_t[1024]");

			--print("GetProperty(), handle: ", self.Handle);
			local err = WinCrypt.Crypt32.CertGetStoreProperty(self.Handle, dwPropId, nil, pcbData);
			if err == 0 then
				local winerr = WinCrypt.Kernel32.GetLastError();
				--print("Failed to get property: ", string.format("0x%x",winerr));
				return nil, winerr
			end

			local dataLen = pcbData[0];

			local buff = ffi.new("uint8_t[?]", dataLen);
			local err = WinCrypt.Crypt32.CertGetStoreProperty(self.Handle, dwPropId, buff, pcbData);
			dataLen = pcbData[0];
			assert(err ~= 0, "Failed to get store property: "..dwPropId)

			return buff
		end,

		GetName = function(self)
			local buff, err = self:GetProperty(CERT_STORE_LOCALIZED_NAME_PROP_ID)

			if not buff then
				return nil, err
			end

			local name = A(buff);

			return name
		end,

	},
}
CertificateStore = ffi.metatype(CertificateStore, CertificateStore_mt);



-- Libraries
WinCrypt.Crypt32 = Crypt32;
WinCrypt.Advapi32 = Advapi32;
WinCrypt.Kernel32 = Kernel32;

-- Functions
WinCrypt.CryptAcquireContext = CryptAcquireContext;
WinCrypt.CryptDecodeObject = CryptDecodeObject;
WinCrypt.PFXImport = PFXImport;
WinCrypt.CryptGetDefaultProvider = CryptGetDefaultProvider;

-- Classes
WinCrypt.CertificateStore = CertificateStore;
WinCrypt.CERT_INFO = CERT_INFO;
WinCrypt.CertificateContext = CertificateContext;
WinCrypt.CryptoProvider = CryptoProvider;

return WinCrypt

