
local ffi = require("ffi");

local Application = require("Application")
local SocketServer = require("SocketServer");
local NativeSocket = require("NativeSocket");
local NetStream = require("NetStream")

--Application:setMessageQuanta(0)

local content = [[
HTTP/1.1 200 OK

]]

local function handleNewConnection(sock)
--print("handleNewConnection: ", sock)

  -- create a socket wrapper
  local socket, err = NativeSocket:init(sock, true);

  if not socket then
      print("NativeSocket:init, ERROR: ", err)
      return ;
  end

  local netstream, err = NetStream:init(socket);

  -- read a line from the socket
  local line, err = netstream:readLine();

  if not line then
    return false, err
  end
  
print("LINE: ", line);

  -- write the line back out to the socket
---[=[
  local content = [[
HTTP/1.1 200 OK
Connection: close

<html>
  <head><title>Line Server</title></head>
  <body>]]..line..[[
  </body>
</html>]]

  socket:send(content, #content); 
--]=]

  socket:closeDown();
    --stop();
end


-- For every new connection
-- spawn a task to deal with it
local function OnAccept(sock)
    --print("LineServer.OnAccept: ", sock)

    --spawn(handleNewConnection, sock)
    handleNewConnection(sock)
end

local server = SocketServer(8080, OnAccept);

server:run();
