
--[[
	Get the IP address of the local interface (assuming first one)
	This is the interface the outside world will see and can possibly
	connect to.
--]]
local net = require("Network")()
print(net:GetLocalInterface())