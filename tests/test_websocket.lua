-- test_websocket.lua

local ffi = require("ffi");
local WebSocket = require("WebSocket");
local UrlParser = require("url");
local NetStream = require("IOCPNetStream");

local connect = require("comp_test_websocket");

local main = function()
--[[
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
--]]

	local connection = connect();

	while true do
		local frame = connection:ReadFrame();
		print("== FRAME ==")
		print(ffi.string(frame.Data, frame.DataLength));
	end
end

run(main);

