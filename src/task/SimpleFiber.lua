
--[[
	Fiber, contains stuff related to a running fiber
--]]
local SimpleFiber = {}

setmetatable(SimpleFiber, {
	__call = function(self, ...)
		return self:init(...);
	end,
});

local SimpleFiber_mt = {
	__index = SimpleFiber,
}

SimpleFiber.init = function(self, aroutine, ...)
	-- The first parameter must be a function
	if not aroutine or type(aroutine) ~= "function" then
		return nil;
	end

	local obj = {
		routine = coroutine.create(aroutine), 
		params = {...},
	}
	setmetatable(obj, SimpleFiber_mt);
	
	obj:setParams(...);

	return obj
end

SimpleFiber.create = function(self, aroutine, ...)
	return self:init(aroutine, ...)
end


SimpleFiber.getStatus = function(self)
	return coroutine.status(self.routine);
end

SimpleFiber.setParams = function(self, ...)
	local nparams = select('#',...);

--print("SimpleFiber.setParams: ", nparams);

	self.params = {...}
	return self;
end


SimpleFiber.resume = function(self)
--print("SimpleFiber, RESUMING: ", unpack(self.params));
	return coroutine.resume(self.routine, unpack(self.params));
end

return SimpleFiber;
