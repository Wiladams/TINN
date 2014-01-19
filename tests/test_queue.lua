-- test_collections.lua
local Stopwatch = require("StopWatch")
local Collections = require("Collections");
local queue = Collections.Queue();

local clock = Stopwatch();

local iter = 0
local function foo()
	iter = iter + 1;
	return "william", iter
end

while iter <= 200000 do
	local res = {foo()}
	queue:Enqueue(res)
	local tbl = queue:Dequeue()
	if not tbl then
		break
	end
	tbl[3] = iter
	--print(tbl[1], tbl[2])
end

print("trans per second: ", iter / clock:Seconds())


