
local Collections = require("Collections")
local Functor = require("Functor")


local waitForCondition = {}
setmetatable(waitForCondition, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local waitForCondition_mt = {
	__index = waitForCondition;
}

function waitForCondition.init(self, scheduler)
	local obj = {
		Scheduler = scheduler,
		FibersAwaitingCondition = Collections.Queue(),
	}
	setmetatable(obj, waitForCondition_mt)

	--scheduler:addQuantaStep(Functor(obj.step,obj));
	--scheduler:spawn(obj.step, obj)

	return obj;
end

function waitForCondition.create(self, scheduler)
	if not scheduler then
		return nil, "no scheduler specified"
	end

	return self:init(scheduler)
end

function waitForCondition.tasksArePending(self)
	return self.FibersAwaitingCondition:Len() > 0;
end


function waitForCondition.yield(self, predicate)
	--print("waitForCondition.yield: ", predicate, self.Scheduler.CurrentFiber)
	
	local currentFiber = self.Scheduler:getCurrentFiber();
	if currentFiber == nil then
		return false, "not currently in a running task"
	end

	currentFiber.Predicate = predicate;
	self.FibersAwaitingCondition:enqueue(currentFiber)

	return self.Scheduler:suspend()
end

-- each time we get CPU cycles, perform the following
function waitForCondition.step(self)
	local nPredicates = self.FibersAwaitingCondition:length()

--print("waitForCondition.step ==> ", nPredicates)

	for i=1,nPredicates do
		local fiber = self.FibersAwaitingCondition:dequeue();
		if fiber.Predicate() then
			fiber.Predicate = nil;
			self.Scheduler:scheduleTask(fiber);
			--print("Conditional FIBER To Be RESCHEDULED")
		else
			-- stick the fiber back in the queue if it does not
			-- indicate true as yet.
			self.FibersAwaitingCondition:enqueue(fiber)
		end
	end
end

function waitForCondition.start(self)
	while true do
		self:step();
		self.Scheduler:yield();
	end
end

return waitForCondition

