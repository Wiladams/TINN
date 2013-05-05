local ffi = require("ffi")

local _WIN64 = ffi.os == "Windows" and ffi.abi("64bit");
require("WTypes");




ffi.cdef[[
static const int ANYSIZE_ARRAY = 1;       
]]

ffi.cdef[[
static const int IMAGE_NUMBEROF_DIRECTORY_ENTRIES   = 16;

static const int MAX_PATH = 260;

typedef struct _IMAGE_FILE_HEADER {
    WORD    Machine;
    WORD    NumberOfSections;
    DWORD   TimeDateStamp;
    DWORD   PointerToSymbolTable;
    DWORD   NumberOfSymbols;
    WORD    SizeOfOptionalHeader;
    WORD    Characteristics;
} IMAGE_FILE_HEADER, *PIMAGE_FILE_HEADER;

typedef struct _IMAGE_DATA_DIRECTORY {
    DWORD   VirtualAddress;
    DWORD   Size;
} IMAGE_DATA_DIRECTORY, *PIMAGE_DATA_DIRECTORY;

//
// Optional header format.
//

typedef struct _IMAGE_OPTIONAL_HEADER {
    //
    // Standard fields.
    //

    WORD    Magic;
    BYTE    MajorLinkerVersion;
    BYTE    MinorLinkerVersion;
    DWORD   SizeOfCode;
    DWORD   SizeOfInitializedData;
    DWORD   SizeOfUninitializedData;
    DWORD   AddressOfEntryPoint;
    DWORD   BaseOfCode;
    DWORD   BaseOfData;

    //
    // NT additional fields.
    //

    DWORD   ImageBase;
    DWORD   SectionAlignment;
    DWORD   FileAlignment;
    WORD    MajorOperatingSystemVersion;
    WORD    MinorOperatingSystemVersion;
    WORD    MajorImageVersion;
    WORD    MinorImageVersion;
    WORD    MajorSubsystemVersion;
    WORD    MinorSubsystemVersion;
    DWORD   Win32VersionValue;
    DWORD   SizeOfImage;
    DWORD   SizeOfHeaders;
    DWORD   CheckSum;
    WORD    Subsystem;
    WORD    DllCharacteristics;
    DWORD   SizeOfStackReserve;
    DWORD   SizeOfStackCommit;
    DWORD   SizeOfHeapReserve;
    DWORD   SizeOfHeapCommit;
    DWORD   LoaderFlags;
    DWORD   NumberOfRvaAndSizes;
    IMAGE_DATA_DIRECTORY DataDirectory[IMAGE_NUMBEROF_DIRECTORY_ENTRIES];
} IMAGE_OPTIONAL_HEADER32, *PIMAGE_OPTIONAL_HEADER32;


typedef struct _IMAGE_OPTIONAL_HEADER64 {
    WORD        Magic;
    BYTE        MajorLinkerVersion;
    BYTE        MinorLinkerVersion;
    DWORD       SizeOfCode;
    DWORD       SizeOfInitializedData;
    DWORD       SizeOfUninitializedData;
    DWORD       AddressOfEntryPoint;
    DWORD       BaseOfCode;
    ULONGLONG   ImageBase;
    DWORD       SectionAlignment;
    DWORD       FileAlignment;
    WORD        MajorOperatingSystemVersion;
    WORD        MinorOperatingSystemVersion;
    WORD        MajorImageVersion;
    WORD        MinorImageVersion;
    WORD        MajorSubsystemVersion;
    WORD        MinorSubsystemVersion;
    DWORD       Win32VersionValue;
    DWORD       SizeOfImage;
    DWORD       SizeOfHeaders;
    DWORD       CheckSum;
    WORD        Subsystem;
    WORD        DllCharacteristics;
    ULONGLONG   SizeOfStackReserve;
    ULONGLONG   SizeOfStackCommit;
    ULONGLONG   SizeOfHeapReserve;
    ULONGLONG   SizeOfHeapCommit;
    DWORD       LoaderFlags;
    DWORD       NumberOfRvaAndSizes;
    IMAGE_DATA_DIRECTORY DataDirectory[IMAGE_NUMBEROF_DIRECTORY_ENTRIES];
} IMAGE_OPTIONAL_HEADER64, *PIMAGE_OPTIONAL_HEADER64;


typedef struct _IMAGE_NT_HEADERS64 {
    DWORD Signature;
    IMAGE_FILE_HEADER FileHeader;
    IMAGE_OPTIONAL_HEADER64 OptionalHeader;
} IMAGE_NT_HEADERS64, *PIMAGE_NT_HEADERS64;

typedef struct _IMAGE_NT_HEADERS {
    DWORD Signature;
    IMAGE_FILE_HEADER FileHeader;
    IMAGE_OPTIONAL_HEADER32 OptionalHeader;
} IMAGE_NT_HEADERS32, *PIMAGE_NT_HEADERS32;
]]

