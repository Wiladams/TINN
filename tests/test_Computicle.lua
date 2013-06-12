
local Computicle = require("Computicle");

local test_compute = function()
local comp1 = Computicle:compute([[print("Hello World!");]]);
local comp2 = Computicle:compute([[
	for i=1,10 do
		print("Counter: ", i);
	end
]]);

print("Finish: ", comp1:waitForFinish());
print("Finish: ", comp2:waitForFinish());
end

local test_computicle = function()
	local comp = Computicle:create([[print("Hello World!")]]);
	comp:resume();

	print("Finish: ", comp:waitForFinish());
end


--test_computicle();

test_compute();


