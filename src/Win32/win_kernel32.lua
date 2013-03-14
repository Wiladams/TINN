local ffi = require "ffi"
local C = ffi.C

require "WinBase"
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

BOOL CloseHandle(HANDLE hObject);

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

BOOL QueryPerformanceFrequency(int64_t *lpFrequency);
BOOL QueryPerformanceCounter(int64_t *lpPerformanceCount);

//	DWORD QueueUserAPC(PAPCFUNC pfnAPC, HANDLE hThread, ULONG_PTR dwData);

void Sleep(DWORD dwMilliseconds);

DWORD SleepEx(DWORD dwMilliseconds, BOOL bAlertable);

DWORD WaitForSingleObject(HANDLE hHandle, DWORD dwMilliseconds);

HANDLE CreateWaitableTimerA(LPSECURITY_ATTRIBUTES lpTimerAttributes,
	BOOL bManualReset, LPCTSTR lpTimerName);

]]

ffi.cdef[[
typedef struct _OSVERSIONINFO {
  DWORD dwOSVersionInfoSize;
  DWORD dwMajorVersion;
  DWORD dwMinorVersion;
  DWORD dwBuildNumber;
  DWORD dwPlatformId;
  TCHAR szCSDVersion[128];
} OSVERSIONINFO, *POSVERSIONINFO;

BOOL GetVersionExA(POSVERSIONINFO pVersionInfo);

]]

OSVERSIONINFO = ffi.typeof("OSVERSIONINFO")
OSVERSIONINFO_mt = {
	__new = function(ct)
		local obj = ffi.new("OSVERSIONINFO")
		obj.dwOSVersionInfoSize = ffi.sizeof("OSVERSIONINFO");
		kernel32.GetVersionExA(obj);

		return obj;
	end,
}
OSVERSIONINFO = ffi.metatype(OSVERSIONINFO, OSVERSIONINFO_mt);


function GetPerformanceFrequency(anum)
	anum = anum or ffi.new("int64_t[1]");
	local success = ffi.C.QueryPerformanceFrequency(anum)
	if success == 0 then
		return nil 
	end

	return tonumber(anum[0])
end

function GetPerformanceCounter(anum)
	anum = anum or ffi.new("int64_t[1]")
	local success = ffi.C.QueryPerformanceCounter(anum)
	if success == 0 then 
		return nil 
	end

	return tonumber(anum[0])
end

function GetCurrentTickTime()
	local frequency = 1/GetPerformanceFrequency();
	local currentCount = GetPerformanceCounter();
	local seconds = currentCount * frequency;
--print(string.format("win_kernel32 - GetCurrentTickTime() - %d\n", seconds));

	return seconds;
end


function GetProcAddress(library, funcname)
	ffi.load(library)
	local paddr = ffi.C.GetProcAddress(ffi.C.GetModuleHandleA(library), funcname)
	return paddr
end

function GetCurrentDirectory()
	local buffsize = 1024;
	local buff = ffi.new("char[1024]");
	local err = kernel32.GetCurrentDirectoryA(buffsize, buff);

	if err == 0 then return nil end

	return ffi.string(buff);
end

local CreateWaitableTimer =  function(manualReset, name)

	local handle =  kernel32.CreateWaitableTimerA(nil, manualReset, name);
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
print("bytesneeded: ", bytesneeded);

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
	GetPerformanceFrequency = GetPerformanceFrequency,
	GetPerformanceCounter = GetPerformanceCounter,
	GetCurrentTickTime = GetCurrentTickTime,
	GetProcAddress = GetProcAddress,
	GetCurrentDirectory = GetCurrentDirectory,

	AnsiToUnicode16 = AnsiToUnicode16L,
	Unicode16ToAnsi = Unicode16ToAnsi,
	TEXT = TEXT,
}
