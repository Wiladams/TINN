-- ThreadPool_ffi.lua
-- API Schema Set: API-MS-Win-Core-ThreadPool-L1-1-0
-- Origin: WinBase.h
--

local ffi = require("ffi");
require("WinNT");


-- Threadpool related
ffi.cdef[[
typedef VOID (* WAITORTIMERCALLBACKFUNC) (PVOID, BOOLEAN );   

typedef DWORD TP_VERSION, *PTP_VERSION; 

typedef struct _TP_CALLBACK_INSTANCE TP_CALLBACK_INSTANCE, *PTP_CALLBACK_INSTANCE;

typedef VOID (NTAPI *PTP_SIMPLE_CALLBACK)(PTP_CALLBACK_INSTANCE Instance, PVOID Context);

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

typedef VOID (NTAPI *PTP_CLEANUP_GROUP_CANCEL_CALLBACK)(PVOID ObjectContext, PVOID CleanupContext);
]]

--[[
//
// Do not manipulate this structure directly!  Allocate space for it
// and use the inline interfaces below.
//
--]]
--if (_WIN32_WINNT >= _WIN32_WINNT_WIN7)
if (true) then
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


function TpInitializeCallbackEnviron(CallbackEnviron)

    -- if (_WIN32_WINNT >= _WIN32_WINNT_WIN7)
    if (true) then
        CallbackEnviron.Version = 3;
    else
        CallbackEnviron.Version = 1;
    end

    CallbackEnviron.Pool = nil;
    CallbackEnviron.CleanupGroup = nil;
    CallbackEnviron.CleanupGroupCancelCallback = nil;
    CallbackEnviron.RaceDll = nil;
    CallbackEnviron.ActivationContext = nil;
    CallbackEnviron.FinalizationCallback = nil;
    CallbackEnviron.u.Flags = 0;

--#if (_WIN32_WINNT >= _WIN32_WINNT_WIN7)
    if (true) then
        CallbackEnviron.CallbackPriority = ffi.C.TP_CALLBACK_PRIORITY_NORMAL;
        CallbackEnviron.Size = ffi.sizeof("TP_CALLBACK_ENVIRON");
    end

    return true;
end

function
TpSetCallbackThreadpool( CallbackEnviron,  Pool)
    CallbackEnviron.Pool = Pool;
    return true;
end

function
TpSetCallbackCleanupGroup(
                   CallbackEnviron,
                         CleanupGroup,
     CleanupGroupCancelCallback
    )

    CallbackEnviron.CleanupGroup = CleanupGroup;
    CallbackEnviron.CleanupGroupCancelCallback = CleanupGroupCancelCallback;
    return true;
end

function
TpSetCallbackActivationContext(
      CallbackEnviron,
    ActivationContext
    )

    CallbackEnviron.ActivationContext = ActivationContext;
    return true;
end

function
TpSetCallbackNoActivationContext(
     CallbackEnviron
    )

    CallbackEnviron.ActivationContext = (struct _ACTIVATION_CONTEXT *)(LONG_PTR) -1; // INVALID_ACTIVATION_CONTEXT
    return true;
end

function
TpSetCallbackLongFunction(
     CallbackEnviron
    )

    CallbackEnviron.u.s.LongFunction = 1;
    return true;
end

function
TpSetCallbackRaceWithDll(
     CallbackEnviron,
                       DllHandle
    )

    CallbackEnviron.RaceDll = DllHandle;
    return true;
end

function
TpSetCallbackFinalizationCallback(
     CallbackEnviron,
         FinalizationCallback
    )

    CallbackEnviron.FinalizationCallback = FinalizationCallback;
    return true;
end

function
TpSetCallbackPriority(
     CallbackEnviron,
        Priority
    )

    CallbackEnviron.CallbackPriority = Priority;
    return true;
end

function
TpSetCallbackPersistent(
     CallbackEnviron
    )

    CallbackEnviron.u.s.Persistent = 1;
    return true;
end


function
TpDestroyCallbackEnviron( CallbackEnviron)

--[[
    //
    // For the current version of the callback environment, no actions
    // need to be taken to tear down an initialized structure.  This
    // may change in a future release.
    //
--]]
	return true;
end


