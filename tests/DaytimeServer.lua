
local SocketUtils = require "SocketUtils"


local function Run(config)
	local port = config.port or 13
	local ServerSocket, err = SocketUtils.CreateTcpServerSocket({port = port, backlog = 15, nonblocking=false, nodelay = false});
	
	if not ServerSocket then 
		return false, err
	end
	
	print("Daytime Server Running")
	while (true) do
		local acceptedsock, err = ServerSocket:Accept()

		if acceptedsock then
			--print("Accepted: ", acceptedsock);
			acceptedsock:Send(os.date("%c"));
			acceptedsock:Send("\r\n");
			
			-- close down the socket
			-- or the client won't know when to stop reading
			acceptedsock:CloseDown()
			
			acceptedsock = nil
		else
			print("No SOCKET");
		end
	end
end

return {
	Startup = Run,
}
