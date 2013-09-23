local ffi = require("ffi");
local bit = require("bit");
local band = bit.band;
local bor = bit.bor;
local rshift = bit.rshift;

local u32 = require("user32_ffi");
local vkeys = require("vkeys");

local buttonmsgmap = {}
buttonmsgmap[u32.WM_LBUTTONDOWN]	= vkeys.LBUTTON;
buttonmsgmap[u32.WM_LBUTTONUP]		= vkeys.LBUTTON;
buttonmsgmap[u32.WM_LBUTTONDBLCLK]	= vkeys.LBUTTON;
buttonmsgmap[u32.WM_RBUTTONDOWN]	= vkeys.RBUTTON;
buttonmsgmap[u32.WM_RBUTTONUP]		= vkeys.RBUTTON;
buttonmsgmap[u32.WM_RBUTTONDBLCLK]	= vkeys.RBUTTON;
buttonmsgmap[u32.WM_MBUTTONDOWN]	= vkeys.MBUTTON;
buttonmsgmap[u32.WM_MBUTTONUP]		= vkeys.MBUTTON;
buttonmsgmap[u32.WM_MBUTTONDBLCLK]	= vkeys.MBUTTON;
buttonmsgmap[u32.WM_XBUTTONDOWN]	= vkeys.XBUTTON1;
buttonmsgmap[u32.WM_XBUTTONUP]		= vkeys.XBUTTON1;
buttonmsgmap[u32.WM_XBUTTONDBLCLK]	= vkeys.XBUTTON1;

local LOWORD = function(param)
	return band(param, 0x0000ffff);
end

local HIWORD = function(param)
	return band(rshift(param, 16), 0x0000ffff);
end


-- This fuctions is called with typical windows message parameters.
-- It will turn them into a table structure which is either keyboard
-- or mouse event.
local sign = function(x)
	return x / math.abs(x);
end


local ConvertKeyMouse = function(hWnd, msg, wParam, lParam)
	if msg == u32.WM_CHAR then
		return {kind="keychar", char=string.char(wParam)}
	end

	if msg == u32.WM_KEYDOWN then
		return {kind="keydown", vkey=tonumber(wParam)}
	end

	if msg == u32.WM_KEYUP then
		return {kind="keyup", vkey=tonumber(wParam)}
	end

	if msg == u32.WM_MOUSEMOVE then
		return {kind="mousemove", x=LOWORD(lParam), y=HIWORD(lParam), modifiers = LOWORD(wParam)}
	end

	if msg == u32.WM_LBUTTONDOWN or msg == u32.WM_RBUTTONDOWN or
		msg == u32.WM_MBUTTONDOWN or msg == u32.WM_XBUTTONDOWN then
		return {kind="mousedown", x=LOWORD(lParam), y=HIWORD(lParam), modifiers = LOWORD(wParam), button=buttonmsgmap[msg]}
	end

	if msg == u32.WM_LBUTTONUP or msg == u32.WM_RBUTTONUP or
		msg == u32.WM_MBUTTONUP or msg == u32.WM_XBUTTONUP then

		return {kind="mouseup", x=LOWORD(lParam), y=HIWORD(lParam), modifiers = LOWORD(wParam), button=buttonmsgmap[msg]}
	end

	if msg == u32.WM_MOUSEWHEEL then
		return {kind="mousewheel", x=LOWORD(lParam), y=HIWORD(lParam), modifiers = LOWORD(wParam), delta = sign(tonumber(ffi.cast("short",HIWORD(wParam))))}
	end
end


return {
	ConvertKeyMouse = ConvertKeyMouse,
	VKeys = vkeys,
}
