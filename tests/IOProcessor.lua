
local ffi = require("ffi");

local Collections = require "Collections"
local IOCPSocket = require("IOCPSocket");
local SimpleFiber = require("SimpleFiber");
local IOCompletionPort = require("IOCompletionPort");
local SocketOps = require("SocketOps");


IOProcessor = {
	fibers = Collections.Queue.new();
	coroutines = {};
	EventFibers = {};
	FibersAwaitingEvent = {};

	IOEventQueue = IOCompletionPort:create();
	MessageQuanta = 15;		-- 15 milliseconds
};


--[[
	Socket Management
--]]

IOProcessor.createClientSocket = function(self, hostname, port)
	return IOCPSocket:createClient(hostname, port, self)
end

IOProcessor.createServerSocket = function(self, params)
	return IOCPSocket:createServerSocket(params, self)
end


IOProcessor.observeSocketIO = function(self, socket)
	return self.IOEventQueue:addIoHandle(socket:getNativeHandle(), socket.SafeHandle);
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
	--print("Spawn()")
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

IOProcessor.yieldForIo = function(self, sock, iotype)

	-- associate a fiber with a socket
	print("yieldForIo, CurrentFiber: ", self.CurrentFiber);
	
	self.EventFibers[sock:getNativeSocket()] = self.CurrentFiber;

	-- Keep a list of fibers that are awaiting io
	if self.CurrentFiber ~= nil then
		self.FibersAwaitingEvent[self.CurrentFiber] = true;

		-- Whether we were successful or not in adding the socket
		-- to the pool, perform a yield() so the world can move on.
		self:yield();
	end

end


IOProcessor.processIOEvent = function(self, key, numbytes, overlapped)
	local ovl = ffi.cast("SocketOverlapped *", overlapped);
	local sock = ovl.sock;
	ovl.bytestransferred = numbytes;
	if sock == INVALID_SOCKET then
		return false, "invalid socket"
	end

	--print("IOProcessor.processIOEvent(): ", sock, ovl.operation);

	local fiber = self.EventFibers[sock];
	if fiber then
		self:scheduleFiber(fiber);
		self.EventFibers[sock] = nil;
		self.FibersAwaitingEvent[fiber] = nil;
	else
		print("EventScheduler_t.ProcessEventQueue(), No Fiber waiting to process.")
		-- remove the socket from the watch list
	end
end

IOProcessor.stepIOEvents = function(self)
	-- Check to see if there are any IO Events to deal with
	local key, numbytes, overlapped = self.IOEventQueue:dequeue(self.MessageQuanta);

	--print("IO Event Queue: ", key, numbytes, overlapped);

	if key then
		self:processIOEvent(key, numbytes, overlapped);
	else
		--print("Event Pool ERROR: ", numbytes);
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

end


return IOProcessor

