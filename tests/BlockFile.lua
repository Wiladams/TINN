-- BlockFile.lua

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
local BlockFile={}
setmetatable(BlockFile, {
	__call = function(self, ...)
		return self:create(...);
	end,
})

local BlockFile_mt = {
	__index = BlockFile;
}

BlockFile.init = function(self, rawHandle)
	local obj = {
		Handle = FsHandles.FsHandle(rawHandle);
		FilePointer = 0;
	}
	setmetatable(obj, BlockFile_mt)

	if IOProcessor then
		IOProcessor:observeIOEvent(obj:getNativeHandle(), obj:getNativeHandle());
	end

	return obj;
end

BlockFile.create = function(self, lpFileName, dwDesiredAccess, dwCreationDisposition, dwShareMode)
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

BlockFile.getNativeHandle = function(self) 
	return self.Handle.Handle 
end

-- Cancel current IO operation
BlockFile.cancel = function(self)
	local res = core_file.CancelIo(self:getNativeHandle());
end


-- Close the file handle
BlockFile.close = function(self)
	self.Handle:free();
	self.Handle = nil;
end

BlockFile.canSeek = function(self)
	return true;
end

BlockFile.seek = function(self, offset, origin)
	offset = offset or 0
	origin = origin or StreamOps.SEEK_SET

	if origin == StreamOps.SEEK_CUR then
		self.DeviceOffset = self.DeviceOffset + offset;
	elseif origin == StreamOps.SEEK_SET then
		self.DeviceOffset = offset;
	elseif origin == StreamOps.SEEK_END then
		-- find the length of the file
		-- then subtract from there
	end

	return self.DeviceOffset;
end

BlockFile.createOverlapped = function(self, buff, bufflen, operation)
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
	obj.OVL.OVL.Offset = self.FilePointer;

	return obj, obj.OVL.opcounter;
end



-- Write bytes to the file
BlockFile.writeBytes = function(self, buff, nNumberOfBytesToWrite, offset, deviceoffset)
	fileoffset = fileoffset or 0
	self.FilePointer = deviceoffset or 0

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


BlockFile.readBytes = function(self, buff, nNumberOfBytesToRead, offset, deviceoffset)
	offset = offset or 0
	self.FilePointer = deviceoffset or 0

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
		ffi.cast("OVERLAPPED *",lpOverlapped));


	if res == 0 then
		local err = errorhandling.GetLastError();

--print("BlockFile, readBytes: ", res, err)

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


return BlockFile;