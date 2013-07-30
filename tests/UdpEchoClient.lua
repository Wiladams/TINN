local ffi = require "ffi"

local IOProcessor = require("IOProcessor");
local IOCPSocket = require("IOCPSocket");
local ws2_32 = require("ws2_32");
local SocketUtils = require("SocketUtils");

local StopWatch = require("StopWatch");

local hostname = "localhost"
local serviceport = 9090


local argv = {...}
local argc = #argv

local EchoRequest = function(socket, addr, addrlen, phrase)
    -- fill the buffer with current time
    phrase = phrase or os.date("%c");

    local bytessent, err = socket:sendTo(addr, addrlen, phrase, #phrase);

--print("bytessent: ", bytessent, err);

    if not bytessent then
        print("sendTo ERROR: ", bytessent, err);
        return false, err;
    end

    local bufflen = 1500;
    local buff = ffi.new("uint8_t[?]", bufflen);
    
    local fromAddr = sockaddr_in();
    local fromLen = ffi.sizeof(fromAddr);

    local bytesreceived, err = socket:receiveFrom(fromAddr, fromLen, buff, bufflen);

    if not bytesreceived then
        return false, err;
    end

    if bytesreceived > 0 then
        --print("RECEIVED: ", bytesreceived);
        --return ffi.string(buff, bytesreceived);
        return true
    end

    return string.format("bytesreceived == %d", bytesreceived);
end



loop = function(phrase)
    local sw = StopWatch();

    local iterations = tonumber(argv[1]) or 1;

    --print("iterations: ", iterations);


    -- create the client socket
    local socket, err = IOCPSocket:create(AF_INET, SOCK_DGRAM, 0);

    if not socket then
        print("Socket Creation Failed: ", err);
        return nil, err;
    end

    -- create the address to the server
    local addr, err = SocketUtils.CreateSocketAddress(hostname, serviceport)
    local addrlen = ffi.sizeof(addr);



    local transcount = 0;

    for i=1,iterations do
        local dtc, err = EchoRequest(socket, addr, addrlen, phrase);
    
        if dtc then
            transcount = transcount + 1;
            --print(transcount, dtc, transcount/sw:Seconds());
        else
            print("Error: ", i, err);        
        end
        --collectgarbage();
    end

    print("Transactions: ", transcount, transcount/sw:Seconds());
end

run(loop, "Hello, World!");

