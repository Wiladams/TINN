--
--
local ffi = require("ffi")

--local _WIN64 = ffi.os == "Windows" and ffi.abi("64bit");
local basetsd = require("basetsd")

require("WTypes");



MINCHAR    = 0x80;        
MAXCHAR    = 0x7f;       
MINSHORT   = 0x8000;      
MAXSHORT   = 0x7fff;      
MINLONG    = 0x80000000;  
MAXLONG    = 0x7fffffff;  
MAXBYTE    = 0xff;        
MAXWORD    = 0xffff;      
MAXDWORD   = 0xffffffff;  

ffi.cdef[[
static const int MAXIMUM_WAIT_OBJECTS = 64;
]]

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

static const int DELETE                          =  (0x00010000);
static const int READ_CONTROL                    =  (0x00020000);
static const int WRITE_DAC                       =  (0x00040000);
static const int WRITE_OWNER                     =  (0x00080000);
static const int SYNCHRONIZE                     =  (0x00100000);

static const int STANDARD_RIGHTS_REQUIRED        = 0x000F0000;

static const int STANDARD_RIGHTS_READ            = READ_CONTROL;
static const int STANDARD_RIGHTS_WRITE           = READ_CONTROL;
static const int STANDARD_RIGHTS_EXECUTE         = READ_CONTROL;

static const int STANDARD_RIGHTS_ALL             = 0x001F0000;

typedef struct {
    static const int Read = STANDARD_RIGHTS_READ;
    static const int Write = STANDARD_RIGHTS_WRITE;
    static const int Execute = STANDARD_RIGHTS_EXECUTE;
    static const int All = STANDARD_RIGHTS_ALL;
} StandardRights;

static const int SPECIFIC_RIGHTS_ALL             = 0x0000FFFF;


static const int PROCESS_TERMINATE                  =  (0x0001);
static const int PROCESS_CREATE_THREAD              =  (0x0002); 
static const int PROCESS_SET_SESSIONID              =  (0x0004); 
static const int PROCESS_VM_OPERATION               =  (0x0008); 
static const int PROCESS_VM_READ                    =  (0x0010); 
static const int PROCESS_VM_WRITE                   =  (0x0020); 
static const int PROCESS_DUP_HANDLE                 =  (0x0040); 
static const int PROCESS_CREATE_PROCESS             =  (0x0080); 
static const int PROCESS_SET_QUOTA                  =  (0x0100); 
static const int PROCESS_SET_INFORMATION            =  (0x0200); 
static const int PROCESS_QUERY_INFORMATION          =  (0x0400); 
static const int PROCESS_SUSPEND_RESUME             =  (0x0800); 
static const int PROCESS_QUERY_LIMITED_INFORMATION  =  (0x1000); 
static const int PROCESS_ALL_ACCESS        = (STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE | 0xFFFF);
]]

