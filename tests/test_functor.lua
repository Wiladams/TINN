-- test_functor.lua
local Functor = require("Functor")

-- some function that will be called with parameters
local function printSomething(words)
	print(words)
end


local f1 = Functor(printSomething)

f1("words to say")

local methods = {}
local methods_mt = {
	__index = methods,
}

methods.init = function(self)
	local obj = {
		name = "foo",
		name2 = "bar",
	}
	setmetatable(obj, methods_mt)
	
	return obj;
end

methods.method1 = function(self)
	print(self.name)
end

methods.method2 = function(self)
	print(self.name2)
end

local m1 = methods:init();

local f2 = Functor(methods.method1, m1)
local f3 = Functor(m1.method2, m1)

f2();
f3();
