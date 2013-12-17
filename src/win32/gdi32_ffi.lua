local ffi = require "ffi"
local C = ffi.C
local bit = require "bit"
local lshift = bit.lshift
local rshift = bit.rshift

local band = bit.band	-- &
local bor = bit.bor	-- |
local bnot = bit.bnot	-- ~

require "WTypes"

local Lib = ffi.load("gdi32")
local ImgLib = ffi.load("Msimg32")


ffi.cdef[[
static const int AD_COUNTERCLOCKWISE =1;
static const int AD_CLOCKWISE        =2;
]]

ffi.cdef[[
/* Device Parameters for GetDeviceCaps() */
typedef enum  {
	DRIVERVERSION = 0,     /* Device driver version                    */
	TECHNOLOGY    = 2,     /* Device classification                    */
	HORZSIZE      = 4,     /* Horizontal size in millimeters           */
	VERTSIZE      = 6,     /* Vertical size in millimeters             */
	HORZRES       = 8,     /* Horizontal width in pixels               */
	VERTRES       = 10,    /* Vertical height in pixels                */
	BITSPIXEL     = 12,    /* Number of bits per pixel                 */
	PLANES        = 14,    /* Number of planes                         */
	NUMBRUSHES    = 16,    /* Number of brushes the device has         */
	NUMPENS       = 18,    /* Number of pens the device has            */
	NUMMARKERS    = 20,    /* Number of markers the device has         */
	NUMFONTS      = 22,    /* Number of fonts the device has           */
	NUMCOLORS     = 24,    /* Number of colors the device supports     */
	PDEVICESIZE   = 26,    /* Size required for device descriptor      */
	CURVECAPS     = 28,    /* Curve capabilities                       */
	LINECAPS      = 30,    /* Line capabilities                        */
	POLYGONALCAPS = 32,    /* Polygonal capabilities                   */
	TEXTCAPS      = 34,    /* Text capabilities                        */
	CLIPCAPS      = 36,    /* Clipping capabilities                    */
	RASTERCAPS    = 38,    /* Bitblt capabilities                      */
	ASPECTX       = 40,    /* Length of the X leg                      */
	ASPECTY       = 42,    /* Length of the Y leg                      */
	ASPECTXY      = 44,    /* Length of the hypotenuse                 */

	LOGPIXELSX    = 88,    /* Logical pixels/inch in X                 */
	LOGPIXELSY    = 90,    /* Logical pixels/inch in Y                 */

	SIZEPALETTE  = 104,    /* Number of entries in physical palette    */
	NUMRESERVED  = 106,    /* Number of reserved entries in palette    */
	COLORRES     = 108    /* Actual color resolution                  */
} DevCapEnums;

// Printing related DeviceCaps. These replace the appropriate Escapes

static const int PHYSICALWIDTH   =110; /* Physical Width in device units           */
static const int PHYSICALHEIGHT  =111; /* Physical Height in device units          */
static const int PHYSICALOFFSETX =112; /* Physical Printable Area x margin         */
static const int PHYSICALOFFSETY =113; /* Physical Printable Area y margin         */
static const int SCALINGFACTORX  =114; /* Scaling factor x                         */
static const int SCALINGFACTORY  =115; /* Scaling factor y                         */

// Display driver specific

static const int VREFRESH       = 116;  /* Current vertical refresh rate of the    */
                                        /* display device (for displays only) in Hz*/
static const int DESKTOPVERTRES = 117;  /* Horizontal width of entire desktop in   */
                                        /* pixels                                  */
static const int DESKTOPHORZRES = 118;  /* Vertical height of entire desktop in    */
                                        /* pixels                                  */
static const int BLTALIGNMENT   = 119;  /* Preferred blt alignment                 */

static const int SHADEBLENDCAPS  =120;  /* Shading and blending caps               */
static const int COLORMGMTCAPS   =121;  /* Color Management caps                   */
]]

--[=[
ffi.cdef[[
/* Device Capability Masks: */

/* Device Technologies */
#define DT_PLOTTER          0   /* Vector plotter                   */
#define DT_RASDISPLAY       1   /* Raster display                   */
#define DT_RASPRINTER       2   /* Raster printer                   */
#define DT_RASCAMERA        3   /* Raster camera                    */
#define DT_CHARSTREAM       4   /* Character-stream, PLP            */
#define DT_METAFILE         5   /* Metafile, VDM                    */
#define DT_DISPFILE         6   /* Display-file                     */
]]

ffi.cdef[[
/* Curve Capabilities */
#define CC_NONE             0   /* Curves not supported             */
#define CC_CIRCLES          1   /* Can do circles                   */
#define CC_PIE              2   /* Can do pie wedges                */
#define CC_CHORD            4   /* Can do chord arcs                */
#define CC_ELLIPSES         8   /* Can do ellipese                  */
#define CC_WIDE             16  /* Can do wide lines                */
#define CC_STYLED           32  /* Can do styled lines              */
#define CC_WIDESTYLED       64  /* Can do wide styled lines         */
#define CC_INTERIORS        128 /* Can do interiors                 */
#define CC_ROUNDRECT        256 /*                                  */
]]

ffi.cdef[[
/* Line Capabilities */
#define LC_NONE             0   /* Lines not supported              */
#define LC_POLYLINE         2   /* Can do polylines                 */
#define LC_MARKER           4   /* Can do markers                   */
#define LC_POLYMARKER       8   /* Can do polymarkers               */
#define LC_WIDE             16  /* Can do wide lines                */
#define LC_STYLED           32  /* Can do styled lines              */
#define LC_WIDESTYLED       64  /* Can do wide styled lines         */
#define LC_INTERIORS        128 /* Can do interiors                 */
]]

ffi.cdef[[
/* Polygonal Capabilities */
#define PC_NONE             0   /* Polygonals not supported         */
#define PC_POLYGON          1   /* Can do polygons                  */
#define PC_RECTANGLE        2   /* Can do rectangles                */
#define PC_WINDPOLYGON      4   /* Can do winding polygons          */
#define PC_TRAPEZOID        4   /* Can do trapezoids                */
#define PC_SCANLINE         8   /* Can do scanlines                 */
#define PC_WIDE             16  /* Can do wide borders              */
#define PC_STYLED           32  /* Can do styled borders            */
#define PC_WIDESTYLED       64  /* Can do wide styled borders       */
#define PC_INTERIORS        128 /* Can do interiors                 */
#define PC_POLYPOLYGON      256 /* Can do polypolygons              */
#define PC_PATHS            512 /* Can do paths                     */
]]
--]=]

