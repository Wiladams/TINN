
local ffi = require("ffi");

local IOProcessor = require("IOProcessor");
local IOCPSocket = require("IOCPSocket");
local ws2_32 = require("ws2_32");


IOProcessor:setMessageQuanta(5);

SocketServer = {}
setmetatable(SocketServer, {
  __call = function(self, ...)
    return self:create(...);
  end,
});

SocketServer_mt = {
  __index = SocketServer;
}

SocketServer.init = function(self, socket, onAccept, onAcceptParam)
--print("SocketServer.init: ", socket, onAccept, onAcceptParam)
  local obj = {
    ServerSocket = socket;
    OnAccept = onAccept;
    OnAcceptParam = onAcceptParam;
  };

  setmetatable(obj, SocketServer_mt);

  return obj;
end

SocketServer.create = function(self, port, onAccept, onAcceptParam, autoclose)
  autoclose = autoclose or false;
  port = port or 9090;
--print("SocketServer:create(): ", port, onAccept, onAcceptParam);

  local socket, err = IOProcessor:createServerSocket({port = port, backlog = 15, autoclose = autoclose});
	
  if not socket then 
    print("Server Socket not created!!")
    return nil, err
  end

  return self:init(socket, onAccept, onAcceptParam);
end


SocketServer.handleAccepted = function(self, sock)
print("SocketServer.handleAccepted(): ", sock);

  if self.OnAccept then
--print("CALLING self.OnAccept")
    return self.OnAccept(self.OnAcceptParam, sock);
  else
print("NO OnAccept available, closing  socket...")
    ws2_32.closesocket(sock);
  end
end

-- The primary application loop
SocketServer.loop = function(self)

  while true do
    local sock, err = self.ServerSocket:accept();

    if sock then
      self:handleAccepted(sock);
    else
       print("Accept ERROR: ", err);
    end

    collectgarbage();
  end
end

SocketServer.run = function(self)
  print("SocketServer.run()");
  spawn(self.loop, self);
  run();
end


return SocketServer;

