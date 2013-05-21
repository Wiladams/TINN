-- sspicli.lua
-- 

local ffi = require("ffi");

require("WTypes");
require("WinNT");
require("SubAuth");
require("NTSecAPI");

local advapiLib = ffi.load("AdvApi32");
local secur32lib = ffi.load("secur32");


--[=[
if not __SECSTATUS_DEFINED__ then
ffi.cdef[[
typedef LONG SECURITY_STATUS;
]]
__SECSTATUS_DEFINED__ = true;
end
--]=]

ffi.cdef[[
typedef WCHAR SEC_WCHAR;
typedef CHAR SEC_CHAR;
]]

if not __SECHANDLE_DEFINED__ then
ffi.cdef[[
typedef struct _SecHandle
{
    ULONG_PTR dwLower ;
    ULONG_PTR dwUpper ;
} SecHandle, * PSecHandle ;
]]
__SECHANDLE_DEFINED__ = true
end -- __SECHANDLE_DEFINED__

SecInvalidateHandle = function( x )
    ffi.cast("PSecHandle", x).dwLower = ffi.cast("ULONG_PTR", ((INT_PTR)-1)) ;
    ffi.cast("PSecHandle", x).dwUpper = ffi.cast("ULONG_PTR", ((INT_PTR)-1)) ;
end

SecIsValidHandle = function( x )
    return x.dwLower ~= ffi.cast("ULONG_PTR", -1) and 
        x.dwUpper ~= ffi.cast("ULONG_PTR", -1);
end

ffi.cdef[[
//
// SecBuffer
//
//  Generic memory descriptors for buffers passed in to the security
//  API
//

typedef struct _SecBuffer {
    unsigned long cbBuffer;             // Size of the buffer, in bytes
    unsigned long BufferType;           // Type of the buffer (below)
    void * pvBuffer;            // Pointer to the buffer
} SecBuffer, * PSecBuffer;

typedef struct _SecBufferDesc {
    unsigned long ulVersion;            // Version number
    unsigned long cBuffers;             // Number of buffers
    PSecBuffer pBuffers;                // Pointer to array of buffers
} SecBufferDesc, * PSecBufferDesc;
]]

ffi.cdef[[
typedef LARGE_INTEGER _SECURITY_INTEGER, SECURITY_INTEGER, *PSECURITY_INTEGER; 
]]

ffi.cdef[[
typedef SECURITY_INTEGER TimeStamp;                 
typedef SECURITY_INTEGER * PTimeStamp;      
]]

ffi.cdef[[
//
// pseudo handle value: the handle has already been deleted
//

static const int SEC_DELETED_HANDLE  = ((ULONG_PTR) (-2));

typedef SecHandle CredHandle;
typedef PSecHandle PCredHandle;

typedef SecHandle CtxtHandle;
typedef PSecHandle PCtxtHandle;
]]

ffi.cdef[[
typedef void
(* SEC_GET_KEY_FN) (
    void * Arg,                 // Argument passed in
    void * Principal,           // Principal ID
    unsigned long KeyVer,               // Key Version
    void * * Key,       // Returned ptr to key
    SECURITY_STATUS * Status    // returned status
    );
]]


ffi.cdef[[
//
// Routines for manipulating packages
//

typedef struct _SECURITY_PACKAGE_OPTIONS {
    unsigned long   Size;
    unsigned long   Type;
    unsigned long   Flags;
    unsigned long   SignatureSize;
    void *  Signature;
} SECURITY_PACKAGE_OPTIONS, * PSECURITY_PACKAGE_OPTIONS;
]]

ffi.cdef[[
static const int SECPKG_OPTIONS_TYPE_UNKNOWN =0;
static const int SECPKG_OPTIONS_TYPE_LSA     =1;
static const int SECPKG_OPTIONS_TYPE_SSPI    =2;

static const int SECPKG_OPTIONS_PERMANENT    =0x00000001;
]]


ffi.cdef[[
//
// SecPkgInfo structure
//
//  Provides general information about a security provider
//

typedef struct _SecPkgInfoW
{
    unsigned long fCapabilities;        // Capability bitmask
    unsigned short wVersion;            // Version of driver
    unsigned short wRPCID;              // ID for RPC Runtime
    unsigned long cbMaxToken;           // Size of authentication token (max)
    SEC_WCHAR * Name;           // Text name
    SEC_WCHAR * Comment;        // Comment
} SecPkgInfoW, * PSecPkgInfoW;



typedef struct _SecPkgInfoA
{
    unsigned long fCapabilities;        // Capability bitmask
    unsigned short wVersion;            // Version of driver
    unsigned short wRPCID;              // ID for RPC Runtime
    unsigned long cbMaxToken;           // Size of authentication token (max)

    SEC_CHAR * Name;            // Text name


    SEC_CHAR * Comment;         // Comment
} SecPkgInfoA, * PSecPkgInfoA;
]]


ffi.cdef[[
typedef enum
{
    // Examples for the following formats assume a fictitous company
    // which hooks into the global X.500 and DNS name spaces as follows.
    //
    // Enterprise root domain in DNS is
    //
    //      widget.com
    //
    // Enterprise root domain in X.500 (RFC 1779 format) is
    //
    //      O=Widget, C=US
    //
    // There exists the child domain
    //
    //      engineering.widget.com
    //
    // equivalent to
    //
    //      OU=Engineering, O=Widget, C=US
    //
    // There exists a container within the Engineering domain
    //
    //      OU=Software, OU=Engineering, O=Widget, C=US
    //
    // There exists the user
    //
    //      CN=John Doe, OU=Software, OU=Engineering, O=Widget, C=US
    //
    // And this user's downlevel (pre-ADS) user name is
    //
    //      Engineering\JohnDoe

    // unknown name type
    NameUnknown = 0,

    // CN=John Doe, OU=Software, OU=Engineering, O=Widget, C=US
    NameFullyQualifiedDN = 1,

    // Engineering\JohnDoe
    NameSamCompatible = 2,

    // Probably "John Doe" but could be something else.  I.e. The
    // display name is not necessarily the defining RDN.
    NameDisplay = 3,


    // String-ized GUID as returned by IIDFromString().
    // eg: {4fa050f0-f561-11cf-bdd9-00aa003a77b6}
    NameUniqueId = 6,

    // engineering.widget.com/software/John Doe
    NameCanonical = 7,

    // someone@example.com
    NameUserPrincipal = 8,

    // Same as NameCanonical except that rightmost '/' is
    // replaced with '\n' - even in domain-only case.
    // eg: engineering.widget.com/software\nJohn Doe
    NameCanonicalEx = 9,

    // www/srv.engineering.com/engineering.com
    NameServicePrincipal = 10,

    // DNS domain name + SAM username
    // eg: engineering.widget.com\JohnDoe
    NameDnsDomain = 12

} EXTENDED_NAME_FORMAT, * PEXTENDED_NAME_FORMAT ;
]]

