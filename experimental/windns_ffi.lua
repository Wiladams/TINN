local ffi = require("ffi")
local WTypes = require("WTypes")
local IPUtils = require("IPUtils")

ffi.cdef[[
// DNS server validation error codes
static const int DNS_VALSVR_ERROR_INVALID_ADDR             =  0x01;
static const int DNS_VALSVR_ERROR_INVALID_NAME             =  0x02;
static const int DNS_VALSVR_ERROR_UNREACHABLE              =  0x03;
static const int DNS_VALSVR_ERROR_NO_RESPONSE              =  0x04;
static const int DNS_VALSVR_ERROR_NO_AUTH                  =  0x05;
static const int DNS_VALSVR_ERROR_REFUSED                  =  0x06;

static const int DNS_VALSVR_ERROR_NO_TCP                   =  0x10;
static const int DNS_VALSVR_ERROR_UNKNOWN                  =  0xFF;

// For win_error.lua
static const int DNS_ERROR_NON_RFC_NAME          = 9556;
static const int DNS_ERROR_INVALID_NAME_CHAR     = 9560;
]]

ffi.cdef[[
typedef unsigned __int64 QWORD, *PQWORD;
typedef LONG    DNS_STATUS;
typedef DNS_STATUS *PDNS_STATUS;

typedef DWORD   IP4_ADDRESS, *PIP4_ADDRESS;
]]


ffi.cdef[[
typedef struct  _IP4_ARRAY
{
    DWORD           AddrCount;
    IP4_ADDRESS     AddrArray[1];
}
IP4_ARRAY, *PIP4_ARRAY;

typedef union
{
    DWORD       IP6Dword[4];
    WORD        IP6Word[8];
    BYTE        IP6Byte[16];
} IP6_ADDRESS, *PIP6_ADDRESS;
]]


ffi.cdef[[
#pragma pack(push)
#pragma pack(1)

typedef struct _DnsAddr
{
    CHAR            MaxSa[ (32) ];
    union
    {
        DWORD       DnsAddrUserDword[ 8 ];
    }
    Data;
} DNS_ADDR, *PDNS_ADDR;

typedef struct _DnsAddrArray
{
    DWORD           MaxCount;
    DWORD           AddrCount;
    DWORD           Tag;
    WORD            Family;
    WORD            WordReserved;
    DWORD           Flags;
    DWORD           MatchFlag;
    DWORD           Reserved1;
    DWORD           Reserved2;
    DNS_ADDR        AddrArray[ 1 ];
} DNS_ADDR_ARRAY, *PDNS_ADDR_ARRAY;

#pragma pack(pop)
]]


ffi.cdef[[
#pragma pack(push)
#pragma pack(1)

typedef struct _DNS_HEADER
{
    WORD    Xid;

    BYTE    RecursionDesired : 1;
    BYTE    Truncation : 1;
    BYTE    Authoritative : 1;
    BYTE    Opcode : 4;
    BYTE    IsResponse : 1;

    BYTE    ResponseCode : 4;
    BYTE    CheckingDisabled : 1;
    BYTE    AuthenticatedData : 1;
    BYTE    Reserved : 1;
    BYTE    RecursionAvailable : 1;

    WORD    QuestionCount;
    WORD    AnswerCount;
    WORD    NameServerCount;
    WORD    AdditionalCount;
}
DNS_HEADER, *PDNS_HEADER;

typedef struct _DNS_HEADER_EXT
{
    WORD            Reserved : 15;
    WORD            DnssecOk : 1;
    BYTE            chRcode;
    BYTE            chVersion;
}
DNS_HEADER_EXT, *PDNS_HEADER_EXT;

typedef struct _DNS_WIRE_QUESTION
{
    

    WORD    QuestionType;
    WORD    QuestionClass;
}
DNS_WIRE_QUESTION, *PDNS_WIRE_QUESTION;

typedef struct _DNS_WIRE_RECORD
{
    WORD    RecordType;
    WORD    RecordClass;
    DWORD   TimeToLive;
    WORD    DataLength;
} DNS_WIRE_RECORD, *PDNS_WIRE_RECORD;

#pragma pack(pop)
]]

ffi.cdef[[
typedef enum
{
    
    DnsConfigPrimaryDomainName_W,
    DnsConfigPrimaryDomainName_A,
    DnsConfigPrimaryDomainName_UTF8,

    
    DnsConfigAdapterDomainName_W,
    DnsConfigAdapterDomainName_A,
    DnsConfigAdapterDomainName_UTF8,

    
    DnsConfigDnsServerList,

    
    DnsConfigSearchList,
    DnsConfigAdapterInfo,

    
    DnsConfigPrimaryHostNameRegistrationEnabled,
    DnsConfigAdapterHostNameRegistrationEnabled,
    DnsConfigAddressRegistrationMaxCount,

    DnsConfigHostName_W,
    DnsConfigHostName_A,
    DnsConfigHostName_UTF8,
    DnsConfigFullHostName_W,
    DnsConfigFullHostName_A,
    DnsConfigFullHostName_UTF8  
} DNS_CONFIG_TYPE;


DNS_STATUS
DnsQueryConfig(
                                          DNS_CONFIG_TYPE     Config,
                                          DWORD               Flag,
                                      PCWSTR              pwsAdapterName,
                                      PVOID               pReserved,
    PVOID               pBuffer,
                                       PDWORD              pBufLen
    );
]]

