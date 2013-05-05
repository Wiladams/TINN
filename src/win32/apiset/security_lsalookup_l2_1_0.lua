-- security_lsalookup_l2_1_0.lua
-- api-ms-win-security-lsalookup-l2-1-0.dll

local ffi = require("ffi");	
local advapiLib = ffi.load("advapi32");
require("ntstatus");
require("WinNT");

ffi.cdef[[
typedef PVOID LSA_HANDLE, *PLSA_HANDLE;

//
// LSA Enumeration Context
//

typedef ULONG LSA_ENUMERATION_HANDLE, *PLSA_ENUMERATION_HANDLE;

]]

ffi.cdef[[
BOOL
LookupAccountNameW(
    LPCWSTR lpSystemName,
    LPCWSTR lpAccountName,
    PSID Sid,
    LPDWORD cbSid,
    LPWSTR ReferencedDomainName,
    LPDWORD cchReferencedDomainName,
    PSID_NAME_USE peUse
    );

BOOL
LookupAccountSidW(
    LPCWSTR lpSystemName,
    PSID Sid,
    LPWSTR Name,
    LPDWORD cchName,
    LPWSTR ReferencedDomainName,
    LPDWORD cchReferencedDomainName,
    PSID_NAME_USE peUse
    );

BOOL
LookupPrivilegeDisplayNameW(
    LPCWSTR lpSystemName,
    LPCWSTR lpName,
    LPWSTR lpDisplayName,
    LPDWORD cchDisplayName,
    LPDWORD lpLanguageId
    );

BOOL
LookupPrivilegeNameW(
    LPCWSTR lpSystemName,
    PLUID   lpLuid,
    LPWSTR lpName,
    LPDWORD cchName
    );

BOOL
LookupPrivilegeValueW(
    LPCWSTR lpSystemName,
    LPCWSTR lpName,
    PLUID   lpLuid
    );

NTSTATUS
LsaEnumerateTrustedDomains(
    LSA_HANDLE PolicyHandle,
    PLSA_ENUMERATION_HANDLE EnumerationContext,
    PVOID *Buffer,
    ULONG PreferedMaximumLength,
    PULONG CountReturned
    );
]]

return {
	Lib = advapiLib,

	LookupAccountNameW = advapiLib.LookupAccountNameW,
	LookupAccountSidW = advapiLib.LookupAccountSidW,
	LookupPrivilegeDisplayNameW = advapiLib.LookupPrivilegeDisplayNameW,
	LookupPrivilegeNameW = advapiLib.LookupPrivilegeNameW,
	LookupPrivilegeValueW = advapiLib.LookupPrivilegeValueW,
	LsaEnumerateTrustedDomains = advapiLib.LsaEnumerateTrustedDomains,
}