ffi.cdef[[


typedef UNICODE_STRING LSA_UNICODE_STRING, *PLSA_UNICODE_STRING;
typedef STRING LSA_STRING, *PLSA_STRING;
]]

ffi.cdef[[
typedef struct _LSA_LAST_INTER_LOGON_INFO {
    LARGE_INTEGER LastSuccessfulLogon;
    LARGE_INTEGER LastFailedLogon;
    ULONG FailedAttemptCountSinceLastSuccessfulLogon;
} LSA_LAST_INTER_LOGON_INFO, *PLSA_LAST_INTER_LOGON_INFO;
]]

ffi.cdef[[
typedef struct _SECURITY_LOGON_SESSION_DATA {
    ULONG               Size;
    LUID                LogonId;
    LSA_UNICODE_STRING  UserName;
    LSA_UNICODE_STRING  LogonDomain;
    LSA_UNICODE_STRING  AuthenticationPackage;
    ULONG               LogonType;
    ULONG               Session;
    PSID                Sid;
    LARGE_INTEGER       LogonTime;

    //
    // new for whistler:
    //

    LSA_UNICODE_STRING  LogonServer;
    LSA_UNICODE_STRING  DnsDomainName;
    LSA_UNICODE_STRING  Upn;

    //
    // new for LH
    //

    ULONG UserFlags;

    LSA_LAST_INTER_LOGON_INFO LastLogonInfo;
    LSA_UNICODE_STRING LogonScript;
    LSA_UNICODE_STRING ProfilePath;
    LSA_UNICODE_STRING HomeDirectory;
    LSA_UNICODE_STRING HomeDirectoryDrive;

    LARGE_INTEGER LogoffTime;
    LARGE_INTEGER KickOffTime;
    LARGE_INTEGER PasswordLastSet;
    LARGE_INTEGER PasswordCanChange;
    LARGE_INTEGER PasswordMustChange;

} SECURITY_LOGON_SESSION_DATA, * PSECURITY_LOGON_SESSION_DATA;
]]

ffi.cdef[[
// the public view
typedef PVOID PSEC_WINNT_AUTH_IDENTITY_OPAQUE; // the credential structure is opaque
]]




















ffi.cdef[[

SECURITY_STATUS 
AcceptSecurityContext(
     PCredHandle phCredential,               // Cred to base context
     PCtxtHandle phContext,                  // Existing context (OPT)
     PSecBufferDesc pInput,                  // Input buffer
         unsigned long fContextReq,              // Context Requirements
         unsigned long TargetDataRep,            // Target Data Rep
     PCtxtHandle phNewContext,               // (out) New context handle
     PSecBufferDesc pOutput,                 // (inout) Output buffers
        unsigned long * pfContextAttr,  // (out) Context attributes
     PTimeStamp ptsExpiry                    // (out) Life span (OPT)
    );

typedef SECURITY_STATUS
(* ACCEPT_SECURITY_CONTEXT_FN)(
    PCredHandle,
    PCtxtHandle,
    PSecBufferDesc,
    unsigned long,
    unsigned long,
    PCtxtHandle,
    PSecBufferDesc,
    unsigned long *,
    PTimeStamp);
]]

ffi.cdef[[
SECURITY_STATUS 
AcquireCredentialsHandleA(
    const char * pszPrincipal,                 // Name of principal
    const char * pszPackage,                   // Name of package
    unsigned long fCredentialUse,       // Flags indicating use
    void * pvLogonId,           // Pointer to logon ID
    void * pAuthData,           // Package specific data
    SEC_GET_KEY_FN pGetKeyFn,           // Pointer to GetKey() func
    void * pvGetKeyArgument,    // Value to pass to GetKey()
    PCredHandle phCredential,           // (out) Cred Handle
    PTimeStamp ptsExpiry                // (out) Lifetime (optional)
    );

typedef SECURITY_STATUS
(* ACQUIRE_CREDENTIALS_HANDLE_FN_A)(
    SEC_CHAR *,
    SEC_CHAR *,
    unsigned long,
    void *,
    void *,
    SEC_GET_KEY_FN,
    void *,
    PCredHandle,
    PTimeStamp);
]]

ffi.cdef[[

SECURITY_STATUS 
AcquireCredentialsHandleW(

     LPWSTR pszPrincipal,                // Name of principal
         LPWSTR pszPackage,                  // Name of package

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

    SEC_WCHAR *,
    SEC_WCHAR *,
    unsigned long,
    void *,
    void *,
    SEC_GET_KEY_FN,
    void *,
    PCredHandle,
    PTimeStamp);
]]

ffi.cdef[[
SECURITY_STATUS 
AddCredentialsA(
    PCredHandle hCredentials,
    LPSTR pszPrincipal,             // Name of principal
    LPSTR pszPackage,                   // Name of package
    unsigned long fCredentialUse,       // Flags indicating use
    void * pAuthData,           // Package specific data
    SEC_GET_KEY_FN pGetKeyFn,           // Pointer to GetKey() func
    void * pvGetKeyArgument,    // Value to pass to GetKey()
     PTimeStamp ptsExpiry                // (out) Lifetime (optional)
    );

typedef SECURITY_STATUS
(* ADD_CREDENTIALS_FN_A)(
    PCredHandle,
    SEC_CHAR *,
    SEC_CHAR *,
    unsigned long,
    void *,
    SEC_GET_KEY_FN,
    void *,
    PTimeStamp);
]]

