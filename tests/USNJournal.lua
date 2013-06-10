-- USNJournal.lua
-- References
-- http://msdn.microsoft.com/en-us/library/windows/desktop/aa364563(v=vs.85).aspx
-- http://www.microsoft.com/msj/0999/journal/journal.aspx
-- http://www.microsoft.com/msj/1099/journal2/journal2.aspx
-- 

local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;
local band = bit.band;

local core_io = require("core_io_l1_1_1");
local core_file = require("core_file_l1_2_0");
local WinIoCtl = require("WinIoCtl");
local WinBase = require("WinBase");
local errorhandling = require("core_errorhandling_l1_1_1");
local FsHandles = require("FsHandles");


--[[
Change journal operations
FSCTL_CREATE_USN_JOURNAL
FSCTL_DELETE_USN_JOURNAL
FSCTL_ENUM_USN_DATA
FSCTL_MARK_HANDLE
FSCTL_QUERY_USN_JOURNAL
FSCTL_READ_USN_JOURNAL
--]]




--[[
	ChangeJournal

	An abstraction for NTFS Change journal management
--]]
local ChangeJournal = {}
setmetatable(ChangeJournal, {
	__call = function(self, ...)
		self:init(...);
	end,


});

local ChangeJournal_mt = {
	__index = ChangeJournal;
}




ChangeJournal.init = function(self, handle)

	local obj = {
		Handle = handle;
	}
	setmetatable(obj, ChangeJournal_mt);

	local jinfo = obj:getJournalInfo();
	obj.JournalID = jinfo.UsnJournalID;
	obj.LowestUsn = jinfo.LowestValidUsn;
	obj.FirstUsn = jinfo.FirstUsn;
	obj.MaxSize = jinfo.MaximumSize;
	obj.MaxUsn = jinfo.MaxUsn;
	obj.AllocationSize = jinfo.AllocationDelta;

	return obj;
end

ChangeJournal.activate = function(self, driveLetter)
	local handle, err = self:getVolumeHandle(driveLetter, CREATE_NEW);

	--print("ChangeJournal.create, getVolumeHandle: ", handle, err);

	if not handle then
		return false, err;
	end


	local dwIoControlCode = FSCTL_CREATE_USN_JOURNAL;
	local lpInBuffer = ffi.new("CREATE_USN_JOURNAL_DATA");
	local nInBufferSize = ffi.sizeof(lpInBuffer);
	local lpOutBuffer = nil;
	local nOutBufferSize = 0;
	local lpBytesReturned = ffi.new("DWORD[1]");
	local lpOverlapped = nil;

	lpInBuffer.MaximumSize = 1024 * 1024 * 400;
	lpInBuffer.AllocationDelta = 4096 * 1024;

	local status = core_io.DeviceIoControl(self:getNativeHandle(), 
          dwIoControlCode, 
          lpInBuffer,
          nInBufferSize,
          lpOutBuffer,
          nOutBufferSize,
          lpBytesReturned,
          lpOverlapped);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return lpInBuffer;
end

ChangeJournal.disable = function(self, driveLetter)

end

ChangeJournal.open = function(self, driveLetter)
	local handle, err = self:getVolumeHandle(driveLetter);
	if not handle then
		return false, err;
	end

	return self:init(handle);
end

ChangeJournal.getVolumeHandle = function(self, driveLetter, dwCreationDisposition, dwDesiredAccess)
	local lpFileName = string.format("\\\\.\\%s", driveLetter);
	local dwShareMode = bor(FILE_SHARE_READ, FILE_SHARE_WRITE);
	local lpSecurityAttributes = nil;
	dwCreationDisposition = dwCreationDisposition or OPEN_EXISTING;
	dwDesiredAccess = dwDesiredAccess or bor(ffi.C.GENERIC_READ, ffi.C.GENERIC_WRITE);
	local dwFlagsAndAttributes = 0;
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
		return false, errorhandling.GetLastError();
	end

	return FsHandles.FsHandle(handle);
end

ChangeJournal.getNextUsn = function(self)
	local jinfo, err = self:getJournalInfo();

	if not jinfo then
		return false, err;
	end

	return jinfo.NextUsn;
end

ChangeJournal.getNativeHandle = function(self)
	return self.Handle.Handle;
end


