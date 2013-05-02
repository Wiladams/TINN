-- test_netutils.lua

local netutils = require("netutils");

local test_Raw = function()
	local buff, err = netutils.NetApiBufferAllocate(256);

	print("Allocated: ", buff, err);

	local status = netutils.NetApiBufferFree(buff);
	print("Freed: ", status);
end

local test_Buffer = function()
	local buff, err = netutils.NetApiBuffer(256);

	print("Allocated: ", buff, err);

	if not buff then 
		return false;
	end

	print("Size: ", #buff);

	buff:Reallocate(512);

	print("Reallocated: ", #buff);

	
end


test_Buffer();
--test_Raw();