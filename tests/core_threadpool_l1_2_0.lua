-- api-ms-win-core-threadpool-l1-2-0.dll
-- core_threadpool_l1_2_0.lua

local ffi = require("ffi")
local Lib = ffi.load("kernel32")

local WTypes = require("WTypes")
local core_sync = require("core_synch_l1_2_0")



ffi.cdef[[
typedef DWORD TP_VERSION, *PTP_VERSION; 

typedef struct _TP_CALLBACK_INSTANCE TP_CALLBACK_INSTANCE, *PTP_CALLBACK_INSTANCE;

typedef void (__stdcall *PTP_SIMPLE_CALLBACK)(PTP_CALLBACK_INSTANCE Instance, PVOID Context);

typedef struct _TP_POOL TP_POOL, *PTP_POOL; 

typedef enum _TP_CALLBACK_PRIORITY {
    TP_CALLBACK_PRIORITY_HIGH,
    TP_CALLBACK_PRIORITY_NORMAL,
    TP_CALLBACK_PRIORITY_LOW,
    TP_CALLBACK_PRIORITY_INVALID
} TP_CALLBACK_PRIORITY;

typedef struct _TP_POOL_STACK_INFORMATION {
    SIZE_T StackReserve;
    SIZE_T StackCommit;
}TP_POOL_STACK_INFORMATION, *PTP_POOL_STACK_INFORMATION;

typedef struct _TP_CLEANUP_GROUP TP_CLEANUP_GROUP, *PTP_CLEANUP_GROUP; 

typedef void (__stdcall *PTP_CLEANUP_GROUP_CANCEL_CALLBACK)(
    PVOID ObjectContext,
    PVOID CleanupContext
    );
]]

ffi.cdef[[
typedef struct _TP_WORK TP_WORK, *PTP_WORK;

typedef void (__stdcall *PTP_WORK_CALLBACK)(
    PTP_CALLBACK_INSTANCE Instance,
    PVOID                 Context,
    PTP_WORK              Work
    );

typedef struct _TP_TIMER TP_TIMER, *PTP_TIMER;

typedef VOID (__stdcall *PTP_TIMER_CALLBACK)(
    PTP_CALLBACK_INSTANCE Instance,
    PVOID                 Context,
    PTP_TIMER             Timer
    );

typedef DWORD    TP_WAIT_RESULT;

typedef struct _TP_WAIT TP_WAIT, *PTP_WAIT;

typedef VOID (__stdcall *PTP_WAIT_CALLBACK)(
    PTP_CALLBACK_INSTANCE Instance,
    PVOID                 Context,
    PTP_WAIT              Wait,
    TP_WAIT_RESULT        WaitResult
    );

typedef struct _TP_IO TP_IO, *PTP_IO;
]]

--[[
//
// Do not manipulate this structure directly!  Allocate space for it
// and use the inline interfaces below.
//
--]]

--if (_WIN32_WINNT >= _WIN32_WINNT_WIN7) then
ffi.cdef[[
typedef struct _TP_CALLBACK_ENVIRON_V3 {
    TP_VERSION                         Version;
    PTP_POOL                           Pool;
    PTP_CLEANUP_GROUP                  CleanupGroup;
    PTP_CLEANUP_GROUP_CANCEL_CALLBACK  CleanupGroupCancelCallback;
    PVOID                              RaceDll;
    struct _ACTIVATION_CONTEXT        *ActivationContext;
    PTP_SIMPLE_CALLBACK                FinalizationCallback;
    union {
        DWORD                          Flags;
        struct {
            DWORD                      LongFunction :  1;
            DWORD                      Persistent   :  1;
            DWORD                      Private      : 30;
        } s;
    } u;    
    TP_CALLBACK_PRIORITY               CallbackPriority;
    DWORD                              Size;
} TP_CALLBACK_ENVIRON_V3;

typedef TP_CALLBACK_ENVIRON_V3 TP_CALLBACK_ENVIRON, *PTP_CALLBACK_ENVIRON;
]]
--[=[
else
ffi.cdef[[
typedef struct _TP_CALLBACK_ENVIRON_V1 {
    TP_VERSION                         Version;
    PTP_POOL                           Pool;
    PTP_CLEANUP_GROUP                  CleanupGroup;
    PTP_CLEANUP_GROUP_CANCEL_CALLBACK  CleanupGroupCancelCallback;
    PVOID                              RaceDll;
    struct _ACTIVATION_CONTEXT        *ActivationContext;
    PTP_SIMPLE_CALLBACK                FinalizationCallback;
    union {
        DWORD                          Flags;
        struct {
            DWORD                      LongFunction :  1;
            DWORD                      Persistent   :  1;
            DWORD                      Private      : 30;
        } s;
    } u;    
} TP_CALLBACK_ENVIRON_V1;

typedef TP_CALLBACK_ENVIRON_V1 TP_CALLBACK_ENVIRON, *PTP_CALLBACK_ENVIRON;
]]
end
--]=]

