-- core_processthreads_l1_1_1.lua
-- api-ms-win-core-processthreads-l1-1-1.dll	
local ffi = require("ffi");

local k32Lib = ffi.load("kernel32");
local advLib = ffi.load("Advapi32");
local WinBase = require("WinBase");
local WinNT = require("WinNT");


-- Win8
-- GetCurrentThreadStackLimits
-- GetProcessMitigationPolicy
-- SetProcessMitigationPolicy

-- Advapi32
-- CreateProcessAsUserW
-- OpenProcessToken
-- OpenThreadToken
-- SetThreadToken



ffi.cdef[[
typedef PCONTEXT LPCONTEXT;
typedef PEXCEPTION_RECORD LPEXCEPTION_RECORD;
typedef PEXCEPTION_POINTERS LPEXCEPTION_POINTERS;
]]

ffi.cdef[[
BOOL
CreateProcessA(
    LPCSTR lpApplicationName,
    LPSTR lpCommandLine,
    LPSECURITY_ATTRIBUTES lpProcessAttributes,
    LPSECURITY_ATTRIBUTES lpThreadAttributes,
    BOOL bInheritHandles,
    DWORD dwCreationFlags,
    LPVOID lpEnvironment,
    LPCSTR lpCurrentDirectory,
    LPSTARTUPINFOA lpStartupInfo,
    LPPROCESS_INFORMATION lpProcessInformation
    );


BOOL
CreateProcessAsUserW (
       HANDLE hToken,
       LPCWSTR lpApplicationName,
    LPWSTR lpCommandLine,
       LPSECURITY_ATTRIBUTES lpProcessAttributes,
       LPSECURITY_ATTRIBUTES lpThreadAttributes,
           BOOL bInheritHandles,
           DWORD dwCreationFlags,
       LPVOID lpEnvironment,
       LPCWSTR lpCurrentDirectory,
           LPSTARTUPINFOW lpStartupInfo,
          LPPROCESS_INFORMATION lpProcessInformation
    );

BOOL
CreateProcessW(
       LPCWSTR lpApplicationName,
    LPWSTR lpCommandLine,
       LPSECURITY_ATTRIBUTES lpProcessAttributes,
       LPSECURITY_ATTRIBUTES lpThreadAttributes,
           BOOL bInheritHandles,
           DWORD dwCreationFlags,
       LPVOID lpEnvironment,
       LPCWSTR lpCurrentDirectory,
           LPSTARTUPINFOW lpStartupInfo,
          LPPROCESS_INFORMATION lpProcessInformation
    );

HANDLE
CreateRemoteThread(
         HANDLE hProcess,
     LPSECURITY_ATTRIBUTES lpThreadAttributes,
         SIZE_T dwStackSize,
         LPTHREAD_START_ROUTINE lpStartAddress,
     LPVOID lpParameter,
         DWORD dwCreationFlags,
    LPDWORD lpThreadId
    );

HANDLE
CreateRemoteThreadEx(
         HANDLE hProcess,
     LPSECURITY_ATTRIBUTES lpThreadAttributes,
         SIZE_T dwStackSize,
         LPTHREAD_START_ROUTINE lpStartAddress,
     LPVOID lpParameter,
         DWORD dwCreationFlags,
     LPPROC_THREAD_ATTRIBUTE_LIST lpAttributeList,
    LPDWORD lpThreadId
    );

typedef struct _PROC_THREAD_ATTRIBUTE_LIST *PPROC_THREAD_ATTRIBUTE_LIST, *LPPROC_THREAD_ATTRIBUTE_LIST;

HANDLE
CreateThread(
    LPSECURITY_ATTRIBUTES lpThreadAttributes,
    SIZE_T dwStackSize,
    LPTHREAD_START_ROUTINE lpStartAddress,
    LPVOID lpParameter,
    DWORD dwCreationFlags,
    LPDWORD lpThreadId
    );


void DeleteProcThreadAttributeList(LPPROC_THREAD_ATTRIBUTE_LIST lpAttributeList);

static const int PROC_THREAD_ATTRIBUTE_REPLACE_VALUE    = 0x00000001;

void ExitProcess(UINT uExitCode);

void ExitThread(DWORD dwExitCode);

BOOL
FlushInstructionCache(
    HANDLE hProcess,
    LPCVOID lpBaseAddress,
    SIZE_T dwSize
    );

void FlushProcessWriteBuffers(void);

HANDLE
GetCurrentProcess(void);

DWORD
GetCurrentProcessId(void);

DWORD
GetCurrentProcessorNumber(void);


void GetCurrentProcessorNumberEx(
    PPROCESSOR_NUMBER ProcNumber
    );

HANDLE
GetCurrentThread(void);

DWORD
GetCurrentThreadId(void);
]]




