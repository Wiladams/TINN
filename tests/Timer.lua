local Task = require("IOProcessor")
 
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
		Running = params.Running or false;
		TimerFunc = params.TimerFunc;
	}
	setmetatable(obj, Timer_mt);

	if obj.Running then
		obj:start()
	end

	return obj;
end

Timer.create = function(self, ...)
	return self:init(...);
end

Timer.start = function(self)
	--if self.Running then
	--	return false, "already running"
	--end

	self.Running = true;

	local function closure()
		if self.Delay then
			wait(self.Delay);
			self.TimerFunc(self);
		end

		if not self.Period then
			return 
		end

		while self.Running do
			wait(self.Period)
			self.TimerFunc(self);
		end
	end

	spawn(closure);
end

Timer.stop = function(self)
	self.Running = false;
end

return Timer
