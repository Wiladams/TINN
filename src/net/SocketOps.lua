-- SocketOps.lua
local IOOps = require("IOOps")


local ffi = require("ffi");

ffi.cdef[[
typedef struct {
	IOOverlapped OVL;

	SOCKET sock;

} SocketOverlapped;
]]


return {
	ERROR = -1;
	CONNECT = 1;
	ACCEPT = 2;
	READ = 3;
	WRITE = 4;
};
