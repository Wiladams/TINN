local Application = require("Application")
local Stopwatch = require("StopWatch")

local app = Application(true);

local loopcount = 5000
local clock = Stopwatch();

local quanta = 0;

local fiber0 = function()
	local msg = "fiber0\n";
	while true do
		quanta = quanta + 1
		--print("fiber0: ", count)
		--io.write(msg)
		yield();
	end
end

local fiber1 = function()
	local count = 0;
	for j=1,loopcount do
		if j % 2 == 0 then
			count = count + 1
			--print("fiber1: ", count)
		end

		yield();
	end
	print("fiber1, finished counting.")
end

local fiber2 = function()
	local count = 0
	for j=1,loopcount do
		if j % 5 == 0 then
			count = count + 1;
			--print("fiber2: ", count)
		end

		yield();
	end
	print("fiber2 finished counting.")
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

local killTime = function(maxticks)
	maxticks = maxticks or 10

	local closure = function()
		if tick >= maxticks then
			return true;
		end

		return false;
	end

	local killer = function()
		waitFor(closure)
		print("Ran out of time")
		print("Quanta/Second: ", quanta/clock:Seconds())

		stop();
	end

	spawn(killer)
end


local printStats = function()
	app:waitFor(stats)
end


local test_sleep = function()
	print("GOING TO SLEEP")
	sleep(1000*3)
	print("DONE SLEEPING")
end


--fiber0();

spawn(fiber0);

spawn(fiber1)
spawn(fiber2)

periodic(printTime, 500)
--app:delay(printTime, 2000)
killTime(5);

--app:spawn(printStats)
--app:spawn(test_sleep)


run()
--app:start();