--[=[
ffi.cdef[[
/* Clipping Capabilities */
#define CP_NONE             0   /* No clipping of output            */
#define CP_RECTANGLE        1   /* Output clipped to rects          */
#define CP_REGION           2   /* obsolete                         */
]]
--]=]


ffi.cdef[[
/* Text Capabilities */
static const int TC_OP_CHARACTER     = 0x00000001;  /* Can do OutputPrecision   CHARACTER      */
static const int TC_OP_STROKE        = 0x00000002;  /* Can do OutputPrecision   STROKE         */
static const int TC_CP_STROKE        = 0x00000004;  /* Can do ClipPrecision     STROKE         */
static const int TC_CR_90            = 0x00000008;  /* Can do CharRotAbility    90             */
static const int TC_CR_ANY           = 0x00000010;  /* Can do CharRotAbility    ANY            */
static const int TC_SF_X_YINDEP      = 0x00000020;  /* Can do ScaleFreedom      X_YINDEPENDENT */
static const int TC_SA_DOUBLE        = 0x00000040;  /* Can do ScaleAbility      DOUBLE         */
static const int TC_SA_INTEGER       = 0x00000080;  /* Can do ScaleAbility      INTEGER        */
static const int TC_SA_CONTIN        = 0x00000100;  /* Can do ScaleAbility      CONTINUOUS     */
static const int TC_EA_DOUBLE        = 0x00000200;  /* Can do EmboldenAbility   DOUBLE         */
static const int TC_IA_ABLE          = 0x00000400;  /* Can do ItalisizeAbility  ABLE           */
static const int TC_UA_ABLE          = 0x00000800;  /* Can do UnderlineAbility  ABLE           */
static const int TC_SO_ABLE          = 0x00001000;  /* Can do StrikeOutAbility  ABLE           */
static const int TC_RA_ABLE          = 0x00002000;  /* Can do RasterFontAble    ABLE           */
static const int TC_VA_ABLE          = 0x00004000;  /* Can do VectorFontAble    ABLE           */
static const int TC_RESERVED         = 0x00008000;
static const int TC_SCROLLBLT        = 0x00010000;  /* Don't do text scroll with blt           */
]]

ffi.cdef[[
/* Raster Capabilities */
static const int RC_NONE             = 0;
static const int RC_BITBLT           =1;       /* Can do standard BLT.             */
static const int RC_BANDING          =2;       /* Device requires banding support  */
static const int RC_SCALING          =4;       /* Device requires scaling support  */
static const int RC_BITMAP64         =8;       /* Device can support >64K bitmap   */
static const int RC_GDI20_OUTPUT     = 0x0010;      /* has 2.0 output calls         */
static const int RC_GDI20_STATE      = 0x0020;
static const int RC_SAVEBITMAP       = 0x0040;
static const int RC_DI_BITMAP        = 0x0080;     /* supports DIB to memory       */
static const int RC_PALETTE          = 0x0100;      /* supports a palette           */
static const int RC_DIBTODEV         = 0x0200;      /* supports DIBitsToDevice      */
static const int RC_BIGFONT          = 0x0400;      /* supports >64K fonts          */
static const int RC_STRETCHBLT       = 0x0800;      /* supports StretchBlt          */
static const int RC_FLOODFILL        = 0x1000;      /* supports FloodFill           */
static const int RC_STRETCHDIB       = 0x2000;      /* supports StretchDIBits       */
static const int RC_OP_DX_OUTPUT     = 0x4000;
static const int RC_DEVBITS          = 0x8000;
]]

--[=[
ffi.cdef[[
/* Shading and blending caps */
#define SB_NONE             0x00000000
#define SB_CONST_ALPHA      0x00000001
#define SB_PIXEL_ALPHA      0x00000002
#define SB_PREMULT_ALPHA    0x00000004

#define SB_GRAD_RECT        0x00000010
#define SB_GRAD_TRI         0x00000020

/* Color Management caps */
#define CM_NONE             0x00000000
#define CM_DEVICE_ICM       0x00000001
#define CM_GAMMA_RAMP       0x00000002
#define CM_CMYK_COLOR       0x00000004
]]
--]=]



