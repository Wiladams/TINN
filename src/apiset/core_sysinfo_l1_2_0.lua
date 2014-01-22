-- core-sysinfo-l1-2-0.lua
-- api-ms-win-core-sysinfo-l1-2-0.dll	

local ffi = require("ffi");
local k32Lib = ffi.load("kernel32");
local WinNT = require("WinNT");



ffi.cdef[[
static const int MAX_COMPUTERNAME_LENGTH = 31;


typedef enum _COMPUTER_NAME_FORMAT {
    ComputerNameNetBIOS,
    ComputerNameDnsHostname,
    ComputerNameDnsDomain,
    ComputerNameDnsFullyQualified,
    ComputerNamePhysicalNetBIOS,
    ComputerNamePhysicalDnsHostname,
    ComputerNamePhysicalDnsDomain,
    ComputerNamePhysicalDnsFullyQualified,
    ComputerNameMax
} COMPUTER_NAME_FORMAT ;
]]


ffi.cdef[[
typedef struct _SYSTEM_INFO {
    union {
        DWORD dwOemId;          // Obsolete field...do not use
        struct {
            WORD wProcessorArchitecture;
            WORD wReserved;
        } ;// DUMMYSTRUCTNAME;
    } ;// DUMMYUNIONNAME;
    DWORD dwPageSize;
    LPVOID lpMinimumApplicationAddress;
    LPVOID lpMaximumApplicationAddress;
    DWORD_PTR dwActiveProcessorMask;
    DWORD dwNumberOfProcessors;
    DWORD dwProcessorType;
    DWORD dwAllocationGranularity;
    WORD wProcessorLevel;
    WORD wProcessorRevision;
} SYSTEM_INFO, *LPSYSTEM_INFO;
]]

ffi.cdef[[
typedef struct _OSVERSIONINFOA {
    DWORD dwOSVersionInfoSize;
    DWORD dwMajorVersion;
    DWORD dwMinorVersion;
    DWORD dwBuildNumber;
    DWORD dwPlatformId;
    CHAR   szCSDVersion[ 128 ];     // Maintenance string for PSS usage
} OSVERSIONINFOA, *POSVERSIONINFOA, *LPOSVERSIONINFOA;

typedef struct _OSVERSIONINFOW {
    DWORD dwOSVersionInfoSize;
    DWORD dwMajorVersion;
    DWORD dwMinorVersion;
    DWORD dwBuildNumber;
    DWORD dwPlatformId;
    WCHAR  szCSDVersion[ 128 ];     // Maintenance string for PSS usage
} OSVERSIONINFOW, *POSVERSIONINFOW, *LPOSVERSIONINFOW, RTL_OSVERSIONINFOW, *PRTL_OSVERSIONINFOW;
]]

ffi.cdef[[
typedef struct _OSVERSIONINFOEXA {
    DWORD dwOSVersionInfoSize;
    DWORD dwMajorVersion;
    DWORD dwMinorVersion;
    DWORD dwBuildNumber;
    DWORD dwPlatformId;
    CHAR   szCSDVersion[ 128 ];     // Maintenance string for PSS usage
    WORD   wServicePackMajor;
    WORD   wServicePackMinor;
    WORD   wSuiteMask;
    BYTE  wProductType;
    BYTE  wReserved;
} OSVERSIONINFOEXA, *POSVERSIONINFOEXA, *LPOSVERSIONINFOEXA;
typedef struct _OSVERSIONINFOEXW {
    DWORD dwOSVersionInfoSize;
    DWORD dwMajorVersion;
    DWORD dwMinorVersion;
    DWORD dwBuildNumber;
    DWORD dwPlatformId;
    WCHAR  szCSDVersion[ 128 ];     // Maintenance string for PSS usage
    WORD   wServicePackMajor;
    WORD   wServicePackMinor;
    WORD   wSuiteMask;
    BYTE  wProductType;
    BYTE  wReserved;
} OSVERSIONINFOEXW, *POSVERSIONINFOEXW, *LPOSVERSIONINFOEXW, RTL_OSVERSIONINFOEXW, *PRTL_OSVERSIONINFOEXW;
]]


