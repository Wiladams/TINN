-- NativeFile.lua

local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;

local core_file = require("core_file_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local FsHandles = require("FsHandles")
local WinBase = require("WinBase")
local IOOps = require("IOOps")


ffi.cdef[[
typedef struct {
	IOOverlapped OVL;

	// Our specifics
	HANDLE file;
} FileOverlapped;
]]



-- A win32 file interfaces
-- put the standard async stream interface onto a file
local NativeFile={
	READ = 3;
	WRITE = 4;
}
setmetatable(NativeFile, {
	__call = function(self, ...)
		return self:create(...);
	end,
})

local NativeFile_mt = {
	__index = NativeFile;
}

NativeFile.init = function(self, rawHandle)
	local obj = {
		Handle = FsHandles.FsHandle(rawHandle);
	}
	setmetatable(obj, NativeFile_mt)

	if IOProcessor then
		IOProcessor:observeIOEvent(obj:getNativeHandle(), obj:getNativeHandle());
	end

	return obj;
end

NativeFile.create = function(self, lpFileName, dwDesiredAccess, dwCreationDisposition, dwShareMode)
	if not lpFileName then
		return nil;
	end
	dwDesiredAccess = dwDesiredAccess or bor(ffi.C.GENERIC_READ, ffi.C.GENERIC_WRITE)
	dwCreationDisposition = dwCreationDisposition or OPEN_ALWAYS;
	dwShareMode = dwShareMode or bor(FILE_SHARE_READ, FILE_SHARE_WRITE);
	local lpSecurityAttributes = nil;
	local dwFlagsAndAttributes = bor(ffi.C.FILE_ATTRIBUTE_NORMAL, FILE_FLAG_OVERLAPPED);
	local hTemplateFile = nil;

	local rawHandle = core_file.CreateFileA(
        lpFileName,
        dwDesiredAccess,
        dwShareMode,
    	lpSecurityAttributes,
        dwCreationDisposition,
        dwFlagsAndAttributes,
    	hTemplateFile);

	if rawHandle == INVALID_HANDLE_VALUE then
		return nil, errorhandling.GetLastError();
	end

	return self:init(rawHandle)
end

NativeFile.getNativeHandle = function(self) 
	return self.Handle.Handle 
end

-- Cancel current IO operation
NativeFile.cancel = function(self)
	local res = core_file.CancelIo(self:getNativeHandle());
end


-- Close the file handle
NativeFile.close = function(self)
	self.Handle:free();
	self.Handle = nil;
end

NativeFile.createOverlapped = function(self, buff, bufflen, operation)
	if not IOProcessor then 
		return nil 
	end

	local obj = ffi.new("FileOverlapped");
	
	obj.file = self:getNativeHandle();
	obj.OVL.operation = operation;
	obj.OVL.opcounter = IOProcessor:getNextOperationId();
	obj.OVL.Buffer = buff;
	obj.OVL.BufferLength = bufflen;

	return obj, obj.OVL.opcounter;
end


-- Write bytes to the file
NativeFile.writeBytes = function(self, buff, nNumberOfBytesToWrite, offset)
	if not self.Handle then
		return nil;
	end

	local lpBuffer = ffi.cast("const char *",buff) + offset or 0
	local lpNumberOfBytesWritten = nil;
	local lpOverlapped = self:createOverlapped(ffi.cast("uint8_t *",buff)+offset, 
		nNumberOfBytesToWrite, 
		IOOps.WRITE);


	if lpOverlapped == nil then
		lpNumberOfBytesWritten = ffi.new("DWORD[1]")
	end

--print("lpOverlapped: ", lpOverlapped)
--print("lpNumberOfBytesWritten: ", lpNumberOfBytesWritten)

	local res = core_file.WriteFile(self:getNativeHandle(), lpBuffer, nNumberOfBytesToWrite,
		lpNumberOfBytesWritten,
  		ffi.cast("OVERLAPPED *",lpOverlapped));

--print("WriteFile res: ", res)
	if res == 0 then
		local err = errorhandling.GetLastError();
		if err ~= ERROR_IO_PENDING then
			return false, err
		end
	else
		return lpNumberOfBytesWritten[0];
	end


	if IOProcessor then
    	local key, bytes, ovl = IOProcessor:yieldForIo(self, IOOps.WRITE, lpOverlapped.OVL.opcounter);
--print("key, bytes, ovl: ", key, bytes, ovl)
	    return bytes
	end
end

NativeFile.writeString = function(self, astring)
	return self:writeBytes(astring, #astring, 0)
end


NativeFile.readBytes = function(self, buff, nNumberOfBytesToRead, offset)
	offset = offset or 0
	local lpBuffer = ffi.cast("char *",buff) + offset
	local lpNumberOfBytesRead = nil
	local lpOverlapped = self:createOverlapped(ffi.cast("uint8_t *",buff)+offset, 
		nNumberOfBytesToRead, 
		IOOps.READ);

	if lpOverlapped == nil then
		lpNumberOfBytesRead = ffi.new("DWORD[1]")
	end


	local res = core_file.ReadFile(self:getNativeHandle(), lpBuffer, nNumberOfBytesToRead,
		lpNumberOfBytesRead,
		lpOverlapped);


	if res == 0 then
		local err = errorhandling.GetLastError();
		if err ~= ERROR_IO_PENDING then
			return false, err
		end
	else
		return lpNumberOfBytesRead[0];
	end

	if IOProcessor then
    	local key, bytes, ovl = IOProcessor:yieldForIo(self, IOOps.WRITE, lpOverlapped.OVL.opcounter);
--print("key, bytes, ovl: ", key, bytes, ovl)
	    return bytes
	end

end


return NativeFile;