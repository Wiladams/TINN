-- test_Timer.lua

local Timer = require("Timer")

local function printThis()
	print("this")
end

local count = 0;
local function counter(timer)
	count = count + 1;
	if count >= 15 then
		timer:cancel();
	end
	print("counter: ",count)
end

local function testDelays()
	local timer = Timer {Delay = 1*1000, Period = 300, OnTime = printThis}

	-- wait a few seconds, then stop the time
	print("wait 4 seconds...")
	sleep(4*1000)
	print("stop timer")
	timer:cancel();

	-- Wait a few more seconds then exit
	print("wait 2 seconds...")
	sleep(1000*2);
end

local testCounter = function()
	local timer = Timer {Period = 500, OnTime = counter}
end


local function main()
	spawn(testDelays, printThis)
	spawn(testCounter)
end

run(main)

