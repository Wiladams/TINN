
local ffi = require ("ffi");
local bit = require ("bit");
local bor = bit.bor;
local band = bit.band;
local rshift = bit.rshift;
local lshift = bit.lshift;

local core_string = require("core_string_l1_1_0");
local require("ntstatus");

local L = core_string.toUnicode;


SECURITY_WIN32 = true;

--[[
From Security.h

--]]

--[[
// This file will go out and pull in all the header files that you need,
// based on defines that you issue.  The following macros are used.
//
// SECURITY_KERNEL      Use the kernel interface, not the usermode
//
--]]

--
-- These are name that can be used to refer to the builtin packages
--

if not NTLMSP_NAME_A then
	NTLMSP_NAME_A =	"NTLM";
	NTLMSP_NAME   =	L"NTLM"; 
end -- NTLMSP_NAME

if not MICROSOFT_KERBEROS_NAME_A then
	MICROSOFT_KERBEROS_NAME_A   ="Kerberos";
	MICROSOFT_KERBEROS_NAME_W   =L"Kerberos";
	MICROSOFT_KERBEROS_NAME 	=MICROSOFT_KERBEROS_NAME_W;
end  -- MICROSOFT_KERBEROS_NAME_A


if not NEGOSSP_NAME then
	NEGOSSP_NAME_W  =L"Negotiate";
	NEGOSSP_NAME_A  ="Negotiate";

	if UNICODE then
		NEGOSSP_NAME    =NEGOSSP_NAME_W;
	else
		NEGOSSP_NAME    =NEGOSSP_NAME_A;
	end
end   -- NEGOSSP_NAME

--
-- Include the master SSPI header file
--

--[[
	From SSPI
--]]

--#include <sdkddkver.h>

--
-- Determine environment:
--

if SECURITY_WIN32 then
	ISSP_LEVEL  = 32
	ISSP_MODE   = 1
end -- SECURITY_WIN32

if SECURITY_KERNEL then
	ISSP_LEVEL  = 32;          

	-- SECURITY_KERNEL trumps SECURITY_WIN32.  Undefine ISSP_MODE so that
	-- we don't get redefine errors.
	ISSP_MODE   = 0;
end -- SECURITY_KERNEL

if SECURITY_MAC then
	ISSP_LEVEL  = 32;
	ISSP_MODE   = 1;
end -- SECURITY_MAC


if not ISSP_LEVEL then
error([[
You must define one of SECURITY_WIN32, SECURITY_KERNEL, or
SECURITY_MAC]]);
end -- !ISSP_LEVEL


--
-- Now, define platform specific mappings:
--






--[[
//
// Decide what a string - 32 bits only since for 16 bits it is clear.
//
--]]

if UNICODE then
ffi.cdef[[
typedef SEC_WCHAR * SECURITY_PSTR;
typedef const SEC_WCHAR * SECURITY_PCSTR;
]]
else -- UNICODE
ffi.cdef[[
typedef SEC_CHAR * SECURITY_PSTR;
typedef const SEC_CHAR * SECURITY_PCSTR;
]]
end -- UNICODE


--[[
//
// Equivalent string for rpcrt:
//

//
// Okay, security specific types:
//
--]]







if (_NTDEF_) or (_WINNT_) then

else
ffi.cdef[[ 
typedef struct _SECURITY_INTEGER
{
    unsigned long LowPart;
    long HighPart;
} SECURITY_INTEGER, *PSECURITY_INTEGER;
]]
end -- _NTDEF_ || _WINNT_

if not SECURITY_MAC then

else -- SECURITY_MAC
ffi.cdef[[
typedef unsigned long TimeStamp;
typedef unsigned long * PTimeStamp;
]]
end -- SECURITY_MAC



--[[
// If we are in 32 bit mode, define the SECURITY_STRING structure,
// as a clone of the base UNICODE_STRING structure.  This is used
// internally in security components, an as the string interface
// for kernel components (e.g. FSPs)
--]]

if not  _NTDEF_ then
ffi.cdef[[
typedef struct _SECURITY_STRING {
    unsigned short      Length;
    unsigned short      MaximumLength;
    unsigned short *    Buffer;
} SECURITY_STRING, * PSECURITY_STRING;
]]
else -- _NTDEF_
ffi.cdef[[
typedef UNICODE_STRING SECURITY_STRING, *PSECURITY_STRING;  
]]
end -- _NTDEF_






ffi.cdef[[
//
//  Security Package Capabilities
//
static const int SECPKG_FLAG_INTEGRITY                 =  0x00000001;  // Supports integrity on messages
static const int SECPKG_FLAG_PRIVACY                   =  0x00000002;  // Supports privacy (confidentiality)
static const int SECPKG_FLAG_TOKEN_ONLY                =  0x00000004;  // Only security token needed
static const int SECPKG_FLAG_DATAGRAM                  =  0x00000008;  // Datagram RPC support
static const int SECPKG_FLAG_CONNECTION                =  0x00000010;  // Connection oriented RPC support
static const int SECPKG_FLAG_MULTI_REQUIRED            =  0x00000020;  // Full 3-leg required for re-auth.
static const int SECPKG_FLAG_CLIENT_ONLY               =  0x00000040;  // Server side functionality not available
static const int SECPKG_FLAG_EXTENDED_ERROR            =  0x00000080;  // Supports extended error msgs
static const int SECPKG_FLAG_IMPERSONATION             =  0x00000100;  // Supports impersonation
static const int SECPKG_FLAG_ACCEPT_WIN32_NAME         =  0x00000200;  // Accepts Win32 names
static const int SECPKG_FLAG_STREAM                    =  0x00000400;  // Supports stream semantics
static const int SECPKG_FLAG_NEGOTIABLE                =  0x00000800;  // Can be used by the negotiate package
static const int SECPKG_FLAG_GSS_COMPATIBLE            =  0x00001000;  // GSS Compatibility Available
static const int SECPKG_FLAG_LOGON                     =  0x00002000;  // Supports common LsaLogonUser
static const int SECPKG_FLAG_ASCII_BUFFERS             =  0x00004000;  // Token Buffers are in ASCII
static const int SECPKG_FLAG_FRAGMENT                  =  0x00008000;  // Package can fragment to fit
static const int SECPKG_FLAG_MUTUAL_AUTH               =  0x00010000;  // Package can perform mutual authentication
static const int SECPKG_FLAG_DELEGATION                =  0x00020000;  // Package can delegate
static const int SECPKG_FLAG_READONLY_WITH_CHECKSUM    =  0x00040000;  // Package can delegate
static const int SECPKG_FLAG_RESTRICTED_TOKENS         =  0x00080000;  // Package supports restricted callers
static const int SECPKG_FLAG_NEGO_EXTENDER             =  0x00100000;  // this package extends SPNEGO, there is at most one
static const int SECPKG_FLAG_NEGOTIABLE2               =  0x00200000;  // this package is negotiated under the NegoExtender

static const int SECPKG_ID_NONE      =0xFFFF;
]]



ffi.cdef[[
static const int SECBUFFER_VERSION           =0;

static const int SECBUFFER_EMPTY             =0;   // Undefined, replaced by provider
static const int SECBUFFER_DATA              =1;   // Packet data
static const int SECBUFFER_TOKEN             =2;   // Security token
static const int SECBUFFER_PKG_PARAMS        =3;   // Package specific parameters
static const int SECBUFFER_MISSING           =4;   // Missing Data indicator
static const int SECBUFFER_EXTRA             =5;   // Extra data
static const int SECBUFFER_STREAM_TRAILER    =6;   // Security Trailer
static const int SECBUFFER_STREAM_HEADER     =7;   // Security Header
static const int SECBUFFER_NEGOTIATION_INFO  =8;   // Hints from the negotiation pkg
static const int SECBUFFER_PADDING           =9;   // non-data padding
static const int SECBUFFER_STREAM            =10;  // whole encrypted message
static const int SECBUFFER_MECHLIST          =11;
static const int SECBUFFER_MECHLIST_SIGNATURE =12;
static const int SECBUFFER_TARGET            =13;  // obsolete
static const int SECBUFFER_CHANNEL_BINDINGS  =14;
static const int SECBUFFER_CHANGE_PASS_RESPONSE =15;
static const int SECBUFFER_TARGET_HOST       =16;
static const int SECBUFFER_ALERT             =17;

static const int SECBUFFER_ATTRMASK                     = 0xF0000000;
static const int SECBUFFER_READONLY                     = 0x80000000;  // Buffer is read-only, no checksum
static const int SECBUFFER_READONLY_WITH_CHECKSUM       = 0x10000000;  // Buffer is read-only, and checksummed
static const int SECBUFFER_RESERVED                     = 0x60000000;  // Flags reserved to security system
]]

