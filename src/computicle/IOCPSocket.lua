
local ffi = require "ffi"

local ws2_32 = require("ws2_32");
local mswsock = require("mswsock");
local WinSock = require "WinSock_Utils"
local SocketUtils = require("SocketUtils");
local SocketOps = require("SocketOps");


ffi.cdef[[

typedef struct {
	SOCKET			sock;
} IOCPSocketHandle;
]]

IOCPSocketHandle = ffi.typeof("IOCPSocketHandle");
IOCPSocketHandle_mt = {
	__gc = function(self)
		print("GC: IOCPSocketHandle: ", self.sock);
		-- Force close on socket
		-- To ensure it's really closed
		local status = ws2_32.closesocket(self.sock);
	end,	
}
ffi.metatype(IOCPSocketHandle, IOCPSocketHandle_mt);


local IOCPSocket = {};
setmetatable(IOCPSocket, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local IOCPSocket_mt = {
	__index = IOCPSocket,
}

IOCPSocket.init = function(self, sock, iop)

	local obj = {
		SafeHandle = IOCPSocketHandle(sock),
		EventQueue = iop,
	};
	setmetatable(obj, IOCPSocket_mt);

	--obj:setNonBlocking(true);

	if iop then
		iop:observeSocketIO(obj);
	end

	return obj;
end

IOCPSocket.create = function(self, family, socktype, protocol, iop)
	family = family or AF_INET;
	socktype = socktype or SOCK_STREAM;
	protocol = protocol or 0;
	local lpProtocolInfo = nil;
	local group = 0;
	local dwFlags = WSA_FLAG_OVERLAPPED;


	-- Create the actual socket
	local sock = ws2_32.WSASocketA(family, socktype, protocol, lpProtocolInfo, group, dwFlags);
	--local sock = ws2_32.socket(family, socktype, protocol);
	
	if sock == INVALID_SOCKET then
		return nil, ws2_32.WSAGetLastError();
	end
				

	local socket, err = self:init(sock, iop);

	if not socket then
		return nil, err
	end

	return socket;
end

IOCPSocket.createClient = function(self, hostname, port, iop)
	local family = AF_INET;
	local socktype = SOCK_STREAM;
	local protocol = protocol or 0;


	-- Try to get an address for the hostname
	local addr, err = SocketUtils.CreateSocketAddress(hostname, port)

	if not addr then
		print("-- CreateTcpClientSocket() - could not create address: ", hostname, port)
		return nil, err
	end


	local socket, err = self:create(family, socktype, protocol, iop);


	if not socket then
		return nil, err
	end


	-- Connect to the host
	local status, err = socket:connectTo(addr);
	if not status then 
		return nil, err
	end

	return socket;
end

IOCPSocket.createServer = function(self, params, iop)
	params = params or {port = 80, backlog = 15, nonblocking=false, nodelay = false}
	params.backlog = params.backlog or 15
	params.port = params.port or 80

	local family = AF_INET;
	local socktype = SOCK_STREAM;
	local protocol = protocol or 0;

	local socket, err = self:create(family, socktype, protocol, iop);

	if not socket then
		return nil, err
	end


	-- Configure as server socket
	local success, err = socket:setNoDelay(params.nodelay);
	local success, err = socket:setReuseAddress(true);

	local addr = sockaddr_in(params.port);
	local addrlen = ffi.sizeof(addr);

	success, err = socket:bind(addr,addrlen)
	if not success then
		return nil, err
	end

	-- turn it into a 'listening' socket
	success, err = socket:makePassive(params.backlog);
	if not success then
		return nil, err
	end

	success, err = socket:setNonBlocking(params.nonblocking);

	return socket
end


IOCPSocket.getNativeSocket = function(self)
	return self.SafeHandle.sock;
end

IOCPSocket.getNativeHandle = function(self)
	return ffi.cast("HANDLE", ffi.cast("intptr_t", self.SafeHandle.sock));
end

--[[
	Setting various options
--]]
--
-- SetKeepAlive
-- Note: timeout and interval are in milliseconds
-- this is the proper way to set a keep alive on a per socket
-- basis.
IOCPSocket.setKeepAlive = function(self, keepalive, timeout, interval)
	timeout = timeout or 60*2*1000	-- two minutes
	interval = interval or 1*1000	-- one second

	local keeper = tcp_keepalive(1, timeout, interval);
	if not keepalive then
		keeper.onoff = 0;
	end
	local outbuffsize = ffi.sizeof(tcp_keepalive)
	local outbuff = ffi.new("uint8_t[?]", outbuffsize);
	local pbytesreturned = ffi.new("int32_t[1]")

	local success, err = WinSock.WSAIoctl(self:getNativeSocket(), SIO_KEEPALIVE_VALS, 
		keeper, ffi.sizeof(tcp_keepalive),
		outbuff, outbuffsize,
		pbytesreturned);

	return success, err
end

		IOCPSocket.setNoDelay = function(self, nodelay)
			local oneint = ffi.new("int[1]");
			if nodelay then
				oneint[0] = 1
			end

			return WinSock.setsockopt(self:getNativeSocket(), IPPROTO_TCP, TCP_NODELAY, oneint, ffi.sizeof(oneint))
		end
		
IOCPSocket.setNonBlocking = function(self, nonblocking)
	local oneint = ffi.new("int[1]");
	if nonblocking then
		oneint[0] = 1
	end

	return WinSock.ioctlsocket(self:getNativeSocket(), FIONBIO, oneint);
end
		
		IOCPSocket.setReuseAddress = function(self, reuse)
			local oneint = ffi.new("int[1]");
			if reuse then
				oneint[0] = 1
			end

			return WinSock.setsockopt(self:getNativeSocket(), SOL_SOCKET, SO_REUSEADDR, oneint, ffi.sizeof(oneint))
		end
		
		IOCPSocket.setExclusiveAddress = function(self, exclusive)
			local oneint = ffi.new("int[1]");
			if exclusive then
				oneint[0] = 1
			end

			return WinSock.setsockopt(self:getNativeSocket(), SOL_SOCKET, SO_EXCLUSIVEADDRUSE, oneint, ffi.sizeof(oneint))
		end
		
		--[[
			Reading Socket Options
		--]]
		IOCPSocket.getConnectionTime = function(self)
			local poptvalue = ffi.new('int[1]')
			local poptsize = ffi.new('int[1]',ffi.sizeof('int'))
			local size = ffi.sizeof('int')

			local success, err = WinSock.getsockopt(self:getNativeSocket(), SOL_SOCKET, SO_CONNECT_TIME, poptvalue, poptsize)
		
		--print("GetConnectionTime, getsockopt:", success, err)
			if not success then
				return nil, err
			end

			return poptvalue[0];		
		end

		IOCPSocket.getLastError = function(self)
			local poptvalue = ffi.new('int[1]')
			local poptsize = ffi.new('int[1]',ffi.sizeof('int'))
			local size = ffi.sizeof('int')

			local success, err = WinSock.getsockopt(self:getNativeSocket(), SOL_SOCKET, SO_ERROR, poptvalue, poptsize)
		
			if not success then
				return err
				--return nil, err
			end

			return poptvalue[0];
		end

--[[
			Connection Management
--]]
IOCPSocket.IsConnected = function(self)
	success, err = self:getConnectionTime()
	if success and success >= 0 then
		return true
	end

	return false
end

IOCPSocket.closeDown = function(self)
	--print("++++++++++   CLOSEDOWN ++++++++++")
	local success, err = WinSock.DisconnectEx(self:getNativeSocket(),nil,0,0);
	--print("DisconnectEx(): ", success, err);

	return WinSock.closesocket(self:getNativeSocket());
end

IOCPSocket.CloseDown = function(self)
	return self:closeDown();
end


IOCPSocket.forceClose = function(self)
	return WinSock.closesocket(self:getNativeSocket());
end
		
IOCPSocket.shutdown = function(self, how)
	how = how or SD_SEND
			
	return WinSock.shutdown(self:getNativeSocket(), how)
end


--[[

--]]
local opCounter = 0;

IOCPSocket.createOverlapped = function(self, buff, bufflen, operation)
	opCounter = opCounter + 1;
	local obj = ffi.new("SocketOverlapped");
	obj.sock = self:getNativeSocket();
	obj.operation = operation;
	obj.opcounter = IOProcessor:getNextOperationId();
	obj.Buffer = buff;
	obj.BufferLength = bufflen;

	return obj, opCounter;
end


--[[
	Client Socket Routines
--]]
IOCPSocket.connectTo = function(self, address)
	local name = ffi.cast("const struct sockaddr *", address)
	local namelen = ffi.sizeof(address)
	return WinSock.connect(self:getNativeSocket(), name, namelen);
end

--[[
	Server socket routines
--]]
IOCPSocket.makePassive = function(self, backlog)
	backlog = backlog or 5
	return WinSock.listen(self:getNativeSocket(), backlog)
end

IOCPSocket.accept = function(self)
	local family = AF_INET;
	local socktype = SOCK_STREAM;
	local protocol = 0;
	local lpProtocolInfo = nil;
	local group = 0;
	local dwFlags = WSA_FLAG_OVERLAPPED;


	local newsock = ws2_32.WSASocketA(family, socktype, protocol, lpProtocolInfo, group, dwFlags);
	if newsock == INVALID_SOCKET then
		return false, ws2_32.WSAGetLastError();
	end

	-- Now, construct up the accept call
	local sAcceptSocket = newsock;
	local dwReceiveDataLength = 0;
	local dwLocalAddressLength = ffi.sizeof("struct sockaddr_in")+16;
	local dwRemoteAddressLength = ffi.sizeof("struct sockaddr_in")+16;
	local lpOutputBufferLen = dwReceiveDataLength + dwLocalAddressLength + dwRemoteAddressLength;
	local lpOutputBuffer = ffi.new("char[?]", lpOutputBufferLen);
	local lpdwBytesReceived = ffi.new("DWORD[1]");

	local lpOverlapped = self:createOverlapped(lpOutputBuffer, lpOutputBufferLen, SocketOps.ACCEPT);

	local status = mswsock.AcceptEx(self:getNativeSocket(), sAcceptSocket, 
		lpOutputBuffer, 
		dwReceiveDataLength,
		dwLocalAddressLength,
		dwRemoteAddressLength,
		lpdwBytesReceived,
		ffi.cast("OVERLAPPED *", lpOverlapped));

	--print("IOCPSocket.accept: ", status);

	-- If the accept completes successfully, then 
	-- return the new socket
	if status ~= 0 then
		return newsock;
	end

	local err = ws2_32.WSAGetLastError();

	--print("  ERR: ", err);

	if err ~= WSA_IO_PENDING then
		return false, err;
	end

	-- If we've gotten this far, it means an accept was queued
	-- so we should yield, and we'll continue when completion is indicated
	if IOProcessor then    	
    	local status = IOProcessor:yieldForIo(self, SocketOps.ACCEPT, lpOverlapped.opcounter);

    	-- BUGBUG
    	-- check current state of socket
		--local bytestrans, flags = IOProcessor:getCompletionStatus(self:getNativeSocket(), lpOverlapped);
    	--print("Status after yield: ", bytestrans, flags);

    	-- if no error, then return the socket
     	return newsock;
    end

    return false, "No IOProcessor present";		
end
		
IOCPSocket.bind = function(self, addr, addrlen)
	return WinSock.bind(self:getNativeSocket(), addr, addrlen)
end

--[[
	Data Transport
--]]




IOCPSocket.send = function(self, buff, bufflen)
	bufflen = bufflen or #buff

	local lpBuffers = ffi.new("WSABUF", bufflen, ffi.cast("char *",buff));
	local dwBufferCount = 1;
	local lpNumberOfBytesSent = ffi.new("DWORD[1]");
	local dwFlags = 0;
	local lpOverlapped = self:createOverlapped(ffi.cast("uint8_t *",buff), bufflen, SocketOps.WRITE);
	local lpCompletionRoutine = nil;


	local status = ws2_32.WSASend(self:getNativeSocket(),
		lpBuffers,
		dwBufferCount,
		lpNumberOfBytesSent,
		dwFlags,
		ffi.cast("OVERLAPPED *",lpOverlapped),
		lpCompletionRoutine);

--print("IOCPSocket.send, WSASend status: ", status);

	-- if the return value is == 0, then the transfer
	-- to the network stack has already completed, so 
	-- return the number of bytes transferred.


-- Do the following if we want to handle
-- immediate success
	if status == 0 then
		print("#### IOCPSocket, WSASend STATUS == 0 ####")
		local bytestrans, flags = IOProcessor:getCompletionStatus(self:getNativeSocket(), lpOverlapped);
		if not bytestrans then
			return false, flags;
		end

		-- return the number of bytes transferred
		return bytestrans;
	end


	if status == SOCKET_ERROR then
		local err = ws2_32.WSAGetLastError();
		if err ~= WSA_IO_PENDING then
			print("    IOCPSocket.send, ERROR: ", err);
			return false, err;
		end
	end

    
    if IOProcessor then    	
    	local status = IOProcessor:yieldForIo(self, SocketOps.WRITE, lpOverlapped.opcounter);

    	-- BUGBUG
    	-- check current state of socket
    	-- of no error, then return the number of bytes read
    	return lpOverlapped.bytestransferred;
    end

	return false, err, "no ioprocessor present";
end



IOCPSocket.receive = function(self, buff, bufflen)

	local lpBuffers = ffi.new("WSABUF", bufflen, buff);
	local dwBufferCount = 1;
	local lpNumberOfBytesRecvd = ffi.new("DWORD[1]");
	local lpFlags = ffi.new("DWORD[1]");
	local lpOverlapped = self:createOverlapped(buff, bufflen, SocketOps.READ);
	local lpCompletionRoutine = nil;


	local status = ws2_32.WSARecv(self:getNativeSocket(),
    	lpBuffers,
    	dwBufferCount,
    	lpNumberOfBytesRecvd,
    	lpFlags,
    	ffi.cast("OVERLAPPED *",lpOverlapped),
    	lpCompletionRoutine);

--print("IOCPSocket.receive, WSARecv(), STATUS: ", status);

	-- if the return value is == 0, then the transfer
	-- to the network stack has already completed, so 
	-- return the number of bytes transferred.
	if status == 0 then
		print("#### IOCPSocket.WSARecv, STATUS == 0 ####");
		
		return lpNumberOfBytesRecvd[0];

--[[		
		local bytestrans, flags = IOProcessor:getCompletionStatus(self:getNativeSocket(), lpOverlapped);


		if not bytestrans then
			return false, flags;
		end

		-- return the number of bytes transferred
		return lpNumberOfBytesRecvd[0];
--]]
	else
		-- didn't get bytes immediately, so see if it's a 'pending'
		-- or some other error
		local err = ws2_32.WSAGetLastError();
	
    	if err ~= WSA_IO_PENDING then
        	return false, err;
    	end

    	-- BUGBUG
    	-- check current state of socket
    	-- of no error, then return the number of bytes read
		--local bytestrans, flags = IOProcessor:getCompletionStatus(self:getNativeSocket(), lpOverlapped);
 	end

    local status = IOProcessor:yieldForIo(self, SocketOps.READ, lpOverlapped.opcounter);

	local bytestrans, flags = IOProcessor:getCompletionStatus(self:getNativeSocket(), lpOverlapped);
	
	--print("    bytestrans, flags: ", bytestrans, flags);
	--print("receive, bytesReceived: ", bytesReceived);
    
    local bytesReceived = lpOverlapped.bytestransferred;
    
    return bytesReceived;
end




return IOCPSocket;