
local Desktop = require("Desktop");

function test_GetDesktops()
	local desktops = Desktop:desktopNames();
	for _, name in ipairs(desktops) do 
		print(name);
	end
end

function test_desktopwindows()
	local dtop = Desktop:openThreadDesktop();

	local wins = dtop:getWindowHandles();

	for winid, hwnd in pairs(wins) do
		print("HWND: ", winid, hwnd);
	end
end


test_GetDesktops();
--test_desktopwindows();
