-- core_errorhandling_l1_1_1.lua	
-- api-ms-win-core-errorhandling-l1-1-1.dll	

local ffi = require("ffi");

local k32Lib = ffi.load("kernel32");
local WTypes = require ("WTypes");
local WinNT = require("WinNT");


ffi.cdef[[
static const int SEM_FAILCRITICALERRORS      =0x0001;
static const int SEM_NOGPFAULTERRORBOX       =0x0002;
static const int SEM_NOALIGNMENTFAULTEXCEPT  =0x0004;
static const int SEM_NOOPENFILEERRORBOX      =0x8000;
]]

ffi.cdef[[
typedef LONG (* PTOP_LEVEL_EXCEPTION_FILTER)(struct _EXCEPTION_POINTERS *ExceptionInfo);
typedef PTOP_LEVEL_EXCEPTION_FILTER LPTOP_LEVEL_EXCEPTION_FILTER;
]]

ffi.cdef[[
PVOID
AddVectoredContinueHandler (ULONG First, PVECTORED_EXCEPTION_HANDLER Handler);

PVOID
AddVectoredExceptionHandler (ULONG First, PVECTORED_EXCEPTION_HANDLER Handler);

UINT
GetErrorMode(void);

DWORD 
GetLastError(void);

void
RaiseException(
    DWORD dwExceptionCode,
    DWORD dwExceptionFlags,
    DWORD nNumberOfArguments,
    const ULONG_PTR *lpArguments);

ULONG
RemoveVectoredContinueHandler (PVOID Handle);

ULONG
RemoveVectoredExceptionHandler (PVOID Handle);

void
RestoreLastError(DWORD dwErrCode);

UINT
SetErrorMode(UINT uMode);

void
SetLastError(DWORD dwErrCode);

LPTOP_LEVEL_EXCEPTION_FILTER
SetUnhandledExceptionFilter(LPTOP_LEVEL_EXCEPTION_FILTER lpTopLevelExceptionFilter);

LONG
UnhandledExceptionFilter(struct _EXCEPTION_POINTERS *ExceptionInfo);

]]


return {
	AddVectoredContinueHandler = k32Lib.AddVectoredContinueHandler,
	AddVectoredExceptionHandler = k32Lib.AddVectoredExceptionHandler,
	GetErrorMode = k32Lib.GetErrorMode,
	GetLastError = k32Lib.GetLastError,
	RaiseException = k32Lib.RaiseException,
	RemoveVectoredContinueHandler = k32Lib.RemoveVectoredContinueHandler,
	RemoveVectoredExceptionHandler = k32Lib.RemoveVectoredExceptionHandler,
	RestoreLastError = k32Lib.RestoreLastError,
	SetErrorMode = k32Lib.SetErrorMode,
	SetLastError = k32Lib.SetLastError,
	SetUnhandledExceptionFilter = k32Lib.SetUnhandledExceptionFilter,
	UnhandledExceptionFilter = k32Lib.UnhandledExceptionFilter,
}
