-- parallel.lua
-- Network Applicaiton Parallel Processing Environment (NAPPE)

local Task = require("IOProcessor")
local Timer = require("Timer")




local delay = function(func, millis)
	millis = millis or 1000
	return Timer({Delay=millis, OnTime=func})
end

local periodic = function(func, millis)
	millis = millis or 1000
	return Timer({Period=millis, OnTime=func})
end

local spawn = function(func, ...)
	return Task:spawn(func, ...);
end

local taskIsFinished = function(task)
	local closure = function()
		return task:getStatus() == "dead"
	end

	return closure
end

local when = function(pred, func)

	local watchit = function()
		--print("watchit - BEGIN")
		Task:yieldUntilPredicate(pred)
		func()
	end

	Task:spawn(watchit)
end

local whenever = function(pred, func)

	local watchit = nil;
	watchit = function()
		--print("watchit - BEGIN")
		Task:yieldUntilPredicate(pred)
		func()
		Task:spawn(watchit)
	end

	Task:spawn(watchit)
end




local exports = {
	delay = delay,
	periodic = periodic,
	spawn = spawn,
	taskIsFinished = taskIsFinished,
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