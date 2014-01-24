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

	local success, err = socket:bind(addr,addrlen)
	if not success then
		return nil, err
	end

	local success, err = self:setPromiscuous(socket)

	if not success then
		return nil, err
	end


	local obj = {
		Socket = socket,
		PacketBuffer = ffi.new("uint8_t[64*1024]")
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
	local lpvInBuffer = ffi.new("DWORD[1]", 1)
	local cbInBuffer = ffi.sizeof(lpvInBuffer)

	local success, err = WinSock.WSAIoctl(
		socket:getNativeSocket(), 
		ws2_32.SIO_RCVALL, 
		lpvInBuffer, 
		cbInBuffer,
		nil, 
		outbuffsize,
		pbytesreturned);

	return success, err
end

function PacketSniffer.packets(self)
	local function closure()
		local bytesreceived, err = self.Socket:receive(self.PacketBuffer, 65536)

		if not bytesreceived then
			print("packets err: ", err)
			return nil, err;
		end

		return bytesreceived, self.PacketBuffer;
	end

	return closure
end

return PacketSniffer
