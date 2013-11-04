-- SysInfo.lua

local ffi = require("ffi");

local core_sysinfo = require("core_sysinfo_l1_2_0");
local k32Lib = ffi.load("kernel32");
local errorhandling = require("core_errorhandling_l1_1_1");




local OSVERSIONINFO = ffi.typeof("OSVERSIONINFOA")
local OSVERSIONINFO_mt = {
	__new = function(ct)
		local obj = ffi.new(ct)
		obj.dwOSVersionInfoSize = ffi.sizeof(ct);
		core_sysinfo.GetVersionExA(obj);

		return obj;
	end,

	__tostring = function(self)
		return string.format("%d.%d.%d", 
			self.dwMajorVersion, self.dwMinorVersion, self.dwBuildNumber);
	end,
}
OSVERSIONINFO = ffi.metatype(OSVERSIONINFO, OSVERSIONINFO_mt);


local GetSystemDirectory = function()
   local lpBuffer = ffi.new("char[?]", ffi.C.MAX_PATH+1);
    local buffSize = core_sysinfo.GetSystemDirectoryA(lpBuffer, ffi.C.MAX_PATH);
    
    if res == 0 then
        return false, errorhandling.GetLastError();
    end

    return ffi.string(lpBuffer, buffSize);
end


local GetSystemWindowsDirectory = function()
   local lpBuffer = ffi.new("char[?]", ffi.C.MAX_PATH+1);
    local buffSize = core_sysinfo.GetSystemWindowsDirectoryA(lpBuffer, ffi.C.MAX_PATH);
    
    if res == 0 then
        return false, errorhandling.GetLastError();
    end

    return ffi.string(lpBuffer, buffSize);
end


local systemDirectory = function()
    print(GetSystemDirectory());
end

local windowsDirectory = function()
    print(GetSystemWindowsDirectory());
end


--[[
    DWORD dwLength;
    DWORD dwMemoryLoad;
    DWORDLONG ullTotalPhys;
    DWORDLONG ullAvailPhys;
    DWORDLONG ullTotalPageFile;
    DWORDLONG ullAvailPageFile;
    DWORDLONG ullTotalVirtual;
    DWORDLONG ullAvailVirtual;
    DWORDLONG ullAvailExtendedVirtual;
--]]
local getMemoryStatus = function()
    local lpBuffer = ffi.new("MEMORYSTATUSEX")
    lpBuffer.dwLength = ffi.sizeof("MEMORYSTATUSEX")

    local res = core_sysinfo.GlobalMemoryStatusEx(lpBuffer)
    
    if res == 0 then
        return false, errorhandling.GetLastError();
    end

    local info = {
        MemoryLoad = lpBuffer.dwMemoryLoad;
        
        TotalPhysical = lpBuffer.ullTotalPhys;
        AvailablePhysical = lpBuffer.ullAvailPhys;

        TotalVirtual = lpBuffer.ullTotalVirtual;
        AvailableVirtual = lpBuffer.ullAvailVirtual;

        TotalPageFile = lpBuffer.ullAvailPageFile;
        AvailablePageFile = lpBuffer.ullAvailPageFile;

        AvailableExtendedVirtual = lpBuffer.ullAvailExtendedVirtual;
    }
    
    return info;
end

return {
    getMemoryStatus = getMemoryStatus;

    OSVersionInfo = OSVERSIONINFO;

    getSystemDirectory = GetSystemDirectory;
    getSystemWindowsDirectory = GetSystemWindowsDirectory;

    systemDirectory = systemDirectory,
    windowsDirectory = windowsDirectory,
}
