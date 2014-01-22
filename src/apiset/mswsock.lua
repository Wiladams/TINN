-- mswsock.lua
-- mswsock.dll

local ffi = require("ffi");
local WTypes = require("WTypes");

ffi.cdef[[
typedef  DWORD (* LPFN_NSPAPI) (void ) ;


//
// Structures for using the service routines asynchronously.
//
typedef void (*LPSERVICE_CALLBACK_PROC) (LPARAM lParam, HANDLE hAsyncTaskHandle);

typedef struct _SERVICE_ASYNC_INFO {
    LPSERVICE_CALLBACK_PROC lpServiceCallbackProc;
    LPARAM lParam;
    HANDLE hAsyncTaskHandle;
} SERVICE_ASYNC_INFO, *PSERVICE_ASYNC_INFO, * LPSERVICE_ASYNC_INFO;

typedef struct _NS_ROUTINE {
    DWORD        dwFunctionCount;
    LPFN_NSPAPI *alpfnFunctions;
    DWORD        dwNameSpace;
    DWORD        dwPriority;
} NS_ROUTINE, *PNS_ROUTINE, * LPNS_ROUTINE;

]]

ffi.cdef[[
//
// A Single Address definition.
//
typedef struct _SERVICE_ADDRESS {
    DWORD   dwAddressType ;
    DWORD   dwAddressFlags ;
    DWORD   dwAddressLength ;
    DWORD   dwPrincipalLength ;
    BYTE   *lpAddress ;
    BYTE   *lpPrincipal ;
} SERVICE_ADDRESS, *PSERVICE_ADDRESS, *LPSERVICE_ADDRESS;

//
// Addresses used by the service. Contains array of SERVICE_ADDRESS.
//
typedef struct _SERVICE_ADDRESSES {
    DWORD           dwAddressCount ;
    SERVICE_ADDRESS Addresses[1] ;
} SERVICE_ADDRESSES, *PSERVICE_ADDRESSES, *LPSERVICE_ADDRESSES;
]]

ffi.cdef[[
//
// Service Information.
//
typedef struct _SERVICE_INFOA {
    LPGUID lpServiceType ;
    LPSTR   lpServiceName ;
    LPSTR   lpComment ;
    LPSTR   lpLocale ;
    DWORD dwDisplayHint ;
    DWORD dwVersion ;
    DWORD dwTime ;
    LPSTR   lpMachineName ;
    LPSERVICE_ADDRESSES lpServiceAddress ;
    BLOB ServiceSpecificInfo ;
} SERVICE_INFOA, *PSERVICE_INFOA, * LPSERVICE_INFOA ;
//
// Service Information.
//
typedef struct _SERVICE_INFOW {
    LPGUID lpServiceType ;
    LPWSTR  lpServiceName ;
    LPWSTR  lpComment ;
    LPWSTR  lpLocale ;
    DWORD dwDisplayHint ;
    DWORD dwVersion ;
    DWORD dwTime ;
    LPWSTR  lpMachineName ;
    LPSERVICE_ADDRESSES lpServiceAddress ;
    BLOB ServiceSpecificInfo ;
} SERVICE_INFOW, *PSERVICE_INFOW, * LPSERVICE_INFOW ;
]]

ffi.cdef[[
typedef struct _TRANSMIT_FILE_BUFFERS {
    LPVOID Head;
    DWORD HeadLength;
    LPVOID Tail;
    DWORD TailLength;
} TRANSMIT_FILE_BUFFERS, *PTRANSMIT_FILE_BUFFERS, *LPTRANSMIT_FILE_BUFFERS;
]]


