local ffi = require"ffi"
local bit = require"bit"

local bnot = bit.bnot
local band = bit.band
local bor = bit.bor
local lshift = bit.lshift
local rshift = bit.rshift

local basetsd = require("basetsd");


ffi.cdef[[


typedef uint32_t *  PDWORD;
typedef long *    PLONG;
typedef long            *LPLONG;

]]


ffi.cdef[[

// Basic Data types
typedef unsigned char *PBYTE;

typedef BYTE			BOOLEAN;

typedef wchar_t			  WCHAR;


typedef long      BOOL;
typedef long *    PBOOL;


typedef int *        LPINT;
typedef int *        PINT;




typedef float 			FLOAT;
typedef double          DOUBLE;

typedef uint8_t			BCHAR;
typedef unsigned int	UINT32;


// Some pointer types
typedef char *			PCHAR;
typedef const char * PCCHAR;
typedef unsigned char *PUCHAR;
typedef char *      PSTR;


typedef uint16_t *		PWCHAR;

typedef unsigned char *PBOOLEAN;
typedef const unsigned char *PCUCHAR;
typedef unsigned int	*PUINT;
typedef unsigned int	*PUINT32;
typedef unsigned long	*PULONG;
typedef unsigned short	*PUSHORT;
typedef LONGLONG 		*PLONGLONG;
typedef ULONGLONG 		*PULONGLONG;


typedef void        VOID;
typedef void *			PVOID;
]]



ffi.cdef[[


typedef DWORD *			LPCOLORREF;

typedef BOOL *			LPBOOL;
typedef BYTE *      LPBYTE;
typedef char *			LPSTR;
typedef short *			LPWSTR;
typedef short *			PWSTR;
typedef const short *	LPCWSTR;
typedef const short *	PCWSTR;
typedef PWSTR *PZPWSTR;
typedef LPSTR			LPTSTR;

typedef DWORD *			LPDWORD;
typedef void *			LPVOID;
typedef WORD *			LPWORD;

typedef const char *	LPCSTR;
typedef const char *	PCSTR;
typedef LPCSTR			LPCTSTR;
typedef const void *	LPCVOID;


typedef LONG_PTR		LRESULT;

typedef LONG_PTR		LPARAM;
typedef UINT_PTR		WPARAM;


typedef unsigned char	TBYTE;
typedef char			TCHAR;

typedef USHORT			COLOR16;
typedef DWORD			COLORREF;

// Special types
typedef WORD			ATOM;
typedef DWORD			LCID;
typedef USHORT			LANGID;
]]

ffi.cdef[[
typedef struct tagDEC {
    USHORT wReserved;
    union {
        struct {
            BYTE scale;
            BYTE sign;
        };
        USHORT signscale;
    };
    ULONG Hi32;
    union {
        struct {
            ULONG Lo32;
            ULONG Mid32;
        } ;
        ULONGLONG Lo64;
    } ;
} DECIMAL;
typedef DECIMAL *LPDECIMAL;
]]
--[[
#define DECIMAL_NEG ((BYTE)0x80)
#define DECIMAL_SETZERO(dec) \
        {(dec).Lo64 = 0; (dec).Hi32 = 0; (dec).signscale = 0;}
--]]

ffi.cdef[[
// Ole Automation
typedef WCHAR			OLECHAR;
typedef OLECHAR 		*LPOLESTR;
typedef const OLECHAR	*LPCOLESTR;

//typedef char      OLECHAR;
//typedef LPSTR     LPOLESTR;
//typedef LPCSTR    LPCOLESTR;

typedef OLECHAR *BSTR;
typedef BSTR *LPBSTR;

typedef struct tagBSTRBLOB
    {
    ULONG cbSize;
    BYTE *pData;
    }   BSTRBLOB;

typedef struct tagBSTRBLOB *LPBSTRBLOB;

]]

ffi.cdef[[
/* 0 == FALSE, -1 == TRUE */
typedef short VARIANT_BOOL;
typedef VARIANT_BOOL _VARIANT_BOOL;

]]


ffi.cdef[[
typedef DWORD ACCESS_MASK;
typedef ACCESS_MASK* PACCESS_MASK;


typedef LONG FXPT16DOT16, *LPFXPT16DOT16;
typedef LONG FXPT2DOT30, *LPFXPT2DOT30;
]]

ffi.cdef[[
typedef struct tagBLOB
    {
    ULONG cbSize;
    /* [size_is] */ BYTE *pBlobData;
    }   BLOB;

typedef struct tagBLOB *LPBLOB;
]]

ffi.cdef[[
typedef struct tagCLIPDATA
    {
    ULONG cbSize;
    long ulClipFmt;
    BYTE *pClipData;
    }   CLIPDATA;

typedef unsigned short VARTYPE;
]]