ffi.cdef[[
typedef struct _SEC_NEGOTIATION_INFO {
    unsigned long       Size;           // Size of this structure
    unsigned long       NameLength;     // Length of name hint
    SEC_WCHAR * Name;           // Name hint
    void *      Reserved;       // Reserved
} SEC_NEGOTIATION_INFO, * PSEC_NEGOTIATION_INFO ;

typedef struct _SEC_CHANNEL_BINDINGS {
    unsigned long  dwInitiatorAddrType;
    unsigned long  cbInitiatorLength;
    unsigned long  dwInitiatorOffset;
    unsigned long  dwAcceptorAddrType;
    unsigned long  cbAcceptorLength;
    unsigned long  dwAcceptorOffset;
    unsigned long  cbApplicationDataLength;
    unsigned long  dwApplicationDataOffset;
} SEC_CHANNEL_BINDINGS, * PSEC_CHANNEL_BINDINGS ;
]]

ffi.cdef[[
//
//  Data Representation Constant:
//
static const int SECURITY_NATIVE_DREP       = 0x00000010;
static const int SECURITY_NETWORK_DREP      = 0x00000000;

//
//  Credential Use Flags
//
static const int SECPKG_CRED_INBOUND        = 0x00000001;
static const int SECPKG_CRED_OUTBOUND       = 0x00000002;
static const int SECPKG_CRED_BOTH           = 0x00000003;
static const int SECPKG_CRED_DEFAULT        = 0x00000004;
static const int SECPKG_CRED_RESERVED       = 0xF0000000;

//
//  SSP SHOULD prompt the user for credentials/consent, independent
//  of whether credentials to be used are the 'logged on' credentials
//  or retrieved from credman.
//
//  An SSP may choose not to prompt, however, in circumstances determined
//  by the SSP.
//

static const int SECPKG_CRED_AUTOLOGON_RESTRICTED   = 0x00000010;

//
// auth will always fail, ISC() is called to process policy data only
//

static const int SECPKG_CRED_PROCESS_POLICY_ONLY    = 0x00000020;

//
//  InitializeSecurityContext Requirement and return flags:
//

static const int ISC_REQ_DELEGATE               = 0x00000001;
static const int ISC_REQ_MUTUAL_AUTH            = 0x00000002;
static const int ISC_REQ_REPLAY_DETECT          = 0x00000004;
static const int ISC_REQ_SEQUENCE_DETECT        = 0x00000008;
static const int ISC_REQ_CONFIDENTIALITY        = 0x00000010;
static const int ISC_REQ_USE_SESSION_KEY        = 0x00000020;
static const int ISC_REQ_PROMPT_FOR_CREDS       = 0x00000040;
static const int ISC_REQ_USE_SUPPLIED_CREDS     = 0x00000080;
static const int ISC_REQ_ALLOCATE_MEMORY        = 0x00000100;
static const int ISC_REQ_USE_DCE_STYLE          = 0x00000200;
static const int ISC_REQ_DATAGRAM               = 0x00000400;
static const int ISC_REQ_CONNECTION             = 0x00000800;
static const int ISC_REQ_CALL_LEVEL             = 0x00001000;
static const int ISC_REQ_FRAGMENT_SUPPLIED      = 0x00002000;
static const int ISC_REQ_EXTENDED_ERROR         = 0x00004000;
static const int ISC_REQ_STREAM                 = 0x00008000;
static const int ISC_REQ_INTEGRITY              = 0x00010000;
static const int ISC_REQ_IDENTIFY               = 0x00020000;
static const int ISC_REQ_NULL_SESSION           = 0x00040000;
static const int ISC_REQ_MANUAL_CRED_VALIDATION = 0x00080000;
static const int ISC_REQ_RESERVED1              = 0x00100000;
static const int ISC_REQ_FRAGMENT_TO_FIT        = 0x00200000;
// This exists only in Windows Vista and greater
static const int ISC_REQ_FORWARD_CREDENTIALS    = 0x00400000;
static const int ISC_REQ_NO_INTEGRITY           = 0x00800000; // honored only by SPNEGO
static const int ISC_REQ_USE_HTTP_STYLE         = 0x01000000;

static const int ISC_RET_DELEGATE               = 0x00000001;
static const int ISC_RET_MUTUAL_AUTH            = 0x00000002;
static const int ISC_RET_REPLAY_DETECT          = 0x00000004;
static const int ISC_RET_SEQUENCE_DETECT        = 0x00000008;
static const int ISC_RET_CONFIDENTIALITY        = 0x00000010;
static const int ISC_RET_USE_SESSION_KEY        = 0x00000020;
static const int ISC_RET_USED_COLLECTED_CREDS   = 0x00000040;
static const int ISC_RET_USED_SUPPLIED_CREDS    = 0x00000080;
static const int ISC_RET_ALLOCATED_MEMORY       = 0x00000100;
static const int ISC_RET_USED_DCE_STYLE         = 0x00000200;
static const int ISC_RET_DATAGRAM               = 0x00000400;
static const int ISC_RET_CONNECTION             = 0x00000800;
static const int ISC_RET_INTERMEDIATE_RETURN    = 0x00001000;
static const int ISC_RET_CALL_LEVEL             = 0x00002000;
static const int ISC_RET_EXTENDED_ERROR         = 0x00004000;
static const int ISC_RET_STREAM                 = 0x00008000;
static const int ISC_RET_INTEGRITY              = 0x00010000;
static const int ISC_RET_IDENTIFY               = 0x00020000;
static const int ISC_RET_NULL_SESSION           = 0x00040000;
static const int ISC_RET_MANUAL_CRED_VALIDATION = 0x00080000;
static const int ISC_RET_RESERVED1              = 0x00100000;
static const int ISC_RET_FRAGMENT_ONLY          = 0x00200000;
// This exists only in Windows Vista and greater
static const int ISC_RET_FORWARD_CREDENTIALS    = 0x00400000;

static const int ISC_RET_USED_HTTP_STYLE        = 0x01000000;
static const int ISC_RET_NO_ADDITIONAL_TOKEN    = 0x02000000;  // *INTERNAL*
static const int ISC_RET_REAUTHENTICATION       = 0x08000000;  // *INTERNAL*

static const int ASC_REQ_DELEGATE               = 0x00000001;
static const int ASC_REQ_MUTUAL_AUTH            = 0x00000002;
static const int ASC_REQ_REPLAY_DETECT          = 0x00000004;
static const int ASC_REQ_SEQUENCE_DETECT        = 0x00000008;
static const int ASC_REQ_CONFIDENTIALITY        = 0x00000010;
static const int ASC_REQ_USE_SESSION_KEY        = 0x00000020;
static const int ASC_REQ_ALLOCATE_MEMORY        = 0x00000100;
static const int ASC_REQ_USE_DCE_STYLE          = 0x00000200;
static const int ASC_REQ_DATAGRAM               = 0x00000400;
static const int ASC_REQ_CONNECTION             = 0x00000800;
static const int ASC_REQ_CALL_LEVEL             = 0x00001000;
static const int ASC_REQ_EXTENDED_ERROR         = 0x00008000;
static const int ASC_REQ_STREAM                 = 0x00010000;
static const int ASC_REQ_INTEGRITY              = 0x00020000;
static const int ASC_REQ_LICENSING              = 0x00040000;
static const int ASC_REQ_IDENTIFY               = 0x00080000;
static const int ASC_REQ_ALLOW_NULL_SESSION     = 0x00100000;
static const int ASC_REQ_ALLOW_NON_USER_LOGONS  = 0x00200000;
static const int ASC_REQ_ALLOW_CONTEXT_REPLAY   = 0x00400000;
static const int ASC_REQ_FRAGMENT_TO_FIT        = 0x00800000;
static const int ASC_REQ_FRAGMENT_SUPPLIED      = 0x00002000;
static const int ASC_REQ_NO_TOKEN               = 0x01000000;
static const int ASC_REQ_PROXY_BINDINGS         = 0x04000000;
//      SSP_RET_REAUTHENTICATION        =0x08000000;  // *INTERNAL*
static const int ASC_REQ_ALLOW_MISSING_BINDINGS  =0x10000000;

static const int ASC_RET_DELEGATE               = 0x00000001;
static const int ASC_RET_MUTUAL_AUTH            = 0x00000002;
static const int ASC_RET_REPLAY_DETECT          = 0x00000004;
static const int ASC_RET_SEQUENCE_DETECT        = 0x00000008;
static const int ASC_RET_CONFIDENTIALITY        = 0x00000010;
static const int ASC_RET_USE_SESSION_KEY        = 0x00000020;
static const int ASC_RET_ALLOCATED_MEMORY       = 0x00000100;
static const int ASC_RET_USED_DCE_STYLE         = 0x00000200;
static const int ASC_RET_DATAGRAM               = 0x00000400;
static const int ASC_RET_CONNECTION             = 0x00000800;
static const int ASC_RET_CALL_LEVEL             = 0x00002000; // skipped 1000 to be like ISC_
static const int ASC_RET_THIRD_LEG_FAILED       = 0x00004000;
static const int ASC_RET_EXTENDED_ERROR         = 0x00008000;
static const int ASC_RET_STREAM                 = 0x00010000;
static const int ASC_RET_INTEGRITY              = 0x00020000;
static const int ASC_RET_LICENSING              = 0x00040000;
static const int ASC_RET_IDENTIFY               = 0x00080000;
static const int ASC_RET_NULL_SESSION           = 0x00100000;
static const int ASC_RET_ALLOW_NON_USER_LOGONS  = 0x00200000;
static const int ASC_RET_ALLOW_CONTEXT_REPLAY   = 0x00400000;  // deprecated - don't use this flag!!!
static const int ASC_RET_FRAGMENT_ONLY          = 0x00800000;
static const int ASC_RET_NO_TOKEN               = 0x01000000;
static const int ASC_RET_NO_ADDITIONAL_TOKEN    = 0x02000000;  // *INTERNAL*
static const int ASC_RET_NO_PROXY_BINDINGS      = 0x04000000;
//      SSP_RET_REAUTHENTICATION        =0x08000000;  // *INTERNAL*
static const int ASC_RET_MISSING_BINDINGS        =0x10000000;
]]

