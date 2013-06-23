local Computicle = require("Computicle");

--local comp = Computicle:create("print('Hello, World')");
local comp = Computicle:create([[
gIdleTimeout = 500

require("DaytimeClient");

	local dtc, err = GetDateAndTime("localhost");
	
	--if not dtc then
	--	print("test_DaytimeClient.lua - ERROR: ", err);
	--	break;
	--end

	print(dtc);

	--collectgarbage();
]]);


comp:waitForFinish();
