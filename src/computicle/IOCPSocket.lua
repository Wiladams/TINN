
local ffi = require "ffi"

local ws2_32 = require("ws2_32");
local mswsock = require("mswsock");
local WinSock = require "WinSock_Utils"
local SocketUtils = require("SocketUtils");
local SocketOps = require("SocketOps");


ffi.cdef[[

typedef struct {
	SOCKET			sock;

	bool			autoClose;
} IOCPSocketHandle;
]]

IOCPSocketHandle = ffi.typeof("IOCPSocketHandle");
IOCPSocketHandle_mt = {
	__gc = function(self)
		print("GC: IOCPSocketHandle: ", self.sock, self.autoClose);
		-- Force close on socket
		-- To ensure it's really closed
		if self.autoClose then
			ws2_32.closesocket(self.sock);
		end
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

IOCPSocket.init = function(self, sock, autoclose)
	autoclose = autoclose or false;

	local obj = {
		SafeHandle = IOCPSocketHandle(sock, autoclose),
	};
	setmetatable(obj, IOCPSocket_mt);

	if IOProcessor then
		IOProcessor:observeSocketIO(obj);
	end

	return obj;
end


IOCPSocket.create = function(self, family, socktype, protocol, autoclose)
	family = family or AF_INET;
	socktype = socktype or SOCK_STREAM;
	protocol = protocol or 0;
	autoclose = autoclose or false;

	local lpProtocolInfo = nil;
	local group = 0;
	local dwFlags = WSA_FLAG_OVERLAPPED;


	-- Create the actual socket
	local sock = ws2_32.WSASocketA(family, socktype, protocol, lpProtocolInfo, group, dwFlags);
	--local sock = ws2_32.socket(family, socktype, protocol);
	
	if sock == INVALID_SOCKET then
		return nil, ws2_32.WSAGetLastError();
	end
				

	local socket, err = self:init(sock, autoclose);

	if not socket then
		return nil, err
	end

	return socket;
end

IOCPSocket.createClient = function(self, hostname, port)
print("IOCPSocket.createClient(): ", hostname, port);
	local family = AF_INET;
	local socktype = SOCK_STREAM;
	local protocol = protocol or 0;


	-- Try to get an address for the hostname
	local addr, err = SocketUtils.CreateSocketAddress(hostname, port)

	if not addr then
		print("-- CreateTcpClientSocket() - could not create address: ", hostname, port)
		return nil, err
	end


	local socket, err = self:create(family, socktype, protocol, autoclose);


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

IOCPSocket.createServer = function(self, params)
	autoclose = autoclose or false;

	params = params or {port = 80, backlog = 15, nonblocking=false, nodelay = false}
	params.backlog = params.backlog or 15
	params.port = params.port or 80
	params.autoclose = params.autoclose or false;

	local family = AF_INET;
	local socktype = SOCK_STREAM;
	local protocol = protocol or 0;

	local socket, err = self:create(family, socktype, protocol, params.autoclose);

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
	-- listen(sock);
	success, err = socket:makePassive(params.backlog);
	if not success then
		return nil, err
	end

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
IOCPSocket.setAutoClose = function(self, autoclose)
	autoclose = autoclose or false;
	self.SafeHandle.autoClose = autoclose;

	return self;
end

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
	--print("++++++++++   CLOSEDOWN ++++++++++", self:getNativeSocket())
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

IOCPSocket.createOverlapped = function(self, buff, bufflen, operation)
	local obj = ffi.new("SocketOverlapped");
	obj.sock = self:getNativeSocket();
	obj.operation = operation;
	obj.opcounter = IOProcessor:getNextOperationId();
	obj.Buffer = buff;
	obj.BufferLength = bufflen;

	return obj, obj.opcounter;
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
		local err = ws2_32.WSAGetLastError();
		print("IOCPSocket.accept(), WSASocketA ERR: ", err);
		return false, err
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

	--print("IOCPSocket.accept, AcceptEx(), STATUS: ", status);

	-- If the accept completes successfully, then 
	-- return the new socket
	if status ~= 0 then
		-- even though the indication is that we got a new socket
		-- the notification won't come until later, so treat both 
		-- cases as PENDING
		--return newsock;
	else
		local err = ws2_32.WSAGetLastError();

		--print("  IOCPSocket.accept(), ERR: ", err);

		if err ~= WSA_IO_PENDING then
			print("IOCPSocket.accept(), ERR, NOT == WSA_IO_PENDING: ", err);
			return false, err;
		end
	end

	-- If we've gotten this far, it means an accept was queued
	-- so we should yield, and we'll continue when completion is indicated
--print("++ IOCPSocket.accept(), before YIELD: ", IOProcessor, IOProcessor.yieldForIo);

   	local key, bytes, ovl = IOProcessor:yieldForIo(self, SocketOps.ACCEPT, lpOverlapped.opcounter);

--print("++ IOCPSocket.accept(), after YIELD: ", key, bytes, ovl);

    -- if no error, then return the socket
    return newsock;
end
		
IOCPSocket.bind = function(self, addr, addrlen)
	return WinSock.bind(self:getNativeSocket(), addr, addrlen)
end

IOCPSocket.bindToPort = function(self, port)
	local addr = sockaddr_in(port);
	local addrlen = ffi.sizeof(addr);

	return self:bind(addr,addrlen)
end


--[[
	Data Transport
--]]




IOCPSocket.send = function(self, buff, bufflen)
	bufflen = bufflen or #buff

	local lpBuffers = ffi.new("WSABUF", bufflen, ffi.cast("char *",buff));
	local dwBufferCount = 1;
	--local lpNumberOfBytesSent = ffi.new("DWORD[1]");
	local lpNumberOfBytesSent = nil;
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
		--print("#### IOCPSocket, WSASend STATUS == 0 ####")
		-- return the number of bytes transferred
		--return lpNumberOfBytesSent[0];
	else
		local err = ws2_32.WSAGetLastError();
		if err ~= WSA_IO_PENDING then
			print("    IOCPSocket.send, ERROR: ", err);
			return false, err;
		end
	end
    
    local key, bytes, ovl = IOProcessor:yieldForIo(self, SocketOps.WRITE, lpOverlapped.opcounter);

--print("WSASEND: ", key, bytes, ovl);

    -- BUGBUG
    -- check current state of socket
    -- of no error, then return the number of bytes read
    return bytes;
end

IOCPSocket.sendTo = function(self, lpTo, iTolen, buff, bufflen)
	if lpTo == nil then
		return false;
	end


	bufflen = bufflen or #buff

	local lpBuffers = ffi.new("WSABUF", bufflen, ffi.cast("char *",buff));
	local dwBufferCount = 1;
	local lpNumberOfBytesSent = nil;
	local dwFlags = 0;
	local lpOverlapped = self:createOverlapped(ffi.cast("uint8_t *",buff), bufflen, SocketOps.WRITE);
	local lpCompletionRoutine = nil;

	local status = ws2_32.WSASendTo(self:getNativeSocket(),
    	lpBuffers,
    	dwBufferCount,
    	lpNumberOfBytesSent,
    	dwFlags,
    	ffi.cast("const struct sockaddr *", lpTo),
    	iTolen,
    	ffi.cast("OVERLAPPED *",lpOverlapped),
    	lpCompletionRoutine);


	-- Do the following if we want to handle
	-- immediate success
	if status == 0 then
		--print("#### IOCPSocket, WSASend STATUS == 0 ####")
		-- return the number of bytes transferred
		--return lpNumberOfBytesSent[0];
	else
		local err = ws2_32.WSAGetLastError();
		if err ~= WSA_IO_PENDING then
			print("    IOCPSocket.send, ERROR: ", err);
			return false, err;
		end
	end
    
    local key, bytes, ovl = IOProcessor:yieldForIo(self, SocketOps.WRITE, lpOverlapped.opcounter);

--print("WSASEND: ", key, bytes, ovl);

    -- BUGBUG
    return bytes;
end




IOCPSocket.receive = function(self, buff, bufflen)

	local lpBuffers = ffi.new("WSABUF", bufflen, buff);
	local dwBufferCount = 1;
--	local lpNumberOfBytesRecvd = ffi.new("DWORD[1]");
	local lpNumberOfBytesRecvd = nil;
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
	-- to the network stack has already completed, 
	-- but the completion notification has not necessarily
	-- happened, so treat it the same as PENDING 
	if status == 0 then
		--print("#### IOCPSocket.WSARecv, STATUS == 0 ####");
		
		--return lpNumberOfBytesRecvd[0];
	else
		-- didn't get bytes immediately, so see if it's a 'pending'
		-- or some other error
		local err = ws2_32.WSAGetLastError();
	
    	if err ~= WSA_IO_PENDING then
    		print("IOCPSocket.WSARecv, ERROR: ", err);
        	return false, err;
    	end
    end

    local key, bytes, ovl = IOProcessor:yieldForIo(self, SocketOps.READ, lpOverlapped.opcounter);

--print("WSARECV: ", key, bytes, ovl);

    return bytes;
end


IOCPSocket.receiveFrom = function(self, lpFrom, fromLen, buff, bufflen)

	local lpBuffers = ffi.new("WSABUF", bufflen, buff);
	local dwBufferCount = 1;
--	local lpNumberOfBytesRecvd = ffi.new("DWORD[1]");
	-- if we're going to use io completion ports, then
	-- the numberOfBytesRecvd MUST be == nil
	local lpNumberOfBytesRecvd = nil;
	local lpFlags = ffi.new("DWORD[1]");
	local lpOverlapped = self:createOverlapped(buff, bufflen, SocketOps.READ);
	local lpCompletionRoutine = nil;
	local lpFromlen = ffi.new("DWORD[1]", fromLen);

	local status = ws2_32.WSARecvFrom(self:getNativeSocket(),
    	lpBuffers,
    	dwBufferCount,
    	lpNumberOfBytesRecvd,
    	lpFlags,
    	ffi.cast("struct sockaddr *", lpFrom),
    	lpFromlen,
    	ffi.cast("OVERLAPPED *",lpOverlapped),
    	lpCompletionRoutine);


--print("IOCPSocket.receive, WSARecv(), STATUS: ", status);

	-- if the return value is == 0, then the transfer
	-- to the network stack has already completed, 
	-- but the completion notification has not necessarily
	-- happened, so treat it the same as PENDING 
	if status == 0 then
		--print("#### IOCPSocket.WSARecv, STATUS == 0 ####");
		
		--return lpNumberOfBytesRecvd[0];
	else
		-- didn't get bytes immediately, so see if it's a 'pending'
		-- or some other error
		local err = ws2_32.WSAGetLastError();
	
    	if err ~= WSA_IO_PENDING then
    		print("IOCPSocket.WSARecv, ERROR: ", err);
        	return false, err;
    	end
    end

    local key, bytes, ovl = IOProcessor:yieldForIo(self, SocketOps.READ, lpOverlapped.opcounter);

--print("WSARecvFrom: ", key, bytes, ovl);

    return bytes;
end



return IOCPSocket;