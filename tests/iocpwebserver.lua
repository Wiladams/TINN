-- iocpwebserver.lua

local ffi = require("ffi");

local IOCompletionPort = require("IOCompletionPort");
local Computicle = require("Computicle");

local Scheduler = require("EventScheduler");
local Collections = require("Collections");
local NativeSocket = require("NativeSocket");
local NetStream = require ("NetStream")
local IOCPSocketIo = require("IOCPSocketIo");

local HttpRequest = require "HttpRequest"
local HttpResponse = require "HttpResponse"
local URL = require("url");
local StaticService = require("StaticService");

local sched = Scheduler();

-- Setup the notification queue that will be used for
-- general socket IO.
local notificationQueue = IOCompletionPort:create();

-- a queue used to indicate which sockets have
-- headers that are pending for reads
local PreamblePending = Collections.Queue.new();



-- Setup the computicles
-- Setup the socket acceptor computicle to send new
-- socket notifications to SELFICLE
local comp = Computicle:load("SocketAcceptor", {sink1=SELFICLE:getStoned()});

local HandleSingleRequest = function(stream, pendingqueue)
	local request, err  = HttpRequest.Parse(stream);

	if not request then
		print("HandleSingleRequest, Dump stream: ", err)
		return 
	end

	local urlparts = URL.parse(request.Resource)
	

	if urlparts.path == "/ping" then
		--print("echo")
		local response = HttpResponse.Open(stream)
		response:writeHead("204")
		response:writeEnd();
	else
		local filename = './wwwroot'..urlparts.path;
	
		local response = HttpResponse.Open(stream);

		StaticService.SendFile(filename, response)
	end

	-- recycle the stream in case a new request comes 
	-- in on it.
	return pendingqueue:Enqueue(stream)
end


local HandlePendingRequests = function()
	while true do
		local netstream = PreamblePending:Dequeue();
		if netstream then
			if  netstream:IsConnected() then
				sched:Spawn(HandleSingleRequest, netstream, PreamblePending)
			else
				print("netstream disconnected")
			end
		end

		sched:Yield();
	end
end

local HandleNewConnection = function(sock)
	print("HandleNewConnection: ", sock);

	-- create a new socket to wrap the sock
	local accepted = NativeSocket(sock);

	local iocp = IOCompletionPort:create(notificationQueue:getNativeHandle(), accepted:getNativeHandle());

	local res, err = accepted:SetNonBlocking(true);
	res, err = accepted:SetNoDelay(true);
	res, err = accepted:SetKeepAlive(true, 10*1000, 500);
	local netstream = NetStream.new(accepted, IOCPSocketIo)

	PreamblePending:Enqueue(netstream);
end



local HandleIncomingMessages = function()
	while true do
		local msg, err = SELFICLE:getMessage(15);
		if msg then
			msg = ffi.cast("ComputicleMsg *", msg);
			local sock = msg.Param1;
			SELFICLE:freeData(msg);

			HandleNewConnection(sock);
		else
			--print("NO MSG")
		end

		sched:Yield();
	end
end

sched:Spawn(HandleIncomingMessages);

sched:Start();
