local ffi = require "ffi"

local Application = require("Application");
local NativeSocket = require("NativeSocket")
local StopWatch = require("StopWatch");

local hostname = "localhost"
local serviceport = 8080


local argv = {...}
local argc = #argv

local sw = StopWatch();
local finished = 0;

local function EchoRequest(msg, len)
--print("Echo Request: ", msg, len)

    local socket, err = NativeSocket:createClient(hostname, serviceport, true);

    if not socket then
        print("socket creation error: ", err)
        return false;
    end

    local bytessent, err = socket:send(msg, len);

--print("EchoRequest: ", bytessent, err)

    local buff = ffi.new("uint8_t[1500]");
    local n, err = socket:receive(buff, 1500)

print("EchoRequest, receive: ", n, err)

    if n > 0 then
        -- return ffi.string(buff, n);
        print(ffi.string(buff, n))
    end

    finished = finished + 1;

    --collectgarbage();
end


local function cleanup()
    print("Transactions: ", finished, finished/sw:Seconds());
    stop();
end

local function loop()

    local iterations = tonumber(argv[1]) or 1;
    --print("iterations: ", iterations);

    local transcount = 0;

    -- fill the buffer with current time
    --local datestr = os.date("%c");
    --datestr = datestr.."\r\n";
    local msg = "GET /echo HTTP/1.1\r\n\r\n\r\n"

    for i=1,iterations do
        spawn(EchoRequest, msg, #msg);            
    end

    when(function() return finished == iterations end, cleanup)
end

run(loop);