ffi.cdef[[
static const int SECURITY_DESCRIPTOR_REVISION    = 1;

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

ffi.cdef[[
////////////////////////////////////////////////////////////////////////
//                                                                    //
//              Security Id     (SID)                                 //
//                                                                    //
////////////////////////////////////////////////////////////////////////
//
//
// Pictorially the structure of an SID is as follows:
//
//         1   1   1   1   1   1
//         5   4   3   2   1   0   9   8   7   6   5   4   3   2   1   0
//      +---------------------------------------------------------------+
//      |      SubAuthorityCount        |Reserved1 (SBZ)|   Revision    |
//      +---------------------------------------------------------------+
//      |                   IdentifierAuthority[0]                      |
//      +---------------------------------------------------------------+
//      |                   IdentifierAuthority[1]                      |
//      +---------------------------------------------------------------+
//      |                   IdentifierAuthority[2]                      |
//      +---------------------------------------------------------------+
//      |                                                               |
//      +- -  -  -  -  -  -  -  SubAuthority[]  -  -  -  -  -  -  -  - -+
//      |                                                               |
//      +---------------------------------------------------------------+
//
//

typedef struct _SID_IDENTIFIER_AUTHORITY {
    BYTE  Value[6];
} SID_IDENTIFIER_AUTHORITY, *PSID_IDENTIFIER_AUTHORITY;
]]

ffi.cdef[[
typedef struct _SID {
   BYTE  Revision;
   BYTE  SubAuthorityCount;
   SID_IDENTIFIER_AUTHORITY IdentifierAuthority;
   DWORD SubAuthority[ANYSIZE_ARRAY];
} SID, *PISID;
]]

ffi.cdef[[
typedef struct _SID_AND_ATTRIBUTES {
    PSID Sid;
    DWORD Attributes;
} SID_AND_ATTRIBUTES, * PSID_AND_ATTRIBUTES;
]]

ffi.cdef[[
/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// Universal well-known SIDs                                               //
//                                                                         //
//     Null SID                     S-1-0-0                                //
//     World                        S-1-1-0                                //
//     Local                        S-1-2-0                                //
//     Creator Owner ID             S-1-3-0                                //
//     Creator Group ID             S-1-3-1                                //
//     Creator Owner Server ID      S-1-3-2                                //
//     Creator Group Server ID      S-1-3-3                                //
//                                                                         //
//     (Non-unique IDs)             S-1-4                                  //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////
]]

local createAuthority = function(b1, b2, b3, b4, b5, b6)
    local auth = ffi.new("SID_IDENTIFIER_AUTHORITY");
    auth.Value[0] = b1;
    auth.Value[1] = b2;
    auth.Value[2] = b3;
    auth.Value[3] = b4;
    auth.Value[4] = b5;
    auth.Value[5] = b6;
    return auth;
end

SECURITY_NULL_SID_AUTHORITY        = createAuthority(0,0,0,0,0,0);
SECURITY_WORLD_SID_AUTHORITY       = createAuthority(0,0,0,0,0,1);
SECURITY_LOCAL_SID_AUTHORITY       = createAuthority(0,0,0,0,0,2);
SECURITY_CREATOR_SID_AUTHORITY     = createAuthority(0,0,0,0,0,3);
SECURITY_NON_UNIQUE_AUTHORITY      = createAuthority(0,0,0,0,0,4);
SECURITY_RESOURCE_MANAGER_AUTHORITY= createAuthority(0,0,0,0,0,9);


ffi.cdef[[
static const int SECURITY_NULL_RID                 = (0x00000000);
static const int SECURITY_WORLD_RID                = (0x00000000);
static const int SECURITY_LOCAL_RID                = (0x00000000);
static const int SECURITY_LOCAL_LOGON_RID          = (0x00000001);

static const int SECURITY_CREATOR_OWNER_RID        = (0x00000000);
static const int SECURITY_CREATOR_GROUP_RID        = (0x00000001);

static const int SECURITY_CREATOR_OWNER_SERVER_RID = (0x00000002);
static const int SECURITY_CREATOR_GROUP_SERVER_RID = (0x00000003);

static const int SECURITY_CREATOR_OWNER_RIGHTS_RID = (0x00000004);
]]

--[[
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// NT well-known SIDs                                                        //
//                                                                           //
//     NT Authority            S-1-5                                         //
//     Dialup                  S-1-5-1                                       //
//                                                                           //
//     Network                 S-1-5-2                                       //
//     Batch                   S-1-5-3                                       //
//     Interactive             S-1-5-4                                       //
//     (Logon IDs)             S-1-5-5-X-Y                                   //
//     Service                 S-1-5-6                                       //
//     AnonymousLogon          S-1-5-7       (aka null logon session)        //
//     Proxy                   S-1-5-8                                       //
//     Enterprise DC (EDC)     S-1-5-9       (aka domain controller account) //
//     Self                    S-1-5-10      (self RID)                      //
//     Authenticated User      S-1-5-11      (Authenticated user somewhere)  //
//     Restricted Code         S-1-5-12      (Running restricted code)       //
//     Terminal Server         S-1-5-13      (Running on Terminal Server)    //
//     Remote Logon            S-1-5-14      (Remote Interactive Logon)      //
//     This Organization       S-1-5-15                                      //
//                                                                           //
//     IUser                   S-1-5-17
//     Local System            S-1-5-18                                      //
//     Local Service           S-1-5-19                                      //
//     Network Service         S-1-5-20                                      //
//                                                                           //
//     (NT non-unique IDs)     S-1-5-0x15-... (NT Domain Sids)               //
//                                                                           //
//     (Built-in domain)       S-1-5-0x20                                    //
//                                                                           //
//     (Security Package IDs)  S-1-5-0x40                                    //
//     NTLM Authentication     S-1-5-0x40-10                                 //
//     SChannel Authentication S-1-5-0x40-14                                 //
//     Digest Authentication   S-1-5-0x40-21                                 //
//                                                                           //
//     Other Organization      S-1-5-1000    (>=1000 can not be filtered)    //
//                                                                           //
//                                                                           //
// NOTE: the relative identifier values (RIDs) determine which security      //
//       boundaries the SID is allowed to cross.  Before adding new RIDs,    //
//       a determination needs to be made regarding which range they should  //
//       be added to in order to ensure proper "SID filtering"               //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
--]]

SECURITY_NT_AUTHORITY           = createAuthority(0,0,0,0,0,5);   -- ntifs

ffi.cdef[[
static const int SECURITY_DIALUP_RID             = (0x00000001);
static const int SECURITY_NETWORK_RID            = (0x00000002);
static const int SECURITY_BATCH_RID              = (0x00000003);
static const int SECURITY_INTERACTIVE_RID        = (0x00000004);
static const int SECURITY_LOGON_IDS_RID          = (0x00000005);
static const int SECURITY_LOGON_IDS_RID_COUNT    = (3);
static const int SECURITY_SERVICE_RID            = (0x00000006);
static const int SECURITY_ANONYMOUS_LOGON_RID    = (0x00000007);
static const int SECURITY_PROXY_RID              = (0x00000008);
static const int SECURITY_ENTERPRISE_CONTROLLERS_RID = (0x00000009);
static const int SECURITY_SERVER_LOGON_RID       = SECURITY_ENTERPRISE_CONTROLLERS_RID;
static const int SECURITY_PRINCIPAL_SELF_RID     = (0x0000000A);
static const int SECURITY_AUTHENTICATED_USER_RID = (0x0000000B);
static const int SECURITY_RESTRICTED_CODE_RID    = (0x0000000C);
static const int SECURITY_TERMINAL_SERVER_RID    = (0x0000000D);
static const int SECURITY_REMOTE_LOGON_RID       = (0x0000000E);
static const int SECURITY_THIS_ORGANIZATION_RID  = (0x0000000F);
static const int SECURITY_IUSER_RID              = (0x00000011);
static const int SECURITY_LOCAL_SYSTEM_RID       = (0x00000012);
static const int SECURITY_LOCAL_SERVICE_RID      = (0x00000013);
static const int SECURITY_NETWORK_SERVICE_RID    = (0x00000014);

static const int SECURITY_NT_NON_UNIQUE          = (0x00000015);
static const int SECURITY_NT_NON_UNIQUE_SUB_AUTH_COUNT  = (3);

static const int SECURITY_ENTERPRISE_READONLY_CONTROLLERS_RID = (0x00000016);

static const int SECURITY_BUILTIN_DOMAIN_RID     = (0x00000020);
static const int SECURITY_WRITE_RESTRICTED_CODE_RID = (0x00000021);


static const int SECURITY_PACKAGE_BASE_RID       = (0x00000040);
static const int SECURITY_PACKAGE_RID_COUNT      = (2);
static const int SECURITY_PACKAGE_NTLM_RID       = (0x0000000A);
static const int SECURITY_PACKAGE_SCHANNEL_RID   = (0x0000000E);
static const int SECURITY_PACKAGE_DIGEST_RID     = (0x00000015);

static const int SECURITY_CRED_TYPE_BASE_RID             = (0x00000041);
static const int SECURITY_CRED_TYPE_RID_COUNT            = (2);
static const int SECURITY_CRED_TYPE_THIS_ORG_CERT_RID    = (0x00000001);

static const int SECURITY_MIN_BASE_RID           = (0x00000050);

static const int SECURITY_SERVICE_ID_BASE_RID    = (0x00000050);
static const int SECURITY_SERVICE_ID_RID_COUNT   = (6);

static const int SECURITY_RESERVED_ID_BASE_RID   = (0x00000051);

static const int SECURITY_APPPOOL_ID_BASE_RID    = (0x00000052);
static const int SECURITY_APPPOOL_ID_RID_COUNT   = (6);

static const int SECURITY_VIRTUALSERVER_ID_BASE_RID    = (0x00000053);
static const int SECURITY_VIRTUALSERVER_ID_RID_COUNT   = (6);

static const int SECURITY_USERMODEDRIVERHOST_ID_BASE_RID  = (0x00000054);
static const int SECURITY_USERMODEDRIVERHOST_ID_RID_COUNT = (6);

static const int SECURITY_CLOUD_INFRASTRUCTURE_SERVICES_ID_BASE_RID  = (0x00000055);
static const int SECURITY_CLOUD_INFRASTRUCTURE_SERVICES_ID_RID_COUNT = (6);

static const int SECURITY_WMIHOST_ID_BASE_RID  = (0x00000056);
static const int SECURITY_WMIHOST_ID_RID_COUNT = (6);

static const int SECURITY_TASK_ID_BASE_RID                 = (0x00000057);

static const int SECURITY_NFS_ID_BASE_RID        = (0x00000058);

static const int SECURITY_COM_ID_BASE_RID        = (0x00000059);

static const int SECURITY_VIRTUALACCOUNT_ID_RID_COUNT   = (6);

static const int SECURITY_MAX_BASE_RID       = (0x0000006F);
static const int SECURITY_MAX_ALWAYS_FILTERED    = (0x000003E7);
static const int SECURITY_MIN_NEVER_FILTERED     = (0x000003E8);

static const int SECURITY_OTHER_ORGANIZATION_RID = (0x000003E8);

//
//Service SID type RIDs are in the range 0x50- 0x6F.  Therefore, we are giving  the next available RID to Windows Mobile team.
//
static const int SECURITY_WINDOWSMOBILE_ID_BASE_RID = (0x00000070);
]]


ffi.cdef[[
/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// well-known domain relative sub-authority values (RIDs)...               //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////



static const int DOMAIN_GROUP_RID_ENTERPRISE_READONLY_DOMAIN_CONTROLLERS = (0x000001F2);

static const int FOREST_USER_RID_MAX            = (0x000001F3);

// Well-known users ...

static const int DOMAIN_USER_RID_ADMIN          = (0x000001F4);
static const int DOMAIN_USER_RID_GUEST          = (0x000001F5);
static const int DOMAIN_USER_RID_KRBTGT         = (0x000001F6);

static const int DOMAIN_USER_RID_MAX            = (0x000003E7);


// well-known groups ...

static const int DOMAIN_GROUP_RID_ADMINS        = (0x00000200);
static const int DOMAIN_GROUP_RID_USERS         = (0x00000201);
static const int DOMAIN_GROUP_RID_GUESTS        = (0x00000202);
static const int DOMAIN_GROUP_RID_COMPUTERS     = (0x00000203);
static const int DOMAIN_GROUP_RID_CONTROLLERS   = (0x00000204);
static const int DOMAIN_GROUP_RID_CERT_ADMINS   = (0x00000205);
static const int DOMAIN_GROUP_RID_SCHEMA_ADMINS = (0x00000206);
static const int DOMAIN_GROUP_RID_ENTERPRISE_ADMINS = (0x00000207);
static const int DOMAIN_GROUP_RID_POLICY_ADMINS = (0x00000208);
static const int DOMAIN_GROUP_RID_READONLY_CONTROLLERS = (0x00000209);

// well-known aliases ...

static const int DOMAIN_ALIAS_RID_ADMINS                         = (0x00000220);
static const int DOMAIN_ALIAS_RID_USERS                          = (0x00000221);
static const int DOMAIN_ALIAS_RID_GUESTS                         = (0x00000222);
static const int DOMAIN_ALIAS_RID_POWER_USERS                    = (0x00000223);

static const int DOMAIN_ALIAS_RID_ACCOUNT_OPS                    = (0x00000224);
static const int DOMAIN_ALIAS_RID_SYSTEM_OPS                     = (0x00000225);
static const int DOMAIN_ALIAS_RID_PRINT_OPS                      = (0x00000226);
static const int DOMAIN_ALIAS_RID_BACKUP_OPS                     = (0x00000227);

static const int DOMAIN_ALIAS_RID_REPLICATOR                     = (0x00000228);
static const int DOMAIN_ALIAS_RID_RAS_SERVERS                    = (0x00000229);
static const int DOMAIN_ALIAS_RID_PREW2KCOMPACCESS               = (0x0000022A);
static const int DOMAIN_ALIAS_RID_REMOTE_DESKTOP_USERS           = (0x0000022B);
static const int DOMAIN_ALIAS_RID_NETWORK_CONFIGURATION_OPS      = (0x0000022C);
static const int DOMAIN_ALIAS_RID_INCOMING_FOREST_TRUST_BUILDERS = (0x0000022D);

static const int DOMAIN_ALIAS_RID_MONITORING_USERS               = (0x0000022E);
static const int DOMAIN_ALIAS_RID_LOGGING_USERS                  = (0x0000022F);
static const int DOMAIN_ALIAS_RID_AUTHORIZATIONACCESS            = (0x00000230);
static const int DOMAIN_ALIAS_RID_TS_LICENSE_SERVERS             = (0x00000231);
static const int DOMAIN_ALIAS_RID_DCOM_USERS                     = (0x00000232);
static const int DOMAIN_ALIAS_RID_IUSERS                         = (0x00000238);
static const int DOMAIN_ALIAS_RID_CRYPTO_OPERATORS               = (0x00000239);
static const int DOMAIN_ALIAS_RID_CACHEABLE_PRINCIPALS_GROUP     = (0x0000023B);
static const int DOMAIN_ALIAS_RID_NON_CACHEABLE_PRINCIPALS_GROUP = (0x0000023C);
static const int DOMAIN_ALIAS_RID_EVENT_LOG_READERS_GROUP        = (0x0000023D);
static const int DOMAIN_ALIAS_RID_CERTSVC_DCOM_ACCESS_GROUP      = (0x0000023E);
]]

SECURITY_MANDATORY_LABEL_AUTHORITY    =      createAuthority(0,0,0,0,0,16);

ffi.cdef[[
static const int SECURITY_MANDATORY_UNTRUSTED_RID            = (0x00000000);
static const int SECURITY_MANDATORY_LOW_RID                  = (0x00001000);
static const int SECURITY_MANDATORY_MEDIUM_RID               = (0x00002000);
static const int SECURITY_MANDATORY_MEDIUM_PLUS_RID          = (SECURITY_MANDATORY_MEDIUM_RID + 0x100);
static const int SECURITY_MANDATORY_HIGH_RID                 = (0x00003000);
static const int SECURITY_MANDATORY_SYSTEM_RID               = (0x00004000);
static const int SECURITY_MANDATORY_PROTECTED_PROCESS_RID    = (0x00005000);
]]

ffi.cdef[[
//
// SECURITY_MANDATORY_MAXIMUM_USER_RID is the highest RID that
// can be set by a usermode caller.
//

static const int SECURITY_MANDATORY_MAXIMUM_USER_RID  = SECURITY_MANDATORY_SYSTEM_RID;
]]

MANDATORY_LEVEL_TO_MANDATORY_RID = function(I)
    return (I * 0x1000);
end



ffi.cdef[[
typedef struct _QUOTA_LIMITS {
    SIZE_T PagedPoolLimit;
    SIZE_T NonPagedPoolLimit;
    SIZE_T MinimumWorkingSetSize;
    SIZE_T MaximumWorkingSetSize;
    SIZE_T PagefileLimit;
    LARGE_INTEGER TimeLimit;
} QUOTA_LIMITS, *PQUOTA_LIMITS;
]]

ffi.cdef[[
typedef DWORD ACCESS_MASK;
typedef ACCESS_MASK *PACCESS_MASK;
]]

ffi.cdef[[
//
//  These are the generic rights.
//

static const int GENERIC_READ                    =  (0x80000000);
static const int GENERIC_WRITE                   =  (0x40000000);
static const int GENERIC_EXECUTE                 =  (0x20000000);
static const int GENERIC_ALL                     =  (0x10000000);

typedef struct _GENERIC_MAPPING {
    ACCESS_MASK GenericRead;
    ACCESS_MASK GenericWrite;
    ACCESS_MASK GenericExecute;
    ACCESS_MASK GenericAll;
} GENERIC_MAPPING;
typedef GENERIC_MAPPING *PGENERIC_MAPPING;
]]

ffi.cdef[[
typedef struct _LUID_AND_ATTRIBUTES {
    LUID Luid;
    DWORD Attributes;
    } LUID_AND_ATTRIBUTES, * PLUID_AND_ATTRIBUTES;
typedef LUID_AND_ATTRIBUTES LUID_AND_ATTRIBUTES_ARRAY[ANYSIZE_ARRAY];
typedef LUID_AND_ATTRIBUTES_ARRAY *PLUID_AND_ATTRIBUTES_ARRAY;
]]

ffi.cdef[[
static const int SE_PRIVILEGE_ENABLED_BY_DEFAULT = (0x00000001);
static const int SE_PRIVILEGE_ENABLED            = (0x00000002);
static const int SE_PRIVILEGE_REMOVED            = (0x00000004);
static const int SE_PRIVILEGE_USED_FOR_ACCESS    = (0x80000000);

static const int SE_PRIVILEGE_VALID_ATTRIBUTES   =(SE_PRIVILEGE_ENABLED_BY_DEFAULT | \
                                         SE_PRIVILEGE_ENABLED            | \
                                         SE_PRIVILEGE_REMOVED            | \
                                         SE_PRIVILEGE_USED_FOR_ACCESS);
]]

ffi.cdef[[
typedef struct _PRIVILEGE_SET {
    DWORD PrivilegeCount;
    DWORD Control;
    LUID_AND_ATTRIBUTES Privilege[ANYSIZE_ARRAY];
    } PRIVILEGE_SET, * PPRIVILEGE_SET;
]]

ffi.cdef[[
typedef struct _OBJECT_TYPE_LIST {
    WORD   Level;
    WORD   Sbz;
    GUID *ObjectType;
} OBJECT_TYPE_LIST, *POBJECT_TYPE_LIST;
]]

ffi.cdef[[
typedef enum _AUDIT_EVENT_TYPE {
    AuditEventObjectAccess,
    AuditEventDirectoryServiceAccess
} AUDIT_EVENT_TYPE, *PAUDIT_EVENT_TYPE;
]]




ffi.cdef[[
//
// Well known SID definitions for lookup.
//

typedef enum {

    WinNullSid                                  = 0,
    WinWorldSid                                 = 1,
    WinLocalSid                                 = 2,
    WinCreatorOwnerSid                          = 3,
    WinCreatorGroupSid                          = 4,
    WinCreatorOwnerServerSid                    = 5,
    WinCreatorGroupServerSid                    = 6,
    WinNtAuthoritySid                           = 7,
    WinDialupSid                                = 8,
    WinNetworkSid                               = 9,
    WinBatchSid                                 = 10,
    WinInteractiveSid                           = 11,
    WinServiceSid                               = 12,
    WinAnonymousSid                             = 13,
    WinProxySid                                 = 14,
    WinEnterpriseControllersSid                 = 15,
    WinSelfSid                                  = 16,
    WinAuthenticatedUserSid                     = 17,
    WinRestrictedCodeSid                        = 18,
    WinTerminalServerSid                        = 19,
    WinRemoteLogonIdSid                         = 20,
    WinLogonIdsSid                              = 21,
    WinLocalSystemSid                           = 22,
    WinLocalServiceSid                          = 23,
    WinNetworkServiceSid                        = 24,
    WinBuiltinDomainSid                         = 25,
    WinBuiltinAdministratorsSid                 = 26,
    WinBuiltinUsersSid                          = 27,
    WinBuiltinGuestsSid                         = 28,
    WinBuiltinPowerUsersSid                     = 29,
    WinBuiltinAccountOperatorsSid               = 30,
    WinBuiltinSystemOperatorsSid                = 31,
    WinBuiltinPrintOperatorsSid                 = 32,
    WinBuiltinBackupOperatorsSid                = 33,
    WinBuiltinReplicatorSid                     = 34,
    WinBuiltinPreWindows2000CompatibleAccessSid = 35,
    WinBuiltinRemoteDesktopUsersSid             = 36,
    WinBuiltinNetworkConfigurationOperatorsSid  = 37,
    WinAccountAdministratorSid                  = 38,
    WinAccountGuestSid                          = 39,
    WinAccountKrbtgtSid                         = 40,
    WinAccountDomainAdminsSid                   = 41,
    WinAccountDomainUsersSid                    = 42,
    WinAccountDomainGuestsSid                   = 43,
    WinAccountComputersSid                      = 44,
    WinAccountControllersSid                    = 45,
    WinAccountCertAdminsSid                     = 46,
    WinAccountSchemaAdminsSid                   = 47,
    WinAccountEnterpriseAdminsSid               = 48,
    WinAccountPolicyAdminsSid                   = 49,
    WinAccountRasAndIasServersSid               = 50,
    WinNTLMAuthenticationSid                    = 51,
    WinDigestAuthenticationSid                  = 52,
    WinSChannelAuthenticationSid                = 53,
    WinThisOrganizationSid                      = 54,
    WinOtherOrganizationSid                     = 55,
    WinBuiltinIncomingForestTrustBuildersSid    = 56,
    WinBuiltinPerfMonitoringUsersSid            = 57,
    WinBuiltinPerfLoggingUsersSid               = 58,
    WinBuiltinAuthorizationAccessSid            = 59,
    WinBuiltinTerminalServerLicenseServersSid   = 60,
    WinBuiltinDCOMUsersSid                      = 61,
    WinBuiltinIUsersSid                         = 62,
    WinIUserSid                                 = 63,
    WinBuiltinCryptoOperatorsSid                = 64,
    WinUntrustedLabelSid                        = 65,
    WinLowLabelSid                              = 66,
    WinMediumLabelSid                           = 67,
    WinHighLabelSid                             = 68,
    WinSystemLabelSid                           = 69,
    WinWriteRestrictedCodeSid                   = 70,
    WinCreatorOwnerRightsSid                    = 71,
    WinCacheablePrincipalsGroupSid              = 72,
    WinNonCacheablePrincipalsGroupSid           = 73,
    WinEnterpriseReadonlyControllersSid         = 74,
    WinAccountReadonlyControllersSid            = 75,
    WinBuiltinEventLogReadersGroup              = 76,
    WinNewEnterpriseReadonlyControllersSid      = 77,
    WinBuiltinCertSvcDComAccessGroup            = 78,
    WinMediumPlusLabelSid                       = 79,
    WinLocalLogonSid                            = 80,
    WinConsoleLogonSid                          = 81,
    WinThisOrganizationCertificateSid           = 82,
} WELL_KNOWN_SID_TYPE;
]]


ffi.cdef[[
typedef enum _SECURITY_IMPERSONATION_LEVEL {
    SecurityAnonymous,
    SecurityIdentification,
    SecurityImpersonation,
    SecurityDelegation
    } SECURITY_IMPERSONATION_LEVEL, * PSECURITY_IMPERSONATION_LEVEL;
]]

--[[
#define SECURITY_MAX_IMPERSONATION_LEVEL SecurityDelegation
#define SECURITY_MIN_IMPERSONATION_LEVEL SecurityAnonymous
#define DEFAULT_IMPERSONATION_LEVEL SecurityImpersonation
#define VALID_IMPERSONATION_LEVEL(L) (((L) >= SECURITY_MIN_IMPERSONATION_LEVEL) && ((L) <= SECURITY_MAX_IMPERSONATION_LEVEL))
--]]


ffi.cdef[[
typedef enum _ACL_INFORMATION_CLASS {
    AclRevisionInformation = 1,
    AclSizeInformation
} ACL_INFORMATION_CLASS;

//
//  This record is returned/sent if the user is requesting/setting the
//  AclRevisionInformation
//

typedef struct _ACL_REVISION_INFORMATION {
    DWORD AclRevision;
} ACL_REVISION_INFORMATION;
typedef ACL_REVISION_INFORMATION *PACL_REVISION_INFORMATION;

//
//  This record is returned if the user is requesting AclSizeInformation
//

typedef struct _ACL_SIZE_INFORMATION {
    DWORD AceCount;
    DWORD AclBytesInUse;
    DWORD AclBytesFree;
} ACL_SIZE_INFORMATION;
typedef ACL_SIZE_INFORMATION *PACL_SIZE_INFORMATION;

]]

ffi.cdef[[
static const int ACL_REVISION     = 2;
static const int ACL_REVISION_DS  = 4;

// This is the history of ACL revisions.  Add a new one whenever
// ACL_REVISION is updated

static const int ACL_REVISION1   = 1;
static const int ACL_REVISION2   = 2;
static const int ACL_REVISION3   = 3;
static const int ACL_REVISION4   = 4;
static const int MIN_ACL_REVISION = ACL_REVISION2;
static const int MAX_ACL_REVISION = ACL_REVISION4;
]]

ffi.cdef[[
typedef struct _ACL
{
    UCHAR AclRevision;
    UCHAR Sbz1;
    USHORT AclSize;
    USHORT AceCount;
    USHORT Sbz2;
}   ACL, *PACL;
]]

ffi.cdef[[
//
//  The structure of an ACE is a common ace header followed by ace type
//  specific data.  Pictorally the structure of the common ace header is
//  as follows:
//
//       3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
//       1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
//      +---------------+-------+-------+---------------+---------------+
//      |            AceSize            |    AceFlags   |     AceType   |
//      +---------------+-------+-------+---------------+---------------+
//
//  AceType denotes the type of the ace, there are some predefined ace
//  types
//
//  AceSize is the size, in bytes, of ace.
//
//  AceFlags are the Ace flags for audit and inheritance, defined shortly.

typedef struct _ACE_HEADER {
    BYTE  AceType;
    BYTE  AceFlags;
    WORD   AceSize;
} ACE_HEADER;
typedef ACE_HEADER *PACE_HEADER;

//
//  The following are the predefined ace types that go into the AceType
//  field of an Ace header.
//

static const int ACCESS_MIN_MS_ACE_TYPE                  = (0x0);
static const int ACCESS_ALLOWED_ACE_TYPE                 = (0x0);
static const int ACCESS_DENIED_ACE_TYPE                  = (0x1);
static const int SYSTEM_AUDIT_ACE_TYPE                   = (0x2);
static const int SYSTEM_ALARM_ACE_TYPE                   = (0x3);
static const int ACCESS_MAX_MS_V2_ACE_TYPE               = (0x3);

static const int ACCESS_ALLOWED_COMPOUND_ACE_TYPE        = (0x4);
static const int ACCESS_MAX_MS_V3_ACE_TYPE               = (0x4);

static const int ACCESS_MIN_MS_OBJECT_ACE_TYPE           = (0x5);
static const int ACCESS_ALLOWED_OBJECT_ACE_TYPE          = (0x5);
static const int ACCESS_DENIED_OBJECT_ACE_TYPE           = (0x6);
static const int SYSTEM_AUDIT_OBJECT_ACE_TYPE            = (0x7);
static const int SYSTEM_ALARM_OBJECT_ACE_TYPE            = (0x8);
static const int ACCESS_MAX_MS_OBJECT_ACE_TYPE           = (0x8);

static const int ACCESS_MAX_MS_V4_ACE_TYPE               = (0x8);
static const int ACCESS_MAX_MS_ACE_TYPE                  = (0x8);

static const int ACCESS_ALLOWED_CALLBACK_ACE_TYPE        = (0x9);
static const int ACCESS_DENIED_CALLBACK_ACE_TYPE         = (0xA);
static const int ACCESS_ALLOWED_CALLBACK_OBJECT_ACE_TYPE = (0xB);
static const int ACCESS_DENIED_CALLBACK_OBJECT_ACE_TYPE  = (0xC);
static const int SYSTEM_AUDIT_CALLBACK_ACE_TYPE          = (0xD);
static const int SYSTEM_ALARM_CALLBACK_ACE_TYPE          = (0xE);
static const int SYSTEM_AUDIT_CALLBACK_OBJECT_ACE_TYPE   = (0xF);
static const int SYSTEM_ALARM_CALLBACK_OBJECT_ACE_TYPE   = (0x10);

static const int SYSTEM_MANDATORY_LABEL_ACE_TYPE         = (0x11);
static const int ACCESS_MAX_MS_V5_ACE_TYPE               = (0x11);


//
//  The following are the inherit flags that go into the AceFlags field
//  of an Ace header.
//

static const int OBJECT_INHERIT_ACE                = (0x1);
static const int CONTAINER_INHERIT_ACE             = (0x2);
static const int NO_PROPAGATE_INHERIT_ACE          = (0x4);
static const int INHERIT_ONLY_ACE                  = (0x8);
static const int INHERITED_ACE                     = (0x10);
static const int VALID_INHERIT_FLAGS               = (0x1F);


//  The following are the currently defined ACE flags that go into the
//  AceFlags field of an ACE header.  Each ACE type has its own set of
//  AceFlags.
//
//  SUCCESSFUL_ACCESS_ACE_FLAG - used only with system audit and alarm ACE
//  types to indicate that a message is generated for successful accesses.
//
//  FAILED_ACCESS_ACE_FLAG - used only with system audit and alarm ACE types
//  to indicate that a message is generated for failed accesses.
//

//
//  SYSTEM_AUDIT and SYSTEM_ALARM AceFlags
//
//  These control the signaling of audit and alarms for success or failure.
//

static const int SUCCESSFUL_ACCESS_ACE_FLAG       = (0x40);
static const int FAILED_ACCESS_ACE_FLAG           = (0x80);


//
//  We'll define the structure of the predefined ACE types.  Pictorally
//  the structure of the predefined ACE's is as follows:
//
//       3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
//       1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
//      +---------------+-------+-------+---------------+---------------+
//      |    AceFlags   | Resd  |Inherit|    AceSize    |     AceType   |
//      +---------------+-------+-------+---------------+---------------+
//      |                              Mask                             |
//      +---------------------------------------------------------------+
//      |                                                               |
//      +                                                               +
//      |                                                               |
//      +                              Sid                              +
//      |                                                               |
//      +                                                               +
//      |                                                               |
//      +---------------------------------------------------------------+
//
//  Mask is the access mask associated with the ACE.  This is either the
//  access allowed, access denied, audit, or alarm mask.
//
//  Sid is the Sid associated with the ACE.
//

//  The following are the four predefined ACE types.

//  Examine the AceType field in the Header to determine
//  which structure is appropriate to use for casting.


typedef struct _ACCESS_ALLOWED_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD SidStart;
} ACCESS_ALLOWED_ACE;

typedef ACCESS_ALLOWED_ACE *PACCESS_ALLOWED_ACE;

typedef struct _ACCESS_DENIED_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD SidStart;
} ACCESS_DENIED_ACE;
typedef ACCESS_DENIED_ACE *PACCESS_DENIED_ACE;

typedef struct _SYSTEM_AUDIT_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD SidStart;
} SYSTEM_AUDIT_ACE;
typedef SYSTEM_AUDIT_ACE *PSYSTEM_AUDIT_ACE;

typedef struct _SYSTEM_ALARM_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD SidStart;
} SYSTEM_ALARM_ACE;
typedef SYSTEM_ALARM_ACE *PSYSTEM_ALARM_ACE;

