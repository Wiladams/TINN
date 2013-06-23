
local ffi = require "ffi"

local WinSock = require "WinSock_Utils"
local SocketUtils = require "SocketUtils"
local NativeSocket = require "NativeSocket"

function pathFromResource(resource)
	print("pathFromResource: ", resource)

	local urloffset = resource:find("//", 1, true)
	print("urloffset: ", urloffset)
	if not urloffset then
		return nil
	end

	local url = resource:sub(urloffset+2)
	print("URL:",url);

	local pathoffset = url:find("//", 1, true)
	if not pathoffset then
		return "/", url
	end

	local path = url:sub(pathoffset+2)

	return path, url
end

function test_bytes_ready()
	local socket = CreateTcpSocket()
	--socket:SetNonBlocking(false)

	print(socket:GetBytesPendingReceive())
end

function test_path_parsing()
	local path, url = pathFromResource("/connect/browser/jakljdfkjjasdfl//http://www.adafruit.com/index.html")

	print("PATH:",path)
	print("URL:",url)
end

function sockerr(err)
	local anerror = WinSock.SocketErrors[err]

	if anerror then return anerror[2] end

	return tostring(err)
end

function test_receive_zero()
	-- create a socket
	--local sock = CreateTcpSocket()
	-- see if it's connected
	--print("Sock Currently Connected: ", sock:IsCurrentlyConnected());

	-- try to ready 0 bytes from it
	local buff = ffi.new("uint8_t[1024]")


	-- Try the same thing with a connected socket
	local gsock, err = SocketUtils.CreateTcpClientSocket("www.google.com", 80)
	--gsock:SetNonBlocking(true)
	print("GSocket Creation: ", gsock, "Error: ", err);

	if err then
		print("GSock Connected: ", WinSock.GetSocketErrorString(err));
	end
	
	-- try to receive blank
	nbytes, err = gsock:Receive(buff, 0, 0)
	print("  GSock Send:",WinSock.GetSocketErrorString(err), nbytes);
end

function test_send_zero()
	-- create a simple buffer
	local buff = ffi.new("uint8_t[1024]")

	-- Create a connected socket
	local gsock, err = SocketUtils.CreateTcpClientSocket("www.bing.com", 80)
	--gsock:SetNonBlocking(true)
	print("GSocket Creation: ", gsock, "Error: ", err);

	if err then
		print("GSock Failed Connection: ", WinSock.GetSocketErrorString(err));
	end
	
	-- try to send blank
	local nbytes, err = gsock:Send(buff, 0, 0)
	print("Send Result: ", nbytes, err);
	--print("Send Connected:",WinSock.GetSocketErrorString(err), "Bytes: ", nbytes);
end

--test_receive_zero();
test_send_zero();