if _WIN64 then
ffi.cdef[[
typedef IMAGE_NT_HEADERS64                  IMAGE_NT_HEADERS;
typedef PIMAGE_NT_HEADERS64                 PIMAGE_NT_HEADERS;
]]
else
ffi.cdef[[
typedef IMAGE_NT_HEADERS32                  IMAGE_NT_HEADERS;
typedef PIMAGE_NT_HEADERS32                 PIMAGE_NT_HEADERS;
]]
end

ffi.cdef[[
//
// Section header format.
//

static const int IMAGE_SIZEOF_SHORT_NAME            =  8;

typedef struct _IMAGE_SECTION_HEADER {
    BYTE    Name[IMAGE_SIZEOF_SHORT_NAME];
    union {
            DWORD   PhysicalAddress;
            DWORD   VirtualSize;
    } Misc;
    DWORD   VirtualAddress;
    DWORD   SizeOfRawData;
    DWORD   PointerToRawData;
    DWORD   PointerToRelocations;
    DWORD   PointerToLinenumbers;
    WORD    NumberOfRelocations;
    WORD    NumberOfLinenumbers;
    DWORD   Characteristics;
} IMAGE_SECTION_HEADER, *PIMAGE_SECTION_HEADER;

]]

ffi.cdef[[
//
//  Doubly linked list structure.  Can be used as either a list head, or
//  as link words.
//

typedef struct _LIST_ENTRY {
   struct _LIST_ENTRY *Flink;
   struct _LIST_ENTRY *Blink;
} LIST_ENTRY, *PLIST_ENTRY, * PRLIST_ENTRY;
]]

