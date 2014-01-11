--
-- GDIWindow.lua
--

local ffi = require "ffi"
local bit = require "bit"
local bor = bit.bor

local Application = require("Application")
local Functor = require("Functor")
local Gdi32 = require "GDI32"
local User32 = require "user32_ffi"
local errorhandling = require("core_errorhandling_l1_1_1")
local WindowKind = require("WindowKind");



local GDIWindow = {
	Defaults = {
		ClassName = "GDIWindow",
		Title = "GDI Application",
		Origin = {10,10},
		Extent = {320, 240},
	},
	
	WindowMap = {},
}
setmetatable(GDIWindow, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local GDIWindow_mt = {
	__index = GDIWindow;
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

	local self = GDIWindow.WindowMap[winnum]

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




local winKind = WindowKind:create("GDIWindow", WindowProc);


function GDIWindow.init(self, nativewindow, params)

	--local obj = Application(true);
	local obj = {}

	obj.NativeWindow = nativewindow;

	obj.Width = params.Extent[1];
	obj.Height = params.Extent[2];

	obj.IsReady = false;
	obj.IsValid = false;
	obj.IsRunning = false;

		-- Interactor routines
	obj.MessageDelegate = params.MessageDelegate;
	obj.OnCreatedDelegate = params.OnCreatedDelegate;
	obj.OnSetFocusDelegate = params.OnSetFocusDelegate;
	obj.OnTickDelegate = params.OnTickDelegate;
	obj.OnQuitDelegate = params.OnQuitDelegate;

	obj.KeyboardInteractor = params.KeyboardInteractor;
	obj.MouseInteractor = params.MouseInteractor;
	obj.GestureInteractor = params.GestureInteractor;


	setmetatable(obj, GDIWindow_mt);
	
	obj:OnCreated(nativewindow);
	
	return obj;
end	

function GDIWindow.create(self, params)
	params = params or GDIWindow.Defaults

	params.ClassName = params.ClassName or GDIWindow.Defaults.ClassName
	params.Title = params.Title or GDIWindow.Defaults.Title
	params.Origin = params.Origin or GDIWindow.Defaults.Origin
	params.Extent = params.Extent or GDIWindow.Defaults.Extent
	-- try to create a window of our kind
	local win, err = winKind:createWindow(params.Extent[1], params.Extent[2], params.Title);
	
	if not win then
		return nil, err;
	end
	
	return self:init(win, params);
end

function GDIWindow.getBackBuffer(self)
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

function GDIWindow:getClientSize()
	return self.NativeWindow:GetClientSize();
end

function GDIWindow:show()
	self.NativeWindow:Show();
end

function GDIWindow:hide()
	self.NativeWindow:Hide();
end

function GDIWindow.redraw(self, flags)
	return self.NativeWindow:redraw(flags);
end

function GDIWindow:update()
	self.NativeWindow:Update();
end


function GDIWindow:swapBuffers()
	gdi32.SwapBuffers(self.GDIContext.Handle);
end


function GDIWindow:OnCreated(nativewindow)
print("GDIWindow:OnCreated: ", nativewindow)

	local winptr = ffi.cast("intptr_t", nativewindow:getNativeHandle())
	local winnum = tonumber(winptr)

	GDIWindow.WindowMap[winnum] = self

	self.GDIContext = DeviceContext:init(User32.GetDC(nativewindow:getNativeHandle()));


	self.GDIContext:UseDCPen()
	self.GDIContext:UseDCBrush()

--print("GDIContext: ", self.GDIContext);

	self.IsValid = true
	self.IsRunning = true;

	if self.OnCreatedDelegate then
		self.OnCreatedDelegate(self)
	end
print("GDIWindow:OnCreated - END")
end

function GDIWindow:OnDestroy()
	print("GDIWindow:OnDestroy")

	ffi.C.PostQuitMessage(0)

	return 0
end

function GDIWindow:OnQuit()
print("GDIWindow:OnQuit")
	self.IsRunning = false

	if self.OnQuitDelegate then
		self.OnQuitDelegate(self)
	end
	-- return true, indicating it is ok to
	-- continue to quit.
	return true;
end

function GDIWindow.handleFrameTick(self)
	local tickCount = 0;

	local closure = function(timer)
		tickCount = tickCount + 1;

		if (self.OnTickDelegate) then
			self.OnTickDelegate(self, tickCount)
		end
	end

	return closure;
end

function GDIWindow:OnFocusMessage(msg)
print("OnFocusMessage")
	if (self.OnSetFocusDelegate) then
		self.OnSetFocusDelegate(self, msg)
	end
end

function GDIWindow:OnKeyboardMessage(msg, wparam, lparam)
	if self.KeyboardInteractor then
		self.KeyboardInteractor(msg)
		return 0;
	end
	return 1;
end

function GDIWindow:OnMouseMessage(msg)
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
local function user32MessageIsAvailable()
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

local function handleUser32Message(win)
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


local function appToClose(win)

	local closure = function()
		if win.IsRunning == false then
			print("APP CLOSE, IsRunning == false")		
			return true;
		end
		return false;
	end

	return closure;
end

function GDIWindow.main(self)
	print("GDIWindow.main - BEGIN")

	self:show()
	self:update()

	-- handle the user32 message queue
	whenever(user32MessageIsAvailable(), handleUser32Message(self))


	-- wait here until the application window is closed
	waitFor(appToClose(self))

	--if self.FrameTimer then
	--	self.FrameTimer:cancel();
	--end

	stop();

	print("GDIWindow.main - END")
end

function GDIWindow.run(self)
	-- set quanta to 0 so we don't waste time
	-- in i/o processing if there's nothing there
	--Task:setMessageQuanta(0);
	

	-- spawn the thread that will wait
	-- for messages to finish
	self.IsRunning = true;
	spawn(self.main, self);

	run()

	print("EXIT GDIWindow.run")
end


return GDIWindow;
