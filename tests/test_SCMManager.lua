
local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;


local SCManager = require("SCManager");








local test_servicecontrol = function()
	local mgr, err = SCManager();

	if not mgr then
		print("Error: ", err);
		return false, err;
	end

	local access = bor(
		ffi.C.SERVICE_INTERROGATE,
		ffi.C.SERVICE_STOP, 
		ffi.C.SERVICE_PAUSE_CONTINUE, 
		ffi.C.SERVICE_ENUMERATE_DEPENDENTS);
	
	local servicehandle, err = mgr:openService("WSearch", access);

	print("ServiceHandle: ", servicehandle, err);

	if servicehandle then
		--print("PAUSE")
		--print(servicehandle:pause());
	
		print("STOP")
		print(servicehandle:stop());

		-- servicehandle:resume();
	end
end



--test_query();

test_servicecontrol();
