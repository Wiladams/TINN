-- TokenRing.lua
local Computicle = require("Computicle");

local TokenRing = {
	Messages = {
		DELIVER = 101,
	},

}
setmetatable(TokenRing, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

TokenRing_mt = {
	__index = TokenRing,
}


TokenRing.init = function(self, nodelist)
	local obj = {
		NodeList = nodelist;
	}
	setmetatable(obj, TokenRing_mt);

	return obj;
end


TokenRing.create = function(self, nEntries)
print("TokenRing.create: ", nEntries);

	local nodelist = {}
	for i=1,nEntries do
		local node = Computicle:load("comp_tokenring_node");
		node.NodeId = i;
		table.insert(nodelist, node);

		-- connect the nodes together
		if i > 1 then
			nodelist[i-1].next = node;
		end

		-- link the ending node back to the beginning node
		if i == nEntries then
			node.next = nodelist[1];
		end
	end

	return self:init(nodelist);
end

TokenRing.deliver = function(self, msg, nodeid)
	nodeid = nodeid or 1;

	self.NodeList[1]:postMessage(TokenRing.Messages.DELIVER, nodeid, msg)
end

TokenRing.awaitFinish = function(self)
	return self.NodeList[1]:waitForFinish();
end

return TokenRing
