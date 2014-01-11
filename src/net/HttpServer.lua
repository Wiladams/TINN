-- HttpServer.lua
local SocketServer = require("SocketServer")

local NativeSocket = require("NativeSocket")
local NetStream = require("NetStream");
local WebRequest = require("WebRequest");
local WebResponse = require("WebResponse");
local URL = require("url");

local HttpServer = {}
setmetatable(HttpServer, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local HttpServer_mt = {
	__index = HttpServer;
}

HttpServer.init = function(self, port, onRequest, onRequestParam)
	local obj = {
		OnRequest = onRequest;
		OnRequestParam = onRequestParam;
	};
	setmetatable(obj, HttpServer_mt);
	
	obj.SocketServer = SocketServer(port, HttpServer.OnAccept, obj);

	return obj;
end

HttpServer.create = function(self, port, onRequest, onRequestParam)
	return self:init(port, onRequest, onRequestParam);
end


--[[
	Instance Methods
--]]
HttpServer.HandleRequestFinished = function(self, request)
	-- Once we're done with this single request
	-- send it back aroud again in case there is
	-- more to be processed.
	local sock = request.DataStream.Socket:getNativeSocket();
	self:OnAccept(sock);
end

HttpServer.HandlePreamblePending = function(self, sock)
  local socket = NativeSocket:init(sock);
  local stream, err = NetStream:init(socket);

  if self.OnRequest then
	local request, err  = WebRequest:Parse(stream);

	if request then
		request.Url = URL.parse(request.Resource);
		local response = WebResponse:OpenResponse(request.DataStream)
		self.OnRequest(self.OnRequestParam, request, response);
	else
		print("HandleSingleRequest, Dump stream: ", err)
		socket:closeDown();
	end
  else
  	socket:closeDown();
  end
end

HttpServer.OnAccept = function(self, sock)
--print("HttpServer.OnAccept(): ", self, sock, self.OnRequest);
	spawn(self.HandlePreamblePending, self, sock);
end

HttpServer.run = function(self)
	return self.SocketServer:run();
end

return HttpServer;
