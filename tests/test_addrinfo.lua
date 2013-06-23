
local ffi = require("ffi");
local ws2_32 = require("ws2_32");

local gethost = function(hostname, family, sockttype, isnumericstring)
	hostname = hostname or "localhost"
	family = family or AF_UNSPEC;
	socktype = socktype or SOCK_STREAM;

	local servicename = nil;
	local err;
	local hints = addrinfo();
	local res = ffi.new("PADDRINFOA[1]")

	--hints.ai_flags = AI_CANONNAME;	-- return canonical name
	hints.ai_family = family;
	hints.ai_socktype = socktype;
	if isnumericstring then
		hints.ai_flags = AI_NUMERICHOST
	end

	err = ws2_32.getaddrinfo(hostname, servicename, hints, res)
--print("host_serv, err: ", err);
	if err ~= 0 then
		-- error condition
		return nil, err
	end

	return res[0]
end

PrintHostInfo = function(host)
    for info in host:addresses() do
        print("-- AddrInfo ==")
        print("Flags: ", info.ai_flags);
        print("Family: ", ws2_32.families[info.ai_family])
        print("Sock Type: ", ws2_32.socktypes[info.ai_socktype]);
        print("Protocol: ", ws2_32.protocols[info.ai_protocol]);
        print("Canon Name: ", info.ai_canonname);
            --print("Addr Len: ", info.ai_addrlen);
            --print("Address: ", info.ai_addr);
            --print("Address Family: ", info.ai_addr.sa_family);
        local addr;
        if info.ai_addr.sa_family == AF_INET then
            addr = ffi.cast("struct sockaddr_in *", info.ai_addr);
        elseif info.ai_addr.sa_family == AF_INET6 then
            addr = ffi.cast("struct sockaddr_in6 *", info.ai_addr);
        end
        print(addr);
    end
end


local host = gethost("www.bing.com");

if host then
	for address in host:addresses() do
		print(address);
	end

	PrintHostInfo(host);
end



