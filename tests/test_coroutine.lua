-- test_coroutine.lua
local Application = require("Application");
local Task = require("Task");

local inMainFiber = function(self)
	return coroutine.running() == nil; 
end

function func1(...)
	local nparams = select('#', ...)
	if nparams == 1 and select(1,...) == 1 then
		print("func1, param count: ", nparams)
		
		print("NEXT: ", coroutine.yield(2));
	end


	return 32, 64, 128;
end

local function test_fiber()
	local task = Task(func1, 1);

	print("TASK: ", task)
	repeat
		result = {task:resume()};
		local success = result[1];
		table.remove(result,1);
		local step = unpack(result);

		print("=========")
		print("SUCCESS: ", success);
		print(" VALUES: ", unpack(result));
		print(" Status: ", task:getStatus());
		print("---------")
		task:setParams(unpack(result));
	until task:getStatus() == "dead"
end


test_fiber();
--run(func1, 1);
