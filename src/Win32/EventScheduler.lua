
local cocreate = coroutine.create
local resume = coroutine.resume
local yield = coroutine.yield
local costatus = coroutine.status

local Collections = require "Collections"

local SimpleFiber = require("SimpleFiber")
local SocketIoPool = require("SocketIoPool")

--[[
	EventScheduler
	The core routines related to managing fibers.
--]]
local EventScheduler_t = {}
local EventScheduler_mt = {
	__index = EventScheduler_t
}

--[[
	fibers - a queue of the fiber objects that are active
	coroutines - used to store a mapping between a coroutine
		and the fiber it is supporting.
--]]
local EventScheduler = function()
	local obj = {
		fibers = Collections.Queue.new();
		coroutines = {};

		ActiveFibers = 0,
		SpawnedFibers = 0,
		FinishedFibers = 0,

		IoEventPool = SocketIoPool(100);
		
		EventFibers = {};
		FibersAwaitingEvent = {};
	}
	setmetatable(obj, EventScheduler_mt)

	return obj
end

EventScheduler_t.ScheduleFiber = function(self, afiber)
	if not afiber then
		return nil
	end
	self.coroutines[afiber.routine] = afiber;
	self.fibers:Enqueue(afiber)	

	return afiber;
end

EventScheduler_t.Spawn = function(self, aroutine, ...)
	--print("Spawn()")
	self.SpawnedFibers = self.SpawnedFibers + 1;
	return self:ScheduleFiber(SimpleFiber(aroutine, ...));
end

EventScheduler_t.RemoveFiber = function(self, afiber)
	--print("DROPPING DEAD FIBER")
	self.coroutines[afiber.routine] = nil;
	self.FinishedFibers = self.FinishedFibers + 1;
end

EventScheduler_t.InMainFiber = function(self)
	return coroutine.running() == nil; 
end

EventScheduler_t.Yield = function(self)
	yield();
end

EventScheduler_t.YieldForIo = function(self, sock, iotype)
--print("EventScheduler_t.YieldForIo()");
--print("-- Current Fiber: ", self.CurrentFiber);

	-- Try to add the socket to the event pool
	local success, err = self.IoEventPool:AddSocket(sock, iotype)

	if success then
		-- associate a fiber with a socket
		self.EventFibers[sock.Handle] = self.CurrentFiber;

		-- Keep a list of fibers that are awaiting io
		self.FibersAwaitingEvent[self.CurrentFiber] = true;
	else
		-- failed to add socket to event pool
	end

	-- Whether we were successful or not in adding the socket
	-- to the pool, perform a yield() so the world can move on.
	yield();
end


EventScheduler_t.ProcessEventQueue = function(self, queue)
	for i=1,queue:Len() do
		local sock = queue:Dequeue();

		if sock then
			--print("ProcessEventQueue(): ", string.format("0x%x",sock.fdarray.revents));

			local fiber = self.EventFibers[sock.Handle];
			if fiber then
				self:ScheduleFiber(fiber);
				self.EventFibers[sock.Handle] = nil;
				self.FibersAwaitingEvent[fiber] = nil;
				self.IoEventPool:RemoveSocket(sock);
			else
				print("EventScheduler_t.ProcessEventQueue(), No Fiber waiting to process.")
				-- remove the socket from the watch list
			end
		else
			print("EventScheduler_t.ProcessEventQueue(), No sock found in queue");
		end
	end
end

EventScheduler_t.Start =  function(self)
	self.ContinueRunning = true;
	local ioeventqueue = Collections.Queue.new();

	while self.ContinueRunning do
		-- First check if there are any io events
		local success, err = self.IoEventPool:Cycle(ioeventqueue, 0);
		--print("Event Pool: ", success, err, ioeventqueue:Len())
		if success  then
			if success > 0 then
				-- schedule the io operations
				self:ProcessEventQueue(ioeventqueue);
			end
		else
			--print("Event Pool ERROR: ", err);
		end

		-- Now check the regular fibers
		local fiber = self.fibers:Dequeue()

		if fiber then
			if fiber.status ~= "dead" then
				self.CurrentFiber = fiber;
				local result, values = fiber:Resume();
				if not result then
					print("RESUME RESULT: ", result, values)
				end
				self.CurrentFiber = nil;

				if fiber.status ~= "dead" and not self.FibersAwaitingEvent[fiber] then
					self:ScheduleFiber(fiber)
				else
					--print("FIBER FINISHED")
					--print("-- ",values)
					-- remove coroutine from dictionary
					self:RemoveFiber(fiber)
				end
			else
				self:RemoveFiber(fiber)
			end
		end
		
		--if not self:InMainFiber() then
		--	yield();
		--end
	end
end

EventScheduler_t.Stop =  function(self)
	self.ContinueRunning = false;
end

return EventScheduler

