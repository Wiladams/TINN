-- test_acceptsocket.lua

local tmain = function()
	--print("Main")
	listener, err = IOProcessor:createServerSocket({port=8080});

	if not listener then
		print("Error creating listener: ", err);
		return false, err;
	end

	print("Listener: ", listener:getNativeSocket(), err);

	while true do
		local accepted, err = listener:accept();

		print("Accepted: ", accepted, err);

		--break;
	end
end

run(tmain)
