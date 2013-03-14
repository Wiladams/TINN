
local ffi = require "ffi"

local wsock = require "win_socket"

-- Startup windows sockets
local SocketLib = ffi.load("ws2_32")

--[[
	Casual Macros
--]]

function IN4_CLASSA(i)
	return (band(i, 0x00000080) == 0)
end

function IN4_CLASSB(i)
	return (band(i, 0x000000c0) == 0x00000080)
end

function IN4_CLASSC(i)
	return (band(i, 0x000000e0) == 0x000000c0)
end

function IN4_CLASSD(i)
	return (band(i, 0x000000f0) == 0x000000e0)
end

IN4_MULTICAST = IN4_CLASSD


--[[
	Data Structures
--]]

IN_ADDR = ffi.typeof("struct in_addr");
IN_ADDR_mt = {
	__gc = function (self)
		print("-- IN_ADDR: GC");
	end,

	__tostring = function(self)
		local res = SocketLib.inet_ntoa(self)
		if res then
			return ffi.string(res)
		end

		return nil
	end,

	__index = {
		Assign = function(self, rhs)
		--print("IN_ADDR Assign: ", rhs.s_addr)
			self.S_addr = rhs.S_addr
			return self
		end,

		Clone = function(self)
			local obj = IN_ADDR(self.S_addr)
			return obj
		end,

	},
}
IN_ADDR = ffi.metatype(IN_ADDR, IN_ADDR_mt)


local families = {
	[AF_INET] = "AF_INET",
	[AF_INET6] = "AF_INET6",
	[AF_BTH] = "AF_BTH",
}

local socktypes = {
	[SOCK_STREAM] = "SOCK_STREAM",
	[SOCK_DGRAM] = "SOCK_DGRAM",
}

local protocols = {
	[IPPROTO_IP]  = "IPPROTO_IP",
	[IPPROTO_TCP] = "IPPROTO_TCP",
	[IPPROTO_UDP] = "IPPROTO_UDP",
	[IPPROTO_GGP] = "IPPROTO_GGP",
}


sockaddr_in = ffi.typeof("struct sockaddr_in")
sockaddr_in_mt = {
	__gc = function (self)
		--print("GC: sockaddr_in");
	end,

	__new = function(ct, port, family)
		port = tonumber(port) or 80
		family = family or AF_INET;
		
		local obj = ffi.new(ct)
		obj.sin_family = family;
		obj.sin_addr.S_addr = SocketLib.htonl(INADDR_ANY);
		obj.sin_port = SocketLib.htons(port);
		
		return obj
	end,
	
	__tostring = function(self)
		return string.format("Family: %s  Port: %d Address: %s",
			families[self.sin_family], SocketLib.ntohs(self.sin_port), tostring(self.sin_addr));
	end,

	__index = {
		SetPort = function(self, port)
			local portnum = tonumber(port);
			if not portnum then 
				return nil, "not a number"
			end
			
			self.sin_port = SocketLib.htons(tonumber(port));
		end,
	},
}
sockaddr_in = ffi.metatype(sockaddr_in, sockaddr_in_mt);

sockaddr_in6 = ffi.typeof("struct sockaddr_in6")
sockaddr_in6_mt = {
	__gc = function (self)
		print("-- sockaddr_in6: GC");
	end,

	__tostring = function(self)
		return string.format("Family: %s  Port: %d Address: %s",
			families[self.sin6_family], self.sin6_port, tostring(self.sin6_addr));
	end,

	__index = {
		SetPort = function(self, port)
			local portnum = tonumber(port);
			self.sin6_port = SocketLib.htons(portnum);
		end,
	},
}
sockaddr_in6 = ffi.metatype(sockaddr_in6, sockaddr_in6_mt);


sockaddr = ffi.typeof("struct sockaddr")
sockaddr_mt = {
	__index = {
	}
}
sockaddr = ffi.metatype(sockaddr, sockaddr_mt);


