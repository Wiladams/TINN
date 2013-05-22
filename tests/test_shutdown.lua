-- test_shutdown.lua
local ffi = require("ffi");

local core_shutdown = require("core_shutdown_l1_1_0");
local errorhandling = require("core_errorhandling_l1_1_1");

local Token = require("Token");


local function test_Shutdown()
	local token = Token:getProcessToken();
	token:enablePrivilege(Token.Privileges.SE_SHUTDOWN_NAME);
	
	local status = core_shutdown.InitiateSystemShutdownExW(nil, nil,
    	10,false,true,ffi.C.SHTDN_REASON_MAJOR_APPLICATION);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

print(test_Shutdown());