ChangeJournal.getJournalInfo = function(self)
	local dwIoControlCode = FSCTL_QUERY_USN_JOURNAL;
	local lpInBuffer = nil;
	local nInBufferSize = 0;
	local lpOutBuffer = ffi.new("USN_JOURNAL_DATA");
	local nOutBufferSize = ffi.sizeof(lpOutBuffer);
	local lpBytesReturned = ffi.new("DWORD[1]");
	local lpOverlapped = nil;

	local status = core_io.DeviceIoControl(self:getNativeHandle(), 
          dwIoControlCode, 
          lpInBuffer,
          nInBufferSize,
          lpOutBuffer,
          nOutBufferSize,
          lpBytesReturned,
          lpOverlapped);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end


	return lpOutBuffer;
end

ChangeJournal.entries = function(self, StartUsn, ReasonMask)
	StartUsn = StartUsn or 0;
	ReasonMask = ReasonMask or 0xFFFFFFFF;
	local ReturnOnlyOnClose = false;
	local Timeout = 0;
	local BytesToWaitFor = 0;

	local BUF_LEN = ffi.C.USN_PAGE_SIZE;
	local Buffer = ffi.new("uint8_t[?]", BUF_LEN);
    local ReadData = ffi.new("READ_USN_JOURNAL_DATA", {StartUsn, ReasonMask, ReturnOnlyOnClose, Timeout, BytesToWaitFor, self.JournalID});

    local dwBytes = ffi.new("DWORD[1]");
    local bytesReturned = 0;
    local dwRetBytes = 0;
    local UsnRecord = nil;
	local nextBuffUsn = StartUsn;

	local closure = function()

		if dwRetBytes == 0 then
			ReadData.StartUsn = nextBuffUsn;

			local status = core_io.DeviceIoControl( self:getNativeHandle(), 
            	FSCTL_READ_USN_JOURNAL, 
            	ReadData,
            	ffi.sizeof(ReadData),
            	Buffer,
            	BUF_LEN,
            	dwBytes,
            	nil);

			if status == 0 then
				local err = errorhandling.GetLastError();
				return nil;
			end

			bytesReturned = dwBytes[0];

			-- skip past the initial USN
			nextBuffUsn = ffi.cast("USN *", Buffer)[0];
			dwRetBytes = bytesReturned - ffi.sizeof("USN");

			if dwRetBytes == 0 then
				-- reached end of records
				return nil;
			end

			-- Find the first record
			UsnRecord = ffi.cast("PUSN_RECORD", ffi.cast("PUCHAR",Buffer) + ffi.sizeof("USN")); 
			dwRetBytes = dwRetBytes - UsnRecord.RecordLength;

			return UsnRecord; 
		end

		-- Return the next record
		UsnRecord = ffi.cast("PUSN_RECORD",(ffi.cast("PCHAR",UsnRecord) + UsnRecord.RecordLength));
		dwRetBytes = dwRetBytes - UsnRecord.RecordLength;

		return UsnRecord;
	end

	return closure;
end

ChangeJournal.waitForNextEntry = function(self, usn, ReasonMask) 
 	usn = usn or self:getNextUsn();
 	local ReasonMask = ReasonMask or 0xFFFFFFFF;
 	local ReturnOnlyOnClose = false;
 	local Timeout = 0;
 	local BytesToWaitFor = 1;

    local ReadData = ffi.new("READ_USN_JOURNAL_DATA", {usn, ReasonMask, ReturnOnlyOnClose, Timeout, BytesToWaitFor, self.JournalID});

    local pusn = ffi.new("USN");
    
    -- This function does not return until the USN
    -- record exits
	local BUF_LEN = ffi.C.USN_PAGE_SIZE;
	local Buffer = ffi.new("uint8_t[?]", BUF_LEN);
    local dwBytes = ffi.new("DWORD[1]");

	local status = core_io.DeviceIoControl( self:getNativeHandle(), 
        FSCTL_READ_USN_JOURNAL, 
        ReadData,
        ffi.sizeof(ReadData),
        Buffer,
        BUF_LEN,
        dwBytes,
        nil);

    if status == 0 then
    	return false, errorhandling.GetLastError();
    end

	local UsnRecord = ffi.cast("PUSN_RECORD", ffi.cast("PUCHAR",Buffer) + ffi.sizeof("USN")); 

    return UsnRecord;
end

return ChangeJournal;

