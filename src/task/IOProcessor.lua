
local ffi = require("ffi");

local Collections = require("Collections");
local StopWatch = require("StopWatch");
local SimpleFiber = require("SimpleFiber");
local IOCompletionPort = require("IOCompletionPort");
local WinError = require("win_error");
local core_synch = require("core_synch_l1_2_0");
local IOOps = require("IOOps")

local tabutils = require("tabutils");


IOProcessor = {
	Clock = StopWatch();
	fibers = Collections.Queue();
	coroutines = {};
	EventFibers = {};
	FibersAwaitingEvent = {};
	FibersAwaitingTime = {};

	IOEventQueue = IOCompletionPort:create();
	MessageQuanta = 10;		-- milliseconds

	OperationId = 0;
};


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

IOProcessor.scheduleFiber = function(self, afiber, ...)
	if not afiber then
		return nil
	end

	afiber:setParams(...);
	self.coroutines[afiber.routine] = afiber;
	self.fibers:Enqueue(afiber);	

	return afiber;
end

IOProcessor.spawn = function(self, aroutine, ...)
	--print("IOProcessor.spawn()", aroutine, ...);
	return self:scheduleFiber(SimpleFiber(aroutine), ...);
end

IOProcessor.removeFiber = function(self, fiber)
	--print("DROPPING DEAD FIBER: ", fiber);
	self.coroutines[fiber.routine] = nil;
	return true;
end

IOProcessor.inMainFiber = function(self)
	return coroutine.running() == nil; 
end

IOProcessor.yield = function(self)
	return coroutine.yield();
end

IOProcessor.yieldForIo = function(self, socket, iotype, opid)
--print("== IOProcessor.yieldForIo: BEGIN: ", socket:getNativeSocket(), iotype, opid, self.CurrentFiber);

	-- Keep a list of fibers that are awaiting io
	self.EventFibers[opid] = self.CurrentFiber;
	if self.CurrentFiber ~= nil then
		self.FibersAwaitingEvent[self.CurrentFiber] = true;
--print("== IOProcessor.yieldForIo: END: ")
		return self:yield();
	end

print("IOProcessor.yieldForIo:  NO CURRENT FIBER");

	return nil;
end

local function compareTaskDueTime(task1, task2)
	if task1.DueTime < task2.DueTime then
		return true
	end
	
	return false;
end

IOProcessor.yieldUntilTime = function(self, atime)
	--print("IOProcessor.yieldUntilTime: ", atime, self.Clock:Milliseconds())

	if self.CurrentFiber ~= nil then
		self.CurrentFiber.DueTime = atime;
		tabutils.binsert(self.FibersAwaitingTime, self.CurrentFiber, compareTaskDueTime);

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
	local nAwaiting = #self.FibersAwaitingTime;
--print("Timer Events Waiting: ", nAwaiting)
	for i=1,nAwaiting do

		local fiber = self.FibersAwaitingTime[1];
		if fiber.DueTime <= currentTime then
			--print("ACTIVATE: ", fiber.DueTime, currentTime);
			-- put it back into circulation
			-- preferably at the front of the list
			fiber.DueTime = 0;
			self:scheduleFiber(fiber);

			-- Remove the fiber from the list of fibers that are
			-- waiting on time
			table.remove(self.FibersAwaitingTime, 1);
		end
	end
end


IOProcessor.processIOEvent = function(self, key, numbytes, overlapped)
	local ovl = ffi.cast("IOOverlapped *", overlapped);

	-- Find the waiting task that is waiting for this IO event
	ovl.bytestransferred = numbytes;

	local fiber = self.EventFibers[ovl.opcounter];
	if fiber then
		self:scheduleFiber(fiber, key, numbytes, overlapped);
		self.EventFibers[ovl.opcounter] = nil;
		self.FibersAwaitingEvent[fiber] = nil;
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
	local fiber = self.fibers:Dequeue()

	-- Take care of spawning a fiber first
	if fiber then
		if fiber:getStatus() ~= "dead" then

			-- If the fiber we pulled off the active list is 
			-- not dead, then set it as the currently running fiber
			-- and resume it.
			self.CurrentFiber = fiber;
			local results = {fiber:resume()};

			-- parse out the results of the resume into a success
			-- and the rest of the values returned from the resume
			local success = results[1];
			table.remove(results,1);

			self.CurrentFiber = nil;

			--print("SUCCESS: ", success);
			if not success then
				print("RESUME ERROR")
				print(unpack(results));
			end

			-- The scheduling strategy here is:
			--   if the fiber is dead, 
			--     then remove it from the list of live fibers 
			--     to be run
			--   if it's not dead, but waiting for IO
			--   or waiting for timer
			--     then don't put it in the running list
			if fiber:getStatus() == "dead" then
				--print("INNER FIBER DEAD")
				self:removeFiber(fiber)
			elseif  not self.FibersAwaitingEvent[fiber] then
				if fiber.DueTime and fiber.DueTime < self.Clock:Milliseconds() then
					self:scheduleFiber(fiber, results);
				end
			end
		else
			print("OUTER FIBER DEAD")
			self:removeFiber(fiber)
		end
	end
end

IOProcessor.step = function(self)
	self:stepTimeEvents();
	self:stepFibers();
	self:stepIOEvents();

	local fibersawaitio = false;


	for fiber in pairs(self.FibersAwaitingEvent) do
		fibersawaitio = true;
		break;
	end

	local fibersawaittime = #self.FibersAwaitingTime > 0

	--print("IOProcessor.step, fibersawaitio: ", fibersawaitio);
	
	if self.fibers:Len() < 1 and
		not fibersawaitio and
		not fibersawaittime then
		return false
	end

	return true;
end

IOProcessor.start = function(self)
	-- Run the IOProcessor loop
	self.ContinueRunning = true;

	while self.ContinueRunning do
	    if not IOProcessor:step() then
	    	break;
	    end
	    --core_synch.Sleep(5);
	end
end

IOProcessor.stop = function(self)
	self.ContinueRunning = false;
end

IOProcessor.run = function(self, func, ...)
--print("IOProcessor.run: ", self, func)
	if func ~= nil then
		self:spawn(func, ...);
	end

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

wait = function(millis)
	return IOProcessor:yieldForTime(millis)
end

yield = function()
	return IOProcessor:yield();
end


return IOProcessor

