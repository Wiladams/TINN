-- comp_getbing.lua
--IOProcessor = require("IOProcessor");
local IOCPNetStream = require("IOCPNetStream");
local HttpRequest = require("HttpRequest");
local HttpResponse = require("HttpResponse");
local HttpChunkIterator = require("HttpChunkIterator");

local hostname = "www.google.com"

local netstream, err = IOCPNetStream:create(hostname, 80);

local function GET()

	if not netstream then
		print("netstream, ERROR: ", err);
		return false, err;
	end

	local request = HttpRequest.new("GET", "/ping", {Host= hostname});
	request:Send(netstream);

	--local request = "GET / HTTP/1.1\r\nHost: www.google.com\r\n\r\n";

--print("== REQUEST ==");
--print(request);
--print("** REQUEST **");

	--local bytes, err = netstream:writeString(request);

--print("after writeLine: ", bytes, err);
	local response = HttpResponse.Parse(netstream);
	print("== RESPONSE ==")
	print(response.Status, response.Phrase);

	for chunk in HttpChunkIterator.ReadChunks(response) do
		print(chunk);
	end

	exit();
end

IOProcessor:spawn(GET);