ffi.cdef[[
typedef struct
{
    IP4_ADDRESS     IpAddress;
} DNS_A_DATA, *PDNS_A_DATA;

typedef struct
{
    PWSTR           pNameHost;
} DNS_PTR_DATAW, *PDNS_PTR_DATAW;

typedef struct
{
    PSTR            pNameHost;
} DNS_PTR_DATAA, *PDNS_PTR_DATAA;

typedef struct
{
    PWSTR           pNamePrimaryServer;
    PWSTR           pNameAdministrator;
    DWORD           dwSerialNo;
    DWORD           dwRefresh;
    DWORD           dwRetry;
    DWORD           dwExpire;
    DWORD           dwDefaultTtl;
} DNS_SOA_DATAW, *PDNS_SOA_DATAW;

typedef struct
{
    PSTR            pNamePrimaryServer;
    PSTR            pNameAdministrator;
    DWORD           dwSerialNo;
    DWORD           dwRefresh;
    DWORD           dwRetry;
    DWORD           dwExpire;
    DWORD           dwDefaultTtl;
} DNS_SOA_DATAA, *PDNS_SOA_DATAA;

typedef struct
{
    PWSTR           pNameMailbox;
    PWSTR           pNameErrorsMailbox;
} DNS_MINFO_DATAW, *PDNS_MINFO_DATAW;

typedef struct
{
    PSTR            pNameMailbox;
    PSTR            pNameErrorsMailbox;
} DNS_MINFO_DATAA, *PDNS_MINFO_DATAA;

typedef struct
{
    PWSTR           pNameExchange;
    WORD            wPreference;
    WORD            Pad;        
} DNS_MX_DATAW, *PDNS_MX_DATAW;

typedef struct
{
    PSTR            pNameExchange;
    WORD            wPreference;
    WORD            Pad;        
} DNS_MX_DATAA, *PDNS_MX_DATAA;

typedef struct
{
    DWORD           dwStringCount;
    PWSTR           pStringArray[1];
} DNS_TXT_DATAW, *PDNS_TXT_DATAW;

typedef struct
{
    DWORD           dwStringCount;
    PSTR            pStringArray[1];
} DNS_TXT_DATAA, *PDNS_TXT_DATAA;

typedef struct
{
    DWORD           dwByteCount;
    BYTE            Data[1];
} DNS_NULL_DATA, *PDNS_NULL_DATA;

typedef struct
{
    IP4_ADDRESS     IpAddress;
    UCHAR           chProtocol;
    BYTE            BitMask[1];
} DNS_WKS_DATA, *PDNS_WKS_DATA;

typedef struct
{
    IP6_ADDRESS     Ip6Address;
} DNS_AAAA_DATA, *PDNS_AAAA_DATA;

typedef struct
{
    WORD            wTypeCovered;
    BYTE            chAlgorithm;
    BYTE            chLabelCount;
    DWORD           dwOriginalTtl;
    DWORD           dwExpiration;
    DWORD           dwTimeSigned;
    WORD            wKeyTag;
    WORD            wSignatureLength;
    PWSTR           pNameSigner;
    BYTE            Signature[1];
} DNS_SIG_DATAW, *PDNS_SIG_DATAW, DNS_RRSIG_DATAW, *PDNS_RRSIG_DATAW;

typedef struct
{
    WORD            wTypeCovered;
    BYTE            chAlgorithm;
    BYTE            chLabelCount;
    DWORD           dwOriginalTtl;
    DWORD           dwExpiration;
    DWORD           dwTimeSigned;
    WORD            wKeyTag;
    WORD            wSignatureLength;
    PSTR            pNameSigner;
    BYTE            Signature[1];
} DNS_SIG_DATAA, *PDNS_SIG_DATAA, DNS_RRSIG_DATAA, *PDNS_RRSIG_DATAA;

typedef struct
{
    WORD            wFlags;
    BYTE            chProtocol;
    BYTE            chAlgorithm;
    WORD            wKeyLength;
    WORD            wPad;            
    BYTE            Key[1];
} DNS_KEY_DATA, *PDNS_KEY_DATA, DNS_DNSKEY_DATA, *PDNS_DNSKEY_DATA;

typedef struct
{
    DWORD           dwByteCount;
    BYTE            DHCID[1];
} DNS_DHCID_DATA, *PDNS_DHCID_DATA;

typedef struct
{
    PWSTR           pNextDomainName;
    WORD            wTypeBitMapsLength;
    WORD            wPad;            
    BYTE            TypeBitMaps[1];
} DNS_NSEC_DATAW, *PDNS_NSEC_DATAW;

typedef struct
{
    PSTR            pNextDomainName;
    WORD            wTypeBitMapsLength;
    WORD            wPad;            
    BYTE            TypeBitMaps[1];
} DNS_NSEC_DATAA, *PDNS_NSEC_DATAA;

typedef struct
{
    BYTE            chAlgorithm;
    BYTE            bFlags;
    WORD            wIterations;
    BYTE            bSaltLength;
    BYTE            bHashLength;
    WORD            wTypeBitMapsLength;
    BYTE            chData[1];
} DNS_NSEC3_DATA, *PDNS_NSEC3_DATA;

typedef struct
{
    BYTE            chAlgorithm;
    BYTE            bFlags;
    WORD            wIterations;
    BYTE            bSaltLength;
    BYTE            bPad[3];        
    BYTE            pbSalt[1];
} DNS_NSEC3PARAM_DATA, *PDNS_NSEC3PARAM_DATA;

typedef struct
{
    WORD            wKeyTag;
    BYTE            chAlgorithm;
    BYTE            chDigestType;
    WORD            wDigestLength;
    WORD            wPad;            
    BYTE            Digest[1];
} DNS_DS_DATA, *PDNS_DS_DATA;

typedef struct
{
    WORD            wDataLength;
    WORD            wPad;            
    BYTE            Data[1];
} DNS_OPT_DATA, *PDNS_OPT_DATA;

typedef struct
{
    WORD            wVersion;
    WORD            wSize;
    WORD            wHorPrec;
    WORD            wVerPrec;
    DWORD           dwLatitude;
    DWORD           dwLongitude;
    DWORD           dwAltitude;
} DNS_LOC_DATA, *PDNS_LOC_DATA;

typedef struct
{
    PWSTR           pNameNext;
    WORD            wNumTypes;
    WORD            wTypes[1];
} DNS_NXT_DATAW, *PDNS_NXT_DATAW;

typedef struct
{
    PSTR            pNameNext;
    WORD            wNumTypes;
    WORD            wTypes[1];
} DNS_NXT_DATAA, *PDNS_NXT_DATAA;

typedef struct
{
    PWSTR           pNameTarget;
    WORD            wPriority;
    WORD            wWeight;
    WORD            wPort;
    WORD            Pad;            
} DNS_SRV_DATAW, *PDNS_SRV_DATAW;

typedef struct
{
    PSTR            pNameTarget;
    WORD            wPriority;
    WORD            wWeight;
    WORD            wPort;
    WORD            Pad;            
} DNS_SRV_DATAA, *PDNS_SRV_DATAA;

typedef struct
{
    WORD            wOrder;
    WORD            wPreference;
    PWSTR           pFlags;
    PWSTR           pService;
    PWSTR           pRegularExpression;
    PWSTR           pReplacement;
} DNS_NAPTR_DATAW, *PDNS_NAPTR_DATAW;

typedef struct
{
    WORD            wOrder;
    WORD            wPreference;
    PSTR            pFlags;
    PSTR            pService;
    PSTR            pRegularExpression;
    PSTR            pReplacement;
} DNS_NAPTR_DATAA, *PDNS_NAPTR_DATAA;

typedef struct
{
    BYTE            AddressType;
    BYTE            Address[ (20) ];    
} DNS_ATMA_DATA, *PDNS_ATMA_DATA;


typedef struct
{
    PWSTR           pNameAlgorithm;
    PBYTE           pAlgorithmPacket;
    PBYTE           pKey;
    PBYTE           pOtherData;
    DWORD           dwCreateTime;
    DWORD           dwExpireTime;
    WORD            wMode;
    WORD            wError;
    WORD            wKeyLength;
    WORD            wOtherLength;
    UCHAR           cAlgNameLength;
    BOOL            bPacketPointers;
} DNS_TKEY_DATAW, *PDNS_TKEY_DATAW;

typedef struct
{
    PSTR            pNameAlgorithm;
    PBYTE           pAlgorithmPacket;
    PBYTE           pKey;
    PBYTE           pOtherData;
    DWORD           dwCreateTime;
    DWORD           dwExpireTime;
    WORD            wMode;
    WORD            wError;
    WORD            wKeyLength;
    WORD            wOtherLength;
    UCHAR           cAlgNameLength;
    BOOL            bPacketPointers;
} DNS_TKEY_DATAA, *PDNS_TKEY_DATAA;

typedef struct
{
    PWSTR           pNameAlgorithm;
    PBYTE           pAlgorithmPacket;
    PBYTE           pSignature;
    PBYTE           pOtherData;
    LONGLONG        i64CreateTime;
    WORD            wFudgeTime;
    WORD            wOriginalXid;
    WORD            wError;
    WORD            wSigLength;
    WORD            wOtherLength;
    UCHAR           cAlgNameLength;
    BOOL            bPacketPointers;
} DNS_TSIG_DATAW, *PDNS_TSIG_DATAW;

typedef struct
{
    PSTR            pNameAlgorithm;
    PBYTE           pAlgorithmPacket;
    PBYTE           pSignature;
    PBYTE           pOtherData;
    LONGLONG        i64CreateTime;
    WORD            wFudgeTime;
    WORD            wOriginalXid;
    WORD            wError;
    WORD            wSigLength;
    WORD            wOtherLength;
    UCHAR           cAlgNameLength;
    BOOL            bPacketPointers;
} DNS_TSIG_DATAA, *PDNS_TSIG_DATAA;

typedef struct
{
    DWORD           dwMappingFlag;
    DWORD           dwLookupTimeout;
    DWORD           dwCacheTimeout;
    DWORD           cWinsServerCount;
    IP4_ADDRESS     WinsServers[1];
} DNS_WINS_DATA, *PDNS_WINS_DATA;

typedef struct
{
    DWORD           dwMappingFlag;
    DWORD           dwLookupTimeout;
    DWORD           dwCacheTimeout;
    PWSTR           pNameResultDomain;
} DNS_WINSR_DATAW, *PDNS_WINSR_DATAW;

typedef struct
{
    DWORD           dwMappingFlag;
    DWORD           dwLookupTimeout;
    DWORD           dwCacheTimeout;
    PSTR            pNameResultDomain;
} DNS_WINSR_DATAA, *PDNS_WINSR_DATAA;
]]

