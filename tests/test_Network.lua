
--[[
	Get the IP address of the local interface (assuming first one)
	This is the interface the outside world will see and can possibly
	connect to.
--]]
local Network = require("Network")
local ws2_32 = require("ws2_32")


local interfaces,err = Network:GetInterfaces(SOCK_DGRAM);
print("interfaces: ", interfaces, err)

local function printTable(tbl, indent)
	indent = indent or ""

	for k,v in pairs(tbl) do
		if type(v) == 'table' then
			print("interface", k)
			printTable(v, indent..'  ')
		else
			io.write(indent,k,'  ',tostring(v),'\n')
		end
	end
end

local function getFirst(interfaces)
	for k,v in pairs(interfaces) do
		if v.isloopback == false and
			v.isup then
			return v.address;
		end
	end
end


--printTable(interfaces)

print("local: ", Network:GetLocalAddress()