if STRICT then
    ffi.cdef[[
        typedef void *HANDLE;
    ]]

    function DECLARE_HANDLE(name) 
        ffi.cdef(string.format("struct %s__{int unused;}; typedef struct %s__ *%s", name, name, name));
    end
else
    ffi.cdef[[
        typedef PVOID HANDLE;
    ]]
    
    function DECLARE_HANDLE(name) 
        ffi.cdef(string.format("typedef HANDLE %s",name));
    end
end

ffi.cdef[[
typedef HANDLE *PHANDLE;
]]

ffi.cdef[[
// Various Handles
typedef HANDLE       *  LPHANDLE;
typedef void *          HBITMAP;
typedef void *          HBRUSH;
typedef void *          HICON;
typedef HICON           HCURSOR;
typedef HANDLE          HDC;
typedef void *          HDESK;
typedef HANDLE          HDROP;
typedef HANDLE          HDWP;
typedef HANDLE          HENHMETAFILE;
typedef INT             HFILE;
typedef HANDLE          HFONT;
typedef void *          HGDIOBJ;
typedef HANDLE          HGLOBAL;
typedef HANDLE          HGLRC;
typedef HANDLE          HHOOK;
typedef void *          HINSTANCE;
typedef void *          HKEY;
typedef HKEY *      PHKEY;
typedef void *          HKL;
typedef HANDLE          HLOCAL;
typedef void *          HMEMF;
typedef HANDLE          HMENU;
typedef HANDLE          HMETAFILE;
typedef void            HMF;
typedef HINSTANCE       HMODULE;
typedef HANDLE          HMONITOR;
typedef HANDLE          HPALETTE;
typedef void *          HPEN;
typedef LONG            HRESULT;
typedef HANDLE          HRGN;
typedef void *          HRSRC;
typedef void *          HSTR;
typedef HANDLE          HSZ;
typedef void *          HTASK;
typedef void *          HWINSTA;
typedef HANDLE          HWND;
]]

require "guiddef"



ffi.cdef[[
// Update Sequence Number

typedef LONGLONG USN;


typedef union _LARGE_INTEGER {
	struct {
		DWORD LowPart;
		LONG HighPart;
	};
	struct {
		DWORD LowPart;
		LONG HighPart;
	} u;
	LONGLONG QuadPart;
} LARGE_INTEGER,  *PLARGE_INTEGER;

typedef struct _ULARGE_INTEGER
{
    ULONGLONG QuadPart;
} 	ULARGE_INTEGER;

typedef ULARGE_INTEGER *PULARGE_INTEGER;

]]


ffi.cdef[[
typedef struct _FILETIME
{
    DWORD dwLowDateTime;
    DWORD dwHighDateTime;
} 	FILETIME;

typedef struct _FILETIME *PFILETIME;

typedef struct _FILETIME *LPFILETIME;
]]

