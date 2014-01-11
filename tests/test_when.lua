-- test_when.lua

local Application = require("Application")


local counter = 0;

local function incrementCounter()
	counter = counter + 1;

	print("Counter: ", counter)
end

local function counterExpires()
	if counter >= 5 then
		return true;
	end

	return false;
end

local function stopWorld()
	print("Goodbye World!")
	stop();
end

local function main()

	-- Create a timer with the task of incrementing
	-- the counter every few milliseconds
	periodic(incrementCounter, 500)

	-- start the task to watch the counter expiration
	when(counterExpires, stopWorld)
end


run(main)
