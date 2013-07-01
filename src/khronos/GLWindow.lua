--
-- GLWindow.lua
--


local ffi = require "ffi"
local bit = require "bit"
local bor = bit.bor
local band = bit.band;
local rshift = bit.rshift;


local errorhandling = require("core_errorhandling_l1_1_1");

local Gdi32 = require ("GDI32");
local User32 = require ("user32_ffi");
local WindowKind = require("WindowKind");


local StopWatch = require ("StopWatch");

local GLContext = require("GLContext");
local libraryloader = require("core_libraryloader_l1_1_1");



local GLWindow = {
	Defaults = {
		ClassName = "LuaWindow",
		Title = "Game Window",
		Origin = {10,10},
		Extent = {320, 240},
		FrameRate = 30,
	},
	WindowMap = {},
}
setmetatable(GLWindow, {
	__call = function(self, ...)
		return self:create(...);
	end,
});
local GLWindow_mt = {
	__index = GLWindow;
}

--[[
	for window creation, we should see the
	following sequence
        WM_GETMINMAXINFO 		= 0x0024
        WM_NCCREATE 			= 0x0081
        WM_NCCALCSIZE 			= 0x0083
        WM_CREATE 				= 0x0001

	Then, after ShowWindow is called
		WM_SHOWWINDOW 			= 0x0018,
		WM_WINDOWPOSCHANGING 	= 0x0046,
		WM_ACTIVATEAPP 			= 0x001C,

	Closing Sequence
		WM_CLOSE 				= 0x0010,
		...
		WM_ACTIVATEAPP 			= 0x001C,
		WM_KILLFOCUS			= 0x0008,
		WM_IME_SETCONTEXT 		= 0x0281,
		WM_IME_NOTIFY 			= 0x0282,
		WM_DESTROY 				= 0x0002,
		WM_NCDESTROY 			= 0x0082,
--]]
local LOWORD = function(param)
	return band(param, 0x0000ffff);
end

local HIWORD = function(param)
	return rshift(band(param, 0xffff0000), 16);
end

local WindowProc = function(hwnd, msg, wparam, lparam)
-- lookup which window object is associated with the
-- window handle
	local winptr = ffi.cast("intptr_t", hwnd)
	local winnum = tonumber(winptr)

	local win = GLWindow.WindowMap[winnum]

--print(string.format("WindowProc: 0x%x, Window: 0x%x, win: %s", msg, winnum, tostring(win)))

	-- if we have a win, then the window is capable
	-- of handling the message
	if win then
		--print(string.format("MSG: 0x%x",msg));

		if (win.MessageDelegate) then
			result = win.MessageDelegate(hwnd, msg, wparam, lparam)
			return result
		end

		if (msg == User32.WM_DESTROY) then
			return win:OnDestroy()
		end

		if (msg >= User32.WM_MOUSEFIRST and msg <= User32.WM_MOUSELAST) or
				(msg >= User32.WM_NCMOUSEMOVE and msg <= User32.WM_NCMBUTTONDBLCLK) then
			win:OnMouseMessage(hwnd, msg, wparam, lparam)
		end

		if (msg >= User32.WM_KEYDOWN and msg <= User32.WM_SYSCOMMAND) then
			win:OnKeyboardMessage(hwnd, msg, wparam, lparam)
		end

		if msg == User32.WM_SIZING then
			local prect = ffi.cast("PRECT", lparam);
			--print("WM_SIZING: ", wparam, prect.left, prect.top, prect.right, prect.bottom);


			local newWidth = prect.right - prect.left;
			local newHeight = prect.bottom - prect.top;
			win:OnWindowResizing(newWidth, newHeight);
		end

		if msg == User32.WM_SIZE then
			local newWidth = LOWORD(lparam);
			local newHeight = HIWORD(lparam);
			--print("WM_SIZE: ", wparam, newWidth, newHeight);

			win:OnWindowResized(newWidth, newHeight);
		end

	end

	-- If we have reached here, then do default message processing
	return User32.DefWindowProcA(hwnd, msg, wparam, lparam);
end


local winKind = WindowKind:create("GLWindow", WindowProc);