local TP_CALLBACK_ENVIRON = ffi.typeof("TP_CALLBACK_ENVIRON")
local TP_CALLBACK_ENVIRON_mt = {
    __new = function(ct, ...)
        --print("__new: TP_CALLBACK_ENVIRON")
        local obj = ffi.new(ct,...)

        obj.Version = 3;


        obj.Pool = nil;
        obj.CleanupGroup = nil;
        obj.CleanupGroupCancelCallback = nil;
        obj.RaceDll = nil;
        obj.ActivationContext = nil;
        obj.FinalizationCallback = nil;
        obj.u.Flags = 0;


        obj.CallbackPriority = ffi.C.TP_CALLBACK_PRIORITY_NORMAL;
        obj.Size = ffi.sizeof("TP_CALLBACK_ENVIRON");
        
        return obj;
    end,

    __gc = function(self)
        --print("GC: TP_CALLBACK_ENVIRON")
    end,
}
ffi.metatype(TP_CALLBACK_ENVIRON, TP_CALLBACK_ENVIRON_mt)


local function TpInitializeCallbackEnviron(CallbackEnviron)

--#if (_WIN32_WINNT >= _WIN32_WINNT_WIN7)

    CallbackEnviron.Version = 3;

--#else
--    CallbackEnviron->Version = 1;
--#endif

    CallbackEnviron.Pool = nil;
    CallbackEnviron.CleanupGroup = nil;
    CallbackEnviron.CleanupGroupCancelCallback = nil;
    CallbackEnviron.RaceDll = nil;
    CallbackEnviron.ActivationContext = nil;
    CallbackEnviron.FinalizationCallback = nil;
    CallbackEnviron.u.Flags = 0;

--#if (_WIN32_WINNT >= _WIN32_WINNT_WIN7)

    CallbackEnviron.CallbackPriority = ffi.C.TP_CALLBACK_PRIORITY_NORMAL;
    CallbackEnviron.Size = ffi.sizeof("TP_CALLBACK_ENVIRON");

--#endif
end





ffi.cdef[[
typedef void (__stdcall *PTP_WIN32_IO_CALLBACK)(
    PTP_CALLBACK_INSTANCE Instance,
    PVOID                 Context,
    PVOID                 Overlapped,
    ULONG                 IoResult,
    ULONG_PTR             NumberOfBytesTransferred,
    PTP_IO                Io
    );
]]



ffi.cdef[[
BOOL
CallbackMayRunLong(
    PTP_CALLBACK_INSTANCE pci
    );

VOID
CancelThreadpoolIo(
    PTP_IO pio
    );

VOID
CloseThreadpool(
    PTP_POOL ptpp
    );

VOID
CloseThreadpoolCleanupGroup(
    PTP_CLEANUP_GROUP ptpcg
    );

VOID
CloseThreadpoolCleanupGroupMembers(
        PTP_CLEANUP_GROUP ptpcg,
           BOOL              fCancelPendingCallbacks,
    PVOID             pvCleanupContext
    );

VOID
CloseThreadpoolIo(
    PTP_IO pio
    );

VOID
CloseThreadpoolTimer(
    PTP_TIMER pti
    );

VOID
CloseThreadpoolWait(
    PTP_WAIT pwa
    );

VOID
CloseThreadpoolWork(
    PTP_WORK pwk
    );

PTP_POOL
CreateThreadpool(PVOID reserved);

PTP_CLEANUP_GROUP
CreateThreadpoolCleanupGroup(void);

PTP_IO
CreateThreadpoolIo(
    HANDLE                fl,
    PTP_WIN32_IO_CALLBACK pfnio,
    PVOID                 pv,
    PTP_CALLBACK_ENVIRON  pcbe
    );

PTP_TIMER
CreateThreadpoolTimer(
    PTP_TIMER_CALLBACK   pfnti,
    PVOID                pv,
    PTP_CALLBACK_ENVIRON pcbe
    );

PTP_WAIT
CreateThreadpoolWait(
    PTP_WAIT_CALLBACK    pfnwa,
    PVOID                pv,
    PTP_CALLBACK_ENVIRON pcbe
    );

PTP_WORK
CreateThreadpoolWork(
    PTP_WORK_CALLBACK    pfnwk,
    PVOID                pv,
    PTP_CALLBACK_ENVIRON pcbe
    );


VOID
DisassociateCurrentThreadFromCallback(
    PTP_CALLBACK_INSTANCE pci
    );

VOID
FreeLibraryWhenCallbackReturns(
    PTP_CALLBACK_INSTANCE pci,
    HMODULE               mod
    );

BOOL
IsThreadpoolTimerSet(
    PTP_TIMER pti
    );

VOID
LeaveCriticalSectionWhenCallbackReturns(
    PTP_CALLBACK_INSTANCE pci,
    PCRITICAL_SECTION     pcs
    );


BOOL
QueryThreadpoolStackInformation(
    PTP_POOL           ptpp,
    PTP_POOL_STACK_INFORMATION ptpsi
    );


VOID
ReleaseMutexWhenCallbackReturns(
    PTP_CALLBACK_INSTANCE pci,
    HANDLE                mut
    );


VOID
ReleaseSemaphoreWhenCallbackReturns(
    PTP_CALLBACK_INSTANCE pci,
    HANDLE                sem,
    DWORD                 crel
    );


VOID
SetEventWhenCallbackReturns(
    PTP_CALLBACK_INSTANCE pci,
    HANDLE                evt
    );


BOOL
SetThreadpoolStackInformation(
    PTP_POOL           ptpp,
    PTP_POOL_STACK_INFORMATION ptpsi
    );


VOID
SetThreadpoolThreadMaximum(
    PTP_POOL ptpp,
    DWORD    cthrdMost
    );


BOOL
SetThreadpoolThreadMinimum(
    PTP_POOL ptpp,
    DWORD    cthrdMic
    );


VOID
SetThreadpoolTimer(
    PTP_TIMER pti,
    PFILETIME pftDueTime,
    DWORD     msPeriod,
    DWORD     msWindowLength
    );


VOID
SetThreadpoolWait(
    PTP_WAIT  pwa,
    HANDLE    h,
    PFILETIME pftTimeout
    );


VOID
StartThreadpoolIo(
    PTP_IO pio
    );


VOID
SubmitThreadpoolWork(
    PTP_WORK pwk
    );


BOOL
TrySubmitThreadpoolCallback(
    PTP_SIMPLE_CALLBACK  pfns,
    PVOID                pv,
    PTP_CALLBACK_ENVIRON pcbe
    );


VOID
WaitForThreadpoolIoCallbacks(
    PTP_IO pio,
    BOOL   fCancelPendingCallbacks
    );


VOID
WaitForThreadpoolTimerCallbacks(
    PTP_TIMER pti,
    BOOL      fCancelPendingCallbacks
    );


VOID
WaitForThreadpoolWaitCallbacks(
    PTP_WAIT pwa,
    BOOL     fCancelPendingCallbacks
    );


VOID
WaitForThreadpoolWorkCallbacks(
    PTP_WORK pwk,
    BOOL     fCancelPendingCallbacks
    );



]]



