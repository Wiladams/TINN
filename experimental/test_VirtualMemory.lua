
local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;


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


--local vmem1, err = VirtualMemory(0xffff, nil, bor(ffi.C.PAGE_READWRITE, ffi.C.PAGE_GUARD));
local vmem1, err = VirtualMemory(0xffff, nil, bor(ffi.C.PAGE_READWRITE));

print("vmem1: ", vmem1, err);

local info = vmem1:getInfo();

printMemoryInfo(info);


-- write some bytes
local intPtr = ffi.cast("int *",vmem1.Address)
intPtr[0] = 23;

--print("PIN: ", vmem1:pin());

--print("UnPIN: ", vmem1:unpin());
print("First: ", intPtr[0])