-- service_management_l1_1_0.lua	
-- api-ms-win-service-management-l1-1-0.dll	

local ffi = require("ffi");
local advapiLib = ffi.load("AdvApi32");
require("WTypes");
local WinNT = require("WinNT");
local service_core = require("service_core_l1_1_1");

ffi.cdef[[
static const int SC_MANAGER_ALL_ACCESS = (0xF003F);
static const int SC_MANAGER_CONNECT =(0x0001);
static const int SC_MANAGER_ENUMERATE_SERVICE =(0x0004);
]]

ffi.cdef[[
//
// The following defines are for service stop reason codes
//

//
// Stop reason flags. Update SERVICE_STOP_REASON_FLAG_MAX when
// new flags are added.
//
static const int SERVICE_STOP_REASON_FLAG_MIN                            = 0x00000000;
static const int SERVICE_STOP_REASON_FLAG_UNPLANNED                      = 0x10000000;
static const int SERVICE_STOP_REASON_FLAG_CUSTOM                         = 0x20000000;
static const int SERVICE_STOP_REASON_FLAG_PLANNED                        = 0x40000000;
static const int SERVICE_STOP_REASON_FLAG_MAX                            = 0x80000000;

//
// Microsoft major reasons. Update SERVICE_STOP_REASON_MAJOR_MAX when
// new codes are added.
//
static const int SERVICE_STOP_REASON_MAJOR_MIN                           = 0x00000000;
static const int SERVICE_STOP_REASON_MAJOR_OTHER                         = 0x00010000;
static const int SERVICE_STOP_REASON_MAJOR_HARDWARE                      = 0x00020000;
static const int SERVICE_STOP_REASON_MAJOR_OPERATINGSYSTEM               = 0x00030000;
static const int SERVICE_STOP_REASON_MAJOR_SOFTWARE                      = 0x00040000;
static const int SERVICE_STOP_REASON_MAJOR_APPLICATION                   = 0x00050000;
static const int SERVICE_STOP_REASON_MAJOR_NONE                          = 0x00060000;
static const int SERVICE_STOP_REASON_MAJOR_MAX                           = 0x00070000;
static const int SERVICE_STOP_REASON_MAJOR_MIN_CUSTOM                    = 0x00400000;
static const int SERVICE_STOP_REASON_MAJOR_MAX_CUSTOM                    = 0x00ff0000;

//
// Microsoft minor reasons. Update SERVICE_STOP_REASON_MINOR_MAX when
// new codes are added.
//
static const int SERVICE_STOP_REASON_MINOR_MIN                           = 0x00000000;
static const int SERVICE_STOP_REASON_MINOR_OTHER                         = 0x00000001;
static const int SERVICE_STOP_REASON_MINOR_MAINTENANCE                   = 0x00000002;
static const int SERVICE_STOP_REASON_MINOR_INSTALLATION                  = 0x00000003;
static const int SERVICE_STOP_REASON_MINOR_UPGRADE                       = 0x00000004;
static const int SERVICE_STOP_REASON_MINOR_RECONFIG                      = 0x00000005;
static const int SERVICE_STOP_REASON_MINOR_HUNG                          = 0x00000006;
static const int SERVICE_STOP_REASON_MINOR_UNSTABLE                      = 0x00000007;
static const int SERVICE_STOP_REASON_MINOR_DISK                          = 0x00000008;
static const int SERVICE_STOP_REASON_MINOR_NETWORKCARD                   = 0x00000009;
static const int SERVICE_STOP_REASON_MINOR_ENVIRONMENT                   = 0x0000000a;
static const int SERVICE_STOP_REASON_MINOR_HARDWARE_DRIVER               = 0x0000000b;
static const int SERVICE_STOP_REASON_MINOR_OTHERDRIVER                   = 0x0000000c;
static const int SERVICE_STOP_REASON_MINOR_SERVICEPACK                   = 0x0000000d;
static const int SERVICE_STOP_REASON_MINOR_SOFTWARE_UPDATE               = 0x0000000e;
static const int SERVICE_STOP_REASON_MINOR_SECURITYFIX                   = 0x0000000f;
static const int SERVICE_STOP_REASON_MINOR_SECURITY                      = 0x00000010;
static const int SERVICE_STOP_REASON_MINOR_NETWORK_CONNECTIVITY          = 0x00000011;
static const int SERVICE_STOP_REASON_MINOR_WMI                           = 0x00000012;
static const int SERVICE_STOP_REASON_MINOR_SERVICEPACK_UNINSTALL         = 0x00000013;
static const int SERVICE_STOP_REASON_MINOR_SOFTWARE_UPDATE_UNINSTALL     = 0x00000014;
static const int SERVICE_STOP_REASON_MINOR_SECURITYFIX_UNINSTALL         = 0x00000015;
static const int SERVICE_STOP_REASON_MINOR_MMC                           = 0x00000016;
static const int SERVICE_STOP_REASON_MINOR_NONE                          = 0x00000017;
static const int SERVICE_STOP_REASON_MINOR_MAX                           = 0x00000018;
static const int SERVICE_STOP_REASON_MINOR_MIN_CUSTOM                    = 0x00000100;
static const int SERVICE_STOP_REASON_MINOR_MAX_CUSTOM                    = 0x0000FFFF;

//
// Service object specific access type
//
static const int SERVICE_QUERY_CONFIG           = 0x0001;
static const int SERVICE_CHANGE_CONFIG          = 0x0002;
static const int SERVICE_QUERY_STATUS           = 0x0004;
static const int SERVICE_ENUMERATE_DEPENDENTS   = 0x0008;
static const int SERVICE_START                  = 0x0010;
static const int SERVICE_STOP                   = 0x0020;
static const int SERVICE_PAUSE_CONTINUE         = 0x0040;
static const int SERVICE_INTERROGATE            = 0x0080;
static const int SERVICE_USER_DEFINED_CONTROL   = 0x0100;

static const int SERVICE_ALL_ACCESS             = (STANDARD_RIGHTS_REQUIRED     | \
                                        SERVICE_QUERY_CONFIG         | \
                                        SERVICE_CHANGE_CONFIG        | \
                                        SERVICE_QUERY_STATUS         | \
                                        SERVICE_ENUMERATE_DEPENDENTS | \
                                        SERVICE_START                | \
                                        SERVICE_STOP                 | \
                                        SERVICE_PAUSE_CONTINUE       | \
                                        SERVICE_INTERROGATE          | \
                                        SERVICE_USER_DEFINED_CONTROL);


//
// Controls
//
static const int SERVICE_CONTROL_STOP                   = 0x00000001;
static const int SERVICE_CONTROL_PAUSE                  = 0x00000002;
static const int SERVICE_CONTROL_CONTINUE               = 0x00000003;
static const int SERVICE_CONTROL_INTERROGATE            = 0x00000004;
static const int SERVICE_CONTROL_SHUTDOWN               = 0x00000005;
static const int SERVICE_CONTROL_PARAMCHANGE            = 0x00000006;
static const int SERVICE_CONTROL_NETBINDADD             = 0x00000007;
static const int SERVICE_CONTROL_NETBINDREMOVE          = 0x00000008;
static const int SERVICE_CONTROL_NETBINDENABLE          = 0x00000009;
static const int SERVICE_CONTROL_NETBINDDISABLE         = 0x0000000A;
static const int SERVICE_CONTROL_DEVICEEVENT            = 0x0000000B;
static const int SERVICE_CONTROL_HARDWAREPROFILECHANGE  = 0x0000000C;
static const int SERVICE_CONTROL_POWEREVENT             = 0x0000000D;
static const int SERVICE_CONTROL_SESSIONCHANGE          = 0x0000000E;
static const int SERVICE_CONTROL_PRESHUTDOWN            = 0x0000000F;
static const int SERVICE_CONTROL_TIMECHANGE             = 0x00000010;
static const int SERVICE_CONTROL_TRIGGEREVENT           = 0x00000020;

//
// Info levels for ControlServiceEx
//
static const int SERVICE_CONTROL_STATUS_REASON_INFO     = 1;

//
// Service control status reason parameters
//
typedef struct _SERVICE_CONTROL_STATUS_REASON_PARAMSA {
    DWORD                   dwReason;
    LPSTR                   pszComment;
    SERVICE_STATUS_PROCESS  ServiceStatus;
} SERVICE_CONTROL_STATUS_REASON_PARAMSA, *PSERVICE_CONTROL_STATUS_REASON_PARAMSA;
//
// Service control status reason parameters
//
typedef struct _SERVICE_CONTROL_STATUS_REASON_PARAMSW {
    DWORD                   dwReason;
    LPWSTR                  pszComment;
    SERVICE_STATUS_PROCESS  ServiceStatus;
} SERVICE_CONTROL_STATUS_REASON_PARAMSW, *PSERVICE_CONTROL_STATUS_REASON_PARAMSW;

]]


