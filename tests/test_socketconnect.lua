-- test_socketconnect.lua

local Application = require("Application")
local NativeSocket = require("NativeSocket")
local SocketUtils = require("SocketUtils")

local hostname = arg[1] or "localhost"
local port = tonumber(arg[2]) or 8080


local function createClient(hostname, port, protocol)
	local family = AF_INET;
	local socktype = SOCK_STREAM;
	local protocol = protocol or 0;


	-- Try to get an address for the hostname
	local addr, err = SocketUtils.CreateSocketAddress(hostname, port)

print("Address: ", addr, err)

	if not addr then
		print("-- createClient() - could not create address: ", err, hostname, port)
		return nil, err
	end

	local socket, err = NativeSocket:create(family, socktype, protocol, autoclose);


	if not socket then
		return nil, err
	end

	-- Connect to the host
	local status, err = socket:connectTo(addr);
	if not status then 
		return nil, err
	end

	return socket;
end

local function main()
	local socket, err = createClient(hostname, port)

	print("socket createClient: ", socket, err)
end

run(main)