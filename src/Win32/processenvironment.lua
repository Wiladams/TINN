-- processenvironment.lua
require ("core_processenvironment");
local kernel32 = require("win_kernel32");
local k32Lib = kernel32.Lib;

local GetCommandLine = function()
	local cmdline = LPSTR k32Lib.GetCommandLineA();
	return ffi.string(cmdline);
end

return {
	getCommandLine = GetCommandLine,

	GetCommandLine = GetCommandLine,
}