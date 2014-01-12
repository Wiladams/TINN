local ffi = require("ffi");

local Application = require("Application");
local NativeSocket = require("NativeSocket");

local serverport = 9090;


-- Setup the server socket
local socket, err = NativeSocket:create(AF_INET, SOCK_DGRAM, 0);

--if not socket then
--	print("create socket ERROR: ", err);
--	return nil, err;
--end

local success, err = socket:bindToPort(serverport);

--if not success then
--	print("bindToPort, ERROR: ", err);
--	return false, err;
--end


-- The primary application loop
local loop = function()
	local bufflen = 1500;
	local buff = ffi.new("uint8_t[?]", bufflen);
	local from = sockaddr_in();
	local fromLen = ffi.sizeof(from);



  	while true do
    	local bytesread, err = socket:receiveFrom(from, fromLen, buff, bufflen);

    	if not bytesread then
    		print("receiveFrom ERROR: ", err)
    		return false, err;
    	end

    	--print("BYTESREAD: ", bytesread, from);
    	
    	--print(ffi.string(buff, bytesread));

    	-- echo back to sender
    	local bytessent, err = socket:sendTo(from, fromLen, buff, bufflen);
	    --collectgarbage();
    end
end

run(loop);
