-- ObjBase.lua
local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;

local WTypes = require("WTypes")
local IUnknown = require("IUnknown")

local CLSCTX_ALL = bor(CLSCTX_INPROC_SERVER,CLSCTX_INPROC_HANDLER,CLSCTX_LOCAL_SERVER,CLSCTX_REMOTE_SERVER);

ffi.cdef[[
/* Storage instantiation modes */
static const int STGM_DIRECT             = 0x00000000L;
static const int STGM_TRANSACTED         = 0x00010000L;
static const int STGM_SIMPLE             = 0x08000000L;

static const int STGM_READ               = 0x00000000L;
static const int STGM_WRITE              = 0x00000001L;
static const int STGM_READWRITE          = 0x00000002L;

static const int STGM_SHARE_DENY_NONE    = 0x00000040L;
static const int STGM_SHARE_DENY_READ    = 0x00000030L;
static const int STGM_SHARE_DENY_WRITE   = 0x00000020L;
static const int STGM_SHARE_EXCLUSIVE    = 0x00000010L;

static const int STGM_PRIORITY           = 0x00040000L;
static const int STGM_DELETEONRELEASE    = 0x04000000L;
static const int STGM_NOSCRATCH          = 0x00100000L;

static const int STGM_CREATE             = 0x00001000L;
static const int STGM_CONVERT            = 0x00020000L;
static const int STGM_FAILIFTHERE        = 0x00000000L;

static const int STGM_NOSNAPSHOT         = 0x00200000L;
static const int STGM_DIRECT_SWMR        = 0x00400000L;

]]


ffi.cdef[[
HRESULT CoCreateInstance(REFCLSID rclsid, 
	IUnknown * pUnkOuter,
    DWORD dwClsContext, 
    REFIID riid, 
    void ** ppv);

HRESULT  CoInitialize(LPVOID pvReserved);
void  CoUninitialize(void);

]]

ffi.cdef[[
// COM initialization flags; passed to CoInitialize.
typedef enum tagCOINIT
{
  COINIT_APARTMENTTHREADED  = 0x2,      // Apartment model

  // These constants are only valid on Windows NT 4.0
  COINIT_MULTITHREADED      = 0x0,      // OLE calls objects on any thread.
  COINIT_DISABLE_OLE1DDE    = 0x4,      // Don't use DDE for Ole1 support.
  COINIT_SPEED_OVER_MEMORY  = 0x8,      // Trade memory for speed.
} COINIT;
]]


local Lib = ffi.load("Ole32")

return {
	CLSCTX_ALL = CLSCTX_ALL,

	CoCreateInstance = Lib.CoCreateInstance,
	CoInitialize = Lib.CoInitialize,
}