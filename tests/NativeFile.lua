-- NativeFile.lua

local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;

local core_file = require("core_file_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local FsHandles = require("FsHandles")
local WinBase = require("WinBase")


-- A win32 file interfaces
-- put the standard async stream interface onto a file
local NativeFile={}
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
	local dwFlagsAndAttributes = ffi.C.FILE_ATTRIBUTE_NORMAL;
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

NativeFile.cancel = function(self)
	local res = core_file.CancelIo(self:getNativeHandle());
end


NativeFile.close = function(self)
	self.Handle:free();
	self.Handle = nil;
end


NativeFile.writeBytes = function(self, buff, nNumberOfBytesToWrite, offset)
	if not self.Handle then
		return nil;
	end

	local lpBuffer = ffi.cast("const char *",buff) + offset or 0
	local lpNumberOfBytesWritten = ffi.new("DWORD[1]")
	local lpOverlapped = nil;

	local res = core_file.WriteFile(self:getNativeHandle(), lpBuffer, nNumberOfBytesToWrite,
		lpNumberOfBytesWritten,
  		lpOverlapped);

	if res == 0 then
		return false, errorhandling.GetLastError();
	end 

	return lpNumberOfBytesWritten[0];
end

NativeFile.writeString = function(self, astring)
	return self:writeBytes(astring, #astring, 0)
end


NativeFile.readBytes = function(self, buff, nNumberOfBytesToRead, offset)
	offset = offset or 0
	local lpBuffer = ffi.cast("char *",buff) + offset
	local lpNumberOfBytesRead = ffi.new("DWORD[1]")
	local lpOverlapped = nil;

	local res = core_file.ReadFile(self:getNativeHandle(), lpBuffer, nNumberOfBytesToRead,
		lpNumberOfBytesRead,
		lpOverlapped);


	if res == 0 then
		return false, errorhandling.GetLastError();
	end 

	return lpNumberOfBytesRead[0];
end


return NativeFile;