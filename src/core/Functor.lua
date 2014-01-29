-- functor.lua


local function Functor(func, target)
	return function(...)
		if target then
			return func(target,...)
		end

		return func(...)
	end
end

--[[
-- If you want to implement a functor as a table, 
-- the following could be used.
-- The only real advantage is that you can perhaps do more
-- interesting things with the table, like attach attributes 
-- and the like.  But, really, it's a lot slower because 
-- getmetatable() is called each time the __call is invoked.
local functor = {}
setmetatable(functor, {
	__call = function(self, ...)
		return self:create(...);
	end,
})
local functor_mt = {
	__index = functor,
	__call = function(self, ...)
		if self.Target then
			return self.Func(self.Target, ...)
		end

		return self.Func(...)
	end,
}

functor.init = function(self, func, target)
	local obj = {
		Func = func;
		Target = target;
	}
	setmetatable(obj, functor_mt)

	return obj;
end

functor.create = function(self, func, target)
	return self:init(func, target)
end
]]

return Functor