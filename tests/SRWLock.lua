-- SRWLock.lua

local ffi = require("ffi");
local core_synch = require("core_synch_l1_2_0");

ffi.cdef[[
typedef struct {
	PSRWLOCK	Handle;
} SRWLockExclusive;
]]

SRWLockExclusive = ffi.typeof("SRWLockExclusive")
SRWLockExclusive_t = {
	__gc = function(self)
		if self.Handle ~= nil then
			core_synch.ReleaseSRWLockExclusive(self.Handle);
		end
	end,

	__new = function(ct, handle)
		if handle == nil then
			return nil;
		end

		core_synch.AcquireSRWLockExclusive(handle);

		return ffi.new(ct, handle);
	end,

	__index = {
		exit = function(self)
			if self.Handle ~= nil then
				core_synch.ReleaseSRWLockExclusive(self.Handle);
				self.Handle = nil;
			end

			return true;	
		end,			
	}
}


OSRWLock = {}
OSRWLock_mt = {
	__index = SRWLock,
}

OSRWLock.init = function(self, rawhandle)
	local obj = {
		Handle = rawhandle;
	};

	setmetatable(obj, SRWLock_mt);
	return obj;
end

OSRWLock.create = function(self)
	local rawhandle = ffi.new("SRWLOCK");
	core_synch.InitializeSRWLock (rawhandle);

	return self:init(rawhandle);
end

OSRWLock.lockExclusive = function(self)
	if not self.Handle then
		return false;
	end

	return SRWLockExclusive(self.Handle);
end

OSRWLock.exit = function(self)
	core_synch.ReleaseSRWLockExclusive(self.Handle);
end

