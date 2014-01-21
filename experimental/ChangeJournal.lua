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
local Device = require("Device")




--[[
	ChangeJournal

	An abstraction for NTFS Change journal management
--]]
local ChangeJournal = {}
setmetatable(ChangeJournal, {
	__call = function(self, ...)
		return self:open(...);
	end,
});

local ChangeJournal_mt = {
	__index = ChangeJournal;
}

ChangeJournal.init = function(self, device)
--print("ChangeJournal.init: ", device)

	local obj = {
		Device = device;
	}
	setmetatable(obj, ChangeJournal_mt);

	local jinfo, err = obj:getJournalInfo();

	print("ChangeJournal.init, jinfo: ", jinfo, err)

	if jinfo then
		obj.JournalID = jinfo.UsnJournalID;
		obj.LowestUsn = jinfo.LowestValidUsn;
		obj.FirstUsn = jinfo.FirstUsn;
		obj.MaxSize = jinfo.MaximumSize;
		obj.MaxUsn = jinfo.MaxUsn;
		obj.AllocationSize = jinfo.AllocationDelta;
	end

	return obj;
end


ChangeJournal.open = function(self, driveLetter)
	local device, err = Device(driveLetter)

print("ChangeJournal.open, device: ", device, err)

	if not device then
		print("ChangeJournal.open, ERROR: ", err)
		return nil, err
	end

	return self:init(device);
end


ChangeJournal.getNextUsn = function(self)
	local jinfo, err = self:getJournalInfo();

	if not jinfo then
		return false, err;
	end

	return jinfo.NextUsn;
end



ChangeJournal.getJournalInfo = function(self)
	local dwIoControlCode = FSCTL_QUERY_USN_JOURNAL;
	local lpInBuffer = nil;
	local nInBufferSize = 0;
	local lpOutBuffer = ffi.new("USN_JOURNAL_DATA");
	local nOutBufferSize = ffi.sizeof(lpOutBuffer);

	local success, err = self.Device:control(dwIoControlCode, 
          lpInBuffer,
          nInBufferSize,
          lpOutBuffer,
          nOutBufferSize);

	if not success then
		return false, errorhandling.GetLastError();
	end

	return lpOutBuffer;
end

--[[
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

			local success, err = self.Device:control(FSCTL_READ_USN_JOURNAL, 
            	ReadData,
            	ffi.sizeof(ReadData),
            	Buffer,
            	BUF_LEN);

			if not success then
				return nil;
			end


			bytesReturned = success;

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
--]]

function ChangeJournal.waitForNextEntry(self, usn, ReasonMask) 
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

	local success, err = self.Device:control(FSCTL_READ_USN_JOURNAL, 
        ReadData,
        ffi.sizeof(ReadData),
        Buffer,
        BUF_LEN);

	if not success then 
		return false, err
	end

	local UsnRecord = ffi.cast("PUSN_RECORD", ffi.cast("PUCHAR",Buffer) + ffi.sizeof("USN")); 

    return UsnRecord;
end

return ChangeJournal;

