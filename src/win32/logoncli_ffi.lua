-- logoncli_ffi.lua

local ffi = require ("ffi");
local Lib = ffi.load("logoncli"); -- logoncli.dll
require("WTypes");
require("ntstatus");
local winsock = require("win_socket");

ffi.cdef[[
typedef DWORD NET_API_STATUS;
]]

ffi.cdef[[
//
// API to enumerate trusted domains
//
static const int DS_DOMAIN_IN_FOREST          = 0x0001;  // Domain is a member of the forest
static const int DS_DOMAIN_DIRECT_OUTBOUND    = 0x0002;  // Domain is directly trusted
static const int DS_DOMAIN_TREE_ROOT          = 0x0004;  // Domain is root of a tree in the forest
static const int DS_DOMAIN_PRIMARY            = 0x0008;  // Domain is the primary domain of queried server
static const int DS_DOMAIN_NATIVE_MODE        = 0x0010;  // Primary domain is running in native mode
static const int DS_DOMAIN_DIRECT_INBOUND     = 0x0020;  // Domain is directly trusting
static const int DS_DOMAIN_VALID_FLAGS = (DS_DOMAIN_IN_FOREST | DS_DOMAIN_DIRECT_OUTBOUND | DS_DOMAIN_TREE_ROOT | DS_DOMAIN_PRIMARY | DS_DOMAIN_NATIVE_MODE | DS_DOMAIN_DIRECT_INBOUND );


typedef struct _DS_DOMAIN_TRUSTSW {
    //
    // Name of the trusted domain.
    //
    LPWSTR NetbiosDomainName;
    LPWSTR DnsDomainName;

    //
    // Flags defining attributes of the trust.
    //
    ULONG Flags;

    //
    // Index to the domain that is the parent of this domain.
    //  Only defined if NETLOGON_DOMAIN_IN_FOREST is set and
    //      NETLOGON_DOMAIN_TREE_ROOT is not set.
    //
    ULONG ParentIndex;

    //
    // The trust type and attributes of this trust.
    //
    // If NETLOGON_DOMAIN_DIRECTLY_TRUSTED is not set,
    //  these value are infered.
    //
    ULONG TrustType;
    ULONG TrustAttributes;

    //
    // The SID of the trusted domain.
    //
    // If NETLOGON_DOMAIN_DIRECTLY_TRUSTED is not set,
    //  this value will be NULL.
    //
    PSID DomainSid;

    //
    // The GUID of the trusted domain.
    //

    GUID DomainGuid;

} DS_DOMAIN_TRUSTSW, *PDS_DOMAIN_TRUSTSW;


//
// ANSI version of the above struct
//
typedef struct _DS_DOMAIN_TRUSTSA {
    LPSTR NetbiosDomainName;
    LPSTR DnsDomainName;
    ULONG Flags;
    ULONG ParentIndex;
    ULONG TrustType;
    ULONG TrustAttributes;
    PSID DomainSid;
    GUID DomainGuid;
} DS_DOMAIN_TRUSTSA, *PDS_DOMAIN_TRUSTSA;
]]

ffi.cdef[[
//
// Structure returned from DsGetDcName
//

typedef struct _DOMAIN_CONTROLLER_INFOA {
    LPSTR DomainControllerName;
    LPSTR DomainControllerAddress;
    ULONG DomainControllerAddressType;
    GUID DomainGuid;
    LPSTR DomainName;
    LPSTR DnsForestName;
    ULONG Flags;
    LPSTR DcSiteName;
    LPSTR ClientSiteName;
} DOMAIN_CONTROLLER_INFOA, *PDOMAIN_CONTROLLER_INFOA;

typedef struct _DOMAIN_CONTROLLER_INFOW {
    LPWSTR DomainControllerName;
    LPWSTR DomainControllerAddress;
    ULONG DomainControllerAddressType;
    GUID DomainGuid;
    LPWSTR DomainName;
    LPWSTR DnsForestName;
    ULONG Flags;
    LPWSTR DcSiteName;
    LPWSTR ClientSiteName;
} DOMAIN_CONTROLLER_INFOW, *PDOMAIN_CONTROLLER_INFOW;
]]

