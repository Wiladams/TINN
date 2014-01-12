
local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;
local band = bit.band;
local rshift = bit.rshift;
local lshift = bit.lshift;

local IPUtils = {}

IPUtils.swap16 = function(num)
	return bit.bor(bit.lshift(band(num, 0x00ff), 8), rshift(band(num, 0xff00),8));
end

IPUtils.htons = ffi.abi("le") and IPUtils.swap16 or function(x) return band(x, 0xffff) end
IPUtils.htonl = ffi.abi("le") and bit.bswap or function(x) return band(x, 0xffffffff) end

IPUtils.ntohs = ffi.abi("le") and IPUtils.swap16 or function(x) return x end
IPUtils.ntohl = ffi.abi("le") and bit.bswap or function(x) return x end

return IPUtils
