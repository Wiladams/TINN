-- test_filesystem.lua

local ffi = require("ffi");

local core_string = require("core_string_l1_1_0");
local core_file = require("core_file_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local WinBase = require("WinBase");
local FileSystemItem = require("FileSystemItem");


local FileSystem = {}

FileSystem.volumes = function(self)
end

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


local depthQuery = {}

depthQuery.traverseItems = function(starting, indentation, filterfunc)
	indentation = indentation or "";

	starting = starting or FileSystemItem({Name="c:"});

	for item in starting:items() do
		if filterfunc then
			if filterfunc(item) then
				if item.Name ~= '.' and item.Name ~= ".." then
			  		io.write(indentation, item.Name, '\n');
			  		--io.write(indentation, item:getFullPath(), '\n');
				end
			end
		else
			if item.Name ~= '.' and item.Name ~= ".." then
			  io.write(indentation, item.Name, '\n');
			end
		end
		
		if item:isDirectory() and item.Name ~= "." and item.Name ~= ".." then
			depthQuery.traverseItems(item, indentation.."  ", filterfunc);
		end
	end
end

--printDriveCount();
--printVolumes();
--printFileNames();
--printFileNames("c:\\tools\\*");

local function passHidden(item)
	return item:isHidden();
end

local function passLua(item)
	return item.Name:find(".lua", 1, true);
end

local function passDirectory(item)
	return item:isDirectory();
end

--depthQuery.traverseItems(FileSystemItem({Name="c:"}), "", passDirectory);
depthQuery.traverseItems(FileSystemItem({Name="c:"}), "", passLua);
--depthQuery.traverseItems(FileSystemItem({Name="c:"}), "", passHidden);
