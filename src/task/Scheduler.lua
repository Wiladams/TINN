
local ffi = require("ffi");

local Collections = require("Collections");
local StopWatch = require("StopWatch");
local Task = require("Task");


--[[
	The Scheduler supports a collaborative processing
	environment.  As such, it manages multiple tasks which
	are represented by Lua coroutines.
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

function Scheduler.init(self, scheduler)
	local obj = {
		Clock = StopWatch();
		TasksReadyToRun = Collections.Queue();
		TaskID = 0;
	}
	setmetatable(obj, Scheduler_mt)
	
	return obj;
end

function Scheduler.create(self, ...)
	return self:init(...)
end

--[[
		Instance Methods
--]]
function Scheduler.tasksArePending(self)
	return self.TasksReadyToRun:Len() > 0
end

function Scheduler.tasksPending(self)
	return self.TasksReadyToRun:Len();
end


function Scheduler.getClock(self)
	return self.Clock;
end


--[[
	Task Handling
--]]
function Scheduler.getNewTaskID(self)
	self.TaskID = self.TaskID + 1;
	return self.TaskID;
end

function Scheduler.scheduleTask(self, task, params)
	--print("Scheduler.scheduleTask: ", task, params)
	params = params or {}
	
	if not task then
		return false, "no task specified"
	end

	task:setParams(params);
	self.TasksReadyToRun:Enqueue(task);	
	task.state = "readytorun"

	return task;
end

function Scheduler.spawn(self, func, ...)
	--print("Scheduler.spawn - BEGIN")
	local task = Task(func, ...)
	task.TaskID = self:getNewTaskID();
	self:scheduleTask(task, {...});
	--print("Scheduler.spawn - END")
	
	return task;
end

function Scheduler.removeFiber(self, fiber)
	--print("REMOVING DEAD FIBER: ", fiber);
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
		print("Scheduler.step: NO TASK")
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
		print("suspended task wants to run")
		return true;
	end

	-- If we have gotten this far, then the task truly is ready to 
	-- run, and it should be set as the currentFiber, and its coroutine
	-- is resumed.
	self.CurrentFiber = task;
	local results = {task:resume()};

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

--print("PCALL, RESUME: ", pcallsuccess, success)

	-- no task is currently executing
	self.CurrentFiber = nil;

	--print("SUCCESS: ", success);
	--print("STATE: ", task.state)

	if not success then
		print("RESUME ERROR")
		print(unpack(results));
	end

	-- Again, check to see if the task is dead after
	-- the most recent resume.  If it's dead, then don't
	-- bother putting it back into the readytorun queue
	-- just remove the task from the list of tasks
	if task:getStatus() == "dead" then
		self:removeFiber(task)

		return true;
	end

	-- The only way the task will get back onto the readylist
	-- is if it's state is 'readytorun', otherwise, it will
	-- stay out of the readytorun list.
	if task.state == "readytorun" then
		self:scheduleTask(task, results);
	end
end


--[[
	Primary Interfaces
--]]

function Scheduler.suspend(self, ...)
	self.CurrentFiber.state = "suspended"
	return self:yield(...)
end

function Scheduler.yield(self, ...)
	return coroutine.yield(...);
end


--[[
	Running the scheduler itself
--]]
function Scheduler.start(self)
	if self.ContinueRunning then
		return false, "scheduler is already running"
	end
	
	self.ContinueRunning = true;

	while self.ContinueRunning do
		self:step();
		if self.OnStepped then
			self.OnStepped()
		end
	end
	print("FINISHED STEP ITERATION")
end

function Scheduler.stop(self)
	self.ContinueRunning = false;
end

return Scheduler