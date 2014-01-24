-- test_packetsniffer.lua
local ffi = require("ffi")
local Application = require("Application")
local PacketSniffer = require("PacketSniffer")
local ipheaders = require("ipheaders")
local ws2_32 = require("ws2_32")
local IPUtils = require("IPUtils")
local bit = require("bit")
local bswap = bit.bswap;

local function printIPV4Header(hdr)
--[[
	print("== IP V4 HEADER ==")
	print(" Header Len: ", hdr.ip_header_len*4)
	print("  Total Len: ", IPUtils.ntohs(hdr.ip_total_length))
	print("Frag Offset: ", hdr.ip_frag_offset)
	print("        TTL: ", hdr.ip_ttl)
	print("      PROTO: ", ws2_32.protocols[hdr.ip_protocol])
--]]
	local src = IN_ADDR();
    src.S_addr = hdr.ip_srcaddr

	local dst = IN_ADDR();
    dst.S_addr = hdr.ip_destaddr
end

local function IPV4Header_tostring(hdr)
	local src = IN_ADDR();
    src.S_addr = hdr.ip_srcaddr

	local dst = IN_ADDR();
    dst.S_addr = hdr.ip_destaddr

	return string.format("{PROTO='%s', LEN='%d', SRC=,%s', DST='%s'}", 
		ws2_32.protocols[hdr.ip_protocol], 
		IPUtils.ntohs(hdr.ip_total_length),
		src,
		dst
		);
end

--[[
typedef struct tcp_header
{
 unsigned short source_port;  // source port
 unsigned short dest_port;    // destination port
 unsigned int   sequence;     // sequence number - 32 bits
 unsigned int   acknowledge;  // acknowledgement number - 32 bits
 
 unsigned char  ns   :1;          //Nonce Sum Flag Added in RFC 3540.
 unsigned char  reserved_part1:3; //according to rfc
 unsigned char  data_offset:4;    //number of dwords in the TCP header.
 
 unsigned char  fin  :1;      //Finish Flag
 unsigned char  syn  :1;      //Synchronise Flag
 unsigned char  rst  :1;      //Reset Flag
 unsigned char  psh  :1;      //Push Flag
 unsigned char  ack  :1;      //Acknowledgement Flag
 unsigned char  urg  :1;      //Urgent Flag
 
 unsigned char  ecn  :1;      //ECN-Echo Flag
 unsigned char  cwr  :1;      //Congestion Window Reduced Flag
 
 unsigned short window;          // window
 unsigned short checksum;        // checksum
 unsigned short urgent_pointer;  // urgent pointer
}   TCP_HDR;
--]]
local function TCPHeader_tostring(hdr)
	return string.format("{LEN=%d, SRCP=%d, DSTP=%d}",
		hdr.data_offset*4,
		IPUtils.ntohs(hdr.source_port),
		IPUtils.ntohs(hdr.dest_port))
end

local function main()
	local sniffer, err = PacketSniffer()


	if not sniffer then
		print(sniffer, err)
		return nil;
	end

	for bytecount, buff in sniffer:packets() do
		--print(bytecount, buff)
		local iphead = ffi.cast("IPV4_HDR *", buff)
		print(IPV4Header_tostring(iphead))
		if (iphead.ip_protocol == IPPROTO_TCP) then
			local offset = iphead.ip_header_len*4;
			local tcphdr = ffi.cast("TCP_HDR *", buff + offset)
			--print("",offset)
			print("",TCPHeader_tostring(tcphdr))

			-- body of TCP
			offset = offset + ffi.sizeof("TCP_HDR")
			local bodyptr = ffi.cast("char *", buff + offset)
			if IPUtils.ntohs(tcphdr.dest_port) == 80 then
				-- assume it's HTTP
				local size = bytecount - offset
				print(ffi.string(bodyptr, size))
			end
		end
	end
end

run(main)