ffi.cdef[[
typedef struct _UNICODE_STRING {
    USHORT Length;
    USHORT MaximumLength;
    PWSTR Buffer;
} UNICODE_STRING, *PUNICODE_STRING;

typedef struct _STRING {
    USHORT Length;
    USHORT MaximumLength;
    PCHAR Buffer;
} STRING, *PSTRING;

typedef UNICODE_STRING LSA_UNICODE_STRING, *PLSA_UNICODE_STRING;
typedef STRING LSA_STRING, *PLSA_STRING;

typedef enum {

    ForestTrustTopLevelName,
    ForestTrustTopLevelNameEx,
    ForestTrustDomainInfo,
    ForestTrustRecordTypeLast = ForestTrustDomainInfo

} LSA_FOREST_TRUST_RECORD_TYPE;

typedef struct _LSA_FOREST_TRUST_DOMAIN_INFO {
    PSID Sid;
    LSA_UNICODE_STRING DnsName;
    LSA_UNICODE_STRING NetbiosName;

} LSA_FOREST_TRUST_DOMAIN_INFO, *PLSA_FOREST_TRUST_DOMAIN_INFO;


//
//  To prevent huge data to be passed in, we should put a limit on LSA_FOREST_TRUST_BINARY_DATA.
//      128K is large enough that can't be reached in the near future, and small enough not to
//      cause memory problems.

static const int MAX_FOREST_TRUST_BINARY_DATA_SIZE = ( 128 * 1024 );


typedef struct _LSA_FOREST_TRUST_BINARY_DATA {

    ULONG Length;
    PUCHAR Buffer;
} LSA_FOREST_TRUST_BINARY_DATA, *PLSA_FOREST_TRUST_BINARY_DATA;

typedef struct _LSA_FOREST_TRUST_RECORD {

    ULONG Flags;
    LSA_FOREST_TRUST_RECORD_TYPE ForestTrustType; // type of record
    LARGE_INTEGER Time;


    union {                                       // actual data

        LSA_UNICODE_STRING TopLevelName;
        LSA_FOREST_TRUST_DOMAIN_INFO DomainInfo;
        LSA_FOREST_TRUST_BINARY_DATA Data;        // used for unrecognized types
    } ForestTrustData;

} LSA_FOREST_TRUST_RECORD, *PLSA_FOREST_TRUST_RECORD;

static const int MAX_RECORDS_IN_FOREST_TRUST_INFO = 4000;

typedef struct _LSA_FOREST_TRUST_INFORMATION {
    ULONG RecordCount;
    PLSA_FOREST_TRUST_RECORD * Entries;
} LSA_FOREST_TRUST_INFORMATION, *PLSA_FOREST_TRUST_INFORMATION;
]]

ffi.cdef[[
DWORD
DsAddressToSiteNamesA(
    LPCSTR ComputerName ,
    DWORD EntryCount,
    PSOCKET_ADDRESS SocketAddresses,
    LPSTR **SiteNames
    );

DWORD
DsAddressToSiteNamesExA(
    LPCSTR ComputerName ,
    DWORD EntryCount,
    PSOCKET_ADDRESS SocketAddresses,
    LPSTR **SiteNames,
    LPSTR **SubnetNames
    );

DWORD
DsAddressToSiteNamesExW(
    LPCWSTR ComputerName ,
    DWORD EntryCount,
    PSOCKET_ADDRESS SocketAddresses,
    LPWSTR **SiteNames,
    LPWSTR **SubnetNames
    );

DWORD
DsAddressToSiteNamesW(
    LPCWSTR ComputerName ,
    DWORD EntryCount,
    PSOCKET_ADDRESS SocketAddresses,
    LPWSTR **SiteNames
    );
]]