ffi.cdef[[
//
//  Security Credentials Attributes:
//

static const int SECPKG_CRED_ATTR_NAMES        = 1;
static const int SECPKG_CRED_ATTR_SSI_PROVIDER = 2;

typedef struct _SecPkgCredentials_NamesW
{
    SEC_WCHAR * sUserName;
} SecPkgCredentials_NamesW, * PSecPkgCredentials_NamesW;

typedef struct _SecPkgCredentials_NamesA
{
    SEC_CHAR * sUserName;
} SecPkgCredentials_NamesA, * PSecPkgCredentials_NamesA;
]]



ffi.cdef[[
typedef struct _SecPkgCredentials_SSIProviderW
{
    SEC_WCHAR * sProviderName;
    unsigned long       ProviderInfoLength;
    char *      ProviderInfo;
} SecPkgCredentials_SSIProviderW, * PSecPkgCredentials_SSIProviderW;


typedef struct _SecPkgCredentials_SSIProviderA
{
    SEC_CHAR  * sProviderName;
    unsigned long       ProviderInfoLength;
    char *      ProviderInfo;
} SecPkgCredentials_SSIProviderA, * PSecPkgCredentials_SSIProviderA;
]]



ffi.cdef[[
//
//  Security Context Attributes:
//
static const int  SECPKG_ATTR_SIZES           = 0;
static const int  SECPKG_ATTR_NAMES           = 1;
static const int  SECPKG_ATTR_LIFESPAN        = 2;
static const int  SECPKG_ATTR_DCE_INFO        = 3;
static const int  SECPKG_ATTR_STREAM_SIZES    = 4;
static const int  SECPKG_ATTR_KEY_INFO        = 5;
static const int  SECPKG_ATTR_AUTHORITY       = 6;
static const int  SECPKG_ATTR_PROTO_INFO      = 7;
static const int  SECPKG_ATTR_PASSWORD_EXPIRY = 8;
static const int  SECPKG_ATTR_SESSION_KEY     = 9;
static const int  SECPKG_ATTR_PACKAGE_INFO    = 10;
static const int  SECPKG_ATTR_USER_FLAGS      = 11;
static const int  SECPKG_ATTR_NEGOTIATION_INFO = 12;
static const int  SECPKG_ATTR_NATIVE_NAMES    = 13;
static const int  SECPKG_ATTR_FLAGS           = 14;
// These attributes exist only in Win XP and greater
static const int  SECPKG_ATTR_USE_VALIDATED   = 15;
static const int  SECPKG_ATTR_CREDENTIAL_NAME = 16;
static const int  SECPKG_ATTR_TARGET_INFORMATION = 17;
static const int  SECPKG_ATTR_ACCESS_TOKEN    = 18;
// These attributes exist only in Win2K3 and greater
static const int  SECPKG_ATTR_TARGET          = 19;
static const int  SECPKG_ATTR_AUTHENTICATION_ID  = 20;
// These attributes exist only in Win2K3SP1 and greater
static const int  SECPKG_ATTR_LOGOFF_TIME     = 21;
//
// win7 or greater
//
static const int  SECPKG_ATTR_NEGO_KEYS         = 22;
static const int  SECPKG_ATTR_PROMPTING_NEEDED  = 24;
static const int  SECPKG_ATTR_UNIQUE_BINDINGS   = 25;
static const int  SECPKG_ATTR_ENDPOINT_BINDINGS = 26;
static const int  SECPKG_ATTR_CLIENT_SPECIFIED_TARGET = 27;

static const int  SECPKG_ATTR_LAST_CLIENT_TOKEN_STATUS = 30;
static const int  SECPKG_ATTR_NEGO_PKG_INFO        = 31; // contains nego info of packages
static const int  SECPKG_ATTR_NEGO_STATUS          = 32; // contains the last error
static const int  SECPKG_ATTR_CONTEXT_DELETED      = 33; // a context has been deleted

static const int  SECPKG_ATTR_SUBJECT_SECURITY_ATTRIBUTES = 128;

typedef struct _SecPkgContext_SubjectAttributes { 
    void* AttributeInfo; // contains a PAUTHZ_SECURITY_ATTRIBUTES_INFORMATION structure
} SecPkgContext_SubjectAttributes, *PSecPkgContext_SubjectAttributes;

static const int  SECPKG_ATTR_NEGO_INFO_FLAG_NO_KERBEROS = 0x1;
static const int  SECPKG_ATTR_NEGO_INFO_FLAG_NO_NTLM     = 0x2;
]]

