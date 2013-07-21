
local ffi = require("ffi");

local SocketServer = require("SocketServer");
local IOCPSocket = require("IOCPSocket");
local IOCPNetStream = require("IOCPNetStream")

local OnAccept = function(param, sock)
  -- create a socket wrapper
  local socket = IOCPSocket:init(sock, false);
  local netstream = IOCPNetStream:init(socket);

  -- read a line from the socket
  --local bufflen = 1500;
  --local buff = ffi.new("uint8_t[1500]");
  --local bytesread, err = IOCPSocketIo.ReadLine(socket, buff, bufflen);
  --print("LINE: ", bytesread, err);
  local line, err = netstream:readLine();
  print("LINE: ", line);

  -- write the line back out to the socket
  socket:send(line, #line); 
  --socket:send(buff, bytesread); 
end

local server = SocketServer(9090, OnAccept);

server:run();


