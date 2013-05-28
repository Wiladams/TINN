local ffi = require("ffi");
local inter = require("core_interlocked");
local k32Lib = ffi.load("Kernel32");


local head = ffi.new("SLIST_HEADER");

ffi.cdef[[
typedef struct _LIST_DATA
{
    SLIST_ENTRY ItemEntry;	// SLIST_ENTRY should be first.
    void * Data;            // Your data.
} LIST_DATA, *PLIST_DATA;
]]
local LIST_DATA = ffi.typeof("LIST_DATA");

local InterlockedList = {}
setmetatable(InterlockedList, {__call = function(self, ...) return InterlockedList.new(...); end});

local InterlockedList_mt = {
	__len = function(self)
		return QueryDepthSList(self.Head);
	end,

	__index = InterlockedList,
}

InterlockedList.new = function(...)
	local head = ffi.new("SLIST_HEADER");
	k32Lib.InitializeSListHead (head);

	local obj = {
		Head = head;
	}
	setmetatable(obj, InterlockedList_mt);

	return obj;
end

InterlockedList.push = function(self, data)
	local ListData = LIST_DATA();
	ListData.Data = data;
	local entry = k32Lib.InterlockedPushEntrySList (self.Head, ListData);

	return entry;
end

InterlockedList.pop = function(self)
	local entry = k32Lib.InterlockedPopEntrySList (self.Head);
	if entry ~= nil then
		return entry.Data;
	end

	return false;
end


local list = InterlockedList();

print("List Len: ", #list);
