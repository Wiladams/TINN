local Computicle = require("Computicle");



local comp2 = Computicle:create([[
local ffi = require("ffi");

while true do
	local msg = SELFICLE:getMessage();
	msg = ffi.cast("ComputicleMsg *", msg);

	print(msg.Message*10);
	SELFICLE.Heap:free(msg);
end
]]);

local sinkstone = comp2:getStoned();


local comp1 = Computicle:create([[
local ffi = require("ffi");

local stone = _params.sink;
stone = ffi.cast("Computicle_t *", stone);

local sinkComp = Computicle:init(stone.HeapHandle, stone.IOCPHandle, stone.ThreadHandle);

for i = 1, 10 do
	sinkComp:postMessage(i);
end
]], {sink = sinkstone});


print("Finish 1: ", comp1:waitForFinish());

print("Finish 2: ", comp2:waitForFinish());
