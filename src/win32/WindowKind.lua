-- WindowKind.lua

local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;

local errorhandling = require("core_errorhandling_l1_1_1");
local libraryloader = require("core_libraryloader_l1_1_1");

local User32 = require("user32_ffi");
local NativeWindow = require("NativeWindow");


local WindowKind = {}
setmetatable(WindowKind, {
    __call = function(self, ...)
        return self:create(...);
    end,
});

local WindowKind_mt = {
    __index = WindowKind,    
}

WindowKind.init = function(self, classname, atom)
    local obj = {
        ClassAtom = atom,
        ClassName = classname,
    }
    setmetatable(obj, WindowKind_mt);

    return obj;
end

WindowKind.create = function(self, classname, msgproc, style)
	msgproc = msgproc or User32.DefWindowProcA;
	style = style or bor(User32.CS_HREDRAW,User32.CS_VREDRAW, User32.CS_OWNDC);

	local appInstance = libraryloader.GetModuleHandleA(nil);

	local wcex = ffi.new("WNDCLASSEXA");
    wcex.cbSize = ffi.sizeof(wcex);
    wcex.style          = style;
    wcex.lpfnWndProc    = msgproc;
    wcex.cbClsExtra     = 0;
    wcex.cbWndExtra     = 0;
    wcex.hInstance      = appInstance;
    wcex.hIcon          = nil;		-- LoadIcon(hInst, MAKEINTRESOURCE(IDI_APPLICATION));
    wcex.hCursor        = nil;		-- User32.LoadCursorA(nil, IDC_ARROW);
    wcex.hbrBackground  = nil;		-- (HBRUSH)(COLOR_WINDOW+1);
    wcex.lpszMenuName   = nil;		-- NULL;
    wcex.lpszClassName  = classname;
    wcex.hIconSm        = nil;		-- LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_APPLICATION));

	local classAtom = User32.RegisterClassExA(wcex);

	if classAtom == 0 then
    	return nil, errorhandling.GetLastError();
    end

    return self:init(classname, classAtom);
end


WindowKind.createWindow = function(self, width, height, title)
    return NativeWindow:create(self.ClassName, width, height,  title);
end

return WindowKind;