GLWindow.init = function(self, nativewindow, params)
	params = params or GLWindow.Defaults

	params.ClassName = params.ClassName or GLWindow.Defaults.ClassName
	params.Title = params.Title or GLWindow.Defaults.Title
	params.Origin = params.Origin or GLWindow.Defaults.Origin
	params.Extent = params.Extent or GLWindow.Defaults.Extent
	params.FrameRate = params.FrameRate or GLWindow.Defaults.FrameRate

	local obj = {
		NativeWindow = nativewindow;

		Width = params.Extent[1];
		Height = params.Extent[2];

		GLContext = nil;

		IsReady = false;
		IsValid = false;
		IsRunning = false;

		FrameRate = params.FrameRate;
		Interval =1/ params.FrameRate;

		-- Interactor routines
		MessageDelegate = params.MessageDelegate;
		OnSetFocusDelegate = params.OnSetFocusDelegate;
		OnTickDelegate = params.OnTickDelegate;
		OnWindowResizedDelegate = params.OnWindowResizedDelegate;
		OnWindowResizingDelegate = params.OnWindowResizingDelegate;

		OnKeyDelegate = params.OnKeyDelegate;
		OnMouseDelegate = params.OnMouseDelegate;
		GestureInteractor = params.GestureInteractor;
	}
	setmetatable(obj, GLWindow_mt);

	obj:OnCreated(nativewindow);


	return obj;
end

GLWindow.create = function(self, params)
	params = params or GLWindow.Defaults

	params.ClassName = params.ClassName or GLWindow.Defaults.ClassName
	params.Title = params.Title or GLWindow.Defaults.Title
	params.Origin = params.Origin or GLWindow.Defaults.Origin
	params.Extent = params.Extent or GLWindow.Defaults.Extent
	params.FrameRate = params.FrameRate or GLWindow.Defaults.FrameRate

	-- try to create a window of our kind
	local win, err = winKind:createWindow(params.Extent[1], params.Extent[2], params.Title);
	
	if not win then
		return nil, err;
	end

	return self:init(win, params);
end

function GLWindow:GetClientSize()
	return self.NativeWindow:GetClientSize();
end


function GLWindow:SetFrameRate(rate)
	self.FrameRate = rate
	self.Interval = 1/self.FrameRate
end



function GLWindow:Show()
	self.NativeWindow:Show();
end

function GLWindow:Hide()
	self.NativeWindow:Hide();
end

function GLWindow:Maximize()
	self.NativeWindow:Maximize();
end

function GLWindow:Update()
	self.NativeWindow:Update();
end


function GLWindow:SwapBuffers()
	Gdi32.Lib.SwapBuffers(self.GDIContext.Handle);
end


function GLWindow:CreateGLContext()
	local ctx, err = GLContext(self.NativeWindow:getNativeHandle());

	if not ctx then
		return false, err
	end

	ctx:MakeCurrent(self.GDIContext.Handle);
	self.GLContext = ctx;

	return ctx;
end


function GLWindow:OnCreated(nativewindow)
--print("GLWindow:OnCreated: ", hwnd)
	local hwnd = nativewindow:getNativeHandle();

	local winptr = ffi.cast("intptr_t", hwnd)
	local winnum = tonumber(winptr)

	GLWindow.WindowMap[winnum] = self;

	self.GDIContext = nativewindow:getDeviceContext();

--print("GDIContext: ", self.GDIContext, self.GDIContext.Handle);
	self.GDIContext:UseDCPen()
	self.GDIContext:UseDCBrush()

	local success, err = self:CreateGLContext()
	if not success then
		print("GLWindow:OnCreated(), CreateGLContext(), FAILURE: ", err);
	end

	self.IsValid = true
end

function GLWindow:OnDestroy()
	print("GLWindow:OnDestroy")

	ffi.C.PostQuitMessage(0)

	return 0
end

function GLWindow:OnQuit()
--print("GLWindow:OnQuit")
	self.IsRunning = false
	stop();
	-- delete glcontext
	--if self.GLContext then
	--	self.GLContext:Destroy()
	--end
end

function GLWindow:OnTick(tickCount)
	if (self.OnTickDelegate) then
		self.OnTickDelegate(self, tickCount)
	end
end

function GLWindow:OnFocusMessage(msg)
--print("OnFocusMessage")
	if (self.OnSetFocusDelegate) then
		self.OnSetFocusDelegate(self, msg)
	end
end

function GLWindow:OnKeyboardMessage(hwnd, msg, wparam, lparam)
	if self.OnKeyDelegate then
		self.OnKeyDelegate(hwnd, msg, wparam, lparam)
	end
end

function GLWindow:OnMouseMessage(hwnd, msg, wparam, lparam)
--print("GLWindow:OnMouseMessage()")
	if self.OnMouseDelegate then
		self.OnMouseDelegate(hwnd, msg, wparam, lparam)
	end
end

function GLWindow:OnWindowResized(width, height)
	--print("GLWindow:OnWindowResized: ", width, height);
	if self.OnWindowResizedDelegate then
		self.OnWindowResizedDelegate(width, height);
	end
end

function GLWindow:OnWindowResizing(width, height)
	--print("GLWindow:OnWindowResizing: ", width, height);
	if self.OnWindowResizingDelegate then
		self.OnWindowResizingDelegate(width, height);
	end
end

return GLWindow;
