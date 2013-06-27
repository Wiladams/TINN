
local ffi = require("ffi");
local core_interlocked = require("core_interlocked");
local Heap = require("Heap");


SList = {}
setmetatable(SList, {
	__call = function(self, ...)
		return self:create(...);
	end,
});
SList_mt = {
	__index = SList;
}

SList.create = function(self, listHead)
	local obj = {};

	if not listHead then
		obj.OwnAllocation = true;
		listHead = ffi.new("SLIST_HEADER");
		core_interlocked.InitializeSListHead(listHead);
	end

	obj.ListHead = listHead;

	setmetatable(obj, SList_mt);

	return obj;
end

SList.push = function(self, item)
	core_interlocked.InterlockedPushEntrySList(self.ListHead, ffi.cast("SLIST_ENTRY *",item));
end

SList.pop = function(self)
	return core_interlocked.InterlockedPopEntrySList(self.ListHead);
end

SList.length = function(self)
	return core_interlocked.QueryDepthSList(self.ListHead);
end

return SList;
