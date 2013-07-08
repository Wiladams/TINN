local ffi = require"ffi"

local core_profile = require("core_profile_l1_1_0");

local StopWatch = {}
setmetatable(StopWatch, {
	__call = function(self, ...) 
		return self:create(...);
	end,
});

local StopWatch_mt = {
	__index = StopWatch,
	
	__tostring = function(self)
		return string.format("Frequency: %d  Count: %d", self.Frequency, self.StartCount)
	end,
}

StopWatch.init = function(self, frequency, startcount)
	local obj = {
		Frequency = frequency,
		StartCount = startcount,
		freqbuff = ffi.new("int64_t[1]");
		countbuff = ffi.new("int64_t[1]");
	}
	setmetatable(obj, StopWatch_mt)

	return obj
end

StopWatch.create = function(self, frequency, startcount)
	local freqbuff = ffi.new("int64_t[1]");
	local countbuff = ffi.new("int64_t[1]");

	frequency = frequency or 1/core_profile.getPerformanceFrequency(freqbuff);
	startcount = startcount or core_profile.getPerformanceCounter(countbuff);

	local obj = self:init(frequency, startcount);

	return obj;
end


function StopWatch:GetCurrentTicks()
	return core_profile.getPerformanceCounter(self.countbuff);
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
	self.Frequency = 1/core_profile.getPerformanceFrequency(self.freqbuff);
	self.StartCount = core_profile.getPerformanceCounter(self.countbuff);
end

-- <summary>
-- Return the number of seconds that elapsed since Reset() was called.
-- </summary>
-- <returns>The number of elapsed seconds.</returns>

function StopWatch:Seconds()
	--local currentCount = GetPerformanceCounter(self.countbuff);
	local currentCount = core_profile.getPerformanceCounter();

	local ellapsed = currentCount - self.StartCount
	local seconds = ellapsed * self.Frequency;

	return seconds
end

function StopWatch:Milliseconds()
	return self:Seconds() * 1000
end

return StopWatch
