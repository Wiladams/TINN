-- VirtualMemory.lua

local ffi = require("ffi");
local core_memory = require("core_memory_l1_1_1");
local errorhandling = require("core_errorhandling_l1_1_1");

ffi.cdef[[
typedef struct {
    LPVOID Address;
    SIZE_T Size;
    HANDLE Process;
} VirtualMemoryHandle;
]]

local VirtualMemoryHandle = ffi.typeof("VirtualMemoryHandle");
local VirtualMemoryHandle_mt = {
	__gc = function(self)
		self:free();
    end,

	__index = {
		free = function(self, dwFreeType)
			if self.Address == nil then return false end

			dwSize = dwSize or 0;
			dwFreeType = dwFreeType or ffi.C.MEM_RELEASE;
			core_memory.VirtualFree(self.Address, dwSize, dwFreeType);

			self.Address = nil;
		end,

		getInfo = function(self)
			local lpBuffer = ffi.new("MEMORY_BASIC_INFORMATION");
			local bytesWritten = core_memory.VirtualQuery(self.Address, lpBuffer, ffi.sizeof(lpBuffer));

			return lpBuffer;
    	end,

    	protect = function(self, flNewProtect)
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
		end,

		pin = function(self)
			local status = core_memory.VirtualLock(self.Address, self.Size);
			if status == 0 then
				return false, errorhandling.GetLastError();
			end

			return true;
		end,

		unpin = function(self, lpAddress, dwSize)
			local status = core_memory.VirtualUnlock(self.Address, self.Size);
			if status == 0 then
				return false, errorhandling.GetLastError();
			end

			return true;
		end,
	};
};

ffi.metatype(VirtualMemoryHandle, VirtualMemoryHandle_mt);


VirtualMemory = {}

VirtualMemory.alloc = function(self, dwSize, flAllocationType, flProtect)
	flAllocationType = flAllocationType or ffi.C.MEM_COMMIT;
	flProtect = flProtect or ffi.C.PAGE_READWRITE;

	local hProcess = nil;
	local lpAddress = nil;
	local handle = core_memory.VirtualAlloc(
    	lpAddress,
    	dwSize,
    	flAllocationType,
    	flProtect);

	if handle == nil then
		return false, errorhandling.GetLastError();
	end

	return VirtualMemoryHandle(handle, dwSize, hProcess);
end

return VirtualMemory;
