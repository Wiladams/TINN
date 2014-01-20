local ffi = require "ffi"

local Application = require("Application");
local NativeSocket = require("NativeSocket")
local StopWatch = require("StopWatch");

local hostname = "localhost"
local serviceport = 9090


local argv = {...}
local argc = #argv


EchoRequest = function()
    local socket, err = NativeSocket:createClient(hostname, serviceport, true);
    
    if not socket then
        print("Socket Creation Failed: ", err);
        return nil, err;
    end

    -- fill the buffer with current time
    local datestr = os.date("%c");

    local bytessent, err = socket:send(datestr, #datestr);

--print("bytessent: ", bytessent, err);

    local bufflen = 1500;
    local buff = ffi.new("uint8_t[?]", bufflen);
    local n, err = socket:receive(buff, bufflen)

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
        local dtc, err = EchoRequest();
    
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
