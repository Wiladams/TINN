-- ver.lua

local SysInfo = require("SysInfo");

local ver = function()
	local osvinfo = SysInfo.OSVersionInfo();
	print( string.format("Microsoft Windows [Version %s]", tostring(osvinfo)));
end

return {
	ver = ver;
}