-- iocpserver.lua
local SocketServer = require("SocketServer")

local IOCPSocket = require("IOCPSocket")
local IOCPNetStream = require("IOCPNetStream");
local WebRequest = require("WebRequest");
local WebResponse = require("WebResponse");
local URL = require("url");

HttpServer = {}
setmetatable(HttpServer, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

HttpServer_mt = {
	__index = HttpServer;
}

HttpServer.init = function(self, port, onRequest, onRequestParam)
	local obj = {
		OnRequest = onRequest;
		OnRequestParam = onRequestParam;
	};
	setmetatable(obj, HttpServer_mt);
	
	obj.SocketServer = SocketServer(port, HttpServer.OnAccept, obj);
	obj.SocketServer.OnAccept = self.OnAccept;

	return obj;
end

HttpServer.create = function(self, port, onRequest, onRequestParam)
	return self:init(port, onRequest, onRequestParam);
end


--[[
	Instance Methods
--]]
HttpServer.OnAccept = function(self, sock)
--print("HttpServer.OnAccept(): ", self, sock, self.OnRequest);

  local socket = IOCPSocket:init(sock, IOProcessor);
  local stream, err = IOCPNetStream:init(socket);

  if self.OnRequest then
	local request, err  = WebRequest:Parse(stream);

	if request then
		request.Url = URL.parse(request.Resource);
		local response = WebResponse:OpenResponse(request.DataStream)
		self.OnRequest(self.OnRequestParam, request, response);
	else
		print("HandleSingleRequest, Dump stream: ", err)
	end
  else
  	-- do nothing and let the socket close
  end
end

HttpServer.run = function(self)
	return self.SocketServer:run();
end

return HttpServer;
