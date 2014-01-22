-- core-synch-l1-2-0.lua	
-- api-ms-win-core-synch-l1-2-0.dll	

local ffi = require("ffi");
local k32Lib = ffi.load("kernel32");
local WTypes = require("WTypes");
local WinNT = require("WinNT");
local WinBase = require("WinBase");

ffi.cdef[[
typedef struct _RTL_SRWLOCK {                            
        PVOID Ptr;                                       
} RTL_SRWLOCK, *PRTL_SRWLOCK;                            

//#define RTL_SRWLOCK_INIT {0}                            


typedef RTL_SRWLOCK SRWLOCK, *PSRWLOCK;
]]

ffi.cdef[[
typedef struct _RTL_CRITICAL_SECTION_DEBUG {
    WORD   Type;
    WORD   CreatorBackTraceIndex;
    struct _RTL_CRITICAL_SECTION *CriticalSection;
    LIST_ENTRY ProcessLocksList;
    DWORD EntryCount;
    DWORD ContentionCount;
    DWORD Flags;
    WORD   CreatorBackTraceIndexHigh;
    WORD   SpareWORD  ;
} RTL_CRITICAL_SECTION_DEBUG, *PRTL_CRITICAL_SECTION_DEBUG, RTL_RESOURCE_DEBUG, *PRTL_RESOURCE_DEBUG;

static const int RTL_CRITSECT_TYPE = 0;
static const int RTL_RESOURCE_TYPE = 1;

//
// These flags define the upper byte of the critical section SpinCount field
//
static const int RTL_CRITICAL_SECTION_FLAG_NO_DEBUG_INFO        = 0x01000000;
static const int RTL_CRITICAL_SECTION_FLAG_DYNAMIC_SPIN         = 0x02000000;
static const int RTL_CRITICAL_SECTION_FLAG_STATIC_INIT          = 0x04000000;
static const int RTL_CRITICAL_SECTION_ALL_FLAG_BITS             = 0xFF000000;
static const int RTL_CRITICAL_SECTION_FLAG_RESERVED             = (RTL_CRITICAL_SECTION_ALL_FLAG_BITS & (~(RTL_CRITICAL_SECTION_FLAG_NO_DEBUG_INFO | RTL_CRITICAL_SECTION_FLAG_DYNAMIC_SPIN | RTL_CRITICAL_SECTION_FLAG_STATIC_INIT)));

//
// These flags define possible values stored in the Flags field of a critsec debuginfo.
//
static const int RTL_CRITICAL_SECTION_DEBUG_FLAG_STATIC_INIT    = 0x00000001;

#pragma pack(push, 8)

typedef struct _RTL_CRITICAL_SECTION {
    PRTL_CRITICAL_SECTION_DEBUG DebugInfo;

    //
    //  The following three fields control entering and exiting the critical
    //  section for the resource
    //

    LONG LockCount;
    LONG RecursionCount;
    HANDLE OwningThread;        // from the thread's ClientId->UniqueThread
    HANDLE LockSemaphore;
    ULONG_PTR SpinCount;        // force size on 64-bit systems when packed
} RTL_CRITICAL_SECTION, *PRTL_CRITICAL_SECTION;

#pragma pack(pop)


typedef RTL_CRITICAL_SECTION CRITICAL_SECTION;
typedef PRTL_CRITICAL_SECTION PCRITICAL_SECTION;
typedef PRTL_CRITICAL_SECTION LPCRITICAL_SECTION;

]]

ffi.cdef[[
typedef struct _RTL_CONDITION_VARIABLE {                    
        PVOID Ptr;                                       
} RTL_CONDITION_VARIABLE, *PRTL_CONDITION_VARIABLE;      
//#define RTL_CONDITION_VARIABLE_INIT {0}                 
static const int RTL_CONDITION_VARIABLE_LOCKMODE_SHARED  = 0x1;     


typedef RTL_CONDITION_VARIABLE CONDITION_VARIABLE, *PCONDITION_VARIABLE;
]]

