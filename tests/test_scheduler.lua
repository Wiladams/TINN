-- test_scheduler.lua

local Scheduler = require("Scheduler")
local waitForTime = require("waitForTime")

local sched = Scheduler()
local wft = waitForTime(sched);

local func1 = nil
func1 = function(param)
	print("func1, param: ", param)

	wft:yield(1000)

	sched:spawn(func1, param + 1)
end

local function onStepped()
	print("osp: ", wft:tasksPending())
	collectgarbage();
end

sched.OnStepped = onStepped
sched:spawn(wft.start, wft)
sched:spawn(func1, 1)

sched:start();
