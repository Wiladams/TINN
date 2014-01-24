local ffi = require("ffi")

ffi.cdef[[
typedef struct ip_hdr
{
 unsigned char  ip_header_len:4;  // 4-bit header length (in 32-bit words)
 unsigned char  ip_version   :4;  // 4-bit IPv4 version
 unsigned char  ip_tos;           // IP type of service
 unsigned short ip_total_length;  // Total length
 unsigned short ip_id;            // Unique identifier
 
 unsigned char  ip_frag_offset   :5; // Fragment offset field
 
 unsigned char  ip_more_fragment :1;
 unsigned char  ip_dont_fragment :1;
 unsigned char  ip_reserved_zero :1;
 
 unsigned char  ip_frag_offset1;    //fragment offset
 
 unsigned char  ip_ttl;           // Time to live
 unsigned char  ip_protocol;      // Protocol(TCP,UDP etc)
 unsigned short ip_checksum;      // IP checksum
 unsigned int   ip_srcaddr;       // Source address
 unsigned int   ip_destaddr;      // Source address
}   IPV4_HDR;
]]

ffi.cdef[[
typedef struct udp_hdr
{
 unsigned short source_port;     // Source port no.
 unsigned short dest_port;       // Dest. port no.
 unsigned short udp_length;      // Udp packet length
 unsigned short udp_checksum;    // Udp checksum (optional)
}   UDP_HDR;
]]

ffi.cdef[[
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
]]

ffi.cdef[[
typedef struct icmp_hdr
{
 BYTE type;          // ICMP Error type
 BYTE code;          // Type sub code
 USHORT checksum;
 USHORT id;
 USHORT seq;
}   ICMP_HDR;
]]
