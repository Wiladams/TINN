local ffi = require("ffi")
local core_file = require("core_file_l1_2_0");
local core_string = require("core_string_l1_1_0")

-- for WinBase
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
	[ffi.C.DRIVE_UNKNOWN] = "DRIVE_UNKNOWN",
	[ffi.C.DRIVE_NO_ROOT_DIR] = "DRIVE_NO_ROOT_DIR",
	[ffi.C.DRIVE_REMOVABLE] = "DRIVE_REMOVABLE",
	[ffi.C.DRIVE_FIXED] = "DRIVE_FIXED",
	[ffi.C.DRIVE_REMOTE] = "DRIVE_REMOTE",
	[ffi.C.DRIVE_CDROM] = "DRIVE_CDROM",
	[ffi.C.DRIVE_RAMDISK] = "DRIVE_RAMDISK",
}

local function logicalDriveNames()
	local nBufferLength = 255;
	local lpBuffer = ffi.new("wchar_t[256]");

	local res = core_file.GetLogicalDriveStringsW(nBufferLength, lpBuffer)

	--print("Number of chars: ", res);


	-- now we have all drives, nul terminated, in a single buffer.
	local idx = -1;
	local nameBuff = ffi.new("char[256]")

	local function closure()
		idx = idx + 1;
		local len = 0;

		while len < 255 do 
			--print("char: ", string.char(lpBuffer[idx]))
			if lpBuffer[idx] == 0 then
				break
			end
		
			nameBuff[len] = lpBuffer[idx];
			len = len + 1;
			idx = idx + 1;
		end

		if len == 0 then
			return nil;
		end

		return ffi.string(nameBuff, len);
	end

	return closure;
end

for name in logicalDriveNames() do
	local dtype = core_file.GetDriveTypeA(name)
	print("DRIVE: ", name, driveTypes[dtype] or dtype)
end

