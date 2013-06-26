
local ffi = require("ffi");
local bit = require("bit");
local bnot = bit.bnot;
local rshift = bit.rshift;
local lshift = bit.lshift;
local band = bit.band;

local ws2_32 = require("ws2_32");
local IPUtils = require("IPUtils");


-- Get the adress of a particular field within a structure
local fieldAddress = function(astruct, fieldname)
	local structtype = ffi.typeof(astruct);
	local offset = ffi.offsetof(structtype, fieldname);
	local structptr = ffi.cast("uint8_t *", astruct); 
	
	return structptr + offset;
end

ip_packet = {}

ffi.cdef[[
typedef u_short n_short;		/* short as received from the net */
typedef u_long	n_long;			/* long as received from the net */

typedef	u_long	n_time;			/* ms since 00:00 GMT, byte rev */
]]



if ffi.abi('le') then
ffi.cdef[[
/*
 * Structure of an internet header, naked of options.
 *
 * We declare ip_len and ip_off to be short, rather than u_short
 * pragmatically since otherwise unsigned comparisons can result
 * against negative integers quite easily, and fail in subtle ways.
 */
struct ip {
	u_char	ip_hl:4,		/* header length */
			ip_v:4;			/* version */
	u_char	ip_tos;			/* type of service */
	short	ip_len;			/* total length */
	u_short	ip_id;			/* identification */
	short	ip_off;			/* fragment offset field */
	u_char	ip_ttl;			/* time to live */
	u_char	ip_p;			/* protocol */
	u_short	ip_sum;			/* checksum */
	struct	in_addr ip_src; /* source address */
	struct  in_addr ip_dst;	/* dest address */
};
]]
else
ffi.cdef[[
struct ip {
	u_char	ip_v:4,			/* version */
			ip_hl:4;		/* header length */
	u_char	ip_tos;			/* type of service */
	short	ip_len;			/* total length */
	u_short	ip_id;			/* identification */
	short	ip_off;			/* fragment offset field */
	u_char	ip_ttl;			/* time to live */
	u_char	ip_p;			/* protocol */
	u_short	ip_sum;			/* checksum */
	struct	in_addr ip_src,ip_dst;	/* source and dest address */
};
]]
end 


ip_packet.IPVERSION = 4;
ip_packet.IP_DF =0x4000;			-- dont fragment flag
ip_packet.IP_MF =0x2000;			-- more fragments flag

ip_packet.IP_MAXPACKET=	65535;		-- maximum packet size


-- Definitions for IP type of service (ip_tos)

ip_packet.IPTOS_LOWDELAY		=0x10;
ip_packet.IPTOS_THROUGHPUT	=0x08;
ip_packet.IPTOS_RELIABILITY	=0x04;


-- Internet implementation parameters.

ip_packet.MAXTTL		=255;		-- maximum time to live (seconds) */
ip_packet.IPFRAGTTL	=60;		-- time to live for frags, slowhz */
ip_packet.IPTTLDEC	=1;		-- subtracted when forwarding */

ip_packet.IP_MSS		=576;		-- default maximum segment size */



ffi.cdef[[
/*
 * Udp protocol header.
 * Per RFC 768, September, 1981.
 */
struct udphdr {
	uint16_t	uh_sport;		/* source port */
	uint16_t	uh_dport;		/* destination port */
	int16_t		uh_ulen;		/* udp length */
	uint16_t	uh_sum;			/* udp checksum */
};
]]


ip_packet.ETHER_ADDR_LEN = 6;
ip_packet.ETHER_HEADER_SIZE = (ip_packet.ETHER_ADDR_LEN * 2 + ffi.sizeof("uint16_t"));

ip_packet.printIP = function(ip)
	ip = ffi.cast("struct ip *", ip);

	print("        Version: ", ip.ip_v);
	print("     header len: ", ip.ip_hl);
	print("type of service: ", ip.ip_tos);
	print("   total length: ", string.format("0x%04x",ip.ip_len));
	print(" identification: ", ip.ip_id);
	print("fragment offset: ", ip.ip_off);
	print("   time to live: ", ip.ip_ttl);
	print("       protocol: ", ip.ip_p);
	print("       checksum: ", ip.ip_sum);
	print("         source: ", ip.ip_src);
	print("    destination: ", ip.ip_dst);

	--struct	in_addr ip_src,ip_dst;	/* source and dest address */
end


