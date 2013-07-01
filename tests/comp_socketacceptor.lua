-- comp_socketacceptor.lua

local ffi = require("ffi");

local WinBase = require("WinBase");
local SocketOps = require("SocketOps");

local ws2_32 = require("ws2_32");

local IOCompletionPort = require("IOCompletionPort");
local IOCPSocket = require("IOCPSocket");
local mswsock = require("mswsock");


-- Create a IOCP that will be used to receive
-- accept notifications
local acceptNotificationQueue = IOCompletionPort:create();

-- Create the socket that will listen for connection requests
if _params then
	port = _params.port or 8080;
	backlog = _params.backlog or 10;
else
	port = 8080;
	backlog = 10;
end

listenSocket, err = IOCPSocket:createServer({port = port, backlog = backlog, nonblocking=true, nodelay = false});


-- Add the listening socket to the accept IOCP so that any activity
-- related to the socket is posted to the queuue
listenIOCP, err = acceptNotificationQueue:addIoHandle(listenSocket:getNativeHandle(), listenSocket.SafeHandle);

-- Create the set of sockets that we'll be using with the AcceptEx call
-- however many are created here will be all that are available for
-- the lifetime of the service

acceptsOutstanding = 0;



local sListenSocket = listenSocket:getNativeSocket();
socketsUsed = {};



local postAccept = function()
--print("postAccept")
	-- Each new accept must have a socket that is already 
	-- constructed standing by, so create that socket
	local newSocket = IOCPSocket();

	if not newSocket then
		return false, "could not create new socket";
	end

	local overlap = ffi.new("SocketOverlapped");
	overlap.sock = newSocket:getNativeSocket();

	local socketEntry = {socket = newSocket, overlap = overlap};
	socketsUsed[newSocket:getNativeSocket()] = socketEntry;


	-- Now, construct up the accept call
	local sAcceptSocket = newSocket:getNativeSocket();
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
		ffi.cast("OVERLAPPED *",socketEntry.overlap));

	local err;

	if status == 0 then
		err = ws2_32.WSAGetLastError();
		if err ~= WSA_IO_PENDING then
			return false, err;
		end
	end

	-- if we got to here, the socket was accepted

	acceptsOutstanding = acceptsOutstanding + 1;

	return socketEntry;
end

handleAccept = function(sock)
	-- decrement the accept count
	--print("handleAccept: ", sock);

	acceptsOutstanding = acceptsOutstanding - 1;
	
	if sink1 then
		sink1:postMessage(SocketOps.ACCEPT, sock);
	end
end


OnIdle = function(counter)
	local sockEntry = nil;

	if acceptsOutstanding < 1 then
		sockEntry, err = postAccept();
		if not sockEntry then
			print("postAccept, ERROR: ", err);
			exit();
			return;
		end
	end

-- gIdleTimeout
	local key, bytestrans, overlapped = acceptNotificationQueue:dequeue();	

	if key then
		--print(key, bytestrans, overlapped);
		overlapped = ffi.cast("SocketOverlapped *", overlapped);
		--print("OVERLAPPED SOCKET: ", overlapped.sock);
		handleAccept(overlapped.sock);
	else
		if bytestrans ~= WAIT_TIMEOUT then
			print("ERROR: ", bytestrans);
			--exit();
		end
	end
end