ffi.cdef[[

SECURITY_STATUS 
AddCredentialsW(
    PCredHandle hCredentials,
    LPWSTR pszPrincipal,                // Name of principal
    LPWSTR pszPackage,                  // Name of package
    unsigned long fCredentialUse,       // Flags indicating use
    void * pAuthData,           // Package specific data
    SEC_GET_KEY_FN pGetKeyFn,           // Pointer to GetKey() func
    void * pvGetKeyArgument,    // Value to pass to GetKey()
    PTimeStamp ptsExpiry                // (out) Lifetime (optional)
    );

typedef SECURITY_STATUS
(* ADD_CREDENTIALS_FN_W)(
    PCredHandle,
    SEC_WCHAR *,
    SEC_WCHAR *,
    unsigned long,
    void *,
    SEC_GET_KEY_FN,
    void *,
    PTimeStamp);
]]

ffi.cdef[[
SECURITY_STATUS
AddSecurityPackageA(LPSTR pszPackageName, PSECURITY_PACKAGE_OPTIONS pOptions);

SECURITY_STATUS
AddSecurityPackageW(LPWSTR pszPackageName, PSECURITY_PACKAGE_OPTIONS pOptions);
]]

ffi.cdef[[
SECURITY_STATUS 
ApplyControlToken(
    PCtxtHandle phContext,              // Context to modify
    PSecBufferDesc pInput               // Input token to apply
    );

typedef SECURITY_STATUS
(* APPLY_CONTROL_TOKEN_FN)(
    PCtxtHandle, PSecBufferDesc);
]]

ffi.cdef[[
SECURITY_STATUS 
ChangeAccountPasswordA(
       SEC_CHAR *  pszPackageName,
       SEC_CHAR *  pszDomainName,
       SEC_CHAR *  pszAccountName,
       SEC_CHAR *  pszOldPassword,
       SEC_CHAR *  pszNewPassword,
       BOOLEAN             bImpersonating,
       unsigned long       dwReserved,
    PSecBufferDesc      pOutput
    );

typedef SECURITY_STATUS
(* CHANGE_PASSWORD_FN_A)(
    SEC_CHAR *,
    SEC_CHAR *,
    SEC_CHAR *,
    SEC_CHAR *,
    SEC_CHAR *,
    BOOLEAN,
    unsigned long,
    PSecBufferDesc
    );

SECURITY_STATUS 
ChangeAccountPasswordW(
       SEC_WCHAR *  pszPackageName,
       SEC_WCHAR *  pszDomainName,
       SEC_WCHAR *  pszAccountName,
       SEC_WCHAR *  pszOldPassword,
       SEC_WCHAR *  pszNewPassword,
       BOOLEAN              bImpersonating,
       unsigned long        dwReserved,
    PSecBufferDesc       pOutput
    );

typedef SECURITY_STATUS
(* CHANGE_PASSWORD_FN_W)(
    SEC_WCHAR *,
    SEC_WCHAR *,
    SEC_WCHAR *,
    SEC_WCHAR *,
    SEC_WCHAR *,
    BOOLEAN,
    unsigned long,
    PSecBufferDesc
    );
]]

ffi.cdef[[
SECURITY_STATUS 
CompleteAuthToken(
    PCtxtHandle phContext,              // Context to complete
    PSecBufferDesc pToken               // Token to complete
    );

typedef SECURITY_STATUS
(* COMPLETE_AUTH_TOKEN_FN)(
    PCtxtHandle,
    PSecBufferDesc);
]]

ffi.cdef[[
SECURITY_STATUS 
DecryptMessage(      PCtxtHandle         phContext,
                  PSecBufferDesc      pMessage,
                     unsigned long       MessageSeqNo,
                 unsigned long *     pfQOP);


typedef SECURITY_STATUS
(* DECRYPT_MESSAGE_FN)(
    PCtxtHandle, PSecBufferDesc, unsigned long,
    unsigned long *);
]]

ffi.cdef[[
SECURITY_STATUS DeleteSecurityContext(
    PCtxtHandle phContext               // Context to delete
    );

typedef SECURITY_STATUS
(* DELETE_SECURITY_CONTEXT_FN)(
    PCtxtHandle);
]]

ffi.cdef[[
SECURITY_STATUS
DeleteSecurityPackageA(LPSTR pszPackageName);

SECURITY_STATUS
DeleteSecurityPackageW(LPWSTR pszPackageName);
]]

ffi.cdef[[
SECURITY_STATUS 
EncryptMessage(    PCtxtHandle         phContext,
                   unsigned long       fQOP,
                PSecBufferDesc      pMessage,
                   unsigned long       MessageSeqNo);

typedef SECURITY_STATUS
(* ENCRYPT_MESSAGE_FN)(
    PCtxtHandle, unsigned long, PSecBufferDesc, unsigned long);

]]

ffi.cdef[[

SECURITY_STATUS 
EnumerateSecurityPackagesA(
    unsigned long * pcPackages,     // Receives num. packages
    PSecPkgInfoA  * ppPackageInfo    // Receives array of info
    );

typedef SECURITY_STATUS (* ENUMERATE_SECURITY_PACKAGES_FN_A)(unsigned long *, PSecPkgInfoA *);


SECURITY_STATUS 
EnumerateSecurityPackagesW(
    unsigned long * pcPackages,     // Receives num. packages
    PSecPkgInfoW  * ppPackageInfo    // Receives array of info
    );

typedef SECURITY_STATUS (* ENUMERATE_SECURITY_PACKAGES_FN_W)(unsigned long *,PSecPkgInfoW *);

]]

ffi.cdef[[

SECURITY_STATUS 
ExportSecurityContext(
     PCtxtHandle          phContext,             // (in) context to export
     ULONG                fFlags,                // (in) option flags
    PSecBuffer           pPackedContext,        // (out) marshalled context
    void * * pToken             // (out, optional) token handle for impersonation
    );

typedef SECURITY_STATUS
(* EXPORT_SECURITY_CONTEXT_FN)(
    PCtxtHandle,
    ULONG,
    PSecBuffer,
    void * *
    );
]]

