-- test_acceptsocket.lua
local IOProcessor = require("IOProcessor")
local ws2_32 = require("ws2_32");
local Collections = require("Collections");
local IOCompletionPort = require("IOCompletionPort");

--local acceptQueue = Collections.Queue.new();
local acceptQueue = IOCompletionPort();

local cleanup = function()
	while true do
		--print("cleanup loop")
		--sock = acceptQueue:Dequeue();
		sock = acceptQueue:dequeue(15);
		if sock then
			print("CLEANUP: ", sock);
			local status = ws2_32.closesocket(sock);
			print("CLOSED: ", status);
		end
		yield();
	end
end


local tmain = function()
	print("tmain")
	listener, err = IOProcessor:createServerSocket({port=8080});

	if not listener then
		print("Error creating listener: ", err);
		return false, err;
	end

	print("Listener: ", listener:getNativeSocket(), err);

	while true do
		local accepted, err = listener:accept();

		print("Accepted: ", accepted, err);
		--acceptQueue:Enqueue(accepted);
		acceptQueue:enqueue(accepted);
	end
end

spawn(cleanup);
run(tmain)
