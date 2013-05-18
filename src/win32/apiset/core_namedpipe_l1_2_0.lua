-- core_namedpipe_l1_2_0.lua	
--api-ms-win-core-namedpipe-l1-2-0.dll	

local ffi = require("ffi");
local WTypes = require("WTypes");
local k32Lib = ffi.load("kernel32");
local advapiLib = ffi.load("AdvApi32");

ffi.cdef[[
BOOL
ConnectNamedPipe(
           HANDLE hNamedPipe,
    LPOVERLAPPED lpOverlapped
    );

HANDLE
CreateNamedPipeW(
        LPCWSTR lpName,
        DWORD dwOpenMode,
        DWORD dwPipeMode,
        DWORD nMaxInstances,
        DWORD nOutBufferSize,
        DWORD nInBufferSize,
        DWORD nDefaultTimeOut,
    LPSECURITY_ATTRIBUTES lpSecurityAttributes
    );

BOOL
CreatePipe(
    PHANDLE hReadPipe,
    PHANDLE hWritePipe,
    LPSECURITY_ATTRIBUTES lpPipeAttributes,
        DWORD nSize
    );

BOOL
DisconnectNamedPipe(
    HANDLE hNamedPipe
    );

BOOL
GetNamedPipeClientComputerNameW(
    HANDLE Pipe,
    LPWSTR ClientComputerName,
    ULONG ClientComputerNameLength
    );

BOOL
ImpersonateNamedPipeClient(
    HANDLE hNamedPipe
    );

BOOL
PeekNamedPipe(
    HANDLE hNamedPipe,
    LPVOID lpBuffer,
    DWORD nBufferSize,
    LPDWORD lpBytesRead,
    LPDWORD lpTotalBytesAvail,
    LPDWORD lpBytesLeftThisMessage
    );

BOOL
SetNamedPipeHandleState(
    HANDLE hNamedPipe,
    LPDWORD lpMode,
    LPDWORD lpMaxCollectionCount,
    LPDWORD lpCollectDataTimeout
    );

BOOL
TransactNamedPipe(
           HANDLE hNamedPipe,
    LPVOID lpInBuffer,
           DWORD nInBufferSize,
    LPVOID lpOutBuffer,
           DWORD nOutBufferSize,
          LPDWORD lpBytesRead,
    LPOVERLAPPED lpOverlapped
    );

BOOL
WaitNamedPipeW(
    LPCWSTR lpNamedPipeName,
    DWORD nTimeOut
    );
]]

return {
	ConnectNamedPipe = k32Lib.ConnectNamedPipe,
	CreateNamedPipeW = k32Lib.CreateNamedPipeW,
	CreatePipe = k32Lib.CreatePipe,
	DisconnectNamedPipe = k32Lib.DisconnectNamedPipe,
	GetNamedPipeClientComputerNameW = k32Lib.GetNamedPipeClientComputerNameW,
	ImpersonateNamedPipeClient = advapiLib.ImpersonateNamedPipeClient,
	PeekNamedPipe = k32Lib.PeekNamedPipe,
	SetNamedPipeHandleState = k32Lib.SetNamedPipeHandleState,
	TransactNamedPipe = k32Lib.TransactNamedPipe,
	WaitNamedPipeW = k32Lib.WaitNamedPipeW,
}