addrinfo = nil
addrinfo_mt = {
	__tostring = function(self)
		local family = families[self.ai_family]
		local socktype = socktypes[self.ai_socktype]
		local protocol = protocols[self.ai_protocol]

		--local family = self.ai_family
		local socktype = self.ai_socktype
		local protocol = self.ai_protocol


		local str = string.format("Socket Type: %s, Protocol: %s, %s", socktype, protocol, tostring(self.ai_addr));

		return str
	end,

	__index = {
		Print = function(self)
			print("-- AddrInfo ==")
			print("Flags: ", self.ai_flags);
			print("Family: ", families[self.ai_family])
			print("Sock Type: ", socktypes[self.ai_socktype]);
			print("Protocol: ", protocols[self.ai_protocol]);
			print("Canon Name: ", self.ai_canonname);
			--print("Addr Len: ", self.ai_addrlen);
			--print("Address: ", self.ai_addr);
			--print("Address Family: ", self.ai_addr.sa_family);
			local addr
			if self.ai_addr.sa_family == AF_INET then
				addr = ffi.cast("struct sockaddr_in *", self.ai_addr)
			elseif self.ai_addr.sa_family == AF_INET6 then
				addr = ffi.cast("struct sockaddr_in6 *", self.ai_addr)
			end
			print(addr);

			if self.ai_next ~= nil then
				self.ai_next:Print();
			end
		end,
	},
}
addrinfo = ffi.metatype("struct addrinfo", addrinfo_mt)




--[[
	BSD Style functions
--]]
local accept = function(s, addr, addrlen)
	local socket = SocketLib.accept(s,addr,addrlen);
	if socket == INVALID_SOCKET then
		return false, SocketLib.WSAGetLastError();
	end
	
	return socket;
end

local bind = function(s, name, namelen)
	if 0 == SocketLib.bind(s, ffi.cast("const struct sockaddr *",name), namelen) then
		return true;
	end
	
	return false, SocketLib.WSAGetLastError();
end

local connect = function(s, name, namelen)
	if 0 == SocketLib.connect(s, ffi.cast("const struct sockaddr *", name), namelen) then
		return true
	end
	
	return false, SocketLib.WSAGetLastError();
end

local closesocket = function(s)
	if 0 == SocketLib.closesocket(s) then
		return true
	end
	
	return false, SocketLib.WSAGetLastError();
end

local ioctlsocket = function(s, cmd, argp)
	if 0 == SocketLib.ioctlsocket(s, cmd, argp) then
		return true
	end
	
	return false, SocketLib.WSAGetLastError();
end

local listen = function(s, backlog)
	if 0 == SocketLib.listen(s, backlog) then
		return true
	end
	
	return false, SocketLib.WSAGetLastError();
end

local recv = function(s, buf, len, flags)
	len = len or #buf;
	flags = flags or 0;
	
	local bytesreceived = SocketLib.recv(s, ffi.cast("char*", buf), len, flags);

	if bytesreceived == SOCKET_ERROR then
		return false, SocketLib.WSAGetLastError();
	end
	
	return bytesreceived;
end

local send = function(s, buf, len, flags)
	len = len or #buf;
	flags = flags or 0;
	
	local bytessent = SocketLib.send(s, ffi.cast("const char*", buf), len, flags);

	if bytessent == SOCKET_ERROR then
		return false, SocketLib.WSAGetLastError();
	end
	
	return bytessent;
end

-- int getsockopt(SOCKET s, int level, int optname, char* optval,int* optlen);
local getsockopt = function(s, optlevel, optname, optval, optlen)
	if 0 == SocketLib.getsockopt(s, optlevel, optname, ffi.cast("char *",optval), optlen) then
		return true
	end
	
	return false, SocketLib.WSAGetLastError();
end

local setsockopt = function(s, optlevel, optname, optval, optlen)
	if 0 == SocketLib.setsockopt(s, optlevel, optname, ffi.cast("const uint8_t *", optval), optlen) then
		return true
	end
	
	return false, SocketLib.WSAGetLastError();
end

