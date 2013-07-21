
local ffi = require("ffi");
local bit = require("bit");
local band = bit.band;

local core_string = require("core_string_l1_1_0");
local core_file = require("core_file_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local WinBase = require("WinBase");
local WinNT = require("WinNT");
local FsHandles = require("FsHandles");

local Collections = require("Collections");


--[[
	File System File Iterator
--]]

local FileSystemItem = {}
setmetatable(FileSystemItem, {
	__call = function(self, ...)
		return self:new(...);
	end,
});

local FileSystemItem_mt = {
	__index = FileSystemItem;
}


FileSystemItem.new = function(self, params)
	params = params or {}
	setmetatable(params, FileSystemItem_mt);

	return params;
end

FileSystemItem.getFullPath = function(self)
	local fullpath = self.Name;

	if self.Parent then
		fullpath = self.Parent:getFullPath().."\\"..fullpath;
	end

	return fullpath;
end

FileSystemItem.getPath = function(self)
	local fullpath = self.Name;

	if self.Parent and self.Parent.Name:find(":") == nil then
		fullpath = self.Parent:getFullPath().."\\"..fullpath;
	end

	return fullpath;
end

FileSystemItem.isArchive = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_ARCHIVE) > 0; 
end

FileSystemItem.isCompressed = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_COMPRESSED) > 0; 
end

FileSystemItem.isDevice = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_DEVICE) > 0; 
end

FileSystemItem.isDirectory = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_DIRECTORY) > 0; 
end

FileSystemItem.isEncrypted = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_ENCRYPTED) > 0; 
end

FileSystemItem.isHidden = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_HIDDEN) > 0; 
end

FileSystemItem.isNormal = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_NORMAL) > 0; 
end

FileSystemItem.isNotContentIndexed = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_NOT_CONTENT_INDEXED) > 0; 
end

FileSystemItem.isOffline = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_OFFLINE) > 0; 
end

FileSystemItem.isReadOnly = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_READONLY) > 0; 
end

FileSystemItem.isReparsePoint = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_REPARSE_POINT) > 0; 
end

FileSystemItem.isSparse = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_SPARSE_FILE) > 0; 
end

FileSystemItem.isSystem = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_SYSTEM) > 0; 
end

FileSystemItem.isTemporary = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_TEMPORARY) > 0; 
end

FileSystemItem.isVirtual = function(self)
	return band(self.Attributes, ffi.C.FILE_ATTRIBUTE_VIRTUAL) > 0; 
end



-- Iterate over the subitems this item might contain
FileSystemItem.items = function(self, pattern)
	pattern = pattern or self:getFullPath().."\\*";
	local lpFileName = core_string.toUnicode(pattern);
	--local fInfoLevelId = ffi.C.FindExInfoStandard;
	local fInfoLevelId = ffi.C.FindExInfoBasic;
	local lpFindFileData = ffi.new("WIN32_FIND_DATAW");
	local fSearchOp = ffi.C.FindExSearchNameMatch;
	local lpSearchFilter = nil;
	local dwAdditionalFlags = 0;

	local rawHandle = core_file.FindFirstFileExW(lpFileName,
		fInfoLevelId,
		lpFindFileData,
		fSearchOp,
		lpSearchFilter,
		dwAdditionalFlags);

	local handle = FsHandles.FsFindFileHandle(rawHandle);
	local firstone = true;

	local closure = function()
		if not handle:isValid() then 
			return nil;
		end

		if firstone then
			firstone = false;
			return FileSystemItem({
				Parent = self;
				Attributes = lpFindFileData.dwFileAttributes;
				Name = core_string.toAnsi(lpFindFileData.cFileName);
				Size = (lpFindFileData.nFileSizeHigh * (MAXDWORD+1)) + lpFindFileData.nFileSizeLow;
				});
		end

		local status = core_file.FindNextFileW(handle.Handle, lpFindFileData);

		if status == 0 then
			return nil;
		end

		return FileSystemItem({
				Parent = self;
				Attributes = lpFindFileData.dwFileAttributes;
				Name = core_string.toAnsi(lpFindFileData.cFileName);
				});

	end
	
	return closure;
end

FileSystemItem.itemsRecursive = function(self)
	local stack = Collections.Stack();
	local itemIter = self:items();

	local closure = function()
		while true do
			local anItem = itemIter();
			if anItem then
				if (anItem.Name ~= ".") and (anItem.Name ~= "..") then
					if anItem:isDirectory() then
						stack:push(itemIter);
						itemIter = anItem:items();
					end

					return anItem;
				end
			else
				itemIter = stack:pop();
				if not itemIter then
					return nil;
				end 
			end
		end 
	end

	return closure;
end


ffi.cdef[[
typedef enum _STREAM_INFO_LEVELS {
    FindStreamInfoStandard,
    FindStreamInfoMaxInfoLevel
} STREAM_INFO_LEVELS;

typedef struct _WIN32_FIND_STREAM_DATA {
    LARGE_INTEGER StreamSize;
    WCHAR cStreamName[ MAX_PATH + 36 ];
} WIN32_FIND_STREAM_DATA, *PWIN32_FIND_STREAM_DATA;

HANDLE FindFirstStreamW(
    LPCWSTR lpFileName,
    STREAM_INFO_LEVELS InfoLevel,
    LPVOID lpFindStreamData,
    DWORD dwFlags);

BOOL FindNextStreamW(
    HANDLE hFindStream,
	LPVOID lpFindStreamData
);
]]

local k32Lib = ffi.load("Kernel32");


FileSystemItem.streams = function(self)
	local lpFileName = core_string.toUnicode(self:getFullPath());
	local InfoLevel = ffi.C.FindStreamInfoStandard;
	local lpFindStreamData = ffi.new("WIN32_FIND_STREAM_DATA");
	local dwFlags = 0;

	local rawHandle = k32Lib.FindFirstStreamW(lpFileName,
		InfoLevel,
		lpFindStreamData,
		dwFlags);
	local firstone = true;
	local fsHandle = FsHandles.FsFindFileHandle(rawHandle);

	--print("streams, rawHandle: ", rawHandle, rawHandle == INVALID_HANDLE);

	local closure = function()
		if not fsHandle:isValid() then return nil; end

		if firstone then
			firstone = false;
			return core_string.toAnsi(lpFindStreamData.cStreamName);
		end
		 
		local status = k32Lib.FindNextStreamW(fsHandle.Handle, lpFindStreamData);
		if status == 0 then
			local err = errorhandling.GetLastError();
			--print("Status: ", err);
			-- if not more streams found, then GetLastError() will return
			-- ERROR_HANDLE_EOF (38)
			return nil;
		end

		return core_string.toAnsi(lpFindStreamData.cStreamName);
	end

	return closure;
end

return FileSystemItem;
