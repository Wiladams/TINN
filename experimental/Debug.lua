-- test_core_debug.lua

local core_debug = require("core_debug_l1_1_1");
local errorhandling = require("core_errorhandling_l1_1_1");





--[[
	Debug

	Description: This is the interface to be used from within a program to cause
	debug breaks to occur.  A single instance works for an entire application.
--]]
local Debug = {}

Debug["break"] = function(self)
	core_debug.DebugBreak();
	return true;
end

Debug.isDebuggerPresent = function(self)
	return core_debug.IsDebuggerPresent() > 0;
end

Debug.write = function(self, ...)
	local nargs = select('#', ...);
	for i=1,nargs do
		core_debug.OutputDebugStringA(tostring(select(i,...)));
	end
	
	return true;
end

return Debug;
