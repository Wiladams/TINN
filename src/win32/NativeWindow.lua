
local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;

local Gdi32 = require("GDI32");
local User32 = require("user32_ffi");
local User32Lib = ffi.load("User32");
local errorhandling = require("core_errorhandling_l1_1_1");
local core_library = require("core_libraryloader_l1_1_1");


ffi.cdef[[
typedef struct _User32Window {
	HWND	Handle;
} WindowHandle, *PWindowHandle;
]]

WindowHandle = ffi.typeof("WindowHandle");
WindowHandle_mt = {
	
}
ffi.metatype(WindowHandle, WindowHandle_mt);


local NativeWindow = {}
setmetatable(NativeWindow, {
	__call = function(self, ...)
		return self:create(...);
	end,
});
local NativeWindow_mt = {
	__index = NativeWindow,
}

NativeWindow.init = function(self, rawhandle)
	local obj = {
		Handle = WindowHandle(rawhandle);
	}
	setmetatable(obj, NativeWindow_mt);

	return obj;
end

NativeWindow.create = function(self, className, width, height, title)
	className = className or "NativeWindowClass";
	title = title or "Native Window Title";

	local dwExStyle = bor(User32.WS_EX_APPWINDOW, User32.WS_EX_WINDOWEDGE);
	local dwStyle = bor(User32.WS_SYSMENU, User32.WS_VISIBLE, User32.WS_POPUP);

--print("GameWindow:CreateWindow - 1.0")
	local appInstance = core_library.GetModuleHandleA(nil);

	local hwnd = User32.CreateWindowExA(
		0,
		className,
		title,
		User32.WS_OVERLAPPEDWINDOW,
		User32.CW_USEDEFAULT,
		User32.CW_USEDEFAULT,
		width, height,
		nil,
		nil,
		appInstance,
		nil);

	if hwnd == nil then
		return false, errorhandling.GetLastError();
	end

	return self:init(hwnd);
end

--[[
	Instance Methods
--]]

-- Attributes
NativeWindow.getNativeHandle = function(self)
	return self.Handle.Handle;
end

NativeWindow.getDeviceContext = function(self)
	return DeviceContext(User32.GetDC(self:getNativeHandle()));
end

-- Functions
NativeWindow.Hide = function(self, kind)
	kind = kind or User32.SW_HIDE;
	self:Show(kind);
end
		
NativeWindow.Maximize = function(self)
	print("NativeWinow:MAXIMIZE: ", User32.SW_MAXIMIZE);
	return self:Show(User32.SW_MAXIMIZE);
end

NativeWindow.Show = function(self, kind)
	kind = kind or User32.SW_SHOWNORMAL;

	return User32.ShowWindow(self:getNativeHandle(), kind);
end

NativeWindow.Update = function(self)
	User32.UpdateWindow(self:getNativeHandle())
end

NativeWindow.GetClientSize = function(self)
	local csize = ffi.new( "RECT[1]" )
	User32.GetClientRect(self:getNativeHandle(), csize);
	csize = csize[0]
	local width = csize.right-csize.left
	local height = csize.bottom-csize.top

	return width, height
end

NativeWindow.GetTitle = function(self)
	local buf = ffi.new("char[?]", 256)
	local lbuf = ffi.cast("intptr_t", buf)
	if User32.SendMessageA(self:getNativeHandle(), User32.WM_GETTEXT, 255, lbuf) ~= 0 then
		return ffi.string(buf)
	end
end


return NativeWindow;
