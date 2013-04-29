-- test_OSVersionInfo.lua

local SysInfo = require("SysInfo");

local osvinfo = SysInfo.OSVersionInfo();

print(string.format("Microsoft Windows [Version %s]", tostring(osvinfo)));