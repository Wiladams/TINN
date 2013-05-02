-- ntstatus.lua

local ffi = require("ffi")

ffi.cdef[[
static const int STATUS_PENDING                  = (0x00000103);    // winnt
]]