function ip_packet.checksum(buf, nbytes, sum)
	sum = sum or 0;
	buf = ffi.cast("unsigned char *", buf);

	-- Checksum all the pairs of bytes first...
	local i = 0; 
	while (i < band(nbytes, bnot(1))) do
		sum = sum + ffi.cast("uint16_t",ws2_32.ntohs((ffi.cast("uint16_t *",(buf + i)))[0]));
		if (sum > 0xFFFF) then
			sum = sum - 0xFFFF;
		end

		i = i + 2;
	end

	--[[
	 * If there's a single byte left over, checksum it, too.
	 * Network byte order is big-endian, so the remaining byte is
	 * the high byte.
	--]]
	if (i < nbytes) then
		sum = sum + lshift(buf[i], 8);
		if (sum > 0xFFFF) then
			sum = sum - 0xFFFF;
		end
	end

	return tonumber(sum);
end

function ip_packet.wrapsum(sum)
	sum = band(bnot(sum), 0xFFFF);
	return (ws2_32.htons(sum));
end

--[[
function ip_packet.assemble_hw_header(struct interface_info *interface, unsigned char *buf,
    int *bufix, struct hardware *to)
{
	struct ether_header eh;

	if (to != NULL && to->hlen == 6) /* XXX */
		memcpy(eh.ether_dhost, to->haddr, sizeof(eh.ether_dhost));
	else
		memset(eh.ether_dhost, 0xff, sizeof(eh.ether_dhost));
	if (interface->hw_address.hlen == sizeof(eh.ether_shost))
		memcpy(eh.ether_shost, interface->hw_address.haddr,
		    sizeof(eh.ether_shost));
	else
		memset(eh.ether_shost, 0x00, sizeof(eh.ether_shost));

	eh.ether_type = htons(ETHERTYPE_IP);

	memcpy(&buf[*bufix], &eh, ETHER_HEADER_SIZE);
	*bufix += ETHER_HEADER_SIZE;
}
--]]

--[[
Parameters
buf - uint8_t *
	The buffer to be written into
bufix - int
	Where to start writing into the buffer
srcAddr - uint32_t
	The source IP address
dstAddr - uint32_t
	The destination IP address
port - uint16_t
	The IP port to be addressed
data - uint8_t *
	The data payload
len - int
	The length of the data payload
--]]
ip_packet.assemble_udp_ip_header = function(buf, bufix, 
	srcAddr, dstAddr, 
	port, data, len)

	buf = ffi.cast("unsigned char *", buf);
	data = ffi.cast("const unsigned char *", data)
	local ip = ffi.new("struct ip");
	local udp = ffi.new("struct udphdr");

	local ip_len = ffi.sizeof(ip) + ffi.sizeof(udp) + len;
print("native, ip_len: ", string.format("0x%04x", ip_len));
print("netwise, ip_len: ", string.format("0x%04x", ws2_32.htons(ip_len)));

	ip.ip_v = ip_packet.IPVERSION;
	ip.ip_hl = 5;
	ip.ip_tos = ip_packet.IPTOS_LOWDELAY;
	ip.ip_len = ws2_32.htons(ip_len);
	ip.ip_id = 0;
	ip.ip_off = 0;
	ip.ip_ttl = 128;
	ip.ip_p = IPPROTO_UDP;
	ip.ip_sum = 0;
	ip.ip_src.S_addr = srcAddr;
	ip.ip_dst.S_addr = dstAddr;

	ip.ip_sum = ip_packet.wrapsum(ip_packet.checksum(ip, ffi.sizeof(ip), 0));


	--[[
	 * While the BPF -- used for broadcasts -- expects a "true" IP header
	 * with all the bytes in network byte order, the raw socket interface
	 * which is used for unicasts expects the ip_len field to be in host
	 * byte order.  In both cases, the checksum has to be correct, so this
	 * is as good a place as any to turn the bytes around again.
	--]]
	if (dstAddr ~= INADDR_BROADCAST) then
		ip.ip_len = ws2_32.ntohs(ip.ip_len);
	end

	ffi.copy(buf+bufix, ip, ffi.sizeof(ip));
	bufix = bufix + ffi.sizeof(ip);

	udp.uh_sport = ws2_32.htons(INADDR_LOOPBACK);	-- LOCAL_PORT
	udp.uh_dport = port;
	udp.uh_ulen = ws2_32.htons(ffi.sizeof(udp) + len);
	--ffi.fill(&udp.uh_sum, 0, ffi.sizeof(udp.uh_sum));

	udp.uh_sum = ip_packet.wrapsum(ip_packet.checksum(udp, ffi.sizeof(udp),
	    ip_packet.checksum(data, len, ip_packet.checksum(fieldAddress(ip,"ip_src"),
	    2 * ffi.sizeof("uint16_t"),
	    IPPROTO_UDP + ffi.cast("uint32_t",ws2_32.ntohs(udp.uh_ulen))))));

	ffi.copy(buf+bufix, udp, ffi.sizeof(udp));

	bufix = bufix + ffi.sizeof(udp);

	return bufix;