ffi.cdef[[
//
// Structure to represent a system wide processor number. It contains a
// group number and relative processor number within the group.
//

typedef struct _PROCESSOR_NUMBER {
    WORD   Group;
    BYTE  Number;
    BYTE  Reserved;
} PROCESSOR_NUMBER, *PPROCESSOR_NUMBER;

//
// Structure to represent a group-specific affinity, such as that of a
// thread.  Specifies the group number and the affinity within that group.
//
typedef ULONG_PTR KAFFINITY;
typedef KAFFINITY *PKAFFINITY;

typedef struct _GROUP_AFFINITY {
    KAFFINITY Mask;
    WORD   Group;
    WORD   Reserved[3];
} GROUP_AFFINITY, *PGROUP_AFFINITY;


typedef enum _LOGICAL_PROCESSOR_RELATIONSHIP {
    RelationProcessorCore,
    RelationNumaNode,
    RelationCache,
    RelationProcessorPackage,
    RelationGroup,
    RelationAll = 0xffff
} LOGICAL_PROCESSOR_RELATIONSHIP;

static const int  LTP_PC_SMT = 0x1;

typedef enum _PROCESSOR_CACHE_TYPE {
    CacheUnified,
    CacheInstruction,
    CacheData,
    CacheTrace
} PROCESSOR_CACHE_TYPE;

static const int CACHE_FULLY_ASSOCIATIVE = 0xFF;

typedef struct _CACHE_DESCRIPTOR {
    BYTE   Level;
    BYTE   Associativity;
    WORD   LineSize;
    DWORD  Size;
    PROCESSOR_CACHE_TYPE Type;
} CACHE_DESCRIPTOR, *PCACHE_DESCRIPTOR;

typedef struct _SYSTEM_LOGICAL_PROCESSOR_INFORMATION {
    ULONG_PTR   ProcessorMask;
    LOGICAL_PROCESSOR_RELATIONSHIP Relationship;
    union {
        struct {
            BYTE  Flags;
        } ProcessorCore;
        struct {
            DWORD NodeNumber;
        } NumaNode;
        CACHE_DESCRIPTOR Cache;
        ULONGLONG  Reserved[2];
    } DUMMYUNIONNAME;
} SYSTEM_LOGICAL_PROCESSOR_INFORMATION, *PSYSTEM_LOGICAL_PROCESSOR_INFORMATION;

typedef struct _PROCESSOR_RELATIONSHIP {
    BYTE  Flags;
    BYTE  Reserved[21];
    WORD   GroupCount;
    GROUP_AFFINITY GroupMask[ANYSIZE_ARRAY];
} PROCESSOR_RELATIONSHIP, *PPROCESSOR_RELATIONSHIP;

typedef struct _NUMA_NODE_RELATIONSHIP {
    DWORD NodeNumber;
    BYTE  Reserved[20];
    GROUP_AFFINITY GroupMask;
} NUMA_NODE_RELATIONSHIP, *PNUMA_NODE_RELATIONSHIP;

typedef struct _CACHE_RELATIONSHIP {
    BYTE  Level;
    BYTE  Associativity;
    WORD   LineSize;
    DWORD CacheSize;
    PROCESSOR_CACHE_TYPE Type;
    BYTE  Reserved[20];
    GROUP_AFFINITY GroupMask;
} CACHE_RELATIONSHIP, *PCACHE_RELATIONSHIP;

typedef struct _PROCESSOR_GROUP_INFO {
    BYTE  MaximumProcessorCount;
    BYTE  ActiveProcessorCount;
    BYTE  Reserved[38];
    KAFFINITY ActiveProcessorMask;
} PROCESSOR_GROUP_INFO, *PPROCESSOR_GROUP_INFO;

typedef struct _GROUP_RELATIONSHIP {
    WORD   MaximumGroupCount;
    WORD   ActiveGroupCount;
    BYTE  Reserved[20];
    PROCESSOR_GROUP_INFO GroupInfo[ANYSIZE_ARRAY];
} GROUP_RELATIONSHIP, *PGROUP_RELATIONSHIP;

struct _SYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX {
    LOGICAL_PROCESSOR_RELATIONSHIP Relationship;
    DWORD Size;
    union {
        PROCESSOR_RELATIONSHIP Processor;
        NUMA_NODE_RELATIONSHIP NumaNode;
        CACHE_RELATIONSHIP Cache;
        GROUP_RELATIONSHIP Group;
    } DUMMYUNIONNAME;
};

typedef struct _SYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX SYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX, *PSYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX;
]]

ffi.cdef[[
//
// Define 128-bit 16-byte aligned xmm register type.
//
// DECLSPEC_ALIGN(16) 
typedef struct _M128A {
    ULONGLONG Low;
    LONGLONG High;
} M128A, *PM128A;
]]

if _WIN64 then
ffi.cdef[[
//
// Format of data for (F)XSAVE/(F)XRSTOR instruction
//
// DECLSPEC_ALIGN(16) 
typedef struct _XSAVE_FORMAT {
    WORD   ControlWord;
    WORD   StatusWord;
    BYTE  TagWord;
    BYTE  Reserved1;
    WORD   ErrorOpcode;
    DWORD ErrorOffset;
    WORD   ErrorSelector;
    WORD   Reserved2;
    DWORD DataOffset;
    WORD   DataSelector;
    WORD   Reserved3;
    DWORD MxCsr;
    DWORD MxCsr_Mask;
    M128A FloatRegisters[8];
    M128A XmmRegisters[16];
    BYTE  Reserved4[96];
} XSAVE_FORMAT, *PXSAVE_FORMAT;
]]
else
ffi.cdef[[
//DECLSPEC_ALIGN(16) 
    typedef struct _XSAVE_FORMAT {
    WORD   ControlWord;
    WORD   StatusWord;
    BYTE  TagWord;
    BYTE  Reserved1;
    WORD   ErrorOpcode;
    DWORD ErrorOffset;
    WORD   ErrorSelector;
    WORD   Reserved2;
    DWORD DataOffset;
    WORD   DataSelector;
    WORD   Reserved3;
    DWORD MxCsr;
    DWORD MxCsr_Mask;
    M128A FloatRegisters[8];
    M128A XmmRegisters[8];
    BYTE  Reserved4[192];

    //
    // The fields below are not part of XSAVE/XRSTOR format.
    // They are written by the OS which is relying on a fact that
    // neither (FX)SAVE nor (F)XSTOR used this area.
    //

    DWORD   StackControl[7];    // KERNEL_STACK_CONTROL structure actualy
    DWORD   Cr0NpxState;
} XSAVE_FORMAT, *PXSAVE_FORMAT;
]]
end

