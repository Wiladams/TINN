
local cocreate = coroutine.create;
local costatus = coroutine.status;
local resume = coroutine.resume;
local yield = coroutine.yield;

--[[
	Fiber, contains stuff related to a running fiber
--]]
local SimpleFiber_t = {}
local SimpleFiber_mt = {
	__index = SimpleFiber_t,
}

local SimpleFiber = function(aroutine, ...)
	local routine = cocreate(aroutine)
	if not routine then
		return nil
	end

	local obj = {
		routine = routine, 
		params = {...},
		status = costatus(routine),
	}
	setmetatable(obj, SimpleFiber_mt);

	return obj
end

SimpleFiber_t.Resume = function(self, ...)
	local success, values = resume(self.routine, unpack(self.params));

	self.status = costatus(self.routine)

	return success, values;
end

SimpleFiber_t.Suspend = function(self, ...)
	self.status = "suspended"
	return yield("suspended", ...)
end


return SimpleFiber;
