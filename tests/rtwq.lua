-- rtwq.lua
-- http://msdn.microsoft.com/en-us/library/windows/desktop/dn314989(v=vs.85).aspx

local ffi = require("ffi");

local WTypes = require("WTypes");
local Lib = ffi.load("RTWorkQ.dll");

ffi.cdef[[
typedef struct {
	void * ptr;	
} IUnknown ;

typedef void (__stdcall *MFPERIODICCALLBACK)(IUnknown *pContext);

typedef enum  { 
  MF_STANDARD_WORKQUEUE       = 0,
  MF_WINDOW_WORKQUEUE         = 1,
  MF_MULTITHREADED_WORKQUEUE  = 2
} MFASYNC_WORKQUEUE_TYPE;

]]

ffi.cdef[[
HRESULT RtwqAddPeriodicCallback(
  MFPERIODICCALLBACK Callback,
  IUnknown *pContext,
    DWORD *pdwKey
);

HRESULT RtwqAllocateSerialWorkQueue(
     DWORD dwWorkQueue,
    DWORD *pdwWorkQueue
);

HRESULT rtwqAllocateWorkQueueEx(
      MFASYNC_WORKQUEUE_TYPE  WorkQueueType,
    DWORD *pdwWorkQueue
);

HRESULT RtwqBeginRegisterWorkQueueWithMMCSSEx(
    DWORD dwWorkQueueId,
    LPCWSTR wszClass,
    DWORD dwTaskId,
    LONG lPriority,
    IMFAsyncCallback *pDoneCallback,
    IUnknown *pDoneState
);

HRESULT RtwqBeginUnregisterWorkQueueWithMMCSS(
    DWORD dwWorkQueueId,
    IMFAsyncCallback *pDoneCallback,
    IUnknown *pDoneState 
);


HRESULT RtwqCancelWorkItem(
    MFWORKITEM_KEY _KEY Key
);

HRESULT RtwqCreateAsyncResult(
     IUnknown *punkObject,
     IMFAsyncCallback *pCallback,
     IUnknown *punkState,
    IMFAsyncResult **ppAsyncResult
);

HRESULT RtwqEndRegisterWorkQueueWithMMCSS(
     IMFAsyncResult *pResult,
    DWORD *pdwTaskId
);

HRESULT rtwqEndUnregisterWorkQueueWithMMCSS(
    IMFAsyncResult *pResult
);

ULONG RtwqGetPlatformFlags(void);

ULONG  RtwqGetPlatformVersion(void);

HRESULT RtwqGetTimerPeriodicity(
    DWORD *Periodicity
);

HRESULT RtwqGetWorkQueueMMCSSClass(
       DWORD dwWorkQueueId,
      LPWSTR pwszClass,
  _Inout_  DWORD *pcchClass
);


HRESULT RtwqGetWorkQueueMMCSSPriority(
     DWORD dwWorkQueueId,
    LONG *plPriority 
);

HRESULT RtwqGetWorkQueueMMCSSTaskId(
     DWORD dwWorkQueueId,
    LPDWORD *pdwTaskId
);

HRESULT RtwqInvokeCallback(
  IMFAsyncResult *result
);

HRESULT RtwqJoinWorkQueue(
     DWORD dwWorkQueueId,
     HANDLE hHandle,
    HANDLE *pJoinHandle
);

HRESULT RtwqLockPlatform(void);

HRESULT RtwqLockSharedWorkQueue(
       PCWSTR wszClass,
       LONG basePriority,
  _Inout_  DWORD *pdwTaskId,
      DWORD *pID
);

HRESULT RtwqLockWorkQueue(
    DWORD dwWorkQueue
);

HRESULT RtwqPutWaitingWorkItem(
         HANDLE hEvent,
         LONG lPriority,
         IMFAsyncResult *pResult,
    MFWORKITEM_KEY *pKey
);

HRESULT RtwqPutWorkItem(
        DWORD dwQueue,
        LONG lPriority,
        IMFAsyncCallback  *pCallback,
  _In_opt_  IUnknown *pState
);

HRESULT RtwqPutWorkItemEx(
    DWORD dwQueue,
    LONG  lPriority,
    IMFAsyncResult  *pResult
);


HRESULT RtwqRegisterPlatformEvents(
    PlatformExtension *pPlatformExtension
);

HRESULT RtwqRegisterPlatformWithMMCSS(
       PCWSTR wszClass,
  _Inout_  DWORD *pdwTaskId,
       LONG lPriority
);

HRESULT RtwqRemovePeriodicCallback(
    DWORD dwKey
);

HRESULT RtwqScheduleWorkItem(
         IMFAsyncCallback *pCallback,
         IUnknown * pState,
         INT64 Timeout,
    MFWORKITEM_KEY  *pKey
);

HRESULT RtwqScheduleWorkItemEx(
         IMFAsyncResult * pResult,
         INT64 Timeout,
    MFWORKITEM_KEY * pKey
);

HRESULT RtwqShutdown(void);

HRESULT RtwqStartup(
    ULONG version,
    DWORD dwFlags
);

HRESULT RtwqUnjoinWorkQueue(
    DWORD dwWorkQueueId,
    HANDLE hJoinHandle
);

HRESULT RtwqUnlockPlatform(void);

HRESULT RtwqUnlockWorkQueue(
    DWORD dwWorkQueue
);

HRESULT RtwqUnregisterPlatformEvents(
    PlatformExtension *pPlatformExtension
);

HRESULT RtwqUnregisterPlatformFromMMCSS(void);

]]



