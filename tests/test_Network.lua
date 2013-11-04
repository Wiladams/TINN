
--[[
	Get the IP address of the local interface (assuming first one)
	This is the interface the outside world will see and can possibly
	connect to.
--]]
local Network = require("Network")

local interfaces = Network:GetInterfaces();

local printTable = nil
printTable = function(tbl)
	for k,v in pairs(tbl) do
		print(k,v)
		if type(v) == "table" then
			printTable(v)
		end
	end
end

printTable(interfaces)