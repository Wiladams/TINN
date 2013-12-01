local ffi = require "ffi"

local IOProcessor = require("IOProcessor");
local IOCPSocket = require("IOCPSocket");
local SocketUtils = require("SocketUtils");


local hostname = arg[1] or "localhost"
local serviceport = arg[2] or 8080


local phrase = "HELLO UDP Test"

local main = function()
    -- create the client socket
    local socket, err = IOCPSocket:create(AF_INET, SOCK_DGRAM, 0);

    if not socket then
        print("Socket Creation Failed: ", err);
        return nil, err;
    end

    -- create the address to the server
    local addr, err = SocketUtils.CreateSocketAddress(hostname, serviceport)
    local addrlen = ffi.sizeof(addr);



    local bytessent, err = socket:sendTo(addr, addrlen, phrase, #phrase);

    print("bytessent: ", bytessent, err);    
end

run(main);

