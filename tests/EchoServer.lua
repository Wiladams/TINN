--local SocketServer = require("SocketServer2");
local SocketServer = require("SocketServer");

local OnData = function(socket, buff, bufflen)  
  socket:send(buff, bufflen); 
end

local server = SocketServer(9090);
server:run(OnData);