ffi.cdef[[

typedef struct _POINTFLOAT {
  FLOAT  x;
  FLOAT  y;
} POINTFLOAT;

typedef struct _GLYPHMETRICSFLOAT {
  FLOAT      gmfBlackBoxX;
  FLOAT      gmfBlackBoxY;
  POINTFLOAT gmfptGlyphOrigin;
  FLOAT      gmfCellIncX;
  FLOAT      gmfCellIncY;
} GLYPHMETRICSFLOAT, *LPGLYPHMETRICSFLOAT;

typedef struct tagPIXELFORMATDESCRIPTOR {
  WORD  nSize;
  WORD  nVersion;
  DWORD dwFlags;
  BYTE  iPixelType;
  BYTE  cColorBits;
  BYTE  cRedBits;
  BYTE  cRedShift;
  BYTE  cGreenBits;
  BYTE  cGreenShift;
  BYTE  cBlueBits;
  BYTE  cBlueShift;
  BYTE  cAlphaBits;
  BYTE  cAlphaShift;
  BYTE  cAccumBits;
  BYTE  cAccumRedBits;
  BYTE  cAccumGreenBits;
  BYTE  cAccumBlueBits;
  BYTE  cAccumAlphaBits;
  BYTE  cDepthBits;
  BYTE  cStencilBits;
  BYTE  cAuxBuffers;
  BYTE  iLayerType;
  BYTE  bReserved;
  DWORD dwLayerMask;
  DWORD dwVisibleMask;
  DWORD dwDamageMask;
} PIXELFORMATDESCRIPTOR;


typedef struct tagLAYERPLANEDESCRIPTOR {
  WORD  nSize;
  WORD  nVersion;
  DWORD dwFlags;
  BYTE  iPixelType;
  BYTE  cColorBits;
  BYTE  cRedBits;
  BYTE  cRedShift;
  BYTE  cGreenBits;
  BYTE  cGreenShift;
  BYTE  cBlueBits;
  BYTE  cBlueShift;
  BYTE  cAlphaBits;
  BYTE  cAlphaShift;
  BYTE  cAccumBits;
  BYTE  cAccumRedBits;
  BYTE  cAccumGreenBits;
  BYTE  cAccumBlueBits;
  BYTE  cAccumAlphaBits;
  BYTE  cDepthBits;
  BYTE  cStencilBits;
  BYTE  cAuxBuffers;
  BYTE  iLayerPlane;
  BYTE  bReserved;
  COLORREF crTransparent;
} LAYERPLANEDESCRIPTOR, *LPLAYERPLANEDESCRIPTOR;

]]

ffi.cdef[[
typedef struct _GRADIENT_TRIANGLE {
  ULONG    Vertex1;
  ULONG    Vertex2;
  ULONG    Vertex3;
}GRADIENT_TRIANGLE, *PGRADIENT_TRIANGLE;

typedef struct _GRADIENT_RECT {
  ULONG    UpperLeft;
  ULONG    LowerRight;
}GRADIENT_RECT, *PGRADIENT_RECT;
]]

--[[
	Old Style OpenGL Support
--]]

ffi.cdef[[

// For OpenGL
typedef int  (* PFNCHOOSEPIXELFORMAT)(HDC  hdc, const PIXELFORMATDESCRIPTOR *  ppfd);
typedef int  (* PFNDESCRIBEPIXELFORMAT)(HDC hdc, int iPixelFormat, unsigned int nBytes, PIXELFORMATDESCRIPTOR *  ppfd);
typedef BOOL (* PFNSETPIXELFORMAT)(HDC hdc, int  iPixelFormat, const PIXELFORMATDESCRIPTOR *  ppfd);
typedef int  (* PFNSWAPBUFFERS)(HDC hdc);


int ChoosePixelFormat(HDC  hdc, const PIXELFORMATDESCRIPTOR *  ppfd);
int DescribePixelFormat(HDC hdc, int iPixelFormat, unsigned int nBytes, PIXELFORMATDESCRIPTOR *  ppfd);
BOOL SetPixelFormat(HDC hdc, int  iPixelFormat, const PIXELFORMATDESCRIPTOR *  ppfd);
int SwapBuffers(HDC hdc);
]]





ffi.cdef[[
typedef void (__stdcall * LINEDDAPROC)(int, int, LPARAM);
]]


--[[
    Bitmap Functions
--]]
ffi.cdef[[

// currentlly defined blend function
static const int AC_SRC_OVER                = 0x00;

// alpha format flags
static const int AC_SRC_ALPHA               = 0x01;

typedef struct _BLENDFUNCTION
{
    BYTE   BlendOp;
    BYTE   BlendFlags;
    BYTE   SourceConstantAlpha;
    BYTE   AlphaFormat;
}BLENDFUNCTION,*PBLENDFUNCTION;

typedef struct _TRIVERTEX {
  LONG        x;
  LONG        y;
  COLOR16     Red;
  COLOR16     Green;
  COLOR16     Blue;
  COLOR16     Alpha;
}TRIVERTEX, *PTRIVERTEX;


typedef struct tagRGBQUAD {
  BYTE    rgbBlue;
  BYTE    rgbGreen;
  BYTE    rgbRed;
  BYTE    rgbReserved;
} RGBQUAD;

typedef struct tagRGBTRIPLE {
  BYTE rgbtBlue;
  BYTE rgbtGreen;
  BYTE rgbtRed;
} RGBTRIPLE;

]]

