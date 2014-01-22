-- WebApp.lua

local HttpServer = require("HttpServer")
local ResourceMapper = require("ResourceMapper");
local URL = require("url");
local FileService = require("FileService");
local Functor = require("Functor")

-- Create a default resource mapper
-- which will simply serve up files, and
-- nothing else.
local DefaultResourceMap = {
	["/"]		= {name="/",
		GET = function(request, response)
    		local absolutePath = string.gsub(URL.unescape(request.Url.path), "%.%.", '%.');
			local filename = './wwwroot'..absolutePath;
			FileService.SendFile(filename, response)
			return false;
		end,
	};
}

local WebApp = {}
setmetatable(WebApp, {
	__call = function(self, ...)
		--print("WebApp.__call() - BEGIN")
		return self:create(...);
	end,
})
local WebApp_mt = {
	__index = WebApp,
}






WebApp.init = function(self, resourceMap, port)
	resourceMap = resourceMap or DefaultResourceMap
	port = port or 8080


	local obj = {
		ServicePort = port;
		ResourceMap = resourceMap;
		Mapper = ResourceMapper(resourceMap)
	}
	setmetatable(obj, WebApp_mt)

	obj.Server = HttpServer(port, Functor(obj.OnRequest, obj));	

	return obj;
end

function WebApp.create(self, ...)
--print("WebApp.create() - BEGIN")
	return self:init(...)
end

-- Generic web server
-- utilize a resource map to handle all the requests
function WebApp.OnRequest(self, request, response)
	local handler, err = self.Mapper:getHandler(request)

	-- recycle the socket, unless the handler explictly says
	-- it will do it, by returning 'true'
	if handler then
		if not handler(request, response) then
			self.Server:HandleRequestFinished(request);
		end
	else
		print("NO HANDLER: ", request.Url.path);
		-- send back content not found
		response:writeHead(404);
		response:writeEnd();

		-- recylce the request in case the socket
		-- is still open
		self.Server:HandleRequestFinished(request);
	end

end

WebApp.run = function(self, ...)
--print("WebApp.run() - BEGIN")
	return self.Server:run(...);
end

return WebApp