typedef struct _SYSTEM_MANDATORY_LABEL_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD SidStart;
} SYSTEM_MANDATORY_LABEL_ACE, *PSYSTEM_MANDATORY_LABEL_ACE;

static const int SYSTEM_MANDATORY_LABEL_NO_WRITE_UP       =  0x1;
static const int SYSTEM_MANDATORY_LABEL_NO_READ_UP        =  0x2;
static const int SYSTEM_MANDATORY_LABEL_NO_EXECUTE_UP     =  0x4;

static const int SYSTEM_MANDATORY_LABEL_VALID_MASK = (SYSTEM_MANDATORY_LABEL_NO_WRITE_UP   | \
                                           SYSTEM_MANDATORY_LABEL_NO_READ_UP    | \
                                           SYSTEM_MANDATORY_LABEL_NO_EXECUTE_UP);
// end_ntifs


typedef struct _ACCESS_ALLOWED_OBJECT_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD Flags;
    GUID ObjectType;
    GUID InheritedObjectType;
    DWORD SidStart;
} ACCESS_ALLOWED_OBJECT_ACE, *PACCESS_ALLOWED_OBJECT_ACE;

typedef struct _ACCESS_DENIED_OBJECT_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD Flags;
    GUID ObjectType;
    GUID InheritedObjectType;
    DWORD SidStart;
} ACCESS_DENIED_OBJECT_ACE, *PACCESS_DENIED_OBJECT_ACE;

