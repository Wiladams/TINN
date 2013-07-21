-- core_interlocked.lua
-- api-ms-win-core-interlocked-l1-2-0.dll	

local ffi = require("ffi");
require("WTypes");
require("WinNT");
local Lib = ffi.load("kernel32");
local Ntdll = ffi.load("Ntdll.dll");


ffi.cdef[[

//
//  Singly linked list structure. Can be used as either a list head, or
//  as link words.
//

typedef struct _SINGLE_LIST_ENTRY {
    struct _SINGLE_LIST_ENTRY *Next;
} SINGLE_LIST_ENTRY, *PSINGLE_LIST_ENTRY;

]]


if _WIN64 then
ffi.cdef[[
//
// The type SINGLE_LIST_ENTRY is not suitable for use with SLISTs.  For
// WIN64, an entry on an SLIST is required to be 16-byte aligned, while a
// SINGLE_LIST_ENTRY structure has only 8 byte alignment.
//
// Therefore, all SLIST code should use the SLIST_ENTRY type instead of the
// SINGLE_LIST_ENTRY type.
//

//#pragma warning(push)
//#pragma warning(disable:4324)   // structure padded due to align()
typedef struct DECLSPEC_ALIGN(16) _SLIST_ENTRY *PSLIST_ENTRY;
typedef struct DECLSPEC_ALIGN(16) _SLIST_ENTRY {
    PSLIST_ENTRY Next;
} SLIST_ENTRY;
//#pragma warning(pop)

typedef struct _SLIST_ENTRY32 {
    DWORD Next;
} SLIST_ENTRY32, *PSLIST_ENTRY32;
]]
else
ffi.cdef[[
typedef  SINGLE_LIST_ENTRY SLIST_ENTRY;
typedef  struct _SINGLE_LIST_ENTRY _SLIST_ENTRY;
typedef  PSINGLE_LIST_ENTRY PSLIST_ENTRY;

typedef SLIST_ENTRY SLIST_ENTRY32, *PSLIST_ENTRY32;
]]
end -- _WIN64

if _WIN64 then
ffi.cdef[[
typedef union DECLSPEC_ALIGN(16) _SLIST_HEADER {
    struct {  // original struct
        ULONGLONG Alignment;
        ULONGLONG Region;
    } DUMMYSTRUCTNAME;
    struct {  // 8-byte header
        ULONGLONG Depth:16;
        ULONGLONG Sequence:9;
        ULONGLONG NextEntry:39;
        ULONGLONG HeaderType:1; // 0: 8-byte; 1: 16-byte
        ULONGLONG Init:1;       // 0: uninitialized; 1: initialized
        ULONGLONG Reserved:59;
        ULONGLONG Region:3;
    } Header8;
    struct {  // ia64 16-byte header
        ULONGLONG Depth:16;
        ULONGLONG Sequence:48;
        ULONGLONG HeaderType:1; // 0: 8-byte; 1: 16-byte
        ULONGLONG Init:1;       // 0: uninitialized; 1: initialized
        ULONGLONG Reserved:2;
        ULONGLONG NextEntry:60; // last 4 bits are always 0's
    } Header16;
    struct {  // x64 16-byte header
        ULONGLONG Depth:16;
        ULONGLONG Sequence:48;
        ULONGLONG HeaderType:1; // 0: 8-byte; 1: 16-byte
        ULONGLONG Reserved:3;
        ULONGLONG NextEntry:60; // last 4 bits are always 0's
    } HeaderX64;
} SLIST_HEADER, *PSLIST_HEADER;

typedef union _SLIST_HEADER32{
    ULONGLONG Alignment;
    struct {
        SLIST_ENTRY32 Next;
        WORD   Depth;
        WORD   Sequence;
    } DUMMYSTRUCTNAME;
} SLIST_HEADER32, *PSLIST_HEADER32;
]]
else
ffi.cdef[[
typedef union _SLIST_HEADER {
    ULONGLONG Alignment;
    struct {
        SLIST_ENTRY Next;
        WORD   Depth;
        WORD   Sequence;
    } DUMMYSTRUCTNAME;
} SLIST_HEADER, *PSLIST_HEADER;

typedef SLIST_HEADER SLIST_HEADER32, *PSLIST_HEADER32;
]]
end -- _WIN64


ffi.cdef[[
void InitializeSListHead (PSLIST_HEADER ListHead);
]]

--[[
InterlockedCompareExchange
InterlockedCompareExchange64
InterlockedDecrement
InterlockedExchange
InterlockedExchangeAdd
--]]

ffi.cdef[[
PSLIST_ENTRY InterlockedFlushSList (PSLIST_HEADER ListHead);
]]

--InterlockedIncrement


ffi.cdef[[
PSLIST_ENTRY InterlockedPopEntrySList (PSLIST_HEADER ListHead);

PSLIST_ENTRY InterlockedPushEntrySList (PSLIST_HEADER ListHead,PSLIST_ENTRY ListEntry);
]]

ffi.cdef[[
PSLIST_ENTRY RtlFirstEntrySList(PSLIST_HEADER ListHead);
]]

--InterlockedPushListSListEx
ffi.cdef[[
USHORT QueryDepthSList (PSLIST_HEADER ListHead);
]]

return {
    InitializeSListHead = Lib.InitializeSListHead,
--InterlockedCompareExchange = Lib.InterlockedCompareExchange,
--InterlockedCompareExchange64 = Lib.InterlockedCompareExchange64,
--InterlockedDecrement = Lib.InterlockedDecrement,
--InterlockedExchange = Lib.InterlockedExchange,
--InterlockedExchangeAdd = Lib.InterlockedExchangeAdd,
    InterlockedFlushSList = Lib.InterlockedFlushSList,
--InterlockedIncrement = Lib.InterlockedIncrement,
    InterlockedPopEntrySList = Lib.InterlockedPopEntrySList,
    InterlockedPushEntrySList = Lib.InterlockedPushEntrySList,
--InterlockedPushListSListEx = Lib.InterlockedPushListSListEx,

    RtlFirstEntrySList = Ntdll.RtlFirstEntrySList,
    QueryDepthSList = Lib.QueryDepthSList,


}
