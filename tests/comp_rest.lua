
local restops = require("restops");

local Collections = require ("Collections");

local FileStream = require ("FileStream");
local NetStream = require ("NetStream");
local SocketPool = require("SocketPool");

local URL = require ("url");
local HttpRequest = require ("HttpRequest");
local HttpResponse = require("HttpResponse");
local chunkiter = require ("HttpChunkIterator");

local sout = FileStream.new(io.stdout)


local GET = function(resource, showheaders, onfinish)
--print("http_get: ", resource, showheaders, onfinish)
	if not resource then
		return onfinish(nil, "no resource specified");
	end

	local urlparts = URL.parse(resource, {port="80", path="/", scheme="http"});
	local hostname = urlparts.host
	local path = urlparts.path
	local port = urlparts.port

	-- Open up a stream to get the real content
	local resourcestream, err = NetStream.Open(hostname, port);

	if not resourcestream then
		return onfinish(nil, err)
	end

	-- Send a proper http request to the service
	if port and port ~= "80" then
		hostname = hostname..':'..port
	end

	local headers = {
		["Host"]		= hostname,
		["Connection"]	= "close",
	}
	if urlparts.query then
		path = path..'?'..urlparts.query
	end

	local request = HttpRequest.new("GET", path, headers, nil);
	local success, err = request:Send(resourcestream);

	if not success then
		return onfinish(false, err)
	end

	local response, err = HttpResponse.Parse(resourcestream);

	if response then
		-- successful read of preamble
		-- so print it out, and keep out of queue
		if showheaders then
			response:WritePreamble(sout);
		end

		for chunk, err in chunkiter.ReadChunks(response) do
			-- do nothing
			-- but read the chunks
			io.write(chunk);
		end
		result = "OK";
	else
		result = err;
	end
	
	return onfinish(result);
end

OnMessage = function(msg)
	if msg.Message == restops.GET then
	
	end
end
