-- test_packetsniffer.lua
local Application = require("Application")
local PacketSniffer = require("PacketSniffer")

local function main()
	local sniffer, err = PacketSniffer()


	if not sniffer then
		print(sniffer, err)
		return nil;
	end

	for bytecount, buff in sniffer:packets() do
		print(bytecount, buff)
	end
end

run(main)