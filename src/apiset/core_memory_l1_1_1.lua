-- core-memory_l1_1_1.lua	
-- api-ms-win-core-memory-l1-1-1.dll	

local ffi = require("ffi")
local WTypes = require("WTypes");

ffi.cdef[[
typedef struct _MEMORY_BASIC_INFORMATION {
    PVOID BaseAddress;
    PVOID AllocationBase;
    DWORD AllocationProtect;
    SIZE_T RegionSize;
    DWORD State;
    DWORD Protect;
    DWORD Type;
} MEMORY_BASIC_INFORMATION, *PMEMORY_BASIC_INFORMATION;

typedef struct _MEMORY_BASIC_INFORMATION32 {
    DWORD BaseAddress;
    DWORD AllocationBase;
    DWORD AllocationProtect;
    DWORD RegionSize;
    DWORD State;
    DWORD Protect;
    DWORD Type;
} MEMORY_BASIC_INFORMATION32, *PMEMORY_BASIC_INFORMATION32;

// DECLSPEC_ALIGN(16) 
typedef struct _MEMORY_BASIC_INFORMATION64 {
    ULONGLONG BaseAddress;
    ULONGLONG AllocationBase;
    DWORD     AllocationProtect;
    DWORD     __alignment1;
    ULONGLONG RegionSize;
    DWORD     State;
    DWORD     Protect;
    DWORD     Type;
    DWORD     __alignment2;
} MEMORY_BASIC_INFORMATION64, *PMEMORY_BASIC_INFORMATION64;
]]

ffi.cdef[[
HANDLE
CreateFileMappingNumaW(
        HANDLE hFile,
    LPSECURITY_ATTRIBUTES lpFileMappingAttributes,
        DWORD flProtect,
        DWORD dwMaximumSizeHigh,
        DWORD dwMaximumSizeLow,
    LPCWSTR lpName,
        DWORD nndPreferred
    );

HANDLE
CreateFileMappingW(
        HANDLE hFile,
    LPSECURITY_ATTRIBUTES lpFileMappingAttributes,
        DWORD flProtect,
        DWORD dwMaximumSizeHigh,
        DWORD dwMaximumSizeLow,
    LPCWSTR lpName
    );

typedef enum _MEMORY_RESOURCE_NOTIFICATION_TYPE {
    LowMemoryResourceNotification,
    HighMemoryResourceNotification
} MEMORY_RESOURCE_NOTIFICATION_TYPE;


HANDLE
CreateMemoryResourceNotification(
    MEMORY_RESOURCE_NOTIFICATION_TYPE NotificationType
    );

BOOL
FlushViewOfFile(
    LPCVOID lpBaseAddress,
    SIZE_T dwNumberOfBytesToFlush
    );

SIZE_T
GetLargePageMinimum(
    void
    );

BOOL
GetProcessWorkingSetSizeEx(
     HANDLE hProcess,
    PSIZE_T lpMinimumWorkingSetSize,
    PSIZE_T lpMaximumWorkingSetSize,
    PDWORD Flags
    );

BOOL
GetSystemFileCacheSize (
    PSIZE_T lpMinimumFileCacheSize,
    PSIZE_T lpMaximumFileCacheSize,
    PDWORD lpFlags
    );

UINT
GetWriteWatch(
    DWORD dwFlags,
    PVOID lpBaseAddress,
    SIZE_T dwRegionSize,
    PVOID *lpAddresses,
    ULONG_PTR *lpdwCount,
    PULONG lpdwGranularity
    );

LPVOID
MapViewOfFile(
    HANDLE hFileMappingObject,
    DWORD dwDesiredAccess,
    DWORD dwFileOffsetHigh,
    DWORD dwFileOffsetLow,
    SIZE_T dwNumberOfBytesToMap
    );

LPVOID
MapViewOfFileEx(
        HANDLE hFileMappingObject,
        DWORD dwDesiredAccess,
        DWORD dwFileOffsetHigh,
        DWORD dwFileOffsetLow,
        SIZE_T dwNumberOfBytesToMap,
    LPVOID lpBaseAddress
    );

HANDLE
OpenFileMappingW(
    DWORD dwDesiredAccess,
    BOOL bInheritHandle,
    LPCWSTR lpName
    );

BOOL
QueryMemoryResourceNotification(
    HANDLE ResourceNotificationHandle,
    PBOOL  ResourceState
    );

BOOL
ReadProcessMemory(
    HANDLE hProcess,
    LPCVOID lpBaseAddress,
    LPVOID lpBuffer,
    SIZE_T nSize,
    SIZE_T * lpNumberOfBytesRead
    );

UINT
ResetWriteWatch(
    LPVOID lpBaseAddress,
    SIZE_T dwRegionSize
    );

BOOL
SetProcessWorkingSetSizeEx(
    HANDLE hProcess,
    SIZE_T dwMinimumWorkingSetSize,
    SIZE_T dwMaximumWorkingSetSize,
    DWORD Flags
    );

BOOL
SetSystemFileCacheSize (
    SIZE_T MinimumFileCacheSize,
    SIZE_T MaximumFileCacheSize,
    DWORD Flags
    );

BOOL
UnmapViewOfFile(
    LPCVOID lpBaseAddress
    );

LPVOID
VirtualAlloc(
    LPVOID lpAddress,
    SIZE_T dwSize,
    DWORD flAllocationType,
    DWORD flProtect
    );

LPVOID
VirtualAllocEx(
    HANDLE hProcess,
    LPVOID lpAddress,
    SIZE_T dwSize,
    DWORD flAllocationType,
    DWORD flProtect
    );

BOOL
VirtualFree(
    LPVOID lpAddress,
    SIZE_T dwSize,
    DWORD dwFreeType
    );

BOOL
VirtualFreeEx(
    HANDLE hProcess,
    LPVOID lpAddress,
    SIZE_T dwSize,
    DWORD  dwFreeType
    );

BOOL
VirtualLock(
    LPVOID lpAddress,
    SIZE_T dwSize
    );

BOOL
VirtualProtect(
    LPVOID lpAddress,
    SIZE_T dwSize,
    DWORD flNewProtect,
    PDWORD lpflOldProtect
    );

BOOL
VirtualProtectEx(
    HANDLE hProcess,
    LPVOID lpAddress,
    SIZE_T dwSize,
    DWORD flNewProtect,
    PDWORD lpflOldProtect
    );

SIZE_T
VirtualQuery(
    LPCVOID lpAddress,
    PMEMORY_BASIC_INFORMATION lpBuffer,
    SIZE_T dwLength
    );

SIZE_T
VirtualQueryEx(
    HANDLE hProcess,
    LPCVOID lpAddress,
    PMEMORY_BASIC_INFORMATION lpBuffer,
    SIZE_T dwLength
    );

BOOL
VirtualUnlock(
    LPVOID lpAddress,
    SIZE_T dwSize
    );

BOOL
WriteProcessMemory(
    HANDLE hProcess,
    LPVOID lpBaseAddress,
    LPCVOID lpBuffer,
    SIZE_T nSize,
    SIZE_T * lpNumberOfBytesWritten
    );
]]

