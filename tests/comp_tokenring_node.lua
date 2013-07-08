-- comp_tokenring_node.lua
TokenRing = require("TokenRing");

OnMessage = function(msg)
	--print(string.format("OnMessage: %d", msg.Message));

	if msg.Message == TokenRing.Messages.DELIVER then
		if msg.Param1 == NodeId then
			print("================");
			print("receiving node: ", NodeId);
			print(" delivery Node: ", msg.Param1);
			print(" delivery data: ", msg.Param2);
		else
			if msg.Param1 ~= NodeId then
				next:receiveMessage(msg.Message, msg.Param1, msg.Param2);
			end
		end
	end
end
