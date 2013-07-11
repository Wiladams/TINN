-- test_coroutine.lua
local IOProcessor = require("IOProcessor");
local SimpleFiber = require("SimpleFiber");

local inMainFiber = function(self)
	return coroutine.running() == nil; 
end

local func1 
func1 = function(step)

	if step == 1 then
		print("func1: STEP: ", step);
		
		print("NEXT: ", coroutine.yield(2));
	end


	return 32, 64, 128;
end

local function test_fiber()
local fiber = SimpleFiber(func1, 1);

print("FIBER: ", fiber)
repeat
	result = {fiber:resume()};
	local success = result[1];
	table.remove(result,1);
	local step = unpack(result);

	print("=========")
	print("SUCCESS: ", success);
	print(" VALUES: ", step);
	print(" Status: ", fiber:getStatus());
	print("---------")
	fiber:setParams(step);
until fiber:getStatus() == "dead"
end



run(func1, 1);
