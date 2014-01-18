-- test_windns_ffi.lua
local ffi = require("ffi")

local windns_ffi = require("windns_ffi")
local WinError = require("win_error")

local errors = {
	[0] = "SUCCESS",
	[ERROR_INVALID_NAME] = "ERROR_INVALID_NAME",
	[ffi.C.DNS_ERROR_NON_RFC_NAME] = "DNS_ERROR_NON_RFC_NAME",
	[ffi.C.DNS_ERROR_INVALID_NAME_CHAR] = "DNS_ERROR_INVALID_NAME_CHAR",
}

local function getErrorString(err)
	return errors[err] or tostring(err)
end

local function test_validateNames()

	local names = {
		{"www.bing.com", ffi.C.DnsNameHostnameFull, 0},
		{".www.bing.com", ffi.C.DnsNameHostnameFull, 0},
		{"1234567890", ffi.C.DnsNameHostnameFull, 0},
		{"non_rfc_name", ffi.C.DnsNameHostnameFull, 0},
		{"invalid^char", ffi.C.DnsNameHostnameFull, ffi.C.DNS_ERROR_INVALID_NAME_CHAR},
	}

	for i, entry in ipairs(names) do
		local res = windns_ffi.DnsValidateName(entry[1], entry[2]);

		print("Validate Name: ", entry[1], getErrorString(res))
	end
end


test_validateNames();
