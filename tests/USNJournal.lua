-- USNJournal.lua
-- http://msdn.microsoft.com/en-us/library/windows/desktop/aa364563(v=vs.85).aspx

local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;
local band = bit.band;

local core_io = require("core_io_l1_1_1");
local core_file = require("core_file_l1_2_0");
local WinIoCtl = require("WinIoCtl");
local WinBase = require("WinBase");
local errorhandling = require("core_errorhandling_l1_1_1");

--[[
Change journal operations
FSCTL_CREATE_USN_JOURNAL
FSCTL_DELETE_USN_JOURNAL
FSCTL_ENUM_USN_DATA
FSCTL_MARK_HANDLE
FSCTL_QUERY_USN_JOURNAL
FSCTL_READ_USN_JOURNAL
--]]

ffi.cdef[[
typedef struct {
	HANDLE  Handle;
} FsHandle;
]]
local FsHandle = ffi.typeof("FsHandle");
local FsHandle_mt = {
	__gc = function(self)
		if self:isValid() then
			core_file.CloseHandle(self.Handle);
		end
	end,

	__index = {
		isValid = function(self)
			return self.Handle ~= INVALID_HANDLE_VALUE;
		end,
	},
};


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

ChangeJournal.create = function(self, driveLetter)
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

	return FsHandle(handle);
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

ChangeJournal.entries = function(self, lowest, highest)
	lowest = lowest or self.FirstUsn;
	highest = highest or self:getNextUsn()-1;
	
	local BUF_LEN = 4096;
	local Buffer = ffi.new("uint8_t[?]", BUF_LEN);
    local ReadData = ffi.new("READ_USN_JOURNAL_DATA", {0, 0xFFFFFFFF, false, 0, 0});
    ReadData.UsnJournalID = self.JournalID;
    local dwBytes = ffi.new("DWORD[1]");
    local bytesReturned = 0;
    local dwRetBytes = 0;
    local UsnRecord = nil;
	local firsttime = true;
	local idx = lowest-1;

	local closure = function()
		--idx = idx + 1;
		--if idx > highest then
		--	return nil;
		--end

		if firsttime then
			firsttime = false;
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

			bytesReturned = dwBytes[0];
			dwRetBytes = bytesReturned - ffi.sizeof("USN");

			-- Find the first record
			UsnRecord = ffi.cast("PUSN_RECORD", ffi.cast("PUCHAR",Buffer) + ffi.sizeof("USN")); 

			return UsnRecord; 
		end

        dwRetBytes = dwRetBytes - UsnRecord.RecordLength;

        if dwRetBytes < 1 then
			ReadData.StartUsn = UsnRecord.Usn;
			--ffi.cast("USN *", Buffer)[0];

			local status = core_io.DeviceIoControl( self:getNativeHandle(), 
            	FSCTL_READ_USN_JOURNAL, 
            	ReadData,
            	ffi.sizeof(ReadData),
            	Buffer,
            	BUF_LEN,
            	dwBytes,
            	nil);

			if status == 0 then
				return nil;
			end

			UsnRecord = ffi.cast("PUSN_RECORD", ffi.cast("PUCHAR",Buffer) + ffi.sizeof("USN")); 

			return UsnRecord; 
        end

		UsnRecord = ffi.cast("PUSN_RECORD",(ffi.cast("PCHAR",UsnRecord) + UsnRecord.RecordLength)); 

--[[        
		local status = core_io.DeviceIoControl( self:getNativeHandle(), 
            	FSCTL_READ_USN_JOURNAL, 
            	ReadData,
            	ffi.sizeof(ReadData),
            	Buffer,
            	BUF_LEN,
            	dwBytes,
            	nil);

		if status == 0 then
			return nil;
		end
--]]

		return UsnRecord;
	end

	return closure;
end

return ChangeJournal;

--[[
#define BUF_LEN 4096

   READ_USN_JOURNAL_DATA ReadData = {0, 0xFFFFFFFF, FALSE, 0, 0};
   PUSN_RECORD UsnRecord;  

ReadData.UsnJournalID = JournalData.UsnJournalID;


   for(I=0; I<=10; I++)
   {
      memset( Buffer, 0, BUF_LEN );

      if( !DeviceIoControl( hVol, 
            FSCTL_READ_USN_JOURNAL, 
            &ReadData,
            sizeof(ReadData),
            &Buffer,
            BUF_LEN,
            &dwBytes,
            NULL) )
      {
         printf( "Read journal failed (%d)\n", GetLastError());
         return;
      }

      dwRetBytes = dwBytes - sizeof(USN);

      // Find the first record
      UsnRecord = (PUSN_RECORD)(((PUCHAR)Buffer) + sizeof(USN));  

      printf( "****************************************\n");

      // This loop could go on for a long time, given the current buffer size.
      while( dwRetBytes > 0 )
      {
         printf( "USN: %I64x\n", UsnRecord->Usn );
         printf("File name: %.*S\n", 
                  UsnRecord->FileNameLength/2, 
                  UsnRecord->FileName );
         printf( "Reason: %x\n", UsnRecord->Reason );
         printf( "\n" );

         dwRetBytes -= UsnRecord->RecordLength;

         // Find the next record
         UsnRecord = (PUSN_RECORD)(((PCHAR)UsnRecord) + 
                  UsnRecord->RecordLength); 
      }
      // Update starting USN for next call
      ReadData.StartUsn = *(USN *)&Buffer; 
   }

   CloseHandle(hVol);
--]]