-- test_OSVersionInfo.lua

local SysInfo = require("SysInfo");

local function test_directories()
	print("---- test_directories ----");
	print("System Directory: ", SysInfo.getSystemDirectory());
    print("Windows Directory: ", SysInfo.getSystemWindowsDirectory());

end

local function test_versioninfo()
	print("---- test_versioninfo ----");
	local osvinfo = SysInfo.OSVersionInfo();
	print(string.format("Microsoft Windows [Version %s]", tostring(osvinfo)));
end

local function test_meminfo()
	print("---- test_meminfo ----");
	local mstats = SysInfo.getMemoryStatus();
    print("MemoryLoad: ", mstats.MemoryLoad);
	print("TotalPhysical (MB): ", mstats.TotalPhysical / 1024/1024);
	print("AvailablePhysical (MB): ", mstats.AvailablePhysical/1024/1024);


	print("TotalVirtual (MB): ", mstats.TotalVirtual /1024/1024);
	print("AvailableVirtual (MB): ", mstats.AvailableVirtual/1024/1024);


	print("TotalPageFile (MB) :", mstats.TotalPageFile/1024/1024);
	print("AvailablePageFile (MB): ", mstats.AvailablePageFile/1024/1024);

	print("AvailableExtendedVirtual (MB): ", mstats.AvailableExtendedVirtual/1024/1024);
	
end


test_directories();
test_meminfo();
test_versioninfo();
