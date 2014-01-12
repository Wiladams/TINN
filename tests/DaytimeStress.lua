local ffi = require "ffi"

local NativeSocket = require("NativeSocket")
local Application = require("Application");
local StopWatch = require("StopWatch");


local hostname = "localhost"
local serviceport = 9091

local bufflen = 256;
local buff = ffi.new("char [?]", bufflen);

local argv = {...}
local argc = #argv

print("ARGC: ", argc);

GetDateAndTime = function()
    local socket, err = NativeSocket:createClient(hostname, serviceport);
    
    if not socket then
        print("Socket Creation Failed: ", err);
        return nil, err;
    end

    -- zero out the buffer
    ffi.fill(buff, 0, bufflen);

	--print("client about to receive");
    local n, err = socket:receive(buff, bufflen)
 	--print("client received: ", n, err);

    if not n then
        return false, err;
    end

    if n > 0 then
        return ffi.string(buff, n);
    end

    return string.format("n == %d", n);
end



loop = function()
    local sw = StopWatch();

    local iterations = tonumber(argv[1]) or 500;
    --print("iterations: ", iterations);

    local transcount = 0;

    for i=1,iterations do
        local dtc, err = GetDateAndTime("localhost");
    
        if dtc ~= nil then
            transcount = transcount + 1;
            --print(transcount, dtc, transcount/sw:Seconds());
        else
            print("Error: ", i, err);        
        end
        
        collectgarbage();
    end

    print("Transactions: ", transcount, transcount/sw:Seconds());
end

run(loop);