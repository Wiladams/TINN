local Functor = require("Functor")
local tabutils = require("tabutils");


local waitForTime = {}
setmetatable(waitForTime, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local waitForTime_mt = {
	__index = waitForTime;
}

function waitForTime.init(self, scheduler)
	local obj = {
		Scheduler = scheduler;
		TasksWaitingForTime = {};
	}
	setmetatable(obj, waitForTime_mt)

	return obj;
end

function waitForTime.create(self, scheduler)
	scheduler = scheduler or self.Scheduler
	
	if not scheduler then
		return nil, "no scheduler specified"
	end

	return self:init(scheduler)
end

function waitForTime.setScheduler(self, scheduler)
	self.Scheduler = scheduler;
end

function waitForTime.tasksArePending(self)
	return #self.TasksWaitingForTime > 0
end

function waitForTime.tasksPending(self)
	return #self.TasksWaitingForTime;
end

local function compareTaskDueTime(task1, task2)
	if task1.DueTime < task2.DueTime then
		return true
	end
	
	return false;
end

function waitForTime.yieldUntilTime(self, atime)
--	print("waitForTime.yieldUntilTime: ", atime, self.Scheduler.Clock:Milliseconds())
	--print("Current Fiber: ", self.CurrentFiber)
	local currentFiber = self.Scheduler:getCurrentFiber();
	if currentFiber == nil then
		--print("no current task")
		return false, "not currently in a running task"
	end

	currentFiber.DueTime = atime;
	tabutils.binsert(self.TasksWaitingForTime, currentFiber, compareTaskDueTime);
--print("yieldUntilTime - END")

	return self.Scheduler:suspend()
end

function waitForTime.yield(self, millis)
	--print('waitForTime.yield, CLOCK: ', self.Scheduler.Clock)

	local nextTime = self.Scheduler.Clock:Milliseconds() + millis;

	return self:yieldUntilTime(nextTime);
end

function waitForTime.step(self)
	--print("waitForTime.step, CLOCK: ", self.Scheduler.Clock);

	local currentTime = self.Scheduler.Clock:Milliseconds();

	-- traverse through the fibers that are waiting
	-- on time
	local nAwaiting = #self.TasksWaitingForTime;
--print("Timer Events Waiting: ", nAwaiting)
	for i=1,nAwaiting do

		local fiber = self.TasksWaitingForTime[1];
		if fiber.DueTime <= currentTime then
			--print("ACTIVATE: ", fiber.DueTime, currentTime);
			-- put it back into circulation
			-- preferably at the front of the list
			fiber.DueTime = 0;
			--print("waitForTime.step: ", self)
			self.Scheduler:scheduleTask(fiber);

			-- Remove the fiber from the list of fibers that are
			-- waiting on time
			table.remove(self.TasksWaitingForTime, 1);

			--print("waitForTime.step, after schedule: ", self.Scheduler:tasksPending())
		end
	end
end

function waitForTime.start(self)
	while true do
		self:step();
		self.Scheduler:yield();
	end
end

return waitForTime