ffi.cdef[[
static const int PAGE_NOACCESS          = 0x01;     
static const int PAGE_READONLY          = 0x02;     
static const int PAGE_READWRITE         = 0x04;     
static const int PAGE_WRITECOPY         = 0x08;     
static const int PAGE_EXECUTE           = 0x10;     
static const int PAGE_EXECUTE_READ      = 0x20;     
static const int PAGE_EXECUTE_READWRITE = 0x40;     
static const int PAGE_EXECUTE_WRITECOPY = 0x80;     
static const int PAGE_GUARD            = 0x100;     
static const int PAGE_NOCACHE          = 0x200;     
static const int PAGE_WRITECOMBINE     = 0x400;     

static const int MEM_COMMIT           = 0x1000;     
static const int MEM_RESERVE          = 0x2000;     
static const int MEM_DECOMMIT         = 0x4000;     
static const int MEM_RELEASE          = 0x8000;     
static const int MEM_FREE            = 0x10000;     
static const int MEM_PRIVATE         = 0x20000;     
static const int MEM_MAPPED          = 0x40000;     
static const int MEM_RESET           = 0x80000;     
static const int MEM_TOP_DOWN       = 0x100000;     
static const int MEM_WRITE_WATCH    = 0x200000;     
static const int MEM_PHYSICAL       = 0x400000;     
static const int MEM_ROTATE         = 0x800000;     
static const int MEM_LARGE_PAGES  = 0x20000000;     
static const int MEM_4MB_PAGES    = 0x80000000;     

static const int SEC_FILE           = 0x800000;     
static const int SEC_IMAGE         = 0x1000000;     
static const int SEC_PROTECTED_IMAGE  = 0x2000000;  
static const int SEC_RESERVE       = 0x4000000;     
static const int SEC_COMMIT        = 0x8000000;     
static const int SEC_NOCACHE      = 0x10000000;     
static const int SEC_WRITECOMBINE = 0x40000000;     
static const int SEC_LARGE_PAGES  = 0x80000000;     
static const int MEM_IMAGE        = SEC_IMAGE;     
static const int WRITE_WATCH_FLAG_RESET = 0x01;     
]]


local Lib = ffi.load("kernel32");

return {
    Lib = Lib,
    
--CreateFileMappingFromApp
CreateFileMappingNumaW = Lib.CreateFileMappingNumaW,
CreateFileMappingW = Lib.CreateFileMappingW,
CreateMemoryResourceNotification = Lib.CreateMemoryResourceNotification,
FlushViewOfFile = Lib.FlushViewOfFile,
GetLargePageMinimum = Lib.GetLargePageMinimum,
GetProcessWorkingSetSizeEx = Lib.GetProcessWorkingSetSizeEx,
GetSystemFileCacheSize = Lib.GetSystemFileCacheSize,
GetWriteWatch = Lib.GetWriteWatch,
MapViewOfFile = Lib.MapViewOfFile,
MapViewOfFileEx = Lib.MapViewOfFileEx,
--MapViewOfFileFromApp
OpenFileMappingW = Lib.OpenFileMappingW,
--PrefetchVirtualMemory
QueryMemoryResourceNotification = Lib.QueryMemoryResourceNotification,
ReadProcessMemory = Lib.ReadProcessMemory,
ResetWriteWatch = Lib.ResetWriteWatch,
SetProcessWorkingSetSizeEx = Lib.SetProcessWorkingSetSizeEx,
SetSystemFileCacheSize = Lib.SetSystemFileCacheSize,
UnmapViewOfFile = Lib.UnmapViewOfFile,
--UnmapViewOfFileEx
VirtualAlloc = Lib.VirtualAlloc,
VirtualAllocEx = Lib.VirtualAllocEx,
VirtualFree = Lib.VirtualFree,
VirtualFreeEx = Lib.VirtualFreeEx,
VirtualLock = Lib.VirtualLock,
VirtualProtect = Lib.VirtualProtect,
VirtualProtectEx = Lib.VirtualProtectEx,
VirtualQuery = Lib.VirtualQuery,
VirtualQueryEx = Lib.VirtualQueryEx,
VirtualUnlock = Lib.VirtualUnlock,
WriteProcessMemory = Lib.WriteProcessMemory,
}
