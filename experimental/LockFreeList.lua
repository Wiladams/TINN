
local ffi = require("ffi");
local core_interlocked = require("core_interlocked");


SList = {}
setmetatable(SList, {
	__call = function(self, ...)
		return self:create(...);
	end,
});
SList_mt = {
	__index = SList;
}

SList.init = function(self, listHead)
	local obj = {
		ListHead = listHead;
	};

	setmetatable(obj, SList_mt);

	return obj;
end

SList.create = function(self, listHead)
	local ownAllocation = false;
	if not listHead then
		listHead = ffi.new("SLIST_HEADER");
		core_interlocked.InitializeSListHead(listHead);
	end

	return self:init(listHead, ownAllocation)
end


SList.clear = function(self)
	return core_interlocked.InterlockedFlushSList(self.ListHead);
end


SList.push = function(self, item)
	return core_interlocked.InterlockedPushEntrySList(self.ListHead, ffi.cast("SLIST_ENTRY *",item));
end

SList.pop = function(self)
	return core_interlocked.InterlockedPopEntrySList(self.ListHead);
end

SList.length = function(self)
	return core_interlocked.QueryDepthSList(self.ListHead);
end

return SList;
