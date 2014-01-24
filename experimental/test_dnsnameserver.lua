local ffi = require("ffi")
local DNSNameServer = require("DNSNameServer")
local core_string = require("core_string_l1_1_0")

--local dns = DNSNameServer("8.8.8.8") -- "8.8.8.8" is the public DNS server maintained by google inc.
local dns = DNSNameServer("157.54.10.29") -- ms corporate

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


--local dnsservername = "209.244.0.3"
<<<<<<< HEAD
local dnsservername = "10.211.55.1"
=======
local dnsservername = "157.54.10.29" -- MS Corporate
>>>>>>> 763830638d6995d8d6f1b9748ecb4c55e4bd59c2

local function queryA()
	local function queryDomain(name)
		local dns = DNSNameServer(dnsservername) -- ms corporate
		print("==== DNS A ====> ", name)
		for record in dns:A(name) do
			local a = IN_ADDR();
    		a.S_addr = record.Data.A.IpAddress

    		print(string.format("name: %s\tIP: %s, TTL %d", name, a, record.dwTtl));
		end
	end

	for _, name in ipairs(domains) do 
		--spawn(queryDomain, name)
		queryDomain(name)
	end
end

local function queryCNAME()
	local function queryDomain(name)
		print("==== DNS CNAME ====> ", name)
		for record in dns:CNAME(name) do
			print(core_string.toAnsi(record.pName), core_string.toAnsi(record.Data.CNAME.pNameHost))
		end
	end

	for _, name in ipairs(domains) do 
		spawn(queryDomain, name)
	end
end

local function queryMX()
	local function queryDomain(name)
		print("==== DNS MX ====> ", name)
		for record in dns:MX(name) do
			print(core_string.toAnsi(record.pName), core_string.toAnsi(record.Data["MX"].pNameExchange))
		end
	end

	for _, name in ipairs(domains) do 
		spawn(queryDomain, name)
	end
end

local function querySRV()
	for _, name in ipairs(domains) do 
		print("==== DNS SRV ====> ", name)
		for record in dns:SRV(name) do
			print(core_string.toAnsi(record.pName), core_string.toAnsi(record.Data.SRV.pNameTarget))
		end
	end
end

local function main()
	queryA();
	--queryCNAME();
	--queryMX();
	--querySRV();
end

run(main)

