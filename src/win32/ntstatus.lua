-- ntstatus.lua

local ffi = require("ffi")

ffi.cdef[[
	typedef uint32_t  NTSTATUS;
	typedef NTSTATUS *PNTSTATUS;
]]

ffi.cdef[[
static const int STATUS_PENDING                  = (0x00000103);    		// winnt
static const int STATUS_ACCESS_DENIED            = ((NTSTATUS)0xC0000022);



static const int DBG_CONTINUE                    = ((NTSTATUS)0x00010002);	// winnt
static const int DBG_EXCEPTION_NOT_HANDLED       = ((NTSTATUS)0x80010001);    // winnt

]]
