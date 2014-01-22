-- core_namedpipe_l1_2_0.lua	
--api-ms-win-core-namedpipe-l1-2-0.dll	

local ffi = require("ffi");
local WTypes = require("WTypes");
local WinBase = require("WinBase")

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

ffi.cdef[[
//
// Define the NamedPipe definitions
//


//
// Define the dwOpenMode values for CreateNamedPipe
//

static const int PIPE_ACCESS_INBOUND        = 0x00000001;
static const int PIPE_ACCESS_OUTBOUND       = 0x00000002;
static const int PIPE_ACCESS_DUPLEX         = 0x00000003;

//
// Define the Named Pipe End flags for GetNamedPipeInfo
//

static const int PIPE_CLIENT_END            = 0x00000000;
static const int PIPE_SERVER_END            = 0x00000001;

//
// Define the dwPipeMode values for CreateNamedPipe
//

static const int PIPE_WAIT                  = 0x00000000;
static const int PIPE_NOWAIT                = 0x00000001;
static const int PIPE_READMODE_BYTE         = 0x00000000;
static const int PIPE_READMODE_MESSAGE      = 0x00000002;
static const int PIPE_TYPE_BYTE             = 0x00000000;
static const int PIPE_TYPE_MESSAGE          = 0x00000004;
static const int PIPE_ACCEPT_REMOTE_CLIENTS = 0x00000000;
static const int PIPE_REJECT_REMOTE_CLIENTS = 0x00000008;

//
// Define the well known values for CreateNamedPipe nMaxInstances
//

static const int PIPE_UNLIMITED_INSTANCES    = 255;
]]

return {
    Lib = k32Lib,
    AdvApi32 = advapiLib,
    
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