ffi.cdef[[
typedef struct _TP_WORK TP_WORK, *PTP_WORK;

typedef VOID (NTAPI *PTP_WORK_CALLBACK)(
    PTP_CALLBACK_INSTANCE Instance,
    PVOID                 Context,
    PTP_WORK              Work
    );

typedef struct _TP_TIMER TP_TIMER, *PTP_TIMER;

typedef VOID (NTAPI *PTP_TIMER_CALLBACK)(
    PTP_CALLBACK_INSTANCE Instance,
    PVOID                 Context,
    PTP_TIMER             Timer
    );

typedef DWORD    TP_WAIT_RESULT;

typedef struct _TP_WAIT TP_WAIT, *PTP_WAIT;

typedef VOID (NTAPI *PTP_WAIT_CALLBACK)(
    PTP_CALLBACK_INSTANCE Instance,
    PVOID                 Context,
    PTP_WAIT              Wait,
    TP_WAIT_RESULT        WaitResult
    );

typedef struct _TP_IO TP_IO, *PTP_IO;
]]


ffi.cdef[[
//
// Thread pool API's
//


typedef WAITORTIMERCALLBACKFUNC WAITORTIMERCALLBACK ;


BOOL
RegisterWaitForSingleObject(
    PHANDLE phNewWaitObject,
           HANDLE hObject,
           WAITORTIMERCALLBACK Callback,
       PVOID Context,
           ULONG dwMilliseconds,
           ULONG dwFlags
    );


HANDLE
RegisterWaitForSingleObjectEx(
        HANDLE hObject,
        WAITORTIMERCALLBACK Callback,
    PVOID Context,
        ULONG dwMilliseconds,
        ULONG dwFlags
    );


BOOL
UnregisterWait(
    HANDLE WaitHandle
    );


BOOL
UnregisterWaitEx(HANDLE WaitHandle, HANDLE CompletionEvent);


BOOL
QueueUserWorkItem(
    LPTHREAD_START_ROUTINE Function,
    PVOID Context,
    ULONG Flags
    );


BOOL
BindIoCompletionCallback (
    HANDLE FileHandle,
    LPOVERLAPPED_COMPLETION_ROUTINE Function,
    ULONG Flags
    );



HANDLE
CreateTimerQueue(
    void
    );


BOOL
CreateTimerQueueTimer(
    PHANDLE phNewTimer,
    HANDLE TimerQueue,
    WAITORTIMERCALLBACK Callback,
    PVOID Parameter,
    DWORD DueTime,
           DWORD Period,
           ULONG Flags
    ) ;


BOOL
ChangeTimerQueueTimer(
    HANDLE TimerQueue,
     HANDLE Timer,
        ULONG DueTime,
        ULONG Period
    );


BOOL
DeleteTimerQueueTimer(
    HANDLE TimerQueue,
        HANDLE Timer,
    HANDLE CompletionEvent
    );


BOOL
DeleteTimerQueueEx(
        HANDLE TimerQueue,
    HANDLE CompletionEvent
    );


HANDLE
SetTimerQueueTimer(
    HANDLE TimerQueue,
        WAITORTIMERCALLBACK Callback,
    PVOID Parameter,
        DWORD DueTime,
        DWORD Period,
        BOOL PreferIo
    );


BOOL
CancelTimerQueueTimer(
    HANDLE TimerQueue,
        HANDLE Timer
    );


BOOL
DeleteTimerQueue(
    HANDLE TimerQueue
    );
]]