typedef struct _SYSTEM_AUDIT_OBJECT_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD Flags;
    GUID ObjectType;
    GUID InheritedObjectType;
    DWORD SidStart;
} SYSTEM_AUDIT_OBJECT_ACE, *PSYSTEM_AUDIT_OBJECT_ACE;

typedef struct _SYSTEM_ALARM_OBJECT_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD Flags;
    GUID ObjectType;
    GUID InheritedObjectType;
    DWORD SidStart;
} SYSTEM_ALARM_OBJECT_ACE, *PSYSTEM_ALARM_OBJECT_ACE;

//
// Callback ace support in post Win2000.
// Resource managers can put their own data after Sidstart + Length of the sid
//

typedef struct _ACCESS_ALLOWED_CALLBACK_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD SidStart;
    // Opaque resouce manager specific data
} ACCESS_ALLOWED_CALLBACK_ACE, *PACCESS_ALLOWED_CALLBACK_ACE;

typedef struct _ACCESS_DENIED_CALLBACK_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD SidStart;
    // Opaque resouce manager specific data
} ACCESS_DENIED_CALLBACK_ACE, *PACCESS_DENIED_CALLBACK_ACE;

typedef struct _SYSTEM_AUDIT_CALLBACK_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD SidStart;
    // Opaque resouce manager specific data
} SYSTEM_AUDIT_CALLBACK_ACE, *PSYSTEM_AUDIT_CALLBACK_ACE;

