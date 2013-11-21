-- core_debug_l1_1_1.lua	
-- api-ms-win-core-debug-l1-1-1.dll	

local ffi = require("ffi");
local WTypes = require("WTypes");
local WinNT = require("WinNT");
local WinBase = require("WinBase");

local Lib = ffi.load("kernel32");

ffi.cdef[[
//
// Debug APIs
//
static const int EXCEPTION_DEBUG_EVENT      = 1;
static const int CREATE_THREAD_DEBUG_EVENT  = 2;
static const int CREATE_PROCESS_DEBUG_EVENT = 3;
static const int EXIT_THREAD_DEBUG_EVENT    = 4;
static const int EXIT_PROCESS_DEBUG_EVENT   = 5;
static const int LOAD_DLL_DEBUG_EVENT       = 6;
static const int UNLOAD_DLL_DEBUG_EVENT     = 7;
static const int OUTPUT_DEBUG_STRING_EVENT  = 8;
static const int RIP_EVENT                  = 9;

typedef struct _EXCEPTION_DEBUG_INFO {
    EXCEPTION_RECORD ExceptionRecord;
    DWORD dwFirstChance;
} EXCEPTION_DEBUG_INFO, *LPEXCEPTION_DEBUG_INFO;

typedef struct _CREATE_THREAD_DEBUG_INFO {
    HANDLE hThread;
    LPVOID lpThreadLocalBase;
    LPTHREAD_START_ROUTINE lpStartAddress;
} CREATE_THREAD_DEBUG_INFO, *LPCREATE_THREAD_DEBUG_INFO;

typedef struct _CREATE_PROCESS_DEBUG_INFO {
    HANDLE hFile;
    HANDLE hProcess;
    HANDLE hThread;
    LPVOID lpBaseOfImage;
    DWORD dwDebugInfoFileOffset;
    DWORD nDebugInfoSize;
    LPVOID lpThreadLocalBase;
    LPTHREAD_START_ROUTINE lpStartAddress;
    LPVOID lpImageName;
    WORD fUnicode;
} CREATE_PROCESS_DEBUG_INFO, *LPCREATE_PROCESS_DEBUG_INFO;

typedef struct _EXIT_THREAD_DEBUG_INFO {
    DWORD dwExitCode;
} EXIT_THREAD_DEBUG_INFO, *LPEXIT_THREAD_DEBUG_INFO;

typedef struct _EXIT_PROCESS_DEBUG_INFO {
    DWORD dwExitCode;
} EXIT_PROCESS_DEBUG_INFO, *LPEXIT_PROCESS_DEBUG_INFO;

typedef struct _LOAD_DLL_DEBUG_INFO {
    HANDLE hFile;
    LPVOID lpBaseOfDll;
    DWORD dwDebugInfoFileOffset;
    DWORD nDebugInfoSize;
    LPVOID lpImageName;
    WORD fUnicode;
} LOAD_DLL_DEBUG_INFO, *LPLOAD_DLL_DEBUG_INFO;

typedef struct _UNLOAD_DLL_DEBUG_INFO {
    LPVOID lpBaseOfDll;
} UNLOAD_DLL_DEBUG_INFO, *LPUNLOAD_DLL_DEBUG_INFO;

typedef struct _OUTPUT_DEBUG_STRING_INFO {
    LPSTR lpDebugStringData;
    WORD fUnicode;
    WORD nDebugStringLength;
} OUTPUT_DEBUG_STRING_INFO, *LPOUTPUT_DEBUG_STRING_INFO;

typedef struct _RIP_INFO {
    DWORD dwError;
    DWORD dwType;
} RIP_INFO, *LPRIP_INFO;


typedef struct _DEBUG_EVENT {
    DWORD dwDebugEventCode;
    DWORD dwProcessId;
    DWORD dwThreadId;
    union {
        EXCEPTION_DEBUG_INFO Exception;
        CREATE_THREAD_DEBUG_INFO CreateThread;
        CREATE_PROCESS_DEBUG_INFO CreateProcessInfo;
        EXIT_THREAD_DEBUG_INFO ExitThread;
        EXIT_PROCESS_DEBUG_INFO ExitProcess;
        LOAD_DLL_DEBUG_INFO LoadDll;
        UNLOAD_DLL_DEBUG_INFO UnloadDll;
        OUTPUT_DEBUG_STRING_INFO DebugString;
        RIP_INFO RipInfo;
    } u;
} DEBUG_EVENT, *LPDEBUG_EVENT;

//
// JIT Debugging Info. This structure is defined to have constant size in
// both the emulated and native environment.
//

typedef struct _JIT_DEBUG_INFO {
    DWORD dwSize;
    DWORD dwProcessorArchitecture;
    DWORD dwThreadID;
    DWORD dwReserved0;
    ULONG64 lpExceptionAddress;
    ULONG64 lpExceptionRecord;
    ULONG64 lpContextRecord;
} JIT_DEBUG_INFO, *LPJIT_DEBUG_INFO;

typedef JIT_DEBUG_INFO JIT_DEBUG_INFO32, *LPJIT_DEBUG_INFO32;
typedef JIT_DEBUG_INFO JIT_DEBUG_INFO64, *LPJIT_DEBUG_INFO64;
]]

ffi.cdef[[
BOOL
ContinueDebugEvent(DWORD dwProcessId, DWORD dwThreadId,DWORD dwContinueStatus);

BOOL
DebugActiveProcess(DWORD dwProcessId);

BOOL
DebugActiveProcessStop(DWORD dwProcessId);

void
DebugBreak(void);

BOOL
IsDebuggerPresent(void);

void
OutputDebugStringA(LPCSTR lpOutputString);

void
OutputDebugStringW(LPCWSTR lpOutputString);

BOOL
WaitForDebugEvent(LPDEBUG_EVENT lpDebugEvent, DWORD dwMilliseconds);
]]


return {
	ContinueDebugEvent = Lib.ContinueDebugEvent,
	DebugActiveProcess = Lib.DebugActiveProcess,
	DebugActiveProcessStop = Lib.DebugActiveProcessStop,
	DebugBreak = Lib.DebugBreak,
	IsDebuggerPresent = Lib.IsDebuggerPresent,
	OutputDebugStringA = Lib.OutputDebugStringA,
	OutputDebugStringW = Lib.OutputDebugStringW,
	WaitForDebugEvent = Lib.WaitForDebugEvent,
}
