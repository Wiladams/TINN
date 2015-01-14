-- Machine.lua
local ffi = require("ffi")
local core_file = require("core_file_l1_2_0");
local core_string = require("core_string_l1_1_0")
local errorhandling = require("core_errorhandling_l1_1_1");
local WinError = require("win_error")
local iterators = require("msiterators")
local Storage = require("Storage")

local Machine = {
	Storage = Storage,
	Devices = {},
}

function Machine.Devices.DOSDeviceIterator(self, lpDeviceName)
	if lpDeviceName then
		lpDeviceName = core_string.toUnicode(lpDeviceName)
	end

	local lpTargetPath = ffi.new("wchar_t[1024*64]");
	local ucchMax = 1024*64;

	local res = core_file.QueryDosDeviceW(lpDeviceName, lpTargetPath, ucchMax);

--print("RES: ", res)
	return iterators.wmstrziter(lpTargetPath, res)
end


return Machine