ffi.cdef[[
typedef struct tagBITMAP {
  LONG   bmType;
  LONG   bmWidth;
  LONG   bmHeight;
  LONG   bmWidthBytes;
  WORD   bmPlanes;
  WORD   bmBitsPixel;
  LPVOID bmBits;
} BITMAP, *PBITMAP;
]]

local BITMAP = ffi.typeof("BITMAP")

ffi.cdef[[
typedef struct tagBITMAPCOREHEADER {
  DWORD   bcSize;
  WORD    bcWidth;
  WORD    bcHeight;
  WORD    bcPlanes;
  WORD    bcBitCount;
} BITMAPCOREHEADER, *PBITMAPCOREHEADER;

typedef struct tagBITMAPINFOHEADER{
  DWORD  biSize;
  LONG   biWidth;
  LONG   biHeight;
  WORD   biPlanes;
  WORD   biBitCount;
  DWORD  biCompression;
  DWORD  biSizeImage;
  LONG   biXPelsPerMeter;
  LONG   biYPelsPerMeter;
  DWORD  biClrUsed;
  DWORD  biClrImportant;
} BITMAPINFOHEADER, *PBITMAPINFOHEADER;


typedef struct tagBITMAPINFO {
  BITMAPINFOHEADER bmiHeader;
  RGBQUAD          bmiColors[1];
} BITMAPINFO, *PBITMAPINFO;


typedef struct tagCIEXYZ {
  FXPT2DOT30 ciexyzX;
  FXPT2DOT30 ciexyzY;
  FXPT2DOT30 ciexyzZ;
} CIEXYZ, * PCIEXYZ;


typedef struct tagCIEXYZTRIPLE {
  CIEXYZ  ciexyzRed;
  CIEXYZ  ciexyzGreen;
  CIEXYZ  ciexyzBlue;
} CIEXYZTRIPLE, *PCIEXYZTRIPLE;



typedef struct {
  DWORD        bV4Size;
  LONG         bV4Width;
  LONG         bV4Height;
  WORD         bV4Planes;
  WORD         bV4BitCount;
  DWORD        bV4V4Compression;
  DWORD        bV4SizeImage;
  LONG         bV4XPelsPerMeter;
  LONG         bV4YPelsPerMeter;
  DWORD        bV4ClrUsed;
  DWORD        bV4ClrImportant;
  DWORD        bV4RedMask;
  DWORD        bV4GreenMask;
  DWORD        bV4BlueMask;
  DWORD        bV4AlphaMask;
  DWORD        bV4CSType;
  CIEXYZTRIPLE bV4Endpoints;
  DWORD        bV4GammaRed;
  DWORD        bV4GammaGreen;
  DWORD        bV4GammaBlue;
} BITMAPV4HEADER, *PBITMAPV4HEADER;

typedef struct {
  DWORD        bV5Size;
  LONG         bV5Width;
  LONG         bV5Height;
  WORD         bV5Planes;
  WORD         bV5BitCount;
  DWORD        bV5Compression;
  DWORD        bV5SizeImage;
  LONG         bV5XPelsPerMeter;
  LONG         bV5YPelsPerMeter;
  DWORD        bV5ClrUsed;
  DWORD        bV5ClrImportant;
  DWORD        bV5RedMask;
  DWORD        bV5GreenMask;
  DWORD        bV5BlueMask;
  DWORD        bV5AlphaMask;
  DWORD        bV5CSType;
  CIEXYZTRIPLE bV5Endpoints;
  DWORD        bV5GammaRed;
  DWORD        bV5GammaGreen;
  DWORD        bV5GammaBlue;
  DWORD        bV5Intent;
  DWORD        bV5ProfileData;
  DWORD        bV5ProfileSize;
  DWORD        bV5Reserved;
} BITMAPV5HEADER, *PBITMAPV5HEADER;

]]


BITMAPINFOHEADER = nil
BITMAPINFOHEADER_mt = {

  __index = {
    __new = function(ct)
    print("BITMAPINFOHEADER_ct")
      local obj = ffi.new(ct);
      obj.biSize = ffi.sizeof("BITMAPINFOHEADER")
      return obj;
    end,

    Init = function(self)
      self.biSize = ffi.sizeof("BITMAPINFOHEADER")
    end,
  }
}
BITMAPINFOHEADER = ffi.metatype("BITMAPINFOHEADER", BITMAPINFOHEADER_mt)


BITMAPINFO = ffi.typeof("BITMAPINFO")
BITMAPINFO_mt = {
  __new = function(ct)
  print("BITMAPINFO_ct")
    local obj = ffi.new(ct);
    obj:Init();
    obj.bmiHeader:Init();
    return obj;
  end,

  __index = {
    Init = function(self)
      self.bmiHeader:Init();
    end,
  },
}
BITMAPINFO = ffi.metatype("BITMAPINFO", BITMAPINFO_mt)


