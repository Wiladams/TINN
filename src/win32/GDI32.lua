local ffi = require "ffi"
local bit = require("bit")
local band = bit.band
local bnot = bit.bnot
local lshift = bit.lshift
local rshift = bit.rshift

local GDILib = ffi.load("gdi32")
local gdi_ffi = require ("gdi32_ffi")


--[[
	DeviceContext

	The Drawing Context for good ol' GDI drawing
--]]
DeviceContext = {}
setmetatable(DeviceContext, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

DeviceContext_mt = {
	__index = DeviceContext,

	__tostring = function(self)
		return string.format("DeviceContext(0x%s)", tostring(self.Handle))
	end,
}

DeviceContext.init = function(self, rawhandle)
	local obj = {
		Handle = rawhandle;
	}
	setmetatable(obj, DeviceContext_mt)

	return obj;
end

DeviceContext.create = function(self, lpszDriver, lpszDevice, lpszOutput, lpInitData)
	lpszDriver = lpszDriver or "DISPLAY"
	
	local rawhandle = GDILib.CreateDCA(lpszDriver, lpszDevice, lpszOutput, lpInitData);
	
	if rawhandle == nil then
		return nil, "could not create Device Context as specified"
	end

	-- default to advanced graphics mode instead of GM_COMPATIBLE
	gdi_ffi.SetGraphicsMode(rawhandle, "GM_ADVANCED")

	return self:init(rawhandle)
end

DeviceContext.CreateForMemory = function(self, hDC)
	hDC = hDC or GDILib.CreateDCA("DISPLAY", nil, nil, nil)
	local rawhandle = GDILib.CreateCompatibleDC(hDC) 
	
	return self:init(rawhandle)
end


DeviceContext.clone = function(self)
	local hDC = GDILib.CreateCompatibleDC(self.Handle);
	local ctxt = DeviceContext:init(hDC)
	
	return ctxt;
end

DeviceContext.createCompatibleBitmap = function(self, width, height)
	local bm, err = GDIBitmap:createCompatible(width, height, self);

	return bm, err
end

-- Coordinates and Transforms
DeviceContext.setGraphicsMode = function(self, mode)
	gdi_ffi.SetGraphicsMode(self.Handle, mode)

	return true;
end

DeviceContext.setMapMode = function(self, mode)
	gdi_ffi.SetMapMode(self.Handle, mode)

	return true;
end

-- Device Context State
DeviceContext.flush = function(self)
	return GDILib.GdiFlush()
end

DeviceContext.restore = function(self, nSavedDC)
	nSavedDC = nSavedDC or -1;
	
	return GDILib.RestoreDC(self.Handle, nSavedDC);
end

DeviceContext.save = function(self)
	local stateIndex = GDILib.SaveDC(self.Handle);
	if stateIndex == 0 then
		return false, "failed to save GDI state"
	end

	return stateIndex; 
end

-- Object Management
DeviceContext.SelectObject = function(self, gdiobj)
	GDILib.SelectObject(self.Handle, gdiobj.Handle)
end

DeviceContext.SelectStockObject = function(self, objectIndex)
    -- First get a handle on the object
    local objHandle = GDILib.GetStockObject(objectIndex);

    --  Then select it into the device context
	return GDILib.SelectObject(self.Handle, objHandle);
end


-- Drawing Attributes
DeviceContext.UseDCBrush = function(self)
	self:SelectStockObject(gdi_ffi.DC_BRUSH)
end

DeviceContext.UseDCPen = function(self)
	self:SelectStockObject(gdi_ffi.DC_PEN)
end

DeviceContext.SetDCBrushColor = function(self, color)
	return GDILib.SetDCBrushColor(self.Handle, color)
end

DeviceContext.SetDCPenColor = function(self, color)
	return GDILib.SetDCPenColor(self.Handle, color)
end


-- Drawing routines
DeviceContext.MoveTo = function(self, x, y)
	local result = GDILib.MoveToEx(self.Handle, x, y, nil);
	return result
end

DeviceContext.MoveToEx = function(self, x, y, lpPoint)
	return GDILib.MoveToEx(self.Handle, X, Y, lpPoint);
end

DeviceContext.SetPixel = function(self, x, y, color)
	return GDILib.SetPixel(self.Handle, x, y, color);
end

DeviceContext.SetPixelV = function(self, x, y, crColor)
	return GDILib.SetPixelV(self.Handle, X, Y, crColor);
end

DeviceContext.LineTo = function(self, xend, yend)
	local result = GDILib.LineTo(self.Handle, xend, yend);
	return result
end

DeviceContext.Ellipse = function(self, nLeftRect, nTopRect, nRightRect, nBottomRect)
	return GDILib.Ellipse(self.Handle,nLeftRect,nTopRect,nRightRect,nBottomRect);
end

DeviceContext.Polygon = function(self, lpPoints, nCount)
	local res = gdi_ffi.Polygon(self.Handle,lpPoints, nCount);

	return true;
end

DeviceContext.Rectangle = function(self, left, top, right, bottom)
	return GDILib.Rectangle(self.Handle, left, top, right, bottom);
end

DeviceContext.RoundRect = function(self, left, top, right, bottom, width, height)
	return GDILib.RoundRect(self.Handle, left, top, right, bottom, width, height);
end

-- Text Drawing
DeviceContext.Text = function(self, txt, x, y)
	x = x or 0
	y = y or 0
	
	return GDILib.TextOutA(self.Handle, x, y, txt, string.len(txt));
end

-- Bitmap drawing
DeviceContext.BitBlt = function(self, nXDest, nYDest, nWidth, nHeight, hdcSrc, nXSrc, nYSrc, dwRop)
	nXSrc = nXSrc or 0
	nYSrc = nYSrc or 0
	dwRop = dwRop or gdi_ffi.SRCCOPY
	
	return GDILib.BitBlt(self.Handle,nXDest,nYDest,nWidth,nHeight,hdcSrc,nXSrc,nYSrc,dwRop);
end

		DeviceContext.StretchDIBits = function(self, XDest, YDest, nDestWidth, nDestHeight, XSrc, YSrc, nSrcWidth, nSrcHeight, lpBits, lpBitsInfo, iUsage, dwRop)
			XDest = XDest or 0
			YDest = YDest or 0
			iUsage = iUsage or 0
			dwRop = dwRop or gdi_ffi.SRCCOPY;

			return GDILib.StretchDIBits(hdc,XDest,YDest,nDestWidth,nDestHeight,XSrc,YSrc,nSrcWidth,nSrcHeight,lpBits,lpBitsInfo,iUsage,dwRop);
		end

		DeviceContext.GetDIBits = function(self, hbmp, uStartScan, cScanLines, lpvBits, lpbi, uUsage)
			return GDILib.GetDIBits(self.Handle,hbmp,uStartScan,cScanLines,lpvBits,lpbi,uUsage);
		end

		DeviceContext.StretchBlt = function(self, img, XDest, YDest,DestWidth,DestHeight)
			XDest = XDest or 0
			YDest = YDest or 0
			DestWidth = DestWidth or img.Width
			DestHeight = DestHeight or img.Height

			-- Draw a pixel buffer
			local bmInfo = BITMAPINFO();
			bmInfo.bmiHeader.biWidth = img.Width;
			bmInfo.bmiHeader.biHeight = img.Height;
			bmInfo.bmiHeader.biPlanes = 1;
			bmInfo.bmiHeader.biBitCount = img.BitsPerElement;
			bmInfo.bmiHeader.biClrImportant = 0;
			bmInfo.bmiHeader.biClrUsed = 0;
			bmInfo.bmiHeader.biCompression = 0;

			self:StretchDIBits(XDest,YDest,DestWidth,DestHeight,
				0,0,img.Width, img.Height,
				img.Data,
				bmInfo);
		end





-- For Color
-- 0x00bbggrr
local function RGB(byRed, byGreen, byBlue)
	local acolor = lshift(byBlue,16) + lshift(byGreen,8) + byRed;
	return acolor;
end

local function GetRValue(c)
	return band(c, 0xff)
end

local function GetGValue(c)
	return band(rshift(c,8), 0xff)
end

local function GetBValue(c)
	return band(rshift(c,16), 0xff)
end

--
-- This function answers the question:
-- Given:
--		We know the size of the byte boundary we want
--		to align to.
-- Question:
--		How many bytes need to be allocated to ensure we
--		will align to that boundary.
-- Discussion:
--		This comes up in cases where you're allocating a bitmap image
--		for example.  It may be a 24-bit image, but you need to ensure
--		that each row can align to a 32-bit boundary.  So, we need to
--		essentially scale up the number of bits to match the alignment.
--
local GetAlignedByteCount = function(width, bitsperpixel, alignment)
	local bytesperpixel = bitsperpixel / 8;
	return band((width * bytesperpixel + (alignment - 1)), bnot(alignment - 1));
end





GDIBitmap = {}
setmetatable(GDIBitmap, {
	__call = function(self, ...)
		return self:create(...)
	end,
})
GDIBitmap_mt = {
	__index = GDIBitmap,

	__tostring = function(self) 
		return string.format("GDIBitmap(0x%s)", tostring(self.Handle)) 
	end,
}

GDIBitmap.init = function(self, rawhandle, deviceContext)
--print("GDIBitmap.init - BEGIN: ", rawhandle, deviceContext)
	local obj = {
		Handle = rawhandle;
		DeviceContext = deviceContext;
	}
	setmetatable(obj, GDIBitmap_mt)

	if deviceContext ~= nil then
		deviceContext:SelectObject(obj)
	end

	return obj;
end

GDIBitmap.create = function(self, width, height, deviceContext)
	local rawhandle = GDILib.CreateCompatibleBitmap(deviceContext.Handle, width, height)

	if rawhandle == nil then
		return nil, "failed to create bitmap handle"
	end

	return self:init(rawhandle)
end

GDIBitmap.createCompatible = function(self, width, height, deviceContext)
--print("GDIBitmap.createCompatible - BEGIN: ", width, height, deviceContext)

	local rawhandle = GDILib.CreateCompatibleBitmap(deviceContext.Handle, width, height)

--print("GDIBitmap.createCompatible, rawhandle: ", rawhandle)
	if rawhandle == nil then
		return nil, "failed to create bitmap handle"
	end

	return self:init(rawhandle, deviceContext:clone())
end

GDIBitmap.getDeviceContext = function(self)
	if not self.DeviceContext then
		-- create a memory device context 
		self.DeviceContext = DeviceContext:CreateForMemory()
		self.DeviceContext:SelectObject(self)
	end

	return self.DeviceContext
end

GDIBitmap.getNativeInfo = function(self)
	if not self.Info then
		self.Info = ffi.new("BITMAP")
		local infosize = ffi.sizeof("BITMAP");
		GDILib.GetObjectA(self.Handle, infosize, self.Info)
	end

	return self.Info
end

GDIBitmap.Print = function(self)
	local info = self:getNativeInfo();

	if not info then
		print("No bitmap info available")
		return false;
	end


	print(string.format("== Bitmap =="))
	print(string.format("        type: %d", info.bmType))
	print(string.format("       width: %d", info.bmWidth))
	print(string.format("      height: %d", info.bmHeight))
	print(string.format(" Width Bytes: %d", info.bmWidthBytes))
	print(string.format("      Planes: %d", info.bmPlanes))
	print(string.format("BitsPerPixel: %d", info.bmBitsPixel));
	print(string.format("      Pixels: %s", tostring(info.bmBits)))

	return true;
end




GDIDIBSection = {}
setmetatable(GDIDIBSection, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

GDIDIBSection_mt = {
	__index = GDIDIBSection,
}

GDIDIBSection.init = function(rawhandle, pixels, info, deviceContext)
	local obj = {
		Handle = rawhandle;
		Width = info.bmiHeader.biWidth;
		Height = info.bmiHeader.biHeight;
		BitsPerPixel = info.bmiHeader.biBitCount;
		Pixels = pixels;
		Info = info;
		DeviceContext = deviceContext;
	}
	setmetatable(obj, GDIDIBSection_mt)

	-- Select the dib section into the device context
	-- so that drawing can occur.
	deviceContext:SelectObject(obj)

	return obj;
end

GDIDIBSection.create = function(self, width, height, bitsperpixel, alignment)
	bitsperpixel = bitsperpixel or 32
	alignment = alignment or 4

	-- Need to construct a BITMAPINFO structure
	-- to describe the image we'll be creating
	local bytesPerRow = GetAlignedByteCount(width, bitsperpixel, alignment)
	local info = BITMAPINFO();

	info.bmiHeader.biWidth = width;
	info.bmiHeader.biHeight = height;
	info.bmiHeader.biPlanes = 1;
	info.bmiHeader.biBitCount = bitsperpixel;
	info.bmiHeader.biSizeImage = bytesPerRow * math.abs(height);
	info.bmiHeader.biClrImportant = 0;
	info.bmiHeader.biClrUsed = 0;
	info.bmiHeader.biCompression = 0;	-- GDI32.BI_RGB

	-- Create the DIBSection, using the screen as
	-- the source DC
	local ddc = DeviceContext();
	local DIB_RGB_COLORS = 0
	local pPixels = ffi.new("void *[1]")
	local rawhandle = GDILib.CreateDIBSection(ddc.Handle,
        info,
		DIB_RGB_COLORS,
		pPixels,
		nil,
		0);

	return self:init(rawhandle, pPixels[0], info, ddc)
end

GDIDIBSection.getDeviceContext = function(self)
	if not self.DeviceContext then
		self.DeviceContext = DeviceContext:CreateForMemory();
		self.DeviceContext:SelectObject(self);
	end

	return self.DeviceContext;
end

GDIDIBSection.Print = function(self)
	print("Bits Per Pixel: ", self.BitsPerPixel)
	print("Size: ", self.Width, self.Height)
	print("Pixels: ", self.Pixels)
end
		


return {
	FFI = gdi_ffi,
	Lib = GDILib,

	DeviceContext = DeviceContext,
	GDIBitmap = GDIBitmap,
	GDIDIBSection = GDIDIBSection,

	-- Some helper functions
	GetAlignedByteCount = GetAlignedByteCount,
	GetBValue = GetBValue,
	GetGValue = GetGValue,
	GetRValue = GetRValue,

	RGB = RGB,
}
