-- SysInfo.lua

local ffi = require("ffi");

local SysInfo_ffi = require("SysInfo_ffi");
local k32Lib = ffi.load("kernel32");

if UNICODE then
GetComputerName  = k32Lib.GetComputerNameW;
SetComputerName  = k32Lib.SetComputerNameW;
GetComputerNameEx  = k32Lib.GetComputerNameExW;
SetComputerNameEx  = k32Lib.SetComputerNameExW;
DnsHostnameToComputerName  = k32Lib.DnsHostnameToComputerNameW;
else
GetComputerName  = k32Lib.GetComputerNameA;
SetComputerName  = k32Lib.SetComputerNameA;
GetComputerNameEx  = k32Lib.GetComputerNameExA;
SetComputerNameEx  = k32Lib.SetComputerNameExA;
DnsHostnameToComputerName  = k32Lib.DnsHostnameToComputerNameA;
end -- !UNICODE



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


return {
	GetComputerName = GetComputerName;
	SetComputerName = SetComputerName;
	GetComputerNameEx = GetComputerNameEx;
	SetComputerNameEx = SetComputerNameEx;
	DnsHostnameToComputerName = DnsHostnameToComputerName;
}

--[[
#ifdef UNICODE
#define GetSystemDirectory  GetSystemDirectoryW
#else
#define GetSystemDirectory  GetSystemDirectoryA
#endif // !UNICODE


#ifdef UNICODE
#define GetWindowsDirectory  GetWindowsDirectoryW
#else
#define GetWindowsDirectory  GetWindowsDirectoryA
#endif // !UNICODE


#ifdef UNICODE
#define GetSystemWindowsDirectory  GetSystemWindowsDirectoryW
#else
#define GetSystemWindowsDirectory  GetSystemWindowsDirectoryA
#endif // !UNICODE



#ifdef UNICODE
#define GetVersionEx  GetVersionExW
#else
#define GetVersionEx  GetVersionExA
#endif // !UNICODE
--]]

--[=[
-- Interesting, but no in the core API set
ffi.cdef[[
BOOL
GetComputerNameA (
    LPSTR lpBuffer,
    LPDWORD nSize
    );

BOOL
GetComputerNameW (
    LPWSTR lpBuffer,
    LPDWORD nSize
    );
]]


ffi.cdef[[
BOOL
SetComputerNameA (
    LPCSTR lpComputerName
    );
BOOL
SetComputerNameW (
    LPCWSTR lpComputerName
    );
]]

BOOL
WINAPI
SetSystemTime(
    __in CONST SYSTEMTIME *lpSystemTime
    );

ffi.cdef[[
BOOL
SetComputerNameExA (
    COMPUTER_NAME_FORMAT NameType,
    LPCSTR lpBuffer
    );
BOOL
SetComputerNameExW (
    COMPUTER_NAME_FORMAT NameType,
    LPCWSTR lpBuffer
    );
]]

ffi.cdef[[
BOOL
DnsHostnameToComputerNameA (
    LPCSTR Hostname,
    LPSTR ComputerName,
    LPDWORD nSize
    );

BOOL
DnsHostnameToComputerNameW (
    LPCWSTR Hostname,
    LPWSTR ComputerName,
    LPDWORD nSize
    );
]]


//
// Routines to convert back and forth between system time and file time
//

WINBASEAPI
BOOL
WINAPI
FileTimeToLocalFileTime(
    __in  CONST FILETIME *lpFileTime,
    __out LPFILETIME lpLocalFileTime
    );

WINBASEAPI
BOOL
WINAPI
LocalFileTimeToFileTime(
    __in  CONST FILETIME *lpLocalFileTime,
    __out LPFILETIME lpFileTime
    );

WINBASEAPI
BOOL
WINAPI
FileTimeToSystemTime(
    __in  CONST FILETIME *lpFileTime,
    __out LPSYSTEMTIME lpSystemTime
    );

WINBASEAPI
LONG
WINAPI
CompareFileTime(
    __in CONST FILETIME *lpFileTime1,
    __in CONST FILETIME *lpFileTime2
    );

WINBASEAPI
BOOL
WINAPI
FileTimeToDosDateTime(
    __in  CONST FILETIME *lpFileTime,
    __out LPWORD lpFatDate,
    __out LPWORD lpFatTime
    );

WINBASEAPI
BOOL
WINAPI
DosDateTimeToFileTime(
    __in  WORD wFatDate,
    __in  WORD wFatTime,
    __out LPFILETIME lpFileTime
    );
--]=]