typedef struct _SYSTEM_ALARM_CALLBACK_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD SidStart;
    // Opaque resouce manager specific data
} SYSTEM_ALARM_CALLBACK_ACE, *PSYSTEM_ALARM_CALLBACK_ACE;

typedef struct _ACCESS_ALLOWED_CALLBACK_OBJECT_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD Flags;
    GUID ObjectType;
    GUID InheritedObjectType;
    DWORD SidStart;
    // Opaque resouce manager specific data
} ACCESS_ALLOWED_CALLBACK_OBJECT_ACE, *PACCESS_ALLOWED_CALLBACK_OBJECT_ACE;

typedef struct _ACCESS_DENIED_CALLBACK_OBJECT_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD Flags;
    GUID ObjectType;
    GUID InheritedObjectType;
    DWORD SidStart;
    // Opaque resouce manager specific data
} ACCESS_DENIED_CALLBACK_OBJECT_ACE, *PACCESS_DENIED_CALLBACK_OBJECT_ACE;

typedef struct _SYSTEM_AUDIT_CALLBACK_OBJECT_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD Flags;
    GUID ObjectType;
    GUID InheritedObjectType;
    DWORD SidStart;
    // Opaque resouce manager specific data
} SYSTEM_AUDIT_CALLBACK_OBJECT_ACE, *PSYSTEM_AUDIT_CALLBACK_OBJECT_ACE;

