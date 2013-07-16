-- test_filelist.lua
local FileSystem = require("FileSystem");


local argv = {...}

local basepath = argv[1] or ".";
local filename = argv[2];

local wfs = FileSystem(basepath);

test_single = function()
	local item = wfs:getItem(filename);

	if item then
		print("     Item: ", item.Name);
		print("Directory: ", item:isDirectory());
		print("Full Path: ", item:getFullPath());
	else
		print("Item not found: ", basepath..'\\'..filename);
	end
end

local test_multiple = function()
	for entry in wfs:getItems(filename) do
		print(entry.Name);
	end
end

--test_single();
test_multiple();

