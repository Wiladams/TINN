local ffi = require("ffi");

local SocketServer = require("SocketServer");
local IOCPSocket = require("IOCPSocket");

local OnAccept = function(param, sock) 
	print("EchoServer.OnAccept(): ", sock)

 	local socket = IOCPSocket:init(sock, true);
	
 	-- read from the socket
 	local bufflen = 1500;
 	local buff = ffi.new("uint8_t[?]", bufflen);
 	local bytesread, err = socket:receive(buff, bufflen);

 	-- return what's been read back to the socket
	if bytesread then
		socket:send(buff, bufflen);
	else
		print("ERROR Reading Bytes: ", err);
	end

end

local server = SocketServer(9090, OnAccept);
server:run();

