-- SocketOps.lua

local ffi = require("ffi");

ffi.cdef[[
typedef struct {
	OVERLAPPED OVL;

	SOCKET sock;



	// Data Buffer
	uint8_t * Buffer;
	int BufferLength;

	int operation;
	int bytestransferred;
	int opcounter;
} SocketOverlapped;
]]


return {
	ERROR = -1;
	CONNECT = 1;
	ACCEPT = 2;
	READ = 3;
	WRITE = 4;
};
