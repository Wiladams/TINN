
local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;

local user32_ffi = require ("user32_ffi");
local User32Lib = ffi.load("User32");
local core_library = require("core_libraryloader_l1_1_1");


local RegisterWindowClass = function(wndclassname, msgproc, style)
	msgproc = msgproc or user32_ffi.DefWindowProcA;
	style = style or bor(user32_ffi.CS_HREDRAW,user32_ffi.CS_VREDRAW, user32_ffi.CS_OWNDC);

	local hInst = core_library.GetModuleHandleA(nil);

	local wcex = ffi.new("WNDCLASSEXA");
    wcex.cbSize = ffi.sizeof(wcex);
    wcex.style          = style;
    wcex.lpfnWndProc    = msgproc;
    wcex.cbClsExtra     = 0;
    wcex.cbWndExtra     = 0;
    wcex.hInstance      = hInst;
    wcex.hIcon          = nil;		-- LoadIcon(hInst, MAKEINTRESOURCE(IDI_APPLICATION));
    wcex.hCursor        = nil;		-- LoadCursor(NULL, IDC_ARROW);
    wcex.hbrBackground  = nil;		-- (HBRUSH)(COLOR_WINDOW+1);
    wcex.lpszMenuName   = nil;		-- NULL;
    wcex.lpszClassName  = wndclassname;
    wcex.hIconSm        = nil;		-- LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_APPLICATION));

	local classAtom = user32_ffi.RegisterClassExA(wcex);

	if classAtom == nil then
    	return false, "Call to RegistrationClassEx failed."
    end

	return classAtom;
end

local CreateWindowHandle = function(winclass, wintitle, width, height, winstyle, x, y)
	wintitle = wintitle or "Window";
	winstyle = winstyle or user32_ffi.WS_OVERLAPPEDWINDOW;
	x = x or user32_ffi.CW_USEDEFAULT;
	y = y or user32_ffi.CW_USEDEFAULT;

	local hInst = core_library.GetModuleHandleA(nil);
	local hWnd = user32_ffi.CreateWindowExA(
		0,
		winclass,
		wintitle,
		winstyle,
		x, y,width, height,
		nil,	
		nil,	
		hInst,
		nil);

	if hWnd == nil then
		return false, "error creating window"
	end

	return hWnd;
end





function User32_MsgProc(hwnd, msg, wparam, lparam)
--print("User32_MsgProc: ", msg)
	if (msg == C.WM_CREATE) then
		--print("WM_CREATE")

		local crstruct = ffi.cast("LPCREATESTRUCTA", lparam)

		--print(crstruct.lpCreateParams)
		local win = ffi.cast("PUser32Window", crstruct.lpCreateParams)
		return win:OnCreate()
	elseif (msg == C.WM_DESTROY) then
		--print("WM_DESTROY")
		C.PostQuitMessage(0)
		return 0
	end

	local retValue = user32_ffi.DefWindowProcA(hwnd, msg, wparam, lparam)

	return retValue;
end


User32MSGHandler = {}
User32MSGHandler_mt = {
	__index = User32MSGHandler,
}



User32MSGHandler.new = function(classname, msgproc, classStyle)
	local appInstance = core_library.GetModuleHandleA(nil)
	msgproc = msgproc or User32_MsgProc
	classStyle = classStyle or bit.bor(user32_ffi.CS_HREDRAW, user32_ffi.CS_VREDRAW, user32_ffi.CS_OWNDC);

	local self = {}
	self.AppInstance = appInstance
	self.ClassName = ffi.cast("const char *", classname)
	self.MessageProc = msgproc

	setmetatable(self, User32MSGHandler_mt);

	local winClass = ffi.new('WNDCLASSEXA', {
		cbSize = ffi.sizeof("WNDCLASSEXA");
		style = classStyle;
		lpfnWndProc = self.MessageProc;
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

	self.Registration = user32_ffi.RegisterClassExA(winClass)

	if (self.Registration == 0) then
		print("Registration error")
		--print(C.GetLastError())
	end

	return self
end

User32MSGHandler.CreateHandler = function(self, title, x, y, width, height, windowStyle)
	x = x or 10
	y = y or 10
	width = width or 320
	height = height or 240
	windowStyle = windowStyle or C.WS_OVERLAPPEDWINDOW

	self.Title = ffi.cast("const char *", title)

	local dwExStyle =  bit.bor(user32_ffi.WS_EX_APPWINDOW, user32_ffi.WS_EX_WINDOWEDGE)


	local win = ffi.new("NativeWindow")

	local hWnd = user32_ffi.CreateWindowExA(
				0,
				self.ClassName,
				self.Title,
				windowStyle,
				x,
				y,
				width,
				height,
				nil,
				nil,
				self.AppInstance,
				win)

	if hWnd == nil then
		print("unable to create window")
	else
		win.Handle = hWnd
	end

	return win
end



--[[
	Some functions, reflecting what's in the ffi interface
	
	
--]]

local GetSystemMetrics = function(what)
	local res = user32_ffi.GetSystemMetrics(what)
	if res == 0 then
		return nil, "failed"
	end
	
	return res;
end

local SendInput = function(nInputs, pInputs, cbSize)
	local res = user32_ffi.SendInput(nInputs,pInputs,cbSize);
	
	-- If the number of events inserted was zero,
	-- then there was an error
	if res == 0 then
		return nil, User32Lib.GetLastError();
	end
	
	-- return the number of events that were inserted
	return res
end

return {
	FFI = user32_ffi,
	Lib = User32Lib,
	
	GetDC = user32_ffi.GetDC;
	
	RegisterWindowClass = RegisterWindowClass,
	CreateWindowHandle = CreateWindowHandle,
	User32MSGHandler = User32MSGHandler,
	NativeWindow = NativeWindow,
	
	GetSystemMetrics = GetSystemMetrics,
	SendInput = SendInput,
}