ffi.cdef[[
//
// types of credentials, used by SECPKG_ATTR_PROMPTING_NEEDED
//

typedef enum _SECPKG_CRED_CLASS {
    SecPkgCredClass_None = 0,  // no creds
    SecPkgCredClass_Ephemeral = 10,  // logon creds
    SecPkgCredClass_PersistedGeneric = 20, // saved creds, not target specific
    SecPkgCredClass_PersistedSpecific = 30, // saved creds, target specific
    SecPkgCredClass_Explicit = 40, // explicitly supplied creds
} SECPKG_CRED_CLASS, * PSECPKG_CRED_CLASS;

typedef struct _SecPkgContext_CredInfo {
    SECPKG_CRED_CLASS CredClass;
    unsigned long IsPromptingNeeded;
} SecPkgContext_CredInfo, *PSecPkgContext_CredInfo;

typedef struct _SecPkgContext_NegoPackageInfo
{
    unsigned long PackageMask;
} SecPkgContext_NegoPackageInfo, * PSecPkgContext_NegoPackageInfo;

typedef struct _SecPkgContext_NegoStatus
{
    unsigned long LastStatus;
} SecPkgContext_NegoStatus, * PSecPkgContext_NegoStatus;

typedef struct _SecPkgContext_Sizes
{
    unsigned long cbMaxToken;
    unsigned long cbMaxSignature;
    unsigned long cbBlockSize;
    unsigned long cbSecurityTrailer;
} SecPkgContext_Sizes, * PSecPkgContext_Sizes;

typedef struct _SecPkgContext_StreamSizes
{
    unsigned long   cbHeader;
    unsigned long   cbTrailer;
    unsigned long   cbMaximumMessage;
    unsigned long   cBuffers;
    unsigned long   cbBlockSize;
} SecPkgContext_StreamSizes, * PSecPkgContext_StreamSizes;

typedef struct _SecPkgContext_NamesW
{
    SEC_WCHAR * sUserName;
} SecPkgContext_NamesW, * PSecPkgContext_NamesW;



typedef enum _SECPKG_ATTR_LCT_STATUS {
    SecPkgAttrLastClientTokenYes,
    SecPkgAttrLastClientTokenNo,
    SecPkgAttrLastClientTokenMaybe
} SECPKG_ATTR_LCT_STATUS, * PSECPKG_ATTR_LCT_STATUS;


typedef struct _SecPkgContext_LastClientTokenStatus {
    SECPKG_ATTR_LCT_STATUS LastClientTokenStatus;
} SecPkgContext_LastClientTokenStatus, * PSecPkgContext_LastClientTokenStatus;

typedef struct _SecPkgContext_NamesA
{
    SEC_CHAR * sUserName;
} SecPkgContext_NamesA, * PSecPkgContext_NamesA;
]]


ffi.cdef[[
typedef struct _SecPkgContext_Lifespan
{
    TimeStamp tsStart;
    TimeStamp tsExpiry;
} SecPkgContext_Lifespan, * PSecPkgContext_Lifespan;

typedef struct _SecPkgContext_DceInfo
{
    unsigned long AuthzSvc;
    void * pPac;
} SecPkgContext_DceInfo, * PSecPkgContext_DceInfo;



typedef struct _SecPkgContext_KeyInfoA
{
    SEC_CHAR *  sSignatureAlgorithmName;
    SEC_CHAR *  sEncryptAlgorithmName;
    unsigned long       KeySize;
    unsigned long       SignatureAlgorithm;
    unsigned long       EncryptAlgorithm;
} SecPkgContext_KeyInfoA, * PSecPkgContext_KeyInfoA;

// begin_ntifs

typedef struct _SecPkgContext_KeyInfoW
{
    SEC_WCHAR * sSignatureAlgorithmName;
    SEC_WCHAR * sEncryptAlgorithmName;
    unsigned long       KeySize;
    unsigned long       SignatureAlgorithm;
    unsigned long       EncryptAlgorithm;
} SecPkgContext_KeyInfoW, * PSecPkgContext_KeyInfoW;
]]

ffi.cdef[[
typedef struct _SecPkgContext_AuthorityA
{
    SEC_CHAR *  sAuthorityName;
} SecPkgContext_AuthorityA, * PSecPkgContext_AuthorityA;

// begin_ntifs

typedef struct _SecPkgContext_AuthorityW
{
    SEC_WCHAR * sAuthorityName;
} SecPkgContext_AuthorityW, * PSecPkgContext_AuthorityW;
]]


ffi.cdef[[
typedef struct _SecPkgContext_ProtoInfoA
{
    SEC_CHAR *  sProtocolName;
    unsigned long       majorVersion;
    unsigned long       minorVersion;
} SecPkgContext_ProtoInfoA, * PSecPkgContext_ProtoInfoA;

// begin_ntifs

typedef struct _SecPkgContext_ProtoInfoW
{
    SEC_WCHAR * sProtocolName;
    unsigned long majorVersion;
    unsigned long minorVersion;
} SecPkgContext_ProtoInfoW, * PSecPkgContext_ProtoInfoW;
]]


ffi.cdef[[
typedef struct _SecPkgContext_PasswordExpiry
{
    TimeStamp tsPasswordExpires;
} SecPkgContext_PasswordExpiry, * PSecPkgContext_PasswordExpiry;

typedef struct _SecPkgContext_LogoffTime
{
    TimeStamp tsLogoffTime;
} SecPkgContext_LogoffTime, * PSecPkgContext_LogoffTime;
// Greater than Windows Server 2003 RTM (SP1 and greater contains this)

typedef struct _SecPkgContext_SessionKey
{
    unsigned long SessionKeyLength;
     unsigned char * SessionKey;
} SecPkgContext_SessionKey, *PSecPkgContext_SessionKey;

// used by nego2
typedef struct _SecPkgContext_NegoKeys
{
  unsigned long KeyType;
  unsigned short KeyLength;
   unsigned char* KeyValue;
  unsigned long  VerifyKeyType;
  unsigned short VerifyKeyLength;
  unsigned char* VerifyKeyValue;
} SecPkgContext_NegoKeys, * PSecPkgContext_NegoKeys;

typedef struct _SecPkgContext_PackageInfoW
{
    PSecPkgInfoW PackageInfo;
} SecPkgContext_PackageInfoW, * PSecPkgContext_PackageInfoW;



typedef struct _SecPkgContext_PackageInfoA
{
    PSecPkgInfoA PackageInfo;
} SecPkgContext_PackageInfoA, * PSecPkgContext_PackageInfoA;

// begin_ntifs

typedef struct _SecPkgContext_UserFlags
{
    unsigned long UserFlags;
} SecPkgContext_UserFlags, * PSecPkgContext_UserFlags;

typedef struct _SecPkgContext_Flags
{
    unsigned long Flags;
} SecPkgContext_Flags, * PSecPkgContext_Flags;
]]



ffi.cdef[[
typedef struct _SecPkgContext_NegotiationInfoA
{
    PSecPkgInfoA    PackageInfo ;
    unsigned long   NegotiationState ;
} SecPkgContext_NegotiationInfoA, * PSecPkgContext_NegotiationInfoA ;

// begin_ntifs
typedef struct _SecPkgContext_NegotiationInfoW
{
    PSecPkgInfoW    PackageInfo ;
    unsigned long   NegotiationState ;
} SecPkgContext_NegotiationInfoW, * PSecPkgContext_NegotiationInfoW ;
]]



ffi.cdef[[
static const int SECPKG_NEGOTIATION_COMPLETE          =   0;
static const int SECPKG_NEGOTIATION_OPTIMISTIC        =   1;
static const int SECPKG_NEGOTIATION_IN_PROGRESS       =   2;
static const int SECPKG_NEGOTIATION_DIRECT            =   3;
static const int SECPKG_NEGOTIATION_TRY_MULTICRED     =   4;
]]

ffi.cdef[[
typedef struct _SecPkgContext_NativeNamesW
{
    SEC_WCHAR * sClientName;
    SEC_WCHAR * sServerName;
} SecPkgContext_NativeNamesW, * PSecPkgContext_NativeNamesW;

typedef struct _SecPkgContext_NativeNamesA
{
    SEC_CHAR * sClientName;
    SEC_CHAR * sServerName;
} SecPkgContext_NativeNamesA, * PSecPkgContext_NativeNamesA;
]]




