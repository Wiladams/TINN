local Scheduler = require("EventScheduler");

Runtime = {}
Runtime.Scheduler = Scheduler();

Runtime.Run = function(self, func, ...)
	if func ~= nil then
		self:Spawn(func, ...);
	end
	
	return self.Scheduler:Start();
end 

Runtime.Spawn = function(self, func, ...)
	return self.Scheduler:Spawn(func, ...);
end

Runtime.Stop = function(self)
	return self.Scheduler:Stop();
end

Runtime.Yield = function(self)
	return self.Scheduler:Yield();
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