typedef struct _SYSTEM_ALARM_CALLBACK_OBJECT_ACE {
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    DWORD Flags;
    GUID ObjectType;
    GUID InheritedObjectType;
    DWORD SidStart;
    // Opaque resouce manager specific data
} SYSTEM_ALARM_CALLBACK_OBJECT_ACE, *PSYSTEM_ALARM_CALLBACK_OBJECT_ACE;

//
// Currently define Flags for "OBJECT" ACE types.
//

static const int ACE_OBJECT_TYPE_PRESENT           = 0x1;
static const int ACE_INHERITED_OBJECT_TYPE_PRESENT = 0x2;
]]

ffi.cdef[[
typedef struct _SECURITY_DESCRIPTOR
{
    UCHAR Revision;
    UCHAR Sbz1;
    SECURITY_DESCRIPTOR_CONTROL Control;
    PSID Owner;
    PSID Group;
    PACL Sacl;
    PACL Dacl;
}   SECURITY_DESCRIPTOR, *PSECURITY_DESCRIPTOR;

typedef struct _COAUTHIDENTITY
{
    USHORT *User;
    ULONG UserLength;
    USHORT *Domain;
    ULONG DomainLength;
    USHORT *Password;
    ULONG PasswordLength;
    ULONG Flags;
}   COAUTHIDENTITY;

typedef struct _COAUTHINFO
{
    DWORD dwAuthnSvc;
    DWORD dwAuthzSvc;
    LPWSTR pwszServerPrincName;
    DWORD dwAuthnLevel;
    DWORD dwImpersonationLevel;
    COAUTHIDENTITY *pAuthIdentityData;
    DWORD dwCapabilities;
}   COAUTHINFO;
]]

