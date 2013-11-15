-- IOOps.lua

local ffi = require("ffi");

ffi.cdef[[
typedef struct {
	OVERLAPPED OVL;

	// Data Buffer
	uint8_t * Buffer;
	int BufferLength;

	int operation;
	int bytestransferred;
	int opcounter;

} IOOverlapped;
]]


ffi.cdef[[
typedef struct {
	IOOverlapped OVL;

	// Our specifics
	HANDLE file;
} FileOverlapped;
]]


return {
	ERROR = -1;
	CONNECT = 1;
	ACCEPT = 2;
	READ = 3;
	WRITE = 4;
};
