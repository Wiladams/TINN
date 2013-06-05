-- test_filestream.lua

local JSON = require("dkjson");
local FileSystemItem = require("FileSystemItem")


local getFsStreams = function(fsItem)
	local res = {}

	for item in fsItem:itemsRecursive() do
		--print("Path: ", item:getFullPath());
		local entry = {Path=item:getFullPath()}
		local streams = {};
		for stream in item:streams() do
			--print(" Stream: ", stream);
			table.insert(streams, {Name = stream});
		end
		if #streams > 0 then
			entry.Streams = streams;
		end

		table.insert(res, entry);
	end

	return res;
end



local getUniqueStreamNames = function(fsItem)
	local items = getFsStreams(fsItem);

	local names = {}
	for _,item in ipairs(items) do  
		if item.Streams then
			for _,entry in ipairs(item.Streams) do
				if not names[entry.Name] then
					names[entry.Name] = 1;
				else
					names[entry.Name] = names[entry.Name] + 1;
				end
			end
		end
	end

	return names;
end

local test_findUniqueStreams = function(fsItem)
	local uniqueNames = getUniqueStreamNames(fsItem);

	local jsonstr = JSON.encode(uniqueNames, {indent=true});

	print(jsonstr);
end

local test_findFilesWithStream = function(fsItem, streamType)
	local items = getFsStreams(fsItem);

	local res = {};
	for _, item in ipairs(items) do
		if item.Streams then
			for _,entry in ipairs(item.Streams) do
				if entry.Name == streamType then
					table.insert(res, item);
				end
			end
		end
	end

	local jsonstr = JSON.encode(res, {indent=true});
	print(jsonstr);
end

local rootName = arg[1] or "c:\\Temp";
--local streamType = arg[2] or ":favicon:$DATA";
--local streamType = arg[2] or ":CA_INOCULATEIT:$DATA";
--local streamType = arg[2] or ":OECustomProperty:$DATA";
--local streamType = arg[2] or ":encryptable:$DATA";
local streamType = arg[2] or ":Zone.Identifier:$DATA";

local fsItem = FileSystemItem({Name=rootName});

test_findUniqueStreams(fsItem);

--test_findFilesWithStream(fsItem, streamType);
