local ffi = require("ffi")

local WTypes = require("WTypes")
local gdi_ffi = require("gdi32_ffi")
local user32_ffi = require("user32_ffi")

local Lib = ffi.load("user32")

ffi.cdef[[
static const int MONITORINFOF_PRIMARY       = 0x00000001;

//static const int CCHDEVICENAME = 32
]]

ffi.cdef[[
typedef struct tagMONITORINFO
{
    DWORD   cbSize;
    RECT    rcMonitor;
    RECT    rcWork;
    DWORD   dwFlags;
} MONITORINFO, *LPMONITORINFO;

typedef struct tagMONITORINFOEXA
{
    MONITORINFO;
    CHAR        szDevice[CCHDEVICENAME];
} MONITORINFOEXA, *LPMONITORINFOEXA;
]]

local MONITORINFO = ffi.typeof("MONITORINFO")
local MONITORINFO_mt = {
	__new = function(ct, ...)
		local obj = ffi.new(ct,...)
		obj.cbSize = ffi.sizeof(MONITORINFO)
		return obj;
	end,
}
ffi.metatype(MONITORINFO, MONITORINFO_mt);

local MONITORINFOEXA = ffi.typeof("MONITORINFOEXA")
local MONITORINFOEXA_mt = {
    __new = function(ct, ...)
        local obj = ffi.new(ct,...)
        obj.cbSize = ffi.sizeof(MONITORINFOEXA)
        return obj;
    end,
}
ffi.metatype(MONITORINFOEXA, MONITORINFOEXA_mt);


ffi.cdef[[
typedef BOOL (__stdcall * MONITORENUMPROC)(HMONITOR, HDC, LPRECT, LPARAM);

BOOL
EnumDisplayMonitors(
    HDC hdc,
    LPCRECT lprcClip,
    MONITORENUMPROC lpfnEnum,
    LPARAM dwData);

BOOL
GetMonitorInfoA(
    HMONITOR hMonitor,
    LPMONITORINFO lpmi);

BOOL
GetMonitorInfoW(
    HMONITOR hMonitor,
    LPMONITORINFO lpmi);

HMONITOR
MonitorFromPoint(
    POINT pt,
    DWORD dwFlags);

HMONITOR
MonitorFromRect(
    LPCRECT lprc,
    DWORD dwFlags);

HMONITOR
MonitorFromWindow(
    HWND hwnd,
    DWORD dwFlags);

]]


local exports = {
	MONITORINFO = MONITORINFO,
    MONITORINFOEXA = MONITORINFOEXA,

	EnumDisplayMonitors = Lib.EnumDisplayMonitors,
	GetMonitorInfoA = Lib.GetMonitorInfoA,
	GetMonitorInfoW = Lib.GetMonitorInfoW,
	MonitorFromPoint = Lib.MonitorFromPoint,
	MonitorFromRect = Lib.MonitorFromRect,
	MonitorFromWindow = Lib.MonitorFromWindow,
}

return exports