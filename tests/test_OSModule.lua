

local ffi = require("ffi");

local OSModule = require("OSModule");

--[[
	Test cases


--]]
print("test_OSModule.lua - Test");

test_loadmodule = function()
	local kernel32, err = OSModule:load("kernel32");

	print(kernel32, err);


	local GetConsoleMode = kernel32.GetConsoleMode;

	print("GetConsoleMode", GetConsoleMode);

	local lpMode = ffi.new("DWORD[1]");
	local status = GetConsoleMode(nil, lpMode);

	print("Status: ", status);
end

test_Signature = function()
ffi.cdef[[
typedef BOOL (* PFNGetConsoleMode)(HANDLE hConsoleHandle, LPDWORD lpMode);
]]

--	ffitype = ffi.typeof("PFNGetConsoleMode");
	ffitype = ffi.typeof("GetConsoleMode");
	local kernel32, err = OSModule:load("kernel32");

	print("ffitype: ", ffitype);
	local func = ffi.cast(ffitype, kernel32.GetConsoleMode);
	print("func: ", func);

	local lpMode = ffi.new("DWORD[1]");
	local status = func(nil, lpMode);
	print("Status: ", status);
	print("  Mode: ", lpMode[0]);
end

--test_Signature();
test_loadmodule();

