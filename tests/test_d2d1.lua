-- test_d2d1.lua
local ffi = require("ffi")
local d2d = require("d2d1")
local user32_ffi = require("user32_ffi")

--[[
ID2D1Factory* pD2DFactory = NULL;
HRESULT hr = D2D1CreateFactory(
    D2D1_FACTORY_TYPE_SINGLE_THREADED,
    &pD2DFactory
    );
--]]
--[[
    HRESULT
    D2D1CreateFactory(
        D2D1_FACTORY_TYPE factoryType,
        REFIID riid,
        const D2D1_FACTORY_OPTIONS *pFactoryOptions,
        void **ppIFactory
        );
--]]

local function D2D1CreateFactory(factoryType)
	factoryType = factoryType or ffi.C.D2D1_FACTORY_TYPE_SINGLE_THREADED;
	local ppIFactory = ffi.new("ID2D1Factory * [1]")

    local hr = d2d.D2D1CreateFactory(factoryType, IID_ID2D1Factory, nil, ffi.cast("void *",ppIFactory));

	if hr ~= 0 then
		return nil, hr
	end

    return ppIFactory[0]
end


local factory, err = D2D1CreateFactory()


if not factory then
	error("Factory not created: ", err)
	return err
end

-- Create the Render Target
local hwnd = user32_ffi.GetDesktopWindow()

print("Desktop Window: ", hwnd)

-- Obtain the size of the drawing area.
local rc = ffi.new("RECT");
user32_ffi.GetClientRect(hwnd, rc);

-- Create a Direct2D render target	
local function CreateHwndRenderTarget(This, renderTargetProperties, hwndRenderTargetProperties, hwndRenderTarget)
    return This.lpVtbl.CreateHwndRenderTarget(This, renderTargetProperties, hwndRenderTargetProperties, hwndRenderTarget);
end


local function RenderTargetProperties(
        rttype,
        pixelFormat,
        dpiX,
        dpiY,
        usage,
        minLevel)

    rttype = rttype or ffi.C.D2D1_RENDER_TARGET_TYPE_DEFAULT;
    pixelFormat = pixelFormat or D2D1_PIXEL_FORMAT();
    dpiX = dpiX or 0;
    dpiY = dpiY or 0;
    usage = usage or ffi.C.D2D1_RENDER_TARGET_USAGE_NONE;
    minLevel = minLevel or ffi.C.D2D1_FEATURE_LEVEL_DEFAULT


    local renderTargetProperties = ffi.new("D2D1_RENDER_TARGET_PROPERTIES");

--        DXGI_FORMAT format;
--    D2D1_ALPHA_MODE alphaMode;

    renderTargetProperties.type = rttype;
    renderTargetProperties.pixelFormat = pixelFormat;
    renderTargetProperties.dpiX = dpiX;
    renderTargetProperties.dpiY = dpiY;
    renderTargetProperties.usage = usage;
    renderTargetProperties.minLevel = minLevel;
    
    return renderTargetProperties;
end


local function    HwndRenderTargetProperties(hwnd, pixelSize, presentOptions)

	pixelSize = pixelSize or D2D1_SIZE_F();
	presentOptions = presentOptions or ffi.C.D2D1_PRESENT_OPTIONS_NONE;

    local hwndRenderTargetProperties = ffi.new("D2D1_HWND_RENDER_TARGET_PROPERTIES");
    
    hwndRenderTargetProperties.hwnd = hwnd;
    hwndRenderTargetProperties.pixelSize = pixelSize;
    hwndRenderTargetProperties.presentOptions = presentOptions;
    
	return hwndRenderTargetProperties;
end

local function CreateWindowRenderTarget(factory, hwnd)		
	local pRT = ffi.new("ID2D1HwndRenderTarget * [1]");
	local pixelSize = ffi.new("D2D1_SIZE_U", rc.right - rc.left,rc.bottom - rc.top)

	local hr = CreateHwndRenderTarget(factory,
    	RenderTargetProperties(),
    	HwndRenderTargetProperties(hwnd, pixelSize),
    	pRT);

	print("CreateWindowRenderTarget, hr: ", hr)
	if hr ~= 0 then
		return nil, hr;
	end


	return pRT[0];
end


local pRT, err = CreateWindowRenderTarget(factory, hwnd)

if not pRT then
	error("Error CreateWindowRenderTarget: ", pRT, err)
end

-- Create a Brush

local function CreateSolidColorBrush(This, color, brushProperties, solidColorBrush)
    return This.lpVtbl.Base.CreateSolidColorBrush(ffi.cast("ID2D1RenderTarget *",This), color, brushProperties, solidColorBrush)
end



local pBlackBrush = ffi.new("ID2D1SolidColorBrush *[1]");
  			
local hr = CreateSolidColorBrush(pRT, D2D1_COLOR_F(0,0.5,0,1), nil, pBlackBrush); 
assert(hr == 0, "error creating solid color brush")

pBlackBrush = pBlackBrush[0];

print("Black Brush: ", pBlackBrush)

-- Draw a Rectangle
local function BeginDraw(This)
    return This.lpVtbl.Base.BeginDraw(ffi.cast("ID2D1RenderTarget *",This))
end

local function EndDraw(This, tag1, tag2)
    return This.lpVtbl.Base.EndDraw(ffi.cast("ID2D1RenderTarget *",This), tag1, tag2)
end

local function DrawRectangle(This, rect, brush, strokeWidth, strokeStyle)
	print("DrawRectangle: ", rect.left, rect.top, rect.right, rect.bottom)
	print("  brush: ", brush)
	print("stroke Width: ", strokeWidth)
	print("stroke Style: ", strokeStyle)

    This.lpVtbl.Base.DrawRectangle(ffi.cast("ID2D1RenderTarget *",This), rect, brush, strokeWidth, strokeStyle)
end


-- Do the actual drawing
BeginDraw(pRT);

DrawRectangle(
	pRT,
    D2D1_RECT_F(rc.left + 100.0,rc.top + 100.0,rc.right - 100.0,rc.bottom - 100.0),
    ffi.cast("ID2D1Brush *",pBlackBrush), 
    1, 
    nil);

local hr = EndDraw(pRT);
