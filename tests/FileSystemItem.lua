
local ffi = require("ffi");
local bit = require("bit");
local band = bit.band;

local core_string = require("core_string_l1_1_0");
local core_file = require("core_file_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local WinBase = require("WinBase");
local WinNT = require("WinNT");
local Collections = require("Collections");


--[[
	File System File Iterator
--]]
ffi.cdef[[
typedef struct {
	HANDLE Handle;
} FsFindFileHandle;
]]
local FsFindFileHandle = ffi.typeof("FsFindFileHandle");
local FsFindFileHandle_mt = {
	__gc = function(self)
		core_file.FindClose(self.Handle);
	end,

	__index = {
		isValid = function(self)
			return self.Handle ~= INVALID_HANDLE_VALUE;
		end,
	},
};
ffi.metatype(FsFindFileHandle, FsFindFileHandle_mt);



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

	local handle = FsFindFileHandle(rawHandle);
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

return FileSystemItem;
