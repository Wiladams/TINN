-- test_objunctor.lua
local functor = {}
setmetatable(functor, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local functor_mt = {
	__index = functor,
	
	__call = function(self, ...)
		if self.Func then
			self.Func(...)
		end
	end,
}

functor.init = function(self, func, ...)
	local obj = {
		Func = func,
		Params = {...},
	}
	setmetatable(obj, functor_mt)

	return obj;
end

functor.create = function(self, ...)
	return self:init(...)
end


local printStuff = function(stuff)
	print(stuff)
end


local func1 = functor(printStuff, ctxt)

func1("hello, world");
func1("hello, work");