ffi.cdef[[
typedef DNS_PTR_DATAA   DNS_PTR_DATA,   *PDNS_PTR_DATA;
typedef DNS_SOA_DATAA   DNS_SOA_DATA,   *PDNS_SOA_DATA;
typedef DNS_MINFO_DATAA DNS_MINFO_DATA, *PDNS_MINFO_DATA;
typedef DNS_MX_DATAA    DNS_MX_DATA,    *PDNS_MX_DATA;
typedef DNS_TXT_DATAA   DNS_TXT_DATA,   *PDNS_TXT_DATA;
typedef DNS_SIG_DATAA   DNS_SIG_DATA,   *PDNS_SIG_DATA;
typedef DNS_NXT_DATAA   DNS_NXT_DATA,   *PDNS_NXT_DATA;
typedef DNS_SRV_DATAA   DNS_SRV_DATA,   *PDNS_SRV_DATA;
typedef DNS_NAPTR_DATAA DNS_NAPTR_DATA, *PDNS_NAPTR_DATA;
typedef DNS_RRSIG_DATAA DNS_RRSIG_DATA, *PDNS_RRSIG_DATA;
typedef DNS_NSEC_DATAA  DNS_NSEC_DATA,  *PDNS_NSEC_DATA;
typedef DNS_TKEY_DATAA  DNS_TKEY_DATA,  *PDNS_TKEY_DATA;
typedef DNS_TSIG_DATAA  DNS_TSIG_DATA,  *PDNS_TSIG_DATA;
typedef DNS_WINSR_DATAA DNS_WINSR_DATA, *PDNS_WINSR_DATA;
]]


