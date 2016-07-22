-- test_wkscli.lua
local ffi = require("ffi")


local Workstation = require("Workstation");
local wkscli = require("wkscli")
local netutils = require("netutils")

--[[
	Utility
--]]
local printTable = function(tbl, title)
	if title then
		print(title);
	end

	for k,v in pairs(tbl) do
		print(k,v);
	end
end

local function printRecords(records, title)
--print("printRecords: ", title, records)

	if title then
		print(title);
	end

	for i, record in ipairs(records) do
		printTable(record);
	end
end

--[[
	Test Cases
--]]



local function test_workstation()
	print("---- test_workstation ----");
	
	local station = Workstation();

	print("after workstation construction")

	printRecords(station:getUses(), "++++ USES");


	printRecords(station:getUsers(1), "==== USERS");
	printRecords(station:getTransports(), "#### TRANSPORTS");
end

local function test_uses()
	local ServerName = nil;
	local Level = 0;
	local BufPtr = ffi.new("BYTE *[1]");
	local PreferedMaximumSize = ffi.C.MAX_PREFERRED_LENGTH;
	local EntriesRead = ffi.new("DWORD[1]");
	local TotalEntries = ffi.new("DWORD[1]");
	--local ResumeHandle = ffi.new("DWORD[1]");
	local ResumeHandle = nil;

print("test_uses, 1.0")
print("PreferedMaximumSize: ", PreferedMaximumSize)
print("NetUseEnum: ", wkscli.NetUseEnum)

	local status = wkscli.NetUseEnum (
     ServerName,
     Level,
     BufPtr,
     PreferedMaximumSize,
     EntriesRead,
     TotalEntries,
     ResumeHandle);

	print("uses, STATUS: ", status);
	print("uses, Entries: ", EntriesRead[0]);
	print("uses, TotalEntries: ", TotalEntries[0]);

	local buff, err = netutils.NetApiBuffer(BufPtr[0]);

	local idx = -1;
	local function closure()
		idx = idx + 1;

		if idx >= EntriesRead[0] then
			return nil;
		end

		if Level == 0 then
			local records = ffi.cast("USE_INFO_0 *", buff.Handle);
			return {
				["local"] = core_string.toAnsi(records[idx].ui0_local),
				["remote"] = core_string.toAnsi(records[idx].ui0_remote),
			}
		end

		return nil;
	end

	return closure;
end

test_workstation();
--test_uses();
