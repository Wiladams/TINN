
--[[
	Fiber, contains stuff related to a running fiber
--]]
local SimpleFiber_t = {}
local SimpleFiber_mt = {
	__index = SimpleFiber_t,
}

local SimpleFiber = function(aroutine, ...)
	local routine = coroutine.create(aroutine)
	if not routine then
		return nil
	end

	local obj = {
		routine = routine, 
		params = {...},
		status = coroutine.status(routine),
	}
	setmetatable(obj, SimpleFiber_mt);

	return obj
end

SimpleFiber_t.Resume = function(self, ...)
	local success, values = coroutine.resume(self.routine, unpack(self.params));

	self.status = coroutine.status(self.routine)

	return success, values;
end

SimpleFiber_t.Suspend = function(self, ...)
	self.status = "suspended"
	return coroutine.yield("suspended", ...)
end


return SimpleFiber;
