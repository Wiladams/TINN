
local Monitor = require("Monitor")



for mon in Monitor:Monitors() do 
	print("Monitor: ", mon)
end
