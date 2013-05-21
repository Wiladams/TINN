-- test_collections.lua

local Collections = require("Collections");

local stack = Collections.Stack();

for i=1,10 do
	--print("push: ", i)
	stack:push(i);
end

print("Len: ", stack:len());

while true do
	local item = stack:pop();
	--print("pop: ", item)
	if not item then
		break
	end

	print(item);
end
