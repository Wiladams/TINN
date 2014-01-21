-- test_USNJournal.lua

local ffi = require("ffi");

local WinError = require("win_error");
local core_string = require("core_string_l1_1_0");
local USNJournal = require("USNJournal");

local driveletter = "c:"



local function openJournal(driveletter)
    local journal, err = USNJournal:open(driveletter);


    if not journal and err == ERROR_FILE_NOT_FOUND then
	   -- journal file not found, so activate it
	   journal, err = USNJournal:activate(driveletter);

	   print("Activate Journal: ", journal, err);

	   if not journal then
	       print("Could not activate journal: ", err)
	       return false, err;
	   end
    end 

    return journal
end



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

local function printJournalInfo(jinfo)
    print("Journal ID: ", jinfo.UsnJournalID);
    print("First Usn: ", jinfo.FirstUsn);
    print("Next Usn: ", jinfo.NextUsn);
    print("Lowest Valid Usn: ", jinfo.LowestValidUsn);
    print("Max Usn: ", jinfo.MaxUsn);
    print("Max Size: ", tonumber(jinfo.MaximumSize));
    print("Allocation Delta: ", tonumber(jinfo.AllocationDelta));
end

local function printJournalEntry(entry)
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

local function printEntryReason(entry)
    print(string.format("0x%x",entry.Reason), core_string.toAnsi(entry.FileName, entry.FileNameLength))
end


local function test_getJournalEntries(journal, StartUsn, ReasonMask, printRoutine)
    StartUsn = StartUsn or 0
    ReasonMask = ReasonMask or 0xFFFFFFFF;
    printRoutine = printRoutine or printJournalEntry;

    -- print all the USNs
    for entry in journal:entries(nil, ReasonMask) do
	   printRoutine(entry);

       collectgarbage();
    end
end

local function test_getLatestJournalEntries(journal)
    local startAt = tonumber(journal:getNextUsn()) - ffi.C.USN_PAGE_SIZE;

    for entry in journal:entries(startAt) do
    --  print("USN: ", usn);
       printJournalEntry(entry);
    end
end

local function test_waitForNextEntry(journal)
    local entry = journal:waitForNextEntry();

    while entry do
        printJournalEntry(entry);
        entry = journal:waitForNextEntry();
    end

end


local function main()
    local journal, err = openJournal(driveletter)

    if not journal then
        print("ERROR Opening Journal: ", err)
        return err
    end

    -- We have a journal, let's do a query
    local qresult, err = journal:getJournalInfo();

    printJournalInfo(qresult)

    --test_getJournalEntries(journal, 0, ffi.C.USN_REASON_FILE_DELETE, printEntryReason);
    --test_getLatestJournalEntries(journal);


    test_waitForNextEntry(journal);
end

main()

