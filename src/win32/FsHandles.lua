
local ffi = require("ffi");

local WinBase = require("WinBase");
local core_file = require("core_file_l1_2_0");
local Handle_ffi = require("Handle_ffi");

ffi.cdef[[
typedef struct {
	HANDLE  Handle;
} FsHandle;
]]
local FsHandle = ffi.typeof("FsHandle");
local FsHandle_mt = {
	__gc = function(self)
		if self:isValid() then
			Handle_ffi.CloseHandle(self.Handle);
		end
	end,

	__index = {
		isValid = function(self)
			return self.Handle ~= INVALID_HANDLE_VALUE;
		end,

		free = function(self)
			if self.Handle ~= nil then
				Handle_ffi.CloseHandle(self.Handle);
				self.Handle = nil;
			end
		end,
	},
};
ffi.metatype(FsHandle, FsHandle_mt);


ffi.cdef[[
typedef struct {
	HANDLE Handle;
} FsFindFileHandle;
]]
local FsFindFileHandle = ffi.typeof("FsFindFileHandle");
local FsFindFileHandle_mt = {
	__gc = function(self)
		core_file.FindClose(self.Handle);
	end,

	__index = {
		isValid = function(self)
			return self.Handle ~= INVALID_HANDLE_VALUE;
		end,
	},
};
ffi.metatype(FsFindFileHandle, FsFindFileHandle_mt);



return {
	FsHandle = FsHandle,
	FsFindFileHandle = FsFindFileHandle,
}
