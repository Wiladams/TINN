-- test_dnsqueryconfig.lua
local DNS = require("DNS")


for addr in DNS:nameServers() do
	print("Name Server: ", addr)
end
