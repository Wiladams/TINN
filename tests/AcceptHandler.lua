-- AcceptHandler.lua

local ffi = require("ffi");

local HandleNewConnection = function(sock)
	print("HandleNewConnection: ", sock);

	-- create a stream to wrap the raw socket
	local res, err = accepted:SetNonBlocking(true);
	res, err = accepted:SetNoDelay(true);
	res, err = accepted:SetKeepAlive(true, 10*1000, 500);
	local netstream = NetStream.new(accepted, CoSocketIo)

	PreamblePending:Enqueue(netstream);
end


while true do
	local msg = SELFICLE:getMessage();
	msg = ffi.cast("ComputicleMsg *", msg);

	HandleNewConnection(msg.Param1);

	SELFICLE:freeData(msg);
end


