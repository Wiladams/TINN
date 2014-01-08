

local ffi = require("ffi");

local OSModule = require("OSModule");
local libraryloader = require("core_libraryloader_l1_1_1");
local errorhandling = require("core_errorhandling_l1_1_1");
local core_console = require("core_console_l1_1_0");

--[[
	Test cases


--]]
print("test_OSModule.lua - Test");

local function test_loadmodule()
	local kernel32, err = OSModule("kernel32");

	print(kernel32, err);

	local GetConsoleMode = kernel32.GetConsoleMode;

--[[
	print("GetConsoleMode", GetConsoleMode);

	local lpMode = ffi.new("DWORD[1]");
	local status = GetConsoleMode(nil, lpMode);

	print("Status: ", status);
--]]
end

local function test_Signature()
ffi.cdef[[
typedef BOOL (* PFNGetConsoleMode)(HANDLE hConsoleHandle, LPDWORD lpMode);
]]

--	ffitype = ffi.typeof("PFNGetConsoleMode");
	ffitype = ffi.typeof("GetConsoleMode");
	local kernel32, err = OSModule("kernel32");

	print("ffitype: ", ffitype);
	local func = ffi.cast(ffitype, kernel32.GetConsoleMode);
	print("func: ", func);

	local lpMode = ffi.new("DWORD[1]");
	local status = func(nil, lpMode);
	print("Status: ", status);
	print("  Mode: ", lpMode[0]);
end

function test_loadlibrary()
	flags = 0;
	local handle = libraryloader.LoadLibraryExA("kernel32", nil, flags);

	print("test_loadlibrary, LoadLibraryExA: ", res);

	if handle == nil then
		local err = errorhandling.GetLastError();
		print("Error loading library: ", err);
		
		return false, err;
	end

	local procName = "GetConsoleMode"
	local proc = libraryloader.GetProcAddress(handle, procName);

	print("GetProcAddress: ", proc)

	print("FFI Type: ", ffi.C[procName])
	local ffitype = ffi.typeof("$ *",  ffi.C[procName]);
	local castval = ffi.cast(ffitype, proc);

	print("Cast Proc Value: ", castval)
end

--test_Signature();
--test_loadmodule();
test_loadlibrary();

