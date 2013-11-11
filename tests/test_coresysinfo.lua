--local ffi = require("ffi")

local core_sysinfo = require ("core_sysinfo_l1_2_0")

--[[
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
--]]

getSystemInfo = function()
	local lpSystemInfo = core_sysinfo.SYSTEM_INFO();
	core_sysinfo.GetSystemInfo(lpSystemInfo);

	print("Architecture: ", lpSystemInfo.wProcessorArchitecture);
	--print("Architecture: ", lpSystemInfo.dwOemId);
	print("PageSize: ", lpSystemInfo.dwPageSize);
	print("Minimum Address: ", lpSystemInfo.lpMinimumApplicationAddress);
	print("Maximum Address: ", lpSystemInfo.lpMaximumApplicationAddress);
	print("Processor Mask: ", lpSystemInfo.dwActiveProcessorMask);
	print("Num of Processors: ", lpSystemInfo.dwNumberOfProcessors);
	print("Processor Type: ", lpSystemInfo.dwProcessorType);
	print("Alloc Granularity: ", lpSystemInfo.dwAllocationGranularity);
	print("Processor Level: ", lpSystemInfo.wProcessorLevel);
	print("Processor Revision: ", lpSystemInfo.wProcessorRevision);
end

getSystemInfo();
