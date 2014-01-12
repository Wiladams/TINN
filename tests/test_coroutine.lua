-- test_coroutine.lua
local Application = require("Application");
local Task = require("Task");

local inMainFiber = function(self)
	return coroutine.running() == nil; 
end

function func1(step)

	if step == 1 then
		print("func1: STEP: ", step);
		
		print("NEXT: ", coroutine.yield(2));
	end


	return 32, 64, 128;
end

local function test_fiber()
local task = Task(func1, 1);

print("TASK: ", fiber)
repeat
	result = {task:resume()};
	local success = result[1];
	table.remove(result,1);
	local step = unpack(result);

	print("=========")
	print("SUCCESS: ", success);
	print(" VALUES: ", step);
	print(" Status: ", task:getStatus());
	print("---------")
	task:setParams(step);
until task:getStatus() == "dead"
end


test_fiber();
--run(func1, 1);
