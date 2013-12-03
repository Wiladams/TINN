local ffi = require("ffi")

ffi.cdef[[
typedef struct {
	void * ptr;	
} IUnknown ;
]]
