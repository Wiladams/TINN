-- test_bgprotocol.lua
local IOProcessor = require("IOProcessor")
local serpent = require("serpent")

local BGPPeer = require("BGPPeer")

local bgpeer = BGPPeer("bgpconfig.lua")

local function main()
	print("==== bgpeer ====")
	print(serpent.encode(bgpeer.Config))
end

run(main)
