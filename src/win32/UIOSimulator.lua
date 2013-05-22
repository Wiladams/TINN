


local ffi = require ("ffi")
local bit = require ("bit")
local band = bit.band
local bor = bit.bor

local User32 = require ("User32")
local Kernel32 = require("win_kernel32");




--[[
typedef struct tagMOUSEINPUT {
  LONG      dx;
  LONG      dy;
  DWORD     mouseData;
  DWORD     dwFlags;
  DWORD     time;
  ULONG_PTR dwExtraInfo;
} MOUSEINPUT, *PMOUSEINPUT;
--]]

local UIOSimulator = {
	ScreenWidth = User32.GetSystemMetrics(User32.FFI.CXSCREEN);
	ScreenHeight = User32.GetSystemMetrics(User32.FFI.CYSCREEN);
}



UIOSimulator.MouseDown = function(x, y, which)
	local dx = math.ceil(x*65536/UIOSimulator.ScreenWidth)
	local dy = math.ceil(y*65536/UIOSimulator.ScreenHeight)

	-- construct mouseinput structure
	-- call sendinput
	local minput = ffi.new("INPUT");
	minput.type = ffi.C.INPUT_MOUSE;
	minput.mi.dx = dx;
	minput.mi.dy = dy;
	minput.mi.mouseData = 0;
	minput.mi.dwFlags =  bor(ffi.C.MOUSEEVENTF_ABSOLUTE, ffi.C.MOUSEEVENTF_LEFTDOWN);
	
	local written, err = User32.SendInput(1, minput, ffi.sizeof(minput))
end

UIOSimulator.MouseUp = function(x, y, which)
--print("InjectMouseUp")
	local dx = math.ceil(x*65536/UIOSimulator.ScreenWidth)
	local dy = math.ceil(y*65536/UIOSimulator.ScreenHeight)
	-- construct mouseinput structure
	-- call sendinput
	local minput = ffi.new("INPUT");
	minput.type = ffi.C.INPUT_MOUSE;
	minput.mi.dx = dx;
	minput.mi.dy = dy;
	minput.mi.mouseData = 0;
	minput.mi.dwFlags =  bor(ffi.C.MOUSEEVENTF_ABSOLUTE, ffi.C.MOUSEEVENTF_LEFTUP);
	
	local written, err = User32.SendInput(1, minput, ffi.sizeof(minput))
end

UIOSimulator.MouseMove = function(x, y)
	local dx = math.ceil(x*65536/UIOSimulator.ScreenWidth)
	local dy = math.ceil(y*65536/UIOSimulator.ScreenHeight)

	-- construct mouseinput structure
	-- call sendinput
	local sinput = ffi.new("INPUT");
	sinput.type = ffi.C.INPUT_MOUSE;
	sinput.mi.dx = dx;
	sinput.mi.dy = dy;
	sinput.mi.mouseData = 0;
	sinput.mi.dwFlags =  bor(ffi.C.MOUSEEVENTF_ABSOLUTE, ffi.C.MOUSEEVENTF_MOVE);
	
	local written, err = User32.SendInput(1, sinput, ffi.sizeof(sinput))
	
	--print(written, err);
end


--[[
typedef struct tagKEYBDINPUT {
  WORD      wVk;
  WORD      wScan;
  DWORD     dwFlags;
  DWORD     time;
  ULONG_PTR dwExtraInfo;
} KEYBDINPUT, *PKEYBDINPUT;
--]]
UIOSimulator.KeyDown = function(code)
	local sinput = ffi.new("INPUT");
	sinput.type = ffi.C.INPUT_KEYBOARD;
	sinput.ki.wVk = code;
	sinput.ki.wScan = 0;
	--sinput.ki.dwFlags = 0;
	--sinput.ki.time = 0;
	--sinput.ki.dwExtraInfo = nil;
		
	local written, err = User32.SendInput(1, sinput, ffi.sizeof(sinput))
end

UIOSimulator.KeyUp = function(code)
	local sinput = ffi.new("INPUT");
	sinput.type = ffi.C.INPUT_KEYBOARD;
	sinput.ki.wVk = code;
	sinput.ki.wScan = 0;
	sinput.ki.dwFlags = ffi.C.KEYEVENTF_KEYUP;
	--sinput.ki.time = 0;
	--sinput.ki.dwExtraInfo = nil;
		
	local written, err = User32.SendInput(1, sinput, ffi.sizeof(sinput))
end

local InjectKeyboardActivity = function(flags, code)
	local sinput = ffi.new("INPUT");
	sinput.type = ffi.C.INPUT_KEYBOARD;
	sinput.ki.wVk = code;
	sinput.ki.wScan = 0;
	sinput.ki.dwFlags = ffi.C.KEYEVENTF_SCANCODE;
	--sinput.ki.time = 0;
	--sinput.ki.dwExtraInfo = nil;
	
	if band(flags, KBD_FLAGS_RELEASE) then
		sinput.ki.dwFlags = bor(sinput.ki.dwFlags, KEYEVENTF_KEYUP);
	end
	
	if band(flags, KBD_FLAGS_EXTENDED) then
		sinput.ki.dwFlags = bor(sinput.ki.dwFlags, KEYEVENTF_EXTENDEDKEY);
	end
	
	local written, err = User32.SendInput(1, sinput, ffi.sizeof(sinput))
	
	--print(written, err);
end

return UIOSimulator

