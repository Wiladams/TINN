
--[[
	Fiber, contains stuff related to a running fiber
--]]
local Task = {}

setmetatable(Task, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local Task_mt = {
	__index = Task,
}

Task.init = function(self, aroutine, ...)

	local obj = {
		routine = coroutine.create(aroutine), 
	}
	setmetatable(obj, Task_mt);
	
	obj:setParams(...);

	return obj
end

Task.create = function(self, aroutine, ...)
	-- The 'aroutine' should be something that is callable
	-- either a function, or a table with a meta '__call'
	-- implementation.  Checking with type == 'function'
	-- is not good enough as it will miss the meta __call cases
	--if not aroutine or type(aroutine) ~= "function" then
	--	return nil;
	--end

	return self:init(aroutine, ...)
end


Task.getStatus = function(self)
	return coroutine.status(self.routine);
end

Task.setParams = function(self, ...)
	local nparams = select('#',...);

	self.params = {...}
	return self;
end


Task.resume = function(self)
--print("Task, RESUMING: ", unpack(self.params));
	return coroutine.resume(self.routine, unpack(self.params));
end

return Task;
