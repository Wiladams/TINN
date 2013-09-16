local Computicle = require("Computicle");


local acceptor = Computicle:load("comp_socketacceptor", {port=9090});
local webserver = Computicle:load("comp_webserver");

---[==[
webserver.HandleSingleRequest = function(stream)
	print("HandleSingleRequest: ", stream);

	local HttpRequest = require "HttpRequest"
	local HttpResponse = require "HttpResponse"
	local URL = require("url");
	local FileService = require("FileService");

	local request, err  = HttpRequest.Parse(stream);


--[[	
-- at this point, the stream is sitting waiting for 
-- its preamble to be read




	if not request then
		print("HandleSingleRequest, Dump stream: ", err)
		return 
	end

	local urlparts = URL.parse(request.Resource)
	

	if urlparts.path == "/ping" then
		--print("echo")
		local response = HttpResponse.Open(stream)
		response:writeHead("204")
		response:writeEnd();
	else
		local filename = './wwwroot'..urlparts.path;
	
		local response = HttpResponse.Open(stream);

		FileService.SendFile(filename, response)
	end
--]]
end
--]==]

acceptor.sink1 = webserver;

acceptor:waitForFinish();