ffi.cdef[[
BOOL AlphaBlend(
  HDC hdcDest,
  int xoriginDest,
  int yoriginDest,
  int wDest,
  int hDest,
  HDC hdcSrc,
  int xoriginSrc,
  int yoriginSrc,
  int wSrc,
  int hSrc,
  BLENDFUNCTION ftn
);

BOOL BitBlt(  HDC hdcDest,
  int nXDest,
  int nYDest,
  int nWidth,
  int nHeight,
  HDC hdcSrc,
  int nXSrc,
  int nYSrc,
  DWORD dwRop);

HBITMAP CreateBitmap(
  int nWidth,
  int nHeight,
  UINT cPlanes,
  UINT cBitsPerPel,
  const void *lpvBits
);

HBITMAP CreateBitmapIndirect(const BITMAP *lpbm);

HBITMAP CreateCompatibleBitmap(HDC hdc,
  int nWidth,
  int nHeight);

HBITMAP CreateDIBitmap(
  HDC hdc,
  const BITMAPINFOHEADER *lpbmih,
  DWORD fdwInit,
  const void *lpbInit,
  const BITMAPINFO *lpbmi,
  UINT fuUsage
);

HBITMAP CreateDIBSection(HDC hdc,
  const BITMAPINFO *pbmi,
  UINT iUsage,
  void **ppvBits,
  HANDLE hSection,
  DWORD dwOffset);

BOOL ExtFloodFill(
  HDC hdc,
  int nXStart,
  int nYStart,
  COLORREF crColor,
  UINT fuFillType
);



LONG GetBitmapBits(
   HBITMAP hbmp,
   LONG cbBuffer,
   LPVOID lpvBits
);

BOOL GetBitmapDimensionEx(
   HBITMAP hBitmap,
   LPSIZE lpDimension
);

UINT GetDIBColorTable(
   HDC hdc,
   UINT uStartIndex,
   UINT cEntries,
   RGBQUAD *pColors
);

int   GetDIBits(HDC hdc,
  HBITMAP hbmp,
  UINT uStartScan,
  UINT cScanLines,
  LPVOID lpvBits,
  PBITMAPINFO lpbi,
  UINT uUsage);

COLORREF GetPixel(
  HDC hdc,
  int nXPos,
  int nYPos
);

int GetStretchBltMode(
  HDC hdc
);

BOOL GradientFill(
  HDC hdc,
  PTRIVERTEX pVertex,
  ULONG nVertex,
  PVOID pMesh,
  ULONG nMesh,
  ULONG ulMode
);

BOOL MaskBlt(
  HDC hdcDest,
  int nXDest,
  int nYDest,
  int nWidth,
  int nHeight,
  HDC hdcSrc,
  int nXSrc,
  int nYSrc,
  HBITMAP hbmMask,
  int xMask,
  int yMask,
  DWORD dwRop
);

BOOL PlgBlt(
  HDC hdcDest,
  const POINT *lpPoint,
  HDC hdcSrc,
  int nXSrc,
  int nYSrc,
  int nWidth,
  int nHeight,
  HBITMAP hbmMask,
  int xMask,
  int yMask
);

UINT SetDIBColorTable(
  HDC hdc,
  UINT uStartIndex,
  UINT cEntries,
  const RGBQUAD *pColors
);

int SetDIBits(
  HDC hdc,
  HBITMAP hbmp,
  UINT uStartScan,
  UINT cScanLines,
  const VOID *lpvBits,
  const BITMAPINFO *lpbmi,
  UINT fuColorUse
);

int SetDIBitsToDevice(
  HDC hdc,
  int XDest,
  int YDest,
  DWORD dwWidth,
  DWORD dwHeight,
  int XSrc,
  int YSrc,
  UINT uStartScan,
  UINT cScanLines,
  const VOID *lpvBits,
  const BITMAPINFO *lpbmi,
  UINT fuColorUse
);

uint32_t SetPixel(HDC hdc, int x, int y, uint32_t color);
BOOL SetPixelV(HDC hdc, int X, int Y, uint32_t crColor);

int SetStretchBltMode(
  HDC hdc,
  int iStretchMode
);

BOOL StretchBlt(
  HDC hdcDest,
  int nXOriginDest,
  int nYOriginDest,
  int nWidthDest,
  int nHeightDest,
  HDC hdcSrc,
  int nXOriginSrc,
  int nYOriginSrc,
  int nWidthSrc,
  int nHeightSrc,
  DWORD dwRop
);

int StretchDIBits(HDC hdc,
  int XDest,
  int YDest,
  int nDestWidth,
  int nDestHeight,
  int XSrc,
  int YSrc,
  int nSrcWidth,
  int nSrcHeight,
  const void *lpBits,
  const BITMAPINFO *lpBitsInfo,
  UINT iUsage,
  DWORD dwRop);

BOOL TransparentBlt(
  HDC hdcDest,
  int xoriginDest,
  int yoriginDest,
  int wDest,
  int hDest,
  HDC hdcSrc,
  int xoriginSrc,
  int yoriginSrc,
  int wSrc,
  int hSrc,
  UINT crTransparent
);
]]


--[[
  Coordinate Space and Transformation
--]]
ffi.cdef[[
/* Graphics Modes */

typedef enum {
  GM_COMPATIBLE      = 1,
  GM_ADVANCED        = 2
} GraphicsMode;

/* Mapping Modes */
typedef enum {
  MM_TEXT            = 1,
  MM_LOMETRIC        = 2,
  MM_HIMETRIC        = 3,
  MM_LOENGLISH       = 4,
  MM_HIENGLISH       = 5,
  MM_TWIPS           = 6,
  MM_ISOTROPIC       = 7,
  MM_ANISOTROPIC     = 8
} MappingMode;

]]

ffi.cdef[[
typedef struct _XFORM {
  FLOAT eM11;
  FLOAT eM12;
  FLOAT eM21;
  FLOAT eM22;
  FLOAT eDx;
  FLOAT eDy;
} XFORM, *PXFORM, *LPXFORM;
]]
local XFORM = ffi.typeof("XFORM")

