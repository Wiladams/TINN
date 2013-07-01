-- test_nativewindow.lua

local synch = require("core_synch_l1_2_0");
local WindowKind = require("WindowKind");
local NativeWindow = require("NativeWindow");

local WindowProc = function(hwnd, msg, wparam, lparam)
-- lookup which window object is associated with the
-- window handle
	local winptr = ffi.cast("intptr_t", hwnd)
	local winnum = tonumber(winptr)


print(string.format("WindowProc: 0x%x, Window: 0x%x, win: %s", msg, winnum));


	-- If we have reached here, then do default message processing
	return User32.Lib.DefWindowProcA(hwnd, msg, wparam, lparam);
end


local windowkind, err = WindowKind:create("test_windowkind");

if not windowkind then
	print("Window kind not created, ERROR: ", err);
	return false, err;
end


for k,v in pairs(windowkind) do
	print(k,v);
end

local win = windowkind:createWindow(640, 480, "Window Title");
win:Show();
win:Maximize();

synch.Sleep(5000);