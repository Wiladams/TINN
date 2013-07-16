
local Computicle = require("Computicle");
local Messenger = require("Messenger");

local test_single = function()
	local comp1 = Computicle:create([[print("Hello World!"); exit()]]);
	comp1:waitForFinish();
end


local test_parallel = function()
local comp1 = Computicle:create([[print("Hello World!"); exit()]]);
local comp2 = Computicle:create([[
	for i=1,10 do
		print(string.format("Counter: %d", i));
	end

	exit();
]]);

print("Finish: ", comp1:waitForFinish());
print("Finish: ", comp2:waitForFinish());
end

local test_loadandrun = function()
	print("Finish: ", Computicle:loadAndRun("helloworld"));

end


test_single();
--test_parallel();

--test_loadandrun();