ffi.cdef[[
//
// Run once flags
//

static const int RTL_RUN_ONCE_CHECK_ONLY    = 0x00000001UL;
static const int RTL_RUN_ONCE_ASYNC         = 0x00000002UL;
static const int RTL_RUN_ONCE_INIT_FAILED   = 0x00000004UL;

//
// The context stored in the run once structure must leave the following number
// of low order bits unused.
//

static const int RTL_RUN_ONCE_CTX_RESERVED_BITS = 2;

typedef union _RTL_RUN_ONCE {       
    PVOID Ptr;                      
} RTL_RUN_ONCE, *PRTL_RUN_ONCE;     

typedef DWORD  (* RTL_RUN_ONCE_INIT_FN) (PRTL_RUN_ONCE RunOnce, PVOID Parameter, PVOID *Context);
typedef RTL_RUN_ONCE_INIT_FN *PRTL_RUN_ONCE_INIT_FN;

typedef RTL_RUN_ONCE INIT_ONCE;
typedef PRTL_RUN_ONCE PINIT_ONCE;
typedef PRTL_RUN_ONCE LPINIT_ONCE;
]]

ffi.cdef[[
typedef BOOL ( *PINIT_ONCE_FN) (PINIT_ONCE InitOnce, PVOID Parameter, PVOID *Context);

]]

ffi.cdef[[
typedef
void
( *PTIMERAPCROUTINE)(
    LPVOID lpArgToCompletionRoutine,
    DWORD dwTimerLowValue,
    DWORD dwTimerHighValue
    );
]]



