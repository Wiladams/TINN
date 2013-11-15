--[[
	ConnectNamedPipe = k32Lib.ConnectNamedPipe,
	CreateNamedPipeW = k32Lib.CreateNamedPipeW,
	CreatePipe = k32Lib.CreatePipe,
	DisconnectNamedPipe = k32Lib.DisconnectNamedPipe,
	GetNamedPipeClientComputerNameW = k32Lib.GetNamedPipeClientComputerNameW,
	ImpersonateNamedPipeClient = advapiLib.ImpersonateNamedPipeClient,
	PeekNamedPipe = k32Lib.PeekNamedPipe,
	SetNamedPipeHandleState = k32Lib.SetNamedPipeHandleState,
	TransactNamedPipe = k32Lib.TransactNamedPipe,
	WaitNamedPipeW = k32Lib.WaitNamedPipeW,
--]]

local ffi = require("ffi")

local core_namedpipe = require("core_namedpipe_l1_2_0")
local core_string = require("core_string_l1_1_0")
local errorhandling = require("core_errorhandling_l1_1_1");

local Handles = require("FsHandles")

local NamedPipe = {}
setmetatable(NamedPipe, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local NamedPipe_mt = {
	__index = NamedPipe;
}

NamedPipe.init = function(self, rawHandle)
	local obj = {
		Handle = Handles.FsHandle(rawHandle)
	}
	setmetatable(obj, NamedPipe_mt)
	return obj;
end

NamedPipe.create = function(self, name)
	if not name then 
		return false;
	end

	name = string.format("\\\\.\\pipe\\%s",name)

print("Pipe Name: ", name)

	local lpName = core_string.toUnicode(name);

	if not lpName then 
		return false; 
	end

	local dwOpenMode = ffi.C.PIPE_ACCESS_DUPLEX;
	local dwPipeMode = ffi.C.PIPE_TYPE_BYTE;
	local nMaxInstances = ffi.C.PIPE_UNLIMITED_INSTANCES;
	local nOutBufferSize = 4096;
	local nInBufferSize = 4096;
	local nDefaultTimeOut = 0;
	local lpSecurityAttributes = nil;

	local res = core_namedpipe.CreateNamedPipeW(lpName, 
		dwOpenMode,
		dwPipeMode,
		nMaxInstances,
		nOutBufferSize,
		nInBufferSize,
		nDefaultTimeOut,
		lpSecurityAttributes);

	if res == INVALID_HANDLE_VALUE then
		return nil, GetLastError();
	end


	return self:init(res);
end

NamedPipe.getNativeHandle = function(self) 
	return self.Handle.Handle 
end

NamedPipe.canSeek = function(self)
	return false;
end


NamedPipe.createOverlapped = function(self, buff, bufflen, operation)
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

NamedPipe.writeBytes = function(self, buff, nNumberOfBytesToWrite, offset, deviceoffset)
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

NamedPipe.readBytes = function(self, buff, nNumberOfBytesToRead, offset, deviceoffset)
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


return NamedPipe
