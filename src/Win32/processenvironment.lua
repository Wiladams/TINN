-- processenvironment.lua

local ffi = require("ffi");

require ("core_processenvironment");
local kernel32 = require("win_kernel32");
local k32Lib = kernel32.Lib;

local GetCommandLine = function()
	local cmdline = k32Lib.GetCommandLineA();
	if cmdline ~= nil then
		return ffi.string(cmdline);
	end

	return false, "no command line returned"
end

local GetCurrentDirectory = function()
	local lpBuffer = ffi.new("char[?]", ffi.C.MAX_PATH+1);
	local res = k32Lib.GetCurrentDirectoryA(ffi.C.MAX_PATH, lpBuffer);
	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return ffi.string(lpBuffer);
end

cmdLine = function()
	print(GetCommandLine());
end

cwd = function()
	print(GetCurrentDirectory());
end

return {
	cmdLine = cmdLine;
	cwd = cwd;

	getCommandLine = GetCommandLine,
	GetCommandLine = GetCommandLine,

	getcwd = GetCurrentDirectory,
	GetCurrentDirectory = GetCurrentDirectory,
}