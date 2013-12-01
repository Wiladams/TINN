-- VirtualMemory.lua

local ffi = require("ffi");
local core_memory = require("core_memory_l1_1_1");
local errorhandling = require("core_errorhandling_l1_1_1");



local VirtualMemory = {}
setmetatable(VirtualMemory, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local VirtualMemory_mt = {
	__index = VirtualMemory;
}

VirtualMemory.init = function(self, address, size, process)
	local obj = {
		Address = address;
		Size = size;
		Process = process;
	}
	setmetatable(obj, VirtualMemory_mt)

	return obj;
end

VirtualMemory.create = function(self, dwSize, flAllocationType, flProtect)
	flAllocationType = flAllocationType or ffi.C.MEM_COMMIT;
	flProtect = flProtect or ffi.C.PAGE_READWRITE;

	local hProcess = nil;
	local lpAddress = nil;
	local baseAddress = core_memory.VirtualAlloc(
    	lpAddress,
    	dwSize,
    	flAllocationType,
    	flProtect);

	if baseAddress == nil then
		return false, errorhandling.GetLastError();
	end

	return self:init(baseAddress, dwSize, hProcess)
end

VirtualMemory.free = function(self, dwFreeType)
	if self.Address == nil then 
		return false 
	end

	dwSize = dwSize or 0;
	dwFreeType = dwFreeType or ffi.C.MEM_RELEASE;
	core_memory.VirtualFree(self.Address, self.Size, dwFreeType);

	self.Address = nil;
end

VirtualMemory.getInfo = function(self)
	local lpBuffer = ffi.new("MEMORY_BASIC_INFORMATION");
	local bytesWritten = core_memory.VirtualQuery(self.Address, lpBuffer, ffi.sizeof(lpBuffer));

	return lpBuffer;
end

VirtualMemory.protect = function(self, flNewProtect)
    flNewProtect = flNewProtect or ffi.C.PAGE_READONLY;
    local lpflOldProtect = ffi.new("DWORD[1]");
    local status = core_memory.VirtualProtect(self.Address,
    	self.Size,
    	flNewProtect,
    	lpflOldProtect);

    if status == 0 then
    	return false, errorhandling.GetLastError();
    end

    return lpflOldProtect[0];
end

VirtualMemory.pin = function(self)
	local status = core_memory.VirtualLock(self.Address, self.Size);
	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

VirtualMemory.unpin = function(self, lpAddress, dwSize)
	local status = core_memory.VirtualUnlock(self.Address, self.Size);
	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end


return VirtualMemory;
