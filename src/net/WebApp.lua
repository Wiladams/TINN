-- WebApp.lua

local HttpServer = require("HttpServer")
local ResourceMapper = require("ResourceMapper");
local URL = require("url");
local FileService = require("FileService");


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

-- Create a default resource mapper
-- which will simply serve up files, and
-- nothing else.
WebApp.DefaultResourceMap = {
	["/"]		= {name="/",
		GET = function(request, response)
    		local absolutePath = string.gsub(URL.unescape(request.Url.path), "%.%.", '%.');
			local filename = './wwwroot'..absolutePath;
			FileService.SendFile(filename, response)
			return false;
		end,
	};
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
	resourceMap = resourceMap or WebApp.DefaultResourceMap
	port = port or 8080


	local obj = {}
	obj.ServicePort = port;
	obj.Server = HttpServer(port, OnRequest, obj);
	obj.ResourceMap = resourceMap;
	obj.Mapper = ResourceMapper(resourceMap);
	
	setmetatable(obj, WebApp_mt)

	return obj;
end

WebApp.create = function(self, ...)
--print("WebApp.create() - BEGIN")
	return self:init(...)
end

WebApp.run = function(self, ...)
--print("WebApp.run() - BEGIN")
	return self.Server:run(...);
end

return WebApp
