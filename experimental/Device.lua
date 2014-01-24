--[[
References
http://msdn.microsoft.com/en-us/magazine/cc163415.aspx
--]]
local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;

local core_file = require("core_file_l1_2_0");
local core_io = require("core_io_l1_1_1");
local Application = require("Application")
local IOOps = require("IOOps")
local FsHandles = require("FsHandles");
local errorhandling = require("core_errorhandling_l1_1_1");
local WinBase = require("WinBase");


local Device = {}
setmetatable(Device, {
	__call = function(self, ...)
		return self:open(...)
	end,
})
local Device_mt = {
	__index = Device,
}

function Device.init(self, rawhandle)
	local obj = {
		Handle = FsHandles.FsHandle(rawhandle)
	}
	setmetatable(obj, Device_mt)
	
	Application:watchForIO(rawhandle, rawhandle)

	return obj;
end


function Device.open(self, devicename, dwDesiredAccess, dwShareMode)
	local lpFileName = string.format("\\\\.\\%s", devicename);
	dwDesiredAccess = dwDesiredAccess or bor(ffi.C.GENERIC_READ, ffi.C.GENERIC_WRITE);
	dwShareMode = bor(FILE_SHARE_READ, FILE_SHARE_WRITE);
	local lpSecurityAttributes = nil;
	local dwCreationDisposition = OPEN_EXISTING;
	local dwFlagsAndAttributes = FILE_FLAG_OVERLAPPED;
	local hTemplateFile = nil;

	local handle = core_file.CreateFileA(
        lpFileName,
        dwDesiredAccess,
        dwShareMode,
     	lpSecurityAttributes,
        dwCreationDisposition,
        dwFlagsAndAttributes,
     	hTemplateFile);


	if handle == INVALID_HANDLE_VALUE then
		return nil, errorhandling.GetLastError();
	end

	return self:init(handle)
end

function Device.getNativeHandle(self)
	return self.Handle.Handle;
end

function Device.createOverlapped(self, buff, bufflen)
	local obj = ffi.new("FileOverlapped");
	
	obj.file = self:getNativeHandle();
	obj.OVL.Buffer = buff;
	obj.OVL.BufferLength = bufflen;

	return obj;
end


function Device.control(self, dwIoControlCode, lpInBuffer, nInBufferSize, lpOutBuffer, nOutBufferSize)
	local lpBytesReturned = nil;
	local lpOverlapped = self:createOverlapped(ffi.cast("void *", lpInBuffer), nInBufferSize);


	local status = core_io.DeviceIoControl(self:getNativeHandle(), 
          dwIoControlCode, 
          ffi.cast("void *", lpInBuffer),
          nInBufferSize,
          lpOutBuffer,
          nOutBufferSize,
          lpBytesReturned,
          ffi.cast("OVERLAPPED *",lpOverlapped));

	local err = errorhandling.GetLastError();

	-- Error conditions
	-- status == 1, err == WAIT_TIMEOUT (258)
	-- status == 0, err == ERROR_IO_PENDING (997)
	-- status == 0, err == something else

	if status == 0 then
		if err ~= ERROR_IO_PENDING then
			return false, err
		end
	end

    local key, bytes, ovl = Application:waitForIO(self, lpOverlapped);

    return bytes;
end


return Device