ffi.cdef[[
typedef struct _SecPkgContext_CredentialNameW
{
    unsigned long CredentialType;
    SEC_WCHAR *sCredentialName;
} SecPkgContext_CredentialNameW, * PSecPkgContext_CredentialNameW;



typedef struct _SecPkgContext_CredentialNameA
{
    unsigned long CredentialType;
    SEC_CHAR *sCredentialName;
} SecPkgContext_CredentialNameA, * PSecPkgContext_CredentialNameA;
]]


ffi.cdef[[
typedef struct _SecPkgContext_AccessToken
{
    void * AccessToken;
} SecPkgContext_AccessToken, * PSecPkgContext_AccessToken;

typedef struct _SecPkgContext_TargetInformation
{
    unsigned long MarshalledTargetInfoLength;
    unsigned char * MarshalledTargetInfo;

} SecPkgContext_TargetInformation, * PSecPkgContext_TargetInformation;

typedef struct _SecPkgContext_AuthzID
{
    unsigned long AuthzIDLength;
    char * AuthzID;

} SecPkgContext_AuthzID, * PSecPkgContext_AuthzID;

typedef struct _SecPkgContext_Target
{
    unsigned long TargetLength;
    char * Target;

} SecPkgContext_Target, * PSecPkgContext_Target;


typedef struct _SecPkgContext_ClientSpecifiedTarget
{
    SEC_WCHAR * sTargetName;
} SecPkgContext_ClientSpecifiedTarget, * PSecPkgContext_ClientSpecifiedTarget;

typedef struct _SecPkgContext_Bindings
{
    unsigned long BindingsLength;
    SEC_CHANNEL_BINDINGS * Bindings;
} SecPkgContext_Bindings, * PSecPkgContext_Bindings;
]]




ffi.cdef[[
//
// Flags for ExportSecurityContext
//

static const int SECPKG_CONTEXT_EXPORT_RESET_NEW        = 0x00000001;      // New context is reset to initial state
static const int SECPKG_CONTEXT_EXPORT_DELETE_OLD       = 0x00000002;      // Old context is deleted during export
// This is only valid in W2K3SP1 and greater
static const int SECPKG_CONTEXT_EXPORT_TO_KERNEL        = 0x00000004;      // Context is to be transferred to the kernel
]]

if ISSP_MODE == 0 then     -- For Kernel mode
ffi.cdef[[

SECURITY_STATUS 
AcquireCredentialsHandleW(
     PSECURITY_STRING pPrincipal,
         PSECURITY_STRING pPackage,
         unsigned long fCredentialUse,       // Flags indicating use
     void * pvLogonId,           // Pointer to logon ID
     void * pAuthData,           // Package specific data
     SEC_GET_KEY_FN pGetKeyFn,           // Pointer to GetKey() func
     void * pvGetKeyArgument,    // Value to pass to GetKey()
        PCredHandle phCredential,           // (out) Cred Handle
     PTimeStamp ptsExpiry                // (out) Lifetime (optional)
    );

typedef SECURITY_STATUS
(* ACQUIRE_CREDENTIALS_HANDLE_FN_W)(
    PSECURITY_STRING,
    PSECURITY_STRING,
    unsigned long,
    void *,
    void *,
    SEC_GET_KEY_FN,
    void *,
    PCredHandle,
    PTimeStamp);
]]
else

end







if ISSP_MODE == 0 then      -- For Kernel mode
ffi.cdef[[

SECURITY_STATUS 
AddCredentialsW(
         PCredHandle hCredentials,
     PSECURITY_STRING pPrincipal,
         PSECURITY_STRING pPackage,
         unsigned long fCredentialUse,       // Flags indicating use
     void * pAuthData,           // Package specific data
     SEC_GET_KEY_FN pGetKeyFn,           // Pointer to GetKey() func
     void * pvGetKeyArgument,    // Value to pass to GetKey()
     PTimeStamp ptsExpiry                // (out) Lifetime (optional)
    );

typedef SECURITY_STATUS
(* ADD_CREDENTIALS_FN_W)(
    PCredHandle,
    PSECURITY_STRING,
    PSECURITY_STRING,

    unsigned long,
    void *,
    SEC_GET_KEY_FN,
    void *,
    PTimeStamp);
]]
else

end






--[[
////////////////////////////////////////////////////////////////////////
///
/// Password Change Functions
///
////////////////////////////////////////////////////////////////////////
--]]

if ISSP_MODE ~= 0 then

end -- ISSP_MODE

--[[
////////////////////////////////////////////////////////////////////////
///
/// Context Management Functions
///
////////////////////////////////////////////////////////////////////////
--]]

if ISSP_MODE == 0 then
ffi.cdef[[

SECURITY_STATUS 
InitializeSecurityContextW(
    PCredHandle phCredential,               // Cred to base context
    PCtxtHandle phContext,                  // Existing context (OPT)
    PSECURITY_STRING pTargetName,
    unsigned long fContextReq,              // Context Requirements
    unsigned long Reserved1,                // Reserved, MBZ
    unsigned long TargetDataRep,            // Data rep of target
    PSecBufferDesc pInput,                  // Input Buffers
    unsigned long Reserved2,                // Reserved, MBZ
    PCtxtHandle phNewContext,               // (out) New Context handle
    PSecBufferDesc pOutput,                 // (inout) Output Buffers
    unsigned long * pfContextAttr,  // (out) Context attrs
    PTimeStamp ptsExpiry                    // (out) Life span (OPT)
    );

typedef SECURITY_STATUS
(* INITIALIZE_SECURITY_CONTEXT_FN_W)(
    PCredHandle,
    PCtxtHandle,
    PSECURITY_STRING,
    unsigned long,
    unsigned long,
    unsigned long,
    PSecBufferDesc,
    unsigned long,
    PCtxtHandle,
    PSecBufferDesc,
    unsigned long *,
    PTimeStamp);
]]
else

end


ffi.cdef[[
///////////////////////////////////////////////////////////////////
////
////    Message Support API
////
//////////////////////////////////////////////////////////////////


// This only exists win Win2k3 and Greater
static const int SECQOP_WRAP_NO_ENCRYPT     = 0x80000001;
static const int SECQOP_WRAP_OOB_DATA       = 0x40000000;

]]


if ISSP_MODE == 0 then
ffi.cdef[[

SECURITY_STATUS 
QuerySecurityPackageInfoW(
    PSECURITY_STRING pPackageName,
    PSecPkgInfoW *ppPackageInfo     // Receives package info
    );

typedef SECURITY_STATUS
(* QUERY_SECURITY_PACKAGE_INFO_FN_W)(
    PSECURITY_STRING,
    PSecPkgInfoW *);
]]
else

end








ffi.cdef[[
typedef enum _SecDelegationType {
    SecFull,
    SecService,
    SecTree,
    SecDirectory,
    SecObject
} SecDelegationType, * PSecDelegationType;
]]


if ISSP_MODE == 0 then
ffi.cdef[[
SECURITY_STATUS 
DelegateSecurityContext(
    PCtxtHandle         phContext,          // IN Active context to delegate
    PSECURITY_STRING    pTarget,            // IN Target path
    SecDelegationType   DelegationType,     // IN Type of delegation
    PTimeStamp          pExpiry,            // IN OPTIONAL time limit
    PSecBuffer          pPackageParameters, // IN OPTIONAL package specific
    PSecBufferDesc      pOutput);           // OUT Token for applycontroltoken.
]]
else
ffi.cdef[[
SECURITY_STATUS 
DelegateSecurityContext(
    PCtxtHandle         phContext,          // IN Active context to delegate
    LPSTR          pszTarget,
    SecDelegationType   DelegationType,     // IN Type of delegation
    PTimeStamp          pExpiry,            // IN OPTIONAL time limit
    PSecBuffer          pPackageParameters, // IN OPTIONAL package specific
    PSecBufferDesc      pOutput);           // OUT Token for applycontroltoken.
]]
end


