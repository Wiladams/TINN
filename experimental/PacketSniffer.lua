local ffi = require("ffi")

local NativeSocket = require("NativeSocket")
local WinSock = require "WinSock_Utils"
local Network = require("Network")
local ws2_32 = require("ws2_32")

local PacketSniffer = {}
setmetatable(PacketSniffer, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local PacketSniffer_mt = {
	__index = PacketSniffer,
}

function PacketSniffer.init(self, addr, addrlen)
	local socket, err = NativeSocket(AF_INET, SOCK_RAW, IPPROTO_IP);

	if not socket then
		return nil, err
	end

	success, err = socket:bind(addr,addrlen)
	if not success then
		return nil, err
	end

	self:setPromiscuous(socket)

	local obj = {
		Socket = socket,
	}
	setmetatable(obj, PacketSniffer_mt)

	return obj;
end

function PacketSniffer.create(self, interface)
	interface = interface or Network:GetLocalAddress();
	print("Local Interface: ", interface)

	local addr = sockaddr_in(0);
	local addrlen = ffi.sizeof(addr);
	addr.sin_addr.S_addr = ws2_32.inet_addr(interface);

	return self:init(addr, addrlen);
end

function PacketSniffer.setPromiscuous(self, socket)
	local outbuffsize = 0;
	local pbytesreturned = ffi.new("int32_t[1]")

	local success, err = WinSock.WSAIoctl(
		socket:getNativeSocket(), 
		SIO_RCVALL, 
		nil, 
		0,
		nil, 
		outbuffsize,
		pbytesreturned);

end

return PacketSniffer