ffi.cdef[[
BOOL AcceptEx (SOCKET sListenSocket, SOCKET sAcceptSocket,
	PVOID lpOutputBuffer,
    DWORD dwReceiveDataLength,
    DWORD dwLocalAddressLength,
    DWORD dwRemoteAddressLength,
    LPDWORD lpdwBytesReceived,
    LPOVERLAPPED lpOverlapped);

INT
EnumProtocolsA (
    LPINT           lpiProtocols,
    LPVOID          lpProtocolBuffer,
    LPDWORD         lpdwBufferLength
    );

INT
EnumProtocolsW (
    LPINT           lpiProtocols,
    LPVOID          lpProtocolBuffer,
    LPDWORD         lpdwBufferLength
    );

VOID
GetAcceptExSockaddrs (
    PVOID lpOutputBuffer,
    DWORD dwReceiveDataLength,
    DWORD dwLocalAddressLength,
    DWORD dwRemoteAddressLength,
    struct sockaddr **LocalSockaddr,
    LPINT LocalSockaddrLength,
    struct sockaddr **RemoteSockaddr,
    LPINT RemoteSockaddrLength
    );

INT
GetAddressByNameA (
        DWORD                dwNameSpace,
        LPGUID               lpServiceType,
    LPSTR                lpServiceName,
    LPINT                lpiProtocols,
        DWORD                dwResolution,
    LPSERVICE_ASYNC_INFO lpServiceAsyncInfo,
    LPVOID               lpCsaddrBuffer,
     LPDWORD              lpdwBufferLength,
    LPSTR  lpAliasBuffer,
    LPDWORD               lpdwAliasBufferLength
    );

INT
GetAddressByNameW (
    DWORD                dwNameSpace,
    LPGUID               lpServiceType,
    LPWSTR               lpServiceName,
    LPINT                lpiProtocols,
    DWORD                dwResolution,
    LPSERVICE_ASYNC_INFO lpServiceAsyncInfo,
    LPVOID               lpCsaddrBuffer,
    LPDWORD              lpdwBufferLength,
    LPWSTR  lpAliasBuffer,
    LPDWORD             lpdwAliasBufferLength
    );

INT
GetNameByTypeA (
    LPGUID          lpServiceType,
    LPSTR         lpServiceName,
    DWORD           dwNameLength
    );

INT
GetNameByTypeW (
    LPGUID          lpServiceType,
    LPWSTR         lpServiceName,
    DWORD           dwNameLength
    );

INT
GetServiceA (
    DWORD                dwNameSpace,
    LPGUID               lpGuid,
    LPSTR                lpServiceName,
    DWORD                dwProperties,
    LPVOID               lpBuffer,
    LPDWORD              lpdwBufferSize,
    LPSERVICE_ASYNC_INFO lpServiceAsyncInfo
    );

INT
GetServiceW (
    DWORD                dwNameSpace,
    LPGUID               lpGuid,
    LPWSTR               lpServiceName,
    DWORD                dwProperties,
    LPVOID               lpBuffer,
    LPDWORD              lpdwBufferSize,
    LPSERVICE_ASYNC_INFO lpServiceAsyncInfo
    );

INT
GetTypeByNameA (
    LPSTR         lpServiceName,
    LPGUID        lpServiceType
    );

INT
GetTypeByNameW (
    LPWSTR         lpServiceName,
    LPGUID         lpServiceType
    );

INT
NPLoadNameSpaces (
    LPDWORD         lpdwVersion,
    LPNS_ROUTINE    nsrBuffer,
    LPDWORD         lpdwBufferLength
    );

INT
SetServiceA (
    DWORD                dwNameSpace,
    DWORD                dwOperation,
    DWORD                dwFlags,
    LPSERVICE_INFOA      lpServiceInfo,
    LPSERVICE_ASYNC_INFO lpServiceAsyncInfo,
    LPDWORD              lpdwStatusFlags
    );

INT
SetServiceW (
        DWORD                dwNameSpace,
        DWORD                dwOperation,
        DWORD                dwFlags,
        LPSERVICE_INFOW      lpServiceInfo,
    LPSERVICE_ASYNC_INFO lpServiceAsyncInfo,
       LPDWORD              lpdwStatusFlags
    );

BOOL
TransmitFile (
    SOCKET hSocket,
    HANDLE hFile,
    DWORD nNumberOfBytesToWrite,
    DWORD nNumberOfBytesPerSend,
    LPOVERLAPPED lpOverlapped,
    LPTRANSMIT_FILE_BUFFERS lpTransmitBuffers,
     DWORD dwReserved
    );

INT WSARecvEx(SOCKET s, CHAR *buf, INT len, INT *flags);
]]


local Lib = ffi.load("mswsock");

return {
    Lib = Lib,
    
    AcceptEx = Lib.AcceptEx,
-- dn_expand
    EnumProtocolsA = Lib.EnumProtocolsA,
    EnumProtocolsW = Lib.EnumProtocolsW,
    GetAcceptExSockaddrs = Lib.GetAcceptExSockaddrs,
    GetAddressByNameA = Lib.GetAddressByNameA,
    GetAddressByNameW = Lib.GetAddressByNameW,
    GetNameByTypeA = Lib.GetNameByTypeA,
    GetNameByTypeW = Lib.GetNameByTypeW,
--getnetbyname
    GetServiceA = Lib.GetServiceA,
    GetServiceW = Lib.GetServiceW,
--GetSocketErrorMessageW
    GetTypeByNameA = Lib.GetTypeByNameA,
    GetTypeByNameW = Lib.GetTypeByNameW,
--inet_network
--MigrateWinsockConfiguration
--MigrateWinsockConfigurationEx
    NPLoadNameSpaces = Lib.NPLoadNameSpaces,
--rcmd
--rexec
--rresvport
--s_perror
--sethostname
    SetServiceA = Lib.SetServiceA,
    SetServiceW = Lib.SetServiceW,
    TransmitFile = Lib.TransmitFile,
    WSARecvEx = Lib.WSARecvEx,
}
