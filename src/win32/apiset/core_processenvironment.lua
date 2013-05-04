--core-processenvironment-l1-2-0.lua	
--api-ms-win-core-processenvironment-l1-2-0.dll	

local ffi = require("ffi");

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