
local ffi = require "ffi"
local bit = require "bit"
local lshift = bit.lshift
local rshift = bit.rshift
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local bswap = bit.bswap


local ws2_32 = require("ws2_32");

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
	BSD Style functions
--]]
local accept = function(s, addr, addrlen)
	local socket = ws2_32.accept(s,addr,addrlen);
	if socket == INVALID_SOCKET then
		return false, ws2_32.WSAGetLastError();
	end
	
	return socket;
end

local bind = function(s, name, namelen)
	if 0 == ws2_32.bind(s, ffi.cast("const struct sockaddr *",name), namelen) then
		return true;
	end
	
	return false, ws2_32.WSAGetLastError();
end

local connect = function(s, name, namelen)
	if 0 == ws2_32.connect(s, ffi.cast("const struct sockaddr *", name), namelen) then
		return true
	end
	
	return false, ws2_32.WSAGetLastError();
end

local closesocket = function(s)
	if 0 == ws2_32.closesocket(s) then
		return true
	end
	
	return false, ws2_32.WSAGetLastError();
end

local ioctlsocket = function(s, cmd, argp)
	if 0 == ws2_32.ioctlsocket(s, cmd, argp) then
		return true
	end
	
	return false, ws2_32.WSAGetLastError();
end

local listen = function(s, backlog)
	if 0 == ws2_32.listen(s, backlog) then
		return true
	end
	
	return false, ws2_32.WSAGetLastError();
end

local recv = function(s, buf, len, flags)
	len = len or #buf;
	flags = flags or 0;
	
	local bytesreceived = ws2_32.recv(s, ffi.cast("char*", buf), len, flags);

	if bytesreceived == SOCKET_ERROR then
		return false, ws2_32.WSAGetLastError();
	end
	
	return bytesreceived;
end

local send = function(s, buf, len, flags)
	len = len or #buf;
	flags = flags or 0;
	
	local bytessent = ws2_32.send(s, ffi.cast("const char*", buf), len, flags);

	if bytessent == SOCKET_ERROR then
		return false, ws2_32.WSAGetLastError();
	end
	
	return bytessent;
end

local getsockopt = function(s, optlevel, optname, optval, optlen)
	if 0 == ws2_32.getsockopt(s, optlevel, optname, ffi.cast("char *",optval), optlen) then
		return true
	end
	
	return false, ws2_32.WSAGetLastError();
end

local setsockopt = function(s, optlevel, optname, optval, optlen)
	if 0 == ws2_32.setsockopt(s, optlevel, optname, ffi.cast("const uint8_t *", optval), optlen) then
		return true
	end
	
	return false, ws2_32.WSAGetLastError();
end

local shutdown = function(s, how)
	if 0 == ws2_32.shutdown(s, how) then
		return true
	end
	
	return false, ws2_32.WSAGetLastError();
end

local socket = function(af, socktype, protocol)
	af = af or AF_INET
	socktype = socktype or SOCK_STREAM
	protocol = protocol or IPPROTO_TCP
	
	local sock = ws2_32.socket(af, socktype, protocol);
	if sock == INVALID_SOCKET then
		return false, ws2_32.WSAGetLastError();
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
	local res = ws2_32.WSAEnumProtocolsA(lpiProtocols, lpProtocolBuffer, lpdwBufferLength);

	if res == SOCKET_ERROR then
		return false, ws2_32.WSAGetLastError();
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

	local res = ws2_32.WSAIoctl(s, dwIoControlCode, 
		lpvInBuffer, cbInBuffer,
		lpvOutBuffer, cbOutBuffer,
		lpcbBytesReturned,
		lpOverlapped,
		lpCompletionRoutine);

	if res == 0 then 
		return true
	end

	return false, ws2_32.WSAGetLastError();
end

local WSAPoll = function(fdArray, fds, timeout)
	local res = ws2_32.WSAPoll(fdArray, fds, timeout)
	
	if SOCKET_ERROR == res then
		return false, ws2_32.WSAGetLastError();
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

	local socket = ws2_32.WSASocketA(af, socktype, protocol, lpProtocolInfo, g, dwFlags);
	
	if socket == INVALID_SOCKET then
		return false, ws2_32.WSAGetLastError();
	end

	return socket;
