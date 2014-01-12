local FileSystemItem = require("FileSystemItem");

local FileSystem = {}
setmetatable(FileSystem, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local FileSystem_mt = {
	__index = FileSystem;
}

FileSystem.init = function(self, starting)
	local obj = {
		RootItem = FileSystemItem({Name = starting});
	};
	setmetatable(obj, FileSystem_mt);

	return obj;
end

FileSystem.create = function(self, starting)
	return self:init(starting);
end


FileSystem.getItem = function(self, pattern)
	for item in self.RootItem:items(pattern) do
		return item;
	end

	return nil;
end

FileSystem.getItems = function(self, pattern)
	return self.RootItem:items(pattern);
end

return FileSystem;
