local Scheduler = require("EventScheduler");

Runtime = {}
Runtime.Scheduler = Scheduler();

Runtime.Run = function(self, func, ...)
	if func ~= nil then
		self:Spawn(func, ...);
	end
	
	self.Scheduler:Start();
end 

Runtime.Spawn = function(self, func, ...)
	self.Scheduler:Spawn(func, ...);
end

Runtime.Stop = function(self)
	self.Scheduler:Stop();
end

--[[
	Convenience Functions
--]]

run = function(func, ...)
	return Runtime:Run(func, ...);
end

spawn = function(func, ...)
	return Runtime:Spawn(func, ...);
end

stop = function()
	return Runtime:Stop();
end

yield = function()
	return Runtime:Yield();
end

-- Simple Return
return Runtime