ffi.cdef[[
DWORD
DsDeregisterDnsHostRecordsA (
    LPSTR ServerName ,
    LPSTR DnsDomainName ,
    GUID  *DomainGuid ,
    GUID  *DsaGuid ,
    LPSTR DnsHostName
    );

DWORD
DsDeregisterDnsHostRecordsW (
    LPWSTR ServerName ,
    LPWSTR DnsDomainName ,
    GUID   *DomainGuid ,
    GUID   *DsaGuid ,
    LPWSTR DnsHostName
    );
]]

ffi.cdef[[
DWORD
DsEnumerateDomainTrustsA (
    LPSTR ServerName ,
    ULONG Flags,
    PDS_DOMAIN_TRUSTSA *Domains,
    PULONG DomainCount
    );

DWORD
DsEnumerateDomainTrustsW (
     LPWSTR ServerName ,
     ULONG Flags,
    PDS_DOMAIN_TRUSTSW *Domains,
    PULONG DomainCount
    );
]]

ffi.cdef[[
void
DsGetDcCloseW(HANDLE GetDcContextHandle);
]]

ffi.cdef[[
DWORD
DsGetDcNameA(
      LPCSTR ComputerName ,
      LPCSTR DomainName ,
     GUID *DomainGuid ,
      LPCSTR SiteName ,
     ULONG Flags,
     PDOMAIN_CONTROLLER_INFOA *DomainControllerInfo
);

DWORD
DsGetDcNameW(
      LPCWSTR ComputerName ,
      LPCWSTR DomainName ,
     GUID *DomainGuid ,
      LPCWSTR SiteName ,
     ULONG Flags,
     PDOMAIN_CONTROLLER_INFOW *DomainControllerInfo
);


DWORD
DsGetDcNextA(
     HANDLE GetDcContextHandle,
     PULONG SockAddressCount ,
     LPSOCKET_ADDRESS *SockAddresses ,
     LPSTR *DnsHostName 
    );

DWORD
DsGetDcNextW(
     HANDLE GetDcContextHandle,
     PULONG SockAddressCount ,
     LPSOCKET_ADDRESS *SockAddresses ,
     LPWSTR *DnsHostName 
    );
]]

ffi.cdef[[
DWORD
DsGetDcOpenA(
     LPCSTR DnsName,
     ULONG OptionFlags,
     LPCSTR SiteName ,
     GUID *DomainGuid ,
     LPCSTR DnsForestName ,
     ULONG DcFlags,
     PHANDLE RetGetDcContext
    );

DWORD
DsGetDcOpenW(
     LPCWSTR DnsName,
     ULONG OptionFlags,
     LPCWSTR SiteName ,
     GUID *DomainGuid ,
     LPCWSTR DnsForestName ,
     ULONG DcFlags,
     PHANDLE RetGetDcContext
    );
]]

ffi.cdef[[
DWORD
DsGetDcSiteCoverageA(
      LPCSTR ServerName ,
     PULONG EntryCount,
     LPSTR **SiteNames
    );

DWORD
DsGetDcSiteCoverageW(
      LPCWSTR ServerName ,
     PULONG EntryCount,
     LPWSTR **SiteNames
    );
]]

ffi.cdef[[
DWORD
DsGetForestTrustInformationW (
     LPCWSTR ServerName ,
     LPCWSTR TrustedDomainName ,
     DWORD Flags,
     PLSA_FOREST_TRUST_INFORMATION *ForestTrustInfo
    );
]]

ffi.cdef[[
DWORD
DsGetSiteNameA(
      LPCSTR ComputerName ,
     LPSTR *SiteName
);

DWORD
DsGetSiteNameW(
      LPCWSTR ComputerName ,
     LPWSTR *SiteName
);
]]

ffi.cdef[[
DWORD
DsMergeForestTrustInformationW(
     LPCWSTR DomainName,
     PLSA_FOREST_TRUST_INFORMATION NewForestTrustInfo,
     PLSA_FOREST_TRUST_INFORMATION OldForestTrustInfo ,
     PLSA_FOREST_TRUST_INFORMATION *MergedForestTrustInfo
    );
]]

