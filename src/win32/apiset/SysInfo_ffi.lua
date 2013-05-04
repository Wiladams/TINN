-- SysInfo.lua

local ffi = require("ffi");
local k32Lib = ffi.load("kernel32");
require("WinNT");


if _MAC then
ffi.cdef[[
static const int MAX_COMPUTERNAME_LENGTH = 15;
]]
else
ffi.cdef[[
static const int MAX_COMPUTERNAME_LENGTH = 31;
]]
end





ffi.cdef[[
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
typedef struct _TIME_ZONE_INFORMATION {
    LONG Bias;
    WCHAR StandardName[ 32 ];
    SYSTEMTIME StandardDate;
    LONG StandardBias;
    WCHAR DaylightName[ 32 ];
    SYSTEMTIME DaylightDate;
    LONG DaylightBias;
} TIME_ZONE_INFORMATION, *PTIME_ZONE_INFORMATION, *LPTIME_ZONE_INFORMATION;

typedef struct _TIME_DYNAMIC_ZONE_INFORMATION {
    LONG Bias;
    WCHAR StandardName[ 32 ];
    SYSTEMTIME StandardDate;
    LONG StandardBias;
    WCHAR DaylightName[ 32 ];
    SYSTEMTIME DaylightDate;
    LONG DaylightBias;
    WCHAR TimeZoneKeyName[ 128 ];
    BOOLEAN DynamicDaylightTimeDisabled;
} DYNAMIC_TIME_ZONE_INFORMATION, *PDYNAMIC_TIME_ZONE_INFORMATION;
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


if UNICODE then
ffi.cdef[[
typedef OSVERSIONINFOW OSVERSIONINFO;
typedef POSVERSIONINFOW POSVERSIONINFO;
typedef LPOSVERSIONINFOW LPOSVERSIONINFO;
]]
else
ffi.cdef[[
typedef OSVERSIONINFOA OSVERSIONINFO;
typedef POSVERSIONINFOA POSVERSIONINFO;
typedef LPOSVERSIONINFOA LPOSVERSIONINFO;
]]
end -- UNICODE

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

if UNICODE then
ffi.cdef[[
typedef OSVERSIONINFOEXW OSVERSIONINFOEX;
typedef POSVERSIONINFOEXW POSVERSIONINFOEX;
typedef LPOSVERSIONINFOEXW LPOSVERSIONINFOEX;
]]
else
ffi.cdef[[
typedef OSVERSIONINFOEXA OSVERSIONINFOEX;
typedef POSVERSIONINFOEXA POSVERSIONINFOEX;
typedef LPOSVERSIONINFOEXA LPOSVERSIONINFOEX;
]]
end -- UNICODE



ffi.cdef[[
typedef struct _SYSTEM_INFO {
    union {
        DWORD dwOemId;          // Obsolete field...do not use
        struct {
            WORD wProcessorArchitecture;
            WORD wReserved;
        } DUMMYSTRUCTNAME;
    } DUMMYUNIONNAME;
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
]]

ffi.cdef[[
DWORD
GetDynamicTimeZoneInformation(
    PDYNAMIC_TIME_ZONE_INFORMATION pTimeZoneInformation
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
]]

-- "GetTickCount overflows roughly every 49 days.  
-- Code that does not take that into account can loop indefinitely.  
-- GetTickCount64 operates on 64 bit values and does not have that problem")
ffi.cdef[[
DWORD
GetTickCount(void);

ULONGLONG
GetTickCount64(void);

DWORD
GetTimeZoneInformation(
    LPTIME_ZONE_INFORMATION lpTimeZoneInformation
    );

BOOL
GetTimeZoneInformationForYear(
    USHORT wYear,
    PDYNAMIC_TIME_ZONE_INFORMATION pdtzi,
    LPTIME_ZONE_INFORMATION ptzi
    );

DWORD GetVersion (void);

BOOL GetVersionExA(LPOSVERSIONINFOA lpVersionInformation);

BOOL GetVersionExW(LPOSVERSIONINFOW lpVersionInformation);

UINT GetWindowsDirectoryA(LPSTR lpBuffer, UINT uSize);

UINT GetWindowsDirectoryW(LPWSTR lpBuffer, UINT uSize);
]]

ffi.cdef[[
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
]]

ffi.cdef[[
BOOL
SetLocalTime(const SYSTEMTIME *lpSystemTime);

BOOL
SystemTimeToFileTime(const SYSTEMTIME *lpSystemTime, LPFILETIME lpFileTime);

BOOL
SystemTimeToTzSpecificLocalTime(
    const TIME_ZONE_INFORMATION *lpTimeZoneInformation,
        const SYSTEMTIME *lpUniversalTime,
       LPSYSTEMTIME lpLocalTime);

BOOL
TzSpecificLocalTimeToSystemTime(
    const TIME_ZONE_INFORMATION *lpTimeZoneInformation,
        const SYSTEMTIME *lpLocalTime,
       LPSYSTEMTIME lpUniversalTime);
]]
