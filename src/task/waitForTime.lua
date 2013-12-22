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

waitForTime.init = function(self, scheduler)
	local obj = {
		Scheduler = scheduler;
		TasksWaitingForTime = {};
	}
	setmetatable(obj, waitForTime_mt)

	scheduler:addQuantaStep(Functor(obj.step,obj));

	return obj;
end

waitForTime.create = function(self, scheduler)
	if not scheduler then
		return nil, "no scheduler specified"
	end

	return self:init(scheduler)
end


waitForTime.step = function(self)
	local currentTime = self.Scheduler.Clock:Milliseconds();

	-- traverse through the fibers that are waiting
	-- on time
	local nAwaiting = #self.TasksWaitingForTime;
print("Timer Events Waiting: ", nAwaiting)
	for i=1,nAwaiting do

		local fiber = self.TasksWaitingForTime[1];
		if fiber.DueTime <= currentTime then
			--print("ACTIVATE: ", fiber.DueTime, currentTime);
			-- put it back into circulation
			-- preferably at the front of the list
			fiber.DueTime = 0;
			self:scheduleFiber(fiber);

			-- Remove the fiber from the list of fibers that are
			-- waiting on time
			table.remove(self.TasksWaitingForTime, 1);
		end
	end
end

local function compareTaskDueTime(task1, task2)
	if task1.DueTime < task2.DueTime then
		return true
	end
	
	return false;
end

waitForTime.yieldUntilTime = function(self, atime)
	--print("IOProcessor.yieldUntilTime: ", atime, self.Clock:Milliseconds())
	--print("Current Fiber: ", self.CurrentFiber)
	local currentFiber = self.Scheduler:getCurrentFiber();
	if currentFiber == nil then
		return false, "not currently in a running task"
	end

	currentFiber.DueTime = atime;
	currentFiber.state = "suspended"
	tabutils.binsert(self.TasksWaitingForTime, currentFiber, compareTaskDueTime);

	return self.Scheduler:yield();
end

waitForTime.yield = function(self, millis)
	local nextTime = self.Scheduler.Clock:Milliseconds() + millis;

	return self:yieldUntilTime(nextTime);
end

return waitForTime
