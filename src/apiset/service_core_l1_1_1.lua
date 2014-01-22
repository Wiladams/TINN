-- service_core_l1_1_1.lua	
-- api-ms-win-service-core-l1-1-1.dll	

local ffi = require("ffi");
local advapiLib = ffi.load("AdvApi32");
require("WTypes");
local WinNT = require("WinNT");


DECLARE_HANDLE("SC_HANDLE");

DECLARE_HANDLE("SERVICE_STATUS_HANDLE");

ffi.cdef[[
//
// Service State -- for CurrentState
//
static const int SERVICE_STOPPED                        = 0x00000001;
static const int SERVICE_START_PENDING                  = 0x00000002;
static const int SERVICE_STOP_PENDING                   = 0x00000003;
static const int SERVICE_RUNNING                        = 0x00000004;
static const int SERVICE_CONTINUE_PENDING               = 0x00000005;
static const int SERVICE_PAUSE_PENDING                  = 0x00000006;
static const int SERVICE_PAUSED                         = 0x00000007;


//
// Service State -- for Enum Requests (Bit Mask)
//
static const int SERVICE_ACTIVE               =  0x00000001;
static const int SERVICE_INACTIVE             =  0x00000002;
static const int SERVICE_STATE_ALL            =  (SERVICE_ACTIVE   | \
                                        SERVICE_INACTIVE);
]]

ffi.cdef[[
//
// Service Status Structures
//

typedef struct _SERVICE_STATUS {
    DWORD   dwServiceType;
    DWORD   dwCurrentState;
    DWORD   dwControlsAccepted;
    DWORD   dwWin32ExitCode;
    DWORD   dwServiceSpecificExitCode;
    DWORD   dwCheckPoint;
    DWORD   dwWaitHint;
} SERVICE_STATUS, *LPSERVICE_STATUS;

typedef struct _SERVICE_STATUS_PROCESS {
    DWORD   dwServiceType;
    DWORD   dwCurrentState;
    DWORD   dwControlsAccepted;
    DWORD   dwWin32ExitCode;
    DWORD   dwServiceSpecificExitCode;
    DWORD   dwCheckPoint;
    DWORD   dwWaitHint;
    DWORD   dwProcessId;
    DWORD   dwServiceFlags;
} SERVICE_STATUS_PROCESS, *LPSERVICE_STATUS_PROCESS;

]]

ffi.cdef[[
//
// Info levels for EnumServicesStatusEx
//
typedef enum _SC_ENUM_TYPE {
    SC_ENUM_PROCESS_INFO        = 0
} SC_ENUM_TYPE;

typedef struct _ENUM_SERVICE_STATUSW {
    LPWSTR            lpServiceName;
    LPWSTR            lpDisplayName;
    SERVICE_STATUS    ServiceStatus;
} ENUM_SERVICE_STATUSW, *LPENUM_SERVICE_STATUSW;

typedef struct _ENUM_SERVICE_STATUS_PROCESSA {
    LPSTR                     lpServiceName;
    LPSTR                     lpDisplayName;
    SERVICE_STATUS_PROCESS    ServiceStatusProcess;
} ENUM_SERVICE_STATUS_PROCESSA, *LPENUM_SERVICE_STATUS_PROCESSA;


typedef struct _ENUM_SERVICE_STATUS_PROCESSW {
    LPWSTR                    lpServiceName;
    LPWSTR                    lpDisplayName;
    SERVICE_STATUS_PROCESS    ServiceStatusProcess;
} ENUM_SERVICE_STATUS_PROCESSW, *LPENUM_SERVICE_STATUS_PROCESSW;

]]

ffi.cdef[[
//
// Function Prototype for the Service Main Function
//

typedef void (* LPSERVICE_MAIN_FUNCTIONW)(DWORD dwNumServicesArgs, LPWSTR  *lpServiceArgVectors);
]]

ffi.cdef[[
typedef DWORD (* LPHANDLER_FUNCTION_EX)(
    DWORD    dwControl,
    DWORD    dwEventType,
    LPVOID   lpEventData,
    LPVOID   lpContext);
]]

ffi.cdef[[
typedef struct _SERVICE_TABLE_ENTRYW {
    LPWSTR                      lpServiceName;
    LPSERVICE_MAIN_FUNCTIONW    lpServiceProc;
}SERVICE_TABLE_ENTRYW, *LPSERVICE_TABLE_ENTRYW;
]]


ffi.cdef[[
BOOL
EnumDependentServicesW(
               SC_HANDLE               hService,
               DWORD                   dwServiceState,
                    LPENUM_SERVICE_STATUSW  lpServices,
               DWORD                   cbBufSize,
              LPDWORD                 pcbBytesNeeded,
              LPDWORD                 lpServicesReturned
    );

BOOL
EnumServicesStatusExA(
               SC_HANDLE               hSCManager,
               SC_ENUM_TYPE            InfoLevel,
               DWORD                   dwServiceType,
               DWORD                   dwServiceState,
                    LPBYTE                  lpServices,
               DWORD                   cbBufSize,
               LPDWORD                 pcbBytesNeeded,
               LPDWORD                 lpServicesReturned,
         LPDWORD                 lpResumeHandle,
            LPCSTR                pszGroupName
    );

BOOL
EnumServicesStatusExW(
               SC_HANDLE               hSCManager,
               SC_ENUM_TYPE            InfoLevel,
               DWORD                   dwServiceType,
               DWORD                   dwServiceState,
                    LPBYTE                  lpServices,
               DWORD                   cbBufSize,
              LPDWORD                 pcbBytesNeeded,
              LPDWORD                 lpServicesReturned,
        LPDWORD                 lpResumeHandle,
           LPCWSTR                pszGroupName
    );

SERVICE_STATUS_HANDLE
RegisterServiceCtrlHandlerExW(
       LPCWSTR                    lpServiceName,
            LPHANDLER_FUNCTION_EX       lpHandlerProc,
    LPVOID                     lpContext
    );

BOOL
SetServiceStatus(
           SERVICE_STATUS_HANDLE   hServiceStatus,
           LPSERVICE_STATUS        lpServiceStatus
    );

BOOL
StartServiceCtrlDispatcherW(
     SERVICE_TABLE_ENTRYW    *lpServiceStartTable
    );
]]


return {
  Lib = advapiLib,
  
	EnumDependentServicesW = advapiLib.EnumDependentServicesW,
	EnumServicesStatusExA = advapiLib.EnumServicesStatusExA,
	EnumServicesStatusExW = advapiLib.EnumServicesStatusExW,
--QueryServiceDynamicInformation
	RegisterServiceCtrlHandlerExW = advapiLib.RegisterServiceCtrlHandlerExW,
	SetServiceStatus = advapiLib.SetServiceStatus,
	StartServiceCtrlDispatcherW = advapiLib.StartServiceCtrlDispatcherW,
}