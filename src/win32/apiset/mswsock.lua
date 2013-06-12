-- mswsock.lua
-- mswsock.dll

local ffi = require("ffi");
local WTypes = require("WTypes");


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
AcceptEx
-- dn_expand
EnumProtocolsA
EnumProtocolsW
GetAcceptExSockaddrs
GetAddressByNameA
GetAddressByNameW
GetNameByTypeA
GetNameByTypeW
--getnetbyname
GetServiceA
GetServiceW
--GetSocketErrorMessageW
GetTypeByNameA
GetTypeByNameW
--inet_network
--MigrateWinsockConfiguration
--MigrateWinsockConfigurationEx
NPLoadNameSpaces
--rcmd
--rexec
--rresvport
--s_perror
--sethostname
SetServiceA
SetServiceW
TransmitFile
WSARecvEx
}
