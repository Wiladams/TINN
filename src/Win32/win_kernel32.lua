local ffi = require "ffi"
local C = ffi.C

require ("WinBase");
require ("Handle");

local kernel32 = ffi.load("kernel32");
local coure_errorhandling = require("core_errorhandling_l1_1_1");

-- File System Calls
--
ffi.cdef[[
DWORD GetCurrentDirectoryA(DWORD nBufferLength, LPTSTR lpBuffer);

HANDLE CreateFileA(LPCTSTR lpFileName,
	DWORD dwDesiredAccess,
	DWORD dwShareMode,
	LPSECURITY_ATTRIBUTES lpSecurityAttributes,
	DWORD dwCreationDisposition,
	DWORD dwFlagsAndAttributes,
	HANDLE hTemplateFile
);

BOOL GetFileInformationByHandle(HANDLE hFile,
    PBY_HANDLE_FILE_INFORMATION lpFileInformation);

BOOL GetFileTime(HANDLE hFile,
	LPFILETIME lpCreationTime,
	LPFILETIME lpLastAccessTime,
	LPFILETIME lpLastWriteTime);

BOOL FileTimeToSystemTime(const FILETIME* lpFileTime, LPSYSTEMTIME lpSystemTime);

BOOL DeleteFileW(LPCTSTR lpFileName);

BOOL MoveFileW(LPCTSTR lpExistingFileName, LPCTSTR lpNewFileName);

	/*
HFILE WINAPI OpenFile(LPCSTR lpFileName,
	LPOFSTRUCT lpReOpenBuff,
	UINT uStyle);
*/
]]

ffi.cdef[[
typedef DWORD  (*LPTHREAD_START_ROUTINE)(LPVOID lpParameter);
]]



ffi.cdef[[


HANDLE CreateEventA(LPSECURITY_ATTRIBUTES lpEventAttributes,
		BOOL bManualReset, BOOL bInitialState, LPCSTR lpName);


HANDLE CreateIoCompletionPort(HANDLE FileHandle,
	HANDLE ExistingCompletionPort,
	ULONG_PTR CompletionKey,
	DWORD NumberOfConcurrentThreads);

HANDLE CreateThread(
	LPSECURITY_ATTRIBUTES lpThreadAttributes,
	size_t dwStackSize,
	LPTHREAD_START_ROUTINE lpStartAddress,
	LPVOID lpParameter,
	DWORD dwCreationFlags,
	LPDWORD lpThreadId);


DWORD GetCurrentThreadId(void);
DWORD ResumeThread(HANDLE hThread);
BOOL SwitchToThread(void);
DWORD SuspendThread(HANDLE hThread);




//	DWORD QueueUserAPC(PAPCFUNC pfnAPC, HANDLE hThread, ULONG_PTR dwData);

void Sleep(DWORD dwMilliseconds);

DWORD SleepEx(DWORD dwMilliseconds, BOOL bAlertable);

DWORD WaitForSingleObject(HANDLE hHandle, DWORD dwMilliseconds);

HANDLE CreateWaitableTimerA(LPSECURITY_ATTRIBUTES lpTimerAttributes,
	BOOL bManualReset, LPCTSTR lpTimerName);

]]


return {
	Lib = kernel32,

	-- Local functions
	Sleep = kernel32.Sleep,
	SleepEx = kernel32.SleepEx,
	
	CreateEvent = kernel32.CreateEventA;
	GetLastError = coure_errorhandling.GetLastError;
}