local shutdown = function(s, how)
	if 0 == SocketLib.shutdown(s, how) then
		return true
	end
	
	return false, SocketLib.WSAGetLastError();
end

local socket = function(af, socktype, protocol)
	af = af or AF_INET
	socktype = socktype or SOCK_STREAM
	protocol = protocol or IPPROTO_TCP
	
	local sock = SocketLib.socket(af, socktype, protocol);
	if sock == INVALID_SOCKET then
		return false, SocketLib.WSAGetLastError();
	end
	
	return sock;
end

--[[
	Windows Specific Socket routines
--]]
local WSAEnumProtocols = function()
	local lpiProtocols = nil;
	local dwBufferLen = 16384;
	local lpProtocolBuffer = ffi.cast("LPWSAPROTOCOL_INFOA", ffi.new("uint8_t[?]", dwBufferLen));	-- LPWSAPROTOCOL_INFO
	local lpdwBufferLength = ffi.new('int32_t[1]',dwBufferLen)
	local res = SocketLib.WSAEnumProtocolsA(lpiProtocols, lpProtocolBuffer, lpdwBufferLength);

	if res == SOCKET_ERROR then
		return false, SocketLib.WSAGetLastError();
	end

	local dwBufferLength = lpdwBufferLength[0];
	print("buffer length: ", dwBufferLength);

	return {infos = lpProtocolBuffer, count = res}
end


local WSAIoctl = function(s,
    dwIoControlCode,
    lpvInBuffer,cbInBuffer,
    lpvOutBuffer, cbOutBuffer,
    lpcbBytesReturned,
    lpOverlapped, lpCompletionRoutine)

	local res = SocketLib.WSAIoctl(s, dwIoControlCode, 
		lpvInBuffer, cbInBuffer,
		lpvOutBuffer, cbOutBuffer,
		lpcbBytesReturned,
		lpOverlapped,
		lpCompletionRoutine);

	if res == 0 then 
		return true
	end

	return false, SocketLib.WSAGetLastError();
end

local WSAPoll = function(fdArray, fds, timeout)
	local res = SocketLib.WSAPoll(fdArray, fds, timeout)
	
	if SOCKET_ERROR == res then
		return false, SocketLib.WSAGetLastError();
	end
	
	return res 
end

local WSASocket = function(af, socktype, protocol, lpProtocolInfo, g, dwFlags)
	af = af or AF_INET;
	socktype = socktype or SOCK_STREAM;
	protocol = protocol or 0;
	lpProtocolInfo = lpProtocolInfo or nil;
	g = g or 0;
	dwFlags = dwFlags or WSA_FLAG_OVERLAPPED;

	local socket = SocketLib.WSASocketA(af, socktype, protocol, lpProtocolInfo, g, dwFlags);
	
	if socket == INVALID_SOCKET then
		return false, SocketLib.WSAGetLastError();
	end

	return socket;
end


local GetExtensionFunctionPointer = function(funcguid)
--print("GetExtensionFunctionPointer: ", funcguid)

	local sock = WSASocket();

	local outbuffsize = ffi.sizeof("intptr_t")
	local outbuff = ffi.new("intptr_t[1]");
	local pbytesreturned = ffi.new("int32_t[1]")

	local success, err = WSAIoctl(sock, SIO_GET_EXTENSION_FUNCTION_POINTER, 
		funcguid, ffi.sizeof(funcguid),
		outbuff, outbuffsize,
		pbytesreturned);

	closesocket(sock);

	if not success then
		return false, err
	end

	return ffi.cast("void *", outbuff[0])
end


--[[
	Real convenience functions
--]]

