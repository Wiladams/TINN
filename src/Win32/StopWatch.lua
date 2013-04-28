local ffi = require"ffi"

require "win_kernel32"
local kernel32 = ffi.load("kernel32")

local StopWatch = {}
setmetatable(StopWatch, {__call = function(self, ...) return StopWatch.new(...);end});

local StopWatch_mt = {
	__index = StopWatch,
}

function StopWatch.new()
	local obj = {
		Frequency = 0,
		StartCount = 0,
		freqbuff = ffi.new("int64_t[1]");
		countbuff = ffi.new("int64_t[1]");
	}
	setmetatable(obj, StopWatch_mt)

	obj:Reset();

	return obj
end

function StopWatch:__tostring()
	return string.format("Frequency: %d  Count: %d", self.Frequency, self.StartCount)
end

function StopWatch:GetCurrentTicks()
	return GetPerformanceCounter(self.countbuff);
end

--[[
/// <summary>
/// Reset the startCount, which is the current tick count.
/// This will reset the elapsed time because elapsed time is the
/// difference between the current tick count, and the one that
/// was set here in the Reset() call.
/// </summary>
--]]

function StopWatch:Reset()
	self.Frequency = 1/GetPerformanceFrequency(self.freqbuff);
	self.StartCount = GetPerformanceCounter(self.countbuff);
end

-- <summary>
-- Return the number of seconds that elapsed since Reset() was called.
-- </summary>
-- <returns>The number of elapsed seconds.</returns>

function StopWatch:Seconds()
	--local currentCount = GetPerformanceCounter(self.countbuff);
	local currentCount = GetPerformanceCounter();

	local ellapsed = currentCount - self.StartCount
	local seconds = ellapsed * self.Frequency;

	return seconds
end

function StopWatch:Milliseconds()
	return self:Seconds() * 1000
end

return StopWatch
