--
-- WindowApplication.lua
--

local ffi = require "ffi"
local bit = require "bit"
local bor = bit.bor

local Application = require("Application")
local Timer = require("Timer")

local Gdi32 = require "GDI32"
local User32 = require "user32_ffi"
local errorhandling = require("core_errorhandling_l1_1_1")
local libraryloader = require("core_libraryloader_l1_1_1");
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




function GDIApp.init(self, nativewindow, params)
	local obj = {
		Window = GDIWindow(params)
	}

	local obj = Application(true);


	obj.IsReady = false;
	obj.IsValid = false;
	obj.IsRunning = false;

	setmetatable(obj, GDIApp_mt);
	
	obj:setFrameRate(params.FrameRate)
	obj:OnCreated(nativewindow);
	
	return obj;
end	

function GDIApp.create(self, params)
	params = params or GDIApp.Defaults

	params.ClassName = params.ClassName or GDIApp.Defaults.ClassName
	params.Title = params.Title or GDIApp.Defaults.Title
	params.Origin = params.Origin or GDIApp.Defaults.Origin
	params.Extent = params.Extent or GDIApp.Defaults.Extent
	params.FrameRate = params.FrameRate or GDIApp.Defaults.FrameRate
	
	return self:init(win, params);
end



function GDIApp:setFrameRate(rate)
	self.FrameRate = rate
	self.Interval = 1/self.FrameRate
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

function GDIApp.handleFrameTick(self)
	local tickCount = 0;

	local closure = function(timer)
		tickCount = tickCount + 1;

		if (self.OnTickDelegate) then
			self.OnTickDelegate(self, tickCount)
		end
	end

	return closure;
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
			--print("APP CLOSE, IsRunning == false")		
			return true;
		end
		return false;
	end

	return closure;
end

function GDIApp.main(self)
	print("GDIApp.main - BEGIN")

	self:show()
	self:update()

	-- handle the user32 message queue
	whenever(user32MessageIsAvailable(), handleUser32Message(self))

	-- Start the FrameTimer
	self.FrameTimer = Timer {OnTime = self:handleFrameTick(), Period = 1000/self.FrameRate}


	-- wait here until the application window is closed
	waitFor(appToClose(self))

	if self.FrameTimer then
		self.FrameTimer:cancel();
	end
end

function GDIApp.run(self)
	if not self.IsValid then
		print('Window Handle is NULL')
		return
	end
	-- set quanta to 0 so we don't waste time
	-- in i/o processing if there's nothing there
	--Task:setMessageQuanta(0);
	

	-- spawn the thread that will wait
	-- for messages to finish
	Task:spawn(GDIApp.main, self);

	Task:run()

	print("EXIT GDIApp.run")
end


return GDIApp;