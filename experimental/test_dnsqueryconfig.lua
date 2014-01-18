-- test_dnsqueryconfig.lua
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
	local pBuffer = ffi.new("IP4_ARRAY")
	local pBufferLength = ffi.new("DWORD[1]", ffi.sizeof(pBuffer))

print("DnsQueryConfig: ", windns_ffi.DnsQueryConfig)

	local hr = windns_ffi.DnsQueryConfig(Config, Flag, pwsAdapterName, pReserved, pBuffer, pBufferLength);


	if hr ~= 0 then
		print("DnsQueryConfig ERROR: ", hr)
		return false, hr
	end

	local idx = -1;
	local function closure()
		if hr ~= 0 then
			return nil;
		end

		idx = idx + 1;
		if idx >= pBuffer.AddrCount then
			return nil;
		end

		local addr = IN_ADDR()
		addr.S_addr = pBuffer.AddrArray[idx]

		return addr
	end

	return closure;
end



for addr in DNS:nameServers() do
	print("Name Server: ", addr)
end


