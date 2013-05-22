local ffi = require "ffi"
local C = ffi.C
local bit = require "bit"
local lshift = bit.lshift
local rshift = bit.rshift

local band = bit.band	-- &
local bor = bit.bor	-- |
local bnot = bit.bnot	-- ~

require "WTypes"

local gdi32_ffi = {
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


	SRCCOPY		= 0x00CC0020,
	SRCPAINT	= 0x00EE0086,
	SRCERASE	= 0x00440328,
	BLACKNESS	= 0x00000042,
	WHITENESS	= 0x00FF0062,

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

}



-- GDI32
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
HDC CreateDCA(LPCSTR lpszDriver,LPCSTR lpszDevice,LPCSTR lpszOutput,const void * lpInitData);
HDC CreateCompatibleDC(HDC hdc);
HDC GdiGetDC(HWND hWnd);    // For print spoolers
HDC GetWindowDC(HWND hWnd);

int SaveDC(void *hdc);
bool RestoreDC(void *hdc, int nSavedDC);

COLORREF SetDCPenColor(HDC hdc, COLORREF crColor);
COLORREF SetDCBrushColor(HDC hdc, COLORREF crColor);

HGDIOBJ SelectObject(HDC hdc, HGDIOBJ hgdiobj);
int GetObjectA(HGDIOBJ hgdiobj, int cbBuffer, LPVOID lpvObject);
HGDIOBJ GetStockObject(int fnObject);

bool GdiFlush();

// Drawing
uint32_t SetPixel(HDC hdc, int x, int y, uint32_t color);
BOOL SetPixelV(HDC hdc, int X, int Y, uint32_t crColor);

int MoveToEx(HDC hdc, int X, int Y, void *lpPoint);

int LineTo(HDC hdc, int nXEnd, int nYEnd);

bool Rectangle(HDC hdc, int left, int top, int right, int bottom);

bool RoundRect(HDC hdc, int left, int top, int right, int bottom,
	int width, int height);


BOOL Ellipse(HDC hdc,
  int nLeftRect,
  int nTopRect,
  int nRightRect,
  int nBottomRect);



int GetDIBits(HDC hdc,
	HBITMAP hbmp,
	UINT uStartScan,
	UINT cScanLines,
	LPVOID lpvBits,
	PBITMAPINFO lpbi,
	UINT uUsage);

BOOL BitBlt(  HDC hdcDest,
  int nXDest,
  int nYDest,
  int nWidth,
  int nHeight,
  HDC hdcSrc,
  int nXSrc,
  int nYSrc,
  DWORD dwRop);

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

  // Text
  BOOL TextOutA(HDC hdc, int nXStart, int nYStart, LPCSTR lpString, int cbString);

HBITMAP CreateCompatibleBitmap(HDC hdc,
  int nWidth,
  int nHeight);

HBITMAP CreateDIBSection(HDC hdc,
  const BITMAPINFO *pbmi,
  UINT iUsage,
  void **ppvBits,
  HANDLE hSection,
  DWORD dwOffset);
]]



return gdi32_ffi
