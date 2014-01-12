-- test_bgprotocol.lua
local Application = require("Application")
local serpent = require("serpent")
local NetMesh = require("NetMesh")
local mesh  = NetMesh("bgpconfig.lua")

local function main()
	print("==== mesh ====")
	print(serpent.encode(mesh.Config))
end

run(main)
