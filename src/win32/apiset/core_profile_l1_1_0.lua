-- core_profile_l1_1_0.lua
-- api-ms-win-core-profile-l1-1-0.dll	
local ffi = require("ffi");
local WTypes = require("WTypes");
local errorhandling = require("core_errorhandling_l1_1_1");
local k32Lib = ffi.load("kernel32");

ffi.cdef[[
BOOL QueryPerformanceFrequency(int64_t *lpFrequency);
BOOL QueryPerformanceCounter(int64_t *lpPerformanceCount);
]]

local function GetPerformanceFrequency(anum)
	anum = anum or ffi.new("int64_t[1]");
	local success = ffi.C.QueryPerformanceFrequency(anum)
	if success == 0 then
		return false, errorhandling.GetLastError(); 
	end

	return tonumber(anum[0])
end

local function GetPerformanceCounter(anum)
	anum = anum or ffi.new("int64_t[1]")
	local success = ffi.C.QueryPerformanceCounter(anum)
	if success == 0 then 
		return false, errorhandling.GetLastError();
	end

	return tonumber(anum[0])
end

local function GetCurrentTickTime()
	local frequency = 1/GetPerformanceFrequency();
	local currentCount = GetPerformanceCounter();
	local seconds = currentCount * frequency;

	return seconds;
end


return {
	getPerformanceCounter = GetPerformanceCounter,
	getPerformanceFrequency = GetPerformanceFrequency,
	getCurrentTickTime = GetCurrentTickTime,

	QueryPerformanceCounter = k32Lib.QueryPerformanceCounter;
	QueryPerformanceFrequency = k32Lib.QueryPerformanceFrequency;
}
