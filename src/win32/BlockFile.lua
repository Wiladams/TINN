-- BlockFile.lua

local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;

local core_file = require("core_file_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local WinBase = require("WinBase")
local IOOps = require("IOOps")
local StreamOps = require("StreamOps")
local Handle = require("Handle")
local Application = require("Application")

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

function BlockFile.init(self, rawHandle)
	local obj = {
		Handle = Handle(rawHandle);
		DeviceOffset = 0;
	}
	setmetatable(obj, BlockFile_mt)

	Application:watchForIO(obj:getNativeHandle(), obj:getNativeHandle());

	return obj;
end

function BlockFile.create(self, lpFileName, dwDesiredAccess, dwCreationDisposition, dwShareMode)
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

function BlockFile.getNativeHandle(self) 
	return self.Handle.Handle 
end

-- Cancel current IO operation
function BlockFile.cancel(self)
	local res = core_file.CancelIo(self:getNativeHandle());
end


-- Close the file handle
function BlockFile.close(self)
	self.Handle:free();
	self.Handle = nil;
end

function BlockFile.canSeek(self)
	return true;
end

function BlockFile.seek(self, offset, origin)
	offset = offset or 0
	origin = origin or StreamOps.SEEK_SET

	if origin == StreamOps.SEEK_CUR then
		self.DeviceOffset = self.DeviceOffset + offset;
	elseif origin == StreamOps.SEEK_SET then
		self.DeviceOffset = offset;
	elseif origin == StreamOps.SEEK_END then
		self.DeviceOffset = self:getSize() - offset
	end

	return self.DeviceOffset;
end

function BlockFile.flush(self)
	local res = core_file.FlushFileBuffers(self:getNativeHandle());
	if res == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

function BlockFile.getSize(self)
	local lpFileSizeHigh = nil;

	local res = core_file.GetFileSize(self:getNativeHandle(), lpFileSizeHigh)

	if res == INVALID_FILE_SIZE then
		return false, errorhandling.GetLastError();
	end

	return res;
end

function BlockFile.createOverlapped(self, buff, bufflen, operation)
	
	local obj = ffi.new("FileOverlapped");
	
	obj.file = self:getNativeHandle();
	obj.OVL.operation = operation;
	obj.OVL.opcounter = Application:getNextOperationId();
	obj.OVL.Buffer = buff;
	obj.OVL.BufferLength = bufflen;
	obj.OVL.OVL.Offset = self.DeviceOffset;

	return obj, obj.OVL.opcounter;
end



-- Write bytes to the file
function BlockFile.writeBytes(self, buff, nNumberOfBytesToWrite, offset)
	offset = offset or 0

print("BlockFile:writeBytes: ", buff, nNumberOfBytesToWrite, offset, self.DeviceOffset)
--print("BlockFile:writeBytes: ", self.Handle)

	if not self.Handle then
		return nil;
	end

	local lpBuffer = ffi.cast("const char *",buff) + offset
	local lpNumberOfBytesWritten = nil;
	local lpOverlapped = self:createOverlapped(ffi.cast("uint8_t *",buff)+offset, 
		nNumberOfBytesToWrite, 
		IOOps.WRITE);


	if lpOverlapped == nil then
		lpNumberOfBytesWritten = ffi.new("DWORD[1]")
	end

--print("lpOverlapped: ", lpOverlapped)
--print("lpNumberOfBytesWritten: ", lpNumberOfBytesWritten)

	local res = core_file.WriteFile(self:getNativeHandle(), 
		lpBuffer, 
		nNumberOfBytesToWrite,
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


    local key, bytes, ovl = Application:waitForIO(self, lpOverlapped);

print("BlockFile.writeBytes: key, bytes, ovl: ", key, bytes, ovl)

	self.DeviceOffset = self.DeviceOffset + bytes;
	
	return bytes
end


function BlockFile.readBytes(self, buff, nNumberOfBytesToRead, offset)
	nNumberOfBytesToRead = nNumberOfBytesToRead or 0
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
		ffi.cast("OVERLAPPED *",lpOverlapped));


	local err = errorhandling.GetLastError();

	if res == 0 then
		if err ~= ERROR_IO_PENDING then
			return false, err
		end
	else
		return lpNumberOfBytesRead[0];
	end

    local key, bytes, ovl = Application:waitForIO(self, lpOverlapped);

--    	local ovlp = ffi.cast("OVERLAPPED *", ovl)
--    	print("overlap offset: ", ovlp.Offset)

--print("key, bytes, ovl: ", key, bytes, ovl)
	self.DeviceOffset = self.DeviceOffset + bytes;

	return bytes
end


return BlockFile;