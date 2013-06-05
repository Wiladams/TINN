-- test_wkscli.lua

print("Arg: ", arg);

local Workstation = require("Workstation");







--[[
	Test Cases
--]]
local printTable = function(tbl, title)
	if title then
		print(title);
	end

	for k,v in pairs(tbl) do
		print(k,v);
	end
end

local printRecords = function(records, title)
	if title then
		print(title);
	end

	for i, record in ipairs(records) do
		printTable(record);
	end
end

local station = Workstation();

printRecords(station:getUses(), "++++ USES");
printRecords(station:getUsers(1), "==== USERS");
printRecords(station:getTransports(), "#### TRANSPORTS");
