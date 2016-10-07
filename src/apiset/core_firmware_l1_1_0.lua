-- core_firmware_l1_1_0.lua	
-- api-ms-win-core-firmware-l1-1-0.dll	

local ffi = require("ffi");

local WTypes = require("WTypes");

ffi.cdef[[
DWORD
GetFirmwareEnvironmentVariableW(
    LPCWSTR lpName,
    LPCWSTR lpGuid,
    PVOID pBuffer,
    DWORD    nSize
    );

BOOL
SetFirmwareEnvironmentVariableW(
    LPCWSTR lpName,
    LPCWSTR lpGuid,
    PVOID pValue,
    DWORD    nSize
    );
]]

local Lib = ffi.load("kernel32");

return {
    Lib = Lib,
    
	GetFirmwareEnvironmentVariableW = Lib.GetFirmwareEnvironmentVariableW,
	SetFirmwareEnvironmentVariableW = Lib.SetFirmwareEnvironmentVariableW,
}