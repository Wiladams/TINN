-- SocketOps.lua
local IOOps = require("IOOps")


local ffi = require("ffi");

ffi.cdef[[
typedef struct {
	IOOverlapped OVL;

	SOCKET sock;

} SocketOverlapped;
]]

ffi.cdef[[
typedef struct {
	HANDLE HeapHandle;
	HANDLE IOCPHandle;
	HANDLE ThreadHandle;
} Computicle_t;

]]

return {
	ERROR = -1;
	CONNECT = 1;
	ACCEPT = 2;
	READ = 3;
	WRITE = 4;
};
