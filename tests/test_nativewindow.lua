-- test_nativewindow.lua

local WindowKind = require("WindowKind");
local NativeWindow = require("NativeWindow");
local Application = require("Application");



local windowkind, err = WindowKind:create("test_windowkind");

if not windowkind then
	print("Window kind not created, ERROR: ", err);
	return false, err;
end



local function main()
	local win = windowkind:createWindow(640, 480, "Window Title");
	win:Show();
	--win:Maximize();

	sleep(5000);
end

run(main)
