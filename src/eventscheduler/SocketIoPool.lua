
local ffi = require("ffi");
local bit = require("bit")
local band = bit.band
local bor = bit.bor

local WinSock = require("WinSock_Utils");


local SocketIoPool_t = {}
local SocketIoPool_mt = {
	__index = SocketIoPool_t,
}

local SocketIoPool = function(capacity)
	capacity = capacity or 1
	
	if capacity < 1 then return nil end

	local obj = {
		fdarray = ffi.new("WSAPOLLFD[?]", capacity);

		Capacity = capacity,	-- How many slots are available
		Handles = {},
		Sockets = {},
	}
	setmetatable(obj, SocketIoPool_mt);

	obj:ClearAllSlots();

	return obj
end

SocketIoPool_t.ClearSlot = function(self, slotnumber)
	if not slotnumber or slotnumber < 0 or slotnumber >= self.Capacity then
		return false
	end

	self.fdarray[slotnumber].fd = -1;
	self.fdarray[slotnumber].events = 0;
	self.fdarray[slotnumber].revents = -1;

	return true
end

SocketIoPool_t.ClearAllSlots = function(self)
	for i=1,self.Capacity do
		self:ClearSlot(i-1);
	end
end

SocketIoPool_t.GetOpenSlot = function(self)
	-- traverse each of the slots in the array
	for i=0, self.Capacity-1 do
		if self.fdarray[i].fd < 0 then
			return i
		end
	end

	return nil, "no open slots"
end


SocketIoPool_t.AddSocket = function(self, sock, events)
	local slot, err = self:GetOpenSlot()
--print("AddSocket, slot: ", slot, err)
	if not slot then 
		return nil, err
	end

--print("SocketIoPool:AddSocket(): ", string.format("0x%x", events));

	events = events or bor(POLLWRNORM, POLLIN);

	self.fdarray[slot].fd = sock.Handle;
	self.fdarray[slot].events = events;
	self.fdarray[slot].revents = 0;

	self.Handles[sock.Handle] = sock;
	self.Sockets[sock.Handle] = slot;

	return slot
end

SocketIoPool_t.RemoveSocket = function(self, sock)
	-- remove the associated handle
	self.Handles[sock.Handle] = nil;
	
	-- remove the associated socket
	self:ClearSlot(self.Sockets[sock.Handle]);

	self.Sockets[sock.Handle] = nil;
end


SocketIoPool_t.Cycle = function(self, eventqueue, timeout)
	timeout = timeout or 0

	local success, err = WinSock.WSAPoll(self.fdarray, self.Capacity, timeout);

--print("Cycle: ", success, err, timeout);

	if not success then
		return nil, err
	end

	-- Go through each of the slots looking
	-- for the sockets that are ready for activity
	for i=0, self.Capacity-1 do
		if self.fdarray[i].fd > 0 then
			if self.fdarray[i].revents > 0 then
				self.Handles[self.fdarray[i].fd].fdarray.revents = self.fdarray[i].revents;
				eventqueue:Enqueue(self.Handles[self.fdarray[i].fd]);
				self.fdarray[i].revents = 0;
			end
		end
	end

	return success
end


return SocketIoPool