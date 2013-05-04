-- core_profile_l1_1_0.lua
-- api-ms-win-core-profile-l1-1-0.dll	
local ffi = require("ffi");
require("WTypes");

local k32Lib = ffi.load("kernel32");

ffi.cdef[[
BOOL QueryPerformanceFrequency(int64_t *lpFrequency);
BOOL QueryPerformanceCounter(int64_t *lpPerformanceCount);
]]

local function GetPerformanceFrequency(anum)
	anum = anum or ffi.new("int64_t[1]");
	local success = ffi.C.QueryPerformanceFrequency(anum)
	if success == 0 then
		return false, k32Lib.GetLastError(); 
	end

	return tonumber(anum[0])
end

local function GetPerformanceCounter(anum)
	anum = anum or ffi.new("int64_t[1]")
	local success = ffi.C.QueryPerformanceCounter(anum)
	if success == 0 then 
		return false, k32Lib.GetLastError();
	end

	return tonumber(anum[0])
end

local function GetCurrentTickTime()
	local frequency = 1/GetPerformanceFrequency();
	local currentCount = GetPerformanceCounter();
	local seconds = currentCount * frequency;
--print(string.format("win_kernel32 - GetCurrentTickTime() - %d\n", seconds));

	return seconds;
end


return {
	Lib = k32Lib;

	getPerformanceCounter = GetPerformanceCounter,
	getPerformanceFrequency = GetPerformanceFrequency,
	getCurrentTickTime = GetCurrentTickTime,

	QueryPerformanceCounter = k32Lib.QueryPerformanceCounter;
	QueryPerformanceFrequency = k32Lib.QueryPerformanceFrequency;
}
