-- service_management_l1_1_0.lua	
-- api-ms-win-service-management-l1-1-0.dll	

local ffi = require("ffi");
local advapiLib = ffi.load("AdvApi32");
require("WTypes");
local WinNT = require("WinNT");

ffi.cdef[[
static const int SC_MANAGER_ALL_ACCESS = (0xF003F);
static const int SC_MANAGER_CONNECT =(0x0001);
static const int SC_MANAGER_ENUMERATE_SERVICE =(0x0004);
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
	CloseServiceHandle = advapiLib.CloseServiceHandle,
	ControlServiceExW = advapiLib.ControlServiceExW,
	CreateServiceW = advapiLib.CreateServiceW,
	DeleteService = advapiLib.DeleteService,
	OpenSCManagerW = advapiLib.OpenSCManagerW,
	OpenServiceW = advapiLib.OpenServiceW,
	StartServiceW = advapiLib.StartServiceW,
}
