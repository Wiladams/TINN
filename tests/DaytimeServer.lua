
local IOCPSocket = require("IOCPSocket");

local serverPort = 9091

local port = serverPort
local serverSocket, err = IOCPSocket:createServer({port = serverPort, backlog = 15, nonblocking=false, nodelay = false});
	
if not serverSocket then 
	return false, err
end
	
print("Daytime Server Running")

while true do
	local acceptedsock, err = serverSocket:accept()

	if acceptedsock then
		--print("Accepted: ", acceptedsock);
		acceptedsock:send(os.date("%c"));
		acceptedsock:send("\r\n");
			
		-- close down the socket
		-- or the client won't know when to stop reading
		acceptedsock:closeDown();
			
		acceptedsock = nil
	else
		print("No SOCKET");
	end

	collectgarbage();
end




--return {
--	Startup = Run,
--}
