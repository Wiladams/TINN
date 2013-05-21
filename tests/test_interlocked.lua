local ffi = require("ffi");

local core_interlocked = require("core_interlocked");
local SLIST_ENTRY = ffi.typeof("SLIST_ENTRY");

SList = {}
setmetatable(SList, {
	__call = function(self, ...)
		return self:new(...);
	end,
});
SList_mt = {
	__index = SList;
}

SList.new = function(self, ...)
	local obj = {
		ListHead = ffi.new("SLIST_HEADER");	
	};

	core_interlocked.InitializeSListHead(obj.ListHead);

	setmetatable(obj, SList_mt);

	return obj;
end

SList.push = function(self, item)
	core_interlocked.InterlockedPushEntrySList(self.ListHead, item);
end

SList.pop = function(self)
	return core_interlocked.InterlockedPopEntrySList(self.ListHead);
end

SList.length = function(self)
	return core_interlocked.QueryDepthSList(self.ListHead);
end



--[[
	Test cases
--]]
local alist = SList();
alist:push(SLIST_ENTRY());
alist:push(SLIST_ENTRY());

print("depth: ", alist:length());