ffi.cdef[[
BOOL
GetExitCodeProcess(
     HANDLE hProcess,
    LPDWORD lpExitCode
    );


BOOL
GetExitCodeThread(
     HANDLE hThread,
    LPDWORD lpExitCode
    );


DWORD
GetPriorityClass(
    HANDLE hProcess
    );

BOOL
GetProcessHandleCount(
     HANDLE hProcess,
    PDWORD pdwHandleCount
    );


DWORD
GetProcessId(HANDLE Process);

DWORD
GetProcessIdOfThread(HANDLE Thread);

BOOL
GetProcessTimes(
    HANDLE hProcess,
    LPFILETIME lpCreationTime,
    LPFILETIME lpExitTime,
    LPFILETIME lpKernelTime,
    LPFILETIME lpUserTime
    );

DWORD
GetProcessVersion(
    DWORD ProcessId
    );


void GetStartupInfoW(
    LPSTARTUPINFOW lpStartupInfo
    );

BOOL
GetThreadContext(
       HANDLE hThread,
    LPCONTEXT lpContext
    );

DWORD
GetThreadId(
    HANDLE Thread
    );

BOOL
GetThreadIdealProcessorEx (
    HANDLE hThread,
    PPROCESSOR_NUMBER lpIdealProcessor
    );

int
GetThreadPriority(
    HANDLE hThread
    );

BOOL
GetThreadPriorityBoost(
     HANDLE hThread,
    PBOOL pDisablePriorityBoost
    );

BOOL
GetThreadTimes(
     HANDLE hThread,
    LPFILETIME lpCreationTime,
    LPFILETIME lpExitTime,
    LPFILETIME lpKernelTime,
    LPFILETIME lpUserTime
    );


BOOL
InitializeProcThreadAttributeList(
   LPPROC_THREAD_ATTRIBUTE_LIST lpAttributeList,
    DWORD dwAttributeCount,
    DWORD dwFlags,
    PSIZE_T lpSize
    );

BOOL
IsProcessorFeaturePresent(
    DWORD ProcessorFeature
    );

HANDLE
OpenProcess(
    DWORD dwDesiredAccess,
    BOOL bInheritHandle,
    DWORD dwProcessId);

BOOL
OpenProcessToken (
    HANDLE ProcessHandle,
    DWORD DesiredAccess,
    PHANDLE TokenHandle
    );


HANDLE
OpenThread(
    DWORD dwDesiredAccess,
    BOOL bInheritHandle,
    DWORD dwThreadId
    );


BOOL
OpenThreadToken (
           HANDLE ThreadHandle,
           DWORD DesiredAccess,
           BOOL OpenAsSelf,
   PHANDLE TokenHandle
    );

BOOL
ProcessIdToSessionId(
     DWORD dwProcessId,
    DWORD *pSessionId
    );

BOOL
QueryProcessAffinityUpdateMode(
    HANDLE hProcess,
    LPDWORD lpdwFlags
    );
]]

ffi.cdef[[
typedef void (*PAPCFUNC)(ULONG_PTR Parameter);

DWORD
QueueUserAPC(PAPCFUNC pfnAPC, HANDLE hThread, ULONG_PTR dwData);

DWORD
ResumeThread(HANDLE hThread);


BOOL
SetPriorityClass(
    HANDLE hProcess,
    DWORD dwPriorityClass
    );

BOOL
SetProcessAffinityUpdateMode(
    HANDLE hProcess,
    DWORD dwFlags
    );

BOOL
SetProcessShutdownParameters(
    DWORD dwLevel,
    DWORD dwFlags
    );


BOOL
SetThreadContext(
    HANDLE hThread,
    const CONTEXT *lpContext
    );


BOOL
SetThreadIdealProcessorEx (
    HANDLE hThread,
    PPROCESSOR_NUMBER lpIdealProcessor,
    PPROCESSOR_NUMBER lpPreviousIdealProcessor
    );

BOOL
SetThreadPriority(
    HANDLE hThread,
    int nPriority
    );

BOOL
SetThreadPriorityBoost(
    HANDLE hThread,
    BOOL bDisablePriorityBoost
    );

BOOL
SetThreadStackGuarantee (
    PULONG StackSizeInBytes
    );


BOOL
SetThreadToken (PHANDLE Thread, HANDLE Token);


DWORD
SuspendThread(HANDLE hThread);

BOOL
SwitchToThread(void);

BOOL
TerminateProcess(HANDLE hProcess,UINT uExitCode);

BOOL
TerminateThread(
    HANDLE hThread,
    DWORD dwExitCode
    );

DWORD
TlsAlloc(void);

BOOL
TlsFree(DWORD dwTlsIndex);

LPVOID
TlsGetValue(DWORD dwTlsIndex);

BOOL
TlsSetValue(DWORD dwTlsIndex, LPVOID lpTlsValue);

BOOL
UpdateProcThreadAttribute(
    LPPROC_THREAD_ATTRIBUTE_LIST lpAttributeList,
    DWORD dwFlags,
    DWORD_PTR Attribute,
    PVOID lpValue,
    SIZE_T cbSize,
    PVOID lpPreviousValue,
    PSIZE_T lpReturnSize
    );
]]


