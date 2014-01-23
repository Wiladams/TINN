local ffi = require("ffi")

local ws2_32 = require("ws2_32")
local windns_ffi = require("windns_ffi")
local WinError = require("win_error")


local DNS = {}

function DNS.nameServers(self)
	local Config = ffi.C.DnsConfigDnsServerList;
	local Flag = 0;
	local pwsAdapterName = nil;
	local pReserved = nil;
	local buff = ffi.new("char[256]")
	local pBufferLength = ffi.new("DWORD[1]", 256)

	local hr = windns_ffi.DnsQueryConfig(Config, Flag, pwsAdapterName, pReserved, buff, pBufferLength);

	local idx = -1;
	local function closure()
		if hr ~= 0 then
			print("DnsQueryConfig ERROR: ", hr, pBufferLength[0])
			return nil;
		end

		idx = idx + 1;
		local pBuffer = ffi.cast("IP4_ARRAY *", buff);
		if idx >= pBuffer.AddrCount then
			return nil;
		end

		local addr = IN_ADDR()
		addr.S_addr = pBuffer.AddrArray[idx]

		return addr
	end

	return closure;
end

return DNS