--[[
///////////////////////////////////////////////////////////////////////////
////
////    Proxies
////
///////////////////////////////////////////////////////////////////////////


//
// Proxies are only available on NT platforms
//
--]]





if ISSP_MODE == 0 then
ffi.cdef[[

SECURITY_STATUS 
ImportSecurityContextW(
     PSECURITY_STRING     pszPackage,
     PSecBuffer           pPackedContext,        // (in) marshalled context
     void *               Token,                 // (in, optional) handle to token for context
    PCtxtHandle          phContext              // (out) new context handle
    );

typedef SECURITY_STATUS
(* IMPORT_SECURITY_CONTEXT_FN_W)(
    PSECURITY_STRING,
    PSecBuffer,
    void *,
    PCtxtHandle
    );
]]
else

end





if ISSP_MODE == 0 then
ffi.cdef[[

NTSTATUS
SecMakeSPN(
     PUNICODE_STRING ServiceClass,
     PUNICODE_STRING ServiceName,
     PUNICODE_STRING InstanceName OPTIONAL,
     USHORT InstancePort OPTIONAL,
     PUNICODE_STRING Referrer OPTIONAL,
      PUNICODE_STRING Spn,
     PULONG Length OPTIONAL,
     BOOLEAN Allocate
    );



NTSTATUS
SecMakeSPNEx(
     PUNICODE_STRING ServiceClass,
     PUNICODE_STRING ServiceName,
     PUNICODE_STRING InstanceName OPTIONAL,
     USHORT InstancePort OPTIONAL,
     PUNICODE_STRING Referrer OPTIONAL,
     PUNICODE_STRING TargetInfo OPTIONAL,
      PUNICODE_STRING Spn,
     PULONG Length OPTIONAL,
     BOOLEAN Allocate
    );



NTSTATUS
SecMakeSPNEx2(
     PUNICODE_STRING ServiceClass,
     PUNICODE_STRING ServiceName,
     PUNICODE_STRING InstanceName OPTIONAL,
     USHORT InstancePort OPTIONAL,
     PUNICODE_STRING Referrer OPTIONAL,
     PUNICODE_STRING InTargetInfo OPTIONAL,
      PUNICODE_STRING Spn,
     PULONG TotalSize OPTIONAL,
     BOOLEAN Allocate,
     BOOLEAN IsTargetInfoMarshaled
    );



NTSTATUS
SecLookupAccountSid(
         PSID Sid,
        PULONG NameSize,
      PUNICODE_STRING NameBuffer,
        PULONG DomainSize OPTIONAL,
     PUNICODE_STRING DomainBuffer OPTIONAL,
        PSID_NAME_USE NameUse
    );


NTSTATUS
SecLookupAccountName(
           PUNICODE_STRING Name,
        PULONG SidSize,
          PSID Sid,
          PSID_NAME_USE NameUse,
          PULONG DomainSize OPTIONAL,
    PUNICODE_STRING ReferencedDomain OPTIONAL
    );




NTSTATUS
SecLookupWellKnownSid(
           WELL_KNOWN_SID_TYPE SidType,
          PSID Sid,
           ULONG SidBufferSize,
    PULONG SidSize OPTIONAL
    );
]]
end   -- Kernel mode



-- #define FreeCredentialHandle FreeCredentialsHandle


if SECURITY_WIN32 then
ffi.cdef[[
//
// SASL Profile Support
//

static const int SASL_OPTION_SEND_SIZE      = 1;       // Maximum size to send to peer
static const int SASL_OPTION_RECV_SIZE      = 2;       // Maximum size willing to receive
static const int SASL_OPTION_AUTHZ_STRING   = 3;       // Authorization string
static const int SASL_OPTION_AUTHZ_PROCESSING   = 4;       // Authorization string processing

typedef enum _SASL_AUTHZID_STATE {
    Sasl_AuthZIDForbidden,             // allow no AuthZID strings to be specified - error out (default)
    Sasl_AuthZIDProcessed             // AuthZID Strings processed by Application or SSP
} SASL_AUTHZID_STATE ;

]]
end

--
-- This is the legacy credentials structure.
-- The EX version below is preferred.


if not _AUTH_IDENTITY_EX2_DEFINED then
_AUTH_IDENTITY_EX2_DEFINED = true

ffi.cdef[[
static const int SEC_WINNT_AUTH_IDENTITY_VERSION_2 = 0x201;

typedef struct _SEC_WINNT_AUTH_IDENTITY_EX2 {
   unsigned long Version; // contains SEC_WINNT_AUTH_IDENTITY_VERSION_2
   unsigned short cbHeaderLength;
   unsigned long cbStructureLength;
   unsigned long UserOffset;                // Non-NULL terminated string, unicode only
   unsigned short UserLength;               // # of bytes (NOT WCHARs), not including NULL.
   unsigned long DomainOffset;              // Non-NULL terminated string, unicode only
   unsigned short DomainLength;             // # of bytes (NOT WCHARs), not including NULL.
   unsigned long PackedCredentialsOffset;   // Non-NULL terminated string, unicode only
   unsigned short PackedCredentialsLength;  // # of bytes (NOT WCHARs), not including NULL.
   unsigned long Flags;
   unsigned long PackageListOffset;         // Non-NULL terminated string, unicode only
   unsigned short PackageListLength;
} SEC_WINNT_AUTH_IDENTITY_EX2, *PSEC_WINNT_AUTH_IDENTITY_EX2;
]]
end -- _AUTH_IDENTITY_EX2_DEFINED


if not _AUTH_IDENTITY_DEFINED then
_AUTH_IDENTITY_DEFINED = true
ffi.cdef[[
//
// This was not defined in NTIFS.h for windows 2000 however
// this struct has always been there and are safe to use
// in windows 2000 and above.
//

static const int SEC_WINNT_AUTH_IDENTITY_ANSI    = 0x1;
static const int SEC_WINNT_AUTH_IDENTITY_UNICODE = 0x2;

typedef struct _SEC_WINNT_AUTH_IDENTITY_W {
  unsigned short *User;         //  Non-NULL terminated string.
  unsigned long UserLength;     //  # of characters (NOT bytes), not including NULL.
  unsigned short *Domain;       //  Non-NULL terminated string.
  unsigned long DomainLength;   //  # of characters (NOT bytes), not including NULL.
  unsigned short *Password;     //  Non-NULL terminated string.
  unsigned long PasswordLength; //  # of characters (NOT bytes), not including NULL.
  unsigned long Flags;
} SEC_WINNT_AUTH_IDENTITY_W, *PSEC_WINNT_AUTH_IDENTITY_W;
]]

_AUTH_IDENTITY_A_DEFINED = true

ffi.cdef[[
typedef struct _SEC_WINNT_AUTH_IDENTITY_A {
  unsigned char *User;          //  Non-NULL terminated string.
  unsigned long UserLength;     //  # of characters (NOT bytes), not including NULL.
  unsigned char *Domain;        //  Non-NULL terminated string.
  unsigned long DomainLength;   //  # of characters (NOT bytes), not including NULL.
  unsigned char *Password;      //  Non-NULL terminated string.
  unsigned long PasswordLength; //  # of characters (NOT bytes), not including NULL.
  unsigned long Flags;
} SEC_WINNT_AUTH_IDENTITY_A, *PSEC_WINNT_AUTH_IDENTITY_A;
]]

end -- _AUTH_IDENTITY_DEFINED                                 

--[[
//
// This is the combined authentication identity structure that may be
// used with the negotiate package, NTLM, Kerberos, or SCHANNEL
//
--]]

