-- SocketAcceptor.lua

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



ffi.cdef[[
typedef struct {
	HANDLE HeapHandle;
	HANDLE IOCPHandle;
	HANDLE ThreadHandle;
} Computicle_t;

]]


-- Get the parameter that represents the sink for our messages
local stone1 = ffi.cast("Computicle_t *", _params.sink1);
local sink1 = Computicle:init(stone1.HeapHandle, stone1.IOCPHandle, stone1.ThreadHandle);

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

setOfSockets = Collections.Queue.new("setOfSockets");

local maxSockets = 5;

for i=1,maxSockets do
	local newSocket = NativeSocket();
	local overlap = ffi.new("SocketOverlapped");
	overlap.sock = newSocket.Handle;

	setOfSockets:Enqueue({socket = newSocket, overlap = overlap});
end


-- post some pending accepts
local postBulkAccepts = function()
	local sListenSocket = listenSocket.Handle;

	-- accept socket notifications
	while true do
		local asock = setOfSockets:Dequeue();

		if not asock then
			break;
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
			err = SocketLib.WSAGetLastError();
		end

		print("POSTED ACCEPT: ", status, err);
	end
end


-- Spin forever looking for accept notifications
-- coming from the queue
while true do
	postBulkAccepts();

	local key, bytestrans, overlapped = acceptNotificationQueue:dequeue();	

	if key then
--		print(key, bytestrans, overlapped);
		overlapped = ffi.cast("SocketOverlapped *", overlapped);
		print("OVERLAPPED SOCKET: ", overlapped.sock);

		if sink1 then
			sink1:receiveMessage(SocketOps.ACCEPT, overlapped.sock);
		end
	else
		print("ERROR: ", bytestrans);
	end
end