end

--[[
ssize_t
decode_hw_header(unsigned char *buf, int bufix, struct hardware *from)
{
	struct ether_header eh;

	memcpy(&eh, buf + bufix, ETHER_HEADER_SIZE);

	memcpy(from->haddr, eh.ether_shost, sizeof(eh.ether_shost));
	from->htype = ARPHRD_ETHER;
	from->hlen = sizeof(eh.ether_shost);

	return (sizeof(eh));
}
--]]

local ip_packets_seen = 0;
local ip_packets_bad_checksum=0;
local udp_packets_seen=0;
local int udp_packets_bad_checksum=0;
local udp_packets_length_checked=0;
local udp_packets_length_overflow=0;

ip_packet.decode_udp_ip_header = function(buf, bufix)
	buf = ffi.cast("unsigned char *", buf);
	bufix = bufix or 0;

	-- return values
	local from = ffi.new("struct sockaddr_in");
    local data = nil;
    local buflen = 0;

	local ip_len = lshift(band(buf[bufix], 0xf), 2);
	local len = 0;

print("IP LEN: ", ip_len);

	local ip = ffi.cast("struct ip *",(buf + bufix));
	local udp = ffi.cast("struct udphdr *",(buf + bufix + ip_len));

	-- Check the IP header checksum - it should be zero.
	ip_packets_seen = ip_packets_seen + 1;

--[[
	if (ip_packet.wrapsum(ip_packet.checksum(buf + bufix, ip_len, 0)) ~= 0) then
		
		ip_packets_bad_checksum = ip_packets_bad_checksum + 1;
		
		if (ip_packets_seen > 4 and
		    (ip_packets_seen / ip_packets_bad_checksum) < 2) then
			error(string.format("%d bad IP checksums seen in %d packets", 
				ip_packets_bad_checksum, ip_packets_seen));
			ip_packets_seen = 0;
			ip_packets_bad_checksum = 0;
		end

		return -1, "ip checksum ~= 0";
	end
--]]

	if (IPUtils.ntohs(ip.ip_len) ~= buflen) then
		error(string.format("ip length %d disagrees with bytes received %d.", 
			IPUtils.ntohs(ip.ip_len), buflen));
	end

	ffi.copy(fieldAddress(from,'sin_addr'), fieldAddress(ip,'ip_src'), 4);

	--[[
	 * Compute UDP checksums, including the ``pseudo-header'', the
	 * UDP header and the data.   If the UDP checksum field is zero,
	 * we're not supposed to do a checksum.
	--]]
	if data == nil then
		data = buf + bufix + ip_len + ffi.sizeof(udp);
		len = IPUtils.ntohs(udp.uh_ulen) - ffi.sizeof(udp);
		udp_packets_length_checked = udp_packets_length_checked + 1;

		if (len + data > buf + bufix + buflen) then
			udp_packets_length_overflow = udp_packets_length_overflow + 1;
			
			if (udp_packets_length_checked > 4 and
			    (udp_packets_length_checked / udp_packets_length_overflow) < 2) then
				print(string.format("%d udp packets in %d too long - dropped",
				    udp_packets_length_overflow,
				    udp_packets_length_checked));
				
				udp_packets_length_overflow = 0;
				udp_packets_length_checked = 0;
			end

			return -1;
		end

		if (len + data ~= buf + bufix + buflen) then
			error("accepting packet with data after udp payload.");
		end
	end

	local usum = udp.uh_sum;
	udp.uh_sum = 0;

	local sum = ip_packet.wrapsum(ip_packet.checksum(udp, ffi.sizeof(udp),
	    ip_packet.checksum(data, len, ip_packet.checksum(fieldAddress(ip,'ip_src'),
	    2 * sizeof(ip.ip_src),
	    IPPROTO_UDP + IPUtils.ntohs(udp.uh_ulen)))));

	udp_packets_seen = udp_packets_seen + 1;
	if (usum and usum ~= sum) then
		udp_packets_bad_checksum = udp_packets_bad_checksum + 1;
		if (udp_packets_seen > 4 and
		    (udp_packets_seen / udp_packets_bad_checksum) < 2) then
			error(string.format("%d bad udp checksums in %d packets",
			    udp_packets_bad_checksum, udp_packets_seen));
			udp_packets_seen = 0;
			udp_packets_bad_checksum = 0;
		end
		
		return -1;
	end

	ffi.copy(fieldAddress(from,'sin_port'), fieldAddress(udp,'uh_sport'), 2);

	--return ip_len + ffi.sizeof(udp);
	return from, data, len;
end


return ip_packet;