return {
    Lib = k32Lib,
    AdvApi32Lib = advLib, 
    
	CreateProcessA = k32Lib.CreateProcessA,
	CreateProcessAsUserW = advLib.CreateProcessAsUserW,

	CreateProcessW = k32Lib.CreateProcessW,
	CreateRemoteThread = k32Lib.CreateRemoteThread,
	CreateRemoteThreadEx = k32Lib.CreateRemoteThreadEx,
	CreateThread = k32Lib.CreateThread,
	DeleteProcThreadAttributeList = k32Lib.DeleteProcThreadAttributeList,
	ExitProcess = k32Lib.ExitProcess,
	ExitThread = k32Lib.ExitThread,
	FlushInstructionCache = k32Lib.FlushInstructionCache,
	FlushProcessWriteBuffers = k32Lib.FlushProcessWriteBuffers,
	GetCurrentProcess = k32Lib.GetCurrentProcess,
	GetCurrentProcessId = k32Lib.GetCurrentProcessId,
	GetCurrentProcessorNumber = k32Lib.GetCurrentProcessorNumber,
	GetCurrentProcessorNumberEx = k32Lib.GetCurrentProcessorNumberEx,
	GetCurrentThread = k32Lib.GetCurrentThread,
	GetCurrentThreadId = k32Lib.GetCurrentThreadId,
--	GetCurrentThreadStackLimits = k32Lib.GetCurrentThreadStackLimits,
	GetExitCodeProcess = k32Lib.GetExitCodeProcess,
	GetExitCodeThread = k32Lib.GetExitCodeThread,
	GetPriorityClass = k32Lib.GetPriorityClass,
	GetProcessHandleCount = k32Lib.GetProcessHandleCount,
	GetProcessId = k32Lib.GetProcessId,
	GetProcessIdOfThread = k32Lib.GetProcessIdOfThread,
--	GetProcessMitigationPolicy = k32Lib.GetProcessMitigationPolicy,
	GetProcessTimes = k32Lib.GetProcessTimes,
	GetProcessVersion = k32Lib.GetProcessVersion,
	GetStartupInfoW = k32Lib.GetStartupInfoW,
	GetThreadContext = k32Lib.GetThreadContext,
	GetThreadId = k32Lib.GetThreadId,
	GetThreadIdealProcessorEx = k32Lib.GetThreadIdealProcessorEx,
	GetThreadPriority = k32Lib.GetThreadPriority,
	GetThreadPriorityBoost = k32Lib.GetThreadPriorityBoost,
	GetThreadTimes = k32Lib.GetThreadTimes,
	InitializeProcThreadAttributeList = k32Lib.InitializeProcThreadAttributeList,
	IsProcessorFeaturePresent = k32Lib.IsProcessorFeaturePresent,
	OpenProcess = k32Lib.OpenProcess,
	OpenProcessToken = advLib.OpenProcessToken,
	OpenThread = k32Lib.OpenThread,
	OpenThreadToken = advLib.OpenThreadToken,
	ProcessIdToSessionId = k32Lib.ProcessIdToSessionId,
	QueryProcessAffinityUpdateMode = k32Lib.QueryProcessAffinityUpdateMode,
	QueueUserAPC = k32Lib.QueueUserAPC,
	ResumeThread = k32Lib.ResumeThread,
	SetPriorityClass = k32Lib.SetPriorityClass,
	SetProcessAffinityUpdateMode = k32Lib.SetProcessAffinityUpdateMode,
--	SetProcessMitigationPolicy = k32Lib.SetProcessMitigationPolicy,
	SetProcessShutdownParameters = k32Lib.SetProcessShutdownParameters,
	SetThreadContext = k32Lib.SetThreadContext,
	SetThreadIdealProcessorEx = k32Lib.SetThreadIdealProcessorEx,
	SetThreadPriority = k32Lib.SetThreadPriority,
	SetThreadPriorityBoost = k32Lib.SetThreadPriorityBoost,
	SetThreadStackGuarantee = k32Lib.SetThreadStackGuarantee,
	SetThreadToken = advLib.SetThreadToken,
	SuspendThread = k32Lib.SuspendThread,
	SwitchToThread = k32Lib.SwitchToThread,
	TerminateProcess = k32Lib.TerminateProcess,
	TerminateThread = k32Lib.TerminateThread,
	TlsAlloc = k32Lib.TlsAlloc,
	TlsFree = k32Lib.TlsFree,
	TlsGetValue = k32Lib.TlsGetValue,
	TlsSetValue = k32Lib.TlsSetValue,
	UpdateProcThreadAttribute = k32Lib.UpdateProcThreadAttribute,
}