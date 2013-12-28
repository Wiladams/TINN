-- parallel.lua
-- Network Applicaiton Parallel Processing Environment (NAPPE)

local Functor = require("Functor")
local Task = require("IOProcessor")

-- Scheduler plug-ins
local waitForCondition = require("waitForCondition")
local waitForTime = require("waitForTime")

-- register quanta
local wfc = waitForCondition(Task)
local wft = waitForTime(Task)


--[[
	Convenience Functions
--]]
-- Some standard functions
local sleep = Functor(wft.yield, wft)

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

-- when(Functor(self.noMoreTasks,self), function() self.ContinueRunning = false; end);


local exports = {
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


--[[
function Scheduler.shouldContinue(self)
	-- check the continuation conditions
	local condition = false;

	if self.TasksReadyToRun:Len() > 0 then
		return true;
	elseif self:fibersAwaitIO() then
		return true;
	else
		for _, tasksPending in ipairs(self.ContinuationChecks) do
			if tasksPending() then
				return true
			end
		end
	end

	return false;
end
--]]