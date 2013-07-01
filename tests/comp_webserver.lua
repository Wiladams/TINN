-- comp_webserver.lua

local Collections = require("Collections");
local IOProcessor = require("IOProcessor");
local SocketOps = require("SocketOps");
local IOCPSocket = require("IOCPSocket");
local IOCPSocketIo = require("IOCPSocketIo");
local NetStream = require ("NetStream");


local PreamblePending = Collections.Queue.new();

local HandleNewConnection = function(accepted)
			
	print("Accepted New Connection: ", accepted);
	local socket = IOCPSocket:init(accepted, IOProcessor);
	local netstream = NetStream.new(socket, IOCPSocketIo)
	PreamblePending:Enqueue(netstream);

--[[
	local res, err = accepted:SetNonBlocking(true);
	res, err = accepted:SetNoDelay(true);
	res, err = accepted:SetKeepAlive(true, 10*1000, 500);
--]]
end

-- Handle the case where the thread is idling
-- check to see if there are any requests pending
-- if there are, spawn a routine to deal with them.
OnIdle = function(counter)
	local netstream = PreamblePending:Dequeue();

	if netstream then
		if  netstream:IsConnected() then
			print("IsConnected")
			if HandleSingleRequest then
				print("HandleSingleRequest Defined")
				HandleSingleRequest(netstream);
				netstream:CloseDown();
			else
				print("HandleSingleRequest, NOT defined")
			end
			--self.Scheduler:Spawn(requestHandler, netstream, PreamblePending)
		else
			print("netstream disconnected")
		end
	end
end

-- Handle some inter computicle messages
OnMessage = function(msg)
	if msg.Message == SocketOps.ACCEPT then
		HandleNewConnection(msg.Param1);
	end
end

