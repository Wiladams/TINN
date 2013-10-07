-- SocketResponder.lua

local ffi = require("ffi");

local Collections = require("Collections");
local IOCompletionPort = require("IOCompletionPort");
local SocketUtils = require("SocketUtils");
local NativeSocket = require("NativeSocket");
local WinSock_Utils = require("WinSock_Utils");
local WinBase = require("WinBase");
local mswsock = require("mswsock");
local SocketOps = require("SocketOps");

local SocketLib = ffi.load("ws2_32")




-- Get the parameter that represents the sink for our messages
local stone1 = ffi.cast("Computicle_t *", _params.sink1);
local sink1 = Computicle:init(stone1.HeapHandle, stone1.IOCPHandle, stone1.ThreadHandle);

-- Create a IOCP that will be used to receive
-- accept notifications
local notificationQueue = IOCompletionPort:create();

-- Create the socket that will listen for connection requests
listenSocket = SocketUtils.CreateTcpServerSocket({port = 8080, backlog = 2, nonblocking=true, nodelay = false});


-- Add the listening socket to the accept IOCP so that any activity
-- related to the socket is posted to the queuue
listenIOCP, err = IOCompletionPort:create(acceptNotificationQueue:getNativeHandle(), listenSocket:getNativeHandle());



-- Spin forever looking for accept notifications
-- coming from the queue
while true do
	-- check to see if there are any notifications
	-- related to the sockets we're watching
	local key, bytestrans, overlapped = notificationQueue:dequeue(10);	

	if key then
--		print(key, bytestrans, overlapped);
		overlapped = ffi.cast("SocketOverlapped *", overlapped);
		print("OVERLAPPED SOCKET: ", overlapped.sock);

		if sink1 then
			sink1:postMessage(SocketOps.ACCEPT, overlapped.sock);
		end
	else
		print("ERROR: ", bytestrans);
	end


	-- check to see if there are any new sockets coming in that we 
	-- need to start monitoring
	local msg = SELFICLE:getMessage();
	
end