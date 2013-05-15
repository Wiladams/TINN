
local Scheduler = require("EventScheduler");
local Collections = require("Collections");
local NetStream = require ("NetStream")
local SocketUtils = require ("SocketUtils")
local CoSocketIo = require("CoSocketIo")

local WebApp_t = {}
local WebApp_mt = {
	__index = WebApp_t;	
}

local WebApp = function(config)
	local obj = {
		Scheduler = Scheduler();
		config = config;
	}
	setmetatable(obj, WebApp_mt);

	return obj
end

WebApp_t.Run = function(self, requestHandler)

 	local PreamblePending = Collections.Queue.new();

	local HandlePendingRequests = function()
		while true do
			local netstream = PreamblePending:Dequeue();
			if netstream then
				if  netstream:IsConnected() then
					--print("IsConnected")
					self.Scheduler:Spawn(requestHandler, netstream, PreamblePending)
				else
					print("netstream disconnected")
				end
			end

			self.Scheduler:Yield();
		end
	end

	local HandleNewConnections = function()
	print("HandleNewConnections: ", self.config)

		local port = self.config.port or 8080
		local backlog = self.config.backlog or 10

		local Acceptor, err = SocketUtils.CreateTcpServerSocket({port = port, backlog = backlog, nonblocking=true, nodelay=true});

		if not Acceptor then
			print("Exiting Acceptor: ", err)
			return nil, err
		end

		
		while true do
			local accepted, err = CoSocketIo.Accept(Acceptor);
			if not accepted then
				return nil, err
			end
			
			print("Accepted New Connection")			
			-- create a stream to wrap the raw socket
			local res, err = accepted:SetNonBlocking(true);
			res, err = accepted:SetNoDelay(true);
			res, err = accepted:SetKeepAlive(true, 10*1000, 500);
			local netstream = NetStream.new(accepted, CoSocketIo)

			PreamblePending:Enqueue(netstream);

--[[
			local accepted, err = Acceptor:Accept();
			if accepted then	
				print("Accepted New Connection")			
				-- create a stream to wrap the raw socket
				local res, err = accepted:SetNonBlocking(true);
				res, err = accepted:SetNoDelay(true);
				res, err = accepted:SetKeepAlive(true, 10*1000, 500);
				local netstream = NetStream.new(accepted, CoSocketIo)

				PreamblePending:Enqueue(netstream);
			end

			if err and err ~= WSAEWOULDBLOCK then
				print("EXIT MAIN LOOP: ", err)
				break
			end

			coroutine.yield()
--]]
		end
	end

	self.Scheduler:Spawn(HandlePendingRequests);
	self.Scheduler:Spawn(HandleNewConnections);

	self.Scheduler:Start();
end

return WebApp
