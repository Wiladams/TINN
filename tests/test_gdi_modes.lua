local ffi = require("ffi")
local gdi_ffi = require("gdi32_ffi")
local GDI = require("GDI32")
local GdiCaps = require("GdiCaps")

local User32 = require ("User32")


local scrcaps = GdiCaps.BasicCaps()
local	ScreenWidth = scrcaps.HORZRES
local	ScreenHeight = scrcaps.VERTRES

print("SCREEN: ", ScreenWidth, ScreenHeight)

local function printContextInfo(ctxt)
	-- window information
	local pSize = ffi.new("SIZE")
	gdi_ffi.GetWindowExtEx(hDC, pSize)
	print("WindowExt: ", pSize.cx, pSize.cy)

	--print("WindowOrg: ", )
	-- viewport information

	-- World Transformation
	local xfm = gdi_ffi.XFORM();

	gdi_ffi.GetWorldTransform(hDC, xfm)
	print("World Transform: ")
	print(xfm.eM11, xfm.eM12)
	print(xfm.eM21, xfm.eM22)
	print(xfm.eDx, xfm.eDy)
	print("------------------")
end

local ctxt = DeviceContext();
local hDC = ctxt.Handle;




ctxt:setMapMode("MM_ANISOTROPIC")

--local mapmode = gdi_ffi.GetMapMode(hDC)
--print("Map Mode: ", mapmode)

local oldPoint = ffi.new("POINT")
local oldSize = ffi.new("SIZE")


gdi_ffi.SetWindowExtEx(hDC, 512, 512, oldSize)
print("Old Size: ", oldSize.cx, oldSize.cy)
gdi_ffi.GetWindowExtEx(hDC, oldSize)
print("New Size: ", oldSize.cx, oldSize.cy)
--gdi_ffi.SetWindowOrgEx(hDC, 0, 10, oldPoint)
--print("Old Point: ", oldPoint.y, oldPoint.y)

gdi_ffi.SetViewportExtEx(hDC, 1024, 2048, oldSize)


local lpPoints = ffi.new("POINT[3]",{
	{512,0},
	{0,512},
	{1024,512}
	})
local nCount = 3;

gdi_ffi.Polygon(hDC, lpPoints, nCount);


printContextInfo(hDC)