local SocketErrors = {
	[0]					= {0, "SUCCESS",},
	[WSAEFAULT]			= {10014, "WSAEFAULT", "Bad Address"},
	[WSAEINVAL]			= {10022, "WSAEINVAL", },
	[WSAEWOULDBLOCK]	= {10035, "WSAEWOULDBLOCK", },
	[WSAEINPROGRES]		= {10036, "WSAEINPROGRES", },
	[WSAEALREADY]		= {10037, "WSAEALREADY", },
	[WSAENOTSOCK]		= {10038, "WSAENOTSOCK", },
	[WSAEAFNOSUPPORT]	= {10047, "WSAEAFNOSUPPORT", },
	[WSAECONNABORTED]	= {10053, "WSAECONNABORTED", },
	[WSAECONNRESET] 	= {10054, "WSAECONNRESET", },
	[WSAENOBUFS] 		= {10055, "WSAENOBUFS", },
	[WSAEISCONN]		= {10056, "WSAEISCONN", },
	[WSAENOTCONN]		= {10057, "WSAENOTCONN", },
	[WSAESHUTDOWN]		= {10058, "WSAESHUTDOWN", },
	[WSAETOOMANYREFS]	= {10059, "WSAETOOMANYREFS", },
	[WSAETIMEDOUT]		= {10060, "WSAETIMEDOUT", },
	[WSAECONNREFUSED]	= {10061, "WSAECONNREFUSED", },
	[WSAHOST_NOT_FOUND]	= {11001, "WSAHOST_NOT_FOUND", },
}

function GetSocketErrorString(err)
	if SocketErrors[err] then
		return SocketErrors[err][2];
	end
	return tostring(err)
end


local function GetLocalHostName()
	local name = ffi.new("char[255]")
	local err = SocketLib.gethostname(name, 255);

	return ffi.string(name)
end

--[[
	This startup routine must be called before any other functions
	within the library are utilized.
--]]

function WinsockStartup()
	local wVersionRequested = MAKEWORD( 2, 2 );

	local dataarrayname = string.format("%s[1]", wsock.wsadata_typename)
	local wsadata = ffi.new(dataarrayname)
    local retValue = SocketLib.WSAStartup(wVersionRequested, wsadata);
	wsadata = wsadata[0]

	return retValue, wsadata
end


-- Initialize the library
local err, wsadata = WinsockStartup()

-- Do whatever is needed after library initialization

--
-- Query for direct function call interfaces
--
local CAcceptEx, err = ffi.cast("LPFN_ACCEPTEX", GetExtensionFunctionPointer(WSAID_ACCEPTEX));
local CConnectEx, err = ffi.cast("LPFN_CONNECTEX", GetExtensionFunctionPointer(WSAID_CONNECTEX));
local CDisconnectEx, err = ffi.cast("LPFN_DISCONNECTEX", GetExtensionFunctionPointer(WSAID_DISCONNECTEX));


local DisconnectEx = function(sock, dwFlags, lpOverlapped)
	local success = CDisconnectEx(sock, nil,0,0);
	if success == 1 then
		return true;
	end

	return false, SocketLib.WSAGetLastError();
end


return {
	WSAData = wsadata,

	Lib = SocketLib,
	FFI = wsock,

	-- Data Structures
	IN_ADDR = IN_ADDR,
	sockaddr = sockaddr,
	sockaddr_in = sockaddr_in,
	sockaddr_in6 = sockaddr_in6,
	addrinfo = addrinfo,
	
	-- Library Functions
	accept = accept,
	bind = bind,
	connect = connect,
	closesocket = closesocket,
	ioctlsocket = ioctlsocket,
	listen = listen,
	recv = recv,
	send = send,
	setsockopt = setsockopt,
	getsockopt = getsockopt,
	shutdown = shutdown,
	socket = socket,
	
	-- Microsoft Extension Methods
	WSAIoctl = WSAIoctl,
	WSAPoll = WSAPoll,
	WSASocket = WSASocket,
	WSAEnumProtocols = WSAEnumProtocols,

	CAcceptEx = CAcceptEx;
	CConnectEx = CConnectEx;
	DisconnectEx = DisconnectEx;

	-- Helper functions
	GetLocalHostName = GetLocalHostName,
	GetSocketErrorString = GetSocketErrorString,

	-- Some constants
	families = families,
	socktypes = socktypes,
	protocols = protocols,
}
