-- test_ip_packet.lua

local ffi = require("ffi");
local ws2_32 = require("ws2_32");

local ip_packet = require("ip_packet");


local function test_checksum()
	local testvector = "\000\001\242\003\244\245\246\247";

	print(string.format("checksum: 0x%x", tonumber(ip_packet.checksum(testvector, 8))));
end

local function udp_stuff(payload, payloadLen)
	local buf = ffi.new("uint8_t[1518]");
	local bufix = 0;
	local srcAddr = ws2_32.inet_addr("127.0.0.1");
	local dstAddr = ws2_32.inet_addr("192.168.1.1");
	local port = 13;
	local data = payload;
	local len = payloadLen or #payload;

	local bufix = ip_packet.assemble_udp_ip_header(buf, bufix, 
		srcAddr, dstAddr,
		port, data, len);

	ffi.copy(buf+bufix, data, len);

	return buf, bufix + len;
end

local function test_udp_stuffing()
	local payload = "The quick brown fox jumped over the lazy dogs back"

	buf, len = udp_stuff(payload, #payload);


	print("assembled: ", buf, len);
	ip_packet.printIP(buf);
	
end

local function test_udp_unstuff()
	local payload = "The quick brown fox jumped over the lazy dogs back"
	local buf,len = udp_stuff(payload);
	print("STUFFED ==")
	ip_packet.printIP(buf);

	local bufix = 0;

	local hdr, err = ip_packet.decode_udp_ip_header(buf, bufix);

	print("unstuff, decoded: ", hdr, err);
end

--test_checksum();
--test_udp_stuffing();

test_udp_unstuff();
