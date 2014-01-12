-- test_USNJournal.lua

local ffi = require("ffi");

local WinError = require("win_error");
local core_string = require("core_string_l1_1_0");
local USNJournal = require("USNJournal");

local journal, err = USNJournal:open("c:");

print("Journal: ", journal, err);

if not journal and err == ERROR_FILE_NOT_FOUND then
	-- journal file not found, so activate it
	journal, err = USNJournal:activate("c:");

	print("Activate Journal: ", journal, err);

	if not journal then
		print("Could not activate journal: ", err)
		return false, err;
	end
end 

-- We have a journal, let's do a query
local qresult, err = journal:getJournalInfo();

printJournalInfo = function(jinfo)
    print("Journal ID: ", jinfo.UsnJournalID);
    print("First Usn: ", jinfo.FirstUsn);
    print("Next Usn: ", jinfo.NextUsn);
    print("Lowest Valid Usn: ", jinfo.LowestValidUsn);
    print("Max Usn: ", jinfo.MaxUsn);
    print("Max Size: ", tonumber(jinfo.MaximumSize));
    print("Allocation Delta: ", tonumber(jinfo.AllocationDelta));
end

local printJournalEntry = function(entry)
	print("== JOURNAL ENTRY ==");
	print("Timestamp: ", entry.TimeStamp.QuadPart);
	print("RecordLength: ", entry.RecordLength);
	print("MajorVersion: ", entry.MajorVersion);
	print("MinorVersion: ", entry.MinorVersion);
	print("USN: ", entry.Usn);
	print("Name Length: ", entry.FileNameLength);
	print("Name Offset: ", entry.FileNameOffset);
	print("Filename: ", core_string.toAnsi(entry.FileName, entry.FileNameLength));
end

local printEntryReason = function(entry)
    print(string.format("0x%x",entry.Reason), core_string.toAnsi(entry.FileName, entry.FileNameLength))
end

--print("Query: ", qresult, err);

--printJournalInfo(qresult);


--[[
typedef struct {
    DWORD RecordLength;
    WORD   MajorVersion;
    WORD   MinorVersion;
    DWORDLONG FileReferenceNumber;
    DWORDLONG ParentFileReferenceNumber;
    USN Usn;
    LARGE_INTEGER TimeStamp;
    DWORD Reason;
    DWORD SourceInfo;
    DWORD SecurityId;
    DWORD FileAttributes;
    WORD   FileNameLength;
    WORD   FileNameOffset;
    WCHAR FileName[1];

} USN_RECORD, *PUSN_RECORD;
--]]

local test_getJournalEntries = function(StartUsn, ReasonMask, printRoutine)
    StartUsn = StartUsn or 0
    ReasonMask = ReasonMask or 0xFFFFFFFF;
    printRoutine = printRoutine or printJournalEntry;

    -- print all the USNs
    for entry in journal:entries(nil, ReasonMask) do
	   --printRoutine(entry);

       collectgarbage();
    end
end

local test_getLatestJournalEntries = function()
    local startAt = tonumber(journal:getNextUsn()) - ffi.C.USN_PAGE_SIZE;

    for entry in journal:entries(startAt) do
    --  print("USN: ", usn);
       printJournalEntry(entry);
    end
end

local test_waitForNextEntry = function()
    local entry = journal:waitForNextEntry();

    while entry do
        printJournalEntry(entry);
        entry = journal:waitForNextEntry();
    end

end

test_getJournalEntries(0, ffi.C.USN_REASON_FILE_DELETE, printEntryReason);
--test_getLatestJournalEntries();


--test_waitForNextEntry();