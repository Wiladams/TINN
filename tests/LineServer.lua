
local ffi = require("ffi");

local Application = require("Application")
local SocketServer = require("SocketServer");
local NativeSocket = require("NativeSocket");
local NetStream = require("NetStream")

Application:setMessageQuanta(0)

local content = [[
HTTP/1.1 200 OK

]]

local function handleNewConnection(param, socket)

  local netstream = NetStream:init(socket);

  -- read a line from the socket
  local line, err = netstream:readLine();
  print("LINE: ", line);

  -- write the line back out to the socket
--[=[
  local body = "<html><body>"..line.."</body></html>\r\n"
  local content = [[
HTTP/1.1 200 OK
Connection: close

]]..body
--]=]

  --socket:send(content, #content); 
  socket:closeDown();
end


-- For every new connection
-- spawn a task to deal with it
local function OnAccept(param, sock)
  -- create a socket wrapper
  local socket = NativeSocket:init(sock, false);

  spawn(handleNewConnection, param, socket)

end

local server = SocketServer(8080, OnAccept);

server:run();
