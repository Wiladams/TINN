-- test_packetsniffer.lua
local PacketSniffer = require("PacketSniffer")

local sniffer, err = PacketSniffer()

print(sniffer, err)
