--core-processenvironment-l1-2-0.lua	
--api-ms-win-core-processenvironment-l1-2-0.dll	

local ffi = require("ffi");
local k32Lib = ffi.load("kernel32");
local WTypes = require("WTypes");


ffi.cdef[[
static const int STD_INPUT_HANDLE    = ((DWORD)-10);
static const int STD_OUTPUT_HANDLE   = ((DWORD)-11);
static const int STD_ERROR_HANDLE    = ((DWORD)-12);
]]

--[[
ExpandEnvironmentStringsA
ExpandEnvironmentStringsW
FreeEnvironmentStringsA
FreeEnvironmentStringsW
--]]


ffi.cdef[[
LPSTR GetCommandLineA(void);

LPWSTR GetCommandLineW(void);
]]

ffi.cdef[[
DWORD
GetCurrentDirectoryA(DWORD nBufferLength,LPSTR lpBuffer);

DWORD
GetCurrentDirectoryW(DWORD nBufferLength, LPWSTR lpBuffer);
]]

--[[
GetEnvironmentStrings
GetEnvironmentStringsW
GetEnvironmentVariableA
GetEnvironmentVariableW
--]]


ffi.cdef[[
HANDLE
GetStdHandle(DWORD nStdHandle);
]]

return {
	Lib = k32Lib,
	
	GetCommandLineA = k32Lib.GetCommandLineA,
	GetCommandLineW = k32Lib.GetCommandLineW,
	GetCurrentDirectoryA = k32Lib.GetCurrentDirectoryA,
	GetCurrentDirectoryW = k32Lib.GetCurrentDirectoryW,
	GetStdHandle = k32Lib.GetStdHandle,
}

--[[
NeedCurrentDirectoryForExePathA
NeedCurrentDirectoryForExePathW
SearchPathA
SearchPathW
SetCurrentDirectoryA
SetCurrentDirectoryW
SetEnvironmentStringsW
SetEnvironmentVariableA
SetEnvironmentVariableW
SetStdHandle
SetStdHandleEx
--]]