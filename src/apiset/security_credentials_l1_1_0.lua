-- security_credentials_l1_1_0.lua	
-- api-ms-win-security-credentials-l1-1-0.dll	

local ffi = require("ffi");
require("WTypes");
local Lib = ffi.load("AdvApi32");

ffi.cdef[[

typedef struct _CREDENTIAL_ATTRIBUTEA {
    LPSTR Keyword;
    DWORD Flags;
    DWORD ValueSize;
    LPBYTE Value;
} CREDENTIAL_ATTRIBUTEA, *PCREDENTIAL_ATTRIBUTEA;

typedef struct _CREDENTIAL_ATTRIBUTEW {
    LPWSTR  Keyword;
    DWORD Flags;
    DWORD ValueSize;
    LPBYTE Value;
} CREDENTIAL_ATTRIBUTEW, *PCREDENTIAL_ATTRIBUTEW;


typedef struct _CREDENTIALA {
    DWORD Flags;
    DWORD Type;
    LPSTR TargetName;
    LPSTR Comment;
    FILETIME LastWritten;
    DWORD CredentialBlobSize;
    LPBYTE CredentialBlob;
    DWORD Persist;
    DWORD AttributeCount;
    PCREDENTIAL_ATTRIBUTEA Attributes;
    LPSTR TargetAlias;
    LPSTR UserName;
} CREDENTIALA, *PCREDENTIALA;

typedef struct _CREDENTIALW {
    DWORD Flags;
    DWORD Type;
    LPWSTR TargetName;
    LPWSTR Comment;
    FILETIME LastWritten;
    DWORD CredentialBlobSize;
    LPBYTE CredentialBlob;
    DWORD Persist;
    DWORD AttributeCount;
    PCREDENTIAL_ATTRIBUTEW Attributes;
    LPWSTR TargetAlias;
    LPWSTR UserName;
} CREDENTIALW, *PCREDENTIALW;

]]

ffi.cdef[[
//
// A credential target
//

typedef struct _CREDENTIAL_TARGET_INFORMATIONA {
    LPSTR TargetName;
    LPSTR NetbiosServerName;
    LPSTR DnsServerName;
    LPSTR NetbiosDomainName;
    LPSTR DnsDomainName;
    LPSTR DnsTreeName;
    LPSTR PackageName;
    ULONG Flags;
    DWORD CredTypeCount;
    LPDWORD CredTypes;
} CREDENTIAL_TARGET_INFORMATIONA, *PCREDENTIAL_TARGET_INFORMATIONA;


typedef struct _CREDENTIAL_TARGET_INFORMATIONW {
    LPWSTR TargetName;
    LPWSTR NetbiosServerName;
    LPWSTR DnsServerName;
    LPWSTR NetbiosDomainName;
    LPWSTR DnsDomainName;
    LPWSTR DnsTreeName;
    LPWSTR PackageName;
    ULONG Flags;
    DWORD CredTypeCount;
    LPDWORD CredTypes;
} CREDENTIAL_TARGET_INFORMATIONW, *PCREDENTIAL_TARGET_INFORMATIONW;
]]

ffi.cdef[[
typedef enum _CRED_PROTECTION_TYPE {
    CredUnprotected,
    CredUserProtection,
    CredTrustedProtection
} CRED_PROTECTION_TYPE, *PCRED_PROTECTION_TYPE;

typedef enum _CRED_MARSHAL_TYPE {
    CertCredential = 1,
    UsernameTargetCredential,
    BinaryBlobCredential,
    UsernameForPackedCredentials,  // internal only, reserved
} CRED_MARSHAL_TYPE, *PCRED_MARSHAL_TYPE;
]]

