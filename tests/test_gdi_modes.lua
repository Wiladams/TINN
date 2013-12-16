local ffi = require("ffi")
local gdi_ffi = require("gdi32_ffi")
local GDI = require("GDI32")

local ctxt = DeviceContext();
local hDC = ctxt.Handle;

local mapmode = gdi_ffi.GetMapMode(hDC)

print("Map Mode: ", tostring(mapmode))

local lpPoints = ffi.new("POINT[6]",{
	{512,0},
	{0,512},
	{1024,512}
	})
local nCount = 3;

gdi_ffi.Lib.Polygon(hDC, lpPoints, nCount);