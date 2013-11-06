
local Collections = require "Collections"
local NetStream = require "NetStream"
local SocketUtils = require("SocketUtils")

local SocketPool_t = {}
local SocketPool_mt = {
	__index = SocketPool_t;
}

local SocketPool = function(params)
	params = params or {host="localhost", port=80, reserve=2, timeout=60*2, iocore = SocketUtils}

	local obj = {
		Connections = Collections.Queue();
		Hostname = params.host or "localhost";
		Port = tonumber(params.port) or 80;
		Reserve = params.reserve or 2;
		Timeout = params.timeout,
		IoCore = params.iocore,
	}
	setmetatable(obj, SocketPool_mt);

	obj:Cycle()

	return obj
end

function SocketPool_t:CreateNewConnection()
	local connection, err = NetStream.Open(self.Hostname, self.Port, self.IoCore)
--print("CreateNewConnection: ", self.Hostname, self.Port);

	if not connection then
		return nil, err
	end

	connection:SetIdleInterval(self.Timeout);

	self:AddConnection(connection);

	return connection
end

function SocketPool_t:CleanoutSockets()
	local qLen = self.Connections:Len()

	-- Check each connection to see if it's still connected
	-- and if it has run past its idle time
	while qLen > 0 do
		local connection = self.Connections:Dequeue()
		self:AddConnection(connection)

		qLen = qLen - 1
	end
end

function SocketPool_t:Cycle()
	self:CleanoutSockets();

	-- Fill back up to the reserve level
	while self.Connections:Len() < self.Reserve do
		local connection, err = self:CreateNewConnection()

		if not connection then
			print("SocketPool:Cycle(), FAILED to add new connection: ", err)
			return false, err
		end
	end

	return true
end

function SocketPool_t:AddConnection(connection)
	if not connection then
		return false, "nil connection"
	end
	
	if not connection:IsConnected() then
		return false, "connection not connected" 
	end

	if connection:IsIdle() then
		return false, "connection idle"
	end

	self.Connections:Enqueue(connection)

	return true
end

function SocketPool_t:GetConnection()
	self:Cycle();

	return self.Connections:Dequeue()
end

return SocketPool
