-- UdpListener.lua

local ffi = require("ffi");
local IOCPSocket = require("IOCPSocket");
local SocketUtils = require("SocketUtils")
local Network = require("Network")


local UdpListener = {}
setmetatable(UdpListener, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local UdpListener_mt = {
	__index = UdpListener;
}

UdpListener.init = function(self, socket)
	local obj = {
		Socket = socket
	}
	setmetatable(obj, UdpListener_mt)

	return obj;
end

UdpListener.create = function(self, port)
	if not port then
		return nil, 'no port specified'
	end

    local socket, err = IOCPSocket:create(AF_INET, SOCK_DGRAM, 0);
    if not socket then
      return nil, err;
    end

    local success, err = socket:bindToPort(port);

    if not success then
      return nil, err;
    end

    return self:init(socket)
end


UdpListener.run = function(self, callback, buff, bufflen)
	if not buff then
		bufflen = 1500;
		buff = ffi.new("uint8_t[1500]");
	else
		bufflen = bufflen or #buff
	end

    local from = sockaddr_in();
    local fromLen = ffi.sizeof(from);

    local loop = function()
      while true do
        local bytesread, err = self.Socket:receiveFrom(from, fromLen, buff, bufflen);

        if not bytesread then
          --print("receiveFrom ERROR: ", err)
          return false, err;
        end

        if callback ~= nil then
        	callback(buff, bytesread)
        end
      end
    end

    spawn(loop)

    return true;
end

return UdpListener
