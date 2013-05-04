-- Util_ffi.lua

local ffi = require("ffi");
require("WTypes");

ffi.cdef[[
BOOL Beep(DWORD dwFreq,DWORD dwDuration);

PVOID EncodePointer (PVOID Ptr);

PVOID DecodePointer (PVOID Ptr);

PVOID EncodeSystemPointer (PVOID Ptr);

PVOID DecodeSystemPointer (PVOID Ptr);
]]
