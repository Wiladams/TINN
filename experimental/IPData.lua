
-- Reference
-- http://www.iana.org/assignments/protocol-numbers/protocol-numbers.txt

--  Decimal   Keyword            Protocol

local IPProtocols = {
     { 0,    "HOPOPT",          "IPv6 Hop-by-Hop Option"},                
     { 1,    "ICMP",            "Internet Control Message"},              
     { 2,    "IGMP",            "Internet Group Management"},             
     { 3,    "GGP",             "Gateway-to-Gateway"},                    
     { 4,    "IPv4",            "IPv4 encapsulation"},                    
     { 5,    "ST",              "Stream"},                                
     { 6,    "TCP",             "Transmission Control"},                  
     { 7,    "CBT",             "CBT"},                                   
     { 8,    "EGP",             "Exterior Gateway Protocol"},             
     { 9,    "IGP",             "any private interior gateway (used by Cisco for their IGRP)"},
     {10,    "BBN_RCC_MON",     "BBN RCC Monitoring"},                    
     {11,    "NVP_II",          "Network Voice Protocol"},                
     {12,    "PUP",             "PUP"},                                   
     {13,    "ARGUS",           "ARGUS"},                                 
     {14,    "EMCON",           "EMCON"},                                 
     {15,    "XNET",            "Cross Net Debugger"},                    
     {16,    "CHAOS",           "Chaos"},
     {17,    "UDP",             "User Datagram"},                         
     {18,    "MUX",             "Multiplexing"},                          
     {19,    "DCN_MEAS",        "DCN Measurement Subsystems"},            
     {20,    "HMP",             "Host Monitoring"},                       
     {21,    "PRM",             "Packet Radio Measurement"},                                   
     {22,    "XNS_IDP",         "XEROX NS IDP"},
     {23,    "TRUNK_1",         "Trunk-1"},                               
     {24,    "TRUNK_2",         "Trunk-2"},                               
     {25,    "LEAF_1",          "Leaf-1"},                                
     {26,    "LEAF_2",          "Leaf-2"},                                
     {27,    "RDP",             "Reliable Data Protocol"},                
     {28,    "IRTP",            "Internet Reliable Transaction"},         
     {29,    "ISO_TP4",         "ISO Transport Protocol Class 4"},        
     {30,    "NETBLT",          "Bulk Data Transfer Protocol"},           
     {31,    "MFE_NSP",         "MFE Network Services Protocol"},             
     {32,    "MERIT_INP",       "MERIT Internodal Protocol"},             
     {33,    "DCCP",            "Datagram Congestion Control Protocol"},  
     {34,    "3PC",             "Third Party Connect Protocol"},          
     {35,    "IDPR",            "Inter-Domain Policy Routing Protocol"},  
     {36,    "XTP",             "XTP"},                                   
     {37,    "DDP",             "Datagram Delivery Protocol"},            
     {38,    "IDPR_CMTP",       "IDPR Control Message Transport Proto"},  
     {39,    "TPPLUSPLUS",      "TP++ Transport Protocol"},               
     {40,    "IL",              "IL Transport Protocol"},                 
     {41,    "IPv6",            "IPv6 encapsulation"},                    
     {42,    "SDRP",            "Source Demand Routing Protocol"},        
     {43,    "IPv6_Route",      "Routing Header for IPv6"},               
     {44,    "IPv6_Frag",       "Fragment Header for IPv6"},              
     {45,    "IDRP",            "Inter-Domain Routing Protocol"},         
     {46,    "RSVP",            "Reservation Protocol"},                  
     {47,    "GRE",             "Generic Routing Encapsulation"},         
     {48,    "DSR",             "Dynamic Source Routing Protocol"},       
     {49,    "BNA",             "BNA"},                                   
     {50,    "ESP",             "Encap Security Payload"},                
     {51,    "AH",              "Authentication Header"},                 
     {52,    "I_NLSP",          "Integrated Net Layer Security TUBA"},    
     {53,    "SWIPE",           "IP with Encryption"},                    
     {54,    "NARP",            "NBMA Address Resolution Protocol"},      
     {55,    "MOBILE",          "IP Mobility"},
     {56,    "TLSP",            "Transport Layer Security Protocol using Kryptonet key management"},
     {57,    "SKIP",            "SKIP"},                                  
     {58,    "IPv6_ICMP",       "ICMP for IPv6"},                         
     {59,    "IPv6_NoNxt",      "No Next Header for IPv6"},               
     {60,    "IPv6_Opts",       "Destination Options for IPv6"},          
     {62,    "CFTP",            "CFTP"},                                                                                 
     {64,    "SAT_EXPAK",       "SATNET and Backroom EXPAK"},             
     {65,    "KRYPTOLAN",       "Kryptolan"},                             
     {66,    "RVD",             "MIT Remote Virtual Disk Protocol"},      
     {67,    "IPPC",            "Internet Pluribus Packet Core"},         
     {69,    "SAT_MON",         "SATNET Monitoring"},                     
     {70,    "VISA",            "VISA Protocol"},                         
     {71,    "IPCV",            "Internet Packet Core Utility"},          
     {72,    "CPNX",            "Computer Protocol Network Executive"},   
     {73,    "CPHB",            "Computer Protocol Heart Beat"},          
     {74,    "WSN",             "Wang Span Network"},                     
     {75,    "PVP",             "Packet Video Protocol"},                 
     {76,    "BR_SAT_MON",      "Backroom SATNET Monitoring"},            
     {77,    "SUN_ND",          "SUN ND PROTOCOL-Temporary"},             
     {78,    "WB_MON",          "WIDEBAND Monitoring"},                   
     {79,    "WB_EXPAK",        "WIDEBAND EXPAK"},                        
     {80,    "ISO_IP",          "ISO Internet Protocol"},                 
     {81,    "VMTP",            "VMTP"},                                  
     {82,    "SECURE_VMTP",     "SECURE-VMTP"},                           
     {83,    "VINES",           "VINES"},                                 
     {84,    "TTP",             "TTP"},                                   
     {84,    "IPTM",            "Protocol Internet Protocol Traffic Manager"},
     {85,    "NSFNET_IGP",      "NSFNET-IGP"},                            
     {86,    "DGP",             "Dissimilar Gateway Protocol"},           
     {87,    "TCF",             "TCF"},                                   
     {88,    "EIGRP",           "EIGRP"},                                 
     {89,    "OSPFIGP",         "OSPFIGP"},                               
     {90,    "Sprite_RPC",      "Sprite RPC Protocol"},                                                                               
     {91,    "LARP",            "Locus Address Resolution Protocol"},     
     {92,    "MTP",             "Multicast Transport Protocol"},          
     {93,    "AX_25",           "AX.25 Frames"},                          
     {94,    "IPIP",            "IP-within-IP Encapsulation Protocol"},   
     {95,    "MICP",            "Mobile Internetworking Control Pro."},   
     {96,    "SCC_SP",          "Semaphore Communications Sec. Pro."},    
     {97,    "ETHERIP",         "Ethernet-within-IP Encapsulation"},      
     {98,    "ENCAP",           "Encapsulation Header"},                  
     {100,   "GMTP",            "GMTP"},                                  
     {101,   "IFMP",            "Ipsilon Flow Management Protocol"},      
     {102,   "PNNI",            "PNNI over IP"},                          
     {103,   "PIM",             "Protocol Independent Multicast"},        
     {104,   "ARIS",            "ARIS"},                                  
     {105,   "SCPS",            "SCPS"},                                  
     {106,   "QNX",             "QNX"},                                   
     {107,   "A_N",             "Active Networks"},                       
     {108,   "IPComp",          "IP Payload Compression Protocol"},       
     {109,   "SNP",             "Sitara Networks Protocol"},              
     {110,   "Compaq_Peer",     "Compaq Peer Protocol"},                  
     {111,   "IPX_in_IP",       "IPX in IP"},                             
     {112,   "VRRP",            "Virtual Router Redundancy Protocol"},    
     {113,   "PGM",             "PGM Reliable Transport Protocol"},       
     {115,   "L2TP",            "Layer Two Tunneling Protocol"},          
     {116,   "DDX",             "D-II Data Exchange (DDX)"},              
     {117,   "IATP",            "Interactive Agent Transfer Protocol"},   
     {118,   "STP",             "Schedule Transfer Protocol"},            
     {119,   "SRP",             "SpectraLink Radio Protocol"},            
     {120,   "UTI",             "UTI"},                                   
     {121,   "SMP",             "Simple Message Protocol"},               
     {122,   "SM",              "SM"},                                    
     {123,   "PTP",             "Performance Transparency Protocol"},     
     {124,   "ISIS_over_IPv4"},                                        
     {125,   "FIRE"},                                                  
     {126,   "CRTP",            "Combat Radio Transport Protocol"},       
     {127,   "CRUDP",           "Combat Radio User Datagram"},            
     {128,   "SSCOPMCE"},                                              
     {129,   "IPLT"},                                                  
     {130,   "SPS",             "Secure Packet Shield"},                  
     {131,   "PIPE",            "Private IP Encapsulation within IP"},    
     {132,   "SCTP",            "Stream Control Transmission Protocol"},  
     {133,   "FC",              "Fibre Channel"},                         
     {134,   "RSVP_E2E_IGNORE"},                                       
     {135,   "Mobility_Header"},                                       
     {136,   "UDPLite"},                                               
     {137,   "MPLS_in_IP"},                                            
     {138,   "manet",           "MANET Protocols"},                       
     {139,   "HIP",             "Host Identity Protocol"},                
     {140,   "Shim6",           "Shim6 Protocol"},                        
     {141,   "WESP",            "Wrapped Encapsulating Security Payload"},
     {142,   "ROHC",            "Robust Header Compression"},           

     {255,   "RAW"},                                              
}

local function lookup(id)
     local fieldnum;

     if type(id) == "number" then
          fieldnum = 1
     elseif type(id) == "string" then
          fieldnum = 2
     end

     if not fieldnum then
          return nil;
     end

     for _idx, entry in ipairs(IPProtocols) do
          if entry[fieldnum] == id then
               return entry[2]
          end
     end

     return nil;
end

--[[
No Name Protocols
     {61,                    any host internal protocol            
     {63,                    any local network                     
     {68,                    any distributed file system           
     {99,                    any private encryption scheme         
     {114,                   any 0-hop protocol                    [Internet_Assigned_Numbers_Authority]

-- {143-252,                 Unassigned                            [Internet_Assigned_Numbers_Authority]
     {253,                   Use for experimentation and testing   
     {254,                   Use for experimentation and testing   
--]]

return {
     Protocols = IPProtocols,
     lookup = lookup,
}