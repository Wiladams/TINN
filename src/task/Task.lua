
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

function Task.init(self, aroutine, ...)

	local obj = {
		routine = coroutine.create(aroutine), 
	}
	setmetatable(obj, Task_mt);
	
	obj:setParams({...});

	return obj
end

function Task.create(self, aroutine, ...)
	-- The 'aroutine' should be something that is callable
	-- either a function, or a table with a meta '__call'
	-- implementation.  Checking with type == 'function'
	-- is not good enough as it will miss the meta __call cases

	return self:init(aroutine, ...)
end


function Task.getStatus(self)
	return coroutine.status(self.routine);
end

function Task.setParams(self, params)
	self.params = params

	--print("Task.setParams: ", unpack(self.params))
	return self;
end


function Task.resume(self)
--print("Task, RESUMING: ", unpack(self.params));
	return coroutine.resume(self.routine, unpack(self.params));
end

function Task.yield(self, ...)
	return coroutine.yield(...)
end

return Task;
