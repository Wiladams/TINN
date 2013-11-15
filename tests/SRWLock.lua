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
		self:free();
	end,

	__new = function(ct, handle)
		if handle == nil then
			return nil;
		end

		core_synch.AcquireSRWLockExclusive(handle);

		return ffi.new(ct, handle);
	end,

	__index = {
		free = function(self)
			if self.Handle ~= nil then
				core_synch.ReleaseSRWLockExclusive(self.Handle);
				self.Handle = nil;
			end

			return true;	
		end,			
	}
}
ffi.metatype(SRWLockExclusive, SRWLockExclusive_t)



local OSRWLock = {}
setmetatable(OSRWLock, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local OSRWLock_mt = {
	__index = OSRWLock,
}

OSRWLock.init = function(self, rawhandle)
	local obj = {
		Handle = rawhandle;
	};

	setmetatable(obj, OSRWLock_mt);
	return obj;
end

OSRWLock.create = function(self)
	local rawhandle = ffi.new("SRWLOCK");
	core_synch.InitializeSRWLock (rawhandle);

	return self:init(rawhandle);
end

OSRWLock.lock = function(self)
	if not self.Handle then
		return false;
	end

	return SRWLockExclusive(self.Handle);
end

OSRWLock.release = function(self)
	core_synch.ReleaseSRWLockExclusive(self.Handle);
end

return OSRWLock
