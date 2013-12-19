-- test_when.lua

local Task = require("IOProcessor")
local Timer = require("Timer")
local parallel = require("parallel")()


local counter = 0;

local function incrementCounter()
	counter = counter + 1;

	print("Counter: ", counter)
end

local function timeRunsOut()
	if counter >= 25 then
		return true;
	end

	return false;
end

local function stopWorld()
	print("Goodbye World!")
	Task:stop();
end


local lasttrigger = 0;
local function counterHits5()

	if counter % 5 == 0 then
		if counter ~= lasttrigger then
			lasttrigger = counter
			return true;
		end
	end

	return false;
end

local function sayHalleluja()
	print("Halleluja!")
end


local function main()
	-- Create a timer with the task of incrementing
	-- the counter every few milliseconds
	local t1 = Timer({Period=500, OnTime=incrementCounter})
	
	-- start the task to sing whenever we hit 5 ticks
	whenever(counterHits5, sayHalleluja);

	-- start the task to stop after so many ticks
	when(timeRunsOut, stopWorld);
end



run(main)
