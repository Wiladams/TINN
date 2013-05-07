-- test_shutdown.lua
local ffi = require("ffi");

local kernel32 = require("win_kernel32");
local core_shutdown = require("core_shutdown_l1_1_0");

local function test_Shutdown()
	local status = core_shutdown.InitiateSystemShutdownExW(nil, nil,
    	10,false,true,ffi.C.SHTDN_REASON_MAJOR_APPLICATION);

	if status == 0 then
		return false, kernel32.GetLastError();
	end

	return true;
end

print(test_Shutdown());