ffi.cdef[[
typedef XSAVE_FORMAT XMM_SAVE_AREA32, *PXMM_SAVE_AREA32;




// DECLSPEC_ALIGN(16) 
typedef struct _CONTEXT {

    //
    // Register parameter home addresses.
    //
    // N.B. These fields are for convience - they could be used to extend the
    //      context record in the future.
    //

    DWORD64 P1Home;
    DWORD64 P2Home;
    DWORD64 P3Home;
    DWORD64 P4Home;
    DWORD64 P5Home;
    DWORD64 P6Home;

    //
    // Control flags.
    //

    DWORD ContextFlags;
    DWORD MxCsr;

    //
    // Segment Registers and processor flags.
    //

    WORD   SegCs;
    WORD   SegDs;
    WORD   SegEs;
    WORD   SegFs;
    WORD   SegGs;
    WORD   SegSs;
    DWORD EFlags;

    //
    // Debug registers
    //

    DWORD64 Dr0;
    DWORD64 Dr1;
    DWORD64 Dr2;
    DWORD64 Dr3;
    DWORD64 Dr6;
    DWORD64 Dr7;

    //
    // Integer registers.
    //

    DWORD64 Rax;
    DWORD64 Rcx;
    DWORD64 Rdx;
    DWORD64 Rbx;
    DWORD64 Rsp;
    DWORD64 Rbp;
    DWORD64 Rsi;
    DWORD64 Rdi;
    DWORD64 R8;
    DWORD64 R9;
    DWORD64 R10;
    DWORD64 R11;
    DWORD64 R12;
    DWORD64 R13;
    DWORD64 R14;
    DWORD64 R15;

    //
    // Program counter.
    //

    DWORD64 Rip;

    //
    // Floating point state.
    //

    union {
        XMM_SAVE_AREA32 FltSave;
        struct {
            M128A Header[2];
            M128A Legacy[8];
            M128A Xmm0;
            M128A Xmm1;
            M128A Xmm2;
            M128A Xmm3;
            M128A Xmm4;
            M128A Xmm5;
            M128A Xmm6;
            M128A Xmm7;
            M128A Xmm8;
            M128A Xmm9;
            M128A Xmm10;
            M128A Xmm11;
            M128A Xmm12;
            M128A Xmm13;
            M128A Xmm14;
            M128A Xmm15;
        } DUMMYSTRUCTNAME;
    } DUMMYUNIONNAME;

    //
    // Vector registers.
    //

    M128A VectorRegister[26];
    DWORD64 VectorControl;

    //
    // Special debug control registers.
    //

    DWORD64 DebugControl;
    DWORD64 LastBranchToRip;
    DWORD64 LastBranchFromRip;
    DWORD64 LastExceptionToRip;
    DWORD64 LastExceptionFromRip;
} CONTEXT, *PCONTEXT;
]]

