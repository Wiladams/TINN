-- HttpServer.lua
local SocketServer = require("SocketServer")

local NativeSocket = require("NativeSocket")
local NetStream = require("NetStream");
local WebRequest = require("WebRequest");
local WebResponse = require("WebResponse");
local URL = require("url");
local Functor = require("Functor")

local HttpServer = {}
setmetatable(HttpServer, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local HttpServer_mt = {
	__index = HttpServer;
}

HttpServer.init = function(self, port, onRequest)
	local obj = {
		OnRequest = onRequest;
	};
	setmetatable(obj, HttpServer_mt);
	
	obj.Listener = SocketServer(port, Functor(obj.OnAccept, obj));

	return obj;
end

HttpServer.create = function(self, port, onRequest)
	return self:init(port, onRequest);
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
		self.OnRequest(request, response);
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
	return self.Listener:run();
end

return HttpServer;
