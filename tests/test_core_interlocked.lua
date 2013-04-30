local ffi = require("ffi");
local inter = require("core_interlocked");
local kernel32 = require("kernel_32");
local k32Lib = kernel32.Lib;

local head = ffi.new("SLIST_HEADER");
k32Lib.InitializeSListHead (head);


