-- ntstatus.lua

local ffi = require("ffi")

ffi.cdef[[
	typedef uint32_t  NTSTATUS;
	typedef NTSTATUS *PNTSTATUS;
]]

ffi.cdef[[
static const int STATUS_PENDING                  = (0x00000103);    // winnt
]]
