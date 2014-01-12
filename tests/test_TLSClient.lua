
local ffi = require("ffi");

local Application = require("Application");
local NativeSocket = require("NativeSocket")


local stringzutils = require("stringzutils");

local TLSClient = require("TLSClient");
local SecurityInterface = require("sspi").SecurityInterface;


local serverName = "news.ycombinator.com";
--local serverName = "www.google.com";
local serverPort = 443;

local function main()
	-- 4.0  Connect to the server
	local socket, err = NativeSocket:createClient(serverName, serverPort, true);
	if not socket then
		return false, err
	end


	local session, err = TLSClient.ClientSession(socket, serverName);

	if not session then
		print("NO Session Created: ", err);
		return false, err;
	end

local msg = string.format("GET / HTTP/1.1\r\nHost: %s\r\n\r\n",
	serverName);

print("EncryptSend: ", session:Send(msg));


-- Now do a receive
local recvLength = 640*1024;
local recvBuffer = ffi.new("uint8_t[?]", recvLength);
local buff, length = TLSClient.DecryptReceive(session.Socket,session.Credentials, session.Context, recvBuffer,recvLength );

print("DecryptReceive: ", buff, length);

if buff then
	print(ffi.string(buff, length)); 
end
end

run(main)
