
local Collections = require("Collections")
local Functor = require("Functor")


local waitForEvent = {}
setmetatable(waitForEvent, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local waitForEvent_mt = {
	__index = waitForEvent;
}

function waitForEvent.init(self, scheduler)
	local obj = {
		Scheduler = scheduler,
		SuspendedTasks = Collections.Queue(),
	}
	setmetatable(obj, waitForEvent_mt)

	return obj;
end

function waitForEvent.create(self, scheduler)
	scheduler = scheduler or self.Scheduler

	if not scheduler then
		return nil, "no scheduler specified"
	end

	return self:init(scheduler)
end

function waitForEvent.setScheduler(self, scheduler)
	self.Scheduler = scheduler;
end

function waitForEvent.tasksArePending(self)
	return self.SuspendedTasks:Len() > 0;
end


function waitForEvent.yield(self, eventName)
	
	local currentFiber = self.Scheduler:getCurrentFiber();

	--print("waitForEvent.yield: ", eventName, currentFiber)

	if currentFiber == nil then
		return false, "not currently in a running task"
	end

	-- add the fiber to the list of suspended tasks
	if not self.SuspendedTasks[eventName] then
		self.SuspendedTasks[eventName] = {}
	end

	table.insert(self.SuspendedTasks[eventName], currentFiber);

	return self.Scheduler:suspend()
end


function waitForEvent.signalOne(self, eventName)
	if not self.SuspendedTasks[eventName] then
		return false, "event not registered"
	end

	local nTasks = #self.SuspendedTasks[eventName]
	if nTasks < 1 then
		return false, "no tasks waiting for event"
	end

	local suspended = self.SuspendedTasks[eventName][1];
	print("suspended: ", suspended, suspended.routine);

	self.Scheduler:scheduleTask(suspended);
	table.remove(self.SuspendedTasks[eventName], 1);

	return true;
end

function waitForEvent.signalAll(self, eventName)
	if not self.SuspendedTasks[eventName] then
		return false, "event not registered"
	end

	local nTasks = #self.SuspendedTasks[eventName]
	if nTasks < 1 then
		return false, "no tasks waiting for event"
	end

	for i=1,nTasks do
		self.Scheduler:scheduleTask(self.SuspendedTasks[eventName][1]);
		table.remove(self.SuspendedTasks[eventName], 1);
	end

	return true;
end


return waitForEvent