ffi.cdef[[
static const int EXCEPTION_NONCONTINUABLE =0x1;    // Noncontinuable exception
static const int EXCEPTION_MAXIMUM_PARAMETERS =15; // maximum number of exception parameters

//
// Exception record definition.
//

typedef struct _EXCEPTION_RECORD {
    DWORD    ExceptionCode;
    DWORD ExceptionFlags;
    struct _EXCEPTION_RECORD *ExceptionRecord;
    PVOID ExceptionAddress;
    DWORD NumberParameters;
    ULONG_PTR ExceptionInformation[EXCEPTION_MAXIMUM_PARAMETERS];
    } EXCEPTION_RECORD;

typedef EXCEPTION_RECORD *PEXCEPTION_RECORD;

typedef struct _EXCEPTION_RECORD32 {
    DWORD    ExceptionCode;
    DWORD ExceptionFlags;
    DWORD ExceptionRecord;
    DWORD ExceptionAddress;
    DWORD NumberParameters;
    DWORD ExceptionInformation[EXCEPTION_MAXIMUM_PARAMETERS];
} EXCEPTION_RECORD32, *PEXCEPTION_RECORD32;

typedef struct _EXCEPTION_RECORD64 {
    DWORD    ExceptionCode;
    DWORD ExceptionFlags;
    DWORD64 ExceptionRecord;
    DWORD64 ExceptionAddress;
    DWORD NumberParameters;
    DWORD __unusedAlignment;
    DWORD64 ExceptionInformation[EXCEPTION_MAXIMUM_PARAMETERS];
} EXCEPTION_RECORD64, *PEXCEPTION_RECORD64;

//
// Typedef for pointer returned by exception_info()
//

typedef struct _EXCEPTION_POINTERS {
    PEXCEPTION_RECORD ExceptionRecord;
    PCONTEXT ContextRecord;
} EXCEPTION_POINTERS, *PEXCEPTION_POINTERS;

typedef LONG (* PVECTORED_EXCEPTION_HANDLER)(struct _EXCEPTION_POINTERS *ExceptionInfo);

]]

ffi.cdef[[
// begin_wdm
//
//  The following are masks for the predefined standard access types
//

static const int DELETE                          = (0x00010000);
static const int READ_CONTROL                    = (0x00020000);
static const int WRITE_DAC                       = (0x00040000);
static const int WRITE_OWNER                     = (0x00080000);
static const int SYNCHRONIZE                     = (0x00100000);

static const int STANDARD_RIGHTS_REQUIRED        = 0x000F0000;

static const int STANDARD_RIGHTS_READ            = READ_CONTROL;
static const int STANDARD_RIGHTS_WRITE           = READ_CONTROL;
static const int STANDARD_RIGHTS_EXECUTE         = READ_CONTROL;

static const int STANDARD_RIGHTS_ALL             = 0x001F0000;
static const int SPECIFIC_RIGHTS_ALL             = 0x0000FFFF;


static const int PROCESS_TERMINATE                  = (0x0001);
static const int PROCESS_CREATE_THREAD              = (0x0002); 
static const int PROCESS_SET_SESSIONID              = (0x0004); 
static const int PROCESS_VM_OPERATION               = (0x0008); 
static const int PROCESS_VM_READ                    = (0x0010); 
static const int PROCESS_VM_WRITE                   = (0x0020); 
static const int PROCESS_DUP_HANDLE                 = (0x0040); 
static const int PROCESS_CREATE_PROCESS             = (0x0080); 
static const int PROCESS_SET_QUOTA                  = (0x0100); 
static const int PROCESS_SET_INFORMATION            = (0x0200); 
static const int PROCESS_QUERY_INFORMATION          = (0x0400); 
static const int PROCESS_SUSPEND_RESUME             = (0x0800); 
static const int PROCESS_QUERY_LIMITED_INFORMATION  = (0x1000); 
static const int PROCESS_ALL_ACCESS        = (STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE | 0xFFFF);
]]

ffi.cdef[[
typedef DWORD SECURITY_INFORMATION, *PSECURITY_INFORMATION;

typedef enum _SID_NAME_USE {
    SidTypeUser = 1,
    SidTypeGroup,
    SidTypeDomain,
    SidTypeAlias,
    SidTypeWellKnownGroup,
    SidTypeDeletedAccount,
    SidTypeInvalid,
    SidTypeUnknown,
    SidTypeComputer,
    SidTypeLabel
} SID_NAME_USE, *PSID_NAME_USE;

//
// Locally Unique Identifier
//

typedef struct _LUID {
    DWORD LowPart;
    LONG HighPart;
} LUID, *PLUID;
]]