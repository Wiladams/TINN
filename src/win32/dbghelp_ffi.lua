local ffi = require("ffi")

require("WTypes");
require("WinNT");

local Lib = ffi.load("dbghelp");


--[[
 BUILD Version: 0000     Increment this if a change has global effects

Copyright (c) Microsoft Corporation. All rights reserved.

Module Name:

    dbghelp.h

Abstract:

    This module defines the prototypes and constants required for the image
    help routines.

    Contains debugging support routines that are redistributable.

Revision History:

--]]



--[[
// As a general principal always call the 64 bit version
// of every API, if a choice exists.  The 64 bit version
// works great on 32 bit platforms, and is forward
// compatible to 64 bit platforms.
--]]
local _WIN64 = ffi.os == "Windows" and ffi.abi("64bit");
local _IMAGEHLP64 = ffi.abi("64bit");



--#include <pshpack8.h>



ffi.cdef[[
	static const int IMAGE_SEPARATION = (64*1024);
]]

--[[
// Observant readers may notice that 2 new fields,
// 'fReadOnly' and 'Version' have been added to
// the LOADED_IMAGE structure after 'fDOSImage'.
// This does not change the size of the structure 
// from previous headers.  That is because while 
// 'fDOSImage' is a byte, it is padded by the 
// compiler to 4 bytes.  So the 2 new fields are 
// slipped into the extra space.
--]]

if _IMAGEHLP64 then
ffi.cdef[[
typedef struct _LOADED_IMAGE {
    PSTR                  ModuleName;
    HANDLE                hFile;
    PUCHAR                MappedAddress;
    PIMAGE_NT_HEADERS64   FileHeader;
    PIMAGE_SECTION_HEADER LastRvaSection;
    ULONG                 NumberOfSections;
    PIMAGE_SECTION_HEADER Sections;
    ULONG                 Characteristics;
    BOOLEAN               fSystemImage;
    BOOLEAN               fDOSImage;
    BOOLEAN               fReadOnly;
    UCHAR                 Version;
    LIST_ENTRY            Links;
    ULONG                 SizeOfImage;
} LOADED_IMAGE, *PLOADED_IMAGE;
]]
else
ffi.cdef[[
typedef struct _LOADED_IMAGE {
    PSTR                  ModuleName;
    HANDLE                hFile;
    PUCHAR                MappedAddress;
    PIMAGE_NT_HEADERS32   FileHeader;
    PIMAGE_SECTION_HEADER LastRvaSection;
    ULONG                 NumberOfSections;
    PIMAGE_SECTION_HEADER Sections;
    ULONG                 Characteristics;
    BOOLEAN               fSystemImage;
    BOOLEAN               fDOSImage;
    BOOLEAN               fReadOnly;
    UCHAR                 Version;
    LIST_ENTRY            Links;
    ULONG                 SizeOfImage;
} LOADED_IMAGE, *PLOADED_IMAGE;
]]
end

ffi.cdef[[
	static const int MAX_SYM_NAME           = 2000;
]]

--[[ 
 Error codes set by dbghelp functions.  Call GetLastError
 to see them.
 Dbghelp also sets error codes found in winerror.h
--]]

ERROR_IMAGE_NOT_STRIPPED   = 0x8800;  -- the image is not stripped.  No dbg file available.
ERROR_NO_DBG_POINTER       = 0x8801;  -- image is stripped but there is no pointer to a dbg file
ERROR_NO_PDB_POINTER       = 0x8802;  -- image does not point to a pdb file

ffi.cdef[[
typedef BOOL
( *PFIND_DEBUG_FILE_CALLBACK)(
    HANDLE FileHandle,
    PCSTR FileName,
    PVOID CallerData
    );

HANDLE
SymFindDebugInfoFile(
    HANDLE hProcess,
    PCSTR FileName,
    PSTR DebugFilePath,
    PFIND_DEBUG_FILE_CALLBACK Callback,
    PVOID CallerData
    );

typedef BOOL
( *PFIND_DEBUG_FILE_CALLBACKW)(
    HANDLE FileHandle,
    PCWSTR FileName,
    PVOID  CallerData
    );

HANDLE
SymFindDebugInfoFileW(
    HANDLE hProcess,
    PCWSTR FileName,
    PWSTR DebugFilePath,
    PFIND_DEBUG_FILE_CALLBACKW Callback,
    PVOID CallerData
    );
]]

ffi.cdef[[
HANDLE
FindDebugInfoFile (
    PCSTR FileName,
    PCSTR SymbolPath,
    PSTR DebugFilePath
    );

HANDLE
FindDebugInfoFileEx (
    PCSTR FileName,
    PCSTR SymbolPath,
    PSTR  DebugFilePath,
    PFIND_DEBUG_FILE_CALLBACK Callback,
    PVOID CallerData
    );

HANDLE
FindDebugInfoFileExW (
    PCWSTR FileName,
    PCWSTR SymbolPath,
    PWSTR DebugFilePath,
    PFIND_DEBUG_FILE_CALLBACKW Callback,
    PVOID CallerData
    );
]]

ffi.cdef[[
typedef BOOL
( *PFINDFILEINPATHCALLBACK)(
    PCSTR filename,
    PVOID context
    );

BOOL
SymFindFileInPath(
    HANDLE hprocess,
    PCSTR SearchPath,
    PCSTR FileName,
    PVOID id,
    DWORD two,
    DWORD three,
    DWORD flags,
    PSTR FoundFile,
    PFINDFILEINPATHCALLBACK callback,
    PVOID context
    );

typedef BOOL
( *PFINDFILEINPATHCALLBACKW)(
    PCWSTR filename,
    PVOID context
    );

BOOL
SymFindFileInPathW(
    HANDLE hprocess,
    PCWSTR SearchPath,
    PCWSTR FileName,
    PVOID id,
    DWORD two,
    DWORD three,
    DWORD flags,
    PWSTR FoundFile,
    PFINDFILEINPATHCALLBACKW callback,
    PVOID context
    );
]]

ffi.cdef[[
typedef BOOL
( *PFIND_EXE_FILE_CALLBACK)(
    HANDLE FileHandle,
    PCSTR FileName,
    PVOID CallerData
    );

HANDLE
SymFindExecutableImage(
    HANDLE hProcess,
    PCSTR FileName,
    PSTR ImageFilePath,
    PFIND_EXE_FILE_CALLBACK Callback,
    PVOID CallerData
    );

typedef BOOL
( *PFIND_EXE_FILE_CALLBACKW)(
    HANDLE FileHandle,
    PCWSTR FileName,
    PVOID CallerData
    );

HANDLE
SymFindExecutableImageW(
    HANDLE hProcess,
    PCWSTR FileName,
    PWSTR ImageFilePath,
    PFIND_EXE_FILE_CALLBACKW Callback,
    PVOID CallerData
    );

HANDLE
FindExecutableImage(
    PCSTR FileName,
    PCSTR SymbolPath,
    PSTR ImageFilePath
    );

HANDLE
FindExecutableImageEx(
    PCSTR FileName,
    PCSTR SymbolPath,
    PSTR ImageFilePath,
    PFIND_EXE_FILE_CALLBACK Callback,
    PVOID CallerData
    );

HANDLE
FindExecutableImageExW(
    PCWSTR FileName,
    PCWSTR SymbolPath,
    PWSTR ImageFilePath,
    PFIND_EXE_FILE_CALLBACKW Callback,
    PVOID CallerData
    );
]]

ffi.cdef[[
PIMAGE_NT_HEADERS
ImageNtHeader (
    PVOID Base
    );

PVOID
ImageDirectoryEntryToDataEx (
    PVOID Base,
    BOOLEAN MappedAsImage,
    USHORT DirectoryEntry,
    PULONG Size,
    PIMAGE_SECTION_HEADER *FoundHeader
    );

PVOID
ImageDirectoryEntryToData (
    PVOID Base,
    BOOLEAN MappedAsImage,
    USHORT DirectoryEntry,
    PULONG Size
    );
]]

ffi.cdef[[
PIMAGE_SECTION_HEADER
ImageRvaToSection(
    PIMAGE_NT_HEADERS NtHeaders,
    PVOID Base,
    ULONG Rva
    );

PVOID
ImageRvaToVa(
    PIMAGE_NT_HEADERS NtHeaders,
    PVOID Base,
    ULONG Rva,
    PIMAGE_SECTION_HEADER *LastRvaSection
    );
]]



ffi.cdef[[
BOOL
SearchTreeForFile(
    PCSTR RootPath,
    PCSTR InputPathName,
    PSTR OutputPathBuffer
    );

BOOL
SearchTreeForFileW(
    PCWSTR RootPath,
    PCWSTR InputPathName,
    PWSTR OutputPathBuffer
    );

typedef BOOL
( *PENUMDIRTREE_CALLBACK)(
    PCSTR FilePath,
    PVOID CallerData
    );
]]

ffi.cdef[[
BOOL
EnumDirTree(
    HANDLE hProcess,
    PCSTR RootPath,
    PCSTR InputPathName,
    PSTR OutputPathBuffer,
    PENUMDIRTREE_CALLBACK cb,
    PVOID data
    );

typedef BOOL
( *PENUMDIRTREE_CALLBACKW)(
    PCWSTR FilePath,
    PVOID CallerData
    );

BOOL
EnumDirTreeW(
    HANDLE hProcess,
    PCWSTR RootPath,
    PCWSTR InputPathName,
    PWSTR OutputPathBuffer,
    PENUMDIRTREE_CALLBACKW cb,
    PVOID data
    );
]]

ffi.cdef[[
BOOL
MakeSureDirectoryPathExists(
    PCSTR DirPath
    );
]]

ffi.cdef[[
//
// UnDecorateSymbolName Flags
//

static const int UNDNAME_COMPLETE                 = (0x0000);  // Enable full undecoration
static const int UNDNAME_NO_LEADING_UNDERSCORES   = (0x0001);  // Remove leading underscores from MS extended keywords
static const int UNDNAME_NO_MS_KEYWORDS           = (0x0002);  // Disable expansion of MS extended keywords
static const int UNDNAME_NO_FUNCTION_RETURNS      = (0x0004);  // Disable expansion of return type for primary declaration
static const int UNDNAME_NO_ALLOCATION_MODEL      = (0x0008);  // Disable expansion of the declaration model
static const int UNDNAME_NO_ALLOCATION_LANGUAGE   = (0x0010);  // Disable expansion of the declaration language specifier
static const int UNDNAME_NO_MS_THISTYPE           = (0x0020);  // NYI Disable expansion of MS keywords on the 'this' type for primary declaration
static const int UNDNAME_NO_CV_THISTYPE           = (0x0040);  // NYI Disable expansion of CV modifiers on the 'this' type for primary declaration
static const int UNDNAME_NO_THISTYPE              = (0x0060);  // Disable all modifiers on the 'this' type
static const int UNDNAME_NO_ACCESS_SPECIFIERS     = (0x0080);  // Disable expansion of access specifiers for members
static const int UNDNAME_NO_THROW_SIGNATURES      = (0x0100);  // Disable expansion of 'throw-signatures' for functions and pointers to functions
static const int UNDNAME_NO_MEMBER_TYPE           = (0x0200);  // Disable expansion of 'static' or 'virtual'ness of members
static const int UNDNAME_NO_RETURN_UDT_MODEL      = (0x0400);  // Disable expansion of MS model for UDT returns
static const int UNDNAME_32_BIT_DECODE            = (0x0800);  // Undecorate 32-bit decorated names
static const int UNDNAME_NAME_ONLY                = (0x1000);  // Crack only the name for primary declaration;
                                                                                                   //  return just [scope::]name.  Does expand template params
static const int UNDNAME_NO_ARGUMENTS             = (0x2000);  // Don't undecorate arguments to function
static const int UNDNAME_NO_SPECIAL_SYMS          = (0x4000);  // Don't undecorate special names (v-table, vcall, vector xxx, metatype, etc)

DWORD

UnDecorateSymbolName(
    PCSTR name,
    PSTR outputString,
    DWORD maxStringLength,
    DWORD flags
    );

DWORD

UnDecorateSymbolNameW(
    PCWSTR name,
    PWSTR outputString,
    DWORD maxStringLength,
    DWORD flags
    );
]]

ffi.cdef[[
//
// these values are used for synthesized file types
// that can be passed in as image headers instead of
// the standard ones from ntimage.h
//

static const int DBHHEADER_DEBUGDIRS   =  0x1;
static const int DBHHEADER_CVMISC      =  0x2;
static const int DBHHEADER_PDBGUID     =  0x3;
]]

ffi.cdef[[
typedef struct _MODLOAD_DATA {
    DWORD   ssize;                  // size of this struct
    DWORD   ssig;                   // signature identifying the passed data
    PVOID   data;                   // pointer to passed data
    DWORD   size;                   // size of passed data
    DWORD   flags;                  // options
} MODLOAD_DATA, *PMODLOAD_DATA;

typedef struct _MODLOAD_CVMISC {
    DWORD   oCV;                    // ofset to the codeview record
    size_t  cCV;                    // size of the codeview record
    DWORD   oMisc;                  // offset to the misc record
    size_t  cMisc;                  // size of the misc record
    DWORD   dtImage;                // datetime stamp of the image
    DWORD   cImage;                 // size of the image
} MODLOAD_CVMISC, *PMODLOAD_CVMISC;

typedef struct _MODLOAD_PDBGUID_PDBAGE {
    GUID    PdbGuid;                // Pdb Guid 
    DWORD   PdbAge;                 // Pdb Age 
} MODLOAD_PDBGUID_PDBAGE, *PMODLOAD_PDBGUID_PDBAGE;
]]

