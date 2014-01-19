--[[
local Task = {}
local Task_mt = {
	__index = Task,
}

function Task.new(self, aroutine, ...)
	local obj = {
		routine = coroutine.create(aroutine), 
	}
	setmetatable(obj, Task_mt);
	
	obj:setParams(...);

	return obj
end

function Task.setParams(self, ...)
	self.params = {...}
	return self;
end

function Task.resume(self)
	return coroutine.resume(self.routine, unpack(self.params));
end
--]]

local Task = require("Task")

local total = 0

local function f1()
	for i=1,100 do
		total = total + 1;
		coroutine.yield(i);
	end
end

local t1 = Task(f1)
while t1:resume() do
	local state = t1:resume()
	print(t1:getStatus())
end