ffi.cdef[[
typedef struct _SYSTEMTIME
{
    WORD wYear;
    WORD wMonth;
    WORD wDayOfWeek;
    WORD wDay;
    WORD wHour;
    WORD wMinute;
    WORD wSecond;
    WORD wMilliseconds;
} 	SYSTEMTIME, *PSYSTEMTIME, *LPSYSTEMTIME;


typedef struct _SECURITY_ATTRIBUTES {
	DWORD nLength;
	LPVOID lpSecurityDescriptor;
	BOOL bInheritHandle;
} SECURITY_ATTRIBUTES,  *PSECURITY_ATTRIBUTES,  *LPSECURITY_ATTRIBUTES;


typedef USHORT SECURITY_DESCRIPTOR_CONTROL;

typedef USHORT *PSECURITY_DESCRIPTOR_CONTROL;

typedef LONG SECURITY_STATUS;

typedef PVOID PSID;

typedef LONG SCODE;

typedef SCODE *PSCODE;


typedef
enum tagMEMCTX
    {	MEMCTX_TASK	= 1,
	MEMCTX_SHARED	= 2,
	MEMCTX_MACSYSTEM	= 3,
	MEMCTX_UNKNOWN	= -1,
	MEMCTX_SAME	= -2
    } 	MEMCTX;




typedef
enum tagMSHLFLAGS
    {	MSHLFLAGS_NORMAL	= 0,
	MSHLFLAGS_TABLESTRONG	= 1,
	MSHLFLAGS_TABLEWEAK	= 2,
	MSHLFLAGS_NOPING	= 4,
	MSHLFLAGS_RESERVED1	= 8,
	MSHLFLAGS_RESERVED2	= 16,
	MSHLFLAGS_RESERVED3	= 32,
	MSHLFLAGS_RESERVED4	= 64
    } 	MSHLFLAGS;

typedef
enum tagMSHCTX
    {	MSHCTX_LOCAL	= 0,
	MSHCTX_NOSHAREDMEM	= 1,
	MSHCTX_DIFFERENTMACHINE	= 2,
	MSHCTX_INPROC	= 3,
	MSHCTX_CROSSCTX	= 4
    } 	MSHCTX;

typedef
enum tagDVASPECT
    {	DVASPECT_CONTENT	= 1,
	DVASPECT_THUMBNAIL	= 2,
	DVASPECT_ICON	= 4,
	DVASPECT_DOCPRINT	= 8
    } 	DVASPECT;

typedef
enum tagSTGC
    {	STGC_DEFAULT	= 0,
	STGC_OVERWRITE	= 1,
	STGC_ONLYIFCURRENT	= 2,
	STGC_DANGEROUSLYCOMMITMERELYTODISKCACHE	= 4,
	STGC_CONSOLIDATE	= 8
    } 	STGC;

typedef
enum tagSTGMOVE
    {	STGMOVE_MOVE	= 0,
	STGMOVE_COPY	= 1,
	STGMOVE_SHALLOWCOPY	= 2
    } 	STGMOVE;

typedef
enum tagSTATFLAG
    {	STATFLAG_DEFAULT	= 0,
	STATFLAG_NONAME	= 1,
	STATFLAG_NOOPEN	= 2
    } 	STATFLAG;

typedef  void *HCONTEXT;

typedef struct _BYTE_BLOB
    {
    unsigned long clSize;
    uint8_t abData[ 1 ];
    } 	BYTE_BLOB;

typedef struct _WORD_BLOB
    {
    unsigned long clSize;
    unsigned short asData[ 1 ];
    } 	WORD_BLOB;

typedef struct _DWORD_BLOB
    {
    unsigned long clSize;
    unsigned long alData[ 1 ];
    } 	DWORD_BLOB;

typedef struct _FLAGGED_BYTE_BLOB
    {
    unsigned long fFlags;
    unsigned long clSize;
    uint8_t abData[ 1 ];
    } 	FLAGGED_BYTE_BLOB;

typedef struct _FLAGGED_WORD_BLOB
    {
    unsigned long fFlags;
    unsigned long clSize;
    unsigned short asData[ 1 ];
    } 	FLAGGED_WORD_BLOB;

typedef struct _BYTE_SIZEDARR
    {
    unsigned long clSize;
    uint8_t *pData;
    } 	BYTE_SIZEDARR;

typedef struct _SHORT_SIZEDARR
    {
    unsigned long clSize;
    unsigned short *pData;
    } 	WORD_SIZEDARR;

typedef struct _LONG_SIZEDARR
    {
    unsigned long clSize;
    unsigned long *pData;
    } 	DWORD_SIZEDARR;


]]

--typedef enum tagCLSCTX {
	CLSCTX_INPROC_SERVER	= 0x1
	CLSCTX_INPROC_HANDLER	= 0x2
	CLSCTX_LOCAL_SERVER	= 0x4
	CLSCTX_INPROC_SERVER16	= 0x8
	CLSCTX_REMOTE_SERVER	= 0x10
	CLSCTX_INPROC_HANDLER16	= 0x20
	CLSCTX_RESERVED1	= 0x40
	CLSCTX_RESERVED2	= 0x80
	CLSCTX_RESERVED3	= 0x100
	CLSCTX_RESERVED4	= 0x200
	CLSCTX_NO_CODE_DOWNLOAD	= 0x400
	CLSCTX_RESERVED5	= 0x800
	CLSCTX_NO_CUSTOM_MARSHAL	= 0x1000
	CLSCTX_ENABLE_CODE_DOWNLOAD	= 0x2000
	CLSCTX_NO_FAILURE_LOG	= 0x4000
	CLSCTX_DISABLE_AAA	= 0x8000
	CLSCTX_ENABLE_AAA	= 0x10000
	CLSCTX_FROM_DEFAULT_CONTEXT	= 0x20000
	CLSCTX_ACTIVATE_32_BIT_SERVER	= 0x40000
	CLSCTX_ACTIVATE_64_BIT_SERVER	= 0x80000
	CLSCTX_ENABLE_CLOAKING	= 0x100000
	CLSCTX_PS_DLL	= 0x80000000
--} 	CLSCTX;

CLSCTX_VALID_MASK = bor(
    CLSCTX_INPROC_SERVER ,
    CLSCTX_INPROC_HANDLER ,
    CLSCTX_LOCAL_SERVER ,
    CLSCTX_INPROC_SERVER16 ,
    CLSCTX_REMOTE_SERVER ,
    CLSCTX_NO_CODE_DOWNLOAD ,
    CLSCTX_NO_CUSTOM_MARSHAL ,
    CLSCTX_ENABLE_CODE_DOWNLOAD ,
    CLSCTX_NO_FAILURE_LOG ,
    CLSCTX_DISABLE_AAA ,
    CLSCTX_ENABLE_AAA ,
    CLSCTX_FROM_DEFAULT_CONTEXT ,
    CLSCTX_ACTIVATE_32_BIT_SERVER ,
    CLSCTX_ACTIVATE_64_BIT_SERVER ,
    CLSCTX_ENABLE_CLOAKING ,
    CLSCTX_PS_DLL)

