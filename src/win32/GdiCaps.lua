-- GdiCaps.lua
-- References
-- http://ofekshilon.com/2011/11/13/reading-monitor-physical-dimensions-or-getting-the-edid-the-right-way/
-- http://en.wikipedia.org/wiki/Extended_display_identification_data

local gdi_ffi = require("gdi32_ffi")

--[[
ClippingCaps
ColorManageCaps
CurveCaps
DisplayCaps
LineCaps
PolygonalCaps
PrinterCaps
RasterCaps
ShadingCaps
TextCaps
--]]


--[[
static const int DRIVERVERSION = 0;     /* Device driver version                    */
static const int TECHNOLOGY    = 2;     /* Device classification                    */
static const int HORZSIZE      = 4;     /* Horizontal size in millimeters           */
static const int VERTSIZE      = 6;     /* Vertical size in millimeters             */
static const int HORZRES       = 8;     /* Horizontal width in pixels               */
static const int VERTRES       = 10;    /* Vertical height in pixels                */
static const int BITSPIXEL     = 12;    /* Number of bits per pixel                 */
static const int PLANES        = 14;    /* Number of planes                         */
static const int NUMBRUSHES    = 16;    /* Number of brushes the device has         */
static const int NUMPENS       = 18;    /* Number of pens the device has            */
static const int NUMMARKERS    = 20;    /* Number of markers the device has         */
static const int NUMFONTS      = 22;    /* Number of fonts the device has           */
static const int NUMCOLORS     = 24;    /* Number of colors the device supports     */
static const int PDEVICESIZE   = 26;    /* Size required for device descriptor      */
static const int CURVECAPS     = 28;    /* Curve capabilities                       */
static const int LINECAPS      = 30;    /* Line capabilities                        */
static const int POLYGONALCAPS = 32;    /* Polygonal capabilities                   */
static const int TEXTCAPS      = 34;    /* Text capabilities                        */
static const int CLIPCAPS      = 36;    /* Clipping capabilities                    */
static const int RASTERCAPS    = 38;    /* Bitblt capabilities                      */
static const int ASPECTX       = 40;    /* Length of the X leg                      */
static const int ASPECTY       = 42;    /* Length of the Y leg                      */
static const int ASPECTXY      = 44;    /* Length of the hypotenuse                 */

static const int LOGPIXELSX    = 88;    /* Logical pixels/inch in X                 */
static const int LOGPIXELSY    = 90;    /* Logical pixels/inch in Y                 */

static const int SIZEPALETTE  = 104;    /* Number of entries in physical palette    */
static const int NUMRESERVED  = 106;    /* Number of reserved entries in palette    */
static const int COLORRES     = 108;    /* Actual color resolution                  */
--]]

local BasicCaps = {}
setmetatable(BasicCaps, {
	__call = function(self, ctxt)
		return self:create(ctxt)
	end,
})
local BasicCaps_mt = {
	__index = function(self, key)
		print("__index: ", self, key)
		local res = gdi32_ffi.GetDeviceCaps(self.Context.Handle, key)
		
		return res;
	end,
}

BasicCaps.init = function(self, ctxt)
	local obj = {
		Context = ctxt,
	}
	setmetatable(obj, BasicCaps_mt)

	return obj;
end

BasicCaps.create = function(self, ctxt)
	ctxt = ctxt or DeviceContext();
	return self:init(ctxt)
end


return {
	ClippingCaps = ClippingCaps,
	ColorManageCaps = ColorManageCaps,
	CurveCaps = CurveCaps,
	DisplayCaps = DisplayCaps,
	LineCaps = LineCaps,
	PolygonalCaps = PolygonCaps,
	PrinterCaps = PrinterCaps,
	RasterCaps = RasterCaps,
	ShadingCaps = ShadingCaps,
	TextCaps = TextCaps,

	BasicCaps = BasicCaps,
}
