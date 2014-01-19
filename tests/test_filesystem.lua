-- test_filesystem.lua

local ffi = require("ffi");

local core_string = require("core_string_l1_1_0");
local core_file = require("core_file_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local WinBase = require("WinBase");
local FileSystemItem = require("FileSystemItem");


local FileSystem = {}

FileSystem.logicalDriveCount = function(self)
	return core_file.GetLogicalDrives();
end

--[[
	File System Volume Iterator
--]]
ffi.cdef[[
typedef struct {
	HANDLE Handle;
} FsFindVolumeHandle;
]]
local FsFindVolumeHandle = ffi.typeof("FsFindVolumeHandle");
local FsFindVolumeHandle_mt = {
	__gc = function(self)
		core_file.FindVolumeClose(self.Handle);
	end,

	__index = {
		isValid = function(self)
			return self.Handle ~= INVALID_HANDLE_VALUE;
		end,
	},
};
ffi.metatype(FsFindVolumeHandle, FsFindVolumeHandle_mt);



local volumes = function(self)
	local cchBufferLength = ffi.C.MAX_PATH;
	local lpszVolumeName = ffi.new("WCHAR[?]", cchBufferLength+1);

	local handle = FsFindVolumeHandle(core_file.FindFirstVolumeW(lpszVolumeName, cchBufferLength));
	local firstone = true;

	local closure = function()
		if not handle:isValid() then 
			return nil;
		end

		if firstone then
			firstone = false;
			return core_string.toAnsi(lpszVolumeName);
		end

		local status = core_file.FindNextVolumeW(handle.Handle, lpszVolumeName, cchBufferLength);

		if status == 0 then
			return nil;
		end

		return core_string.toAnsi(lpszVolumeName);
	end

	return closure;
end













--[[
	Test Cases
--]]

local printDriveCount = function()
	local driveCount = FileSystem:logicalDriveCount();
	print("Logical Drive Count: ", driveCount);
end

local printVolumes = function()

	for volume in volumes() do
		print(volume);
	end
end


local printFileNames = function(pattern)
	for filename in files(pattern) do
		print(filename);
	end
end




local printFileItems = function(startat, filterfunc)
	for item in startat:itemsRecursive() do
		if filterfunc then
			if filterfunc(item) then
				print(item:getFullPath());
			end
		else
			print(item.Name);
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


--depthQuery.traverseItems(FileSystemItem({Name="c:"}), "", passDirectory);
--depthQuery.traverseItems(FileSystemItem({Name="c:"}), "", passLua);
--depthQuery.traverseItems(FileSystemItem({Name="c:"}), "", passHidden);
--depthQuery.traverseItems(FileSystemItem({Name="c:"}), "", passDevice);
--depthQuery.traverseItems(FileSystemItem({Name="c:"}), "", passReadOnly);

--printFileItems(FileSystemItem({Name="c:"}), passHidden);
--printFileItems(FileSystemItem({Name="c:"}), passDirectory);
--printFileItems(FileSystemItem({Name="c:\\tools"}));




local printHtml = function(pattern, filterfunc)
	local fs = FileSystemItem({Name=pattern});

io.write[[
<html>
	<head>
		<title>File Directory</title>
	</head>

	<body>
		<ul>
]]
	for item in fs:items() do
		local goone = true;
		if filterfunc then
			if not filterfunc(item) then
				goone = false;
			end
		end
		local url = item:getFullPath();

		if goone then
			io.write([[<li><a href="]]..url..[[">]]..item.Name..[[</a></li>]]);
			io.write('\n');
		end
	end

io.write[[
		</ul>
	</body>
</html>
]]
end

local nodotdot = function(item)
	return item.Name ~= "." and item.Name ~= "..";
end

--printHtml("c:\\tools", nodotdot);

printVolumes();
