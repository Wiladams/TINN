-- Handle.lua

local ffi = require("ffi");
local bit = require("bit");
local band = bit.band;

local Handle_ffi = require("Handle_ffi");
local error_handling = require("core_errorhandling_l1_1_1");


--[[
In Windows, the HANDLE alias is used to represent quite a lot of 
things in OS calls.  Some of these things are backed by the allocation
of resources within the OS.  These handles must be closed properly when
they are no longer needed so the underlying resources are properly
cleaned up.

The following objects are represented by this handle:
access token, 
console input buffer, 
console screen buffer, 
event, 
file, 
file mapping, 
job, 
mailslot, 
mutex, 
pipe, 
printer, 
process, 
registry key, 
semaphore, 
serial communication device, 
socket, 
thread,
waitable timer


--]]
ffi.cdef[[
typedef struct {
	HANDLE Handle;
} Win32Handle, *PWin32Handle;
]]

local Handle = ffi.typeof("Win32Handle");
local Handle_t = {};
local Handle_mt = {

	-- A Win32 OS Handle should be properly closed when it 
	-- is no longer being used.
	__gc = function(self)
		--print("GC: Handle");
		Handle_ffi.CloseHandle(self.Handle);
	end,

	__new = function(ct, ...)
		local obj = ffi.new(ct,...);
		return obj;
	end,

	__index = Handle_t;
}
ffi.metatype(Handle, Handle_mt);

Handle_t.getHandleInformation = function(self)
	local lpdwFlags = ffi.new("DWORD[1]");

	local res = Handle_ffi.GetHandleInformation(self.Handle, lpdwFlags);
	if res == 0 then
		return false, error_handling.GetLastError();
	end

	return lpdwFlags[0];
end

Handle_t.setHandleInformation = function(self, which, turnon)
	local dwFlags = 0
	if turnon then
		dwFlags = which;
	end

	local res = Handle_ffi.SetHandleInformation(self.Handle, which, dwFlags)

	if res == 0 then
		return false, error_handling.GetLastError();
	end

	return true;
end

-- Property setter/getter
Handle_t.isInheritable = function(self)
	local info, err = self:getHandleInformation();
	if not info then
		return false, err;
	end

	return band(info, ffi.C.HANDLE_FLAG_INHERIT) > 0;
end

Handle_t.setInheritable = function(self, turnoff)
	return self:setHandleInformation(ffi.C.HANDLE_FLAG_INHERIT, not turnoff)
end


Handle_t.isProtectedFromClose = function(self)
	local info, err = self:getHandleInformation();
	if not info then
		return false, err;
	end

	return band(info, ffi.C.HANDLE_FLAG_PROTECT_FROM_CLOSE) > 0;
end

Handle_t.setProtectedFromClose = function(self, turnoff)
	return self:setHandleInformation(ffi.C.HANDLE_FLAG_PROTECT_FROM_CLOSE, not turnoff);
end

return Handle;