ffi.cdef[[
BOOL
CredDeleteA (
    LPCSTR TargetName,
    DWORD Type,
    DWORD Flags
    );

BOOL
CredDeleteW (
    LPCWSTR TargetName,
    DWORD Type,
    DWORD Flags
    );

BOOL
CredEnumerateA (
    LPCSTR Filter,
    DWORD Flags,
    DWORD *Count,
    void * Credential
    );
//    PCREDENTIALA **Credential

BOOL
CredEnumerateW (
    LPCWSTR Filter,
    DWORD Flags,
    DWORD *Count,
    PCREDENTIALW **Credential
    );

BOOL
CredFindBestCredentialW (
    LPCWSTR TargetName,
    DWORD Type,
    DWORD Flags,
    PCREDENTIALW *Credential
    );

BOOL
CredFindBestCredentialA (
    LPCSTR TargetName,
    DWORD Type,
    DWORD Flags,
    PCREDENTIALA *Credential
    );

void
CredFree (PVOID Buffer);

BOOL
CredGetSessionTypes (
    DWORD MaximumPersistCount,
    LPDWORD MaximumPersist
    );

BOOL
CredGetTargetInfoW (
    LPCWSTR TargetName,
    DWORD Flags,
    PCREDENTIAL_TARGET_INFORMATIONW *TargetInfo
    );

BOOL
CredGetTargetInfoA (
    LPCSTR TargetName,
    DWORD Flags,
    PCREDENTIAL_TARGET_INFORMATIONA *TargetInfo
    );


BOOL
CredIsMarshaledCredentialW(
    LPCWSTR MarshaledCredential
    );

BOOL
CredIsProtectedW(
    LPWSTR                 pszProtectedCredentials,
    CRED_PROTECTION_TYPE* pProtectionType
    );

BOOL
CredIsProtectedA(
    LPSTR                  pszProtectedCredentials,
    CRED_PROTECTION_TYPE* pProtectionType
    );

BOOL
CredMarshalCredentialW(
    CRED_MARSHAL_TYPE CredType,
    PVOID Credential,
    LPWSTR *MarshaledCredential
    );

BOOL
CredMarshalCredentialA(
    CRED_MARSHAL_TYPE CredType,
    PVOID Credential,
    LPSTR *MarshaledCredential
    );

BOOL
CredProtectW(
    BOOL                               fAsSelf,
    LPWSTR      pszCredentials,
    DWORD                              cchCredentials,
    LPWSTR      pszProtectedCredentials,
    DWORD*                          pcchMaxChars,
    CRED_PROTECTION_TYPE*         ProtectionType
    );

BOOL
CredProtectA(
    BOOL                            fAsSelf,
    LPSTR    pszCredentials,
    DWORD                           cchCredentials,
    LPSTR    pszProtectedCredentials,
    DWORD*                       pcchMaxChars,
    CRED_PROTECTION_TYPE*      ProtectionType
    );

BOOL
CredReadA (
    LPCSTR TargetName,
    DWORD Type,
    DWORD Flags,
    PCREDENTIALA *Credential
    );

BOOL
CredReadDomainCredentialsW (
    PCREDENTIAL_TARGET_INFORMATIONW TargetInfo,
    DWORD Flags,
    DWORD *Count,
    PCREDENTIALW **Credential
    );

BOOL
CredReadDomainCredentialsA (
    PCREDENTIAL_TARGET_INFORMATIONA TargetInfo,
    DWORD Flags,
    DWORD *Count,
    PCREDENTIALA **Credential
    );

BOOL
CredReadW (
    LPCWSTR TargetName,
    DWORD Type,
    DWORD Flags,
    PCREDENTIALW *Credential
    );

BOOL
CredUnmarshalCredentialW(
    LPCWSTR MarshaledCredential,
    PCRED_MARSHAL_TYPE CredType,
    PVOID *Credential
    );

BOOL
CredUnmarshalCredentialA(
    LPCSTR MarshaledCredential,
    PCRED_MARSHAL_TYPE CredType,
    PVOID *Credential
    );

BOOL
CredUnprotectW(
    BOOL                                   fAsSelf,
    LPWSTR pszProtectedCredentials,
    DWORD                                  cchProtectedCredentials,
    LPWSTR      pszCredentials,
    DWORD*                              pcchMaxChars
    );

BOOL
CredUnprotectA(
    BOOL                                   fAsSelf,
    LPSTR  pszProtectedCredentials,
    DWORD                                  cchProtectedCredentials,
    LPSTR       pszCredentials,
    DWORD*                              pcchMaxChars
    );

BOOL
CredWriteW (
    PCREDENTIALW Credential,
    DWORD Flags
    );

BOOL
CredWriteA (
    PCREDENTIALA Credential,
    DWORD Flags
    );

BOOL
CredWriteDomainCredentialsW (
    PCREDENTIAL_TARGET_INFORMATIONW TargetInfo,
    PCREDENTIALW Credential,
    DWORD Flags
    );

BOOL
CredWriteDomainCredentialsA (
    PCREDENTIAL_TARGET_INFORMATIONA TargetInfo,
    PCREDENTIALA Credential,
    DWORD Flags
    );
]]

return Lib;

--[[
return {
CredDeleteA
CredDeleteW
CredEnumerateA
CredEnumerateW
CredFindBestCredentialA
CredFindBestCredentialW
CredFree
CredGetSessionTypes
CredGetTargetInfoA
CredGetTargetInfoW
CredIsMarshaledCredentialW
CredIsProtectedA
CredIsProtectedW
CredMarshalCredentialA
CredMarshalCredentialW
CredProtectA
CredProtectW
CredReadA
CredReadDomainCredentialsA
CredReadDomainCredentialsW
CredReadW
CredUnmarshalCredentialA
CredUnmarshalCredentialW
CredUnprotectA
CredUnprotectW
CredWriteA
CredWriteDomainCredentialsA
CredWriteDomainCredentialsW
CredWriteW
}
--]]