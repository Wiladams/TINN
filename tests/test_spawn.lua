local Application = require("Application")


-- Set quanto to zero to get a flat out loop
-- no stalling waiting for IO events.
--Application:setMessageQuanta(0)


local function fiber1(loopcount)
	local count = 0;
	for j=1,loopcount do
		if j % 2 == 0 then
			count = count + 1
			print("fiber1: ", count)
		end

		yield();
	end
end

local function fiber2(loopcount)
	local count = 0
	for j=1,loopcount do
		if j % 5 == 0 then
			count = count + 1;
			print("fiber2: ", count)
		end

		yield();
	end
end

local function fiber3(loopcount)
	local spawned1 = false;

	for i=1,loopcount do
		print("fiber 3: ", i)
		if (not spawned1) and (i >= loopcount/2) then
			spawn(fiber1, i)
			spawned1 = true;
		end
		yield(i);
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
	print("Application.step, ReadyToRun: ", Application.Scheduler:tasksReadyToRun());
end

printStats = function()
	waitFor(stats)
end


local test_sleep = function()
	print("GOING TO SLEEP")
	sleep(1000*3)
	print("DONE SLEEPING")
end

local function test_spawn_parallel()
	spawn(fiber1, 100)
	spawn(fiber2, 100)
end

local function test_spawn_serial()
	spawn(fiber3, 100)
end

local function main()
--periodic(printTime, 200)

--killTime();

--spawn(printStats)
--spawn(test_sleep)

test_spawn_serial();
--test_spawn_parallel();
end

run(main)