ffi.cdef[[
typedef SC_HANDLE   *LPSC_HANDLE;
]]



ffi.cdef[[
BOOL
CloseServiceHandle(SC_HANDLE   hSCObject);

BOOL
ControlServiceExW(
           SC_HANDLE               hService,
           DWORD                   dwControl,
           DWORD                   dwInfoLevel,
        PVOID                   pControlParams
    );

SC_HANDLE
CreateServiceW(
           SC_HANDLE    hSCManager,
           LPCWSTR     lpServiceName,
       LPCWSTR     lpDisplayName,
           DWORD        dwDesiredAccess,
           DWORD        dwServiceType,
           DWORD        dwStartType,
           DWORD        dwErrorControl,
       LPCWSTR     lpBinaryPathName,
       LPCWSTR     lpLoadOrderGroup,
      LPDWORD      lpdwTagId,
       LPCWSTR     lpDependencies,
       LPCWSTR     lpServiceStartName,
       LPCWSTR     lpPassword
    );

BOOL
DeleteService(SC_HANDLE   hService);

SC_HANDLE
OpenSCManagerW(
           LPCWSTR                lpMachineName,
           LPCWSTR                lpDatabaseName,
               DWORD                   dwDesiredAccess
    );

SC_HANDLE
OpenServiceW(SC_HANDLE               hSCManager,
               LPCWSTR                lpServiceName,
               DWORD                   dwDesiredAccess
    );

BOOL
StartServiceW(SC_HANDLE            hService,
               DWORD                dwNumServiceArgs,
                    LPCWSTR             *lpServiceArgVectors
    );
]]


return {
  Lib = advapiLib,
  
	CloseServiceHandle = advapiLib.CloseServiceHandle,
	ControlServiceExW = advapiLib.ControlServiceExW,
	CreateServiceW = advapiLib.CreateServiceW,
	DeleteService = advapiLib.DeleteService,
	OpenSCManagerW = advapiLib.OpenSCManagerW,
	OpenServiceW = advapiLib.OpenServiceW,
	StartServiceW = advapiLib.StartServiceW,
}
