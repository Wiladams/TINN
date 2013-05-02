-- netutils.lua

local ffi = require("ffi");
local netutils = require("netutils_ffi");
local kernel32 = require("win_kernel32");


local NetApiBufferAllocate = function(ByteCount)
	local pBuffer = ffi.new("PVOID[1]");

	local status = netutils.NetApiBufferAllocate(ByteCount, pBuffer);
	if status ~= ffi.C.NERR_Success then
		return false, status;
	end

	return pBuffer[0];
end

local NetApiBufferFree = function(Buffer)
	local status = netutils.NetApiBufferFree (Buffer);
	if status ~= ffi.C.NERR_Success then
		return false, status;
	end
	return true;
end

local NetApiBufferReallocate = function(OldBuffer, NewByteCount)
	local pNewBuffer = ffi.new("PVOID[1]");
	local status = netutils.NetApiBufferReallocate(OldBuffer, NewByteCount, pNewBuffer);
	if status ~= ffi.C.NERR_Success then
		return false, status;
	end

	return pNewBuffer[0];
end

local NetApiBufferSize = function(Buffer)
	local pByteCount = ffi.new("DWORD[1]");
	local status = netutils.NetApiBufferSize(Buffer, pByteCount);
	
	if status ~= ffi.C.NERR_Success then
		return false, status;
	end

	return pByteCount[0];
end

local NetRemoteComputerSupports = function(UncServerName, OptionsWanted)
	UncServerName = kernel32.AnsiToUnicode16(UncServerName);

	local pOptionsSupported = ffi.new("DWORD[1]");
	local status = netutils.NetRemoteComputerSupports(UncServerName, OptionsWanted, pOptionsSupported);
	
	if status ~= ffi.C.NERR_Success then
		return false, status;
	end
	
	return pOptionsSupported[0];
end

ffi.cdef[[
typedef struct {
	void * Handle;
} NetApiBuffer;
]]
local NetApiBuffer = ffi.typeof("NetApiBuffer");
local NetApiBuffer_t = {};
local NetApiBuffer_mt = {
	__gc = function(self)
		--print("GC: NetApiBuffer");
		return NetApiBufferFree(self.Handle);
	end,

	__new = function(ct, ...)
		if type(select(1,...)) == "number" then
			-- This case is used if we're creating a new
			-- buffer from scratch
			local buff, err = NetApiBufferAllocate(size);
			if not buff then
				return false, err;
			end

			local obj = ffi.new(ct, buff);

			return obj;
		elseif type(select(1,...)) == "cdata" then
			-- This case is used if a buffer was allocated
			-- elsewhere, and we want to track the lifetime
			-- of the pointer
			return ffi.new(ct, select(1,...));
		end

		return false;
	end,

	__len = function(self)
		return NetApiBufferSize(self.Handle);
	end,

	__index = NetApiBuffer_t,
}
ffi.metatype(NetApiBuffer, NetApiBuffer_mt);


NetApiBuffer_t.Reallocate = function(self, newSize)
	local handle, err = NetApiBufferReallocate(self.Handle, newSize);
	if not handle then
		return false, err;
	end

	self.Handle = handle;
	return self;
end




return {
	NetApiBuffer = NetApiBuffer,

	NetApiBufferAllocate = NetApiBufferAllocate;
	NetApiBufferFree = NetApiBufferFree,
	NetApiBufferReallocate = NetApiBufferReallocate,
	NetApiBufferSize = NetApiBufferSize,
	NetRemoteComputerSupports = NetRemoteComputerSupports,
}