ffi.cdef[[
typedef struct _DnsRecordFlags
{
    DWORD   Section     : 2;
    DWORD   Delete      : 1;
    DWORD   CharSet     : 2;
    DWORD   Unused      : 3;

    DWORD   Reserved    : 24;
} DNS_RECORD_FLAGS;

typedef enum _DnsSection
{
    DnsSectionQuestion,
    DnsSectionAnswer,
    DnsSectionAuthority,
    DnsSectionAddtional,
} DNS_SECTION;
]]

ffi.cdef[[
// _Struct_size_bytes_(FIELD_OFFSET(struct _DnsRecordW, Data) + wDataLength)
typedef  struct _DnsRecordW
{
    struct _DnsRecordW *    pNext;
    PWSTR                   pName;
    WORD                    wType;
    WORD                    wDataLength;    
                                            
    union
    {
        DWORD               DW;     
        DNS_RECORD_FLAGS    S;      

    } Flags;

    DWORD                   dwTtl;
    DWORD                   dwReserved;

    union
    {
        DNS_A_DATA          A;
        DNS_SOA_DATAW       SOA, Soa;
        DNS_PTR_DATAW       PTR, Ptr,
                            NS, Ns,
                            CNAME, Cname,
                            DNAME, Dname,
                            MB, Mb,
                            MD, Md,
                            MF, Mf,
                            MG, Mg,
                            MR, Mr;
        DNS_MINFO_DATAW     MINFO, Minfo,
                            RP, Rp;
        DNS_MX_DATAW        MX, Mx,
                            AFSDB, Afsdb,
                            RT, Rt;
        DNS_TXT_DATAW       HINFO, Hinfo,
                            ISDN, Isdn,
                            TXT, Txt,
                            X25;
        DNS_NULL_DATA       Null;
        DNS_WKS_DATA        WKS, Wks;
        DNS_AAAA_DATA       AAAA;
        DNS_KEY_DATA        KEY, Key;
        DNS_SIG_DATAW       SIG, Sig;
        DNS_ATMA_DATA       ATMA, Atma;
        DNS_NXT_DATAW       NXT, Nxt;
        DNS_SRV_DATAW       SRV, Srv;
        DNS_NAPTR_DATAW     NAPTR, Naptr;
        DNS_OPT_DATA        OPT, Opt;
        DNS_DS_DATA         DS, Ds;
        DNS_RRSIG_DATAW     RRSIG, Rrsig;
        DNS_NSEC_DATAW      NSEC, Nsec;
        DNS_DNSKEY_DATA     DNSKEY, Dnskey;
        DNS_TKEY_DATAW      TKEY, Tkey;
        DNS_TSIG_DATAW      TSIG, Tsig;
        DNS_WINS_DATA       WINS, Wins;
        DNS_WINSR_DATAW     WINSR, WinsR, NBSTAT, Nbstat;
        DNS_DHCID_DATA      DHCID;
        DNS_NSEC3_DATA      NSEC3, Nsec3;
        DNS_NSEC3PARAM_DATA	NSEC3PARAM, Nsec3Param;
        PBYTE               pDataPtr;

    } Data;
} DNS_RECORDW, *PDNS_RECORDW;
]]

ffi.cdef[[
typedef struct _DnsRecordOptW
{
    struct _DnsRecordW *    pNext;
    PWSTR                   pName;
    WORD                    wType;
    WORD                    wDataLength;    
                                            
    union
    {
        DWORD               DW;     
        DNS_RECORD_FLAGS    S;      

    } Flags;

    DNS_HEADER_EXT          ExtHeader;      
    WORD                    wPayloadSize;   
    WORD                    wReserved;

    
    union
    {
        DNS_OPT_DATA        OPT, Opt;

    } Data;
}
DNS_RECORD_OPTW, *PDNS_RECORD_OPTW;
]]

