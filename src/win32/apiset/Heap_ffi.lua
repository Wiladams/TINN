local ffi = require("ffi");
require "WTypes"


PROCESS_HEAP_REGION             =0x0001;
PROCESS_HEAP_UNCOMMITTED_RANGE  =0x0002;
PROCESS_HEAP_ENTRY_BUSY         =0x0004;
PROCESS_HEAP_ENTRY_MOVEABLE     =0x0010;
PROCESS_HEAP_ENTRY_DDESHARE     =0x0020;

HEAP_NO_SERIALIZE				= 0x00000001;
HEAP_GENERATE_EXCEPTIONS		= 0x00000004;
HEAP_ZERO_MEMORY				= 0x00000008;
HEAP_REALLOC_IN_PLACE_ONLY		= 0x00000010;
HEAP_CREATE_ENABLE_EXECUTE		= 0x00040000;

ffi.cdef[[
typedef enum _HEAP_INFORMATION_CLASS {
    HeapCompatibilityInformation,
    HeapEnableTerminationOnCorruption
} HEAP_INFORMATION_CLASS;
]]

ffi.cdef[[
typedef struct _PROCESS_HEAP_ENTRY {
    PVOID lpData;
    DWORD cbData;
    BYTE cbOverhead;
    BYTE iRegionIndex;
    WORD wFlags;
    union {
        struct {
            HANDLE hMem;
            DWORD dwReserved[ 3 ];
        } Block;
        struct {
            DWORD dwCommittedSize;
            DWORD dwUnCommittedSize;
            LPVOID lpFirstBlock;
            LPVOID lpLastBlock;
        } Region;
    } DUMMYUNIONNAME;
} PROCESS_HEAP_ENTRY, *LPPROCESS_HEAP_ENTRY, *PPROCESS_HEAP_ENTRY;
]]

PROCESS_HEAP_ENTRY = ffi.typeof("PROCESS_HEAP_ENTRY");

ffi.cdef[[
HANDLE GetProcessHeap( void );

DWORD GetProcessHeaps(DWORD NumberOfHeaps, PHANDLE ProcessHeaps);



LPVOID HeapAlloc(HANDLE hHeap, DWORD dwFlags, SIZE_T dwBytes);

SIZE_T HeapCompact(HANDLE hHeap, DWORD dwFlags);

HANDLE HeapCreate(DWORD flOptions, SIZE_T dwInitialSize, SIZE_T dwMaximumSize);

BOOL HeapDestroy(HANDLE hHeap);

BOOL HeapFree(HANDLE hHeap, DWORD dwFlags, LPVOID lpMem);

BOOL HeapLock(HANDLE hHeap);

LPVOID HeapReAlloc(HANDLE hHeap, DWORD dwFlags, LPVOID lpMem, SIZE_T dwBytes);

SIZE_T HeapSize(HANDLE hHeap, DWORD dwFlags, LPCVOID lpMem);

// HeapSummary()

BOOL HeapUnlock(HANDLE hHeap);

BOOL HeapValidate(HANDLE hHeap, DWORD dwFlags, LPCVOID lpMem);

BOOL HeapWalk(HANDLE hHeap, PROCESS_HEAP_ENTRY * lpEntry);

]]

ffi.cdef[[
BOOL HeapSetInformation (HANDLE HeapHandle,
    HEAP_INFORMATION_CLASS HeapInformationClass,
    PVOID HeapInformation,
    SIZE_T HeapInformationLength);

BOOL HeapQueryInformation (HANDLE HeapHandle,
    HEAP_INFORMATION_CLASS HeapInformationClass,
    PVOID HeapInformation,
    SIZE_T HeapInformationLength,
    PSIZE_T ReturnLength
    );
]]
