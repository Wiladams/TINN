-- parallel.lua
-- Network Applicaiton Parallel Processing Environment (NAPPE)

local Functor = require("Functor")
local Task = require("IOProcessor")
--local Timer = require("Timer")
local waitForCondition = require("waitForCondition")
local waitForTime = require("waitForTime")

-- register quanta
local wfc = waitForCondition(Task)
local wft = waitForTime(Task)


-- Some standard functions
local sleep = Functor(wft.yield, wft)

--[[
local delay = function(func, millis)
	millis = millis or 1000
	return Timer({Delay=millis, OnTime=func})
end

local periodic = function(func, millis)
	millis = millis or 1000
	return Timer({Period=millis, OnTime=func})
end
--]]

local spawn = function(func, ...)
	return Task:spawn(func, ...);
end

local taskIsFinished = function(task)
	local closure = function()
		return task:getStatus() == "dead"
	end

	return closure
end

local waitFor = Functor(wfc.yield, wfc);


local when = function(pred, func)

	local watchit = function()
		--print("watchit - BEGIN")
		--Task:yieldUntilPredicate(pred)
		waitFor(pred)
		func()
	end

	Task:spawn(watchit)
end

local whenever = function(pred, func)

	local watchit = nil;
	watchit = function()
		--print("watchit - BEGIN")
		--Task:yieldUntilPredicate(pred)
		waitFor(pred)
		func()
		Task:spawn(watchit)
	end

	Task:spawn(watchit)
end



local exports = {
	--delay = delay,
	--periodic = periodic,
	sleep = sleep,
	spawn = spawn,
	taskIsFinished = taskIsFinished,
	waitFor = waitFor,
	when = when,
	whenever = whenever,
}

setmetatable(exports, {
	__call = function()
		for k,v in pairs(exports) do
			_G[k] = v;
		end
	end,
})

return exports
