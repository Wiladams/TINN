
local Application = require("Application");
local NativeSocket = require("NativeSocket");
local IOCompletionPort = require("IOCompletionPort");

local serverSocket;
local serverPort = 9091

local acceptedSockets = IOCompletionPort();

local function setup()
	serverSocket, err = NativeSocket:createServer({port = serverPort, backlog = 15});
	
	if not serverSocket then 
		print("Server Socket not created!!")
		return false, err
	end

	print("Listener Created: ", serverSocket:getNativeSocket());

	Application:setMessageQuanta(15);
end

local function acceptor()
print("acceptor");
	while true do
		local acceptedsock, err = serverSocket:accept();

print("POST accept: ", acceptedsock, err);

		if acceptedsock then
			acceptedSockets:enqueue(acceptedsock);
		else
			print("No SOCKET: ", err);
		end
	end
end

local function main()
	while true do
		--local sock, err = acceptedSockets:dequeue(15);
		local sock, err = serverSocket:accept();

print("serverSocket:accept(): ", sock, err);

		if sock then
				--print("Accepted: ", acceptedsock);
				-- BUGBUG
				-- right here, with the IOCPSocket:init, the Application MUST be set!
			local socket = NativeSocket:init(sock);
			local datestr = os.date("%c");
				--print(datestr);
			socket:send(datestr);
			socket:send("\r\n");

				--print("SEND: ", socket:send(os.date("%c")));
				--print("SEND EOL: ", socket:send("\r\n"));
			
			-- close down the socket
			-- or the client won't know when to stop reading
			socket:closeDown();
			
			socket = nil
		else
			--print("No SOCKET: ", err);
		end

		collectgarbage();
	end
end

setup();
--spawn(acceptor);

run(main);