ffi.cdef[[
//
// StackWalking API
//

typedef enum {
    AddrMode1616,
    AddrMode1632,
    AddrModeReal,
    AddrModeFlat
} ADDRESS_MODE;

typedef struct _tagADDRESS64 {
    DWORD64       Offset;
    WORD          Segment;
    ADDRESS_MODE  Mode;
} ADDRESS64, *LPADDRESS64;
]]


if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
    ADDRESS = ffi.typeof("ADDRESS64");
    LPADDRESS = ffi.typeof("LPADDRESS64");
else
    ffi.cdef[[
        typedef struct _tagADDRESS {
            DWORD         Offset;
            WORD          Segment;
            ADDRESS_MODE  Mode;
        } ADDRESS, *LPADDRESS;
    ]]

    local function Address32To64(a32, a64)

        a64.Offset = ffi.cast("(uint64_t)",ffi.cast("int64_t",ffi.cast("int32_t",a32.Offset)));
        a64.Segment = a32.Segment;
        a64.Mode = a32.Mode;
    end


    local function Address64To32(a64, a32)

        a32.Offset = ffi.cast("uint32_t",a64.Offset);
        a32.Segment = a64.Segment;
        a32.Mode = a64.Mode;
    end
end


ffi.cdef[[
//
// This structure is included in the STACKFRAME structure,
// and is used to trace through usermode callbacks in a thread's
// kernel stack.  The values must be copied by the kernel debugger
// from the DBGKD_GET_VERSION and WAIT_STATE_CHANGE packets.
//

//
// New KDHELP structure for 64 bit system support.
// This structure is preferred in new code.
//
typedef struct _KDHELP64 {

    //
    // address of kernel thread object, as provided in the
    // WAIT_STATE_CHANGE packet.
    //
    DWORD64   Thread;

    //
    // offset in thread object to pointer to the current callback frame
    // in kernel stack.
    //
    DWORD   ThCallbackStack;

    //
    // offset in thread object to pointer to the current callback backing
    // store frame in kernel stack.
    //
    DWORD   ThCallbackBStore;

    //
    // offsets to values in frame:
    //
    // address of next callback frame
    DWORD   NextCallback;

    // address of saved frame pointer (if applicable)
    DWORD   FramePointer;


    //
    // Address of the kernel function that calls out to user mode
    //
    DWORD64   KiCallUserMode;

    //
    // Address of the user mode dispatcher function
    //
    DWORD64   KeUserCallbackDispatcher;

    //
    // Lowest kernel mode address
    //
    DWORD64   SystemRangeStart;

    //
    // Address of the user mode exception dispatcher function.
    // Added in API version 10.
    //
    DWORD64   KiUserExceptionDispatcher;

    //
    // Stack bounds, added in API version 11.
    //
    DWORD64   StackBase;
    DWORD64   StackLimit;

    DWORD64   Reserved[5];

} KDHELP64, *PKDHELP64;
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
KDHELP = KDHELP64;
PKDHELP = PKDHELP64;
else
ffi.cdef[[
typedef struct _KDHELP {

    //
    // address of kernel thread object, as provided in the
    // WAIT_STATE_CHANGE packet.
    //
    DWORD   Thread;

    //
    // offset in thread object to pointer to the current callback frame
    // in kernel stack.
    //
    DWORD   ThCallbackStack;

    //
    // offsets to values in frame:
    //
    // address of next callback frame
    DWORD   NextCallback;

    // address of saved frame pointer (if applicable)
    DWORD   FramePointer;

    //
    // Address of the kernel function that calls out to user mode
    //
    DWORD   KiCallUserMode;

    //
    // Address of the user mode dispatcher function
    //
    DWORD   KeUserCallbackDispatcher;

    //
    // Lowest kernel mode address
    //
    DWORD   SystemRangeStart;

    //
    // offset in thread object to pointer to the current callback backing
    // store frame in kernel stack.
    //
    DWORD   ThCallbackBStore;

    //
    // Address of the user mode exception dispatcher function.
    // Added in API version 10.
    //
    DWORD   KiUserExceptionDispatcher;

    //
    // Stack bounds, added in API version 11.
    //
    DWORD   StackBase;
    DWORD   StackLimit;

    DWORD   Reserved[5];

} KDHELP, *PKDHELP;
]]

local function KdHelp32To64(p32, p64)

    p64.Thread = p32.Thread;
    p64.ThCallbackStack = p32.ThCallbackStack;
    p64.NextCallback = p32.NextCallback;
    p64.FramePointer = p32.FramePointer;
    p64.KiCallUserMode = p32.KiCallUserMode;
    p64.KeUserCallbackDispatcher = p32.KeUserCallbackDispatcher;
    p64.SystemRangeStart = p32.SystemRangeStart;
    p64.KiUserExceptionDispatcher = p32.KiUserExceptionDispatcher;
    p64.StackBase = p32.StackBase;
    p64.StackLimit = p32.StackLimit;
end
end

ffi.cdef[[
typedef struct _tagSTACKFRAME64 {
    ADDRESS64   AddrPC;               // program counter
    ADDRESS64   AddrReturn;           // return address
    ADDRESS64   AddrFrame;            // frame pointer
    ADDRESS64   AddrStack;            // stack pointer
    ADDRESS64   AddrBStore;           // backing store pointer
    PVOID       FuncTableEntry;       // pointer to pdata/fpo or NULL
    DWORD64     Params[4];            // possible arguments to the function
    BOOL        Far;                  // WOW far call
    BOOL        Virtual;              // is this a virtual frame?
    DWORD64     Reserved[3];
    KDHELP64    KdHelp;
} STACKFRAME64, *LPSTACKFRAME64;
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
STACKFRAME = STACKFRAME64
LPSTACKFRAME = LPSTACKFRAME64
else
ffi.cdef[[
typedef struct _tagSTACKFRAME {
    ADDRESS     AddrPC;               // program counter
    ADDRESS     AddrReturn;           // return address
    ADDRESS     AddrFrame;            // frame pointer
    ADDRESS     AddrStack;            // stack pointer
    PVOID       FuncTableEntry;       // pointer to pdata/fpo or NULL
    DWORD       Params[4];            // possible arguments to the function
    BOOL        Far;                  // WOW far call
    BOOL        Virtual;              // is this a virtual frame?
    DWORD       Reserved[3];
    KDHELP      KdHelp;
    ADDRESS     AddrBStore;           // backing store pointer
} STACKFRAME, *LPSTACKFRAME;
]]
end

ffi.cdef[[
typedef
BOOL
(__stdcall *PREAD_PROCESS_MEMORY_ROUTINE64)(
    HANDLE hProcess,
    DWORD64 qwBaseAddress,
    PVOID lpBuffer,
    DWORD nSize,
    LPDWORD lpNumberOfBytesRead
    );

typedef
PVOID
(__stdcall *PFUNCTION_TABLE_ACCESS_ROUTINE64)(
    HANDLE ahProcess,
    DWORD64 AddrBase
    );

typedef
DWORD64
(__stdcall *PGET_MODULE_BASE_ROUTINE64)(
    HANDLE hProcess,
    DWORD64 Address
    );

typedef
DWORD64
(__stdcall *PTRANSLATE_ADDRESS_ROUTINE64)(
    HANDLE hProcess,
    HANDLE hThread,
    LPADDRESS64 lpaddr
    );
]]

ffi.cdef[[
BOOL
StackWalk64(
    DWORD MachineType,
    HANDLE hProcess,
    HANDLE hThread,
    LPSTACKFRAME64 StackFrame,
    PVOID ContextRecord,
    PREAD_PROCESS_MEMORY_ROUTINE64 ReadMemoryRoutine,
    PFUNCTION_TABLE_ACCESS_ROUTINE64 FunctionTableAccessRoutine,
    PGET_MODULE_BASE_ROUTINE64 GetModuleBaseRoutine,
    PTRANSLATE_ADDRESS_ROUTINE64 TranslateAddress
    );
]]


if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then

PREAD_PROCESS_MEMORY_ROUTINE = ffi.typeof("PREAD_PROCESS_MEMORY_ROUTINE64");
PFUNCTION_TABLE_ACCESS_ROUTINE = ffi.typeof("PFUNCTION_TABLE_ACCESS_ROUTINE64");
PGET_MODULE_BASE_ROUTINE = ffi.typeof("PGET_MODULE_BASE_ROUTINE64");
PTRANSLATE_ADDRESS_ROUTINE = ffi.typeof("PTRANSLATE_ADDRESS_ROUTINE64");

StackWalk = Lib.StackWalk64;

else
ffi.cdef[[
typedef
BOOL
(__stdcall *PREAD_PROCESS_MEMORY_ROUTINE)(
    HANDLE hProcess,
    DWORD lpBaseAddress,
    PVOID lpBuffer,
    DWORD nSize,
    PDWORD lpNumberOfBytesRead
    );

typedef
PVOID
(__stdcall *PFUNCTION_TABLE_ACCESS_ROUTINE)(
    HANDLE hProcess,
    DWORD AddrBase
    );

typedef
DWORD
(__stdcall *PGET_MODULE_BASE_ROUTINE)(
    HANDLE hProcess,
    DWORD Address
    );

typedef
DWORD
(__stdcall *PTRANSLATE_ADDRESS_ROUTINE)(
    HANDLE hProcess,
    HANDLE hThread,
    LPADDRESS lpaddr
    );

BOOL
StackWalk(
    DWORD MachineType,
    HANDLE hProcess,
    HANDLE hThread,
    LPSTACKFRAME StackFrame,
    PVOID ContextRecord,
    PREAD_PROCESS_MEMORY_ROUTINE ReadMemoryRoutine,
    PFUNCTION_TABLE_ACCESS_ROUTINE FunctionTableAccessRoutine,
    PGET_MODULE_BASE_ROUTINE GetModuleBaseRoutine,
    PTRANSLATE_ADDRESS_ROUTINE TranslateAddress
    );
]]
end


API_VERSION_NUMBER = 11;

ffi.cdef[[
typedef struct API_VERSION {
    USHORT  MajorVersion;
    USHORT  MinorVersion;
    USHORT  Revision;
    USHORT  Reserved;
} API_VERSION, *LPAPI_VERSION;

LPAPI_VERSION
ImagehlpApiVersion();

LPAPI_VERSION
ImagehlpApiVersionEx(
    LPAPI_VERSION AppVersion
    );
]]

ffi.cdef[[
DWORD
GetTimestampForLoadedLibrary(
    HMODULE Module
    );
]]

ffi.cdef[[
//
// typedefs for function pointers
//
typedef BOOL
( *PSYM_ENUMMODULES_CALLBACK64)(
    PCSTR ModuleName,
    DWORD64 BaseOfDll,
    PVOID UserContext
    );

typedef BOOL
( *PSYM_ENUMMODULES_CALLBACKW64)(
    PCWSTR ModuleName,
    DWORD64 BaseOfDll,
    PVOID UserContext
    );

typedef BOOL
( *PENUMLOADED_MODULES_CALLBACK64)(
    PCSTR ModuleName,
    DWORD64 ModuleBase,
    ULONG ModuleSize,
    PVOID UserContext
    );

typedef BOOL
( *PENUMLOADED_MODULES_CALLBACKW64)(
    PCWSTR ModuleName,
    DWORD64 ModuleBase,
    ULONG ModuleSize,
    PVOID UserContext
    );

typedef BOOL
( *PSYM_ENUMSYMBOLS_CALLBACK64)(
    PCSTR SymbolName,
    DWORD64 SymbolAddress,
    ULONG SymbolSize,
    PVOID UserContext
    );

typedef BOOL
( *PSYM_ENUMSYMBOLS_CALLBACK64W)(
    PCWSTR SymbolName,
    DWORD64 SymbolAddress,
    ULONG SymbolSize,
    PVOID UserContext
    );

typedef BOOL
( *PSYMBOL_REGISTERED_CALLBACK64)(
    HANDLE hProcess,
    ULONG ActionCode,
    ULONG64 CallbackData,
    ULONG64 UserContext
    );

typedef
PVOID
( *PSYMBOL_FUNCENTRY_CALLBACK)(
    HANDLE hProcess,
    DWORD AddrBase,
    PVOID UserContext
    );

typedef
PVOID
( *PSYMBOL_FUNCENTRY_CALLBACK64)(
    HANDLE hProcess,
    ULONG64 AddrBase,
    ULONG64 UserContext
    );
]]


if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then

PSYM_ENUMMODULES_CALLBACK = ffi.typeof("PSYM_ENUMMODULES_CALLBACK64");
PSYM_ENUMSYMBOLS_CALLBACK = ffi.typeof("PSYM_ENUMSYMBOLS_CALLBACK64");
PSYM_ENUMSYMBOLS_CALLBACKW = ffi.typeof("PSYM_ENUMSYMBOLS_CALLBACK64W");
PENUMLOADED_MODULES_CALLBACK = ffi.typeof("PENUMLOADED_MODULES_CALLBACK64");
PSYMBOL_REGISTERED_CALLBACK = ffi.typeof("PSYMBOL_REGISTERED_CALLBACK64");
PSYMBOL_FUNCENTRY_CALLBACK = ffi.typeof("PSYMBOL_FUNCENTRY_CALLBACK64");

else
ffi.cdef[[
typedef BOOL
( *PSYM_ENUMMODULES_CALLBACK)(
    PCSTR ModuleName,
    ULONG BaseOfDll,
    PVOID UserContext
    );

typedef BOOL
( *PSYM_ENUMSYMBOLS_CALLBACK)(
    PCSTR SymbolName,
    ULONG SymbolAddress,
    ULONG SymbolSize,
    PVOID UserContext
    );

typedef BOOL
( *PSYM_ENUMSYMBOLS_CALLBACKW)(
    PCWSTR SymbolName,
    ULONG SymbolAddress,
    ULONG SymbolSize,
    PVOID UserContext
    );

typedef BOOL
( *PENUMLOADED_MODULES_CALLBACK)(
    PCSTR ModuleName,
    ULONG ModuleBase,
    ULONG ModuleSize,
    PVOID UserContext
    );

typedef BOOL
( *PSYMBOL_REGISTERED_CALLBACK)(
    HANDLE hProcess,
    ULONG ActionCode,
    PVOID CallbackData,
    PVOID UserContext
    );
]]
end

--[[
// values found in SYMBOL_INFO.Tag
//
// This was taken from cvconst.h and should
// not override any values found there.
//
// #define _NO_CVCONST_H_ if you don't
// have access to that file...
--]]

if _NO_CVCONST_H then
ffi.cdef[[
// DIA enums

enum SymTagEnum
{
    SymTagNull,
    SymTagExe,
    SymTagCompiland,
    SymTagCompilandDetails,
    SymTagCompilandEnv,
    SymTagFunction,
    SymTagBlock,
    SymTagData,
    SymTagAnnotation,
    SymTagLabel,
    SymTagPublicSymbol,
    SymTagUDT,
    SymTagEnum,
    SymTagFunctionType,
    SymTagPointerType,
    SymTagArrayType,
    SymTagBaseType,
    SymTagTypedef,
    SymTagBaseClass,
    SymTagFriend,
    SymTagFunctionArgType,
    SymTagFuncDebugStart,
    SymTagFuncDebugEnd,
    SymTagUsingNamespace,
    SymTagVTableShape,
    SymTagVTable,
    SymTagCustom,
    SymTagThunk,
    SymTagCustomType,
    SymTagManagedType,
    SymTagDimension,
    SymTagMax
};
]]
end

ffi.cdef[[
//
// flags found in SYMBOL_INFO.Flags
//

static const int SYMFLAG_VALUEPRESENT     = 0x00000001;
static const int SYMFLAG_REGISTER         = 0x00000008;
static const int SYMFLAG_REGREL           = 0x00000010;
static const int SYMFLAG_FRAMEREL         = 0x00000020;
static const int SYMFLAG_PARAMETER        = 0x00000040;
static const int SYMFLAG_LOCAL            = 0x00000080;
static const int SYMFLAG_CONSTANT         = 0x00000100;
static const int SYMFLAG_EXPORT           = 0x00000200;
static const int SYMFLAG_FORWARDER        = 0x00000400;
static const int SYMFLAG_FUNCTION         = 0x00000800;
static const int SYMFLAG_VIRTUAL          = 0x00001000;
static const int SYMFLAG_THUNK            = 0x00002000;
static const int SYMFLAG_TLSREL           = 0x00004000;
static const int SYMFLAG_SLOT             = 0x00008000;
static const int SYMFLAG_ILREL            = 0x00010000;
static const int SYMFLAG_METADATA         = 0x00020000;
static const int SYMFLAG_CLR_TOKEN        = 0x00040000;

// this resets SymNext/Prev to the beginning
// of the module passed in the address field

static const int SYMFLAG_RESET            = 0x80000000;
]]

ffi.cdef[[
//
// symbol type enumeration
//
typedef enum {
    SymNone = 0,
    SymCoff,
    SymCv,
    SymPdb,
    SymExport,
    SymDeferred,
    SymSym,       // .sym file
    SymDia,
    SymVirtual,
    NumSymTypes
} SYM_TYPE;
]]

ffi.cdef[[
//
// symbol data structure
//

typedef struct _IMAGEHLP_SYMBOL64 {
    DWORD   SizeOfStruct;           // set to sizeof(IMAGEHLP_SYMBOL64)
    DWORD64 Address;                // virtual address including dll base address
    DWORD   Size;                   // estimated size of symbol, can be zero
    DWORD   Flags;                  // info about the symbols, see the SYMF defines
    DWORD   MaxNameLength;          // maximum size of symbol name in 'Name'
    CHAR    Name[1];                // symbol name (null terminated string)
} IMAGEHLP_SYMBOL64, *PIMAGEHLP_SYMBOL64;

typedef struct _IMAGEHLP_SYMBOL64_PACKAGE {
    IMAGEHLP_SYMBOL64 sym;
    CHAR              name[MAX_SYM_NAME + 1];
} IMAGEHLP_SYMBOL64_PACKAGE, *PIMAGEHLP_SYMBOL64_PACKAGE;

typedef struct _IMAGEHLP_SYMBOLW64 {
    DWORD   SizeOfStruct;           // set to sizeof(IMAGEHLP_SYMBOLW64)
    DWORD64 Address;                // virtual address including dll base address
    DWORD   Size;                   // estimated size of symbol, can be zero
    DWORD   Flags;                  // info about the symbols, see the SYMF defines
    DWORD   MaxNameLength;          // maximum size of symbol name in 'Name'
    WCHAR   Name[1];                // symbol name (null terminated string)
} IMAGEHLP_SYMBOLW64, *PIMAGEHLP_SYMBOLW64;

typedef struct _IMAGEHLP_SYMBOLW64_PACKAGE {
    IMAGEHLP_SYMBOLW64 sym;
    WCHAR              name[MAX_SYM_NAME + 1];
} IMAGEHLP_SYMBOLW64_PACKAGE, *PIMAGEHLP_SYMBOLW64_PACKAGE;
]]


if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then

IMAGEHLP_SYMBOL = ffi.typeof("IMAGEHLP_SYMBOL64");
PIMAGEHLP_SYMBOL = ffi.typeof("PIMAGEHLP_SYMBOL64");
IMAGEHLP_SYMBOL_PACKAGE = ffi.typeof("IMAGEHLP_SYMBOL64_PACKAGE");
PIMAGEHLP_SYMBOL_PACKAGE = ffi.typeof("PIMAGEHLP_SYMBOL64_PACKAGE");
IMAGEHLP_SYMBOLW = ffi.typeof("IMAGEHLP_SYMBOLW64");
PIMAGEHLP_SYMBOLW = ffi.typeof("PIMAGEHLP_SYMBOLW64");
IMAGEHLP_SYMBOLW_PACKAGE = ffi.typeof("IMAGEHLP_SYMBOLW64_PACKAGE");
PIMAGEHLP_SYMBOLW_PACKAGE = ffi.typeof("PIMAGEHLP_SYMBOLW64_PACKAGE");

else
ffi.cdef[[
 typedef struct _IMAGEHLP_SYMBOL {
     DWORD SizeOfStruct;           // set to sizeof(IMAGEHLP_SYMBOL)
     DWORD Address;                // virtual address including dll base address
     DWORD Size;                   // estimated size of symbol, can be zero
     DWORD Flags;                  // info about the symbols, see the SYMF defines
     DWORD                       MaxNameLength;          // maximum size of symbol name in 'Name'
     CHAR                        Name[1];                // symbol name (null terminated string)
 } IMAGEHLP_SYMBOL, *PIMAGEHLP_SYMBOL;

 typedef struct _IMAGEHLP_SYMBOL_PACKAGE {
     IMAGEHLP_SYMBOL sym;
     CHAR            name[MAX_SYM_NAME + 1];
 } IMAGEHLP_SYMBOL_PACKAGE, *PIMAGEHLP_SYMBOL_PACKAGE;

 typedef struct _IMAGEHLP_SYMBOLW {
     DWORD SizeOfStruct;           // set to sizeof(IMAGEHLP_SYMBOLW)
     DWORD Address;                // virtual address including dll base address
     DWORD Size;                   // estimated size of symbol, can be zero
     DWORD Flags;                  // info about the symbols, see the SYMF defines
     DWORD                       MaxNameLength;          // maximum size of symbol name in 'Name'
     WCHAR                       Name[1];                // symbol name (null terminated string)
 } IMAGEHLP_SYMBOLW, *PIMAGEHLP_SYMBOLW;

 typedef struct _IMAGEHLP_SYMBOLW_PACKAGE {
     IMAGEHLP_SYMBOLW sym;
     WCHAR            name[MAX_SYM_NAME + 1];
 } IMAGEHLP_SYMBOLW_PACKAGE, *PIMAGEHLP_SYMBOLW_PACKAGE;
]]
end

ffi.cdef[[
//
// module data structure
//

typedef struct _IMAGEHLP_MODULE64 {
    DWORD    SizeOfStruct;           // set to sizeof(IMAGEHLP_MODULE64)
    DWORD64  BaseOfImage;            // base load address of module
    DWORD    ImageSize;              // virtual size of the loaded module
    DWORD    TimeDateStamp;          // date/time stamp from pe header
    DWORD    CheckSum;               // checksum from the pe header
    DWORD    NumSyms;                // number of symbols in the symbol table
    SYM_TYPE SymType;                // type of symbols loaded
    CHAR     ModuleName[32];         // module name
    CHAR     ImageName[256];         // image name
    CHAR     LoadedImageName[256];   // symbol file name
    // new elements: 07-Jun-2002
    CHAR     LoadedPdbName[256];     // pdb file name
    DWORD    CVSig;                  // Signature of the CV record in the debug directories
    CHAR     CVData[MAX_PATH * 3];   // Contents of the CV record
    DWORD    PdbSig;                 // Signature of PDB
    GUID     PdbSig70;               // Signature of PDB (VC 7 and up)
    DWORD    PdbAge;                 // DBI age of pdb
    BOOL     PdbUnmatched;           // loaded an unmatched pdb
    BOOL     DbgUnmatched;           // loaded an unmatched dbg
    BOOL     LineNumbers;            // we have line number information
    BOOL     GlobalSymbols;          // we have internal symbol information
    BOOL     TypeInfo;               // we have type information
    // new elements: 17-Dec-2003
    BOOL     SourceIndexed;          // pdb supports source server
    BOOL     Publics;                // contains public symbols
} IMAGEHLP_MODULE64, *PIMAGEHLP_MODULE64;

typedef struct _IMAGEHLP_MODULEW64 {
    DWORD    SizeOfStruct;           // set to sizeof(IMAGEHLP_MODULE64)
    DWORD64  BaseOfImage;            // base load address of module
    DWORD    ImageSize;              // virtual size of the loaded module
    DWORD    TimeDateStamp;          // date/time stamp from pe header
    DWORD    CheckSum;               // checksum from the pe header
    DWORD    NumSyms;                // number of symbols in the symbol table
    SYM_TYPE SymType;                // type of symbols loaded
    WCHAR    ModuleName[32];         // module name
    WCHAR    ImageName[256];         // image name
    // new elements: 07-Jun-2002
    WCHAR    LoadedImageName[256];   // symbol file name
    WCHAR    LoadedPdbName[256];     // pdb file name
    DWORD    CVSig;                  // Signature of the CV record in the debug directories
    WCHAR        CVData[MAX_PATH * 3];   // Contents of the CV record
    DWORD    PdbSig;                 // Signature of PDB
    GUID     PdbSig70;               // Signature of PDB (VC 7 and up)
    DWORD    PdbAge;                 // DBI age of pdb
    BOOL     PdbUnmatched;           // loaded an unmatched pdb
    BOOL     DbgUnmatched;           // loaded an unmatched dbg
    BOOL     LineNumbers;            // we have line number information
    BOOL     GlobalSymbols;          // we have internal symbol information
    BOOL     TypeInfo;               // we have type information
    // new elements: 17-Dec-2003
    BOOL     SourceIndexed;          // pdb supports source server
    BOOL     Publics;                // contains public symbols
} IMAGEHLP_MODULEW64, *PIMAGEHLP_MODULEW64;
]]


if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
IMAGEHLP_MODULE = ffi.typeof("IMAGEHLP_MODULE64");
PIMAGEHLP_MODULE = ffi.typeof("PIMAGEHLP_MODULE64");
IMAGEHLP_MODULEW = ffi.typeof("IMAGEHLP_MODULEW64");
PIMAGEHLP_MODULEW = ffi.typeof("PIMAGEHLP_MODULEW64");
else
ffi.cdef[[
typedef struct _IMAGEHLP_MODULE {
    DWORD    SizeOfStruct;           // set to sizeof(IMAGEHLP_MODULE)
    DWORD    BaseOfImage;            // base load address of module
    DWORD    ImageSize;              // virtual size of the loaded module
    DWORD    TimeDateStamp;          // date/time stamp from pe header
    DWORD    CheckSum;               // checksum from the pe header
    DWORD    NumSyms;                // number of symbols in the symbol table
    SYM_TYPE SymType;                // type of symbols loaded
    CHAR     ModuleName[32];         // module name
    CHAR     ImageName[256];         // image name
    CHAR     LoadedImageName[256];   // symbol file name
} IMAGEHLP_MODULE, *PIMAGEHLP_MODULE;

typedef struct _IMAGEHLP_MODULEW {
    DWORD    SizeOfStruct;           // set to sizeof(IMAGEHLP_MODULE)
    DWORD    BaseOfImage;            // base load address of module
    DWORD    ImageSize;              // virtual size of the loaded module
    DWORD    TimeDateStamp;          // date/time stamp from pe header
    DWORD    CheckSum;               // checksum from the pe header
    DWORD    NumSyms;                // number of symbols in the symbol table
    SYM_TYPE SymType;                // type of symbols loaded
    WCHAR    ModuleName[32];         // module name
    WCHAR    ImageName[256];         // image name
    WCHAR    LoadedImageName[256];   // symbol file name
} IMAGEHLP_MODULEW, *PIMAGEHLP_MODULEW;
]]
end

ffi.cdef[[
//
// source file line data structure
//

typedef struct _IMAGEHLP_LINE64 {
    DWORD    SizeOfStruct;           // set to sizeof(IMAGEHLP_LINE64)
    PVOID    Key;                    // internal
    DWORD    LineNumber;             // line number in file
    PCHAR    FileName;               // full filename
    DWORD64  Address;                // first instruction of line
} IMAGEHLP_LINE64, *PIMAGEHLP_LINE64;

typedef struct _IMAGEHLP_LINEW64 {
    DWORD    SizeOfStruct;           // set to sizeof(IMAGEHLP_LINE64)
    PVOID    Key;                    // internal
    DWORD    LineNumber;             // line number in file
    PWSTR    FileName;               // full filename
    DWORD64  Address;                // first instruction of line
} IMAGEHLP_LINEW64, *PIMAGEHLP_LINEW64;
]]


if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
IMAGEHLP_LINE = ffi.typeof("IMAGEHLP_LINE64");
PIMAGEHLP_LINE = ffi.typeof("PIMAGEHLP_LINE64");
else
ffi.cdef[[
typedef struct _IMAGEHLP_LINE {
    DWORD    SizeOfStruct;           // set to sizeof(IMAGEHLP_LINE)
    PVOID    Key;                    // internal
    DWORD    LineNumber;             // line number in file
    PCHAR    FileName;               // full filename
    DWORD    Address;                // first instruction of line
} IMAGEHLP_LINE, *PIMAGEHLP_LINE;

typedef struct _IMAGEHLP_LINEW {
    DWORD    SizeOfStruct;           // set to sizeof(IMAGEHLP_LINE64)
    PVOID    Key;                    // internal
    DWORD    LineNumber;             // line number in file
    PCHAR    FileName;               // full filename
    DWORD64  Address;                // first instruction of line
} IMAGEHLP_LINEW, *PIMAGEHLP_LINEW;
]]
end

ffi.cdef[[
//
// source file structure
//

typedef struct _SOURCEFILE {
    DWORD64  ModBase;                // base address of loaded module
    PCHAR    FileName;               // full filename of source
} SOURCEFILE, *PSOURCEFILE;

typedef struct _SOURCEFILEW {
    DWORD64  ModBase;                // base address of loaded module
    PWSTR    FileName;               // full filename of source
} SOURCEFILEW, *PSOURCEFILEW;
]]

ffi.cdef[[
//
// data structures used for registered symbol callbacks
//

static const int CBA_DEFERRED_SYMBOL_LOAD_START          = 0x00000001;
static const int CBA_DEFERRED_SYMBOL_LOAD_COMPLETE       = 0x00000002;
static const int CBA_DEFERRED_SYMBOL_LOAD_FAILURE        = 0x00000003;
static const int CBA_SYMBOLS_UNLOADED                    = 0x00000004;
static const int CBA_DUPLICATE_SYMBOL                    = 0x00000005;
static const int CBA_READ_MEMORY                         = 0x00000006;
static const int CBA_DEFERRED_SYMBOL_LOAD_CANCEL         = 0x00000007;
static const int CBA_SET_OPTIONS                         = 0x00000008;
static const int CBA_EVENT                               = 0x00000010;
static const int CBA_DEFERRED_SYMBOL_LOAD_PARTIAL        = 0x00000020;
static const int CBA_DEBUG_INFO                          = 0x10000000;
static const int CBA_SRCSRV_INFO                         = 0x20000000;
static const int CBA_SRCSRV_EVENT                        = 0x40000000;
]]

ffi.cdef[[
typedef struct _IMAGEHLP_CBA_READ_MEMORY {
    DWORD64   addr;                                     // address to read from
    PVOID     buf;                                      // buffer to read to
    DWORD     bytes;                                    // amount of bytes to read
    DWORD    *bytesread;                                // pointer to store amount of bytes read
} IMAGEHLP_CBA_READ_MEMORY, *PIMAGEHLP_CBA_READ_MEMORY;
]]

ffi.cdef[[
enum {
    sevInfo = 0,
    sevProblem,
    sevAttn,
    sevFatal,
    sevMax  // unused
};

static const int EVENT_SRCSPEW_START = 100;
static const int EVENT_SRCSPEW       = 100;
static const int EVENT_SRCSPEW_END   = 199;
]]

ffi.cdef[[
typedef struct _IMAGEHLP_CBA_EVENT {
    DWORD severity;                                     // values from sevInfo to sevFatal
    DWORD code;                                         // numerical code IDs the error
    PCHAR desc;                                         // may contain a text description of the error
    PVOID object;                                       // value dependant upon the error code
} IMAGEHLP_CBA_EVENT, *PIMAGEHLP_CBA_EVENT;

typedef struct _IMAGEHLP_CBA_EVENTW {
    DWORD  severity;                                     // values from sevInfo to sevFatal
    DWORD  code;                                         // numerical code IDs the error
    PCWSTR desc;                                         // may contain a text description of the error
    PVOID  object;                                       // value dependant upon the error code
} IMAGEHLP_CBA_EVENTW, *PIMAGEHLP_CBA_EVENTW;

typedef struct _IMAGEHLP_DEFERRED_SYMBOL_LOAD64 {
    DWORD    SizeOfStruct;           // set to sizeof(IMAGEHLP_DEFERRED_SYMBOL_LOAD64)
    DWORD64  BaseOfImage;            // base load address of module
    DWORD    CheckSum;               // checksum from the pe header
    DWORD    TimeDateStamp;          // date/time stamp from pe header
    CHAR     FileName[MAX_PATH];     // symbols file or image name
    BOOLEAN  Reparse;                // load failure reparse
    HANDLE   hFile;                  // file handle, if passed
    DWORD    Flags;                     //
} IMAGEHLP_DEFERRED_SYMBOL_LOAD64, *PIMAGEHLP_DEFERRED_SYMBOL_LOAD64;

typedef struct _IMAGEHLP_DEFERRED_SYMBOL_LOADW64 {
    DWORD    SizeOfStruct;           // set to sizeof(IMAGEHLP_DEFERRED_SYMBOL_LOADW64)
    DWORD64  BaseOfImage;            // base load address of module
    DWORD    CheckSum;               // checksum from the pe header
    DWORD    TimeDateStamp;          // date/time stamp from pe header
    WCHAR    FileName[MAX_PATH + 1]; // symbols file or image name
    BOOLEAN  Reparse;                // load failure reparse
    HANDLE   hFile;                  // file handle, if passed
    DWORD    Flags;         //
} IMAGEHLP_DEFERRED_SYMBOL_LOADW64, *PIMAGEHLP_DEFERRED_SYMBOL_LOADW64;
]]

ffi.cdef[[
static const int DSLFLAG_MISMATCHED_PDB  = 0x1;
static const int DSLFLAG_MISMATCHED_DBG  = 0x2;
]]


if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
IMAGEHLP_DEFERRED_SYMBOL_LOAD = ffi.typeof("IMAGEHLP_DEFERRED_SYMBOL_LOAD64");
PIMAGEHLP_DEFERRED_SYMBOL_LOAD = ffi.typeof("PIMAGEHLP_DEFERRED_SYMBOL_LOAD64");
else
ffi.cdef[[
typedef struct _IMAGEHLP_DEFERRED_SYMBOL_LOAD {
    DWORD    SizeOfStruct;           // set to sizeof(IMAGEHLP_DEFERRED_SYMBOL_LOAD)
    DWORD    BaseOfImage;            // base load address of module
    DWORD    CheckSum;               // checksum from the pe header
    DWORD    TimeDateStamp;          // date/time stamp from pe header
    CHAR     FileName[MAX_PATH];     // symbols file or image name
    BOOLEAN  Reparse;                // load failure reparse
    HANDLE   hFile;                  // file handle, if passed
} IMAGEHLP_DEFERRED_SYMBOL_LOAD, *PIMAGEHLP_DEFERRED_SYMBOL_LOAD;
]]
end

ffi.cdef[[
typedef struct _IMAGEHLP_DUPLICATE_SYMBOL64 {
    DWORD              SizeOfStruct;           // set to sizeof(IMAGEHLP_DUPLICATE_SYMBOL64)
    DWORD              NumberOfDups;           // number of duplicates in the Symbol array
    PIMAGEHLP_SYMBOL64 Symbol;                 // array of duplicate symbols
    DWORD              SelectedSymbol;         // symbol selected (-1 to start)
} IMAGEHLP_DUPLICATE_SYMBOL64, *PIMAGEHLP_DUPLICATE_SYMBOL64;
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
IMAGEHLP_DUPLICATE_SYMBOL = ffi.typeof("IMAGEHLP_DUPLICATE_SYMBOL64");
PIMAGEHLP_DUPLICATE_SYMBOL = ffi.typeof("PIMAGEHLP_DUPLICATE_SYMBOL64");
else
ffi.cdef[[
typedef struct _IMAGEHLP_DUPLICATE_SYMBOL {
    DWORD            SizeOfStruct;           // set to sizeof(IMAGEHLP_DUPLICATE_SYMBOL)
    DWORD            NumberOfDups;           // number of duplicates in the Symbol array
    PIMAGEHLP_SYMBOL Symbol;                 // array of duplicate symbols
    DWORD            SelectedSymbol;         // symbol selected (-1 to start)
} IMAGEHLP_DUPLICATE_SYMBOL, *PIMAGEHLP_DUPLICATE_SYMBOL;
]]
end

ffi.cdef[[
// If dbghelp ever needs to display graphical UI, it will use this as the parent window.

BOOL
SymSetParentWindow(
    HWND hwnd
    );
]]

ffi.cdef[[
PCHAR
SymSetHomeDirectory(
    HANDLE hProcess,
    PCSTR dir
    );

PWSTR
SymSetHomeDirectoryW(
    HANDLE hProcess,
    PCWSTR dir
    );

PCHAR
SymGetHomeDirectory(
    DWORD type,
    PSTR dir,
    size_t size
    );

PWSTR
SymGetHomeDirectoryW(
    DWORD type,
    PWSTR dir,
    size_t size
    );
]]

ffi.cdef[[
typedef enum {
    hdBase = 0, // root directory for dbghelp
    hdSym,      // where symbols are stored
    hdSrc,      // where source is stored
    hdMax       // end marker
};
]]

ffi.cdef[[
typedef struct _OMAP {
    ULONG  rva;
    ULONG  rvaTo;
} OMAP, *POMAP;

BOOL
SymGetOmaps(
    HANDLE hProcess,
    DWORD64 BaseOfDll,
    POMAP *OmapTo,
    PDWORD64 cOmapTo,
    POMAP *OmapFrom,
    PDWORD64 cOmapFrom
    );
]]

ffi.cdef[[
//
// options that are set/returned by SymSetOptions() & SymGetOptions()
// these are used as a mask
//
static const int SYMOPT_CASE_INSENSITIVE          = 0x00000001;
static const int SYMOPT_UNDNAME                   = 0x00000002;
static const int SYMOPT_DEFERRED_LOADS            = 0x00000004;
static const int SYMOPT_NO_CPP                    = 0x00000008;
static const int SYMOPT_LOAD_LINES                = 0x00000010;
static const int SYMOPT_OMAP_FIND_NEAREST         = 0x00000020;
static const int SYMOPT_LOAD_ANYTHING             = 0x00000040;
static const int SYMOPT_IGNORE_CVREC              = 0x00000080;
static const int SYMOPT_NO_UNQUALIFIED_LOADS      = 0x00000100;
static const int SYMOPT_FAIL_CRITICAL_ERRORS      = 0x00000200;
static const int SYMOPT_EXACT_SYMBOLS             = 0x00000400;
static const int SYMOPT_ALLOW_ABSOLUTE_SYMBOLS    = 0x00000800;
static const int SYMOPT_IGNORE_NT_SYMPATH         = 0x00001000;
static const int SYMOPT_INCLUDE_32BIT_MODULES     = 0x00002000;
static const int SYMOPT_PUBLICS_ONLY              = 0x00004000;
static const int SYMOPT_NO_PUBLICS                = 0x00008000;
static const int SYMOPT_AUTO_PUBLICS              = 0x00010000;
static const int SYMOPT_NO_IMAGE_SEARCH           = 0x00020000;
static const int SYMOPT_SECURE                    = 0x00040000;
static const int SYMOPT_NO_PROMPTS                = 0x00080000;
static const int SYMOPT_OVERWRITE                 = 0x00100000;
static const int SYMOPT_IGNORE_IMAGEDIR           = 0x00200000;
static const int SYMOPT_FLAT_DIRECTORY            = 0x00400000;
static const int SYMOPT_FAVOR_COMPRESSED          = 0x00800000;
static const int SYMOPT_ALLOW_ZERO_ADDRESS        = 0x01000000;
static const int SYMOPT_DISABLE_SYMSRV_AUTODETECT = 0x02000000;

static const int SYMOPT_DEBUG                     = 0x80000000;
]]

ffi.cdef[[
DWORD
SymSetOptions(DWORD   SymOptions);

DWORD
SymGetOptions(void);
]]

ffi.cdef[[
BOOL
SymCleanup(HANDLE hProcess);
]]

ffi.cdef[[
BOOL
SymMatchString(
    PCSTR string,
    PCSTR expression,
    BOOL fCase
    );

BOOL
SymMatchStringA(
    PCSTR string,
    PCSTR expression,
    BOOL fCase
    );

BOOL
SymMatchStringW(
    PCWSTR string,
    PCWSTR expression,
    BOOL fCase
    );
]]

ffi.cdef[[
typedef BOOL
( *PSYM_ENUMSOURCEFILES_CALLBACK)(
    PSOURCEFILE pSourceFile,
    PVOID UserContext
    );
]]

ffi.cdef[[
BOOL
SymEnumSourceFiles(
    HANDLE hProcess,
    ULONG64 ModBase,
    PCSTR Mask,
    PSYM_ENUMSOURCEFILES_CALLBACK cbSrcFiles,
    PVOID UserContext
    );

typedef BOOL
( *PSYM_ENUMSOURCEFILES_CALLBACKW)(
    PSOURCEFILEW pSourceFile,
    PVOID UserContext
    );

BOOL
SymEnumSourceFilesW(
    HANDLE hProcess,
    ULONG64 ModBase,
    PCWSTR Mask,
    PSYM_ENUMSOURCEFILES_CALLBACKW cbSrcFiles,
    PVOID UserContext
    );
]]

ffi.cdef[[
BOOL
SymEnumerateModules64(
    HANDLE hProcess,
    PSYM_ENUMMODULES_CALLBACK64 EnumModulesCallback,
    PVOID UserContext
    );

BOOL
SymEnumerateModulesW64(
    HANDLE hProcess,
    PSYM_ENUMMODULES_CALLBACKW64 EnumModulesCallback,
    PVOID UserContext
    );
]]


if not _IMAGEHLP_SOURCE and _IMAGEHLP64 then
SymEnumerateModules = Lib.SymEnumerateModules64;
else
ffi.cdef[[
BOOL
SymEnumerateModules(
    HANDLE hProcess,
    PSYM_ENUMMODULES_CALLBACK EnumModulesCallback,
    PVOID UserContext
    );
]]
end

ffi.cdef[[
BOOL
EnumerateLoadedModulesEx(
    HANDLE hProcess,
    PENUMLOADED_MODULES_CALLBACK64 EnumLoadedModulesCallback,
    PVOID UserContext
    );
    
BOOL
EnumerateLoadedModulesExW(
    HANDLE hProcess,
    PENUMLOADED_MODULES_CALLBACKW64 EnumLoadedModulesCallback,
    PVOID UserContext
    );

BOOL
EnumerateLoadedModules64(
    HANDLE hProcess,
    PENUMLOADED_MODULES_CALLBACK64 EnumLoadedModulesCallback,
    PVOID UserContext
    );

BOOL
EnumerateLoadedModulesW64(
    HANDLE hProcess,
    PENUMLOADED_MODULES_CALLBACKW64 EnumLoadedModulesCallback,
    PVOID UserContext
    );
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
EnumerateLoadedModules = Lib.EnumerateLoadedModules64;
else
ffi.cdef[[
BOOL
EnumerateLoadedModules(
    HANDLE hProcess,
    PENUMLOADED_MODULES_CALLBACK EnumLoadedModulesCallback,
    PVOID UserContext
    );
]]
end

ffi.cdef[[
PVOID
SymFunctionTableAccess64(
    HANDLE hProcess,
    DWORD64 AddrBase
    );
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymFunctionTableAccess = Lib.SymFunctionTableAccess64;
else
ffi.cdef[[
PVOID
SymFunctionTableAccess(
    HANDLE hProcess,
    DWORD AddrBase
    );
]]
end

ffi.cdef[[
BOOL
SymGetUnwindInfo(
    HANDLE hProcess,
    DWORD64 Address,
    PVOID Buffer,
    PULONG Size
    );

BOOL
SymGetModuleInfo64(
    HANDLE hProcess,
    DWORD64 qwAddr,
    PIMAGEHLP_MODULE64 ModuleInfo
    );

BOOL
SymGetModuleInfoW64(
    HANDLE hProcess,
    DWORD64 qwAddr,
    PIMAGEHLP_MODULEW64 ModuleInfo
    );
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymGetModuleInfo   = Lib.SymGetModuleInfo64;
SymGetModuleInfoW  = Lib.SymGetModuleInfoW64;
else
ffi.cdef[[
BOOL
SymGetModuleInfo(
    HANDLE hProcess,
    DWORD dwAddr,
    PIMAGEHLP_MODULE ModuleInfo
    );

BOOL
SymGetModuleInfoW(
    HANDLE hProcess,
    DWORD dwAddr,
    PIMAGEHLP_MODULEW ModuleInfo
    );
]]
end

ffi.cdef[[
DWORD64
SymGetModuleBase64(
    HANDLE hProcess,
    DWORD64 qwAddr
    );
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymGetModuleBase = Lib.SymGetModuleBase64;
else
ffi.cdef[[
DWORD
SymGetModuleBase(
    HANDLE hProcess,
    DWORD dwAddr
    );
]]
end

ffi.cdef[[
typedef struct _SRCCODEINFO {
    DWORD   SizeOfStruct;           // set to sizeof(SRCCODEINFO)
    PVOID   Key;                    // not used
    DWORD64 ModBase;                // base address of module this applies to
    CHAR    Obj[MAX_PATH + 1];      // the object file within the module
    CHAR    FileName[MAX_PATH + 1]; // full filename
    DWORD   LineNumber;             // line number in file
    DWORD64 Address;                // first instruction of line
} SRCCODEINFO, *PSRCCODEINFO;

typedef struct _SRCCODEINFOW {
    DWORD   SizeOfStruct;           // set to sizeof(SRCCODEINFO)
    PVOID   Key;                    // not used
    DWORD64 ModBase;                // base address of module this applies to
    WCHAR   Obj[MAX_PATH + 1];      // the object file within the module
    WCHAR   FileName[MAX_PATH + 1]; // full filename
    DWORD   LineNumber;             // line number in file
    DWORD64 Address;                // first instruction of line
} SRCCODEINFOW, *PSRCCODEINFOW;

typedef BOOL
( *PSYM_ENUMLINES_CALLBACK)(
    PSRCCODEINFO LineInfo,
    PVOID UserContext
    );

BOOL
SymEnumLines(
    HANDLE hProcess,
    ULONG64 Base,
    PCSTR Obj,
    PCSTR File,
    PSYM_ENUMLINES_CALLBACK EnumLinesCallback,
    PVOID UserContext
    );

typedef BOOL
( *PSYM_ENUMLINES_CALLBACKW)(
    PSRCCODEINFOW LineInfo,
    PVOID UserContext
    );

BOOL
SymEnumLinesW(
    HANDLE hProcess,
    ULONG64 Base,
    PCWSTR Obj,
    PCWSTR File,
    PSYM_ENUMLINES_CALLBACKW EnumLinesCallback,
    PVOID UserContext
    );
]]

ffi.cdef[[
BOOL
SymGetLineFromAddr64(
    HANDLE hProcess,
    DWORD64 qwAddr,
    PDWORD pdwDisplacement,
    PIMAGEHLP_LINE64 Line64
    );

BOOL
SymGetLineFromAddrW64(
    HANDLE hProcess,
    DWORD64 dwAddr,
    PDWORD pdwDisplacement,
    PIMAGEHLP_LINEW64 Line
    );
]]

ffi.cdef[[
BOOL
SymEnumSourceLines(
    HANDLE hProcess,
    ULONG64 Base,
    PCSTR Obj,
    PCSTR File,
    DWORD Line,
    DWORD Flags,
    PSYM_ENUMLINES_CALLBACK EnumLinesCallback,
    PVOID UserContext
    );

BOOL
SymEnumSourceLinesW(
    HANDLE hProcess,
    ULONG64 Base,
    PCWSTR Obj,
    PCWSTR File,
    DWORD Line,
    DWORD Flags,
    PSYM_ENUMLINES_CALLBACKW EnumLinesCallback,
    PVOID UserContext
    );
]]

ffi.cdef[[
// flags for SymEnumSourceLines

static const int ESLFLAG_FULLPATH       = 0x1;
static const int ESLFLAG_NEAREST        = 0x2;
static const int ESLFLAG_PREV           = 0x4;
static const int ESLFLAG_NEXT           = 0x8;
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymGetLineFromAddr = Lib.SymGetLineFromAddr64;
SymGetLineFromAddrW = Lib.SymGetLineFromAddrW64;
else
ffi.cdef[[
BOOL
SymGetLineFromAddr(
    HANDLE hProcess,
    DWORD dwAddr,
    PDWORD pdwDisplacement,
    PIMAGEHLP_LINE Line
    );

BOOL
SymGetLineFromAddrW(
    HANDLE hProcess,
    DWORD dwAddr,
    PDWORD pdwDisplacement,
    PIMAGEHLP_LINEW Line
    );
]]
end

ffi.cdef[[
BOOL
SymGetLineFromName64(
    HANDLE hProcess,
    PCSTR ModuleName,
    PCSTR FileName,
    DWORD dwLineNumber,
    PLONG plDisplacement,
    PIMAGEHLP_LINE64 Line
    );

BOOL
SymGetLineFromNameW64(
    HANDLE hProcess,
    PCWSTR ModuleName,
    PCWSTR FileName,
    DWORD dwLineNumber,
    PLONG plDisplacement,
    PIMAGEHLP_LINEW64 Line
    );
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymGetLineFromName = Lib.SymGetLineFromName64;
else
ffi.cdef[[
BOOL
SymGetLineFromName(
    HANDLE hProcess,
    PCSTR ModuleName,
    PCSTR FileName,
    DWORD dwLineNumber,
    PLONG plDisplacement,
    PIMAGEHLP_LINE Line
    );
]]
end

ffi.cdef[[
BOOL
SymGetLineNext64(
    HANDLE hProcess,
    PIMAGEHLP_LINE64 Line
    );

BOOL
SymGetLineNextW64(
    HANDLE hProcess,
    PIMAGEHLP_LINEW64 Line
    );
]]


if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymGetLineNext = Lib.SymGetLineNext64;
else
ffi.cdef[[
BOOL
SymGetLineNext(
    HANDLE hProcess,
    PIMAGEHLP_LINE Line
    );

BOOL
SymGetLineNextW(
    HANDLE hProcess,
    PIMAGEHLP_LINEW Line
    );
]]
end

ffi.cdef[[
BOOL
SymGetLinePrev64(
    HANDLE hProcess,
    PIMAGEHLP_LINE64 Line
    );

BOOL
SymGetLinePrevW64(
    HANDLE hProcess,
    PIMAGEHLP_LINEW64 Line
    );
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymGetLinePrev = Lib.SymGetLinePrev64;
else
ffi.cdef[[
BOOL
SymGetLinePrev(
    HANDLE hProcess,
    PIMAGEHLP_LINE Line
    );

BOOL
SymGetLinePrevW(
    HANDLE hProcess,
    PIMAGEHLP_LINEW Line
    );
]]
end

ffi.cdef[[
ULONG
SymGetFileLineOffsets64(
    HANDLE hProcess,
    PCSTR ModuleName,
    PCSTR FileName,
    PDWORD64 Buffer,
    ULONG BufferLines
    );
]]

ffi.cdef[[
BOOL
SymMatchFileName(
    PCSTR FileName,
    PCSTR Match,
    PSTR *FileNameStop,
    PSTR *MatchStop
    );

BOOL
SymMatchFileNameW(
    PCWSTR FileName,
    PCWSTR Match,
    PWSTR *FileNameStop,
    PWSTR *MatchStop
    );
]]

ffi.cdef[[
BOOL
SymGetSourceFile(
    HANDLE hProcess,
    ULONG64 Base,
    PCSTR Params,
    PCSTR FileSpec,
    PSTR FilePath,
    DWORD Size
    );

BOOL
SymGetSourceFileW(
    HANDLE hProcess,
    ULONG64 Base,
    PCWSTR Params,
    PCWSTR FileSpec,
    PWSTR FilePath,
    DWORD Size
    );
]]

ffi.cdef[[
BOOL
SymGetSourceFileToken(
    HANDLE hProcess,
    ULONG64 Base,
    PCSTR FileSpec,
    PVOID *Token,
    DWORD *Size
    );

BOOL
SymGetSourceFileTokenW(
    HANDLE hProcess,
    ULONG64 Base,
    PCWSTR FileSpec,
    PVOID *Token,
    DWORD *Size
    );
]]

ffi.cdef[[
BOOL
SymGetSourceFileFromToken(
    HANDLE hProcess,
    PVOID Token,
    PCSTR Params,
    PSTR FilePath,
    DWORD Size
    );

BOOL
SymGetSourceFileFromTokenW(
    HANDLE hProcess,
    PVOID Token,
    PCWSTR Params,
    PWSTR FilePath,
    DWORD Size
    );
]]

ffi.cdef[[
BOOL
SymGetSourceVarFromToken(
    HANDLE hProcess,
    PVOID Token,
    PCSTR Params,
    PCSTR VarName,
    PSTR Value,
    DWORD Size
    );

BOOL
SymGetSourceVarFromTokenW(
    HANDLE hProcess,
    PVOID Token,
    PCWSTR Params,
    PCWSTR VarName,
    PWSTR Value,
    DWORD Size
    );
]]

ffi.cdef[[
typedef BOOL ( *PENUMSOURCEFILETOKENSCALLBACK)(PVOID token,  size_t size);

BOOL
SymEnumSourceFileTokens(
    HANDLE hProcess,
    ULONG64 Base,
    PENUMSOURCEFILETOKENSCALLBACK Callback
    );
]]

ffi.cdef[[
BOOL
SymInitialize(
    HANDLE hProcess,
    PCSTR UserSearchPath,
    BOOL fInvadeProcess
    );

BOOL
SymInitializeW(
    HANDLE hProcess,
    PCWSTR UserSearchPath,
    BOOL fInvadeProcess
    );
]]

ffi.cdef[[
BOOL
SymGetSearchPath(
    HANDLE hProcess,
    PSTR SearchPath,
    DWORD SearchPathLength
    );

BOOL
SymGetSearchPathW(
    HANDLE hProcess,
    PWSTR SearchPath,
    DWORD SearchPathLength
    );

BOOL
SymSetSearchPath(
    HANDLE hProcess,
    PCSTR SearchPath
    );

BOOL
SymSetSearchPathW(
    HANDLE hProcess,
    PCWSTR SearchPath
    );
]]

ffi.cdef[[
static const int SLMFLAG_VIRTUAL      = 0x1;
static const int  SLMFLAG_ALT_INDEX   = 0x2;
static const int  SLMFLAG_NO_SYMBOLS  = 0x4;

DWORD64
SymLoadModuleEx(
    HANDLE hProcess,
    HANDLE hFile,
    PCSTR ImageName,
    PCSTR ModuleName,
    DWORD64 BaseOfDll,
    DWORD DllSize,
    PMODLOAD_DATA Data,
    DWORD Flags
    );

DWORD64
SymLoadModuleExW(
    HANDLE hProcess,
    HANDLE hFile,
    PCWSTR ImageName,
    PCWSTR ModuleName,
    DWORD64 BaseOfDll,
    DWORD DllSize,
    PMODLOAD_DATA Data,
    DWORD Flags
    );

BOOL
SymUnloadModule64(
    HANDLE hProcess,
    DWORD64 BaseOfDll
    );
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymUnloadModule = Lib.SymUnloadModule64;
else
ffi.cdef[[
BOOL
SymUnloadModule(
    HANDLE hProcess,
    DWORD BaseOfDll
    );
]]
end

ffi.cdef[[
BOOL
SymUnDName64(
    PIMAGEHLP_SYMBOL64 sym,            // Symbol to undecorate
    PSTR UnDecName,   // Buffer to store undecorated name in
    DWORD UnDecNameLength              // Size of the buffer
    );
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymUnDName = Lib.SymUnDName64;
else
ffi.cdef[[
BOOL
SymUnDName(
    PIMAGEHLP_SYMBOL sym,              // Symbol to undecorate
    PSTR UnDecName,   // Buffer to store undecorated name in
    DWORD UnDecNameLength              // Size of the buffer
    );
]]
end

ffi.cdef[[
BOOL
SymRegisterCallback64(
    HANDLE hProcess,
    PSYMBOL_REGISTERED_CALLBACK64 CallbackFunction,
    ULONG64 UserContext
    );

BOOL
SymRegisterCallbackW64(
    HANDLE hProcess,
    PSYMBOL_REGISTERED_CALLBACK64 CallbackFunction,
    ULONG64 UserContext
    );

BOOL
SymRegisterFunctionEntryCallback64(
    HANDLE hProcess,
    PSYMBOL_FUNCENTRY_CALLBACK64 CallbackFunction,
    ULONG64 UserContext
    );
]]


if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymRegisterCallback = Lib.SymRegisterCallback64;
SymRegisterFunctionEntryCallback = Lib.SymRegisterFunctionEntryCallback64;
else
ffi.cdef[[
BOOL
SymRegisterCallback(
    HANDLE hProcess,
    PSYMBOL_REGISTERED_CALLBACK CallbackFunction,
    PVOID UserContext
    );

BOOL
SymRegisterFunctionEntryCallback(
    HANDLE hProcess,
    PSYMBOL_FUNCENTRY_CALLBACK CallbackFunction,
    PVOID UserContext
    );
]]
end

ffi.cdef[[
typedef struct _IMAGEHLP_SYMBOL_SRC {
    DWORD sizeofstruct;
    DWORD type;
    char  file[MAX_PATH];
} IMAGEHLP_SYMBOL_SRC, *PIMAGEHLP_SYMBOL_SRC;

typedef struct _MODULE_TYPE_INFO { // AKA TYPTYP
    USHORT      dataLength;
    USHORT      leaf;
    BYTE        data[1];
} MODULE_TYPE_INFO, *PMODULE_TYPE_INFO;

typedef struct _SYMBOL_INFO {
    ULONG       SizeOfStruct;
    ULONG       TypeIndex;        // Type Index of symbol
    ULONG64     Reserved[2];
    ULONG       Index;
    ULONG       Size;
    ULONG64     ModBase;          // Base Address of module comtaining this symbol
    ULONG       Flags;
    ULONG64     Value;            // Value of symbol, ValuePresent should be 1
    ULONG64     Address;          // Address of symbol including base address of module
    ULONG       Register;         // register holding value or pointer to value
    ULONG       Scope;            // scope of the symbol
    ULONG       Tag;              // pdb classification
    ULONG       NameLen;          // Actual length of name
    ULONG       MaxNameLen;
    CHAR        Name[1];          // Name of symbol
} SYMBOL_INFO, *PSYMBOL_INFO;

typedef struct _SYMBOL_INFO_PACKAGE {
    SYMBOL_INFO si;
    CHAR        name[MAX_SYM_NAME + 1];
} SYMBOL_INFO_PACKAGE, *PSYMBOL_INFO_PACKAGE;

typedef struct _SYMBOL_INFOW {
    ULONG       SizeOfStruct;
    ULONG       TypeIndex;        // Type Index of symbol
    ULONG64     Reserved[2];
    ULONG       Index;
    ULONG       Size;
    ULONG64     ModBase;          // Base Address of module comtaining this symbol
    ULONG       Flags;
    ULONG64     Value;            // Value of symbol, ValuePresent should be 1
    ULONG64     Address;          // Address of symbol including base address of module
    ULONG       Register;         // register holding value or pointer to value
    ULONG       Scope;            // scope of the symbol
    ULONG       Tag;              // pdb classification
    ULONG       NameLen;          // Actual length of name
    ULONG       MaxNameLen;
    WCHAR       Name[1];          // Name of symbol
} SYMBOL_INFOW, *PSYMBOL_INFOW;

typedef struct _SYMBOL_INFO_PACKAGEW {
    SYMBOL_INFOW si;
    WCHAR        name[MAX_SYM_NAME + 1];
} SYMBOL_INFO_PACKAGEW, *PSYMBOL_INFO_PACKAGEW;

typedef struct _IMAGEHLP_STACK_FRAME
{
    ULONG64 InstructionOffset;
    ULONG64 ReturnOffset;
    ULONG64 FrameOffset;
    ULONG64 StackOffset;
    ULONG64 BackingStoreOffset;
    ULONG64 FuncTableEntry;
    ULONG64 Params[4];
    ULONG64 Reserved[5];
    BOOL    Virtual;
    ULONG   Reserved2;
} IMAGEHLP_STACK_FRAME, *PIMAGEHLP_STACK_FRAME;

typedef void IMAGEHLP_CONTEXT, *PIMAGEHLP_CONTEXT;
]]


ffi.cdef[[
BOOL
SymSetContext(
    HANDLE hProcess,
    PIMAGEHLP_STACK_FRAME StackFrame,
    PIMAGEHLP_CONTEXT Context
    );
]]

ffi.cdef[[
BOOL
SymSetScopeFromAddr(
    HANDLE hProcess,
    ULONG64 Address
    );

BOOL
SymSetScopeFromIndex(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    DWORD Index
    );
]]

ffi.cdef[[
typedef BOOL
( *PSYM_ENUMPROCESSES_CALLBACK)(
    HANDLE hProcess,
    PVOID UserContext
    );

BOOL
SymEnumProcesses(
    PSYM_ENUMPROCESSES_CALLBACK EnumProcessesCallback,
    PVOID UserContext
    );
]]

ffi.cdef[[
BOOL
SymFromAddr(
    HANDLE hProcess,
    DWORD64 Address,
    PDWORD64 Displacement,
    PSYMBOL_INFO Symbol
    );

BOOL
SymFromAddrW(
    HANDLE hProcess,
    DWORD64 Address,
    PDWORD64 Displacement,
    PSYMBOL_INFOW Symbol
    );
]]

ffi.cdef[[
BOOL
SymFromToken(
    HANDLE hProcess,
    DWORD64 Base,
    DWORD Token,
    PSYMBOL_INFO Symbol
    );

BOOL
SymFromTokenW(
    HANDLE hProcess,
    DWORD64 Base,
    DWORD Token,
    PSYMBOL_INFOW Symbol
    );
]]

ffi.cdef[[
BOOL
SymNext(
    HANDLE hProcess,
    PSYMBOL_INFO si
    );

BOOL
SymNextW(
    HANDLE hProcess,
    PSYMBOL_INFOW siw
    );

BOOL
SymPrev(
    HANDLE hProcess,
    PSYMBOL_INFO si
    );

BOOL
SymPrevW(
    HANDLE hProcess,
    PSYMBOL_INFOW siw
    );
]]

ffi.cdef[[
// While SymFromName will provide a symbol from a name,
// SymEnumSymbols can provide the same matching information
// for ALL symbols with a matching name, even regular
// expressions.  That way you can search across modules
// and differentiate between identically named symbols.

BOOL
SymFromName(
    HANDLE hProcess,
    PCSTR Name,
    PSYMBOL_INFO Symbol
    );

BOOL
SymFromNameW(
    HANDLE hProcess,
    PCWSTR Name,
    PSYMBOL_INFOW Symbol
    );
]]

ffi.cdef[[
typedef BOOL
( *PSYM_ENUMERATESYMBOLS_CALLBACK)(
    PSYMBOL_INFO pSymInfo,
    ULONG SymbolSize,
    PVOID UserContext
    );

BOOL
SymEnumSymbols(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    PCSTR Mask,
    PSYM_ENUMERATESYMBOLS_CALLBACK EnumSymbolsCallback,
    PVOID UserContext
    );

typedef BOOL
( *PSYM_ENUMERATESYMBOLS_CALLBACKW)(
    PSYMBOL_INFOW pSymInfo,
    ULONG SymbolSize,
    PVOID UserContext
    );

BOOL
SymEnumSymbolsW(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    PCWSTR Mask,
    PSYM_ENUMERATESYMBOLS_CALLBACKW EnumSymbolsCallback,
    PVOID UserContext
    );

BOOL
SymEnumSymbolsForAddr(
    HANDLE hProcess,
    DWORD64 Address,
    PSYM_ENUMERATESYMBOLS_CALLBACK EnumSymbolsCallback,
    PVOID UserContext
    );

BOOL
SymEnumSymbolsForAddrW(
    HANDLE hProcess,
    DWORD64 Address,
    PSYM_ENUMERATESYMBOLS_CALLBACKW EnumSymbolsCallback,
    PVOID UserContext
    );
]]

ffi.cdef[[
static const int  SYMSEARCH_MASKOBJS     = 0x01;    // used internally to implement other APIs
static const int  SYMSEARCH_RECURSE      = 0X02;    // recurse scopes
static const int  SYMSEARCH_GLOBALSONLY  = 0X04;    // search only for global symbols
static const int  SYMSEARCH_ALLITEMS     = 0X08;    // search for everything in the pdb, not just normal scoped symbols

BOOL
SymSearch(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    DWORD Index,
    DWORD SymTag,
    PCSTR Mask,
    DWORD64 Address,
    PSYM_ENUMERATESYMBOLS_CALLBACK EnumSymbolsCallback,
    PVOID UserContext,
    DWORD Options
    );

BOOL
SymSearchW(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    DWORD Index,
    DWORD SymTag,
    PCWSTR Mask,
    DWORD64 Address,
    PSYM_ENUMERATESYMBOLS_CALLBACKW EnumSymbolsCallback,
    PVOID UserContext,
    DWORD Options
    );
]]

ffi.cdef[[
BOOL
SymGetScope(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    DWORD Index,
    PSYMBOL_INFO Symbol
    );

BOOL
SymGetScopeW(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    DWORD Index,
    PSYMBOL_INFOW Symbol
    );
]]

ffi.cdef[[
BOOL
SymFromIndex(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    DWORD Index,
    PSYMBOL_INFO Symbol
    );

BOOL
SymFromIndexW(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    DWORD Index,
    PSYMBOL_INFOW Symbol
    );
]]

ffi.cdef[[
typedef enum _IMAGEHLP_SYMBOL_TYPE_INFO {
    TI_GET_SYMTAG,
    TI_GET_SYMNAME,
    TI_GET_LENGTH,
    TI_GET_TYPE,
    TI_GET_TYPEID,
    TI_GET_BASETYPE,
    TI_GET_ARRAYINDEXTYPEID,
    TI_FINDCHILDREN,
    TI_GET_DATAKIND,
    TI_GET_ADDRESSOFFSET,
    TI_GET_OFFSET,
    TI_GET_VALUE,
    TI_GET_COUNT,
    TI_GET_CHILDRENCOUNT,
    TI_GET_BITPOSITION,
    TI_GET_VIRTUALBASECLASS,
    TI_GET_VIRTUALTABLESHAPEID,
    TI_GET_VIRTUALBASEPOINTEROFFSET,
    TI_GET_CLASSPARENTID,
    TI_GET_NESTED,
    TI_GET_SYMINDEX,
    TI_GET_LEXICALPARENT,
    TI_GET_ADDRESS,
    TI_GET_THISADJUST,
    TI_GET_UDTKIND,
    TI_IS_EQUIV_TO,
    TI_GET_CALLING_CONVENTION,
    TI_IS_CLOSE_EQUIV_TO,
    TI_GTIEX_REQS_VALID,
    TI_GET_VIRTUALBASEOFFSET,
    TI_GET_VIRTUALBASEDISPINDEX,
    TI_GET_IS_REFERENCE,
    TI_GET_INDIRECTVIRTUALBASECLASS,
    IMAGEHLP_SYMBOL_TYPE_INFO_MAX,
} IMAGEHLP_SYMBOL_TYPE_INFO;

typedef struct _TI_FINDCHILDREN_PARAMS {
    ULONG Count;
    ULONG Start;
    ULONG ChildId[1];
} TI_FINDCHILDREN_PARAMS;
]]

ffi.cdef[[
BOOL
SymGetTypeInfo(
    HANDLE hProcess,
    DWORD64 ModBase,
    ULONG TypeId,
    IMAGEHLP_SYMBOL_TYPE_INFO GetType,
    PVOID pInfo
    );
]]

ffi.cdef[[
static const int IMAGEHLP_GET_TYPE_INFO_UNCACHED = 0x00000001;
static const int IMAGEHLP_GET_TYPE_INFO_CHILDREN = 0x00000002;

typedef struct _IMAGEHLP_GET_TYPE_INFO_PARAMS {
    ULONG    SizeOfStruct;
    ULONG    Flags;
    ULONG    NumIds;
    PULONG   TypeIds;
    ULONG64  TagFilter;
    ULONG    NumReqs;
    IMAGEHLP_SYMBOL_TYPE_INFO* ReqKinds;
    PULONG_PTR ReqOffsets;
    PULONG   ReqSizes;
    ULONG_PTR ReqStride;
    ULONG_PTR BufferSize;
    PVOID    Buffer;
    ULONG    EntriesMatched;
    ULONG    EntriesFilled;
    ULONG64  TagsFound;
    ULONG64  AllReqsValid;
    ULONG    NumReqsValid;
    PULONG64 ReqsValid;
} IMAGEHLP_GET_TYPE_INFO_PARAMS, *PIMAGEHLP_GET_TYPE_INFO_PARAMS;
]]

ffi.cdef[[
BOOL
SymGetTypeInfoEx(
    HANDLE hProcess,
    DWORD64 ModBase,
    PIMAGEHLP_GET_TYPE_INFO_PARAMS Params
    );
]]

ffi.cdef[[
BOOL
SymEnumTypes(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    PSYM_ENUMERATESYMBOLS_CALLBACK EnumSymbolsCallback,
    PVOID UserContext
    );

BOOL
SymEnumTypesW(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    PSYM_ENUMERATESYMBOLS_CALLBACKW EnumSymbolsCallback,
    PVOID UserContext
    );
]]

ffi.cdef[[
BOOL
SymEnumTypesByName(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    PCSTR mask,
    PSYM_ENUMERATESYMBOLS_CALLBACK EnumSymbolsCallback,
    PVOID UserContext
    );

BOOL
SymEnumTypesByNameW(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    PCWSTR mask,
    PSYM_ENUMERATESYMBOLS_CALLBACKW EnumSymbolsCallback,
    PVOID UserContext
    );
]]

ffi.cdef[[
BOOL
SymGetTypeFromName(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    PCSTR Name,
    PSYMBOL_INFO Symbol
    );

BOOL
SymGetTypeFromNameW(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    PCWSTR Name,
    PSYMBOL_INFOW Symbol
    );
]]

ffi.cdef[[
BOOL
SymAddSymbol(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    PCSTR Name,
    DWORD64 Address,
    DWORD Size,
    DWORD Flags
    );

BOOL
SymAddSymbolW(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    PCWSTR Name,
    DWORD64 Address,
    DWORD Size,
    DWORD Flags
    );
]]

ffi.cdef[[
BOOL
SymDeleteSymbol(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    PCSTR Name,
    DWORD64 Address,
    DWORD Flags
    );

BOOL
SymDeleteSymbolW(
    HANDLE hProcess,
    ULONG64 BaseOfDll,
    PCWSTR Name,
    DWORD64 Address,
    DWORD Flags
    );
]]

ffi.cdef[[
BOOL
SymRefreshModuleList(
    HANDLE hProcess
    );
]]

ffi.cdef[[
BOOL
SymAddSourceStream(
    HANDLE hProcess,
    ULONG64 Base,
    PCSTR StreamFile,
    PBYTE Buffer,
    size_t Size
    );

typedef BOOL ( *SYMADDSOURCESTREAM)(HANDLE, ULONG64, PCSTR, PBYTE, size_t);

BOOL
SymAddSourceStreamA(
    HANDLE hProcess,
    ULONG64 Base,
    PCSTR StreamFile,
    PBYTE Buffer,
    size_t Size
    );

typedef BOOL ( *SYMADDSOURCESTREAMA)(HANDLE, ULONG64, PCSTR, PBYTE, size_t);

BOOL
SymAddSourceStreamW(
    HANDLE hProcess,
    ULONG64 Base,
    PCWSTR FileSpec,
    PBYTE Buffer,
    size_t Size
    );
]]

ffi.cdef[[
BOOL
SymSrvIsStoreW(
    HANDLE hProcess,
    PCWSTR path
    );

BOOL
SymSrvIsStore(
    HANDLE hProcess,
    PCSTR path
    );
]]

ffi.cdef[[
PCSTR
SymSrvDeltaName(
    HANDLE hProcess,
    PCSTR SymPath,
    PCSTR Type,
    PCSTR File1,
    PCSTR File2
    );

PCWSTR
SymSrvDeltaNameW(
    HANDLE hProcess,
    PCWSTR SymPath,
    PCWSTR Type,
    PCWSTR File1,
    PCWSTR File2
    );
]]

ffi.cdef[[
PCSTR
SymSrvGetSupplement(
    HANDLE hProcess,
    PCSTR SymPath,
    PCSTR Node,
    PCSTR File
    );

PCWSTR
SymSrvGetSupplementW(
    HANDLE hProcess,
    PCWSTR SymPath,
    PCWSTR Node,
    PCWSTR File
    );
]]

ffi.cdef[[
BOOL
SymSrvGetFileIndexes(
    PCSTR File,
    GUID *Id,
    PDWORD Val1,
    PDWORD Val2,
    DWORD Flags
    );

BOOL
SymSrvGetFileIndexesW(
    PCWSTR File,
    GUID *Id,
    PDWORD Val1,
    PDWORD Val2,
    DWORD Flags
    );
]]

ffi.cdef[[
BOOL
SymSrvGetFileIndexStringW(
    HANDLE hProcess,
    PCWSTR SrvPath,
    PCWSTR File,
    PWSTR Index,
    size_t Size,
    DWORD Flags
    );

BOOL
SymSrvGetFileIndexString(
    HANDLE hProcess,
    PCSTR SrvPath,
    PCSTR File,
    PSTR Index,
    size_t Size,
    DWORD Flags
    );
]]

ffi.cdef[[
typedef struct {
    DWORD sizeofstruct;
    char file[MAX_PATH +1];
    BOOL  stripped;
    DWORD timestamp;
    DWORD size;
    char dbgfile[MAX_PATH +1];
    char pdbfile[MAX_PATH + 1];
    GUID  guid;
    DWORD sig;
    DWORD age;
} SYMSRV_INDEX_INFO, *PSYMSRV_INDEX_INFO;

typedef struct {
    DWORD sizeofstruct;
    WCHAR file[MAX_PATH +1];
    BOOL  stripped;
    DWORD timestamp;
    DWORD size;
    WCHAR dbgfile[MAX_PATH +1];
    WCHAR pdbfile[MAX_PATH + 1];
    GUID  guid;
    DWORD sig;
    DWORD age;
} SYMSRV_INDEX_INFOW, *PSYMSRV_INDEX_INFOW;
]]

ffi.cdef[[
BOOL
SymSrvGetFileIndexInfo(
    PCSTR File,
    PSYMSRV_INDEX_INFO Info,
    DWORD Flags
    );

BOOL
SymSrvGetFileIndexInfoW(
    PCWSTR File,
    PSYMSRV_INDEX_INFOW Info,
    DWORD Flags
    );
]]

ffi.cdef[[
PCSTR
SymSrvStoreSupplement(
    HANDLE hProcess,
    PCSTR SrvPath,
    PCSTR Node,
    PCSTR File,
    DWORD Flags
    );

PCWSTR
SymSrvStoreSupplementW(
    HANDLE hProcess,
    PCWSTR SymPath,
    PCWSTR Node,
    PCWSTR File,
    DWORD Flags
    );
]]

ffi.cdef[[
PCSTR
SymSrvStoreFile(
    HANDLE hProcess,
    PCSTR SrvPath,
    PCSTR File,
    DWORD Flags
    );

PCWSTR
SymSrvStoreFileW(
    HANDLE hProcess,
    PCWSTR SrvPath,
    PCWSTR File,
    DWORD Flags
    );
]]

ffi.cdef[[
// used by SymGetSymbolFile's "Type" parameter

typedef enum {
    sfImage = 0,
    sfDbg,
    sfPdb,
    sfMpd,
    sfMax
};

BOOL
SymGetSymbolFile(
    HANDLE hProcess,
    PCSTR SymPath,
    PCSTR ImageFile,
    DWORD Type,
    PSTR SymbolFile,
    size_t cSymbolFile,
    PSTR DbgFile,
    size_t cDbgFile
    );

BOOL
SymGetSymbolFileW(
    HANDLE hProcess,
    PCWSTR SymPath,
    PCWSTR ImageFile,
    DWORD Type,
    PWSTR SymbolFile,
    size_t cSymbolFile,
    PWSTR DbgFile,
    size_t cDbgFile
    );
]]

ffi.cdef[[
//
// Full user-mode dump creation.
//

typedef BOOL ( *PDBGHELP_CREATE_USER_DUMP_CALLBACK)(
    DWORD DataType,
    PVOID* Data,
    LPDWORD DataLength,
    PVOID UserData
    );

BOOL

DbgHelpCreateUserDump(
    LPCSTR FileName,
    PDBGHELP_CREATE_USER_DUMP_CALLBACK Callback,
    PVOID UserData
    );

BOOL

DbgHelpCreateUserDumpW(
    LPCWSTR FileName,
    PDBGHELP_CREATE_USER_DUMP_CALLBACK Callback,
    PVOID UserData
    );
]]


ffi.cdef[[
// Symbol server exports

typedef BOOL ( *PSYMBOLSERVERPROC)(PCSTR, PCSTR, PVOID, DWORD, DWORD, PSTR);
typedef BOOL ( *PSYMBOLSERVERPROCA)(PCSTR, PCSTR, PVOID, DWORD, DWORD, PSTR);
typedef BOOL ( *PSYMBOLSERVERPROCW)(PCWSTR, PCWSTR, PVOID, DWORD, DWORD, PWSTR);
typedef BOOL ( *PSYMBOLSERVERBYINDEXPROC)(PCSTR, PCSTR, PCSTR, PSTR);
typedef BOOL ( *PSYMBOLSERVERBYINDEXPROCA)(PCSTR, PCSTR, PCSTR, PSTR);
typedef BOOL ( *PSYMBOLSERVERBYINDEXPROCW)(PCWSTR, PCWSTR, PCWSTR, PWSTR);
typedef BOOL ( *PSYMBOLSERVEROPENPROC)(void);
typedef BOOL ( *PSYMBOLSERVERCLOSEPROC)(void);
typedef BOOL ( *PSYMBOLSERVERSETOPTIONSPROC)(UINT_PTR, ULONG64);
typedef BOOL ( *PSYMBOLSERVERSETOPTIONSWPROC)(UINT_PTR, ULONG64);
typedef BOOL ( *PSYMBOLSERVERCALLBACKPROC)(UINT_PTR action, ULONG64 data, ULONG64 context);
typedef UINT_PTR ( *PSYMBOLSERVERGETOPTIONSPROC)();
typedef BOOL ( *PSYMBOLSERVERPINGPROC)(PCSTR);
typedef BOOL ( *PSYMBOLSERVERPINGPROCA)(PCSTR);
typedef BOOL ( *PSYMBOLSERVERPINGPROCW)(PCWSTR);
typedef BOOL ( *PSYMBOLSERVERGETVERSION)(LPAPI_VERSION);
typedef BOOL ( *PSYMBOLSERVERDELTANAME)(PCSTR, PVOID, DWORD, DWORD, PVOID, DWORD, DWORD, PSTR, size_t);
typedef BOOL ( *PSYMBOLSERVERDELTANAMEW)(PCWSTR, PVOID, DWORD, DWORD, PVOID, DWORD, DWORD, PWSTR, size_t);
typedef BOOL ( *PSYMBOLSERVERGETSUPPLEMENT)(PCSTR, PCSTR, PCSTR, PSTR, size_t);
typedef BOOL ( *PSYMBOLSERVERGETSUPPLEMENTW)(PCWSTR, PCWSTR, PCWSTR, PWSTR, size_t);
typedef BOOL ( *PSYMBOLSERVERSTORESUPPLEMENT)(PCSTR, PCSTR, PCSTR, PSTR, size_t, DWORD);
typedef BOOL ( *PSYMBOLSERVERSTORESUPPLEMENTW)(PCWSTR, PCWSTR, PCWSTR, PWSTR, size_t, DWORD);
typedef BOOL ( *PSYMBOLSERVERGETINDEXSTRING)(PVOID, DWORD, DWORD, PSTR, size_t);
typedef BOOL ( *PSYMBOLSERVERGETINDEXSTRINGW)(PVOID, DWORD, DWORD, PWSTR, size_t);
typedef BOOL ( *PSYMBOLSERVERSTOREFILE)(PCSTR, PCSTR, PVOID, DWORD, DWORD, PSTR, size_t, DWORD);
typedef BOOL ( *PSYMBOLSERVERSTOREFILEW)(PCWSTR, PCWSTR, PVOID, DWORD, DWORD, PWSTR, size_t, DWORD);
typedef BOOL ( *PSYMBOLSERVERISSTORE)(PCSTR);
typedef BOOL ( *PSYMBOLSERVERISSTOREW)(PCWSTR);
typedef DWORD ( *PSYMBOLSERVERVERSION)();
typedef BOOL ( *PSYMBOLSERVERMESSAGEPROC)(UINT_PTR action, ULONG64 data, ULONG64 context);
]]

ffi.cdef[[
static const int SYMSRV_VERSION              = 2;

static const int SSRVOPT_CALLBACK            = 0x00000001;
static const int SSRVOPT_DWORD               = 0x00000002;
static const int SSRVOPT_DWORDPTR            = 0x00000004;
static const int SSRVOPT_GUIDPTR             = 0x00000008;
static const int SSRVOPT_OLDGUIDPTR          = 0x00000010;
static const int SSRVOPT_UNATTENDED          = 0x00000020;
static const int SSRVOPT_NOCOPY              = 0x00000040;
static const int SSRVOPT_GETPATH             = 0x00000040;
static const int SSRVOPT_PARENTWIN           = 0x00000080;
static const int SSRVOPT_PARAMTYPE           = 0x00000100;
static const int SSRVOPT_SECURE              = 0x00000200;
static const int SSRVOPT_TRACE               = 0x00000400;
static const int SSRVOPT_SETCONTEXT          = 0x00000800;
static const int SSRVOPT_PROXY               = 0x00001000;
static const int SSRVOPT_DOWNSTREAM_STORE    = 0x00002000;
static const int SSRVOPT_OVERWRITE           = 0x00004000;
static const int SSRVOPT_RESETTOU            = 0x00008000;
static const int SSRVOPT_CALLBACKW           = 0x00010000;
static const int SSRVOPT_FLAT_DEFAULT_STORE  = 0x00020000;
static const int SSRVOPT_PROXYW              = 0x00040000;
static const int SSRVOPT_MESSAGE             = 0x00080000;
static const int SSRVOPT_FAVOR_COMPRESSED    = 0x00200000;
static const int SSRVOPT_STRING              = 0x00400000;
static const int SSRVOPT_WINHTTP             = 0x00800000;
static const int SSRVOPT_WININET             = 0x01000000;

static const int SSRVOPT_MAX                 = 0x0100000;

static const int SSRVOPT_RESET               = ((ULONG_PTR)-1);
static const int NUM_SSRVOPTS                =30;
]]

ffi.cdef[[
static const int SSRVACTION_TRACE        = 1;
static const int SSRVACTION_QUERYCANCEL  = 2;
static const int SSRVACTION_EVENT        = 3;
static const int SSRVACTION_EVENTW       = 4;
static const int SSRVACTION_SIZE         = 5;

static const int SYMSTOREOPT_COMPRESS       = 0x01;
static const int SYMSTOREOPT_OVERWRITE      = 0x02;
static const int SYMSTOREOPT_RETURNINDEX    = 0x04;
static const int SYMSTOREOPT_POINTER        = 0x08;
static const int SYMSTOREOPT_ALT_INDEX      = 0x10;
static const int SYMSTOREOPT_UNICODE        = 0x20;
static const int SYMSTOREOPT_PASS_IF_EXISTS = 0x40;
]]


if DBGHELP_TRANSLATE_TCHAR then
 SymInitialize                     = Lib.SymInitializeW;
 SymAddSymbol                      = Lib.SymAddSymbolW;
 SymDeleteSymbol                   = Lib.SymDeleteSymbolW;
 SearchTreeForFile                 = Lib.SearchTreeForFileW;
 UnDecorateSymbolName              = Lib.UnDecorateSymbolNameW;
 SymGetLineFromName64              = Lib.SymGetLineFromNameW64;
 SymGetLineFromAddr64              = Lib.SymGetLineFromAddrW64;
 SymGetLineNext64                  = Lib.SymGetLineNextW64;
 SymGetLinePrev64                  = Lib.SymGetLinePrevW64;
 SymFromName                       = Lib.SymFromNameW;
 SymFindExecutableImage            = Lib.SymFindExecutableImageW;
 FindExecutableImageEx             = Lib.FindExecutableImageExW;
 SymSearch                         = Lib.SymSearchW;
 SymEnumLines                      = Lib.SymEnumLinesW;
 SymEnumSourceLines                = Lib.SymEnumSourceLinesW;
 SymGetTypeFromName                = Lib.SymGetTypeFromNameW;
 SymEnumSymbolsForAddr             = Lib.SymEnumSymbolsForAddrW;
 SymFromAddr                       = Lib.SymFromAddrW;
 SymMatchString                    = Lib.SymMatchStringW;
 SymEnumSourceFiles                = Lib.SymEnumSourceFilesW;
 SymEnumSymbols                    = Lib.SymEnumSymbolsW;
 SymLoadModuleEx                   = Lib.SymLoadModuleExW;
 SymSetSearchPath                  = Lib.SymSetSearchPathW;
 SymGetSearchPath                  = Lib.SymGetSearchPathW;
 EnumDirTree                       = Lib.EnumDirTreeW;
 SymFromToken                      = Lib.SymFromTokenW;
 SymFromIndex                      = Lib.SymFromIndexW;
 SymGetScope                       = Lib.SymGetScopeW;
 SymNext                           = Lib.SymNextW;
 SymPrev                           = Lib.SymPrevW;
 SymEnumTypes                      = Lib.SymEnumTypesW;
 SymEnumTypesByName                = Lib.SymEnumTypesByNameW;
 SymRegisterCallback64             = Lib.SymRegisterCallbackW64;
 SymFindDebugInfoFile              = Lib.SymFindDebugInfoFileW;
 FindDebugInfoFileEx               = Lib.FindDebugInfoFileExW;
 SymFindFileInPath                 = Lib.SymFindFileInPathW;
 SymEnumerateModules64             = Lib.SymEnumerateModulesW64;
 SymSetHomeDirectory               = Lib.SymSetHomeDirectoryW;
 SymGetHomeDirectory               = Lib.SymGetHomeDirectoryW;
 SymGetSourceFile                  = Lib.SymGetSourceFileW;
 SymGetSourceFileToken             = Lib.SymGetSourceFileTokenW;
 SymGetSourceFileFromToken         = Lib.SymGetSourceFileFromTokenW;
 SymGetSourceVarFromToken          = Lib.SymGetSourceVarFromTokenW;
 SymGetSourceFileToken             = Lib.SymGetSourceFileTokenW;
 SymGetFileLineOffsets64           = Lib.SymGetFileLineOffsetsW64;
 SymFindFileInPath                 = Lib.SymFindFileInPathW;
 SymMatchFileName                  = Lib.SymMatchFileNameW;
 SymGetSourceFileFromToken         = Lib.SymGetSourceFileFromTokenW;
 SymGetSourceVarFromToken          = Lib.SymGetSourceVarFromTokenW;
 SymGetModuleInfo64                = Lib.SymGetModuleInfoW64;
 SymSrvIsStore                     = Lib.SymSrvIsStoreW;
 SymSrvDeltaName                   = Lib.SymSrvDeltaNameW;
 SymSrvGetSupplement               = Lib.SymSrvGetSupplementW;
 SymSrvStoreSupplement             = Lib.SymSrvStoreSupplementW;
 SymSrvGetFileIndexes              = Lib.SymSrvGetFileIndexes;
 SymSrvGetFileIndexString          = Lib.SymSrvGetFileIndexStringW;
 SymSrvStoreFile                   = Lib.SymSrvStoreFileW;
 SymGetSymbolFile                  = Lib.SymGetSymbolFileW;
 EnumerateLoadedModules64          = Lib.EnumerateLoadedModulesW64;
 EnumerateLoadedModulesEx          = Lib.EnumerateLoadedModulesExW;
 SymSrvGetFileIndexInfo            = Lib.SymSrvGetFileIndexInfoW;

 IMAGEHLP_LINE64                   = ffi.typeof("IMAGEHLP_LINEW64");
 PIMAGEHLP_LINE64                  = ffi.typeof("PIMAGEHLP_LINEW64");
 SYMBOL_INFO                       = ffi.typeof("SYMBOL_INFOW");
 PSYMBOL_INFO                      = ffi.typeof("PSYMBOL_INFOW");
 SYMBOL_INFO_PACKAGE               = ffi.typeof("SYMBOL_INFO_PACKAGEW");
 PSYMBOL_INFO_PACKAGE              = ffi.typeof("PSYMBOL_INFO_PACKAGEW");
 FIND_EXE_FILE_CALLBACK            = ffi.typeof("FIND_EXE_FILE_CALLBACKW");
 PFIND_EXE_FILE_CALLBACK           = ffi.typeof("PFIND_EXE_FILE_CALLBACKW");
 SYM_ENUMERATESYMBOLS_CALLBACK     = ffi.typeof("SYM_ENUMERATESYMBOLS_CALLBACKW");
 PSYM_ENUMERATESYMBOLS_CALLBACK    = ffi.typeof("PSYM_ENUMERATESYMBOLS_CALLBACKW");
 SRCCODEINFO                       = ffi.typeof("SRCCODEINFOW");
 PSRCCODEINFO                      = ffi.typeof("PSRCCODEINFOW");
 SOURCEFILE                        = ffi.typeof("SOURCEFILEW");
 PSOURCEFILE                       = ffi.typeof("PSOURCEFILEW");
 SYM_ENUMSOURECFILES_CALLBACK      = ffi.typeof("SYM_ENUMSOURCEFILES_CALLBACKW");
 PSYM_ENUMSOURCEFILES_CALLBACK     = ffi.typeof("PSYM_ENUMSOURECFILES_CALLBACKW");
 IMAGEHLP_CBA_EVENT                = ffi.typeof("IMAGEHLP_CBA_EVENTW");
 PIMAGEHLP_CBA_EVENT               = ffi.typeof("PIMAGEHLP_CBA_EVENTW");
 PENUMDIRTREE_CALLBACK             = ffi.typeof("PENUMDIRTREE_CALLBACKW");
 IMAGEHLP_DEFERRED_SYMBOL_LOAD64   = ffi.typeof("IMAGEHLP_DEFERRED_SYMBOL_LOADW64");
 PIMAGEHLP_DEFERRED_SYMBOL_LOAD64  = ffi.typeof("PIMAGEHLP_DEFERRED_SYMBOL_LOADW64");
 PFIND_DEBUG_FILE_CALLBACK         = ffi.typeof("PFIND_DEBUG_FILE_CALLBACKW");
 PFINDFILEINPATHCALLBACK           = ffi.typeof("PFINDFILEINPATHCALLBACKW");
 IMAGEHLP_MODULE64                 = ffi.typeof("IMAGEHLP_MODULEW64");
 PIMAGEHLP_MODULE64                = ffi.typeof("PIMAGEHLP_MODULEW64");
 SYMSRV_INDEX_INFO                 = ffi.typeof("SYMSRV_INDEX_INFOW");
 PSYMSRV_INDEX_INFO                = ffi.typeof("PSYMSRV_INDEX_INFOW");

 PSYMBOLSERVERPROC                 = ffi.typeof("PSYMBOLSERVERPROCW");
 PSYMBOLSERVERPINGPROC             = ffi.typeof("PSYMBOLSERVERPINGPROCW");
end


ffi.cdef[[
// use SymLoadModuleEx

DWORD64
SymLoadModule64(
    HANDLE hProcess,
    HANDLE hFile,
    PCSTR ImageName,
    PCSTR ModuleName,
    DWORD64 BaseOfDll,
    DWORD SizeOfDll
    );
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymLoadModule = Lib.SymLoadModule64;
else
ffi.cdef[[
DWORD
SymLoadModule(
    HANDLE hProcess,
    HANDLE hFile,
    PCSTR ImageName,
    PCSTR ModuleName,
    DWORD BaseOfDll,
    DWORD SizeOfDll
    );
]]
end

ffi.cdef[[
BOOL
SymGetSymNext64(
    HANDLE hProcess,
    PIMAGEHLP_SYMBOL64 Symbol
    );

BOOL
SymGetSymNextW64(
    HANDLE hProcess,
    PIMAGEHLP_SYMBOLW64 Symbol
    );
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymGetSymNext = Lib.SymGetSymNext64;
SymGetSymNextW = Lib.SymGetSymNextW64;
else
ffi.cdef[[
BOOL
SymGetSymNext(
    HANDLE hProcess,
    PIMAGEHLP_SYMBOL Symbol
    );

BOOL
SymGetSymNextW(
    HANDLE hProcess,
    PIMAGEHLP_SYMBOLW Symbol
    );
]]
end

ffi.cdef[[
BOOL
SymGetSymPrev64(
    HANDLE hProcess,
    PIMAGEHLP_SYMBOL64 Symbol
    );

BOOL
SymGetSymPrevW64(
    HANDLE hProcess,
    PIMAGEHLP_SYMBOLW64 Symbol
    );
]]

if not _IMAGEHLP_SOURCE_ and _IMAGEHLP64 then
SymGetSymPrev = Lib.SymGetSymPrev64;
SymGetSymPrevW = Lib.SymGetSymPrevW64;
else
ffi.cdef[[
BOOL
SymGetSymPrev(
    HANDLE hProcess,
    PIMAGEHLP_SYMBOL Symbol
    );

BOOL
SymGetSymPrevW(
    HANDLE hProcess,
    PIMAGEHLP_SYMBOLW Symbol
    );
]]
end


--#include <poppack.h>

return {
    Lib = Lib;
}