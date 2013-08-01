
local ffi = require("ffi");

local Collections = require("Collections");
local StopWatch = require("StopWatch");
local IOCPSocket = require("IOCPSocket");
local SimpleFiber = require("SimpleFiber");
local IOCompletionPort = require("IOCompletionPort");
local SocketOps = require("SocketOps");
local ws2_32 = require("ws2_32");
local WinError = require("win_error");
local core_synch = require("core_synch_l1_2_0");

local tabutils = require("tabutils");

IOProcessor = {
	Clock = StopWatch();
	fibers = Collections.Queue.new();
	coroutines = {};
	EventFibers = {};
	FibersAwaitingEvent = {};
	FibersAwaitingTime = {};

	ActiveSockets = {};

	IOEventQueue = IOCompletionPort:create();
	MessageQuanta = 10;		-- 15 milliseconds

	OperationId = 0;
};

IOProcessor.setMessageQuanta = function(self, millis)
--print("setMessageQuanta: ", millis);
	self.MessageQuanta = millis;
	return self;
end

--]]

IOProcessor.createClientSocket = function(self, hostname, port)
	local socket = IOCPSocket:createClient(hostname, port)
	
	-- see if we already think there is an active socket with the 
	-- native socket handle.
	-- if there is, it means that the socket was closed, but we never
	-- cleaned up the associated object.
	-- So, clean it up, before creating a new one.
	local alreadyActive = self.ActiveSockets[socket:getNativeSocket()];
	if alreadyActive then
		print("IOProcessor.createClientSocket(), ALREADY ACTIVE: ", socket:getNativeSocket());
		self.ActiveSockets[socket:getNativeSocket()] = nil;
	end

	-- add the socket to the active socket table
	self.ActiveSockets[socket:getNativeSocket()] = socket;

	return socket;
end

IOProcessor.createServerSocket = function(self, params)
	local socket = IOCPSocket:createServer(params)

	-- add the socket to the active socket table
	self.ActiveSockets[socket:getNativeSocket()] = socket;

	return socket;
end

IOProcessor.removeDeadSocket = function(self, sock)
	local socketentry = self.ActiveSockets[sock];
	if socketentry then
		print("REMOVING DEAD SOCKET: ", sock);
		self.ActiveSockets[sock] = nil;
	end

	return true;
end


IOProcessor.observeSocketIO = function(self, socket)
	return self.IOEventQueue:addIoHandle(socket:getNativeHandle(), socket:getNativeSocket());
end

IOProcessor.getCompletionStatus = function(self, sock, Overlapped)
	local lpcbTransfer = ffi.new("DWORD[1]");
	local Flags = ffi.new("DWORD[1]");

	local status = ws2_32.WSAGetOverlappedResult(sock,
		ffi.cast("OVERLAPPED *",Overlapped),
		lpcbTransfer,
        0, 
        Flags);

	--print(string.format("IOProcessor.getCompletionStatus: status(%d), sock(%d), bytes(%d), flags(%d)",
	--	status, sock, lpcbTransfer[0], Flags[0]));

	if status == 0 then
		local err = ws2_32.WSAGetLastError();
		print("    ERR: ", err);
		return false, err;
	end

	return lpcbTransfer[0], Flags[0];
end

IOProcessor.getNextOperationId = function(self)
	self.OperationId = self.OperationId + 1;
	return self.OperationId;
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
	--local keyhandle = ffi.cast("IOCPSocketHandle *", key);
	local ovl = ffi.cast("SocketOverlapped *", overlapped);
	local sock = ovl.sock;

	--print(string.format("IOProcessor.processIOEvent(): keysock(%d), ovlsock(%d), operation(%d), transid(%d), bytes(%d)", 
	--	key, ovl.sock, ovl.operation, ovl.opcounter, numbytes));


	-- an invalid socket can occur for a couple of reasons
	-- 1) The socket was intentionally set that way in the 
	--    overlap data.  this might be the case if some routine
	--    is trying to indicate the overlap is no longer relevant.

	--if sock == INVALID_SOCKET then
	--	print("IOProcessor.processIOEvent(), INVALID_SOCKET");
	--	return false, "invalid socket"
	--end

	-- Get the io completion data from the socket
	--local transferred, flags = self:getCompletionStatus(sock, ovl);

	-- if nothing was transferred, an error is indicated
	-- so, return that error
	--if not transferred then
	--	print("IOProcessor.processIOEvent(), TRANSFERRED == NIL, : ", flags);
	--	return false, flags;
	--end

	-- Find the waiting task that is waiting for this IO event
	ovl.bytestransferred = numbytes;

	local fiber = self.EventFibers[ovl.opcounter];
	if fiber then
		self:scheduleFiber(fiber, key, numbytes, overlapped);
		self.EventFibers[ovl.opcounter] = nil;
		self.FibersAwaitingEvent[fiber] = nil;
	else
		--local achar = string.format("0x%02x",ovl.Buffer[0]);
		local achar = ffi.string(ovl.Buffer, numbytes);
		print("IOProcessor.processIOEvent,NO FIBER WAITING FOR SOCKET EVENT: ", sock, achar)
		--self:removeDeadSocket(sock);
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
		if param2 == ERROR_NETNAME_DELETED then
			print("Processor.stepIOEvents(), ERROR_NETNAME_DELETED: ", param3);
		else
			print("Processor.stepIOEvents(), ERROR: ", param3, param2);
		end

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
	local nextTime = IOProcessor.Clock:Milliseconds() + millis;

--	print("IOProcessor:wait(): ", IOProcessor.Clock:Milliseconds(), millis)

	return IOProcessor:yieldUntilTime(nextTime);
end

yield = function()
	return IOProcessor:yield();
end


return IOProcessor

