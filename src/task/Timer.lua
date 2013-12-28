local Task = require("IOProcessor")
local parallel = require("parallel")


local Timer = {}
setmetatable(Timer, {
	__call = function(self, ...)
		return self:create(...)
	end,
});

local Timer_mt = {
	__index = Timer;
}

Timer.init = function(self,params)
	local obj = {
		Delay = params.Delay;
		Period = params.Period;
		Running = false;
		OnTime = params.OnTime;
	}
	setmetatable(obj, Timer_mt);

	obj:start()

	return obj;
end

Timer.create = function(self, ...)
	return self:init(...);
end

Timer.start = function(self)
	if self.Running then
		return false, "already running"
	end

	self.Running = true;

	local function closure()
		if self.Delay then
			parallel.sleep(self.Delay);
			self.OnTime(self);
		end

		if not self.Period then
			return 
		end

		while self.Running do
			parallel.sleep(self.Period)
			self.OnTime(self);
		end
	end

	Task:spawn(closure);
end

Timer.cancel = function(self)
	self.Running = false;
end


--[[
	A Couple of convenience methods
--]]

--[[
function Timer.delay = function(func, millis)
	millis = millis or 1000
	return Timer({Delay=millis, OnTime=func})
end

function Timer.periodic = function(func, millis)
	millis = millis or 1000
	return Timer({Period=millis, OnTime=func})
end
--]]

return Timer
