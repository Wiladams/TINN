-- SocketAcceptor.lua

local ffi = require("ffi");

local Collections = require("Collections");
local NativeSocket = require("NativeSocket");
local WinSock_Utils = require("WinSock_Utils");
local WinBase = require("WinBase");
local SocketOps = require("SocketOps");

local ws2_32 = ffi.load("ws2_32");


local IOCompletionPort = require("IOCompletionPort");
local SocketUtils = require("SocketUtils");
local mswsock = require("mswsock");



-- Create a IOCP that will be used to receive
-- accept notifications
local acceptNotificationQueue = IOCompletionPort:create();

-- Create the socket that will listen for connection requests
listenSocket = SocketUtils.CreateTcpServerSocket({port = 8080, backlog = 2, nonblocking=true, nodelay = false});


-- Add the listening socket to the accept IOCP so that any activity
-- related to the socket is posted to the queuue
listenIOCP, err = IOCompletionPort:create(acceptNotificationQueue:getNativeHandle(), listenSocket:getNativeHandle());


-- Create the set of sockets that we'll be using with the AcceptEx call
-- however many are created here will be all that are available for
-- the lifetime of the service

socketsUsed = Collections.Queue.new("socketsUsed");
acceptsOutstanding = 0;

local maxSockets = 1;



-- post some pending accepts

local postAccept = function()
	local sListenSocket = listenSocket.Handle;

	local newSocket = NativeSocket();
	local overlap = ffi.new("SocketOverlapped");
	overlap.sock = newSocket.Handle;

	socketsUsed:Enqueue({socket = newSocket, overlap = overlap});


	local asock = setOfSockets:Dequeue();

	-- accept socket notifications
	if not asock then
		return false;
	end

	local sAcceptSocket = asock.socket.Handle;
	local dwReceiveDataLength = 0;
	local dwLocalAddressLength = ffi.sizeof("struct sockaddr_in")+16;
	local dwRemoteAddressLength = ffi.sizeof("struct sockaddr_in")+16;
	local lpOutputBuffer = ffi.new("char[?]", dwReceiveDataLength + dwLocalAddressLength + dwRemoteAddressLength);
	local lpdwBytesReceived = ffi.new("DWORD[1]");

	local status = mswsock.AcceptEx(sListenSocket, sAcceptSocket, 
		lpOutputBuffer, 
		dwReceiveDataLength,
		dwLocalAddressLength,
		dwRemoteAddressLength,
		lpdwBytesReceived,
		ffi.cast("OVERLAPPED *",asock.overlap));

	local err;

	if status == 0 then
		err = ws2_32.WSAGetLastError();
	end

	acceptsOutstanding = acceptsOutstanding + 1;
end

handleAccept = function(sock)
	-- decrement the accept count
	acceptsOutstanding = acceptsOutstanding - 1;
	
	if sink1 then
		sink1:postMessage(SocketOps.ACCEPT, sock);
	end


end


OnIdle = function(counter)
	if acceptsOutstanding < 1 then
		postBulkAccepts();
	end

	local key, bytestrans, overlapped = acceptNotificationQueue:dequeue(gIdleTimeout);	

	if key then
--		print(key, bytestrans, overlapped);
		overlapped = ffi.cast("SocketOverlapped *", overlapped);
		print("OVERLAPPED SOCKET: ", overlapped.sock);
		handleAccept(overlapped.sock);
	else
		if bytestrans ~= WAIT_TIMEOUT then
			print("ERROR: ", bytestrans);
			--exit();
		end
	end
end