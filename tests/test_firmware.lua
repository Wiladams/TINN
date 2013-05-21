
local ffi = require("ffi");
local core_firmware = require("core_firmware_l1_1_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local core_string = require("core_string_l1_1_0");
local Token = require("Token");

GetFirmwareEnvironmentVariable = function(lpName, lpGuid, pBuffer, nSize)
	lpName = lpName or " ";
	lpName = core_string.toUnicode(lpName);
	lpGuid = lpGuid or "{00000000-0000-0000-0000-000000000000}";
	lpGuid = core_string.toUnicode(lpGuid);

	local status = core_firmware.GetFirmwareEnvironmentVariableW(
    	lpName,
    	lpGuid,
    	pBuffer,
    	nSize);

    if status == 0 then
    	return false, errorhandling.GetLastError();
    end

    return status;	-- number of bytes stuffed
end

--[[
BOOL
SetFirmwareEnvironmentVariableW(
    LPCWSTR lpName,
    LPCWSTR lpGuid,
    PVOID pValue,
    DWORD    nSize
    );
--]]




--[[
	Test Cases
    References
    http://www.saferbytes.it/2012/09/18/uefi-technology-say-hello-to-the-windows-8-bootkit/
--]]

-- Must set a privilege to make the firmware call
local token, err = Token:getProcessToken();
token:enablePrivilege(Token.Privileges.SE_SYSTEM_ENVIRONMENT_NAME);

print(GetFirmwareEnvironmentVariable(nil, nil, ffi.new('uint8_t[256]'), 256));