if not SEC_WINNT_AUTH_IDENTITY_VERSION then
ffi.cdef[[
static const int SEC_WINNT_AUTH_IDENTITY_VERSION = 0x200;

typedef struct _SEC_WINNT_AUTH_IDENTITY_EXW {
    unsigned long Version;
    unsigned long Length;
    unsigned short *User;           //  Non-NULL terminated string.
    unsigned long UserLength;       //  # of characters (NOT bytes), not including NULL.
    unsigned short *Domain;         //  Non-NULL terminated string.
    unsigned long DomainLength;     //  # of characters (NOT bytes), not including NULL.
    unsigned short *Password;       //  Non-NULL terminated string.
    unsigned long PasswordLength;   //  # of characters (NOT bytes), not including NULL.
    unsigned long Flags;
    unsigned short *PackageList;
    unsigned long PackageListLength;
} SEC_WINNT_AUTH_IDENTITY_EXW, *PSEC_WINNT_AUTH_IDENTITY_EXW;
]]

ffi.cdef[[
typedef struct _SEC_WINNT_AUTH_IDENTITY_EXA {
    unsigned long Version;
    unsigned long Length;
    unsigned char *User;            //  Non-NULL terminated string.
    unsigned long UserLength;       //  # of characters (NOT bytes), not including NULL.
    unsigned char *Domain;          //  Non-NULL terminated string.
    unsigned long DomainLength;     //  # of characters (NOT bytes), not including NULL.
    unsigned char *Password;        //  Non-NULL terminated string.
    unsigned long PasswordLength;   //  # of characters (NOT bytes), not including NULL.
    unsigned long Flags;
    unsigned char * PackageList;
    unsigned long PackageListLength;
} SEC_WINNT_AUTH_IDENTITY_EXA, *PSEC_WINNT_AUTH_IDENTITY_EXA;
]]


end -- SEC_WINNT_AUTH_IDENTITY_VERSION



if not _AUTH_IDENTITY_INFO_DEFINED then
_AUTH_IDENTITY_INFO_DEFINED = true

ffi.cdef[[
//
// the procedure for how to parse a SEC_WINNT_AUTH_IDENTITY_INFO structure:
//
// 1) First check the first DWORD of SEC_WINNT_AUTH_IDENTITY_INFO, if the first
//   DWORD is 0x200, it is either an AuthIdExw or AuthIdExA, otherwise if the first
//   DWORD is 0x201, the structure is an AuthIdEx2 structure. Otherwise the structure
//   is either an AuthId_a or an AuthId_w.
//
// 2) Secondly check the flags for SEC_WINNT_AUTH_IDENTITY_ANSI or
//   SEC_WINNT_AUTH_IDENTITY_UNICODE, the presence of the former means the structure
//   is an ANSI structure. Otherwise, the structure is the wide version.  Note that
//   AuthIdEx2 does not have an ANSI version so this check does not apply to it.
//

typedef union _SEC_WINNT_AUTH_IDENTITY_INFO {
    SEC_WINNT_AUTH_IDENTITY_EXW AuthIdExw;
    SEC_WINNT_AUTH_IDENTITY_EXA AuthIdExa;
    SEC_WINNT_AUTH_IDENTITY_A AuthId_a;
    SEC_WINNT_AUTH_IDENTITY_W AuthId_w;
    SEC_WINNT_AUTH_IDENTITY_EX2 AuthIdEx2;
} SEC_WINNT_AUTH_IDENTITY_INFO, *PSEC_WINNT_AUTH_IDENTITY_INFO;

// the credential structure is encrypted via
// RtlEncryptMemory(OptionFlags = 0)
static const int SEC_WINNT_AUTH_IDENTITY_FLAGS_PROCESS_ENCRYPTED = 0x10;

// the credential structure is protected by local system via
// RtlEncryptMemory(OptionFlags =
// IOCTL_KSEC_ENCRYPT_MEMORY_SAME_LOGON)
static const int SEC_WINNT_AUTH_IDENTITY_FLAGS_SYSTEM_PROTECTED  =0x20;

static const int SEC_WINNT_AUTH_IDENTITY_FLAGS_RESERVED       =0x10000;
static const int SEC_WINNT_AUTH_IDENTITY_FLAGS_NULL_USER      =0x20000;
static const int SEC_WINNT_AUTH_IDENTITY_FLAGS_NULL_DOMAIN    =0x40000;

//
//  These bits are for communication between SspiPromptForCredentials()
//  and the credential providers. Do not use these bits for any other
//  purpose.
//

static const int SEC_WINNT_AUTH_IDENTITY_FLAGS_SSPIPFC_USE_MASK = 0xFF000000;

//
//  Instructs the credential provider to not save credentials itself
//  when caller selects the "Remember my credential" checkbox.
//

static const int SEC_WINNT_AUTH_IDENTITY_FLAGS_SSPIPFC_SAVE_CRED_BY_CALLER  = 0x80000000;

//
//  State of the "Remember my credentials" checkbox.
//  When set, indicates checked; when cleared, indicates unchecked.
//

static const int SEC_WINNT_AUTH_IDENTITY_FLAGS_SSPIPFC_SAVE_CRED_CHECKED     = 0x40000000;



static const int  SEC_WINNT_AUTH_IDENTITY_FLAGS_VALID_SSPIPFC_FLAGS   =(SEC_WINNT_AUTH_IDENTITY_FLAGS_SSPIPFC_SAVE_CRED_BY_CALLER | 
    SEC_WINNT_AUTH_IDENTITY_FLAGS_SSPIPFC_SAVE_CRED_CHECKED);
]]

end -- _AUTH_IDENTITY_INFO_DEFINED

if not _SSPIPFC_NONE_ then

else 
ffi.cdef[[
// the internal view
typedef PSEC_WINNT_AUTH_IDENTITY_INFO PSEC_WINNT_AUTH_IDENTITY_OPAQUE;
]]
end -- _SSPIPFC_NONE_

ffi.cdef[[
//
//  dwFlags parameter of SspiPromptForCredentials():
//

//
//  Indicates that the credentials should not be saved if
//  the user selects the 'save' (or 'remember my password')
//  checkbox in the credential dialog box. The location pointed
//  to by the pfSave parameter indicates whether or not the user
//  selected the checkbox.
//
//  Note that some credential providers won't honour this flag and
//  may save the credentials in a persistent manner anyway if the
//  user selects the 'save' checbox.
//

static const int SSPIPFC_SAVE_CRED_BY_CALLER    = 0x00000001;

static const int SSPIPFC_VALID_FLAGS = (SSPIPFC_SAVE_CRED_BY_CALLER);
]]

if not _SSPIPFC_NONE_ then -- the public view

--[[ 
    Use SspiFreeAuthIdentity() to free the buffer returned
    in ppAuthIdentity.
--]]

if _CREDUI_INFO_DEFINED then
ffi.cdef[[
unsigned long
SspiPromptForCredentialsW(
    PCWSTR pszTargetName,
    PCREDUI_INFOW pUiInfo,
    unsigned long dwAuthError,
    PCWSTR pszPackage,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE pInputAuthIdentity,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE* ppAuthIdentity,
    int* pfSave,
    unsigned long dwFlags
    );

unsigned long
SspiPromptForCredentialsA(
    PCSTR pszTargetName,
    PCREDUI_INFOA pUiInfo,
    unsigned long dwAuthError,
    PCSTR pszPackage,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE pInputAuthIdentity,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE* ppAuthIdentity,
    int* pfSave,
    unsigned long dwFlags
    );
]]
else
ffi.cdef[[
unsigned long
SspiPromptForCredentialsW(
    PCWSTR pszTargetName,
    PVOID pUiInfo,
    unsigned long dwAuthError,
    PCWSTR pszPackage,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE pInputAuthIdentity,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE* ppAuthIdentity,
    int* pfSave,
    unsigned long dwFlags
    );

unsigned long
SspiPromptForCredentialsA(
    PCSTR pszTargetName,
    PVOID pUiInfo,
    unsigned long dwAuthError,
    PCSTR pszPackage,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE pInputAuthIdentity,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE* ppAuthIdentity,
    int* pfSave,
    unsigned long dwFlags
    );
]]
end

end -- _SSPIPFC_NONE_

