local ffi = require("ffi");
local bit = require("bit");
local band = bit.band;
local bor = bit.bor;
local rshift = bit.rshift;

local u32 = require("user32_ffi");
local vkeys = require("vkeys");

local buttonmsgmap = {}
buttonmsgmap[u32.WM_LBUTTONDOWN]	= VK_LBUTTON;
buttonmsgmap[u32.WM_LBUTTONUP]		= VK_LBUTTON;
buttonmsgmap[u32.WM_LBUTTONDBLCLK]	= VK_LBUTTON;
buttonmsgmap[u32.WM_RBUTTONDOWN]	= VK_RBUTTON;
buttonmsgmap[u32.WM_RBUTTONUP]		= VK_RBUTTON;
buttonmsgmap[u32.WM_RBUTTONDBLCLK]	= VK_RBUTTON;
buttonmsgmap[u32.WM_MBUTTONDOWN]	= VK_MBUTTON;
buttonmsgmap[u32.WM_MBUTTONUP]		= VK_MBUTTON;
buttonmsgmap[u32.WM_MBUTTONDBLCLK]	= VK_MBUTTON;
buttonmsgmap[u32.WM_XBUTTONDOWN]	= VK_XBUTTON1;
buttonmsgmap[u32.WM_XBUTTONUP]		= VK_XBUTTON1;
buttonmsgmap[u32.WM_XBUTTONDBLCLK]	= VK_XBUTTON1;

local LOWORD = function(param)
	return band(param, 0x0000ffff);
end

local HIWORD = function(param)
	return rshift(band(param, 0xffff0000), 16);
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
