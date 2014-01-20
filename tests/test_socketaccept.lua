-- test_socketaccept.lua
local Application = require("Application")
local NativeSocket = require("NativeSocket")

local port = 8080
local backlog = 15

local function handleAccepted(sock)
	print("Handle Accepted: ", sock)
end

local function loop(socket)
  while true do
    local sock, err = socket:accept();

    print("Accepted: ", sock, err)
    
    if sock then
    	handleAccepted(sock);
    else
    	print("Accept ERROR: ", err);
    end
  end
end

local function main()
	local socket, err = NativeSocket:createServer({port = port, backlog = backlog, autoclose = true})

	if not socket then 
    	print("Server Socket not created!!")
    return nil, err
  end

  loop(socket)
end

run(main)
