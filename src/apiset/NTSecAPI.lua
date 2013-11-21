local ffi = require("ffi");
require ("WTypes");
require ("ntstatus");
require ("SubAuth");
require ("WinNT");
local advapiLib = ffi.load("AdvApi32");

ffi.cdef[[
typedef PVOID LSA_HANDLE, *PLSA_HANDLE;

//
// LSA Enumeration Context
//

typedef ULONG LSA_ENUMERATION_HANDLE, *PLSA_ENUMERATION_HANDLE;

]]

ffi.cdef[[
typedef ULONG  LSA_OPERATIONAL_MODE, *PLSA_OPERATIONAL_MODE;

typedef ULONG_PTR LSA_SEC_HANDLE;
typedef LSA_SEC_HANDLE * PLSA_SEC_HANDLE;

]]

ffi.cdef[[
typedef UNICODE_STRING LSA_UNICODE_STRING, *PLSA_UNICODE_STRING;
typedef STRING LSA_STRING, *PLSA_STRING;
]]

ffi.cdef[[
typedef struct _LSA_OBJECT_ATTRIBUTES {
    ULONG Length;
    HANDLE RootDirectory;
    PLSA_UNICODE_STRING ObjectName;
    ULONG Attributes;
    PVOID SecurityDescriptor;        // Points to type SECURITY_DESCRIPTOR
    PVOID SecurityQualityOfService;  // Points to type SECURITY_QUALITY_OF_SERVICE
} LSA_OBJECT_ATTRIBUTES, *PLSA_OBJECT_ATTRIBUTES;
]]


ffi.cdef[[
typedef enum _POLICY_NOTIFICATION_INFORMATION_CLASS {

    PolicyNotifyAuditEventsInformation = 1,
    PolicyNotifyAccountDomainInformation,
    PolicyNotifyServerRoleInformation,
    PolicyNotifyDnsDomainInformation,
    PolicyNotifyDomainEfsInformation,
    PolicyNotifyDomainKerberosTicketInformation,
    PolicyNotifyMachineAccountPasswordInformation,
    PolicyNotifyGlobalSaclInformation,
    PolicyNotifyMax // must always be the last entry

} POLICY_NOTIFICATION_INFORMATION_CLASS, *PPOLICY_NOTIFICATION_INFORMATION_CLASS;
]]


ffi.cdef[[
////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Local Security Policy Administration API datatypes and defines         //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

//
// Access types for the Policy object
//

static const int POLICY_VIEW_LOCAL_INFORMATION              = 0x00000001;
static const int POLICY_VIEW_AUDIT_INFORMATION              = 0x00000002;
static const int POLICY_GET_PRIVATE_INFORMATION             = 0x00000004;
static const int POLICY_TRUST_ADMIN                         = 0x00000008;
static const int POLICY_CREATE_ACCOUNT                      = 0x00000010;
static const int POLICY_CREATE_SECRET                       = 0x00000020;
static const int POLICY_CREATE_PRIVILEGE                    = 0x00000040;
static const int POLICY_SET_DEFAULT_QUOTA_LIMITS            = 0x00000080;
static const int POLICY_SET_AUDIT_REQUIREMENTS              = 0x00000100;
static const int POLICY_AUDIT_LOG_ADMIN                     = 0x00000200;
static const int POLICY_SERVER_ADMIN                        = 0x00000400;
static const int POLICY_LOOKUP_NAMES                        = 0x00000800;
static const int POLICY_NOTIFICATION                        = 0x00001000;

static const int POLICY_ALL_ACCESS    = (STANDARD_RIGHTS_REQUIRED         |\
                               POLICY_VIEW_LOCAL_INFORMATION    |\
                               POLICY_VIEW_AUDIT_INFORMATION    |\
                               POLICY_GET_PRIVATE_INFORMATION   |\
                               POLICY_TRUST_ADMIN               |\
                               POLICY_CREATE_ACCOUNT            |\
                               POLICY_CREATE_SECRET             |\
                               POLICY_CREATE_PRIVILEGE          |\
                               POLICY_SET_DEFAULT_QUOTA_LIMITS  |\
                               POLICY_SET_AUDIT_REQUIREMENTS    |\
                               POLICY_AUDIT_LOG_ADMIN           |\
                               POLICY_SERVER_ADMIN              |\
                               POLICY_LOOKUP_NAMES);


static const int POLICY_READ          = (STANDARD_RIGHTS_READ             |\
                               POLICY_VIEW_AUDIT_INFORMATION    |\
                               POLICY_GET_PRIVATE_INFORMATION);

static const int POLICY_WRITE         = (STANDARD_RIGHTS_WRITE            |\
                               POLICY_TRUST_ADMIN               |\
                               POLICY_CREATE_ACCOUNT            |\
                               POLICY_CREATE_SECRET             |\
                               POLICY_CREATE_PRIVILEGE          |\
                               POLICY_SET_DEFAULT_QUOTA_LIMITS  |\
                               POLICY_SET_AUDIT_REQUIREMENTS    |\
                               POLICY_AUDIT_LOG_ADMIN           |\
                               POLICY_SERVER_ADMIN);

static const int POLICY_EXECUTE       = (STANDARD_RIGHTS_EXECUTE          |\
                               POLICY_VIEW_LOCAL_INFORMATION    |\
                               POLICY_LOOKUP_NAMES);
]]

ffi.cdef[[
NTSTATUS LsaClose(LSA_HANDLE ObjectHandle);


NTSTATUS
LsaEnumerateAccountRights(
    LSA_HANDLE PolicyHandle,
    PSID AccountSid,
    PLSA_UNICODE_STRING *UserRights,
    PULONG CountOfRights
    );

ULONG
LsaNtStatusToWinError(NTSTATUS Status);

NTSTATUS
LsaOpenPolicy(
    PLSA_UNICODE_STRING SystemName,
    PLSA_OBJECT_ATTRIBUTES ObjectAttributes,
    ACCESS_MASK DesiredAccess,
    PLSA_HANDLE PolicyHandle
    );
]]


return {

    LsaClose = advapiLib.LsaClose,
    LsaEnumerateAccountRights = advapiLib.LsaEnumerateAccountRights,
    LsaNtStatusToWinError = advapiLib.LsaNtStatusToWinError,
    LsaOpenPolicy = advapiLib.LsaOpenPolicy,
}