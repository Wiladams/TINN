local Application = require("Application")


-- Set quanto to zero to get a flat out loop
-- no stalling waiting for IO events.
Application:setMessageQuanta(0)

local loopcount = 100

local fiber1 = function()
	local count = 0;
	for j=1,loopcount do
		if j % 2 == 0 then
			count = count + 1
			print("fiber1: ", count)
		end

		yield();
	end
end

local fiber2 = function()
	local count = 0
	for j=1,loopcount do
		if j % 5 == 0 then
			count = count + 1;
			print("fiber2: ", count)
		end

		yield();
	end
end

local tick = 0
local printTime = function(timer)
	tick = tick + 1
	print("== TIME == ",tick)
end

--[[
	The following convolution allows us to call 'killTime()'
	and have a task spawned, which in turn does a waitFor() on 
	a predicate which is based on the number of ticks of a timer.

	Once the predicate is true, the system will be stopped.
--]]
local killTime = function()
	local closure = function()
		if tick >= 10 then
			return true;
		end

		return false;
	end

	local killer = function()
		waitFor(closure)
		print("Ran out of time")
		stop();
	end

	spawn(killer)
end

local stats = function()
	print("IOProcessor.step, ReadyToRun: ", Task.TasksReadyToRun:Len())
	--print("IOProcessor.step, fibersawaitio: ", fibersawaitio);
end

printStats = function()
	waitFor(stats)
end


local test_sleep = function()
	print("GOING TO SLEEP")
	sleep(1000*3)
	print("DONE SLEEPING")
end


spawn(fiber1)
spawn(fiber2)
periodic(printTime, 200)

killTime();

--spawn(printStats)
spawn(test_sleep)

run()