ffi.cdef[[
//
// Token Information Classes.
//
typedef enum _TOKEN_INFORMATION_CLASS { 
  TokenUser                             = 1,
  TokenGroups,
  TokenPrivileges,
  TokenOwner,
  TokenPrimaryGroup,
  TokenDefaultDacl,
  TokenSource,
  TokenType,
  TokenImpersonationLevel,
  TokenStatistics,
  TokenRestrictedSids,
  TokenSessionId,
  TokenGroupsAndPrivileges,
  TokenSessionReference,
  TokenSandBoxInert,
  TokenAuditPolicy,
  TokenOrigin,
  TokenElevationType,
  TokenLinkedToken,
  TokenElevation,
  TokenHasRestrictions,
  TokenAccessInformation,
  TokenVirtualizationAllowed,
  TokenVirtualizationEnabled,
  TokenIntegrityLevel,
  TokenUIAccess,
  TokenMandatoryPolicy,
  TokenLogonSid,
  TokenIsAppContainer,
  TokenCapabilities,
  TokenAppContainerSid,
  TokenAppContainerNumber,
  TokenUserClaimAttributes,
  TokenDeviceClaimAttributes,
  TokenRestrictedUserClaimAttributes,
  TokenRestrictedDeviceClaimAttributes,
  TokenDeviceGroups,
  TokenRestrictedDeviceGroups,
  TokenSecurityAttributes,
  TokenIsRestricted,
  MaxTokenInfoClass
} TOKEN_INFORMATION_CLASS, *PTOKEN_INFORMATION_CLASS;

/*
typedef enum _TOKEN_INFORMATION_CLASS {
    TokenUser = 1,
    TokenGroups,
    TokenPrivileges,
    TokenOwner,
    TokenPrimaryGroup,
    TokenDefaultDacl,
    TokenSource,
    TokenType,
    TokenImpersonationLevel,
    TokenStatistics,
    TokenRestrictedSids,
    TokenSessionId,
    TokenGroupsAndPrivileges,
    TokenSessionReference,
    TokenSandBoxInert,
    TokenAuditPolicy,
    TokenOrigin,
    TokenElevationType,
    TokenLinkedToken,
    TokenElevation,
    TokenHasRestrictions,
    TokenAccessInformation,
    TokenVirtualizationAllowed,
    TokenVirtualizationEnabled,
    TokenIntegrityLevel,
    TokenUIAccess,
    TokenMandatoryPolicy,
    TokenLogonSid,
    MaxTokenInfoClass  // MaxTokenInfoClass should always be the last enum
} TOKEN_INFORMATION_CLASS, *PTOKEN_INFORMATION_CLASS;
*/
]]

ffi.cdef[[
//
// Token Specific Access Rights.
//

static const int TOKEN_ASSIGN_PRIMARY    = (0x0001);
static const int TOKEN_DUPLICATE         = (0x0002);
static const int TOKEN_IMPERSONATE       = (0x0004);
static const int TOKEN_QUERY             = (0x0008);
static const int TOKEN_QUERY_SOURCE      = (0x0010);
static const int TOKEN_ADJUST_PRIVILEGES = (0x0020);
static const int TOKEN_ADJUST_GROUPS     = (0x0040);
static const int TOKEN_ADJUST_DEFAULT    = (0x0080);
static const int TOKEN_ADJUST_SESSIONID  = (0x0100);

static const int TOKEN_ALL_ACCESS_P =(STANDARD_RIGHTS_REQUIRED  |\
                          TOKEN_ASSIGN_PRIMARY      |\
                          TOKEN_DUPLICATE           |\
                          TOKEN_IMPERSONATE         |\
                          TOKEN_QUERY               |\
                          TOKEN_QUERY_SOURCE        |\
                          TOKEN_ADJUST_PRIVILEGES   |\
                          TOKEN_ADJUST_GROUPS       |\
                          TOKEN_ADJUST_DEFAULT );

static const int TOKEN_ALL_ACCESS  = (TOKEN_ALL_ACCESS_P |\
                          TOKEN_ADJUST_SESSIONID );

static const int TOKEN_READ      = (STANDARD_RIGHTS_READ      |\
                          TOKEN_QUERY);


static const int TOKEN_WRITE     = (STANDARD_RIGHTS_WRITE     |\
                          TOKEN_ADJUST_PRIVILEGES   |\
                          TOKEN_ADJUST_GROUPS       |\
                          TOKEN_ADJUST_DEFAULT);

static const int TOKEN_EXECUTE   = (STANDARD_RIGHTS_EXECUTE);
]]

ffi.cdef[[
//
//
// Token Types
//

typedef enum _TOKEN_TYPE {
    TokenPrimary = 1,
    TokenImpersonation
    } TOKEN_TYPE;

typedef TOKEN_TYPE *PTOKEN_TYPE;

//
// Token elevation values describe the relative strength of a given token.
// A full token is a token with all groups and privileges to which the principal
// is authorized.  A limited token is one with some groups or privileges removed.
//

typedef enum _TOKEN_ELEVATION_TYPE {
    TokenElevationTypeDefault = 1,
    TokenElevationTypeFull,
    TokenElevationTypeLimited,
} TOKEN_ELEVATION_TYPE, *PTOKEN_ELEVATION_TYPE;
]]

ffi.cdef[[
typedef struct _TOKEN_USER {
    SID_AND_ATTRIBUTES User;
} TOKEN_USER, *PTOKEN_USER;

typedef struct _TOKEN_GROUPS {
    DWORD GroupCount;
    SID_AND_ATTRIBUTES Groups[ANYSIZE_ARRAY];
} TOKEN_GROUPS, *PTOKEN_GROUPS;

typedef struct _TOKEN_MANDATORY_LABEL {
    SID_AND_ATTRIBUTES Label;
} TOKEN_MANDATORY_LABEL, *PTOKEN_MANDATORY_LABEL;

typedef struct _TOKEN_PRIVILEGES {
    DWORD PrivilegeCount;
    LUID_AND_ATTRIBUTES Privileges[ANYSIZE_ARRAY];
} TOKEN_PRIVILEGES, *PTOKEN_PRIVILEGES;

typedef struct _TOKEN_OWNER {
    PSID Owner;
} TOKEN_OWNER, *PTOKEN_OWNER;

typedef struct _TOKEN_PRIMARY_GROUP {
    PSID PrimaryGroup;
} TOKEN_PRIMARY_GROUP, *PTOKEN_PRIMARY_GROUP;

typedef struct _TOKEN_DEFAULT_DACL {
    PACL DefaultDacl;
} TOKEN_DEFAULT_DACL, *PTOKEN_DEFAULT_DACL;
]]

ffi.cdef[[
static const int TOKEN_SOURCE_LENGTH = 8;

typedef struct _TOKEN_SOURCE {
    CHAR SourceName[TOKEN_SOURCE_LENGTH];
    LUID SourceIdentifier;
} TOKEN_SOURCE, *PTOKEN_SOURCE;
]]

