-- searchdisk.lua

local FileSystemItem = require("FileSystemItem");


local printFileItems = function(startat, filterfunc)
	for item in startat:itemsRecursive() do
		if filterfunc then
			if filterfunc(item) then
				print(item:getFullPath());
			end
		else
			print(item:getFullPath());
		end
	end
end



local function passHidden(item)
	return item:isHidden();
end

local function passLua(item)
	return item.Name:find(".lua", 1, true);
end

local function passDirectory(item)
	return item:isDirectory();
end

local function passDevice(item)
	return item:isDevice();
end

local function passReadOnly(item)
	return item:isReadOnly();
end




if not arg[1] then
	return false;
end

printFileItems(FileSystemItem({Name=arg[1]}));