ffi.cdef[[
void AcquireSRWLockExclusive (
     PSRWLOCK SRWLock
     );

void AcquireSRWLockShared (
     PSRWLOCK SRWLock
     );

BOOL
CancelWaitableTimer(
    HANDLE hTimer
    );

HANDLE
CreateEventA(
    LPSECURITY_ATTRIBUTES lpEventAttributes,
        BOOL bManualReset,
        BOOL bInitialState,
    LPCSTR lpName
    );

HANDLE
CreateEventExA(
    LPSECURITY_ATTRIBUTES lpEventAttributes,
    LPCSTR lpName,
        DWORD dwFlags,
        DWORD dwDesiredAccess
    );
HANDLE
CreateEventExW(
    LPSECURITY_ATTRIBUTES lpEventAttributes,
    LPCWSTR lpName,
        DWORD dwFlags,
        DWORD dwDesiredAccess
    );

HANDLE
CreateEventW(
    LPSECURITY_ATTRIBUTES lpEventAttributes,
        BOOL bManualReset,
        BOOL bInitialState,
    LPCWSTR lpName
    );

HANDLE
CreateMutexA(
    LPSECURITY_ATTRIBUTES lpMutexAttributes,
        BOOL bInitialOwner,
    LPCSTR lpName
    );

HANDLE
CreateMutexExA(
    LPSECURITY_ATTRIBUTES lpMutexAttributes,
    LPCSTR lpName,
        DWORD dwFlags,
        DWORD dwDesiredAccess
    );
HANDLE
CreateMutexExW(
    LPSECURITY_ATTRIBUTES lpMutexAttributes,
    LPCWSTR lpName,
        DWORD dwFlags,
        DWORD dwDesiredAccess
    );

HANDLE
CreateMutexW(
    LPSECURITY_ATTRIBUTES lpMutexAttributes,
        BOOL bInitialOwner,
    LPCWSTR lpName
    );

HANDLE
CreateSemaphoreExW(
       LPSECURITY_ATTRIBUTES lpSemaphoreAttributes,
           LONG lInitialCount,
           LONG lMaximumCount,
       LPCWSTR lpName,
     DWORD dwFlags,
           DWORD dwDesiredAccess
    );

HANDLE
CreateWaitableTimerExW(
    LPSECURITY_ATTRIBUTES lpTimerAttributes,
    LPCWSTR lpTimerName,
        DWORD dwFlags,
        DWORD dwDesiredAccess
    );

void DeleteCriticalSection(
    LPCRITICAL_SECTION lpCriticalSection
    );

void EnterCriticalSection(
    LPCRITICAL_SECTION lpCriticalSection
    );

void InitializeConditionVariable (
    PCONDITION_VARIABLE ConditionVariable
    );

void InitializeCriticalSection(
    LPCRITICAL_SECTION lpCriticalSection
    );


BOOL
InitializeCriticalSectionAndSpinCount(
    LPCRITICAL_SECTION lpCriticalSection,
     DWORD dwSpinCount
    );

BOOL
InitializeCriticalSectionEx(
    LPCRITICAL_SECTION lpCriticalSection,
     DWORD dwSpinCount,
     DWORD Flags
    );

void InitializeSRWLock (
     PSRWLOCK SRWLock
     );

BOOL
InitOnceBeginInitialize (
    LPINIT_ONCE lpInitOnce,
    DWORD dwFlags,
    PBOOL fPending,
    LPVOID *lpContext
    );

BOOL
InitOnceComplete (
    LPINIT_ONCE lpInitOnce,
    DWORD dwFlags,
    LPVOID lpContext
    );

BOOL
InitOnceExecuteOnce (
    PINIT_ONCE InitOnce,
    PINIT_ONCE_FN InitFn,
    PVOID Parameter,
    LPVOID *Context
    );

void InitOnceInitialize (
    PINIT_ONCE InitOnce
    );

void LeaveCriticalSection(
    LPCRITICAL_SECTION lpCriticalSection
    );

HANDLE
OpenEventA(
    DWORD dwDesiredAccess,
    BOOL bInheritHandle,
    LPCSTR lpName
    );

HANDLE
OpenEventW(
    DWORD dwDesiredAccess,
    BOOL bInheritHandle,
    LPCWSTR lpName
    );

HANDLE
OpenMutexW(
    DWORD dwDesiredAccess,
    BOOL bInheritHandle,
    LPCWSTR lpName
    );

HANDLE
OpenSemaphoreW(
    DWORD dwDesiredAccess,
    BOOL bInheritHandle,
    LPCWSTR lpName
    );

HANDLE
OpenWaitableTimerW(
    DWORD dwDesiredAccess,
    BOOL bInheritHandle,
    LPCWSTR lpTimerName
    );

BOOL
ReleaseMutex(
    HANDLE hMutex
    );

BOOL
ReleaseSemaphore(
         HANDLE hSemaphore,
         LONG lReleaseCount,
    LPLONG lpPreviousCount
    );

void ReleaseSRWLockExclusive (
     PSRWLOCK SRWLock
     );

void ReleaseSRWLockShared (
     PSRWLOCK SRWLock
     );

BOOL
ResetEvent(
    HANDLE hEvent
    );

DWORD
SetCriticalSectionSpinCount(
    LPCRITICAL_SECTION lpCriticalSection,
       DWORD dwSpinCount
    );

BOOL
SetEvent(
    HANDLE hEvent
    );

BOOL
SetWaitableTimer(
        HANDLE hTimer,
        const LARGE_INTEGER *lpDueTime,
        LONG lPeriod,
    PTIMERAPCROUTINE pfnCompletionRoutine,
    LPVOID lpArgToCompletionRoutine,
        BOOL fResume
    );

BOOL
SetWaitableTimerEx(
        HANDLE hTimer,
        const LARGE_INTEGER *lpDueTime,
        LONG lPeriod,
    PTIMERAPCROUTINE pfnCompletionRoutine,
    LPVOID lpArgToCompletionRoutine,
    PREASON_CONTEXT WakeContext,
        ULONG TolerableDelay
    );

DWORD
SignalObjectAndWait(
    HANDLE hObjectToSignal,
    HANDLE hObjectToWaitOn,
    DWORD dwMilliseconds,
    BOOL bAlertable
    );

void Sleep(
    DWORD dwMilliseconds
    );

BOOL
SleepConditionVariableCS (
    PCONDITION_VARIABLE ConditionVariable,
    PCRITICAL_SECTION CriticalSection,
    DWORD dwMilliseconds
    );

BOOL
SleepConditionVariableSRW (
    PCONDITION_VARIABLE ConditionVariable,
    PSRWLOCK SRWLock,
    DWORD dwMilliseconds,
    ULONG Flags
    );

DWORD
SleepEx(
    DWORD dwMilliseconds,
    BOOL bAlertable
    );

BOOLEAN
TryAcquireSRWLockExclusive (
    PSRWLOCK SRWLock
    );

BOOLEAN
TryAcquireSRWLockShared (
    PSRWLOCK SRWLock
    );

BOOL
TryEnterCriticalSection(
    LPCRITICAL_SECTION lpCriticalSection
    );

DWORD
WaitForMultipleObjectsEx(
    DWORD nCount,
    const HANDLE *lpHandles,
    BOOL bWaitAll,
    DWORD dwMilliseconds,
    BOOL bAlertable
    );


DWORD
WaitForSingleObject(
    HANDLE hHandle,
    DWORD dwMilliseconds
    );

DWORD
WaitForSingleObjectEx(
    HANDLE hHandle,
    DWORD dwMilliseconds,
    BOOL bAlertable
    );

void WakeAllConditionVariable (
    PCONDITION_VARIABLE ConditionVariable
    );

void WakeConditionVariable (
    PCONDITION_VARIABLE ConditionVariable
    );
]]

