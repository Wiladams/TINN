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
