--[[
	This file represents an interface to the WinSock2
	networking interfaces of the Windows OS.  The functions
	can be found in the .dll:
		ws2_32.dll


--]]

-- WinTypes.h
-- WinBase.h

-- mstcpip.h
-- ws2_32.dll
-- inaddr.h
-- in6addr.h
-- ws2tcpip.h
-- ws2def.h
-- winsock2.h

local ffi = require "ffi"
local bit = require "bit"
local lshift = bit.lshift
local rshift = bit.rshift
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local bswap = bit.bswap

local ws2_32 = require ("ws2_32");


function LOWBYTE(word)
	return band(word, 0xff)
end

function HIGHBYTE(word)
	return band(rshift(word,8), 0xff)
end


ffi.cdef[[

enum {
	IP_DEFAULT_MULTICAST_TTL  = 1,    /* normally limit m'casts to 1 hop  */
	IP_DEFAULT_MULTICAST_LOOP = 1,    /* normally hear sends if a member  */
	IP_MAX_MEMBERSHIPS        = 20,   /* per socket; must fit in one mbuf */
};


// Options for connect and disconnect data and options.  Used only by
// non-TCP/IP transports such as DECNet, OSI TP4, etc.
enum {
            SO_CONNDATA     = 0x7000,
            SO_CONNOPT      = 0x7001,
            SO_DISCDATA     = 0x7002,
            SO_DISCOPT      = 0x7003,
            SO_CONNDATALEN  = 0x7004,
            SO_CONNOPTLEN   = 0x7005,
            SO_DISCDATALEN  = 0x7006,
            SO_DISCOPTLEN   = 0x7007,
};

        /*
         * Option for opening sockets for synchronous access.
         */
enum {
	SO_OPENTYPE             = 0x7008,
	SO_SYNCHRONOUS_ALERT    = 0x10,
	SO_SYNCHRONOUS_NONALERT = 0x20,
};

/*
* Other NT-specific options.
*/
enum {
	SO_MAXDG        = 0x7009,
	SO_MAXPATHDG    = 0x700A,
	SO_UPDATE_ACCEPT_CONTEXT = 0x700B,
	SO_CONNECT_TIME = 0x700C,
};



/*
* WinSock 2 extension -- new options
*/
enum {
	SO_GROUP_ID       = 0x2001,      /* ID of a socket group */
	SO_GROUP_PRIORITY = 0x2002,      /* the relative priority within a group*/
	SO_MAX_MSG_SIZE   = 0x2003,      /* maximum message size */
	SO_PROTOCOL_INFOA = 0x2004,      /* WSAPROTOCOL_INFOA structure */
	SO_PROTOCOL_INFOW = 0x2005,      /* WSAPROTOCOL_INFOW structure */
	SO_PROTOCOL_INFO  = SO_PROTOCOL_INFOW,
	PVD_CONFIG        = 0x3001,       /* configuration info for service provider */
	SO_CONDITIONAL_ACCEPT = 0x3002,   /* enable true conditional accept: */
                                                   /*  connection is not ack-ed to the */
                                       /*  other side until conditional */
                                       /*  function returns CF_ACCEPT */
};


/*
* Maximum queue length specifiable by listen.
*/
enum {
	SOMAXCONN     =  0x7fffffff,
};

enum {
	MSG_OOB         =  0x0001,      /* process out-of-band data */
	MSG_PEEK        =  0x0002,      /* peek at incoming message */
	MSG_DONTROUTE   =  0x0004,      /* send without using routing tables */
	MSG_WAITALL     =  0x0008,      /* do not complete until packet is completely filled */
	MSG_PARTIAL     =  0x8000,      /* partial send or recv for message xport */
	MSG_INTERRUPT   =  0x10,           /* send/recv in the interrupt context */
	MSG_MAXIOVLEN   =  16,
};

/*
* Define constant based on rfc883, used by gethostbyxxxx() calls.
*/
enum {
	MAXGETHOSTSTRUCT  = 1024,
};
]]


ffi.cdef[[
typedef int SERVICETYPE;

typedef struct _flowspec {
	ULONG TokenRate;
	ULONG TokenBucketSize;
	ULONG PeakBandwidth;
	ULONG Latency;
	ULONG DelayVariation;
	SERVICETYPE ServiceType;
	ULONG MaxSduSize;
	ULONG MinimumPolicedSize;
} FLOWSPEC,  *PFLOWSPEC,  *LPFLOWSPEC;

typedef struct _QualityOfService {
	FLOWSPEC SendingFlowspec;
	FLOWSPEC ReceivingFlowspec;
	WSABUF ProviderSpecific;
} QOS,  *LPQOS;
]]





ffi.cdef[[
typedef int (* LPCONDITIONPROC)(
    LPWSABUF lpCallerId,
    LPWSABUF lpCallerData,
    LPQOS lpSQOS,
    LPQOS lpGQOS,
    LPWSABUF lpCalleeId,
    LPWSABUF lpCalleeData,
    int * g,
    DWORD_PTR dwCallbackData
    );
]]



ffi.cdef[[
int GetNameInfoA(const struct sockaddr * sa, DWORD salen, char * host, DWORD hostlen, char * serv,DWORD servlen,int flags);
]]



local FD_CLR = function(fd, set)
--[[
    local __i;
    for (__i = 0; __i < ((fd_set FAR *)(set))->fd_count ; __i++) {
        if (((fd_set FAR *)(set))->fd_array[__i] == fd) {
            while (__i < ((fd_set FAR *)(set))->fd_count-1) {
                ((fd_set FAR *)(set))->fd_array[__i] =
                    ((fd_set FAR *)(set))->fd_array[__i+1];
                __i++;
            }
            ((fd_set FAR *)(set))->fd_count--;
            break;
        }
    }
--]]
end



local FD_SET = function(fd, set)

	local __i = 0;
	
	while (__i < set.fd_count) do
        if (set.fd_array[__i] == fd) then
            break;
        end
        i = i + 1;
    end
    
    if (__i == set.fd_count) then
        if (set.fd_count < ffi.C.FD_SETSIZE) then
            set.fd_array[__i] = fd;
            set.fd_count = set.fd_count + 1;
        end
    end

end


local FD_ZERO = function(set)
	set.fd_count = 0
	
	return true
end


local FD_ISSET = function(fd, set)
	return ws2_32.__WSAFDIsSet(fd, set);
end



return {
	FD_CLEAR = FD_CLEAR,
	FD_SET = FD_SET,
	FD_ZERO = FD_ZERO,
	FD_ISSET = FD_ISSET,
}