return {
    Lib = K32Lib,
    
AcquireSRWLockExclusive = k32Lib.AcquireSRWLockExclusive,
AcquireSRWLockShared = k32Lib.AcquireSRWLockShared,
CancelWaitableTimer = k32Lib.CancelWaitableTimer,
CreateEventA = k32Lib.CreateEventA,
CreateEventExA = k32Lib.CreateEventExA,
CreateEventExW = k32Lib.CreateEventExW,
CreateEventW = k32Lib.CreateEventW,
CreateMutexA = k32Lib.CreateMutexA,
CreateMutexExA = k32Lib.CreateMutexExA,
CreateMutexExW = k32Lib.CreateMutexExW,
CreateMutexW = k32Lib.CreateMutexW,
CreateSemaphoreExW = k32Lib.CreateSemaphoreExW,
CreateWaitableTimerExW = k32Lib.CreateWaitableTimerExW,
DeleteCriticalSection = k32Lib.DeleteCriticalSection,
--DeleteSynchronizationBarrier
EnterCriticalSection = k32Lib.EnterCriticalSection,
--EnterSynchronizationBarrier
InitializeConditionVariable = k32Lib.InitializeConditionVariable,
InitializeCriticalSection = k32Lib.InitializeCriticalSection,
InitializeCriticalSectionAndSpinCount = k32Lib.InitializeCriticalSectionAndSpinCount,
InitializeCriticalSectionEx = k32Lib.InitializeCriticalSectionEx,
InitializeSRWLock = k32Lib.InitializeSRWLock,
--InitializeSynchronizationBarrier
InitOnceBeginInitialize = k32Lib.InitOnceBeginInitialize,
InitOnceComplete = k32Lib.InitOnceComplete,
InitOnceExecuteOnce = k32Lib.InitOnceExecuteOnce,
InitOnceInitialize = k32Lib.InitOnceInitialize,
LeaveCriticalSection = k32Lib.LeaveCriticalSection,
OpenEventA = k32Lib.OpenEventA,
OpenEventW = k32Lib.OpenEventW,
OpenMutexW = k32Lib.OpenMutexW,
OpenSemaphoreW = k32Lib.OpenSemaphoreW,
OpenWaitableTimerW = k32Lib.OpenWaitableTimerW,
ReleaseMutex = k32Lib.ReleaseMutex,
ReleaseSemaphore = k32Lib.ReleaseSemaphore,
ReleaseSRWLockExclusive = k32Lib.ReleaseSRWLockExclusive,
ReleaseSRWLockShared = k32Lib.ReleaseSRWLockShared,
ResetEvent = k32Lib.ResetEvent,
SetCriticalSectionSpinCount = k32Lib.SetCriticalSectionSpinCount,
SetEvent = k32Lib.SetEvent,
SetWaitableTimer = k32Lib.SetWaitableTimer,
SetWaitableTimerEx = k32Lib.SetWaitableTimerEx,
SignalObjectAndWait = k32Lib.SignalObjectAndWait,
Sleep = k32Lib.Sleep,
SleepConditionVariableCS = k32Lib.SleepConditionVariableCS,
SleepConditionVariableSRW = k32Lib.SleepConditionVariableSRW,
SleepEx = k32Lib.SleepEx,
TryAcquireSRWLockExclusive = k32Lib.TryAcquireSRWLockExclusive,
TryAcquireSRWLockShared = k32Lib.TryAcquireSRWLockShared,
TryEnterCriticalSection = k32Lib.TryEnterCriticalSection,
WaitForMultipleObjectsEx = k32Lib.WaitForMultipleObjectsEx,
WaitForSingleObject = k32Lib.WaitForSingleObject,
WaitForSingleObjectEx = k32Lib.WaitForSingleObjectEx,
--WaitOnAddress
WakeAllConditionVariable = k32Lib.WakeAllConditionVariable,
--WakeByAddressAll
--WakeByAddressSingle
WakeConditionVariable = k32Lib.WakeConditionVariable,
}
