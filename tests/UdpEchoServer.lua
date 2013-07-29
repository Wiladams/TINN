local ffi = require("ffi");

local IOProcessor = require("IOProcessor");
local IOCPSocket = require("IOCPSocket");
local ws2_32 = require("ws2_32");

--IOProcessor:setMessageQuanta(5);
local serverport = 9090;


local createServerSocket = function(port)
	local port = port or serverport;
	local socket, err = IOCPSocket:create(AF_INET, SOCK_DGRAM, 0);

	if not socket then
		print("create socket ERROR: ", err);
		return nil, err;
	end

	local addr = sockaddr_in(port);
	local addrlen = ffi.sizeof(addr);

	success, err = socket:bind(addr,addrlen)

	if not success then
		return false, err;
	end

	return socket;
end

-- The primary application loop
local loop = function()
	local bufflen = 1500;
	local buff = ffi.new("uint8_t[?]", bufflen);
	local from = sockaddr_in();
	local fromLen = ffi.sizeof(from);

	local socket, err = createServerSocket(serverport);

	if not socket then
		print("createServerSocket Error: ", err);
		return false, err;
	end

  	while true do
    	local bytesread, err = socket:receiveFrom(from, fromLen, buff, bufflen);

    	if not bytesread then
    		print("receiveFrom ERROR: ", err)
    		return false, err;
    	end

    	print("BYTESREAD: ", bytesread, from);
    	
    	print(ffi.string(buff, bytesread));

    	-- echo back to sender
    	local bytessent, err = socket:sendTo(from, fromLen, buff, bufflen);
	    --collectgarbage();
    end
end

run(loop);