ffi.cdef[[
SECURITY_STATUS 
FreeContextBuffer(
    PVOID pvContextBuffer      // buffer to free
    );

typedef SECURITY_STATUS (* FREE_CONTEXT_BUFFER_FN)(PVOID);
]]

ffi.cdef[[
SECURITY_STATUS 
FreeCredentialsHandle(
    PCredHandle phCredential            // Handle to free
    );

typedef SECURITY_STATUS
(* FREE_CREDENTIALS_HANDLE_FN)(
    PCredHandle );
]]


ffi.cdef[[
BOOLEAN
GetUserNameExA(
    EXTENDED_NAME_FORMAT  NameFormat,
    LPSTR lpNameBuffer,
    PULONG nSize
    );

BOOLEAN
GetUserNameExW(
    EXTENDED_NAME_FORMAT NameFormat,
    LPWSTR lpNameBuffer,
    PULONG nSize
    );
]]

ffi.cdef[[
SECURITY_STATUS 
ImpersonateSecurityContext(
    PCtxtHandle phContext               // Context to impersonate
    );

typedef SECURITY_STATUS
(* IMPERSONATE_SECURITY_CONTEXT_FN)(
    PCtxtHandle);
]]

ffi.cdef[[
SECURITY_STATUS 
ImportSecurityContextA(
     LPSTR                pszPackage,
     PSecBuffer           pPackedContext,        // (in) marshalled context
     void *               Token,                 // (in, optional) handle to token for context
    PCtxtHandle          phContext              // (out) new context handle
    );

typedef SECURITY_STATUS
(* IMPORT_SECURITY_CONTEXT_FN_A)(
    SEC_CHAR *,
    PSecBuffer,
    void *,
    PCtxtHandle
    );
]]

ffi.cdef[[

SECURITY_STATUS 
ImportSecurityContextW(
     LPWSTR               pszPackage,
     PSecBuffer           pPackedContext,        // (in) marshalled context
     void *               Token,                 // (in, optional) handle to token for context
    PCtxtHandle          phContext              // (out) new context handle
    );

typedef SECURITY_STATUS
(* IMPORT_SECURITY_CONTEXT_FN_W)(
    SEC_WCHAR *,
    PSecBuffer,
    void *,
    PCtxtHandle
    );
]]