ffi.cdef[[
// _Struct_size_bytes_(FIELD_OFFSET(struct _DnsRecordA, Data) + wDataLength)
typedef  struct _DnsRecordA
{
    struct _DnsRecordA *    pNext;
    PSTR                    pName;
    WORD                    wType;
    WORD                    wDataLength; 
                                     
    union
    {
        DWORD               DW;     
        DNS_RECORD_FLAGS    S;      

    } Flags;

    DWORD               dwTtl;
    DWORD               dwReserved;

    union
    {
        DNS_A_DATA          A;
        DNS_SOA_DATAA       SOA, Soa;
        DNS_PTR_DATAA       PTR, Ptr,
                            NS, Ns,
                            CNAME, Cname,
                            DNAME, Dname,
                            MB, Mb,
                            MD, Md,
                            MF, Mf,
                            MG, Mg,
                            MR, Mr;
        DNS_MINFO_DATAA     MINFO, Minfo,
                            RP, Rp;
        DNS_MX_DATAA        MX, Mx,
                            AFSDB, Afsdb,
                            RT, Rt;
        DNS_TXT_DATAA       HINFO, Hinfo,
                            ISDN, Isdn,
                            TXT, Txt,
                            X25;
        DNS_NULL_DATA       Null;
        DNS_WKS_DATA        WKS, Wks;
        DNS_AAAA_DATA       AAAA;
        DNS_KEY_DATA        KEY, Key;
        DNS_SIG_DATAA       SIG, Sig;
        DNS_ATMA_DATA       ATMA, Atma;
        DNS_NXT_DATAA       NXT, Nxt;
        DNS_SRV_DATAA       SRV, Srv;
        DNS_NAPTR_DATAA     NAPTR, Naptr;
        DNS_OPT_DATA        OPT, Opt;
        DNS_DS_DATA         DS, Ds;
        DNS_RRSIG_DATAA     RRSIG, Rrsig;
        DNS_NSEC_DATAA      NSEC, Nsec;
        DNS_DNSKEY_DATA     DNSKEY, Dnskey;
        DNS_TKEY_DATAA      TKEY, Tkey;
        DNS_TSIG_DATAA      TSIG, Tsig;
        DNS_WINS_DATA       WINS, Wins;
        DNS_WINSR_DATAA     WINSR, WinsR, NBSTAT, Nbstat;
        DNS_DHCID_DATA      DHCID;
        DNS_NSEC3_DATA      NSEC3, Nsec3;
        DNS_NSEC3PARAM_DATA NSEC3PARAM, Nsec3Param;
        PBYTE               pDataPtr;

    } Data;
}
DNS_RECORDA, *PDNS_RECORDA;
]]

ffi.cdef[[
typedef struct _DnsRecordOptA
{
    struct _DnsRecordA *    pNext;
    PSTR                    pName;
    WORD                    wType;
    WORD                    wDataLength; 
                                     
    union
    {
        DWORD               DW;     
        DNS_RECORD_FLAGS    S;      

    } Flags;

    DNS_HEADER_EXT          ExtHeader;      
    WORD                    wPayloadSize;   
    WORD                    wReserved;

    

    union
    {
        DNS_OPT_DATA        OPT, Opt;

    } Data;
}
DNS_RECORD_OPTA, *PDNS_RECORD_OPTA;
]]

ffi.cdef[[
typedef DNS_RECORDA         DNS_RECORD, *PDNS_RECORD;
typedef DNS_RECORD_OPTA     DNS_RECORD_OPT, *PDNS_RECORD_OPT;
]]


ffi.cdef[[
typedef struct _DnsRRSet
{
    PDNS_RECORD     pFirstRR;
    PDNS_RECORD     pLastRR;
} DNS_RRSET, *PDNS_RRSET;
]]



ffi.cdef[[
typedef void (__stdcall *DNS_PROXY_COMPLETION_ROUTINE) (void *completionContext, DNS_STATUS status);
]]

ffi.cdef[[
typedef enum DNS_PROXY_INFORMATION_TYPE {
                DNS_PROXY_INFORMATION_DIRECT,
                DNS_PROXY_INFORMATION_DEFAULT_SETTINGS,
                DNS_PROXY_INFORMATION_PROXY_NAME,
                DNS_PROXY_INFORMATION_DOES_NOT_EXIST
}   DNS_PROXY_INFORMATION_TYPE;

typedef struct DNS_PROXY_INFORMATION {
                ULONG version;  
                 DNS_PROXY_INFORMATION_TYPE proxyInformationType;
                 PWSTR proxyName;
} DNS_PROXY_INFORMATION;

]]

ffi.cdef[[
typedef enum _DNS_CHARSET
{
    DnsCharSetUnknown,
    DnsCharSetUnicode,
    DnsCharSetUtf8,
    DnsCharSetAnsi,
} DNS_CHARSET;


PDNS_RECORD
DnsRecordCopyEx(
        PDNS_RECORD     pRecord,
        DNS_CHARSET     CharSetIn,
        DNS_CHARSET     CharSetOut
    );

PDNS_RECORD
DnsRecordSetCopyEx(
        PDNS_RECORD     pRecordSet,
        DNS_CHARSET     CharSetIn,
        DNS_CHARSET     CharSetOut
    );
]]

