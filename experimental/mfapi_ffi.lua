local ffi = require("ffi")

local IUnknown = require("IUnknown")

ffi.cdef[[
static const int MF_SDK_VERSION = 0x0002;
static const int MF_API_VERSION = 0x0070; // This value is unused in the Win7 release and left at its Vista release value
static const int MF_VERSION = (MF_SDK_VERSION << 16 | MF_API_VERSION);

static const int MFSTARTUP_NOSOCKET = 0x1;
static const int MFSTARTUP_LITE = (MFSTARTUP_NOSOCKET);
static const int MFSTARTUP_FULL = 0;
]]

local WTypes = require("WTypes")

local Lib = ffi.load("Mfplat")

-- STDAPI == HRESULT __stdcall

ffi.cdef[[
typedef unsigned int64_t MFWORKITEM_KEY;
]]

ffi.cdef[[
HRESULT __stdcall MFStartup( ULONG Version, DWORD dwFlags );
HRESULT __stdcall MFShutdown();

STDAPI MFLockPlatform();
STDAPI MFUnlockPlatform();

STDAPI MFCancelWorkItem(MFWORKITEM_KEY Key);

]]

--[=[
ffi.cdef[[
STDAPI MFGetTimerPeriodicity(DWORD * Periodicity);

typedef void (*MFPERIODICCALLBACK)(IUnknown* pContext);

STDAPI MFAddPeriodicCallback(
            MFPERIODICCALLBACK Callback,
            IUnknown * pContext,
            __out_opt DWORD * pdwKey);

STDAPI MFRemovePeriodicCallback(
            DWORD dwKey);
]]
--]=]

ffi.cdef[[
typedef enum
{
    // MF_STANDARD_WORKQUEUE: Work queue in a thread without Window 
    // message loop.
    MF_STANDARD_WORKQUEUE = 0,

    // MF_WINDOW_WORKQUEUE: Work queue in a thread running Window 
    // Message loop that calls PeekMessage() / DispatchMessage()..
    MF_WINDOW_WORKQUEUE = 1,
}   MFASYNC_WORKQUEUE_TYPE;

STDAPI MFAllocateWorkQueueEx(
    MFASYNC_WORKQUEUE_TYPE WorkQueueType,
    DWORD * pdwWorkQueue);
]]

return {
	MFStartup = Lib.MFStartup;
	MFShutdown = Lib.MFShutdown;
}