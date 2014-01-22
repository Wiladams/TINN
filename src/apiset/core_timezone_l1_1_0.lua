-- core_timezone_l1_1_0.lua	
-- api-ms-win-core-timezone-l1-1-0.dll	

local ffi = require("ffi");
local WTypes = require("WTypes");

local Lib = ffi.load("kernel32");

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
BOOL
FileTimeToSystemTime(
    const FILETIME *lpFileTime,
    LPSYSTEMTIME lpSystemTime
    );

DWORD
GetDynamicTimeZoneInformation(PDYNAMIC_TIME_ZONE_INFORMATION pTimeZoneInformation);

DWORD
GetTimeZoneInformation(LPTIME_ZONE_INFORMATION lpTimeZoneInformation);

BOOL
GetTimeZoneInformationForYear(
    USHORT wYear,
    PDYNAMIC_TIME_ZONE_INFORMATION pdtzi,
    LPTIME_ZONE_INFORMATION ptzi
    );

BOOL
SetDynamicTimeZoneInformation(
    const DYNAMIC_TIME_ZONE_INFORMATION *lpTimeZoneInformation
    );

BOOL
SetTimeZoneInformation(
    const TIME_ZONE_INFORMATION *lpTimeZoneInformation
    );

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


return {
    Lib = Lib,
    
	--EnumDynamicTimeZoneInformation = Lib.EnumDynamicTimeZoneInformation,
	FileTimeToSystemTime = Lib.FileTimeToSystemTime,
	GetDynamicTimeZoneInformation = Lib.GetDynamicTimeZoneInformation,
	--GetDynamicTimeZoneInformationEffectiveYears = Lib.GetDynamicTimeZoneInformationEffectiveYears,
	GetTimeZoneInformation = Lib.GetTimeZoneInformation,
	GetTimeZoneInformationForYear = Lib.GetTimeZoneInformationForYear,
	SetDynamicTimeZoneInformation = Lib.SetDynamicTimeZoneInformation,
	SetTimeZoneInformation = Lib.SetTimeZoneInformation,
	SystemTimeToFileTime = Lib.SystemTimeToFileTime,
	SystemTimeToTzSpecificLocalTime = Lib.SystemTimeToTzSpecificLocalTime,
	TzSpecificLocalTimeToSystemTime = Lib.TzSpecificLocalTimeToSystemTime,
}
