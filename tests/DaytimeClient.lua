local ffi = require "ffi"

require("IOProcessor");


local daytimeport = 9091



GetDateAndTime = function(hostname, port)
    hostname = hostname or "localhost";
    port = port or daytimeport;

    local socket, err = IOProcessor:createClientSocket(hostname, port);


    if not socket then
        print("Socket Creation Failed: ", err);
        return nil, err;
    end

    --socket:setNonBlocking(false);


    local bufflen = 256;
    local buff = ffi.new("char [?]", bufflen);

	--print("client about to receive");
    local n, err = socket:receive(buff, bufflen)
 	--print("client received: ", n, err);

    if not n then
        return false, err;
    end

    if n > 0 then
        return ffi.string(buff, n);
    end

end

