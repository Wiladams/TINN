local ffi = require("ffi");

local SList = require("SList");
local SLIST_ENTRY = ffi.typeof("SLIST_ENTRY");

local msgQueueDef = [[
typedef struct {
	SLIST_ENTRY	EntryHeader;

	// Data specific to queue
	int32_t		message;
	intptr_t	Data;
} MsgEntry;
]]

ffi.cdef(msgQueueDef);
local MsgEntry = ffi.typeof("MsgEntry");

--[[
	Test cases
--]]
local alist = SList();
alist:push(MsgEntry());
alist:push(MsgEntry());

print("depth: ", alist:length());

-- Create an alias to the list
local list2 = SList(alist.ListHead);
list2:push(MsgEntry());
list2:push(MsgEntry());

print("Depth 1: ", alist:length());
print("Depth 2: ", list2:length());
