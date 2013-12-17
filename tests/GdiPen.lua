local gdi_ffi = require("gdi32_ffi")
local bit = require("bit")
local bor = bit.bor;

local GDIPen = {}
setmetatable(GDIPen, {
    __call = function(self, ...)
        return self:create(...);
    end,
})
local GDIPen_mt = {
    __index = GDIPen
}
GDIPen.init = function(self, rawhandle)
    local obj = {
        Handle = rawhandle;
    }
    setmetatable(GDIPen, GDIPen_mt)

    return obj;
end



GDIPen.create = function(self, params)
--        public GDIPen(Colorref colorref)
--            : this(PenType.Cosmetic, PenStyle.Solid, PenJoinStyle.Round, PenEndCap.Round, colorref, 1, Guid.NewGuid())
-- public GDIPen(PenType aType, PenStyle aStyle, PenJoinStyle aJoinStyle, PenEndCap aEndCap, Colorref colorref, int width, Guid uniqueID)


--[[
    TypeOfPen = aType;
    Style = aStyle;
    JoinStyle = aJoinStyle;
    EndCap = aEndCap;
    Width = width;
    Color = colorref;
--]]

    local combinedStyle = bor(aStyle, aType, aJoinStyle, aEndCap);
    local fLogBrush = LOGBRUSH();
    fLogBrush.lbColor = colorref;
    fLogBrush.lbHatch = nil;
    fLogBrush.lbStyle = (int)BrushStyle.Solid;

    if (PenType.Cosmetic == aType) then
            
        -- If it's cosmetic, the width must be 1
        width = 1;

        -- The color must be in the brush structure
        -- Must mask off the alpha, or we'll get black
        fLogBrush.lbColor = band(colorref, 0x00ffffff);

        -- The brush style must be solid
        fLogBrush.lbStyle = BrushStyle.Solid;
    end


    local rawhandle = GDI32.ExtCreatePen((uint)combinedStyle, (uint)width, ref fLogBrush, 0, IntPtr.Zero);

    return self:init(rawhandle);
end