WDT_INPROC_CALL	=( 0x48746457 )

WDT_REMOTE_CALL	=( 0x52746457 )

WDT_INPROC64_CALL =	( 0x50746457 )

ffi.cdef[[
typedef struct _tagpropertykey
    {
    GUID fmtid;
    DWORD pid;
    }   PROPERTYKEY;

typedef const PROPERTYKEY * REFPROPERTYKEY;

enum VARENUM
    {   VT_EMPTY    = 0,
    VT_NULL = 1,
    VT_I2   = 2,
    VT_I4   = 3,
    VT_R4   = 4,
    VT_R8   = 5,
    VT_CY   = 6,
    VT_DATE = 7,
    VT_BSTR = 8,
    VT_DISPATCH = 9,
    VT_ERROR    = 10,
    VT_BOOL = 11,
    VT_VARIANT  = 12,
    VT_UNKNOWN  = 13,
    VT_DECIMAL  = 14,
    VT_I1   = 16,
    VT_UI1  = 17,
    VT_UI2  = 18,
    VT_UI4  = 19,
    VT_I8   = 20,
    VT_UI8  = 21,
    VT_INT  = 22,
    VT_UINT = 23,
    VT_VOID = 24,
    VT_HRESULT  = 25,
    VT_PTR  = 26,
    VT_SAFEARRAY    = 27,
    VT_CARRAY   = 28,
    VT_USERDEFINED  = 29,
    VT_LPSTR    = 30,
    VT_LPWSTR   = 31,
    VT_RECORD   = 36,
    VT_INT_PTR  = 37,
    VT_UINT_PTR = 38,
    VT_FILETIME = 64,
    VT_BLOB = 65,
    VT_STREAM   = 66,
    VT_STORAGE  = 67,
    VT_STREAMED_OBJECT  = 68,
    VT_STORED_OBJECT    = 69,
    VT_BLOB_OBJECT  = 70,
    VT_CF   = 71,
    VT_CLSID    = 72,
    VT_VERSIONED_STREAM = 73,
    VT_BSTR_BLOB    = 0xfff,
    VT_VECTOR   = 0x1000,
    VT_ARRAY    = 0x2000,
    VT_BYREF    = 0x4000,
    VT_RESERVED = 0x8000,
    VT_ILLEGAL  = 0xffff,
    VT_ILLEGALMASKED    = 0xfff,
    VT_TYPEMASK = 0xfff
    } ;
    
typedef ULONG PROPID;

]]

ffi.cdef[[
typedef double DATE;

// Currency
typedef union tagCY {
    struct {
        unsigned long Lo;
        long      Hi;
    };
    LONGLONG int64;
} CY;
]]

ffi.cdef[[
enum {
	MAXSHORT = 32767,
	MINSHORT = -32768,

	MAXINT = 2147483647,
	MININT = -2147483648,

//	MAXLONGLONG = 9223372036854775807,
//	MINLONGLONG = -9223372036854775807,
//  ULONGLONG_MAX   0xffffffffffffffffui64,
	};

]]


ffi.cdef[[

typedef struct tagSIZE {
  LONG cx;
  LONG cy;
} SIZE, *PSIZE, *LPSIZE;

typedef struct tagPOINT {
  int32_t x;
  int32_t y;
} POINT, *PPOINT, *LPPOINT;

typedef struct tagPOINTS
{
    SHORT   x;
    SHORT   y;
} POINTS, *PPOINTS, *LPPOINTS;

typedef struct _POINTL {
  LONG x;
  LONG y;
} POINTL, *PPOINTL;
]]

ffi.cdef[[
typedef struct tagRECT {
	int32_t left;
	int32_t top;
	int32_t right;
	int32_t bottom;
} RECT, *PRECT, *LPRECT;

typedef const RECT * LPCRECT;
]]


RECT = ffi.typeof("RECT")
RECT_mt = {
	__tostring = function(self)
		local str = string.format("%d %d %d %d", self.left, self.top, self.right, self.bottom)
		return str
	end,

	__index = {
	}
}
ffi.metatype(RECT, RECT_mt)

local exports = {
    -- Constants
    VARIANT_TRUE  = ffi.cast("VARIANT_BOOL", -1);
    VARIANT_FALSE = ffi.cast("VARIANT_BOOL", 0);

    -- Types
    POINT = ffi.typeof("POINT");
    RECT = RECT,
    SIZE = ffi.typeof("SIZE");

    -- Functions
    DECLARE_HANDLE = DECLARE_HANDLE,
}

return exports
