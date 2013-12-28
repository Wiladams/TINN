
local ffi = require("ffi")
local bit = require("bit")
local lshift = bit.lshift;
local rshift = bit.rshift;
local bor = bit.bor

require ("dxgiformat")

local _FACDXGI =   0x87a;

local function MAKE_HRESULT(sev,fac,code)
    return  bor(lshift(sev,31), lshift(fac,16), code)
end

local function MAKE_DXGI_HRESULT(code) 
    MAKE_HRESULT(1, _FACDXGI, code)
end 

local function MAKE_DXGI_STATUS(code)  
    MAKE_HRESULT(0, _FACDXGI, code)
end


DXGI_STATUS_OCCLUDED                   = MAKE_DXGI_STATUS(1);
DXGI_STATUS_CLIPPED                    = MAKE_DXGI_STATUS(2);
DXGI_STATUS_NO_REDIRECTION             = MAKE_DXGI_STATUS(4);
DXGI_STATUS_NO_DESKTOP_ACCESS          = MAKE_DXGI_STATUS(5);
DXGI_STATUS_GRAPHICS_VIDPN_SOURCE_IN_USE =MAKE_DXGI_STATUS(6);
DXGI_STATUS_MODE_CHANGED               = MAKE_DXGI_STATUS(7);
DXGI_STATUS_MODE_CHANGE_IN_PROGRESS    = MAKE_DXGI_STATUS(8);


DXGI_ERROR_INVALID_CALL                = MAKE_DXGI_HRESULT(1);
DXGI_ERROR_NOT_FOUND                   = MAKE_DXGI_HRESULT(2);
DXGI_ERROR_MORE_DATA                   = MAKE_DXGI_HRESULT(3);
DXGI_ERROR_UNSUPPORTED                 = MAKE_DXGI_HRESULT(4);
DXGI_ERROR_DEVICE_REMOVED              = MAKE_DXGI_HRESULT(5);
DXGI_ERROR_DEVICE_HUNG                 = MAKE_DXGI_HRESULT(6);
DXGI_ERROR_DEVICE_RESET                = MAKE_DXGI_HRESULT(7);
DXGI_ERROR_WAS_STILL_DRAWING           = MAKE_DXGI_HRESULT(10);
DXGI_ERROR_FRAME_STATISTICS_DISJOINT   = MAKE_DXGI_HRESULT(11);
DXGI_ERROR_GRAPHICS_VIDPN_SOURCE_IN_USE= MAKE_DXGI_HRESULT(12);
DXGI_ERROR_DRIVER_INTERNAL_ERROR       = MAKE_DXGI_HRESULT(32);
DXGI_ERROR_NONEXCLUSIVE                = MAKE_DXGI_HRESULT(33);
DXGI_ERROR_NOT_CURRENTLY_AVAILABLE     = MAKE_DXGI_HRESULT(34);
DXGI_ERROR_REMOTE_CLIENT_DISCONNECTED  = MAKE_DXGI_HRESULT(35);
DXGI_ERROR_REMOTE_OUTOFMEMORY          = MAKE_DXGI_HRESULT(36);

ffi.cdef[[
static const int DXGI_CPU_ACCESS_NONE                  =  ( 0 );
static const int DXGI_CPU_ACCESS_DYNAMIC               =  ( 1 );
static const int DXGI_CPU_ACCESS_READ_WRITE            =  ( 2 );
static const int DXGI_CPU_ACCESS_SCRATCH               =  ( 3 );
static const int DXGI_CPU_ACCESS_FIELD                 =  15;

static const int DXGI_USAGE_SHADER_INPUT               =  ( 1L << (0 + 4) );
static const int DXGI_USAGE_RENDER_TARGET_OUTPUT       =  ( 1L << (1 + 4) );
static const int DXGI_USAGE_BACK_BUFFER                =  ( 1L << (2 + 4) );
static const int DXGI_USAGE_SHARED                     =  ( 1L << (3 + 4) );
static const int DXGI_USAGE_READ_ONLY                  =  ( 1L << (4 + 4) );
static const int DXGI_USAGE_DISCARD_ON_PRESENT         =  ( 1L << (5 + 4) );
static const int DXGI_USAGE_UNORDERED_ACCESS           =  ( 1L << (6 + 4) );
]]

ffi.cdef[[
typedef struct DXGI_RGB
{
    float Red;
    float Green;
    float Blue;
} DXGI_RGB;

typedef struct DXGI_GAMMA_CONTROL
{
    DXGI_RGB Scale;
    DXGI_RGB Offset;
    DXGI_RGB GammaCurve[ 1025 ];
} DXGI_GAMMA_CONTROL;

typedef struct DXGI_GAMMA_CONTROL_CAPABILITIES
{
    BOOL ScaleAndOffsetSupported;
    float MaxConvertedValue;
    float MinConvertedValue;
    UINT NumGammaControlPoints;
    float ControlPointPositions[1025];
} DXGI_GAMMA_CONTROL_CAPABILITIES;

typedef struct DXGI_RATIONAL
{
    UINT Numerator;
    UINT Denominator;
} DXGI_RATIONAL;
]]

ffi.cdef[[
typedef enum DXGI_MODE_SCANLINE_ORDER
{
    DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED        = 0,
    DXGI_MODE_SCANLINE_ORDER_PROGRESSIVE        = 1,
    DXGI_MODE_SCANLINE_ORDER_UPPER_FIELD_FIRST  = 2,
    DXGI_MODE_SCANLINE_ORDER_LOWER_FIELD_FIRST  = 3
} DXGI_MODE_SCANLINE_ORDER;

typedef enum DXGI_MODE_SCALING
{
    DXGI_MODE_SCALING_UNSPECIFIED   = 0,
    DXGI_MODE_SCALING_CENTERED      = 1,
    DXGI_MODE_SCALING_STRETCHED     = 2
} DXGI_MODE_SCALING;

typedef enum DXGI_MODE_ROTATION
{
    DXGI_MODE_ROTATION_UNSPECIFIED  = 0,
    DXGI_MODE_ROTATION_IDENTITY     = 1,
    DXGI_MODE_ROTATION_ROTATE90     = 2,
    DXGI_MODE_ROTATION_ROTATE180    = 3,
    DXGI_MODE_ROTATION_ROTATE270    = 4
} DXGI_MODE_ROTATION;
]]

ffi.cdef[[
typedef struct DXGI_MODE_DESC
{
    UINT Width;
    UINT Height;
    DXGI_RATIONAL RefreshRate;
    DXGI_FORMAT Format;
    DXGI_MODE_SCANLINE_ORDER ScanlineOrdering;
    DXGI_MODE_SCALING Scaling;
} DXGI_MODE_DESC;
]]
DXGI_MODE_DESC = ffi.typeof("DXGI_MODE_DESC")
DXGI_MODE_DESC_mt = {
    __tostring = function(self)
        local refresh = self.RefreshRate.Numerator / self.RefreshRate.Denominator
        return string.format("%dx%d %f", self.Width, self.Height, refresh)
    end,    
}
ffi.metatype(DXGI_MODE_DESC, DXGI_MODE_DESC_mt)


ffi.cdef[[
typedef struct DXGI_SAMPLE_DESC
{
    UINT Count;
    UINT Quality;
} DXGI_SAMPLE_DESC;
]]
