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
--	READ = 3;
--	WRITE = 4;
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
		Offset = 0;
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

NativeFile.createOverlapped = function(self, buff, bufflen, operation, deviceoffset)
	if not IOProcessor then 
		return nil 
	end
	
	fileoffset = fileoffset or 0;

	local obj = ffi.new("FileOverlapped");
	
	obj.file = self:getNativeHandle();
	obj.OVL.operation = operation;
	obj.OVL.opcounter = IOProcessor:getNextOperationId();
	obj.OVL.Buffer = buff;
	obj.OVL.BufferLength = bufflen;
	obj.OVL.OVL.Offset = deviceoffset;

	return obj, obj.OVL.opcounter;
end


-- Write bytes to the file
NativeFile.writeBytes = function(self, buff, nNumberOfBytesToWrite, offset, deviceoffset)
	fileoffset = fileoffset or 0

	if not self.Handle then
		return nil;
	end

	local lpBuffer = ffi.cast("const char *",buff) + offset or 0
	local lpNumberOfBytesWritten = nil;
	local lpOverlapped = self:createOverlapped(ffi.cast("uint8_t *",buff)+offset, 
		nNumberOfBytesToWrite, 
		IOOps.WRITE,
		deviceoffset);


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



NativeFile.readBytes = function(self, buff, nNumberOfBytesToRead, offset, deviceoffset)
	offset = offset or 0
	local lpBuffer = ffi.cast("char *",buff) + offset
	local lpNumberOfBytesRead = nil
	local lpOverlapped = self:createOverlapped(ffi.cast("uint8_t *",buff)+offset, 
		nNumberOfBytesToRead, 
		IOOps.READ,
		deviceoffset);

	if lpOverlapped == nil then
		lpNumberOfBytesRead = ffi.new("DWORD[1]")
	end


	local res = core_file.ReadFile(self:getNativeHandle(), lpBuffer, nNumberOfBytesToRead,
		lpNumberOfBytesRead,
		ffi.cast("OVERLAPPED *",lpOverlapped));


	if res == 0 then
		local err = errorhandling.GetLastError();

--print("NativeFile, readBytes: ", res, err)

		if err ~= ERROR_IO_PENDING then
			return false, err
		end
	else
		return lpNumberOfBytesRead[0];
	end

	if IOProcessor then
    	local key, bytes, ovl = IOProcessor:yieldForIo(self, IOOps.READ, lpOverlapped.OVL.opcounter);

    	local ovlp = ffi.cast("OVERLAPPED *", ovl)
    	print("overlap offset: ", ovlp.Offset)

--print("key, bytes, ovl: ", key, bytes, ovl)
	    return bytes
	end

end

NativeFile.readByte = function(self)
	local buff = ffi.new("uint8_t[1]")
	local abyte, err = self:readBytes(buff, 1)

	if not abyte then
		return false, err
	end

	return buff[0];
end

NativeFile.readString = function(self, bufflen)
	bufflen = bufflen or 4096

--print("IOCPNetStream:ReadString: 1.0: ", bufflen);

	local buff = ffi.new("uint8_t[?]", bufflen);
	if not buff then
		return false, "out of memory"
	end

	local bytesread, err = self:readBytes(buff, bufflen);

	if not bytesread then
		return false, err;
	end

	local str = ffi.string(buff, bytesread)

	return str;
end

return NativeFile;