
--
-- StartUp.lua
--
-- The main interface file
--

local ffi = require "ffi"
bit = require("bit");
band = bit.band;
bor = bit.bor;
rshift = bit.rshift;
lshift = bit.lshift;

local global = _G;

--local apppath = string.format([[;%s\?.lua;%s\core\?.lua;%s\core\Win32\?.lua;%s\modules\?.lua]],argv[1], argv[1], argv[1], argv[1]);
--local ppath = package.path..apppath;
--package.path = ppath;

--local libpath = string.format([[;%s\clibs\?.dll;%s\clibs\?.exe]], argv[1],argv[1]);
--package.cpath = package.cpath..libpath


require ("WTypes");
local Kernel32 = require("win_kernel32");
local User32 = require("User32");
local KeyMouse = require ("KeyMouse");
local StopWatch = require("StopWatch");

ogm = require("OglMan");
glu = require("glu");
local GLWindow = require ("GLWindow");



local canvasWidth = 1024
local canvasHeight = 768

MainWindow = nil;



local View3D_t = {
	Clock = StopWatch.new();
	TickCount = 0;
	FrameCount = 0;
}
local View3D_mt = {
	__index = View3D_t,	
}



function OnIdle()
	if onidle then
		onidle(View3D_t.Clock:Seconds());
	end
end

function OnTick(tickCount)
	View3D_t.TickCount = View3D_t.TickCount + 1
	View3D_t.FrameCount = View3D_t.FrameCount + 1

	View3D_t.FramesPerSecond = View3D_t.TickCount / View3D_t.Clock:Seconds()

	if (_G.ontick) ~= nil then
		ontick(tickCount)
	end

	-- If the user has created a global 'display()' function
	-- then execute that function
	if (_G.display) ~= nil then
		display();
		MainWindow:SwapBuffers();
	end
end

function OnWindowResizing(width, height)
	--print("OnWindowResizing");

	View3D_t.WindowWidth = width;
	View3D_t.WindowHeight = height;

	if _G.reshape then
		reshape(width, height);
	else
		gl.glViewport(0, 0, width, height);
	end

	-- If the user has created a global 'display()' function
	-- then execute that function
	if (_G.display) ~= nil then
		display();
		MainWindow:SwapBuffers();
	end
end

function OnWindowResized(width, height)
	--print("OnWindowResized: ", width, height);

	View3D_t.WindowWidth = width;
	View3D_t.WindowHeight = height;

	if global.reshape then
		reshape(width, height);
	else
		gl.glViewport(0, 0, width, height);
	end
end

function OnKeyMouse(hWnd, msg, wParam, lParam)
--print("StartUp:OnKeyMouse(): ", hWnd, msg, wParam, lParam);

	local event = KeyMouse.ConvertKeyMouse(hWnd, msg, wParam, lParam);

	if event then
		if global["onkeymouse"] then
			onkeymouse(event);
		else
			local func = global[event.kind]
		
			if not func then
				--return false, string.format("OnKeyMouse, no event dispatcher found for kind: %s", event.kind);
				return false;
			end

			func(event);
		end

		return true
	end

	return false;
end




-- The following 'jit.off(Loop)' is here because LuaJit
-- can't quite fix-up the case where a callback is being
-- called from LuaJit'd code
-- http://lua-users.org/lists/lua-l/2011-12/msg00712.html
--
-- I found the proper way to do this is to put the jit.off
-- call before the function body.
--



jit.off(Loop)
function Loop(win)
	win:Show();
	win:Update();
	win.IsRunning = true;


	local timerEvent = Kernel32.CreateEvent(nil, false, false, nil)
	-- If the timer event was not created
	-- just return
	if timerEvent == nil then
		error("unable to create timer")
		return
	end

	local handleCount = 1
	local handles = ffi.new('void*[1]', {timerEvent})

	local msg = ffi.new("MSG")
	local sw = StopWatch.new();
	local tickCount = 1
	local timeleft = 0
	local lastTime = sw:Milliseconds()
	local nextTime = lastTime + win.Interval * 1000

	local dwFlags = bor(User32.FFI.MWMO_ALERTABLE,User32.FFI.MWMO_INPUTAVAILABLE)

	while (win.IsRunning) do
		while (User32.Lib.PeekMessageA(msg, nil, 0, 0, User32.FFI.PM_REMOVE) ~= 0) do
			User32.Lib.TranslateMessage(msg)
			User32.Lib.DispatchMessageA(msg)

--print(string.format("Loop Message: 0x%x", msg.message))

			if msg.message == User32.FFI.WM_QUIT then
				return win:OnQuit()
			end
		end

		timeleft = nextTime - sw:Milliseconds();
		if (timeleft <= 0) then
			OnTick(tickCount);
			tickCount = tickCount + 1
			nextTime = nextTime + win.Interval * 1000
			timeleft = nextTime - sw:Milliseconds();
		end

		if timeleft < 0 then timeleft = 0 end

		-- use an alertable wait
		User32.Lib.MsgWaitForMultipleObjectsEx(handleCount, handles, timeleft, User32.FFI.QS_ALLEVENTS, dwFlags)

		OnIdle();

		yield();
	end

print("Exiting Window Loop")
	stop();
end

local main = function(params)
	params = params or {}
	params.FrameRate = params.FrameRate or 30;

	MainWindow = GLWindow({
		Title = "View3D",
		Extent = {canvasWidth,canvasHeight},
		FrameRate = params.FrameRate,

		OnMouseDelegate = OnKeyMouse,
		OnKeyDelegate = OnKeyMouse,
		OnWindowResizedDelegate = OnWindowResized,
		OnWindowResizingDelegate = OnWindowResizing,
	})

	OnWindowResized(canvasWidth, canvasHeight);

	-- If there is a setup routine,
	-- run that before anything else
	if global.init ~= nil then
		global.init();
	end


	spawn(Loop, MainWindow);
end

return {
	main = main,
	Window = MainWindow,
}