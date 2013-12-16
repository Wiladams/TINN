local GDI = require("GDI32")
local GdiCaps = require("GdiCaps")


local capnames = {
	"DRIVERVERSION",
	"TECHNOLOGY",
	"HORZSIZE",
	"VERTSIZE",
	"HORZRES",
	"VERTRES",
	"BITSPIXEL",
	"PLANES",
	"NUMBRUSHES",
	"NUMPENS",
	"NUMMARKERS",
	"NUMFONTS",
	"NUMCOLORS",
	"PDEVICESIZE",
	"CURVECAPS",
	"LINECAPS",
	"POLYGONALCAPS",
	"TEXTCAPS",
	"CLIPCAPS",
	"RASTERCAPS",
	"ASPECTX",
	"ASPECTY",
	"ASPECTXY",

	"LOGPIXELSX",
	"LOGPIXELSY",

	"SIZEPALETTE",
	"NUMRESERVED",
	"COLORRES",
}

local screen = GdiCaps.BasicCaps()

-- For each name, print out the GetDeviceCaps() value
for _, capname in ipairs(capnames) do
	print(string.format("%s: %d", capname, screen[capname]))
end