ffi.cdef[[
BOOL
DnsRecordCompare(
    PDNS_RECORD     pRecord1,
    PDNS_RECORD     pRecord2);

BOOL
DnsRecordSetCompare(
    PDNS_RECORD     pRR1,
    PDNS_RECORD     pRR2,
    PDNS_RECORD *   ppDiff1,
    PDNS_RECORD *   ppDiff2);

PDNS_RECORD
DnsRecordSetDetach(PDNS_RECORD     pRecordList);
]]


ffi.cdef[[
typedef enum
{
    DnsFreeFlat = 0,
    DnsFreeRecordList,
    DnsFreeParsedMessageFields
} DNS_FREE_TYPE;

void
DnsFree(
         PVOID    pData,
            DNS_FREE_TYPE   FreeType
    );


void
DnsRecordListFree(
     PDNS_RECORD     pRecordList,
            DNS_FREE_TYPE   FreeType
    );
]]

ffi.cdef[[

DNS_STATUS
DnsQuery_A(
                    PCSTR           pszName,
                    WORD            wType,
                    DWORD           Options,
             PVOID           pExtra,
         PDNS_RECORD *   ppQueryResults,
     PVOID *         pReserved
    );

DNS_STATUS
DnsQuery_UTF8(
                    PCSTR           pszName,
                    WORD            wType,
                    DWORD           Options,
             PVOID           pExtra,
         PDNS_RECORD *   ppQueryResults,
     PVOID *         pReserved
    );

DNS_STATUS
DnsQuery_W(
                    PCWSTR          pszName,
                    WORD            wType,
                    DWORD           Options,
             PVOID           pExtra,
         PDNS_RECORD *   ppQueryResults,
     PVOID *         pReserved
    );
]]

ffi.cdef[[
typedef struct _DNS_QUERY_RESULT
{
            ULONG           Version;
           DNS_STATUS      QueryStatus;
           ULONG64         QueryOptions;
           PDNS_RECORD     pQueryRecords;
     PVOID           Reserved;
}
DNS_QUERY_RESULT, *PDNS_QUERY_RESULT;

typedef
VOID 
DNS_QUERY_COMPLETION_ROUTINE(
            PVOID               pQueryContext,
         PDNS_QUERY_RESULT   pQueryResults
);

typedef DNS_QUERY_COMPLETION_ROUTINE *PDNS_QUERY_COMPLETION_ROUTINE;



typedef struct _DNS_QUERY_REQUEST
{
            ULONG           Version;
        PCWSTR          QueryName;
            WORD            QueryType;
            ULONG64         QueryOptions;
        PDNS_ADDR_ARRAY pDnsServerList;
        ULONG           InterfaceIndex;
        PDNS_QUERY_COMPLETION_ROUTINE   pQueryCompletionCallback;
            PVOID           pQueryContext;
} DNS_QUERY_REQUEST, *PDNS_QUERY_REQUEST;

typedef struct _DNS_QUERY_CANCEL
{
    CHAR            Reserved[32];
} DNS_QUERY_CANCEL, *PDNS_QUERY_CANCEL;

DNS_STATUS
DnsQueryEx(
            PDNS_QUERY_REQUEST  pQueryRequest,
         PDNS_QUERY_RESULT   pQueryResults,
     PDNS_QUERY_CANCEL   pCancelHandle
    );

DNS_STATUS
DnsCancelQuery(
            PDNS_QUERY_CANCEL    pCancelHandle
    );
]]

ffi.cdef[[
static const int DNS_UPDATE_SECURITY_USE_DEFAULT    = 0x00000000;
static const int DNS_UPDATE_SECURITY_OFF            = 0x00000010;
static const int DNS_UPDATE_SECURITY_ON             = 0x00000020;
static const int DNS_UPDATE_SECURITY_ONLY           = 0x00000100;
static const int DNS_UPDATE_CACHE_SECURITY_CONTEXT  = 0x00000200;
static const int DNS_UPDATE_TEST_USE_LOCAL_SYS_ACCT = 0x00000400;
static const int DNS_UPDATE_FORCE_SECURITY_NEGO     = 0x00000800;
static const int DNS_UPDATE_TRY_ALL_MASTER_SERVERS  = 0x00001000;
static const int DNS_UPDATE_SKIP_NO_UPDATE_ADAPTERS = 0x00002000;
static const int DNS_UPDATE_REMOTE_SERVER           = 0x00004000;
static const int DNS_UPDATE_RESERVED                = 0xffff0000;

]]

ffi.cdef[[
DNS_STATUS
DnsAcquireContextHandle_W(
                DWORD           CredentialFlags,
            PVOID           Credentials,
         PHANDLE         pContext
    );

DNS_STATUS
DnsAcquireContextHandle_A(
                DWORD           CredentialFlags,
            PVOID           Credentials,
         PHANDLE         pContext
    );

VOID
DnsReleaseContextHandle(
            HANDLE          hContext
    );
]]


