local ffi = require "ffi"
local C = ffi.C

require ("WinBase");
require ("Handle");

local kernel32 = ffi.load("kernel32");

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

DWORD GetLastError();

HMODULE GetModuleHandleA(LPCSTR lpModuleName);


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


void * GetProcAddress(HMODULE hModule, LPCSTR lpProcName);


//	DWORD QueueUserAPC(PAPCFUNC pfnAPC, HANDLE hThread, ULONG_PTR dwData);

void Sleep(DWORD dwMilliseconds);

DWORD SleepEx(DWORD dwMilliseconds, BOOL bAlertable);

DWORD WaitForSingleObject(HANDLE hHandle, DWORD dwMilliseconds);

HANDLE CreateWaitableTimerA(LPSECURITY_ATTRIBUTES lpTimerAttributes,
	BOOL bManualReset, LPCTSTR lpTimerName);

]]





function GetProcAddress(library, funcname)
	ffi.load(library)
	local paddr = ffi.C.GetProcAddress(ffi.C.GetModuleHandleA(library), funcname)
	return paddr
end



--[[
	WinNls.h

	Defined in Kernel32
--]]

ffi.cdef[[
int MultiByteToWideChar(UINT CodePage,
    DWORD    dwFlags,
    LPCSTR   lpMultiByteStr, int cbMultiByte,
    LPWSTR  lpWideCharStr, int cchWideChar);


int WideCharToMultiByte(UINT CodePage,
    DWORD    dwFlags,
	LPCWSTR  lpWideCharStr, int cchWideChar,
    LPSTR   lpMultiByteStr, int cbMultiByte,
    LPCSTR   lpDefaultChar,
    LPBOOL  lpUsedDefaultChar);
]]

local CP_ACP 		= 0		-- default to ANSI code page
local CP_OEMCP		= 1		-- default to OEM code page
local CP_MACCP		= 2		-- default to MAC code page
local CP_THREAD_ACP	= 3		-- current thread's ANSI code page
local CP_SYMBOL		= 42	-- SYMBOL translations


local function AnsiToUnicode16L(in_Src)
	local nsrcBytes = #in_Src

	-- find out how many characters needed
	local charsneeded = kernel32.MultiByteToWideChar(CP_ACP, 0, in_Src, nsrcBytes, nil, 0);
--print("charsneeded: ", nsrcBytes, charsneeded);

	if charsneeded < 0 then
		return nil;
	end


	local buff = ffi.new("uint16_t[?]", charsneeded+1)

	local charswritten = kernel32.MultiByteToWideChar(CP_ACP, 0, in_Src, nsrcBytes, buff, charsneeded)
	buff[charswritten] = 0

--print("charswritten: ", charswritten)

	return ffi.string(buff, (charswritten*2)+1);
end

local function AnsiToUnicode16L(in_Src, nsrcBytes)
	nsrcBytes = nsrcBytes or #in_Src

	-- find out how many characters needed
	local charsneeded = kernel32.MultiByteToWideChar(CP_ACP, 0, in_Src, nsrcBytes, nil, 0);
--print("charsneeded: ", nsrcBytes, charsneeded);

	if charsneeded < 0 then
		return nil;
	end


	local buff = ffi.new("uint16_t[?]", charsneeded+1)

	local charswritten = kernel32.MultiByteToWideChar(CP_ACP, 0, in_Src, nsrcBytes, buff, charsneeded)
	buff[charswritten] = 0

--print("charswritten: ", charswritten)

	return buff;
end

local function Unicode16ToAnsi(in_Src, nsrcBytes)
	nsrcBytes = nsrcBytes
	local srcShorts = ffi.cast("const uint16_t *", in_Src)

	-- find out how many characters needed
	local bytesneeded = kernel32.WideCharToMultiByte(CP_ACP, 0, srcShorts, -1, nil, 0, nil, nil);
--print("bytesneeded: ", bytesneeded);

	if bytesneeded <= 0 then
		return nil;
	end

	local buff = ffi.new("uint8_t[?]", bytesneeded+1)
	local byteswritten = kernel32.WideCharToMultiByte(CP_ACP, 0, srcShorts, -1, buff, bytesneeded, nil, nil);
	buff[byteswritten] = 0

--print("charswritten: ", byteswritten)

	return ffi.string(buff, byteswritten-1);
end

local TEXT = function (quote)
	if UNICODE then
		return AnsiToUnicode16L(quote);
	else
		return quote
	end
end

return {
	Lib = kernel32,

	-- Local functions
	CreateEvent = kernel32.CreateEventA;
	GetLastError = kernel32.GetLastError;
	GetProcAddress = GetProcAddress,

	AnsiToUnicode16 = AnsiToUnicode16L,
	Unicode16ToAnsi = Unicode16ToAnsi,
	TEXT = TEXT,
}