return {
  TP_CALLBACK_ENVIRON = TP_CALLBACK_ENVIRON,
  
  CallbackMayRunLong = Lib.CallbackMayRunLong,
  CancelThreadpoolIo = Lib.CancelThreadpoolIo,
  CloseThreadpool = Lib.CloseThreadpool,
  CloseThreadpoolCleanupGroup = Lib.CloseThreadpoolCleanupGroup,
  CloseThreadpoolCleanupGroupMembers = Lib.CloseThreadpoolCleanupGroupMembers,
  CloseThreadpoolIo = Lib.CloseThreadpoolIo,
  CloseThreadpoolTimer = Lib.CloseThreadpoolTimer,
  CloseThreadpoolWait = Lib.CloseThreadpoolWait,
  CloseThreadpoolWork = Lib.CloseThreadpoolWork,
  CreateThreadpool = Lib.CreateThreadpool,
  CreateThreadpoolCleanupGroup = Lib.CreateThreadpoolCleanupGroup,
  CreateThreadpoolIo = Lib.CreateThreadpoolIo,
  CreateThreadpoolTimer = Lib.CreateThreadpoolTimer,
  CreateThreadpoolWait = Lib.CreateThreadpoolWait,
  CreateThreadpoolWork = Lib.CreateThreadpoolWork,
  DisassociateCurrentThreadFromCallback = Lib.DisassociateCurrentThreadFromCallback,
  FreeLibraryWhenCallbackReturns = Lib.FreeLibraryWhenCallbackReturns,
  IsThreadpoolTimerSet = Lib.IsThreadpoolTimerSet,
  LeaveCriticalSectionWhenCallbackReturns = Lib.LeaveCriticalSectionWhenCallbackReturns,
  QueryThreadpoolStackInformation = Lib.QueryThreadpoolStackInformation,
  ReleaseMutexWhenCallbackReturns = Lib.ReleaseMutexWhenCallbackReturns,
  ReleaseSemaphoreWhenCallbackReturns = Lib.ReleaseSemaphoreWhenCallbackReturns,
  SetEventWhenCallbackReturns = Lib.SetEventWhenCallbackReturns,
  SetThreadpoolStackInformation = Lib.SetThreadpoolStackInformation,
  SetThreadpoolThreadMaximum = Lib.SetThreadpoolThreadMaximum,
  SetThreadpoolThreadMinimum = Lib.SetThreadpoolThreadMinimum,
  SetThreadpoolTimer = Lib.SetThreadpoolTimer,
  SetThreadpoolWait = Lib.SetThreadpoolWait,
  StartThreadpoolIo = Lib.StartThreadpoolIo,
  SubmitThreadpoolWork = Lib.SubmitThreadpoolWork,
  TrySubmitThreadpoolCallback = Lib.TrySubmitThreadpoolCallback,
  WaitForThreadpoolIoCallbacks = Lib.WaitForThreadpoolIoCallbacks,
  WaitForThreadpoolTimerCallbacks = Lib.WaitForThreadpoolTimerCallbacks,
  WaitForThreadpoolWaitCallbacks = Lib.WaitForThreadpoolWaitCallbacks,
  WaitForThreadpoolWorkCallbacks = Lib.WaitForThreadpoolWorkCallbacks,
}