ffi.cdef[[
DNS_STATUS
DnsModifyRecordsInSet_W(
            PDNS_RECORD     pAddRecords,
            PDNS_RECORD     pDeleteRecords,
                DWORD           Options,
            HANDLE          hCredentials,
         PVOID           pExtraList,
         PVOID           pReserved
    );

DNS_STATUS
DnsModifyRecordsInSet_A(
            PDNS_RECORD     pAddRecords,
            PDNS_RECORD     pDeleteRecords,
                DWORD           Options,
            HANDLE          hCredentials,
         PVOID           pExtraList,
         PVOID           pReserved
    );

DNS_STATUS
DnsModifyRecordsInSet_UTF8(
            PDNS_RECORD     pAddRecords,
            PDNS_RECORD     pDeleteRecords,
                DWORD           Options,
            HANDLE          hCredentials,
         PVOID           pExtraList,
         PVOID           pReserved
    );
]]

ffi.cdef[[
DNS_STATUS
DnsReplaceRecordSetW(
                PDNS_RECORD     pReplaceSet,
                DWORD           Options,
            HANDLE          hContext,
         PVOID           pExtraInfo,
         PVOID           pReserved
    );

DNS_STATUS
DnsReplaceRecordSetA(
                PDNS_RECORD     pReplaceSet,
                DWORD           Options,
            HANDLE          hContext,
         PVOID           pExtraInfo,
         PVOID           pReserved
    );

DNS_STATUS
DnsReplaceRecordSetUTF8(
                PDNS_RECORD     pReplaceSet,
                DWORD           Options,
            HANDLE          hContext,
         PVOID           pExtraInfo,
         PVOID           pReserved
    );
]]

ffi.cdef[[
typedef enum _DNS_NAME_FORMAT
{
    DnsNameDomain,
    DnsNameDomainLabel,
    DnsNameHostnameFull,
    DnsNameHostnameLabel,
    DnsNameWildcard,
    DnsNameSrvRecord,
    DnsNameValidateTld
}
DNS_NAME_FORMAT;


DNS_STATUS
DnsValidateName_W(
        PCWSTR          pszName,
        DNS_NAME_FORMAT Format
    );

DNS_STATUS
DnsValidateName_A(
        PCSTR           pszName,
        DNS_NAME_FORMAT Format
    );

DNS_STATUS
DnsValidateName_UTF8(
        PCSTR           pszName,
        DNS_NAME_FORMAT Format
    );
]]


ffi.cdef[[
BOOL
DnsNameCompare_A(
        PCSTR           pName1,
        PCSTR           pName2
    );

BOOL
DnsNameCompare_W(
        PCWSTR          pName1,
        PCWSTR          pName2
    );
]]


ffi.cdef[[
typedef struct _DNS_MESSAGE_BUFFER
{
    DNS_HEADER  MessageHead;
    CHAR        MessageBody[1];
} DNS_MESSAGE_BUFFER, *PDNS_MESSAGE_BUFFER;

BOOL
DnsWriteQuestionToBuffer_W(
    PDNS_MESSAGE_BUFFER pDnsBuffer,
    PDWORD              pdwBufferSize,
    PCWSTR              pszName,
    WORD                wType,
    WORD                Xid,
    BOOL                fRecursionDesired);

BOOL
DnsWriteQuestionToBuffer_UTF8(
         PDNS_MESSAGE_BUFFER pDnsBuffer,
         PDWORD              pdwBufferSize,
            PCSTR               pszName,
            WORD                wType,
            WORD                Xid,
            BOOL                fRecursionDesired
    );

DNS_STATUS
DnsExtractRecordsFromMessage_W(
                PDNS_MESSAGE_BUFFER pDnsBuffer,
                WORD                wMessageLength,
         PDNS_RECORD *       ppRecord
    );

DNS_STATUS
DnsExtractRecordsFromMessage_UTF8(
                PDNS_MESSAGE_BUFFER pDnsBuffer,
                WORD                wMessageLength,
         PDNS_RECORD *       ppRecord
    );
]]

ffi.cdef[[
DWORD
DnsGetProxyInformation(
            PCWSTR                          hostName,
         DNS_PROXY_INFORMATION *         proxyInformation,
     DNS_PROXY_INFORMATION *         defaultProxyInformation,
        DNS_PROXY_COMPLETION_ROUTINE    completionRoutine,
        void *                          completionContext
    );

void DnsFreeProxyName(PWSTR   proxyName);
]]