ffi.cdef[[

SECURITY_STATUS 
InitializeSecurityContextA(
    PCredHandle phCredential,               // Cred to base context
    PCtxtHandle phContext,                  // Existing context (OPT)
    SEC_CHAR * pszTargetName,       // Name of target
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
(* INITIALIZE_SECURITY_CONTEXT_FN_A)(
    PCredHandle,
    PCtxtHandle,
    SEC_CHAR *,
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

ffi.cdef[[

SECURITY_STATUS 
InitializeSecurityContextW(
    PCredHandle phCredential,               // Cred to base context
    PCtxtHandle phContext,                  // Existing context (OPT)
    SEC_WCHAR * pszTargetName,         // Name of target
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
    SEC_WCHAR *,
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


ffi.cdef[[
BOOL
LogonUserExA (
               LPCSTR lpszUsername,
           LPCSTR lpszDomain,
               LPCSTR lpszPassword,
               DWORD dwLogonType,
               DWORD dwLogonProvider,
    PHANDLE phToken,
    PSID  *ppLogonSid,
    PVOID *ppProfileBuffer,
          LPDWORD pdwProfileLength,
          PQUOTA_LIMITS pQuotaLimits
    );
BOOL
LogonUserExW (
               LPCWSTR lpszUsername,
           LPCWSTR lpszDomain,
               LPCWSTR lpszPassword,
               DWORD dwLogonType,
               DWORD dwLogonProvider,
    PHANDLE phToken,
    PSID  *ppLogonSid,
    PVOID *ppProfileBuffer,
          LPDWORD pdwProfileLength,
          PQUOTA_LIMITS pQuotaLimits
    );
]]

ffi.cdef[[
NTSTATUS
LsaCallAuthenticationPackage (
    HANDLE LsaHandle,
    ULONG AuthenticationPackage,
    PVOID ProtocolSubmitBuffer,
    ULONG SubmitBufferLength,
    PVOID *ProtocolReturnBuffer,
    PULONG ReturnBufferLength,
    PNTSTATUS ProtocolStatus
    );
]]

ffi.cdef[[
NTSTATUS
LsaConnectUntrusted (
    PHANDLE LsaHandle
    );
]]

ffi.cdef[[
NTSTATUS
LsaDeregisterLogonProcess (
    HANDLE LsaHandle
    );
]]

ffi.cdef[[
NTSTATUS
LsaDeregisterLogonProcess (
    HANDLE LsaHandle
    );
]]

ffi.cdef[[
NTSTATUS
LsaEnumerateLogonSessions(
    PULONG  LogonSessionCount,
    PLUID * LogonSessionList
    );
]]

ffi.cdef[[
NTSTATUS
LsaFreeReturnBuffer (
    PVOID Buffer
    );
]]

ffi.cdef[[
NTSTATUS
LsaGetLogonSessionData(
    PLUID    LogonId,
    PSECURITY_LOGON_SESSION_DATA * ppLogonSessionData
    );
]]

ffi.cdef[[
typedef enum _SECURITY_LOGON_TYPE {
    UndefinedLogonType = 0, // This is used to specify an undefied logon type
    Interactive = 2,      // Interactively logged on (locally or remotely)
    Network,              // Accessing system via network
    Batch,                // Started via a batch queue
    Service,              // Service started by service controller
    Proxy,                // Proxy logon
    Unlock,               // Unlock workstation
    NetworkCleartext,     // Network logon with cleartext credentials
    NewCredentials,       // Clone caller, new default credentials
    //The types below only exist in Windows XP and greater
    RemoteInteractive,  // Remote, yet interactive. Terminal server
    CachedInteractive,  // Try cached credentials without hitting the net.
    // The types below only exist in Windows Server 2003 and greater
    CachedRemoteInteractive, // Same as RemoteInteractive, this is used internally for auditing purpose
    CachedUnlock        // Cached Unlock workstation
} SECURITY_LOGON_TYPE, *PSECURITY_LOGON_TYPE;
]]



ffi.cdef[[
NTSTATUS
LsaLogonUser (
    HANDLE LsaHandle,
    PLSA_STRING OriginName,
    SECURITY_LOGON_TYPE LogonType,
    ULONG AuthenticationPackage,
    PVOID AuthenticationInformation,
    ULONG AuthenticationInformationLength,
    PTOKEN_GROUPS LocalGroups,
    PTOKEN_SOURCE SourceContext,
    PVOID *ProfileBuffer,
    PULONG ProfileBufferLength,
    PLUID LogonId,
    PHANDLE Token,
    PQUOTA_LIMITS Quotas,
    PNTSTATUS SubStatus
    );
]]

ffi.cdef[[
NTSTATUS
LsaLookupAuthenticationPackage (
    HANDLE LsaHandle,
    PLSA_STRING PackageName,
    PULONG AuthenticationPackage
    );
]]



ffi.cdef[[
NTSTATUS
LsaRegisterLogonProcess (
    PLSA_STRING LogonProcessName,
    PHANDLE LsaHandle,
    PLSA_OPERATIONAL_MODE SecurityMode
    );
]]

ffi.cdef[[
NTSTATUS
LsaRegisterPolicyChangeNotification(
    POLICY_NOTIFICATION_INFORMATION_CLASS InformationClass,
    HANDLE  NotificationEventHandle
    );
]]

ffi.cdef[[
NTSTATUS
LsaUnregisterPolicyChangeNotification(
    POLICY_NOTIFICATION_INFORMATION_CLASS InformationClass,
    HANDLE  NotificationEventHandle
    );
]]

ffi.cdef[[
SECURITY_STATUS 
MakeSignature(
    PCtxtHandle phContext,              // Context to use
    unsigned long fQOP,                 // Quality of Protection
    PSecBufferDesc pMessage,            // Message to sign
    unsigned long MessageSeqNo          // Message Sequence Num.
    );

typedef SECURITY_STATUS
(* MAKE_SIGNATURE_FN)(
    PCtxtHandle,
    unsigned long,
    PSecBufferDesc,
    unsigned long);
]]

ffi.cdef[[
SECURITY_STATUS 
QueryContextAttributesW(
     PCtxtHandle phContext,              // Context to query
     unsigned long ulAttribute,          // Attribute to query
    void * pBuffer              // Buffer for attributes
    );

typedef SECURITY_STATUS
(* QUERY_CONTEXT_ATTRIBUTES_FN_W)(
    PCtxtHandle,
    unsigned long,
    void *);

SECURITY_STATUS 
QueryContextAttributesA(
     PCtxtHandle phContext,              // Context to query
     unsigned long ulAttribute,          // Attribute to query
    void * pBuffer              // Buffer for attributes
    );

typedef SECURITY_STATUS
(* QUERY_CONTEXT_ATTRIBUTES_FN_A)(
    PCtxtHandle,
    unsigned long,
    void *);
]]

ffi.cdef[[

SECURITY_STATUS 
QueryCredentialsAttributesW(
       PCredHandle phCredential,           // Credential to query
       unsigned long ulAttribute,          // Attribute to query
    void * pBuffer              // Buffer for attributes
    );

typedef SECURITY_STATUS
(* QUERY_CREDENTIALS_ATTRIBUTES_FN_W)(
    PCredHandle,
    unsigned long,
    void *);

SECURITY_STATUS 
QueryCredentialsAttributesA(
       PCredHandle phCredential,           // Credential to query
       unsigned long ulAttribute,          // Attribute to query
    void * pBuffer              // Buffer for attributes
    );

typedef SECURITY_STATUS
(* QUERY_CREDENTIALS_ATTRIBUTES_FN_A)(
    PCredHandle,
    unsigned long,
    void *);
]]

ffi.cdef[[
SECURITY_STATUS 
QuerySecurityContextToken(
     PCtxtHandle phContext,
    void * * Token
    );

typedef SECURITY_STATUS
(* QUERY_SECURITY_CONTEXT_TOKEN_FN)(
    PCtxtHandle, void * *);
]]

ffi.cdef[[
SECURITY_STATUS 
QuerySecurityPackageInfoA(
           LPSTR pszPackageName,           // Name of package
    PSecPkgInfoA *ppPackageInfo     // Receives package info
    );

typedef SECURITY_STATUS
(* QUERY_SECURITY_PACKAGE_INFO_FN_A)(
    SEC_CHAR *,
    PSecPkgInfoA *);
]]

ffi.cdef[[

SECURITY_STATUS 
QuerySecurityPackageInfoW(
    LPWSTR pszPackageName,          // Name of package
    PSecPkgInfoW *ppPackageInfo     // Receives package info
    );

typedef SECURITY_STATUS
(* QUERY_SECURITY_PACKAGE_INFO_FN_W)(
    SEC_WCHAR *,
    PSecPkgInfoW *);
]]

ffi.cdef[[

SECURITY_STATUS 
RevertSecurityContext(
    PCtxtHandle phContext               // Context from which to re
    );

typedef SECURITY_STATUS
(* REVERT_SECURITY_CONTEXT_FN)(
    PCtxtHandle);
]]

ffi.cdef[[
SECURITY_STATUS
SaslAcceptSecurityContext(
       PCredHandle                 phCredential,       // Cred to base context
       PCtxtHandle                 phContext,          // Existing context (OPT)
       PSecBufferDesc              pInput,             // Input buffer
           unsigned long               fContextReq,        // Context Requirements
           unsigned long               TargetDataRep,      // Target Data Rep
    PCtxtHandle                 phNewContext,       // (out) New context handle
    PSecBufferDesc              pOutput,            // (inout) Output buffers
          unsigned long *     pfContextAttr,      // (out) Context attributes
       PTimeStamp                  ptsExpiry           // (out) Life span (OPT)
    );
]]

ffi.cdef[[
SECURITY_STATUS
SaslEnumerateProfilesA(
    LPSTR * ProfileList,
          ULONG * ProfileCount
    );

SECURITY_STATUS
SaslEnumerateProfilesW(
    LPWSTR * ProfileList,
          ULONG * ProfileCount
    );
]]

ffi.cdef[[
SECURITY_STATUS
SaslGetContextOption(
    PCtxtHandle ContextHandle,
    ULONG Option,
    PVOID Value,
    ULONG Size,
    PULONG Needed);
]]


ffi.cdef[[
SECURITY_STATUS
SaslGetProfilePackageA(
           LPSTR ProfileName,
    PSecPkgInfoA * PackageInfo
    );


SECURITY_STATUS
SaslGetProfilePackageW(
           LPWSTR ProfileName,
    PSecPkgInfoW * PackageInfo
    );
]]

ffi.cdef[[
SECURITY_STATUS
SaslIdentifyPackageA(
           PSecBufferDesc pInput,
    PSecPkgInfoA * PackageInfo
    );

SECURITY_STATUS
SaslIdentifyPackageW(
           PSecBufferDesc pInput,
    PSecPkgInfoW * PackageInfo
    );
]]

ffi.cdef[[
SECURITY_STATUS
SaslInitializeSecurityContextW(
       PCredHandle                 phCredential,       // Cred to base context
       PCtxtHandle                 phContext,          // Existing context (OPT)
       LPWSTR                      pszTargetName,      // Name of target
           unsigned long               fContextReq,        // Context Requirements
           unsigned long               Reserved1,          // Reserved, MBZ
           unsigned long               TargetDataRep,      // Data rep of target
       PSecBufferDesc              pInput,             // Input Buffers
           unsigned long               Reserved2,          // Reserved, MBZ
    PCtxtHandle                 phNewContext,       // (out) New Context handle
    PSecBufferDesc              pOutput,            // (inout) Output Buffers
          unsigned long *     pfContextAttr,      // (out) Context attrs
       PTimeStamp                  ptsExpiry           // (out) Life span (OPT)
    );

SECURITY_STATUS
SaslInitializeSecurityContextA(
       PCredHandle                 phCredential,       // Cred to base context
       PCtxtHandle                 phContext,          // Existing context (OPT)
       LPSTR                       pszTargetName,      // Name of target
           unsigned long               fContextReq,        // Context Requirements
           unsigned long               Reserved1,          // Reserved, MBZ
           unsigned long               TargetDataRep,      // Data rep of target
       PSecBufferDesc              pInput,             // Input Buffers
           unsigned long               Reserved2,          // Reserved, MBZ
    PCtxtHandle                 phNewContext,       // (out) New Context handle
    PSecBufferDesc              pOutput,            // (inout) Output Buffers
          unsigned long *     pfContextAttr,      // (out) Context attrs
       PTimeStamp                  ptsExpiry           // (out) Life span (OPT)
    );
]]

ffi.cdef[[
SECURITY_STATUS
SaslSetContextOption(
    PCtxtHandle ContextHandle,
    ULONG Option,
    PVOID Value,
    ULONG Size);
]]

ffi.cdef[[
SECURITY_STATUS 
SetContextAttributesW(
    PCtxtHandle phContext,                   // Context to Set
    unsigned long ulAttribute,               // Attribute to Set
    void * pBuffer, // Buffer for attributes
    unsigned long cbBuffer                   // Size (in bytes) of Buffer
    );

typedef SECURITY_STATUS
(* SET_CONTEXT_ATTRIBUTES_FN_W)(
    PCtxtHandle,
    unsigned long,
    void *,
    unsigned long );

]]


ffi.cdef[[
SECURITY_STATUS 
SetContextAttributesA(
    PCtxtHandle phContext,                   // Context to Set
    unsigned long ulAttribute,               // Attribute to Set
    void * pBuffer, // Buffer for attributes
    unsigned long cbBuffer                   // Size (in bytes) of Buffer
    );

typedef SECURITY_STATUS
(* SET_CONTEXT_ATTRIBUTES_FN_A)(
    PCtxtHandle,
    unsigned long,
    void *,
    unsigned long );
]]


ffi.cdef[[

SECURITY_STATUS 
SetCredentialsAttributesW(
    PCredHandle phCredential,                // Credential to Set
    unsigned long ulAttribute,               // Attribute to Set
    void * pBuffer, // Buffer for attributes
    unsigned long cbBuffer                   // Size (in bytes) of Buffer
    );

typedef SECURITY_STATUS
(* SET_CREDENTIALS_ATTRIBUTES_FN_W)(
    PCredHandle,
    unsigned long,
    void *,
    unsigned long );

]] -- For W2k3SP1 and greater


ffi.cdef[[
SECURITY_STATUS 
SetCredentialsAttributesA(
    PCredHandle phCredential,                // Credential to Set
    unsigned long ulAttribute,               // Attribute to Set
    void * pBuffer, // Buffer for attributes
    unsigned long cbBuffer                   // Size (in bytes) of Buffer
    );

typedef SECURITY_STATUS
(* SET_CREDENTIALS_ATTRIBUTES_FN_A)(
    PCredHandle,
    unsigned long,
    void *,
    unsigned long );
]]

ffi.cdef[[
SECURITY_STATUS
SspiCompareAuthIdentities(
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE AuthIdentity1,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE AuthIdentity2,
     PBOOLEAN SameSuppliedUser,
     PBOOLEAN SameSuppliedIdentity
    );
]]

ffi.cdef[[
SECURITY_STATUS
SspiCopyAuthIdentity(
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE AuthData,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE* AuthDataCopy
    );
]]

ffi.cdef[[
SECURITY_STATUS
SspiDecryptAuthIdentity(PSEC_WINNT_AUTH_IDENTITY_OPAQUE EncryptedAuthData);
]]


ffi.cdef[[
SECURITY_STATUS
SspiEncodeAuthIdentityAsStrings(
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE pAuthIdentity,
    PCWSTR* ppszUserName,
    PCWSTR* ppszDomainName,
    PCWSTR* ppszPackedCredentialsString
    );
]]

ffi.cdef[[
SECURITY_STATUS
SspiEncodeStringsAsAuthIdentity(
    PCWSTR pszUserName,
    PCWSTR pszDomainName,
    PCWSTR pszPackedCredentialsString,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE* ppAuthIdentity
    );
]]

ffi.cdef[[
SECURITY_STATUS
SspiEncryptAuthIdentity(PSEC_WINNT_AUTH_IDENTITY_OPAQUE AuthData);
]]

ffi.cdef[[
SECURITY_STATUS
SspiExcludePackage(
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE AuthIdentity,
    PCWSTR pszPackageName,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE* ppNewAuthIdentity
    );
]]

ffi.cdef[[
void SspiFreeAuthIdentity(PSEC_WINNT_AUTH_IDENTITY_OPAQUE AuthData);
]]

ffi.cdef[[
SECURITY_STATUS
SspiGetTargetHostName(
    PCWSTR pszTargetName,
    PWSTR* pszHostName
    );
]]

ffi.cdef[[
BOOLEAN
SspiIsAuthIdentityEncrypted(PSEC_WINNT_AUTH_IDENTITY_OPAQUE EncryptedAuthData);
]]

ffi.cdef[[
void SspiLocalFree(PVOID DataBuffer);
]]

ffi.cdef[[
SECURITY_STATUS
SspiMarshalAuthIdentity(
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE AuthIdentity,
    unsigned long* AuthIdentityLength,
    char** AuthIdentityByteArray
    );
]]

ffi.cdef[[
SECURITY_STATUS
SspiPrepareForCredRead(
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE AuthIdentity,
    PCWSTR pszTargetName,
    PULONG pCredmanCredentialType,
    PCWSTR* ppszCredmanTargetName
    );

SECURITY_STATUS
SspiPrepareForCredWrite(
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE AuthIdentity,
    PCWSTR pszTargetName, // supply NULL for username-target credentials
    PULONG pCredmanCredentialType,
    PCWSTR* ppszCredmanTargetName,
    PCWSTR* ppszCredmanUserName,
    PUCHAR *ppCredentialBlob,
    PULONG pCredentialBlobSize
    );
]]

ffi.cdef[[
SECURITY_STATUS
SspiUnmarshalAuthIdentity(
    unsigned long AuthIdentityLength,
    char* AuthIdentityByteArray,
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE* ppAuthIdentity
    );
]]

ffi.cdef[[
SECURITY_STATUS
SspiValidateAuthIdentity(
    PSEC_WINNT_AUTH_IDENTITY_OPAQUE AuthData
    );
]]

ffi.cdef[[
void SspiZeroAuthIdentity(PSEC_WINNT_AUTH_IDENTITY_OPAQUE AuthData);
]]

ffi.cdef[[
SECURITY_STATUS 
VerifySignature(
     PCtxtHandle phContext,              // Context to use
     PSecBufferDesc pMessage,            // Message to verify
     unsigned long MessageSeqNo,         // Sequence Num.
    unsigned long * pfQOP       // QOP used
    );

typedef SECURITY_STATUS
(* VERIFY_SIGNATURE_FN)(
    PCtxtHandle,
    PSecBufferDesc,
    unsigned long,
    unsigned long *);
]]

ffi.cdef[[
typedef NTSTATUS
(* SpSealMessageFn)(
    LSA_SEC_HANDLE ContextHandle,
    ULONG QualityOfProtection,
    PSecBufferDesc MessageBuffers,
    ULONG MessageSequenceNumber
    );

typedef NTSTATUS
(* SpUnsealMessageFn)(
    LSA_SEC_HANDLE ContextHandle,
    PSecBufferDesc MessageBuffers,
    ULONG MessageSequenceNumber,
    PULONG QualityOfProtection
    );
]]



ffi.cdef[[
typedef struct _SECURITY_FUNCTION_TABLE_W {
    unsigned long                       dwVersion;
    ENUMERATE_SECURITY_PACKAGES_FN_W    EnumerateSecurityPackagesW;
    QUERY_CREDENTIALS_ATTRIBUTES_FN_W   QueryCredentialsAttributesW;
    ACQUIRE_CREDENTIALS_HANDLE_FN_W     AcquireCredentialsHandleW;
    FREE_CREDENTIALS_HANDLE_FN          FreeCredentialsHandle;
    void *                      Reserved2;
    INITIALIZE_SECURITY_CONTEXT_FN_W    InitializeSecurityContextW;
    ACCEPT_SECURITY_CONTEXT_FN          AcceptSecurityContext;
    COMPLETE_AUTH_TOKEN_FN              CompleteAuthToken;
    DELETE_SECURITY_CONTEXT_FN          DeleteSecurityContext;
    APPLY_CONTROL_TOKEN_FN              ApplyControlToken;
    QUERY_CONTEXT_ATTRIBUTES_FN_W       QueryContextAttributesW;
    IMPERSONATE_SECURITY_CONTEXT_FN     ImpersonateSecurityContext;
    REVERT_SECURITY_CONTEXT_FN          RevertSecurityContext;
    MAKE_SIGNATURE_FN                   MakeSignature;
    VERIFY_SIGNATURE_FN                 VerifySignature;
    FREE_CONTEXT_BUFFER_FN              FreeContextBuffer;
    QUERY_SECURITY_PACKAGE_INFO_FN_W    QuerySecurityPackageInfoW;
    void *                      Reserved3;
    void *                      Reserved4;
    EXPORT_SECURITY_CONTEXT_FN          ExportSecurityContext;
    IMPORT_SECURITY_CONTEXT_FN_W        ImportSecurityContextW;
    ADD_CREDENTIALS_FN_W                AddCredentialsW ;
    void *                      Reserved8;
    QUERY_SECURITY_CONTEXT_TOKEN_FN     QuerySecurityContextToken;
    ENCRYPT_MESSAGE_FN                  EncryptMessage;
    DECRYPT_MESSAGE_FN                  DecryptMessage;
    // Fields below this are available in OSes after w2k
    SET_CONTEXT_ATTRIBUTES_FN_W         SetContextAttributesW;

    // Fields below this are available in OSes after W2k3SP1
    SET_CREDENTIALS_ATTRIBUTES_FN_W     SetCredentialsAttributesW;
    CHANGE_PASSWORD_FN_W                ChangeAccountPasswordW;
} SecurityFunctionTableW, * PSecurityFunctionTableW;

]]


ffi.cdef[[
typedef struct _SECURITY_FUNCTION_TABLE_A {
    unsigned long                       dwVersion;
    ENUMERATE_SECURITY_PACKAGES_FN_A    EnumerateSecurityPackagesA;
    QUERY_CREDENTIALS_ATTRIBUTES_FN_A   QueryCredentialsAttributesA;
    ACQUIRE_CREDENTIALS_HANDLE_FN_A     AcquireCredentialsHandleA;
    FREE_CREDENTIALS_HANDLE_FN          FreeCredentialHandle;
    void *                      Reserved2;
    INITIALIZE_SECURITY_CONTEXT_FN_A    InitializeSecurityContextA;
    ACCEPT_SECURITY_CONTEXT_FN          AcceptSecurityContext;
    COMPLETE_AUTH_TOKEN_FN              CompleteAuthToken;
    DELETE_SECURITY_CONTEXT_FN          DeleteSecurityContext;
    APPLY_CONTROL_TOKEN_FN              ApplyControlToken;
    QUERY_CONTEXT_ATTRIBUTES_FN_A       QueryContextAttributesA;
    IMPERSONATE_SECURITY_CONTEXT_FN     ImpersonateSecurityContext;
    REVERT_SECURITY_CONTEXT_FN          RevertSecurityContext;
    MAKE_SIGNATURE_FN                   MakeSignature;
    VERIFY_SIGNATURE_FN                 VerifySignature;
    FREE_CONTEXT_BUFFER_FN              FreeContextBuffer;
    QUERY_SECURITY_PACKAGE_INFO_FN_A    QuerySecurityPackageInfoA;
    void *                      Reserved3;
    void *                      Reserved4;
    EXPORT_SECURITY_CONTEXT_FN          ExportSecurityContext;
    IMPORT_SECURITY_CONTEXT_FN_A        ImportSecurityContextA;
    ADD_CREDENTIALS_FN_A                AddCredentialsA ;
    void *                      Reserved8;
    QUERY_SECURITY_CONTEXT_TOKEN_FN     QuerySecurityContextToken;
    ENCRYPT_MESSAGE_FN                  EncryptMessage;
    DECRYPT_MESSAGE_FN                  DecryptMessage;
    SET_CONTEXT_ATTRIBUTES_FN_A         SetContextAttributesA;
    SET_CREDENTIALS_ATTRIBUTES_FN_A     SetCredentialsAttributesA;
    CHANGE_PASSWORD_FN_A                ChangeAccountPasswordA;
} SecurityFunctionTableA, * PSecurityFunctionTableA;


]]

ffi.cdef[[
PSecurityFunctionTableA InitSecurityInterfaceA(void);

typedef PSecurityFunctionTableA (* INIT_SECURITY_INTERFACE_A)(void);
]]

ffi.cdef[[

PSecurityFunctionTableW InitSecurityInterfaceW(void);

typedef PSecurityFunctionTableW (* INIT_SECURITY_INTERFACE_W)(void);
]]


return {
--[[
AcceptSecurityContext
AcquireCredentialsHandleA
AcquireCredentialsHandleW
AddCredentialsA
AddCredentialsW
AddSecurityPackageA
AddSecurityPackageW
ApplyControlToken
ChangeAccountPasswordA
ChangeAccountPasswordW
CompleteAuthToken
DecryptMessage
DeleteSecurityContext
DeleteSecurityPackageA
DeleteSecurityPackageW
EncryptMessage
EnumerateSecurityPackagesA
EnumerateSecurityPackagesW
ExportSecurityContext
FreeContextBuffer
FreeCredentialsHandle
GetUserNameExA
GetUserNameExW
ImpersonateSecurityContext
ImportSecurityContextA
ImportSecurityContextW
InitializeSecurityContextA
InitializeSecurityContextW
--]]

    InitSecurityInterfaceA = secur32lib.InitSecurityInterfaceA,
    InitSecurityInterfaceW = secur32lib.InitSecurityInterfaceW,

    LogonUserExA = advapiLib.LogonUserExA,

--[[
LsaCallAuthenticationPackage
LsaConnectUntrusted
LsaDeregisterLogonProcess
LsaEnumerateLogonSessions
LsaFreeReturnBuffer
LsaGetLogonSessionData
LsaLogonUser
LsaLookupAuthenticationPackage
LsaRegisterLogonProcess
LsaRegisterPolicyChangeNotification
LsaUnregisterPolicyChangeNotification
MakeSignature
QueryContextAttributesA
QueryContextAttributesW
QueryCredentialsAttributesA
QueryCredentialsAttributesW
QuerySecurityContextToken
QuerySecurityPackageInfoA
QuerySecurityPackageInfoW
RevertSecurityContext
SaslAcceptSecurityContext
SaslEnumerateProfilesA
SaslEnumerateProfilesW
SaslGetContextOption
SaslGetProfilePackageA
SaslGetProfilePackageW
SaslIdentifyPackageA
SaslIdentifyPackageW
SaslInitializeSecurityContextA
SaslInitializeSecurityContextW
SaslSetContextOption
--SealMessage
SetContextAttributesA
SetContextAttributesW
SetCredentialsAttributesA
SetCredentialsAttributesW
SspiCompareAuthIdentities
SspiCopyAuthIdentity
SspiDecryptAuthIdentity
--SspiDecryptAuthIdentityEx
SspiEncodeAuthIdentityAsStrings
SspiEncodeStringsAsAuthIdentity
SspiEncryptAuthIdentity
--SspiEncryptAuthIdentityEx
SspiExcludePackage
SspiFreeAuthIdentity
SspiGetTargetHostName
SspiIsAuthIdentityEncrypted
SspiLocalFree
SspiMarshalAuthIdentity
SspiPrepareForCredRead
SspiPrepareForCredWrite
SspiUnmarshalAuthIdentity
SspiValidateAuthIdentity
SspiZeroAuthIdentity
--UnsealMessage
VerifySignature
--]]
}
