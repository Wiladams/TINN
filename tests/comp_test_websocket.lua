local connect = function()

	local WebSocket = require("WebSocket");
	local UrlParser = require("url");
	local NetStream = require("IOCPNetStream");

	local deviceurl = "ws://127.0.0.1:6437/"
	local urlparts = UrlParser.parse(deviceurl, {port="80", path="/", scheme="ws"});

	local stream, err = NetStream:create(urlparts.host, urlparts.port);

	if not stream then
		print("LeapInterface(), NetStream, ERROR: ", stream, err);
		return false, err
	end

	local socketstream, err = WebSocket(stream);
print("socketstream: ", socketstream, err);

	local origin = "http://localhost"
	local handshake = socketstream:InitiateClientHandshake(deviceurl, origin);

print("HANDSHAKE: ", handshake);

	return socketstream
end

return connect