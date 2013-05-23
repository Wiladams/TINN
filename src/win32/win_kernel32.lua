local ffi = require "ffi"
local C = ffi.C

require ("WinBase");
require ("Handle");

local kernel32 = ffi.load("kernel32");
local coure_errorhandling = require("core_errorhandling_l1_1_1");


ffi.cdef[[
// Synchronization

HANDLE CreateEventA(LPSECURITY_ATTRIBUTES lpEventAttributes,
		BOOL bManualReset, BOOL bInitialState, LPCSTR lpName);



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