ffi.cdef[[
 DWORD
DsValidateSubnetNameA(LPCSTR SubnetName);

DWORD
DsValidateSubnetNameW(LPCWSTR SubnetName);
]]

ffi.cdef[[
NTSTATUS
NetAddServiceAccount(
     LPWSTR ServerName,
     LPWSTR AccountName,
     LPWSTR Reserved,
     DWORD Flags);

NTSTATUS
NetEnumerateServiceAccounts(
    LPWSTR ServerName,
    DWORD Flags,
    DWORD* AccountsCount,
    PZPWSTR* Accounts);

NET_API_STATUS
NetGetAnyDCName (
    LPCWSTR   servername ,
    LPCWSTR   domainname ,
    LPBYTE  *bufptr
    );

NET_API_STATUS
NetGetDCName (
    LPCWSTR   servername ,
    LPCWSTR   domainname ,
    LPBYTE  *bufptr
    );

NTSTATUS
NetIsServiceAccount(
     LPWSTR ServerName,
     LPWSTR AccountName,
    BOOL *IsService);

NTSTATUS
NetQueryServiceAccount(
     LPWSTR ServerName,
     LPWSTR AccountName,
     DWORD InfoLevel,
    PBYTE* Buffer);

NTSTATUS
NetRemoveServiceAccount(
     LPWSTR ServerName,
     LPWSTR AccountName,
     DWORD Flags);
]]


return {
	Lib = Lib,

DsAddressToSiteNamesA = Lib.DsAddressToSiteNamesA,
DsAddressToSiteNamesExA = Lib.DsAddressToSiteNamesExA,
DsAddressToSiteNamesExW = Lib.DsAddressToSiteNamesExW,
DsAddressToSiteNamesW = Lib.DsAddressToSiteNamesW,
DsDeregisterDnsHostRecordsA = Lib.DsDeregisterDnsHostRecordsA,
DsDeregisterDnsHostRecordsW = Lib.DsDeregisterDnsHostRecordsW,
DsEnumerateDomainTrustsA = Lib.DsEnumerateDomainTrustsA,
DsEnumerateDomainTrustsW = Lib.DsEnumerateDomainTrustsW,
DsGetDcCloseW = Lib.DsGetDcCloseW,
DsGetDcNameA = Lib.DsGetDcNameA,
DsGetDcNameW = Lib.DsGetDcNameW,
--DsGetDcNameWithAccountA,
--DsGetDcNameWithAccountW,
DsGetDcNextA = Lib.DsGetDcNextA,
DsGetDcNextW = Lib.DsGetDcNextW,
DsGetDcOpenA = Lib.DsGetDcOpenA,
DsGetDcOpenW = Lib.DsGetDcOpenW,
DsGetDcSiteCoverageA = Lib.DsGetDcSiteCoverageA,
DsGetDcSiteCoverageW = Lib.DsGetDcSiteCoverageW,
DsGetForestTrustInformationW = Lib.DsGetForestTrustInformationW,
DsGetSiteNameA = Lib.DsGetSiteNameA,
DsGetSiteNameW = Lib.DsGetSiteNameW,
DsMergeForestTrustInformationW = Lib.DsMergeForestTrustInformationW,
DsValidateSubnetNameA = Lib.DsValidateSubnetNameA,
DsValidateSubnetNameW = Lib.DsValidateSubnetNameW,
NetAddServiceAccount = Lib.NetAddServiceAccount,
NetEnumerateServiceAccounts = Lib.NetEnumerateServiceAccounts,
NetGetAnyDCName = Lib.NetGetAnyDCName,
NetGetDCName = Lib.NetGetDCName,
NetIsServiceAccount = Lib.NetIsServiceAccount,
--NetLogonGetTimeServiceParentDomain,
NetQueryServiceAccount = Lib.NetQueryServiceAccount,
NetRemoveServiceAccount = Lib.NetRemoveServiceAccount,
--NlSetDsIsCloningPDC,
}
