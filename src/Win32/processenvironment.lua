-- processenvironment.lua

local ffi = require("ffi");

local core_procenv = require ("core_processenvironment");
local core_errorhandling = require("core_errorhandling_l1_1_1");


local GetCommandLine = function()
	local cmdline = core_procenv.GetCommandLineA();
	if cmdline ~= nil then
		return ffi.string(cmdline);
	end

	return false, "no command line returned"
end

local GetCurrentDirectory = function()
	local lpBuffer = ffi.new("char[?]", ffi.C.MAX_PATH+1);
	local res = core_procenv.GetCurrentDirectoryA(ffi.C.MAX_PATH, lpBuffer);
	if res == 0 then
		return false, core_errorhandling.GetLastError();
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