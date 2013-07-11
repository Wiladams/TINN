
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

	local routine = coroutine.create(aroutine)

	local obj = {
		routine = routine, 
		params = {...},
	}
	setmetatable(obj, SimpleFiber_mt);

	return obj
end

SimpleFiber.getStatus = function(self)
	return coroutine.status(self.routine);
end

SimpleFiber.setParams = function(self, ...)
	local nparams = select('#',...);

--print("SimpleFiber.setParams: ", nparams);

	if nparams == 0 then
		self.params = {};
	elseif nparams == 1 then
		if type(select(1,...)) == "table" then
			self.params = select(1,...);
		else
			self.params = {...};
		end
	else
		self.params = {...};
	end

	return self;
end


SimpleFiber.resume = function(self)
--print("SimpleFiber, RESUMING: ", unpack(self.params));
	return coroutine.resume(self.routine, unpack(self.params));
end

return SimpleFiber;
