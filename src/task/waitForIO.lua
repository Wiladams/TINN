-- waitForIO.lua

local ffi = require("ffi")
local Functor = require("Functor")
local IOCompletionPort = require("IOCompletionPort");
local arch = require("arch")



local waitForIO = {
	MessageQuanta = 10;
}
setmetatable(waitForIO, {
	__call = function(self, ...)
		return self:create(...)
	end,
})
local waitForIO_mt = {
	__index = waitForIO,
}


function waitForIO.init(self, scheduler)
	-- print("waitForIO.init, MessageQuanta: ", self.MessageQuanta)
	
	local obj = {
		Scheduler = scheduler;
		IOEventQueue = IOCompletionPort:create();
		FibersAwaitingEvent = {};
		EventFibers = {};

		MessageQuanta = self.MessageQuanta;		-- milliseconds
		OperationId = 0;
	}
	setmetatable(obj, waitForIO_mt)

	return obj;
end

function waitForIO.create(self, scheduler)
	scheduler = scheduler or self.Scheduler

	if not scheduler then
		return nil, "no scheduler specified"
	end

	return self:init(scheduler)
end

function waitForIO.setMessageQuanta(self, quanta)
	self.MessageQuanta = quanta;
end

function waitForIO.setScheduler(self, scheduler)
	self.Scheduler = scheduler;
end

function waitForIO.tasksArePending(self)
	local fibersawaitio = false;

	for fiber in pairs(self.FibersAwaitingEvent) do
		fibersawaitio = true;
		break;
	end

	return fibersawaitio
end


function waitForIO.getNextOperationId(self)
	self.OperationId = self.OperationId + 1;
	return self.OperationId;
end

function waitForIO.watchForIOEvents(self, handle, param)
	--print("waitForIO.observeIOEvent, adding: ", handle, param)

	return self.IOEventQueue:addIoHandle(handle, param);
end

function waitForIO.yield(self, socket, overlapped)
--print("== waitForIO.yield: BEGIN: ", arch.pointerToString(overlapped));

	local currentFiber = self.Scheduler:getCurrentFiber()

	if not currentFiber then
		print("waitForIO.yield:  NO CURRENT FIBER");
		return nil, "not currently running within a task"
	end

	-- Track the task based on the overlapped structure
	self.EventFibers[arch.pointerToString(overlapped)] = currentFiber;
	self.FibersAwaitingEvent[currentFiber] = true;
	
	return self.Scheduler:suspend()
end


function waitForIO.processIOEvent(self, key, numbytes, overlapped)
--print("waitForIO.processIOEvent: ", key, numbytes, arch.pointerToString(overlapped))

	local ovl = ffi.cast("IOOverlapped *", overlapped);

	ovl.bytestransferred = numbytes;

	-- Find the task that is waiting for this IO event
	local fiber = self.EventFibers[arch.pointerToString(overlapped)]

	if not fiber then
		return false, "waitForIO.processIOEvent,NO FIBER WAITING FOR IO EVENT: "
	end

	-- remove the task from the list of tasks that are
	-- waiting for an IO event
	self.FibersAwaitingEvent[fiber] = nil;

	-- remove the fiber from the index based on the
	-- overlapped structure
	self.EventFibers[arch.pointerToString(overlapped)] = nil;

	self.Scheduler:scheduleTask(fiber, key, numbytes, overlapped);

	return true;
end

function waitForIO.step(self)
	-- Check to see if there are any IO Events to deal with
	--local key, numbytes, overlapped = self.IOEventQueue:dequeue(self.MessageQuanta);
	local param1, param2, param3, param4, param5 = self.IOEventQueue:dequeue(self.MessageQuanta);

--print("waitForIO.step: ", param1, param2)

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

function waitForIO.start(self)
	while true do
		self:step();
		self.Scheduler:yield();
	end
end


return waitForIO
