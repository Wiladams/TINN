-- test_Timer.lua

local Timer = require("Timer")

local function printThis()
	print("this")
end

local count = 0;
local function counter(timer)
	count = count + 1;
	if count >= 5 then
		timer:stop();
	end
	print("counter: ",count)
end

local function main(func)
	local timer = Timer {Delay = 1*1000, Period = 300, TimerFunc = func}

	timer:start();


	-- wait a few seconds, then stop the time
	print("wait 4 seconds...")
	wait(4*1000)
	print("stop timer")
	timer:stop(1000*4);

	-- Wait a few more seconds then exit
	print("wait 2 seconds...")
	wait(1000*2);
end

local testCounter = function()
	local timer = Timer {Period = 200, TimerFunc = counter, Running=true}
end


--run(main, printThis)
--run(main, counter)
run(testCounter)

