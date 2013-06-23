local ffi = require("ffi");

local ws2_32 = require("ws2_32");
local SocketUtils = require("SocketUtils");

print("INVALID_SOCKET: ", INVALID_SOCKET, string.format("0x%x",tonumber(INVALID_SOCKET)));

do
	local info = addrinfo();
end

print("after addrinfo");

