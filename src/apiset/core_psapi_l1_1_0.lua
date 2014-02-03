-- core_psapi_l1_1_0.lua	
-- api-ms-win-core-psapi-l1-1-0.dll	

local ffi = require("ffi");
local WTypes = require("WTypes");

ffi.cdef[[
// Structure for GetProcessMemoryInfo()

typedef struct _PROCESS_MEMORY_COUNTERS {
    DWORD cb;
    DWORD PageFaultCount;
    SIZE_T PeakWorkingSetSize;
    SIZE_T WorkingSetSize;
    SIZE_T QuotaPeakPagedPoolUsage;
    SIZE_T QuotaPagedPoolUsage;
    SIZE_T QuotaPeakNonPagedPoolUsage;
    SIZE_T QuotaNonPagedPoolUsage;
    SIZE_T PagefileUsage;
    SIZE_T PeakPagefileUsage;
} PROCESS_MEMORY_COUNTERS;
typedef PROCESS_MEMORY_COUNTERS *PPROCESS_MEMORY_COUNTERS;


typedef struct _PROCESS_MEMORY_COUNTERS_EX {
    DWORD cb;
    DWORD PageFaultCount;
    SIZE_T PeakWorkingSetSize;
    SIZE_T WorkingSetSize;
    SIZE_T QuotaPeakPagedPoolUsage;
    SIZE_T QuotaPagedPoolUsage;
    SIZE_T QuotaPeakNonPagedPoolUsage;
    SIZE_T QuotaNonPagedPoolUsage;
    SIZE_T PagefileUsage;
    SIZE_T PeakPagefileUsage;
    SIZE_T PrivateUsage;
} PROCESS_MEMORY_COUNTERS_EX;
typedef PROCESS_MEMORY_COUNTERS_EX *PPROCESS_MEMORY_COUNTERS_EX;

typedef struct _ENUM_PAGE_FILE_INFORMATION {
    DWORD cb;
    DWORD Reserved;
    SIZE_T TotalSize;
    SIZE_T TotalInUse;
    SIZE_T PeakUsage;
} ENUM_PAGE_FILE_INFORMATION, *PENUM_PAGE_FILE_INFORMATION;

typedef BOOL (*PENUM_PAGE_FILE_CALLBACKW) (LPVOID pContext, PENUM_PAGE_FILE_INFORMATION pPageFileInfo, LPCWSTR lpFilename);

typedef struct _PSAPI_WS_WATCH_INFORMATION {
    LPVOID FaultingPc;
    LPVOID FaultingVa;
} PSAPI_WS_WATCH_INFORMATION, *PPSAPI_WS_WATCH_INFORMATION;

typedef struct _PSAPI_WS_WATCH_INFORMATION_EX {
    PSAPI_WS_WATCH_INFORMATION BasicInfo;
    ULONG_PTR FaultingThreadId;
    ULONG_PTR Flags;    // Reserved
} PSAPI_WS_WATCH_INFORMATION_EX, *PPSAPI_WS_WATCH_INFORMATION_EX;

]]


ffi.cdef[[
BOOL
EmptyWorkingSet(
    HANDLE hProcess
    );

BOOL
EnumDeviceDrivers (
    LPVOID *lpImageBase,
    DWORD cb,
    LPDWORD lpcbNeeded
    );

BOOL
EnumPageFilesW (
    PENUM_PAGE_FILE_CALLBACKW pCallBackRoutine,
    LPVOID pContext
    );

BOOL
EnumProcesses (
    DWORD * lpidProcess,
    DWORD cb,
    LPDWORD lpcbNeeded
    );

DWORD
GetDeviceDriverBaseNameW (
    LPVOID ImageBase,
    LPWSTR lpBaseName,
    DWORD nSize
    );

DWORD
GetDeviceDriverFileNameW (
    LPVOID ImageBase,
    LPWSTR lpFilename,
    DWORD nSize
    );

DWORD
GetMappedFileNameW (
    HANDLE hProcess,
    LPVOID lpv,
    LPWSTR lpFilename,
    DWORD nSize
    );

typedef struct _PERFORMANCE_INFORMATION {
    DWORD cb;
    SIZE_T CommitTotal;
    SIZE_T CommitLimit;
    SIZE_T CommitPeak;
    SIZE_T PhysicalTotal;
    SIZE_T PhysicalAvailable;
    SIZE_T SystemCache;
    SIZE_T KernelTotal;
    SIZE_T KernelPaged;
    SIZE_T KernelNonpaged;
    SIZE_T PageSize;
    DWORD HandleCount;
    DWORD ProcessCount;
    DWORD ThreadCount;
} PERFORMANCE_INFORMATION, *PPERFORMANCE_INFORMATION, PERFORMACE_INFORMATION, *PPERFORMACE_INFORMATION;

BOOL
GetPerformanceInfo (
    PPERFORMANCE_INFORMATION pPerformanceInformation,
    DWORD cb
    );

DWORD
GetProcessImageFileNameW (
    HANDLE hProcess,
    LPWSTR lpImageFileName,
    DWORD nSize
    );

BOOL
GetProcessMemoryInfo(
    HANDLE Process,
    PPROCESS_MEMORY_COUNTERS ppsmemCounters,
    DWORD cb
    );

BOOL
GetWsChanges(
    HANDLE hProcess,
    PPSAPI_WS_WATCH_INFORMATION lpWatchInfo,
    DWORD cb
    );

BOOL
GetWsChangesEx(
    HANDLE hProcess,
    PPSAPI_WS_WATCH_INFORMATION_EX lpWatchInfoEx,
    PDWORD cb
    );

BOOL
InitializeProcessForWsWatch(HANDLE hProcess);

BOOL
QueryWorkingSet(
    HANDLE hProcess,
    PVOID pv,
    DWORD cb
    );

BOOL
QueryWorkingSetEx(
    HANDLE hProcess,
    PVOID pv,
    DWORD cb
    );

BOOL
QueryFullProcessImageNameW(
    HANDLE hProcess,
    DWORD dwFlags,
    LPWSTR lpExeName,
    PDWORD lpdwSize
    );
]]


local Lib = ffi.load("psapi");
local K32Lib = ffi.load("kernel32");

return {
    Lib = Lib,
    K32Lib = K32Lib,
    
	EmptyWorkingSet = Lib.EmptyWorkingSet,
	EnumDeviceDrivers = Lib.EnumDeviceDrivers,
	EnumPageFilesW = Lib.EnumPageFilesW,
	EnumProcesses = Lib.EnumProcesses,
	GetDeviceDriverBaseNameW = Lib.GetDeviceDriverBaseNameW,
	GetDeviceDriverFileNameW = Lib.GetDeviceDriverFileNameW,
	GetMappedFileNameW = Lib.GetMappedFileNameW,
	GetPerformanceInfo = Lib.GetPerformanceInfo,
	GetProcessImageFileNameW = Lib.GetProcessImageFileNameW,
	GetProcessMemoryInfo = Lib.GetProcessMemoryInfo,
	GetWsChanges = Lib.GetWsChanges,
	GetWsChangesEx = Lib.GetWsChangesEx,
	InitializeProcessForWsWatch = Lib.InitializeProcessForWsWatch,
	QueryWorkingSet = Lib.QueryWorkingSet,
	QueryWorkingSetEx = Lib.QueryWorkingSetEx,
	QueryFullProcessImageName = K32Lib.QueryFullProcessImageNameW,
}