ffi.cdef[[

BOOL CombineTransform(
  LPXFORM lpxformResult,
  const XFORM *lpxform1,
  const XFORM *lpxform2
);

BOOL DPtoLP(
    HDC hdc,
    PPOINT lpPoints,
    int nCount
);

BOOL GetCurrentPositionEx(
  HDC hdc,
  LPPOINT lpPoint
);

GraphicsMode GetGraphicsMode(
  HDC hdc
);

MappingMode GetMapMode(
  HDC hdc
);

BOOL GetViewportExtEx(
  HDC hdc,
  LPSIZE lpSize
);

BOOL GetViewportOrgEx(
  HDC hdc,
  LPPOINT lpPoint
);

BOOL GetWindowExtEx(
  HDC hdc,
  LPSIZE lpSize
);

BOOL GetWindowOrgEx(
  HDC hdc,
  LPPOINT lpPoint
);

BOOL GetWorldTransform(
  HDC hdc,
  LPXFORM lpXform
);

BOOL LPtoDP(
    HDC hdc,
  LPPOINT lpPoints,
    int nCount
);

BOOL ModifyWorldTransform(
  HDC hdc,
  const XFORM *lpXform,
  DWORD iMode
);

BOOL OffsetViewportOrgEx(
  HDC hdc,
  int nXOffset,
  int nYOffset,
  LPPOINT lpPoint
);

BOOL OffsetWindowOrgEx(
  HDC hdc,
  int nXOffset,
  int nYOffset,
  LPPOINT lpPoint
);

BOOL ScaleViewportExtEx(
  HDC hdc,
  int Xnum,
  int Xdenom,
  int Ynum,
  int Ydenom,
  LPSIZE lpSize
);

BOOL ScaleWindowExtEx(
  HDC hdc,
  int Xnum,
  int Xdenom,
  int Ynum,
  int Ydenom,
  LPSIZE lpSize
);

int SetGraphicsMode(
  HDC hdc,
  GraphicsMode iMode
);

int SetMapMode(
  HDC hdc,
  MappingMode fnMapMode
);

BOOL SetViewportExtEx(
  HDC hdc,
  int nXExtent,
  int nYExtent,
  LPSIZE lpSize
);

BOOL SetViewportOrgEx(
  HDC hdc,
  int X,
  int Y,
  LPPOINT lpPoint
);

BOOL SetWindowExtEx(
  HDC hdc,
  int nXExtent,
  int nYExtent,
  LPSIZE lpSize
);

BOOL SetWindowOrgEx(
  HDC hdc,
  int X,
  int Y,
  LPPOINT lpPoint
);

BOOL SetWorldTransform(
  HDC hdc,
  const XFORM *lpXform
);


]]

--[[
    Device Context
--]]
ffi.cdef[[
typedef int (__stdcall * GOBJENUMPROC)(LPVOID, LPARAM);

static const int  CCHDEVICENAME = 32;
static const int  CCHFORMNAME = 32;


typedef struct _devicemode {
  BCHAR  dmDeviceName[CCHDEVICENAME];
  WORD   dmSpecVersion;
  WORD   dmDriverVersion;
  WORD   dmSize;
  WORD   dmDriverExtra;
  DWORD  dmFields;
  union {
    struct {
      short dmOrientation;
      short dmPaperSize;
      short dmPaperLength;
      short dmPaperWidth;
      short dmScale;
      short dmCopies;
      short dmDefaultSource;
      short dmPrintQuality;
    };
    POINTL dmPosition;
    DWORD  dmDisplayOrientation;
    DWORD  dmDisplayFixedOutput;
  };

  short  dmColor;
  short  dmDuplex;
  short  dmYResolution;
  short  dmTTOption;
  short  dmCollate;
  BYTE  dmFormName[CCHFORMNAME];
  WORD  dmLogPixels;
  DWORD  dmBitsPerPel;
  DWORD  dmPelsWidth;
  DWORD  dmPelsHeight;
  union {
    DWORD  dmDisplayFlags;
    DWORD  dmNup;
  };
  DWORD  dmDisplayFrequency;
  DWORD  dmICMMethod;
  DWORD  dmICMIntent;
  DWORD  dmMediaType;
  DWORD  dmDitherType;
  DWORD  dmReserved1;
  DWORD  dmReserved2;
  DWORD  dmPanningWidth;
  DWORD  dmPanningHeight;
} DEVMODE, *PDEVMODE;
]]

ffi.cdef[[

BOOL CancelDC(HDC hdc);

HDC   CreateCompatibleDC(HDC hdc);

HDC   CreateDCA(LPCSTR lpszDriver,LPCSTR lpszDevice,LPCSTR lpszOutput,const void * lpInitData);

HDC CreateICA(
  LPCTSTR lpszDriver,
  LPCTSTR lpszDevice,
  LPCTSTR lpszOutput,
  const DEVMODE *lpdvmInit
);

BOOL DeleteDC(
  HDC hdc
);

BOOL DeleteObject(
  HGDIOBJ hObject
);

int DrawEscape(
  HDC hdc,
  int nEscape,
  int cbInput,
  LPCSTR lpszInData
);

int EnumObjects(
  HDC hdc,
  int nObjectType,
  GOBJENUMPROC lpObjectFunc,
  LPARAM lParam
);

HGDIOBJ GetCurrentObject(
  HDC hdc,
  UINT uObjectType
);

int   GetDeviceCaps(HDC hdc, DevCapEnums index);

int GetObjectA(HGDIOBJ hgdiobj, int cbBuffer, LPVOID lpvObject);

HGDIOBJ GetStockObject(int fnObject);

bool  GdiFlush();


HDC ResetDC(HDC hdc, const DEVMODE *lpInitData);

bool  RestoreDC(HDC hdc, int nSavedDC);

int   SaveDC(HDC hdc);

HGDIOBJ SelectObject(HDC hdc, HGDIOBJ hgdiobj);

COLORREF SetDCBrushColor(HDC hdc, COLORREF crColor);


DWORD SetLayout(
  HDC hdc,
  DWORD dwLayout
);

]]

