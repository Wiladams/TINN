
local Desktop = require("Desktop");

function test_GetDesktops()
	local desktops = Desktop:desktopNames();
	for _, name in ipairs(desktops) do 
		print(name);
	end
end

test_GetDesktops()

