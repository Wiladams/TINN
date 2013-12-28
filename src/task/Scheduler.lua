
if Scheduler_Included then
	return Scheduler;
end

Scheduler_Included = true;

local ffi = require("ffi");

local Collections = require("Collections");
local StopWatch = require("StopWatch");
local SimpleFiber = require("SimpleFiber");
local WinError = require("win_error");
local Functor = require("Functor")
local tabutils = require("tabutils");


--[[
	The Scheduler supports a collaborative processing
	environment.  As such, it manages multiple tasks which
	are represented by Lua coroutines.

	There may be multiple instances of schedulers running in
	the system at the same time.  The complexity of dealing 
	with io events, timed events, and the like, are supported
	through a plug-in mechanism.  Any additional features
	can be supported through this plug-in mechanism.
--]]
local Scheduler = {}
setmetatable(Scheduler, {
	__call = function(self, ...)
		return self:create(...)
	end,
})
local Scheduler_mt = {
	__index = Scheduler,
}

function Scheduler.init(self, ...)
	local obj = {
		Clock = StopWatch();
		QuantaSteps = {};
		ContinuationChecks = {};

		TaskID = 0;
		TasksReadyToRun = Collections.Queue();

	}
	setmetatable(obj, Scheduler_mt)
	
	obj:addQuantaStep(Functor(obj.step,obj));

	return obj;
end

function Scheduler.create(self, ...)
	return self:init(...)
end


--[[
		Instance Methods
--]]
function Scheduler.getClock(self)
	return self.Clock;
end


--[[
	Fiber Handling
--]]
function Scheduler.getTaskID(self)
	self.TaskID = self.TaskID + 1;
	return self.TaskID;
end

function Scheduler.scheduleFiber(self, afiber, ...)
	if not afiber then
		return false, "no fiber specified"
	end

	afiber:setParams(...);
	self.TasksReadyToRun:Enqueue(afiber);	
	afiber.state = "readytorun"

	return afiber;
end

function Scheduler.removeFiber(self, fiber)
	--print("DROPPING DEAD FIBER: ", fiber);
	return true;
end

function Scheduler.inMainFiber(self)
	return coroutine.running() == nil; 
end

function Scheduler.getCurrentFiber(self)
	return self.CurrentFiber;
end

function Scheduler.step(self)
	-- Now check the regular fibers
	local task = self.TasksReadyToRun:Dequeue()

	-- If no fiber in ready queue, then just return
	if task == nil then
		return true
	end

	if task:getStatus() == "dead" then
		self:removeFiber(task)

		return true;
	end

	-- If the task we pulled off the active list is 
	-- not dead, then perhaps it is suspended.  If that's true
	-- then it needs to drop out of the active list.
	-- We assume that some other part of the system is responsible for
	-- keeping track of the task, and rescheduling it when appropriate.
	if task.state == "suspended" then
		return true;
	end

	-- If we have gotten this far, then the task truly is ready to 
	-- run, and it should be set as the currentFiber, and its coroutine
	-- is resumed.
	self.CurrentFiber = task;
	local results = {task:resume()};

	-- no task is currently executing
	self.CurrentFiber = nil;

	-- once we get results back from the resume, one
	-- of two things could have happened.
	-- 1) The routine exited normally
	-- 2) The routine yielded
	--
	-- In both cases, we parse out the results of the resume 
	-- into a success indicator and the rest of the values returned 
	-- from the routine
	local success = results[1];
	table.remove(results,1);


	--print("SUCCESS: ", success);
	if not success then
		print("RESUME ERROR")
		print(unpack(results));
	end

	-- Again, check to see if the task is dead after
	-- the most recent resume.  If it's dead, then don't
	-- bother putting it back into the readytorun queue
	-- just remove the task from the list of tasks
	if task:getStatus() == "dead" then
		--print("Scheduler, DEAD coroutine, removing")
		self:removeFiber(task)

		return true;
	end

	-- The only way the task will get back onto the readylist
	-- is if it's state is 'readytorun', otherwise, it will
	-- stay out of the readytorun list.
	if task.state == "readytorun" then
		self:scheduleFiber(task, results);
	end
end


function Scheduler.addQuantaStep(self, astep)
	table.insert(self.QuantaSteps,astep)
end

-- returns an iterator of all the steps
-- to be executed per quanta
function Scheduler.quantumSteps(self)

	local index = 0;
	local listSize = #self.QuantaSteps;

	local closure = function()
		if not self.ContinueRunning then
			return nil;
		end

		index = index + 1;
		
		local astep = self.QuantaSteps[index]

		if (index % listSize) == 0 then
			index = 0
		end

		return astep
	end

	return closure	
end

--[[
	Primary Interfaces
--]]

function Scheduler.spawn(self, aroutine, ...)
	--print("Scheduler.spawn()", aroutine, ...);
	local task = SimpleFiber(aroutine)
	task.TaskID = self:getTaskID();
	self:scheduleFiber(task, ...);

	return task;
end

function Scheduler.suspend(self, aTask)
	aTask = aTask or self.CurrentFiber;

	aTask.state = "suspended";

	return self:yield();
end

function Scheduler.yield(self, ...)
	return coroutine.yield(...);
end

function Scheduler.stop(self)
	self.ContinueRunning = false;
end

function Scheduler.start(self)
	self.ContinueRunning = true;


	for astep in self:quantumSteps() do
		astep()
		
		-- if we're running in a coroutine
		-- then yield
		if not self:inMainFiber() then
			self:yield();
		end
	end

	print("FINISHED STEP ITERATION")
end

function Scheduler.run(self, func, ...)
	if func ~= nil then
		self:spawn(func, ...);
	end


	self:start();
end


return Scheduler