--[[
  Filled Shapes
--]]

ffi.cdef[[
BOOL Ellipse(HDC hdc,
  int nLeftRect,
  int nTopRect,
  int nRightRect,
  int nBottomRect);

BOOL Pie(
  HDC hdc,
  int nLeftRect,
  int nTopRect,
  int nRightRect,
  int nBottomRect,
  int nXRadial1,
  int nYRadial1,
  int nXRadial2,
  int nYRadial2
);

BOOL Polygon(
  HDC hdc,
  const POINT *lpPoints,
  int nCount
);

BOOL PolyPolygon(
  HDC hdc,
  const POINT *lpPoints,
  const INT *lpPolyCounts,
  int nCount
);

bool Rectangle(HDC hdc, int left, int top, int right, int bottom);

bool RoundRect(HDC hdc, int left, int top, int right, int bottom,
  int width, int height);



]]

--[[
  Lines And Arcs
--]]
ffi.cdef[[
// Drawing

BOOL AngleArc(
  HDC hdc,
  int X,
  int Y,
  DWORD dwRadius,
  FLOAT eStartAngle,
  FLOAT eSweepAngle
);

BOOL Arc(
  HDC hdc,
  int nLeftRect,
  int nTopRect,
  int nRightRect,
  int nBottomRect,
  int nXStartArc,
  int nYStartArc,
  int nXEndArc,
  int nYEndArc
);

BOOL ArcTo(
  HDC hdc,
  int nLeftRect,
  int nTopRect,
  int nRightRect,
  int nBottomRect,
  int nXRadial1,
  int nYRadial1,
  int nXRadial2,
  int nYRadial2
);



int GetArcDirection(
  HDC hdc
);

BOOL LineDDA(
  int nXStart,
  int nYStart,
  int nXEnd,
  int nYEnd,
  LINEDDAPROC lpLineFunc,
  LPARAM lpData
);

int LineTo(HDC hdc, int nXEnd, int nYEnd);

int MoveToEx(HDC hdc, int X, int Y, POINT * lpPoint);

BOOL PolyBezier(
  HDC hdc,
  const POINT *lppt,
  DWORD cPoints
);

BOOL PolyBezierTo(
  HDC hdc,
  const POINT *lppt,
  DWORD cCount
);

BOOL PolyDraw(
  HDC hdc,
  const POINT *lppt,
  const BYTE *lpbTypes,
  int cCount
);

BOOL Polyline(
  HDC hdc,
  const POINT *lppt,
  int cPoints
);

BOOL PolylineTo(
  HDC hdc,
  const POINT *lppt,
  DWORD cCount
);

BOOL PolyPolyline(
  HDC hdc,
  const POINT *lppt,
  const DWORD *lpdwPolyPoints,
  DWORD cCount
);


int SetArcDirection(
  HDC hdc,
  int ArcDirection
);


// Text
BOOL TextOutA(HDC hdc, int nXStart, int nYStart, LPCSTR lpString, int cbString);

]]

--[[
  Brushes
--]]
ffi.cdef[[
typedef struct tagLOGBRUSH {
  UINT      lbStyle;
  COLORREF  lbColor;
  ULONG_PTR lbHatch;
} LOGBRUSH, *PLOGBRUSH;

typedef struct tagLOGBRUSH32 {
  UINT     lbStyle;
  COLORREF lbColor;
  ULONG    lbHatch;
} LOGBRUSH32, *PLOGBRUSH32;
]]

--[[
  Pens
--]]
ffi.cdef[[
typedef struct tagLOGPEN {
  UINT     lopnStyle;
  POINT    lopnWidth;
  COLORREF lopnColor;
} LOGPEN, *PLOGPEN;

typedef struct tagEXTLOGPEN {
  DWORD     elpPenStyle;
  DWORD     elpWidth;
  UINT      elpBrushStyle;
  COLORREF  elpColor;
  ULONG_PTR elpHatch;
  DWORD     elpNumEntries;
  DWORD     elpStyleEntry[1];
} EXTLOGPEN, *PEXTLOGPEN;
]]

ffi.cdef[[
HPEN CreatePen(
  int fnPenStyle,
  int nWidth,
  COLORREF crColor);

HPEN CreatePenIndirect(const LOGPEN *lplgpn);

HPEN ExtCreatePen(
  DWORD dwPenStyle,
  DWORD dwWidth,
  const LOGBRUSH *lplb,
  DWORD dwStyleCount,
  const DWORD *lpStyle
);

COLORREF SetDCPenColor(HDC hdc, COLORREF crColor);

]]