ffi.cdef[[
UINT
EnumSystemFirmwareTables(
     DWORD FirmwareTableProviderSignature,
    PVOID pFirmwareTableEnumBuffer,
     DWORD BufferSize
    );

BOOL
GetComputerNameExA (
    COMPUTER_NAME_FORMAT NameType,
    LPSTR lpBuffer,
    LPDWORD nSize
    );

BOOL
GetComputerNameExW (
    COMPUTER_NAME_FORMAT NameType,
    LPWSTR lpBuffer,
    LPDWORD nSize
    );

VOID
GetLocalTime(
    LPSYSTEMTIME lpSystemTime
    );

BOOL
GetLogicalProcessorInformation(
    PSYSTEM_LOGICAL_PROCESSOR_INFORMATION Buffer,
    PDWORD ReturnedLength
    );


BOOL
GetLogicalProcessorInformationEx(
    LOGICAL_PROCESSOR_RELATIONSHIP RelationshipType,
    PSYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX Buffer,
    PDWORD ReturnedLength
    );

VOID
GetNativeSystemInfo(
     LPSYSTEM_INFO lpSystemInfo
    );

BOOL
GetProductInfo(
      DWORD  dwOSMajorVersion,
      DWORD  dwOSMinorVersion,
      DWORD  dwSpMajorVersion,
      DWORD  dwSpMinorVersion,
     PDWORD pdwReturnedProductType
    );

UINT
GetSystemDirectoryA(
    LPSTR lpBuffer,
    UINT uSize
    );
UINT
GetSystemDirectoryW(
    LPWSTR lpBuffer,
    UINT uSize
    );

UINT
GetSystemFirmwareTable(
     DWORD FirmwareTableProviderSignature,
     DWORD FirmwareTableID,
    PVOID pFirmwareTableBuffer,
     DWORD BufferSize
    );

VOID
GetSystemInfo(
    LPSYSTEM_INFO lpSystemInfo
    );

VOID
GetSystemTime(
    LPSYSTEMTIME lpSystemTime
    );

BOOL
GetSystemTimeAdjustment(
    PDWORD lpTimeAdjustment,
    PDWORD lpTimeIncrement,
    PBOOL  lpTimeAdjustmentDisabled
    );

VOID
GetSystemTimeAsFileTime(
    LPFILETIME lpSystemTimeAsFileTime
    );

UINT
GetSystemWindowsDirectoryA(
    LPSTR lpBuffer,
    UINT uSize
    );
UINT
GetSystemWindowsDirectoryW(
    LPWSTR lpBuffer,
    UINT uSize
    );

DWORD
GetTickCount(void);

ULONGLONG
GetTickCount64(void);

DWORD GetVersion (void);

BOOL GetVersionExA(LPOSVERSIONINFOA lpVersionInformation);

BOOL GetVersionExW(LPOSVERSIONINFOW lpVersionInformation);

UINT GetWindowsDirectoryA(LPSTR lpBuffer, UINT uSize);

UINT GetWindowsDirectoryW(LPWSTR lpBuffer, UINT uSize);


typedef struct _MEMORYSTATUSEX {
    DWORD dwLength;
    DWORD dwMemoryLoad;
    DWORDLONG ullTotalPhys;
    DWORDLONG ullAvailPhys;
    DWORDLONG ullTotalPageFile;
    DWORDLONG ullAvailPageFile;
    DWORDLONG ullTotalVirtual;
    DWORDLONG ullAvailVirtual;
    DWORDLONG ullAvailExtendedVirtual;
} MEMORYSTATUSEX, *LPMEMORYSTATUSEX;

BOOL
GlobalMemoryStatusEx(LPMEMORYSTATUSEX lpBuffer);

BOOL
SetComputerNameExW (
    COMPUTER_NAME_FORMAT NameType,
    LPCWSTR lpBuffer
    );

BOOL
SetLocalTime(const SYSTEMTIME *lpSystemTime);

BOOL
SetSystemTime(
     const SYSTEMTIME *lpSystemTime
    );

ULONGLONG
VerSetConditionMask(
     ULONGLONG ConditionMask,
     DWORD TypeMask,
     BYTE  Condition
    );
]]


return {
    Lib = k32Lib,
    
    SYSTEM_INFO = ffi.typeof("SYSTEM_INFO");

EnumSystemFirmwareTables = k32Lib.EnumSystemFirmwareTables,
GetComputerNameExA = k32Lib.GetComputerNameExA,
GetComputerNameExW = k32Lib.GetComputerNameExW,
GetLocalTime = k32Lib.GetLocalTime,
GetLogicalProcessorInformation = k32Lib.GetLogicalProcessorInformation,
GetLogicalProcessorInformationEx = k32Lib.GetLogicalProcessorInformationEx,
GetNativeSystemInfo = k32Lib.GetNativeSystemInfo,
--GetOsSafeBootMode = k32Lib.GetOsSafeBootMode,
GetProductInfo = k32Lib.GetProductInfo,
GetSystemDirectoryA = k32Lib.GetSystemDirectoryA,
GetSystemDirectoryW = k32Lib.GetSystemDirectoryW,
GetSystemFirmwareTable = k32Lib.GetSystemFirmwareTable,
GetSystemInfo = k32Lib.GetSystemInfo,
GetSystemTime = k32Lib.GetSystemTime,
GetSystemTimeAdjustment = k32Lib.GetSystemTimeAdjustment,
GetSystemTimeAsFileTime = k32Lib.GetSystemTimeAsFileTime,
--GetSystemTimePreciseAsFileTime = k32Lib.GetSystemTimePreciseAsFileTime,
GetSystemWindowsDirectoryA = k32Lib.GetSystemWindowsDirectoryA,
GetSystemWindowsDirectoryW = k32Lib.GetSystemWindowsDirectoryW,
GetTickCount = k32Lib.GetTickCount,
GetTickCount64 = k32Lib.GetTickCount64,
GetVersion = k32Lib.GetVersion,
GetVersionExA = k32Lib.GetVersionExA,
GetVersionExW = k32Lib.GetVersionExW,
GetWindowsDirectoryA = k32Lib.GetWindowsDirectoryA,
GetWindowsDirectoryW = k32Lib.GetWindowsDirectoryW,
GlobalMemoryStatusEx = k32Lib.GlobalMemoryStatusEx,
SetComputerNameExW = k32Lib.SetComputerNameExW,
SetLocalTime = k32Lib.SetLocalTime,
SetSystemTime = k32Lib.SetSystemTime,
VerSetConditionMask = k32Lib.VerSetConditionMask,
}
