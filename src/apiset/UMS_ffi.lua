
local ffi = require("ffi");
local bit = require("bit");
require("WTypes");


-- from WinNT.h
ffi.cdef[[
static const int RTL_UMS_VERSION  = (0x0100);  

typedef enum _RTL_UMS_THREAD_INFO_CLASS {
    UmsThreadInvalidInfoClass = 0,
    UmsThreadUserContext,
    UmsThreadPriority,
    UmsThreadAffinity,
    UmsThreadTeb,
    UmsThreadIsSuspended,
    UmsThreadIsTerminated,
    UmsThreadMaxInfoClass
} RTL_UMS_THREAD_INFO_CLASS, *PRTL_UMS_THREAD_INFO_CLASS;

typedef enum _RTL_UMS_SCHEDULER_REASON {
    UmsSchedulerStartup = 0,
    UmsSchedulerThreadBlocked,
    UmsSchedulerThreadYield,
} RTL_UMS_SCHEDULER_REASON, *PRTL_UMS_SCHEDULER_REASON;

typedef void RTL_UMS_SCHEDULER_ENTRY_POINT(
    RTL_UMS_SCHEDULER_REASON Reason,
    ULONG_PTR ActivationPayload,
    PVOID SchedulerParam);

typedef RTL_UMS_SCHEDULER_ENTRY_POINT *PRTL_UMS_SCHEDULER_ENTRY_POINT;
]]


-- from WinBase.h
ffi.cdef[[
static const int UMS_VERSION = RTL_UMS_VERSION;

typedef void *PUMS_CONTEXT;

typedef void *PUMS_COMPLETION_LIST;

typedef enum _RTL_UMS_THREAD_INFO_CLASS UMS_THREAD_INFO_CLASS, *PUMS_THREAD_INFO_CLASS;

typedef enum _RTL_UMS_SCHEDULER_REASON UMS_SCHEDULER_REASON;

typedef PRTL_UMS_SCHEDULER_ENTRY_POINT PUMS_SCHEDULER_ENTRY_POINT;

typedef struct _UMS_SCHEDULER_STARTUP_INFO {

    //
    // UMS Version the application was built to. Should be set to UMS_VERSION
    //
    ULONG UmsVersion;

    //
    // Completion List to associate the new User Scheduler to.
    //
    PUMS_COMPLETION_LIST CompletionList;

    //
    // A pointer to the application-defined function that represents the starting
    // address of the Sheduler.
    //
    PUMS_SCHEDULER_ENTRY_POINT SchedulerProc;

    //
    // pointer to a variable to be passed to the scheduler uppon first activation.
    //
    PVOID SchedulerParam;

} UMS_SCHEDULER_STARTUP_INFO, *PUMS_SCHEDULER_STARTUP_INFO;

BOOL
CreateUmsCompletionList(PUMS_COMPLETION_LIST* UmsCompletionList);

BOOL
DequeueUmsCompletionListItems(PUMS_COMPLETION_LIST UmsCompletionList,
    DWORD WaitTimeOut,
    PUMS_CONTEXT* UmsThreadList
    );

BOOL
GetUmsCompletionListEvent(PUMS_COMPLETION_LIST UmsCompletionList,
    PHANDLE UmsCompletionEvent
    );

BOOL
ExecuteUmsThread(PUMS_CONTEXT UmsThread);

BOOL
UmsThreadYield(PVOID SchedulerParam);

BOOL
DeleteUmsCompletionList(PUMS_COMPLETION_LIST UmsCompletionList);

PUMS_CONTEXT
GetCurrentUmsThread(void);

PUMS_CONTEXT
GetNextUmsListItem(PUMS_CONTEXT UmsContext);

BOOL
QueryUmsThreadInformation(PUMS_CONTEXT UmsThread,
    UMS_THREAD_INFO_CLASS UmsThreadInfoClass,
    PVOID UmsThreadInformation,
    ULONG UmsThreadInformationLength,
    PULONG ReturnLength
    );

BOOL
SetUmsThreadInformation(PUMS_CONTEXT UmsThread,
    UMS_THREAD_INFO_CLASS UmsThreadInfoClass,
    PVOID UmsThreadInformation,
    ULONG UmsThreadInformationLength
    );

BOOL
DeleteUmsThreadContext(PUMS_CONTEXT UmsThread);

BOOL
CreateUmsThreadContext(PUMS_CONTEXT *lpUmsThread);

BOOL
EnterUmsSchedulingMode(PUMS_SCHEDULER_STARTUP_INFO SchedulerStartupInfo);

]]
