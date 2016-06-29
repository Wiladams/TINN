-- Storage.lua
local ffi = require("ffi")
local core_file = require("core_file_l1_2_0");
local core_string = require("core_string_l1_1_0")
local errorhandling = require("core_errorhandling_l1_1_1");
local WinError = require("win_error")
local iterators = require("msiterators")


ffi.cdef[[
static const int DRIVE_UNKNOWN     =0;
static const int DRIVE_NO_ROOT_DIR =1;
static const int  DRIVE_REMOVABLE  = 2;
static const int  DRIVE_FIXED      = 3;
static const int  DRIVE_REMOTE     = 4;
static const int  DRIVE_CDROM      = 5;
static const int  DRIVE_RAMDISK    = 6;
]]


local driveTypes = {
	[ffi.C.DRIVE_UNKNOWN] 		= "UNKNOWN",
	[ffi.C.DRIVE_NO_ROOT_DIR] 	= "NO_ROOT_DIR",
	[ffi.C.DRIVE_REMOVABLE] 	= "REMOVABLE",
	[ffi.C.DRIVE_FIXED] 		= "FIXED",
	[ffi.C.DRIVE_REMOTE] 		= "REMOTE",
	[ffi.C.DRIVE_CDROM] 		= "CDROM",
	[ffi.C.DRIVE_RAMDISK] 		= "RAMDISK",
}




local Storage = {}

function Storage.getDriveType(self, drivename)
	local dtype = core_file.GetDriveTypeA(drivename)
	return dtype, driveTypes[dtype];
end

function Storage.logicalDriveCount(self)
	return core_file.GetLogicalDrives();
end

function Storage.logicalDriveNames(self)
	local nBufferLength = 255;
	local lpBuffer = ffi.new("wchar_t[256]");
	local res = core_file.GetLogicalDriveStringsW(nBufferLength, lpBuffer)

	return iterators.wmstrziter(lpBuffer, nBufferLength)
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



function Storage.volumeNames(self)
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

return Storage