ffi.cdef[[
typedef VOID (WINAPI *PTP_WIN32_IO_CALLBACK)(
        PTP_CALLBACK_INSTANCE Instance,
    PVOID                 Context,
    PVOID                 Overlapped,
           ULONG                 IoResult,
           ULONG_PTR             NumberOfBytesTransferred,
        PTP_IO                Io
    );


PTP_POOL
CreateThreadpool(
    PVOID reserved
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


BOOL
SetThreadpoolStackInformation(
    PTP_POOL           ptpp,
       PTP_POOL_STACK_INFORMATION ptpsi
    );


BOOL
QueryThreadpoolStackInformation(
       PTP_POOL           ptpp,
      PTP_POOL_STACK_INFORMATION ptpsi
    );


VOID
CloseThreadpool(
    PTP_POOL ptpp
    );



PTP_CLEANUP_GROUP
CreateThreadpoolCleanupGroup(void);


VOID
CloseThreadpoolCleanupGroupMembers(
    PTP_CLEANUP_GROUP ptpcg,
    BOOL              fCancelPendingCallbacks,
    PVOID             pvCleanupContext
    );


VOID
CloseThreadpoolCleanupGroup(
    PTP_CLEANUP_GROUP ptpcg
    );
]]


function InitializeThreadpoolEnvironment(pcbe)
    TpInitializeCallbackEnviron(pcbe);
end

function SetThreadpoolCallbackPool(pcbe, ptpp)
    TpSetCallbackThreadpool(pcbe, ptpp);
end

function SetThreadpoolCallbackCleanupGroup(pcbe, ptpcg, pfng)
    TpSetCallbackCleanupGroup(pcbe, ptpcg, pfng);
end

function SetThreadpoolCallbackRunsLong( pcbe)
    TpSetCallbackLongFunction(pcbe);
end

function SetThreadpoolCallbackLibrary(pcbe, mod)
    TpSetCallbackRaceWithDll(pcbe, mod);
end

function SetThreadpoolCallbackPriority(pcbe, Priority)
    TpSetCallbackPriority(pcbe, Priority);
end

function SetThreadpoolCallbackPersistent(pcbe)
    TpSetCallbackPersistent(pcbe);
end

function DestroyThreadpoolEnvironment(pcbe)
    TpDestroyCallbackEnviron(pcbe);
end


ffi.cdef[[
void
SetEventWhenCallbackReturns(
    PTP_CALLBACK_INSTANCE pci,
       HANDLE                evt
    );


void
ReleaseSemaphoreWhenCallbackReturns(
    PTP_CALLBACK_INSTANCE pci,
       HANDLE                sem,
       DWORD                 crel
    );


void
ReleaseMutexWhenCallbackReturns(
    PTP_CALLBACK_INSTANCE pci,
       HANDLE                mut
    );


void
LeaveCriticalSectionWhenCallbackReturns(
    PTP_CALLBACK_INSTANCE pci,
    PCRITICAL_SECTION     pcs
    );


void
FreeLibraryWhenCallbackReturns(
    PTP_CALLBACK_INSTANCE pci,
       HMODULE               mod
    );


BOOL
CallbackMayRunLong(
    PTP_CALLBACK_INSTANCE pci
    );


void
DisassociateCurrentThreadFromCallback(
    PTP_CALLBACK_INSTANCE pci
    );


BOOL
TrySubmitThreadpoolCallback(
           PTP_SIMPLE_CALLBACK  pfns,
    PVOID                pv,
       PTP_CALLBACK_ENVIRON pcbe
    );



PTP_WORK
CreateThreadpoolWork(
           PTP_WORK_CALLBACK    pfnwk,
    PVOID                pv,
       PTP_CALLBACK_ENVIRON pcbe
    );


void
SubmitThreadpoolWork(
    PTP_WORK pwk
    );


void
WaitForThreadpoolWorkCallbacks(
    PTP_WORK pwk,
       BOOL     fCancelPendingCallbacks
    );


void
CloseThreadpoolWork(
    PTP_WORK pwk
    );



PTP_TIMER
CreateThreadpoolTimer(
           PTP_TIMER_CALLBACK   pfnti,
    PVOID                pv,
       PTP_CALLBACK_ENVIRON pcbe
    );


void
SetThreadpoolTimer(
     PTP_TIMER pti,
    PFILETIME pftDueTime,
        DWORD     msPeriod,
    DWORD     msWindowLength
    );


BOOL
IsThreadpoolTimerSet(PTP_TIMER pti);


void
WaitForThreadpoolTimerCallbacks(
    PTP_TIMER pti,
    BOOL      fCancelPendingCallbacks
    );


void
CloseThreadpoolTimer(PTP_TIMER pti);

PTP_WAIT
CreateThreadpoolWait(
    PTP_WAIT_CALLBACK    pfnwa,
    PVOID                pv,
    PTP_CALLBACK_ENVIRON pcbe
    );


void
SetThreadpoolWait(
    PTP_WAIT  pwa,
    HANDLE    h,
    PFILETIME pftTimeout
    );


void
WaitForThreadpoolWaitCallbacks(
    PTP_WAIT pwa,
    BOOL     fCancelPendingCallbacks
    );


void
CloseThreadpoolWait(PTP_WAIT pwa);



PTP_IO
CreateThreadpoolIo(
	HANDLE                fl,
    PTP_WIN32_IO_CALLBACK pfnio,
    PVOID                 pv,
    PTP_CALLBACK_ENVIRON  pcbe
    );


void
StartThreadpoolIo(PTP_IO pio);


void
CancelThreadpoolIo(PTP_IO pio);


void
WaitForThreadpoolIoCallbacks(PTP_IO pio,
       BOOL   fCancelPendingCallbacks);


void
CloseThreadpoolIo(PTP_IO pio);
]]