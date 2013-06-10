
local VirtualMemory = require("VirtualMemory");



local printMemoryInfo = function(info)
	print("== Memory Info ==")
	if not info then
		print("No INFO");
		return false;
	end

	print("              Base: ", info.BaseAddress);
	print("   Allocation Base: ", info.AllocationBase);
	print("Allocation Protect: ", string.format("0x%x",info.AllocationProtect));
	print("        Regionsize: ", info.RegionSize);
	print("             State: ", string.format("0x%x",info.State));
	print("           Protect: ", string.format("0x%x",info.Protect));
	print("              Type: ", string.format("0x%x",info.Type));
end


local vmem1, err = VirtualMemory:alloc(0xffff);

print("vmem1: ", vmem1, err);

local info = vmem1:getInfo();

printMemoryInfo(info);

print("PIN: ", vmem1:pin());

print("UnPIN: ", vmem1:unpin());
