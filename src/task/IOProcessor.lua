
if Task_Included then
	return IOProcessor;
end

Task_Included = true;

local ffi = require("ffi");

local Collections = require("Collections");
local StopWatch = require("StopWatch");
local SimpleFiber = require("SimpleFiber");
local IOCompletionPort = require("IOCompletionPort");
local WinError = require("win_error");
local core_synch = require("core_synch_l1_2_0");
local IOOps = require("IOOps")
local Functor = require("Functor")
local tabutils = require("tabutils");


IOProcessor = {
	Clock = StopWatch();
	QuantaSteps = {};

	TaskID = 0;
	TasksReadyToRun = Collections.Queue();
	TasksWaitingForTime = {};


	FibersAwaitingPredicate = Collections.Queue();

	MessageQuanta = 10;		-- milliseconds
	OperationId = 0;
	IOEventQueue = IOCompletionPort:create();
	EventFibers = {};
	FibersAwaitingEvent = {};
	TasksWaitingForIO = {};
};


IOProcessor.getClock = function(self)
	return self.Clock;
end

--[[
	The message quanta is the amount of time we will wait on the 
	primary message queue, before timing out.

	This is the fasest the single thread can switch between 
	tasks.
--]]
IOProcessor.setMessageQuanta = function(self, millis)
--print("setMessageQuanta: ", millis);
	self.MessageQuanta = millis;
	return self;
end


IOProcessor.getNextOperationId = function(self)
	self.OperationId = self.OperationId + 1;
	return self.OperationId;
end


--
-- Given a handle, add it to the list of handles
-- we will observe for io events.
--
IOProcessor.observeIOEvent = function(self, handle, param)
	return self.IOEventQueue:addIoHandle(handle, param);
end





--[[
	Fiber Handling
--]]
IOProcessor.getTaskID = function(self)
	self.TaskID = self.TaskID + 1;
	return self.TaskID;
end

IOProcessor.scheduleFiber = function(self, afiber, ...)
	if not afiber then
		return false, "no fiber specified"
	end

	afiber:setParams(...);
	self.TasksReadyToRun:Enqueue(afiber);	
	afiber.state = "readytorun"

	return afiber;
end

IOProcessor.spawn = function(self, aroutine, ...)
	--print("IOProcessor.spawn()", aroutine, ...);
	local task = SimpleFiber(aroutine)
	task.TaskID = self:getTaskID();
	self:scheduleFiber(task, ...);

	return task;
end

IOProcessor.removeFiber = function(self, fiber)
	--print("DROPPING DEAD FIBER: ", fiber);
	return true;
end

IOProcessor.inMainFiber = function(self)
	return coroutine.running() == nil; 
end

IOProcessor.getCurrentFiber = function(self)
	return self.CurrentFiber;
end

IOProcessor.yield = function(self, ...)
	return coroutine.yield(...);
end


IOProcessor.yieldForIo = function(self, socket, iotype, opid)
--print("== IOProcessor.yieldForIo: BEGIN: ", socket:getNativeSocket(), iotype, opid, self.CurrentFiber);

	-- Keep a list of fibers that are awaiting io
	self.EventFibers[opid] = self.CurrentFiber;
	if self.CurrentFiber ~= nil then
		self.FibersAwaitingEvent[self.CurrentFiber] = true;
		self.CurrentFiber.state = "suspended";
--print("== IOProcessor.yieldForIo: END: ")
		return self:yield();
	end

print("IOProcessor.yieldForIo:  NO CURRENT FIBER");

	return nil;
end


--[[
local function compareTaskDueTime(task1, task2)
	if task1.DueTime < task2.DueTime then
		return true
	end
	
	return false;
end

IOProcessor.yieldUntilTime = function(self, atime)
	--print("IOProcessor.yieldUntilTime: ", atime, self.Clock:Milliseconds())
	--print("Current Fiber: ", self.CurrentFiber)

	if self.CurrentFiber ~= nil then
		self.CurrentFiber.DueTime = atime;
		self.CurrentFiber.state = "suspended"
		tabutils.binsert(self.TasksWaitingForTime, self.CurrentFiber, compareTaskDueTime);

		return self:yield();
	end

	return false;
end

IOProcessor.yieldForTime = function(self, millis)
	local nextTime = self.Clock:Milliseconds() + millis;

	return self:yieldUntilTime(nextTime);
end

IOProcessor.stepTimeEvents = function(self)
	local currentTime = self.Clock:Milliseconds();

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
			self:scheduleFiber(fiber);

			-- Remove the fiber from the list of fibers that are
			-- waiting on time
			table.remove(self.TasksWaitingForTime, 1);
		end
	end
end
--]]

