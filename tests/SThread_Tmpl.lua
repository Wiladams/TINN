
local ffi = require("ffi");
local SList = require("SList");

-- setup queue to talk back to parent
ffi.cdef[[
typedef struct {
	SLIST_ENTRY	EntryHeader;

	// Data specific to queue
	int32_t		message;
	intptr_t	Data;
} MsgEntry;
]]

local MsgEntry = ffi.typeof("MsgEntry");

local listHead = ffi.cast("SLIST_HEADER *", ffi.cast("void *",tonumber(%s)));
local parentList = SList(listHead);

-- send a message back to parent
local msgEntry = MsgEntry();
msgEntry.message = 10;

--parentList:push(msgEntry);

return 0;