ffi.cdef[[
//
//  DNS Record Types
//
//  _TYPE_ defines are in host byte order.
//  _RTYPE_ defines are in net byte order.
//
//  Generally always deal with types in host byte order as we index
//  resource record functions by type.
//

static const int DNS_TYPE_ZERO       = 0x0000;

//  RFC 1034/1035
static const int DNS_TYPE_A          = 0x0001;      //  1
static const int DNS_TYPE_NS         = 0x0002;      //  2
static const int DNS_TYPE_MD         = 0x0003;      //  3
static const int DNS_TYPE_MF         = 0x0004;      //  4
static const int DNS_TYPE_CNAME      = 0x0005;      //  5
static const int DNS_TYPE_SOA        = 0x0006;      //  6
static const int DNS_TYPE_MB         = 0x0007;      //  7
static const int DNS_TYPE_MG         = 0x0008;      //  8
static const int DNS_TYPE_MR         = 0x0009;      //  9
static const int DNS_TYPE_NULL       = 0x000a;      //  10
static const int DNS_TYPE_WKS        = 0x000b;      //  11
static const int DNS_TYPE_PTR        = 0x000c;      //  12
static const int DNS_TYPE_HINFO      = 0x000d;      //  13
static const int DNS_TYPE_MINFO      = 0x000e;      //  14
static const int DNS_TYPE_MX         = 0x000f;      //  15
static const int DNS_TYPE_TEXT       = 0x0010;      //  16

//  RFC 1183
static const int DNS_TYPE_RP         = 0x0011;      //  17
static const int DNS_TYPE_AFSDB      = 0x0012;      //  18
static const int DNS_TYPE_X25        = 0x0013;      //  19
static const int DNS_TYPE_ISDN       = 0x0014;      //  20
static const int DNS_TYPE_RT         = 0x0015;      //  21

//  RFC 1348
static const int DNS_TYPE_NSAP       = 0x0016;      //  22
static const int DNS_TYPE_NSAPPTR    = 0x0017;      //  23

//  RFC 2065    (DNS security)
static const int DNS_TYPE_SIG        = 0x0018;      //  24
static const int DNS_TYPE_KEY        = 0x0019;      //  25

//  RFC 1664    (X.400 mail)
static const int DNS_TYPE_PX         = 0x001a;      //  26

//  RFC 1712    (Geographic position)
static const int DNS_TYPE_GPOS       = 0x001b;      //  27

//  RFC 1886    (IPv6 Address)
static const int DNS_TYPE_AAAA       = 0x001c;      //  28

//  RFC 1876    (Geographic location)
static const int DNS_TYPE_LOC        = 0x001d;      //  29

//  RFC 2065    (Secure negative response)
static const int DNS_TYPE_NXT        = 0x001e;      //  30

//  Patton      (Endpoint Identifier)
static const int DNS_TYPE_EID        = 0x001f;      //  31

//  Patton      (Nimrod Locator)
static const int DNS_TYPE_NIMLOC     = 0x0020;      //  32

//  RFC 2052    (Service location)
static const int DNS_TYPE_SRV        = 0x0021;      //  33

//  ATM Standard something-or-another (ATM Address)
static const int DNS_TYPE_ATMA       = 0x0022;      //  34

//  RFC 2168    (Naming Authority Pointer)
static const int DNS_TYPE_NAPTR      = 0x0023;      //  35

//  RFC 2230    (Key Exchanger)
static const int DNS_TYPE_KX         = 0x0024;      //  36

//  RFC 2538    (CERT)
static const int DNS_TYPE_CERT       = 0x0025;      //  37

//  A6 Draft    (A6)
static const int DNS_TYPE_A6         = 0x0026;      //  38

//  DNAME Draft (DNAME)
static const int DNS_TYPE_DNAME      = 0x0027;      //  39

//  Eastlake    (Kitchen Sink)
static const int DNS_TYPE_SINK       = 0x0028;      //  40

//  RFC 2671    (EDNS OPT)
static const int DNS_TYPE_OPT        = 0x0029;      //  41

//  RFC 4034    (DNSSEC DS)
static const int DNS_TYPE_DS         = 0x002b;      //  43

//  RFC 4034    (DNSSEC RRSIG)
static const int DNS_TYPE_RRSIG      = 0x002e;      //  46

//  RFC 4034    (DNSSEC NSEC)
static const int DNS_TYPE_NSEC       = 0x002f;      //  47

//  RFC 4034    (DNSSEC DNSKEY)
static const int DNS_TYPE_DNSKEY     = 0x0030;      //  48

//  RFC 4701    (DHCID)
static const int DNS_TYPE_DHCID      = 0x0031;      //  49

//  RFC 5155    (DNSSEC NSEC3)
static const int DNS_TYPE_NSEC3      = 0x0032;      //  50

//  RFC 5155    (DNSSEC NSEC3PARAM)
static const int DNS_TYPE_NSEC3PARAM = 0x0033;      //  51

//
//  IANA Reserved
//

static const int DNS_TYPE_UINFO      = 0x0064;      //  100
static const int DNS_TYPE_UID        = 0x0065;      //  101
static const int DNS_TYPE_GID        = 0x0066;      //  102
static const int DNS_TYPE_UNSPEC     = 0x0067;      //  103
]]



--[[
    Helper functions
--]]
local htons = IPUtils.htons;

local function DNS_BYTE_FLIP_HEADER_COUNTS(pHeader)                                   
    pHeader.Xid             = htons(pHeader.Xid);
    pHeader.QuestionCount   = htons(pHeader.QuestionCount);
    pHeader.AnswerCount     = htons(pHeader.AnswerCount);
    pHeader.NameServerCount = htons(pHeader.NameServerCount);
    pHeader.AdditionalCount = htons(pHeader.AdditionalCount);
end


local Lib = ffi.load("Dnsapi")

return {
    DNS_BYTE_FLIP_HEADER_COUNTS = DNS_BYTE_FLIP_HEADER_COUNTS,

    DnsExtractRecordsFromMessage_W = Lib.DnsExtractRecordsFromMessage_W,
    DnsFree = Lib.DnsFree,
    DnsFreeProxyName = Lib.DnsFreeProxyName, 
    DnsGetProxyInformation = Lib.DnsGetProxyInformation,
    DnsQuery = Lib.DnsQuery_A,
    DnsQueryConfig = Lib.DnsQueryConfig,
    DnsQueryEx = Lib.DnsQueryEx,

    DnsValidateName = Lib.DnsValidateName_A,
    DnsWriteQuestionToBuffer_W = Lib.DnsWriteQuestionToBuffer_W,
    DnsWriteQuestionToBuffer_UTF8 = Lib.DnsWriteQuestionToBuffer_UTF8,

}