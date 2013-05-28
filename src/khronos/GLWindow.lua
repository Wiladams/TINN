--
-- GameWindow.lua
--


local ffi = require "ffi"
local bit = require "bit"
local bor = bit.bor
local band = bit.band;
local rshift = bit.rshift;


local Gdi32 = require ("GDI32");
local User32 = require ("User32");
local StopWatch = require ("StopWatch");
local errorhandling = require("core_errorhandling_l1_1_1");

local GLContext = require("GLContext");
local core_library = require("core_libraryloader_l1_1_1");

local GLWindow_t = {
	Defaults = {
		ClassName = "LuaWindow",
		Title = "Game Window",
		Origin = {10,10},
		Extent = {320, 240},
		FrameRate = 30,
	}
}
GLWindow_t.WindowMap = {}

local GLWindow_mt = {
	__index = GLWindow_t;
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

	local win = GLWindow_t.WindowMap[winnum]

--print(string.format("WindowProc: 0x%x, Window: 0x%x, win: %s", msg, winnum, tostring(win)))

	-- if we have a win, then the window is capable
	-- of handling the message
	if win then
		--print(string.format("MSG: 0x%x",msg));

		if (win.MessageDelegate) then
			result = win.MessageDelegate(hwnd, msg, wparam, lparam)
			return result
		end

		if (msg == User32.FFI.WM_DESTROY) then
			return win:OnDestroy()
		end

		if (msg >= User32.FFI.WM_MOUSEFIRST and msg <= User32.FFI.WM_MOUSELAST) or
				(msg >= User32.FFI.WM_NCMOUSEMOVE and msg <= User32.FFI.WM_NCMBUTTONDBLCLK) then
			win:OnMouseMessage(hwnd, msg, wparam, lparam)
		end

		if (msg >= User32.FFI.WM_KEYDOWN and msg <= User32.FFI.WM_SYSCOMMAND) then
			win:OnKeyboardMessage(hwnd, msg, wparam, lparam)
		end

		if msg == User32.FFI.WM_SIZING then
			local prect = ffi.cast("PRECT", lparam);
			--print("WM_SIZING: ", wparam, prect.left, prect.top, prect.right, prect.bottom);


			local newWidth = prect.right - prect.left;
			local newHeight = prect.bottom - prect.top;
			win:OnWindowResizing(newWidth, newHeight);
		end

		if msg == User32.FFI.WM_SIZE then
			local newWidth = LOWORD(lparam);
			local newHeight = HIWORD(lparam);
			--print("WM_SIZE: ", wparam, newWidth, newHeight);

			win:OnWindowResized(newWidth, newHeight);
		end

	end

	-- If we have reached here, then do default message processing
	return User32.Lib.DefWindowProcA(hwnd, msg, wparam, lparam);
end

local GLWindow = function(params)
	params = params or GLWindow_t.Defaults

	params.ClassName = params.ClassName or GLWindow_t.Defaults.ClassName
	params.Title = params.Title or GLWindow_t.Defaults.Title
	params.Origin = params.Origin or GLWindow_t.Defaults.Origin
	params.Extent = params.Extent or GLWindow_t.Defaults.Extent
	params.FrameRate = params.FrameRate or GLWindow_t.Defaults.FrameRate

	local self = {
		Registration = nil;
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
	setmetatable(self, GLWindow_mt);

	self:Register(params);
	self:CreateWindow(params);

	return self;
end

function GLWindow_t:GetClientSize()
	local csize = ffi.new( "RECT[1]" )
    User32.Lib.GetClientRect(self.WindowHandle, csize);
	csize = csize[0]
	local width = csize.right-csize.left
	local height = csize.bottom-csize.top

	return width, height
end


function GLWindow_t:SetFrameRate(rate)
	self.FrameRate = rate
	self.Interval = 1/self.FrameRate
end



function GLWindow_t:Register(params)
	self.AppInstance = core_library.GetModuleHandleA(nil)
	self.ClassName = params.ClassName

	local classStyle = bit.bor(User32.FFI.CS_HREDRAW, User32.FFI.CS_VREDRAW, User32.FFI.CS_OWNDC);

	local aClass = ffi.new('WNDCLASSEXA', {
		cbSize = ffi.sizeof("WNDCLASSEXA");
		style = classStyle;
		lpfnWndProc = WindowProc;
		cbClsExtra = 0;
		cbWndExtra = 0;
		hInstance = self.AppInstance;
		hIcon = nil;
		hCursor = nil;
		hbrBackground = nil;
		lpszMenuName = nil;
		lpszClassName = self.ClassName;
		hIconSm = nil;
		})

	self.Registration = User32.Lib.RegisterClassExA(aClass)

	assert(self.Registration ~= 0, "Registration error"..tostring(errorhandling.GetLastError()))
end


function GLWindow_t:CreateWindow(params)
	self.ClassName = params.ClassName
	self.Title = params.Title
	self.Width = params.Extent[1]
	self.Height = params.Extent[2]

	local dwExStyle = bit.bor(User32.FFI.WS_EX_APPWINDOW, User32.FFI.WS_EX_WINDOWEDGE)
	local dwStyle = bit.bor(User32.FFI.WS_SYSMENU, User32.FFI.WS_VISIBLE, User32.FFI.WS_POPUP)

--print("GameWindow:CreateWindow - 1.0")
	local hwnd = User32.Lib.CreateWindowExA(
		0,
		self.ClassName,
		self.Title,
		User32.FFI.WS_OVERLAPPEDWINDOW,
		User32.FFI.CW_USEDEFAULT,
		User32.FFI.CW_USEDEFAULT,
		params.Extent[1], params.Extent[2],
		nil,
		nil,
		self.AppInstance,
		nil)
--print("GameWindow:CreateWindow - 2.0")

	assert(hwnd,"unable to create window"..tostring(errorhandling.GetLastError()))

	self.WindowHandle = hwnd;

	self:OnCreated(hwnd)
end


function GLWindow_t:Show()
	User32.Lib.ShowWindow(self.WindowHandle, User32.FFI.SW_SHOW)
end

function GLWindow_t:Hide()
end

function GLWindow_t:Update()
	User32.Lib.UpdateWindow(self.WindowHandle)
end


function GLWindow_t:SwapBuffers()
	Gdi32.Lib.SwapBuffers(self.GDIContext.Handle);
end


function GLWindow_t:CreateGLContext()
	local ctx, err = GLContext(self.WindowHandle);

	if not ctx then
		return false, err
	end

	ctx:MakeCurrent(self.GDIContext.Handle);
	self.GLContext = ctx;

	return ctx;
end


function GLWindow_t:OnCreated(hwnd)
--print("GLWindow:OnCreated: ", hwnd)

	local winptr = ffi.cast("intptr_t", hwnd)
	local winnum = tonumber(winptr)

	GLWindow_t.WindowMap[winnum] = self


	self.GDIContext = DeviceContext(User32.Lib.GetDC(self.WindowHandle));

--print("GDIContext: ", self.GDIContext, self.GDIContext.Handle);
	self.GDIContext:UseDCPen()
	self.GDIContext:UseDCBrush()

	local success, err = self:CreateGLContext()
	if not success then
		print("GLWindow_t:OnCreated(), CreateGLContext(), FAILURE: ", err);
	end

	self.IsValid = true
end

function GLWindow_t:OnDestroy()
	--print("GameWindow:OnDestroy")

	ffi.C.PostQuitMessage(0)

	return 0
end

function GLWindow_t:OnQuit()
--print("GameWindow:OnQuit")
	self.IsRunning = false
	stop();
	-- delete glcontext
	--if self.GLContext then
	--	self.GLContext:Destroy()
	--end
end

function GLWindow_t:OnTick(tickCount)
	if (self.OnTickDelegate) then
		self.OnTickDelegate(self, tickCount)
	end
end

function GLWindow_t:OnFocusMessage(msg)
--print("OnFocusMessage")
	if (self.OnSetFocusDelegate) then
		self.OnSetFocusDelegate(self, msg)
	end
end

function GLWindow_t:OnKeyboardMessage(hwnd, msg, wparam, lparam)
	if self.OnKeyDelegate then
		self.OnKeyDelegate(hwnd, msg, wparam, lparam)
	end
end

function GLWindow_t:OnMouseMessage(hwnd, msg, wparam, lparam)
--print("GLWindow_t:OnMouseMessage()")
	if self.OnMouseDelegate then
		self.OnMouseDelegate(hwnd, msg, wparam, lparam)
	end
end

function GLWindow_t:OnWindowResized(width, height)
	--print("GLWindow_t:OnWindowResized: ", width, height);
	if self.OnWindowResizedDelegate then
		self.OnWindowResizedDelegate(width, height);
	end
end

function GLWindow_t:OnWindowResizing(width, height)
	--print("GLWindow_t:OnWindowResizing: ", width, height);
	if self.OnWindowResizingDelegate then
		self.OnWindowResizingDelegate(width, height);
	end
end

return GLWindow;
