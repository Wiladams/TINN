
local ffi = require("ffi");

local Collections = require "Collections"
local IOCPSocket = require("IOCPSocket");
local SimpleFiber = require("SimpleFiber");
local IOCompletionPort = require("IOCompletionPort");
local SocketOps = require("SocketOps");
local ws2_32 = require("ws2_32");

IOProcessor = {
	fibers = Collections.Queue.new();
	coroutines = {};
	EventFibers = {};
	FibersAwaitingEvent = {};

	IOEventQueue = IOCompletionPort:create();
	MessageQuanta = 15;		-- 15 milliseconds

	OperationId = 0;
};


--[[
	Socket Management
--]]

IOProcessor.createClientSocket = function(self, hostname, port)
	return IOCPSocket:createClient(hostname, port, self)
end

IOProcessor.createServerSocket = function(self, params)
	return IOCPSocket:createServer(params, self)
end


IOProcessor.observeSocketIO = function(self, socket)
	return self.IOEventQueue:addIoHandle(socket:getNativeHandle(), socket.SafeHandle);
end

IOProcessor.getCompletionStatus = function(self, sock, Overlapped)
	local lpcbTransfer = ffi.new("DWORD[1]");
	local Flags = ffi.new("DWORD[1]");

	local status = ws2_32.WSAGetOverlappedResult(sock,
		ffi.cast("OVERLAPPED *",Overlapped),
		lpcbTransfer,
        0, 
        Flags);

	if status == 0 then
		local err = ws2_32.WSAGetLastError();
		return false, err;
	end


	--print("IOProcessor.getCompletionStatus: ", status);
	--print("                   transferred: ", lpcbTransfer[0]);
	--print(string.format("                         Flags: 0x%x", Flags[0]));

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
	self.coroutines[afiber.routine] = afiber;
	self.fibers:Enqueue(afiber);	

	return afiber;
end

IOProcessor.spawn = function(self, aroutine, ...)
	--print("Spawn()", aroutine)
	return self:scheduleFiber(SimpleFiber(aroutine, ...));
end

IOProcessor.removeFiber = function(self, fiber)
	--print("DROPPING DEAD FIBER")
	self.coroutines[fiber.routine] = nil;
end

IOProcessor.inMainFiber = function(self)
	return coroutine.running() == nil; 
end

IOProcessor.yield = function(self)
	coroutine.yield();
end

IOProcessor.yieldForIo = function(self, sock, iotype, opid)

	-- associate a fiber with a socket
	--print("IOProcessor.yieldForIo, CurrentFiber: ", self.CurrentFiber);
	
	self.EventFibers[opid] = self.CurrentFiber;

	-- Keep a list of fibers that are awaiting io
	if self.CurrentFiber ~= nil then
		self.FibersAwaitingEvent[self.CurrentFiber] = true;

		self:yield();
	end
end




IOProcessor.processIOEvent = function(self, key, numbytes, overlapped)
	local ovl = ffi.cast("SocketOverlapped *", overlapped);
	local sock = ovl.sock;

	--print("IOProcessor.processIOEvent(): ", sock);
	--print("                   operation: ", ovl.operation);
	--print("                       bytes: ", numbytes);
	--print("                     counter: ", ovl.opcounter);


	-- an invalid socket can occur for a couple of reasons
	-- 1) The socket was intentionally set that way in the 
	--    overlap data.  this might be the case if some routine
	--    is trying to indicate the overlap is no longer relevant.

	if sock == INVALID_SOCKET then
		return false, "invalid socket"
	end

	-- Get the io completion data from the socket
	local transferred, flags = self:getCompletionStatus(sock, ovl);

	-- if nothing was transferred, an error is indicated
	-- so, return that error
	if not transferred then
		return false, flags;
	end

	-- Find the waiting task that is waiting for this IO event
	ovl.bytestransferred = numbytes;

	local fiber = self.EventFibers[ovl.opcounter];
	if fiber then
		self:scheduleFiber(fiber);
		self.EventFibers[ovl.opcounter] = nil;
		self.FibersAwaitingEvent[fiber] = nil;
	else
		--print("IOProcessor.processIOEvent, No task waiting to process.")
	end

	return true;
end

IOProcessor.stepIOEvents = function(self)
	-- Check to see if there are any IO Events to deal with
	local key, numbytes, overlapped = self.IOEventQueue:dequeue(self.MessageQuanta);

	--print("IO Event Queue: ", key, numbytes, overlapped);

	if key then
		local status, err = self:processIOEvent(key, numbytes, overlapped);
		--print("IOProcessor.stepIOEvents: ", status, err);
	end
end

IOProcessor.stepFibers = function(self)
	-- Now check the regular fibers
	local fiber = self.fibers:Dequeue()

	-- Take care of spawning a fiber first
	if fiber then
		if fiber.status ~= "dead" then
			self.CurrentFiber = fiber;
			local result, values = fiber:Resume();
			if not result then
				print("RESUME RESULT: ", result, values)
			end
			self.CurrentFiber = nil;

			if fiber.status ~= "dead" and not self.FibersAwaitingEvent[fiber] then
				self:scheduleFiber(fiber)
			else
				--print("FIBER FINISHED")
				--print("-- ",values)
				-- remove coroutine from dictionary
				self:removeFiber(fiber)
			end
		else
			self:removeFiber(fiber)
		end
	end
end

IOProcessor.step = function(self)
	self:stepFibers();
	self:stepIOEvents();
	
	local fibersawaitio = false;

	for fiber in pairs(self.FibersAwaitingEvent) do
		fibersawaitio = true;
		break;
	end

	if self.fibers:Len() < 1 and
		not fibersawaitio then
		return false
	end

	return true;
end

IOProcessor.run = function(self)
	-- Run the IOProcessor loop
	local continuerunning = true;

	while continuerunning do
	    continuerunning = IOProcessor:step();
	end
end


return IOProcessor

