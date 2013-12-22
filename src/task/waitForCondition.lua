
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

waitForCondition.init = function(self, scheduler)
	local obj = {
		Scheduler = scheduler,
		FibersAwaitingCondition = Collections.Queue(),
	}
	setmetatable(obj, waitForCondition_mt)

	scheduler:addQuantaStep(Functor(obj.step,obj));

	return obj;
end

waitForCondition.create = function(self, scheduler)
	if not scheduler then
		return nil, "no scheduler specified"
	end

	return self:init(scheduler)
end


-- each time we get CPU cycles, perform the following
waitForCondition.step = function(self)
	local nPredicates = self.FibersAwaitingCondition:length()

--print("waitForCondition.step ==> ", nPredicates)

	for i=1,nPredicates do
		local fiber = self.FibersAwaitingCondition:dequeue();
		if fiber.Predicate() then
			fiber.Predicate = nil;
			self.Scheduler:scheduleFiber(fiber);
			--print("Conditional FIBER To Be RESCHEDULED")
		else
			-- stick the fiber back in the queue if it does not
			-- indicate true as yet.
			self.FibersAwaitingCondition:enqueue(fiber)
		end
	end

end

waitForCondition.yield = function(self, predicate)
--	print("waitForCondition.yield: ", predicate, self.Scheduler.CurrentFiber)
	
	local currentFiber = self.Scheduler:getCurrentFiber();
	if currentFiber == nil then
		return false, "not currently in a running task"
	end

	currentFiber.Predicate = predicate;
	currentFiber.state = "suspended";
	self.FibersAwaitingCondition:enqueue(currentFiber)

	return self.Scheduler:yield();
end

return waitForCondition

