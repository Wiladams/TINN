
local ffi = require("ffi");
local TINNThread = require ("TINNThread");
local core_interlocked = require("core_interlocked");
local core_synch = require("core_synch_l1_2_0");
local SList = require("SList");


local readFile = function(filename)
	local fs = io.open(filename, "rb");
	if not fs then
		return false, 'could not open file';
	end

	local str = fs:read("*all");
	fs:close();

	return str;
end

local msgEntryDef = [[
typedef struct {
	SLIST_ENTRY	EntryHeader;

	// Data specific to queue
	int32_t		message;
	intptr_t	Data;
} MsgEntry;
]]

ffi.cdef(msgEntryDef);
local MsgEntry = ffi.typeof("MsgEntry");

local chunkTemplate = readFile("SThread_Tmpl.lua");




main = function()
	local threads = {};
	local myQueue = SList();

	local threadChunk = string.format(chunkTemplate, 
		TINNThread:CreatePointerString(myQueue.ListHead));

	print("CHUNK");
	print("List Head: ", myQueue.ListHead);

	print(threadChunk);

---[[
	-- Startup some threads
	for i=1,1 do
		local thread = TINNThread({
			CodeChunk = threadChunk;
			});

		table.insert(threads, thread);
	end

	while true do
		-- check length of queue
		-- if it's zero, then sleep a bit
		if myQueue:length() < 1 then
			core_synch.Sleep(100);
		else
			local entry = myQueue:pop();
			print("POPPED: ", entry, entry.message);
		end

	end
--]]
end

run(main);
