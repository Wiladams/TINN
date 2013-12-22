--
-- GDIApp.lua
--

local ffi = require "ffi"
local bit = require "bit"
local bor = bit.bor

local Task = require("IOProcessor")
local parallel = require("parallel")()
local Timer = require("Timer")

local Gdi32 = require "GDI32"
local User32 = require "user32_ffi"
local errorhandling = require("core_errorhandling_l1_1_1")
local libraryloader = require("core_libraryloader_l1_1_1");
local core_synch = require("core_synch_l1_2_0");
local WindowKind = require("WindowKind");



local GDIApp = {
	Defaults = {
		ClassName = "GDIApp",
		Title = "GDI Application",
		Origin = {10,10},
		Extent = {320, 240},
		FrameRate = 30,
	},
	
	WindowMap = {},
}
setmetatable(GDIApp, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local GDIApp_mt = {
	__index = GDIApp;
}



--[[
-- The following 'jit.off(WindowProc)' is here because LuaJit
-- can't quite fix-up the case where a callback is being
-- called from LuaJit'd code
-- http://lua-users.org/lists/lua-l/2011-12/msg00712.html
--
-- I found the proper way to do this is to put the jit.off
-- call before the function body.
--
--]]
jit.off(WindowProc)
function WindowProc(hwnd, msg, wparam, lparam)
-- lookup which window object is associated with the
-- window handle
	local winptr = ffi.cast("intptr_t", hwnd)
	local winnum = tonumber(winptr)

	local self = GDIApp.WindowMap[winnum]

--print(string.format("WindowProc: 0x%x, Window: 0x%x, self: %s", msg, winnum, tostring(self)))

	-- If we don't find a window object associated with 
	-- the window handle, then use the default window proc
	if not self then
		return User32.DefWindowProcA(hwnd, msg, wparam, lparam);
	end

	-- if we have a self, then the window is capable
	-- of handling the message
	if (self.MessageDelegate) then
		result = self.MessageDelegate(hwnd, msg, wparam, lparam)
		return result
	end

	if (msg == User32.WM_DESTROY) then
		return self:OnDestroy()
	elseif (msg >= User32.WM_MOUSEFIRST and msg <= User32.WM_MOUSELAST) or
		(msg >= User32.WM_NCMOUSEMOVE and msg <= User32.WM_NCMBUTTONDBLCLK) then
		self:OnMouseMessage(msg, wparam, lparam)
	elseif (msg >= User32.WM_KEYDOWN and msg <= User32.WM_SYSCOMMAND) then
		self:OnKeyboardMessage(msg, wparam, lparam)
	end
	
--print(string.format("WindowProc Default: 0x%04x", msg))

	return User32.DefWindowProcA(hwnd, msg, wparam, lparam);
end




local winKind = WindowKind:create("GDIApp", WindowProc);


GDIApp.init = function(self, nativewindow, params)

	local obj = {
		NativeWindow = nativewindow,

		Width = params.Extent[1];
		Height = params.Extent[2];

		IsReady = false;
		IsValid = false;
		IsRunning = false;

		-- Interactor routines
		MessageDelegate = params.MessageDelegate;
		OnCreatedDelegate = params.OnCreatedDelegate;
		OnSetFocusDelegate = params.OnSetFocusDelegate;
		OnTickDelegate = params.OnTickDelegate;
		OnQuitDelegate = params.OnQuitDelegate;

		KeyboardInteractor = params.KeyboardInteractor;
		MouseInteractor = params.MouseInteractor;
		GestureInteractor = params.GestureInteractor;
	}
	setmetatable(obj, GDIApp_mt);
	
	obj:setFrameRate(params.FrameRate)
	obj:OnCreated(nativewindow);
	
	return obj;
end	

GDIApp.create = function(self, params)
	params = params or GDIApp.Defaults

	params.ClassName = params.ClassName or GDIApp.Defaults.ClassName
	params.Title = params.Title or GDIApp.Defaults.Title
	params.Origin = params.Origin or GDIApp.Defaults.Origin
	params.Extent = params.Extent or GDIApp.Defaults.Extent
	params.FrameRate = params.FrameRate or GDIApp.Defaults.FrameRate

	-- try to create a window of our kind
	local win, err = winKind:createWindow(params.Extent[1], params.Extent[2], params.Title);
	
	if not win then
		return nil, err;
	end
	
	return self:init(win, params);
end

GDIApp.getBackBuffer = function(self)
	if not self.BackBuffer then
		-- get the GDIcontext for the native window
		local err
		local bbfr, err = self.GDIContext:createCompatibleBitmap(self.Width, self.Height)

		if not bbfr then
			return nil, err;
		end

		self.BackBuffer = bbfr;
	end

	return self.BackBuffer;
end

function GDIApp:getClientSize()
	return self.NativeWindow:GetClientSize();
end

function GDIApp:setFrameRate(rate)
	self.FrameRate = rate
	self.Interval = 1/self.FrameRate
end



function GDIApp:show()
	self.NativeWindow:Show();
end

function GDIApp:hide()
	self.NativeWindow:Hide();
end

GDIApp.redraw = function(self, flags)
	return self.NativeWindow:redraw(flags);
end

function GDIApp:update()
	self.NativeWindow:Update();
end


function GDIApp:swapBuffers()
	gdi32.SwapBuffers(self.GDIContext.Handle);
end


function GDIApp:OnCreated(nativewindow)
print("GDIApp:OnCreated: ", nativewindow)

	local winptr = ffi.cast("intptr_t", nativewindow:getNativeHandle())
	local winnum = tonumber(winptr)

	GDIApp.WindowMap[winnum] = self

	self.GDIContext = DeviceContext:init(User32.GetDC(nativewindow:getNativeHandle()));


	self.GDIContext:UseDCPen()
	self.GDIContext:UseDCBrush()

--print("GDIContext: ", self.GDIContext);

	self.IsValid = true
	self.IsRunning = true;

	if self.OnCreatedDelegate then
		self.OnCreatedDelegate(self)
	end
print("GDIApp:OnCreated - END")
end

function GDIApp:OnDestroy()
	print("GDIApp:OnDestroy")

	ffi.C.PostQuitMessage(0)

	return 0
end

function GDIApp:OnQuit()
print("GDIApp:OnQuit")
	self.IsRunning = false

	if self.OnQuitDelegate then
		self.OnQuitDelegate(self)
	end
	-- return true, indicating it is ok to
	-- continue to quit.
	return true;
end

GDIApp.handleFrameTick = function(self)
	local tickCount = 0;

	local closure = function(timer)
		tickCount = tickCount + 1;

		if (self.OnTickDelegate) then
			self.OnTickDelegate(self, tickCount)
		end
	end

	return closure;
end

function GDIApp:OnFocusMessage(msg)
print("OnFocusMessage")
	if (self.OnSetFocusDelegate) then
		self.OnSetFocusDelegate(self, msg)
	end
end

function GDIApp:OnKeyboardMessage(msg, wparam, lparam)
	if self.KeyboardInteractor then
		self.KeyboardInteractor(msg)
		return 0;
	end
	return 1;
end

function GDIApp:OnMouseMessage(msg)
	if self.MouseInteractor then
		self.MouseInteractor(msg)
		return 0;
	end
	return 1;
end

--[[
	A simple predicate that tells us whether or not a message
	is waiting in the thread's message queue or not.
--]]
local user32MessageIsAvailable = function()
	local msg = ffi.new("MSG")

	local closure = function()
		local peeked = User32.PeekMessageA(msg, nil, 0, 0, User32.PM_NOREMOVE);
--print("PEEKED: ", peeked)
		if peeked == 0 then
			return false
		end

		return true;
	end

	return closure;
end

local handleUser32Message = function(win)
	local msg = ffi.new("MSG")

	local closure = function()
--print("HANDLE MESSAGE: ")
		ffi.fill(msg, ffi.sizeof("MSG"))
		local res = User32.GetMessageA(msg, nil, 0,0)
		local res = User32.TranslateMessage(msg)
			
		User32.DispatchMessageA(msg)

		if msg.message == User32.WM_QUIT then
			print("APP QUIT == TRUE")
			win:OnQuit()
		end
	end

	return closure;
end


local appToClose = function(win)

	local closure = function()
		if win.IsRunning == false then
			--print("APP CLOSE, IsRunning == false")		
			return true;
		end
		return false;
	end

	return closure;
end

GDIApp.main = function(self)
	print("GDIApp.main - BEGIN")

	self:show()
	self:update()

	-- Start the FrameTimer
	--local period = 1000/self.FrameRate;
	--self.FrameTimer = Timer({Delay=period, Period=period, OnTime =self:handleFrameTick()})
	self.FrameTimer = periodic(self:handleFrameTick(), 1000/self.FrameRate)

	-- handle the user32 message queue
	whenever(user32MessageIsAvailable(), handleUser32Message(self))

	-- wait here until the application window is closed
	local res = waitFor(appToClose(self))

	if self.FrameTimer then
		self.FrameTimer:cancel();
	end
end

GDIApp.run = function(self)
	if not self.IsValid then
		print('Window Handle is NULL')
		return
	end
	-- set quanta to 0 so we don't waste time
	-- in i/o processing if there's nothing there
	Task:setMessageQuanta(0);
	

	-- spawn the thread that will wait
	-- for messages to finish
	Task:spawn(GDIApp.main, self);

	Task:run()

	print("EXIT GDIApp.run")
end


return GDIApp;
