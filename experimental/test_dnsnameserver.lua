local ffi = require("ffi")
local DNSNameServer = require("DNSNameServer")
local core_string = require("core_string_l1_1_0")

local dns = DNSNameServer("8.8.8.8") -- "8.8.8.8" is the public DNS server maintained by google inc.

local domains = {
	"www.nanotechstyles.com",
	"adafruit.com",
	"adamation.com",
	"www.adamation.com",
	"microsoft.com",
	"google.com",
	"ibm.com",
	"oracle.com",
	"sparkfun.com",
	"apple.com",
	"netflix.com",
	"www.netflix.com",
	"www.us-west-2.netflix.com",
	"www.us-west-2.prodaa.netflix.com",
	"news.com",
	"hardkernel.org",
	"amazon.com",
	"walmart.com",
	"target.com",
	"godaddy.com",
	"luajit.org",
}


local function printA(record)
    local a = IN_ADDR();
    a.S_addr = record.Data.A.IpAddress

    print(string.format("\tIP: %s, TTL %d", a, record.dwTtl));
end

local function queryA()
	for _, name in ipairs(domains) do 
		print("==== DNS LOOKUP ====> ", name)
		for record in dns:A(name) do
			printA(record)
		end
	end
end

local function queryCNAME()
	for _, name in ipairs(domains) do 
		print("==== DNS CNAME ====> ", name)
		for record in dns:CNAME(name) do
			print(core_string.toAnsi(record.pName), core_string.toAnsi(record.Data.CNAME.pNameHost))
		end
	end
end

local function queryMX()
	for _, name in ipairs(domains) do 
		print("==== DNS MX ====> ", name)
		for record in dns:MX(name) do
			print(core_string.toAnsi(record.pName), core_string.toAnsi(record.Data.MX.pNameExchange))
		end
	end
end

local function main()
	queryA();
	--queryCNAME();
	--queryMX();
end

run(main)