end

--
-- MSWSock.h
--
WSAID_ACCEPTEX = GUID{0xb5367df1,0xcbac,0x11cf,{0x95,0xca,0x00,0x80,0x5f,0x48,0xa1,0x92}}
WSAID_CONNECTEX = GUID{0x25a207b9,0xddf3,0x4660,{0x8e,0xe9,0x76,0xe5,0x8c,0x74,0x06,0x3e}};
WSAID_DISCONNECTEX = GUID{0x7fda2e11,0x8630,0x436f,{0xa0, 0x31, 0xf5, 0x36, 0xa6, 0xee, 0xc1, 0x57}};


ffi.cdef[[
typedef BOOL
( * LPFN_ACCEPTEX)(
    SOCKET sListenSocket,
    SOCKET sAcceptSocket,
    PVOID lpOutputBuffer,
    DWORD dwReceiveDataLength,
    DWORD dwLocalAddressLength,
    DWORD dwRemoteAddressLength,
    LPDWORD lpdwBytesReceived,
    LPOVERLAPPED lpOverlapped
    );

typedef BOOL ( * LPFN_CONNECTEX) (
    SOCKET s,
    const struct sockaddr *name,
    int namelen,
    PVOID lpSendBuffer,
    DWORD dwSendDataLength,
    LPDWORD lpdwBytesSent,
    LPOVERLAPPED lpOverlapped);



typedef BOOL ( * LPFN_DISCONNECTEX) (
    SOCKET s,
    LPOVERLAPPED lpOverlapped,
    DWORD  dwFlags,
    DWORD  dwReserved);

]]

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
	local err = ws2_32.gethostname(name, 255);

	return ffi.string(name)
end

--[[
	This startup routine must be called before any other functions
	within the library are utilized.
--]]
local function MAKEWORD(low,high)
	return bor(low , lshift(high , 8))
end

function WinsockStartup()
	local wVersionRequested = MAKEWORD( 2, 2 );

	local wsadata = ffi.new("WSADATA");
    local status = ws2_32.WSAStartup(wVersionRequested, wsadata);
    if status ~= 0 then
    	return false, ws2_32.WSAGetLastError();
    end

	return true;
end


-- Initialize the library
local successfulStart = WinsockStartup();

-- Do whatever is needed after library initialization

--
-- Query for direct function call interfaces
--
local CAcceptEx, err = ffi.cast("LPFN_ACCEPTEX", GetExtensionFunctionPointer(WSAID_ACCEPTEX));
local CConnectEx, err = ffi.cast("LPFN_CONNECTEX", GetExtensionFunctionPointer(WSAID_CONNECTEX));
local CDisconnectEx, err = ffi.cast("LPFN_DISCONNECTEX", GetExtensionFunctionPointer(WSAID_DISCONNECTEX));

local AcceptEx = function(sock, 
	sListenSocket, 
	sAcceptSocket, 
	lpOutputBuffer, 
	dwReceiveDataLength,
	dwLocalAddressLength,
	dwRemoteAddressLength,
	lpOverlapped)


	dwReceiveDataLength = dwReceiveDataLength or 0;
	dwLocalAddressLength = dwLocalAddressLength or 0;
	dwRemoteAddressLength = dwRemoteAddressLength or 0;
	local lpdwBytesReceived = ffi.new("DWORD[1]");
	
	local status = CAppectEx(
	    sListenSocket,
	    sAcceptSocket,
	    lpOutputBuffer,
	    dwReceiveDataLength,
	    dwLocalAddressLength,
    	dwRemoteAddressLength,
    	lpdwBytesReceived,
    	lpOverlapped);

	if success == 1 then
		return true;
	end

	return false, ws2_32.WSAGetLastError();
end


local DisconnectEx = function(sock, dwFlags, lpOverlapped)
	local success = CDisconnectEx(sock, nil,0,0);
	if success == 1 then
		return true;
	end

	return false, ws2_32.WSAGetLastError();
end


return {
	SuccessfulStartup = successfulStart,

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

	AcceptEx = AcceptEx;
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
