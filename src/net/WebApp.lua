-- WebApp.lua

local IOProcessor = require("IOProcessor")
local HttpServer = require("HttpServer")
local ResourceMapper = require("ResourceMapper");


local WebApp = {}
setmetatable(WebApp, {
	__call = function(self, ...)
		print("WebApp.__call() - BEGIN")
		return self:create(...);
	end,
})
local WebApp_mt = {
	__index = WebApp,
}

-- Generic web server
-- utilize a resource map to handle all the requests
local OnRequest = function(param, request, response)
	local handler, err = param.Mapper:getHandler(request)

	-- recycle the socket, unless the handler explictly says
	-- it will do it, by returning 'true'
	if handler then
		if not handler(request, response) then
			param.Server:HandleRequestFinished(request);
		end
	else
		print("NO HANDLER: ", request.Url.path);
		-- send back content not found
		response:writeHead(404);
		response:writeEnd();

		-- recylce the request in case the socket
		-- is still open
		param.Server:HandleRequestFinished(request);
	end
end

WebApp.init = function(self, resourceMap, port)
	port = port or 8080

	if not resourceMap then
		return nil;
	end

	local obj = {}
	obj.Server = HttpServer(port, OnRequest, obj);
	obj.ResourceMap = resourceMap;
	obj.Mapper = ResourceMapper(resourceMap);
	
	setmetatable(obj, WebApp_mt)

for k,v in pairs(obj) do
	print(k,v)
end

	return obj;
end

WebApp.create = function(self, ...)
print("WebApp.create() - BEGIN")
	return self:init(...)
end

WebApp.run = function(self, ...)
print("WebApp.run() - BEGIN")
	return self.Server:run(...);
end

return WebApp