local gdi32_ffi = {
  Lib = Lib,
  
-- Pixel Types
  PFD_TYPE_RGBA = 0,
  ColorIndex = 1,

  -- Layer Types
    PFD_MAIN_PLANE = 0,
    Overlay = 1,
    Underlay = (-1),

  --PIXELFORMATDESCRIPTOR flags
  PFD_DOUBLEBUFFER = 0x00000001,
    Stereo = 0x00000002,
  PFD_DRAW_TO_WINDOW = 0x00000004,
  DrawToBitmap = 0x00000008,
  SupportGDI = 0x00000010,
  PFD_SUPPORT_OPENGL = 0x00000020,
  GenericFormat = 0x00000040,
  NeedPalette = 0x00000080,
  NeedSystemPalette = 0x00000100,
  SwapExchange = 0x00000200,
  SwapCopy = 0x00000400,
  SwapLayerBuffers = 0x00000800,
  GenericAccelerated = 0x00001000,
  SupportDirectDraw = 0x00002000,
  Direct3DAccelerated = 0x00004000,
  SupportComposition = 0x00008000,

  -- PIXELFORMATDESCRIPTOR flags for use in ChoosePixelFormat only
  PFD_DEPTH_DONTCARE = 0x20000000,
  PFD_DOUBLEBUFFER_DONTCARE = 0x40000000,
  PFD_STEREO_DONTCARE = 0x80000000,


  SRCCOPY   = 0x00CC0020,
  SRCPAINT  = 0x00EE0086,
  SRCERASE  = 0x00440328,
  BLACKNESS = 0x00000042,
  WHITENESS = 0x00FF0062,

  -- Stock Object Index
  WHITE_BRUSH        = 0,
  LTGRAY_BRUSH        = 1,
  GRAY_BRUSH          = 2,
  DKGRAY_BRUSH        = 3,
  BLACK_BRUSH         = 4,
  NULL_BRUSH          = 5,
  --HOLLOW_BRUSH        = NULL_BRUSH,
  WHITE_PEN           = 6,
  BLACK_PEN           = 7,
  NULL_PEN            = 8,
  OEM_FIXED_FONT      = 10,
  ANSI_FIXED_FONT     = 11,
  ANSI_VAR_FONT       = 12,
  SYSTEM_FONT         = 13,
  DEVICE_DEFAULT_FONT = 14,
  DEFAULT_PALETTE     = 15,
  SYSTEM_FIXED_FONT   = 16,
  DEFAULT_GUI_FONT    = 17,
  DC_BRUSH            = 18,
  DC_PEN              = 19,


  -- Types
  BITMAP = BITMAP,
  BITMAPINFOHEADER = BITMAPINFOHEADER,
  XFORM = XFORM,
  
  -- Functions
  -- Bitmaps
  AlphaBlend = ImgLib.AlphaBlend,
  GradientFill = ImgLib.GradientFill,
  TransparentBlt = ImgLib.TransparentBlt,

  -- Coordinates and Viewport
  CombineTransform = Lib.CombineTransform,
  DPtoLP = Lib.DPtoLP,
  GetMapMode = Lib.GetMapMode,
  GetViewportExtEx = Lib.GetViewportExtEx,
  GetViewportOrgEx = Lib.GetViewportOrgEx,
  GetWindowExtEx = Lib.GetWindowExtEx,
  GetWindowOrgEx = Lib.GetWindowOrgEx,
  GetWorldTransform = Lib.GetWorldTransform,
  LPtoDP = Lib.LPtoDP,
  ModifyWorldTransform = Lib.ModifyWorldTransform,
  OffsetViewportOrgEx = Lib.OffsetViewportOrgEx,
  OffsetWindowOrgEx = Lib.OffsetWindowOrgEx,
  ScaleViewportExtEx = Lib.ScaleViewportExtEx,
  ScaleWindowExtEx = Lib.ScaleWindowExtEx,
  SetGraphicsMode = Lib.SetGraphicsMode,
  SetMapMode = Lib.SetMapMode,
  SetViewportExtEx = Lib.SetViewportExtEx,
  SetViewportOrgEx = Lib.SetViewportOrgEx,
  SetWindowExtEx = Lib.SetWindowExtEx,
  SetWindowOrgEx = Lib.SetWindowOrgEx,
  SetWorldTransform = Lib.SetWorldTransform,

  -- Arcs and Lines
  AngleArc = Lib.AngleArc,
  Arc = Lib.Arc,
  ArcTo = Lib.ArcTo,
  BitBlt = Lib.BitBlt,
  Ellipse = Lib.Ellipse,
  GetArcDirection = Lib.GetArcDirection,
  GetDeviceCaps = Lib.GetDeviceCaps,
  LineDDA = Lib.LineDDA,
  LineTo = Lib.LineTo,
  MoveToEx = Lib.MoveToEx,
  PolyBezier = Lib.PolyBezier,
  PolyBezierTo = Lib.PolyBezierTo,
  PolyDraw = Lib.PolyDraw,
  Polyline = Lib.Polyline,
  PolylineTo = Lib.PolylineTo,
  PolyPolyline = Lib.PolyPolyline,
  Rectangle = Lib.Rectangle,
  RoundRect = Lib.RoundRect,
  SetArcDirection = Lib.SetArcDirection,
  SetPixel = Lib.SetPixel,
  SetPixelV = Lib.SetPixelV,
  StretchBlt = Lib.StretchBlt,
  StretchDIBits = Lib.StretchDIBits,
  TextOutA = Lib.TextOutA,

  -- Filled shapes
  Polygon = Lib.Polygon,
}

return gdi32_ffi