if _SEC_WINNT_AUTH_TYPES then
ffi.cdef[[
typedef struct _SEC_WINNT_AUTH_BYTE_VECTOR {
    unsigned long ByteArrayOffset; // each element is a byte
    unsigned short ByteArrayLength; //
} SEC_WINNT_AUTH_BYTE_VECTOR, *PSEC_WINNT_AUTH_BYTE_VECTOR;

typedef struct _SEC_WINNT_AUTH_DATA {
   GUID CredType;
   SEC_WINNT_AUTH_BYTE_VECTOR CredData;
} SEC_WINNT_AUTH_DATA, *PSEC_WINNT_AUTH_DATA;

typedef struct _SEC_WINNT_AUTH_PACKED_CREDENTIALS {
   unsigned short cbHeaderLength;    // the length of the header
   unsigned short cbStructureLength; // pay load length including the header
   SEC_WINNT_AUTH_DATA AuthData;
} SEC_WINNT_AUTH_PACKED_CREDENTIALS, *PSEC_WINNT_AUTH_PACKED_CREDENTIALS;
]]



ffi.cdef[[
typedef struct _SEC_WINNT_AUTH_DATA_PASSWORD {
   SEC_WINNT_AUTH_BYTE_VECTOR UnicodePassword;
} SEC_WINNT_AUTH_DATA_PASSWORD, PSEC_WINNT_AUTH_DATA_PASSWORD;
]]

ffi.cdef[[
typedef struct _SEC_WINNT_AUTH_CERTIFICATE_DATA {
   unsigned short cbHeaderLength;
   unsigned short cbStructureLength;
   SEC_WINNT_AUTH_BYTE_VECTOR Certificate;
} SEC_WINNT_AUTH_CERTIFICATE_DATA, *PSEC_WINNT_AUTH_CERTIFICATE_DATA;

typedef struct _SEC_WINNT_CREDUI_CONTEXT_VECTOR
{
   ULONG CredUIContextArrayOffset; // offset starts at the beginning of
   // this structure, and each element is a SEC_WINNT_AUTH_BYTE_VECTOR that
   // describes the flat CredUI context returned by SpGetCredUIContext()
   USHORT CredUIContextCount;
} SEC_WINNT_CREDUI_CONTEXT_VECTOR, *PSEC_WINNT_CREDUI_CONTEXT_VECTOR;

typedef struct _SEC_WINNT_AUTH_SHORT_VECTOR
{
    ULONG ShortArrayOffset; // each element is a short
    USHORT ShortArrayCount; // number of characters
} SEC_WINNT_AUTH_SHORT_VECTOR, *PSEC_WINNT_AUTH_SHORT_VECTOR;


// free the returned memory using SspiLocalFree

SECURITY_STATUS
SspiGetCredUIContext(
   HANDLE ContextHandle,
   GUID* CredType,
   LUID* LogonId, // use this LogonId, the caller must be localsystem to supply a logon id
   PSEC_WINNT_CREDUI_CONTEXT_VECTOR* CredUIContexts,
    HANDLE* TokenHandle
   );

SECURITY_STATUS
SspiUpdateCredentials(
   HANDLE ContextHandle,
   GUID* CredType,
   ULONG FlatCredUIContextLength,
   PUCHAR FlatCredUIContext
   );
]]

ffi.cdef[[
typedef struct _CREDUIWIN_MARSHALED_CONTEXT
{
    GUID StructureType;
    USHORT cbHeaderLength;
    LUID LogonId; // user's logon id
    GUID MarshaledDataType;
    ULONG MarshaledDataOffset;
    USHORT MarshaledDataLength;
} CREDUIWIN_MARSHALED_CONTEXT, *PCREDUIWIN_MARSHALED_CONTEXT;
]]


if _CREDUI_INFO_DEFINED then
ffi.cdef[[
typedef struct _SEC_WINNT_CREDUI_CONTEXT
{
    USHORT cbHeaderLength;
    HANDLE CredUIContextHandle; // the handle to call SspiGetCredUIContext()
    PCREDUI_INFOW UIInfo; // input from SspiPromptForCredentials()
    ULONG dwAuthError; // the authentication error
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE pInputAuthIdentity;
    PUNICODE_STRING TargetName;
} SEC_WINNT_CREDUI_CONTEXT, *PSEC_WINNT_CREDUI_CONTEXT;
]]
else
ffi.cdef[[
typedef struct _SEC_WINNT_CREDUI_CONTEXT
{
    USHORT cbHeaderLength;
    HANDLE CredUIContextHandle; // the handle to call SspiGetCredUIContext()
    PVOID UIInfo;
    ULONG dwAuthError; // the authentication error
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE pInputAuthIdentity;
    PUNICODE_STRING TargetName;
} SEC_WINNT_CREDUI_CONTEXT, *PSEC_WINNT_CREDUI_CONTEXT;
]]
end




ffi.cdef[[
typedef struct _SEC_WINNT_AUTH_PACKED_CREDENTIALS_EX {
   unsigned short cbHeaderLength;
   unsigned long Flags; // contains the Flags field in
                        // SEC_WINNT_AUTH_IDENTITY_EX
   SEC_WINNT_AUTH_BYTE_VECTOR PackedCredentials;
   SEC_WINNT_AUTH_SHORT_VECTOR PackageList;
} SEC_WINNT_AUTH_PACKED_CREDENTIALS_EX, *PSEC_WINNT_AUTH_PACKED_CREDENTIALS_EX;

//
// free the returned memory using SspiLocalFree
//

SECURITY_STATUS
SspiUnmarshalCredUIContext(
    PUCHAR MarshaledCredUIContext,
    ULONG MarshaledCredUIContextLength,
    PSEC_WINNT_CREDUI_CONTEXT* CredUIContext
    );
]]
end -- _SEC_WINNT_AUTH_TYPES



	
ffi.cdef[[
//
//  Convert the _OPAQUE structure passed in to the
//  3 tuple <username, domainname, 'password'>.
//
//  Note: The 'strings' returned need not necessarily be
//  in user recognisable form. The purpose of this API
//  is to 'flatten' the _OPAQUE structure into the 3 tuple.
//  User recognisable <username, domainname> can always be
//  obtained by passing NULL to the pszPackedCredentialsString
//  parameter.
//
// zero out the pszPackedCredentialsString then
// free the returned memory using SspiLocalFree()
//





//
// free the returned memory using SspiFreeAuthIdentity()
//



//
// use only for the memory returned by SspiCopyAuthIdentity().
// Internally calls SspiZeroAuthIdentity().
//




//
// call SspiFreeAuthIdentity to free the returned AuthIdentity 
// which zeroes out the credentials blob before freeing it
//





//
// zero out the returned AuthIdentityByteArray then
// free the returned memory using SspiLocalFree()
//



//
// free the returned auth identity using SspiFreeAuthIdentity()
//



BOOLEAN
SspiIsPromptingNeeded(unsigned long ErrorOrNtStatus);






//
// Common types used by negotiable security packages
//
// These are defined after W2K
//

static const int SEC_WINNT_AUTH_IDENTITY_MARSHALLED     = 0x4;     // all data is in one buffer
static const int SEC_WINNT_AUTH_IDENTITY_ONLY           = 0x8;     // these credentials are for identity only - no PAC needed


]]








ffi.cdef[[
//#define SECURITY_

// Function table has all routines through DecryptMessage
static const int SECURITY_SUPPORT_PROVIDER_INTERFACE_VERSION    = 1;   

// Function table has all routines through SetContextAttributes
static const int SECURITY_SUPPORT_PROVIDER_INTERFACE_VERSION_2  = 2;  

// Function table has all routines through SetCredentialsAttributes
static const int SECURITY_SUPPORT_PROVIDER_INTERFACE_VERSION_3  = 3;  

// Function table has all routines through ChangeAccountPassword
static const int SECURITY_SUPPORT_PROVIDER_INTERFACE_VERSION_4  = 4;  
]]


return {
    Lib = ffi.load("Secur32");
}

--[[
	Finishing up Security.h

if SECURITY_WIN32 or SECURITY_KERNEL then
    require("secext");
end

--]]



require("sspicli");

