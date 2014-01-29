local ffi = require("ffi")
local DNSNameServer = require("DNSNameServer")
local core_string = require("core_string_l1_1_0")


--local serveraddress = "10.211.55.1"		-- xfinity
local serveraddress = "209.244.0.3" -- level 3

local domains = {
	"www.nanotechstyles.com",
	"www.adafruit.com",
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

local addresses = {
	"209.244.0.3",		-- Level 3
	"94.23.39.66",		-- luajit.org
	"208.109.4.201",	-- godaddy.com

}

local function queryA()
	local function queryDomain(name)
		local dns = DNSNameServer(serveraddress) -- ms corporate
		print("==== DNS A ====> ", name)
		for record in dns:A(name) do
			local a = IN_ADDR();
    		a.S_addr = record.Data.A.IpAddress

    		print(string.format("name: %s\tIP: %s, TTL %d", name, a, record.dwTtl));
		end
	end

	for _, name in ipairs(domains) do 
		spawn(queryDomain, name)
		--queryDomain(name)
	end
end

local function queryCNAME()
	local function queryDomain(name)
		local dns = DNSNameServer(serveraddress) -- ms corporate
		print("==== DNS CNAME ====> ", name)
		for record in dns:CNAME(name) do
			print(core_string.toAnsi(record.pName), core_string.toAnsi(record.Data.CNAME.pNameHost))
		end
	end

	for _, name in ipairs(domains) do 
		spawn(queryDomain, name)
		--queryDomain(name)
	end
end

local function queryMX()
	local function queryDomain(name)
		local dns = DNSNameServer(serveraddress) -- ms corporate
		print("==== DNS MX ====> ", name)
		for record in dns:MX(name) do
			print(core_string.toAnsi(record.pName), core_string.toAnsi(record.Data["MX"].pNameExchange))
		end
	end

	for _, name in ipairs(domains) do 
		spawn(queryDomain, name)
	end
end

local function queryPTR()
	local function queryDomain(name)
		local dns = DNSNameServer(serveraddress) -- ms corporate
		print("==== DNS PTR ====> ", name)
		for record in dns:PTR(name) do
			print(core_string.toAnsi(record.pName), core_string.toAnsi(record.Data.PTR.pNameHost))
		end
	end

	for _, address in ipairs(addresses) do 
		--spawn(queryDomain, address)
		queryDomain(address)
	end
end

local function querySRV()
	local dns = DNSNameServer(serveraddress) -- ms corporate
	for _, name in ipairs(domains) do 
		print("==== DNS SRV ====> ", name)
		for record in dns:SRV(name) do
			print(core_string.toAnsi(record.pName), core_string.toAnsi(record.Data.SRV.pNameTarget))
		end
	end
end

local function main()
	--queryA();
	--queryCNAME();
	--queryMX();
	queryPTR();
	--querySRV();
end

run(main)