ffi.cdef[[
static const int SID_HASH_SIZE = 32;

typedef ULONG_PTR SID_HASH_ENTRY, *PSID_HASH_ENTRY;

typedef struct _SID_AND_ATTRIBUTES_HASH {
    DWORD SidCount;
    PSID_AND_ATTRIBUTES SidAttr;
    SID_HASH_ENTRY Hash[SID_HASH_SIZE];
} SID_AND_ATTRIBUTES_HASH, *PSID_AND_ATTRIBUTES_HASH;
]]

ffi.cdef[[
typedef struct _TOKEN_STATISTICS {
    LUID TokenId;
    LUID AuthenticationId;
    LARGE_INTEGER ExpirationTime;
    TOKEN_TYPE TokenType;
    SECURITY_IMPERSONATION_LEVEL ImpersonationLevel;
    DWORD DynamicCharged;
    DWORD DynamicAvailable;
    DWORD GroupCount;
    DWORD PrivilegeCount;
    LUID ModifiedId;
} TOKEN_STATISTICS, *PTOKEN_STATISTICS;

typedef struct _TOKEN_GROUPS_AND_PRIVILEGES {
    DWORD SidCount;
    DWORD SidLength;
    PSID_AND_ATTRIBUTES Sids;
    DWORD RestrictedSidCount;
    DWORD RestrictedSidLength;
    PSID_AND_ATTRIBUTES RestrictedSids;
    DWORD PrivilegeCount;
    DWORD PrivilegeLength;
    PLUID_AND_ATTRIBUTES Privileges;
    LUID AuthenticationId;
} TOKEN_GROUPS_AND_PRIVILEGES, *PTOKEN_GROUPS_AND_PRIVILEGES;

typedef struct _TOKEN_ORIGIN {
    LUID OriginatingLogonSession ;
} TOKEN_ORIGIN, * PTOKEN_ORIGIN ;

typedef struct _TOKEN_LINKED_TOKEN {
    HANDLE LinkedToken;
} TOKEN_LINKED_TOKEN, *PTOKEN_LINKED_TOKEN;

typedef struct _TOKEN_ELEVATION {
    DWORD TokenIsElevated;
} TOKEN_ELEVATION, *PTOKEN_ELEVATION;

typedef struct _TOKEN_MANDATORY_POLICY {
    DWORD Policy;
} TOKEN_MANDATORY_POLICY, *PTOKEN_MANDATORY_POLICY;

typedef struct _TOKEN_ACCESS_INFORMATION {
    PSID_AND_ATTRIBUTES_HASH SidHash;
    PSID_AND_ATTRIBUTES_HASH RestrictedSidHash;
    PTOKEN_PRIVILEGES Privileges;
    LUID AuthenticationId;
    TOKEN_TYPE TokenType;
    SECURITY_IMPERSONATION_LEVEL ImpersonationLevel;
    TOKEN_MANDATORY_POLICY MandatoryPolicy;
    DWORD Flags;
} TOKEN_ACCESS_INFORMATION, *PTOKEN_ACCESS_INFORMATION;

]]

ffi.cdef[[
//
// Service Types (Bit Mask)
//
static const int SERVICE_KERNEL_DRIVER         = 0x00000001;
static const int SERVICE_FILE_SYSTEM_DRIVER    = 0x00000002;
static const int SERVICE_ADAPTER               = 0x00000004;
static const int SERVICE_RECOGNIZER_DRIVER     = 0x00000008;

static const int SERVICE_DRIVER                = (SERVICE_KERNEL_DRIVER | \
                                        SERVICE_FILE_SYSTEM_DRIVER | \
                                        SERVICE_RECOGNIZER_DRIVER);

static const int SERVICE_WIN32_OWN_PROCESS     = 0x00000010;
static const int SERVICE_WIN32_SHARE_PROCESS   = 0x00000020;
static const int SERVICE_WIN32                 = (SERVICE_WIN32_OWN_PROCESS | \
                                        SERVICE_WIN32_SHARE_PROCESS);

static const int SERVICE_INTERACTIVE_PROCESS   = 0x00000100;

static const int SERVICE_TYPE_ALL              = (SERVICE_WIN32  | \
                                        SERVICE_ADAPTER | \
                                        SERVICE_DRIVER  | \
                                        SERVICE_INTERACTIVE_PROCESS);
]]


ffi.cdef[[
//typedef __ptr64 POINTER_64;

typedef void * __ptr64 PVOID64;


typedef union _FILE_SEGMENT_ELEMENT {
    PVOID64 Buffer;
    ULONGLONG Alignment;
}FILE_SEGMENT_ELEMENT, *PFILE_SEGMENT_ELEMENT;
]]


ffi.cdef[[
static const int FILE_ATTRIBUTE_READONLY             = 0x00000001;  
static const int FILE_ATTRIBUTE_HIDDEN               = 0x00000002;  
static const int FILE_ATTRIBUTE_SYSTEM               = 0x00000004;  
static const int FILE_ATTRIBUTE_DIRECTORY            = 0x00000010;  
static const int FILE_ATTRIBUTE_ARCHIVE              = 0x00000020;  
static const int FILE_ATTRIBUTE_DEVICE               = 0x00000040;  
static const int FILE_ATTRIBUTE_NORMAL               = 0x00000080;  
static const int FILE_ATTRIBUTE_TEMPORARY            = 0x00000100;  
static const int FILE_ATTRIBUTE_SPARSE_FILE          = 0x00000200;  
static const int FILE_ATTRIBUTE_REPARSE_POINT        = 0x00000400;  
static const int FILE_ATTRIBUTE_COMPRESSED           = 0x00000800;  
static const int FILE_ATTRIBUTE_OFFLINE              = 0x00001000;  
static const int FILE_ATTRIBUTE_NOT_CONTENT_INDEXED  = 0x00002000;  
static const int FILE_ATTRIBUTE_ENCRYPTED            = 0x00004000;  
static const int FILE_ATTRIBUTE_VIRTUAL              = 0x00010000;  
]]

ffi.cdef[[
static const int MAXIMUM_ALLOWED                 = 0x02000000;
]]

ffi.cdef[[
static const int PROCESSOR_ARCHITECTURE_INTEL           = 0;
static const int PROCESSOR_ARCHITECTURE_MIPS            = 1;
static const int PROCESSOR_ARCHITECTURE_ALPHA           = 2;
static const int PROCESSOR_ARCHITECTURE_PPC             = 3;
static const int PROCESSOR_ARCHITECTURE_SHX             = 4;
static const int PROCESSOR_ARCHITECTURE_ARM             = 5;
static const int PROCESSOR_ARCHITECTURE_IA64            = 6;
static const int PROCESSOR_ARCHITECTURE_ALPHA64         = 7;
static const int PROCESSOR_ARCHITECTURE_MSIL            = 8;
static const int PROCESSOR_ARCHITECTURE_AMD64           = 9;
static const int PROCESSOR_ARCHITECTURE_IA32_ON_WIN64   = 10;

static const int PROCESSOR_ARCHITECTURE_UNKNOWN = 0xFFFF;
]]



return {
    StandardRights = ffi.new("StandardRights");
    GenericRights = ffi.new("GENERIC_MAPPING");
}