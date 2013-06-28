local Computicle = require("Computicle");

--local comp = Computicle:create("print('Hello, World')");
local comp = Computicle:create([[
gIdleTimeout = 5

require("DaytimeClient");
local StopWatch = require("StopWatch");

sw = StopWatch();

for i=1,50000 do
	local dtc, err = GetDateAndTime("localhost");
	
	print(dtc, i/sw:Seconds());
end

	exit();
]]);


comp:waitForFinish();