IOProcessor.processIOEvent = function(self, key, numbytes, overlapped)
	local ovl = ffi.cast("IOOverlapped *", overlapped);

	ovl.bytestransferred = numbytes;

	-- Find the waiting task that is waiting for this IO event
	-- this lookup needs to be sped up as it governs
	-- overall scheduling quanta
	local fiber = self.EventFibers[ovl.opcounter];

	if fiber then
		-- remove the task from the list of tasks that are
		-- waiting for an IO event
		self.FibersAwaitingEvent[fiber] = nil;

		-- remove the fiber from the index based on the
		-- IO eventid
		self.EventFibers[ovl.opcounter] = nil;

		-- schedule the fiber
		self:scheduleFiber(fiber, key, numbytes, overlapped);
	else
		print("IOProcessor.processIOEvent,NO FIBER WAITING FOR IO EVENT: ", ovl.opcounter)
	end

	return true;
end

IOProcessor.stepIOEvents = function(self)
	-- Check to see if there are any IO Events to deal with
	--local key, numbytes, overlapped = self.IOEventQueue:dequeue(self.MessageQuanta);
	local param1, param2, param3, param4, param5 = self.IOEventQueue:dequeue(self.MessageQuanta);

	local key, bytes, ovl

	-- First check to see if we've got a timeout
	-- if so, then just return immediately
	if not param1 then
		if param2 == WAIT_TIMEOUT then
			return true;
		end
		
		-- other errors that can occur at this point
		-- could either be iocp errors, or they could
		-- be socket specific errors
		-- If the error is ERROR_NETNAME_DELETED
		-- a socket has closed, so do something about it?
--[[
		if param2 == ERROR_NETNAME_DELETED then
			print("Processor.stepIOEvents(), ERROR_NETNAME_DELETED: ", param3);
		else
			print("Processor.stepIOEvents(), ERROR: ", param3, param2);
		end
--]]
		key = param3;
		bytes = param4;
		ovl = param5; 
	else
		key = param1;
		bytes = param2;
		ovl = param3;
	end

	local status, err = self:processIOEvent(key, bytes, ovl);

	return status, err;
end

IOProcessor.stepFibers = function(self)
	-- Now check the regular fibers
	local task = self.TasksReadyToRun:Dequeue()

	-- If no fiber in ready queue, then just return
	if task == nil then
		return true
	end

	if task:getStatus() == "dead" then
		print("IOProcessor, REMOVE stillborn task")
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
		--print("IOProcessor, DEAD coroutine, removing")
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

--[[
IOProcessor.getFibersWaitingOnTime = function(self)
	return #self.TasksWaitingForTime
end
--]]

IOProcessor.fibersAwaitIO = function(self)
	local fibersawaitio = false;


	for fiber in pairs(self.FibersAwaitingEvent) do
		fibersawaitio = true;
		break;
	end

	return fibersawaitio
end

-- returns an iterator of all the steps
-- to be executed per quanta
IOProcessor.addQuantaStep = function(self, astep)
	table.insert(self.QuantaSteps,astep)
end

IOProcessor.quantumSteps = function(self)

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

			-- We've made it through the list at least
			-- once, so check to see if there are still
			-- any tasks running
			if self:noMoreTasks() then
				self.ContinueRunning = false;
			end
		end

		return astep
	end

	return closure	
end


IOProcessor.noMoreTasks = function(self)
	if self.TasksReadyToRun:Len() < 1 and
--	self:getFibersWaitingOnTime() < 1 and
	not self:fibersAwaitIO() then 
		return true
	end

	return false;
end


IOProcessor.stop = function(self)
	self.ContinueRunning = false;
end

IOProcessor.start = function(self)
	self.ContinueRunning = true;

	--when(Functor(self.noMoreTasks,self), function() self.ContinueRunning = false; end);

	for astep in self:quantumSteps() do
		astep()

	end

	print("FINISHED STEP ITERATION")
end

IOProcessor.run = function(self, func, ...)
	if func ~= nil then
		self:spawn(func, ...);
	end

	self:addQuantaStep(Functor(self.stepIOEvents,self));
--	self:addQuantaStep(Functor(self.stepTimeEvents,self));
	self:addQuantaStep(Functor(self.stepFibers,self));

	self:start();
end

--[[
	Define some global functions
--]]

run = function(func, ...)
	return IOProcessor:run(func, ...);
end

spawn = function(func, ...)
	return IOProcessor:spawn(func, ...);
end

stop = function()
	return IOProcessor:stop();
end

--[[
sleep = function(millis)
	return IOProcessor:yieldForTime(millis)
end
--]]

yield = function(...)
	return IOProcessor:yield(...);
end



return IOProcessor

