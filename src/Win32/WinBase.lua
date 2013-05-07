-- WinBase.lua
-- From WinBase.h
local ffi = require "ffi"

require ("WTypes");
require ("Handle_ffi");
require ("Heap_ffi");
require ("SysInfo_ffi");
require ("UMS_ffi");
require ("Util_ffi");
require ("ntstatus");

-- Winnt.h
MAXIMUM_WAIT_OBJECTS = 64     -- Maximum number of wait objects


INVALID_HANDLE_VALUE = ffi.cast("intptr_t", -1)
INVALID_FILE_SIZE         = (0xFFFFFFFF);
INVALID_SET_FILE_POINTER  = (-1);
INVALID_FILE_ATTRIBUTES   = (-1);

WAIT_TIMEOUT = 0X102;
WAIT_OBJECT_0 = 0;


FILE_SHARE_READ			= 0X01;
FILE_SHARE_WRITE		= 0X02;
FILE_FLAG_OVERLAPPED 	= 0X40000000;

FILE_READ_DATA                   = 0x0001    -- file & pipe
FILE_WRITE_DATA                  = 0x0002    -- file & pipe
FILE_APPEND_DATA                 = 0x0004    -- file
FILE_READ_EA                     = 0x0008    -- file & directory
FILE_WRITE_EA                    = 0x0010    -- file & directory
FILE_EXECUTE                     = 0x0020    -- file
FILE_READ_ATTRIBUTES             = 0x0080    -- all
FILE_WRITE_ATTRIBUTES            = 0x0100    -- all

--[[
--FILE_ALL_ACCESS             =STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE | 0x1FF,


FILE_GENERIC_READ          =
            STANDARD_RIGHTS_READ     |
            FILE_READ_DATA           |
            FILE_READ_ATTRIBUTES     |
            FILE_READ_EA             |
            SYNCHRONIZE,


        FILE_GENERIC_WRITE         =
            STANDARD_RIGHTS_WRITE    |
            FILE_WRITE_DATA          |
            FILE_WRITE_ATTRIBUTES    |
            FILE_WRITE_EA            |
            FILE_APPEND_DATA         |
            SYNCHRONIZE,

        FILE_GENERIC_EXECUTE      =
            STANDARD_RIGHTS_EXECUTE  |
            FILE_READ_ATTRIBUTES     |
            FILE_EXECUTE             |
            SYNCHRONIZE,
--]]












OPEN_ALWAYS = 4;
OPEN_EXISTING = 3;



PURGE_TXABORT = 0x01;
PURGE_RXABORT = 0x02;
PURGE_TXCLEAR = 0x04;
PURGE_RXCLEAR = 0x08;




ERROR_IO_PENDING = 0x03E5; -- 997

INFINITE = 0xFFFFFFFF;


-- Access Rights
DELETE 			= 0x00010000
READ_CONTROL	= 0x00020000
WRITE_DAC		= 0x00040000
WRITE_OWNER		= 0x00080000
SYNCHRONIZE		= 0x00100000


--THREAD_ALL_ACCESS
THREAD_DIRECT_IMPERSONATION			= 0x0200
THREAD_GET_CONTEXT					= 0x0008
THREAD_IMPERSONATE					= 0x0100
THREAD_QUERY_INFORMATION			= 0x0040
THREAD_QUERY_LIMITED_INFORMATION	= 0x0800
THREAD_SET_CONTEXT					= 0x0010
THREAD_SET_INFORMATION				= 0x0020
THREAD_SET_LIMITED_INFORMATION		= 0x0400
THREAD_SET_THREAD_TOKEN				= 0x0080
THREAD_SUSPEND_RESUME				= 0x0002
THREAD_TERMINATE					= 0x0001

-- Process dwCreationFlag values

 DEBUG_PROCESS                    = 0x00000001
 DEBUG_ONLY_THIS_PROCESS          = 0x00000002
 CREATE_SUSPENDED                 = 0x00000004
 DETACHED_PROCESS                 = 0x00000008

 CREATE_NEW_CONSOLE               = 0x00000010
 NORMAL_PRIORITY_CLASS            = 0x00000020
 IDLE_PRIORITY_CLASS              = 0x00000040
 HIGH_PRIORITY_CLASS              = 0x00000080

 REALTIME_PRIORITY_CLASS          = 0x00000100
 CREATE_NEW_PROCESS_GROUP         = 0x00000200
 CREATE_UNICODE_ENVIRONMENT       = 0x00000400
 CREATE_SEPARATE_WOW_VDM          = 0x00000800

 CREATE_SHARED_WOW_VDM            = 0x00001000
 CREATE_FORCEDOS                  = 0x00002000
 BELOW_NORMAL_PRIORITY_CLASS      = 0x00004000
 ABOVE_NORMAL_PRIORITY_CLASS      = 0x00008000

 INHERIT_PARENT_AFFINITY          = 0x00010000
 CREATE_PROTECTED_PROCESS         = 0x00040000
 EXTENDED_STARTUPINFO_PRESENT     = 0x00080000

 PROCESS_MODE_BACKGROUND_BEGIN    = 0x00100000
 PROCESS_MODE_BACKGROUND_END      = 0x00200000

 CREATE_BREAKAWAY_FROM_JOB        = 0x01000000
 CREATE_PRESERVE_CODE_AUTHZ_LEVEL = 0x02000000
 CREATE_DEFAULT_ERROR_MODE        = 0x04000000
 CREATE_NO_WINDOW                 = 0x08000000

 PROFILE_USER                     = 0x10000000
 PROFILE_KERNEL                   = 0x20000000
 PROFILE_SERVER                   = 0x40000000
 CREATE_IGNORE_SYSTEM_DEFAULT     = 0x80000000


 STACK_SIZE_PARAM_IS_A_RESERVATION   = 0x00010000    -- Threads only

ffi.cdef[[
static const int STILL_ACTIVE =             STATUS_PENDING;
]]

--[[
#define WAIT_IO_COMPLETION                  STATUS_USER_APC
#define EXCEPTION_ACCESS_VIOLATION          STATUS_ACCESS_VIOLATION
#define EXCEPTION_DATATYPE_MISALIGNMENT     STATUS_DATATYPE_MISALIGNMENT
#define EXCEPTION_BREAKPOINT                STATUS_BREAKPOINT
#define EXCEPTION_SINGLE_STEP               STATUS_SINGLE_STEP
#define EXCEPTION_ARRAY_BOUNDS_EXCEEDED     STATUS_ARRAY_BOUNDS_EXCEEDED
#define EXCEPTION_FLT_DENORMAL_OPERAND      STATUS_FLOAT_DENORMAL_OPERAND
#define EXCEPTION_FLT_DIVIDE_BY_ZERO        STATUS_FLOAT_DIVIDE_BY_ZERO
#define EXCEPTION_FLT_INEXACT_RESULT        STATUS_FLOAT_INEXACT_RESULT
#define EXCEPTION_FLT_INVALID_OPERATION     STATUS_FLOAT_INVALID_OPERATION
#define EXCEPTION_FLT_OVERFLOW              STATUS_FLOAT_OVERFLOW
#define EXCEPTION_FLT_STACK_CHECK           STATUS_FLOAT_STACK_CHECK
#define EXCEPTION_FLT_UNDERFLOW             STATUS_FLOAT_UNDERFLOW
#define EXCEPTION_INT_DIVIDE_BY_ZERO        STATUS_INTEGER_DIVIDE_BY_ZERO
#define EXCEPTION_INT_OVERFLOW              STATUS_INTEGER_OVERFLOW
#define EXCEPTION_PRIV_INSTRUCTION          STATUS_PRIVILEGED_INSTRUCTION
#define EXCEPTION_IN_PAGE_ERROR             STATUS_IN_PAGE_ERROR
#define EXCEPTION_ILLEGAL_INSTRUCTION       STATUS_ILLEGAL_INSTRUCTION
#define EXCEPTION_NONCONTINUABLE_EXCEPTION  STATUS_NONCONTINUABLE_EXCEPTION
#define EXCEPTION_STACK_OVERFLOW            STATUS_STACK_OVERFLOW
#define EXCEPTION_INVALID_DISPOSITION       STATUS_INVALID_DISPOSITION
#define EXCEPTION_GUARD_PAGE                STATUS_GUARD_PAGE_VIOLATION
#define EXCEPTION_INVALID_HANDLE            STATUS_INVALID_HANDLE
#define EXCEPTION_POSSIBLE_DEADLOCK         STATUS_POSSIBLE_DEADLOCK
#define CONTROL_C_EXIT                      STATUS_CONTROL_C_EXIT
--]]

--
-- Priority flags
--
--[[
 THREAD_PRIORITY_LOWEST          THREAD_BASE_PRIORITY_MIN
 THREAD_PRIORITY_BELOW_NORMAL    (THREAD_PRIORITY_LOWEST+1)
 THREAD_PRIORITY_NORMAL          0
 THREAD_PRIORITY_HIGHEST         THREAD_BASE_PRIORITY_MAX
 THREAD_PRIORITY_ABOVE_NORMAL    (THREAD_PRIORITY_HIGHEST-1)
 THREAD_PRIORITY_ERROR_RETURN    (MAXLONG)

 THREAD_PRIORITY_TIME_CRITICAL   THREAD_BASE_PRIORITY_LOWRT
 THREAD_PRIORITY_IDLE            THREAD_BASE_PRIORITY_IDLE

 THREAD_MODE_BACKGROUND_BEGIN    0x00010000
 THREAD_MODE_BACKGROUND_END      0x00020000
--]]


ffi.cdef[[
typedef struct _OVERLAPPED {
    ULONG_PTR Internal;
    ULONG_PTR InternalHigh;
    union {
        struct {
            DWORD Offset;
            DWORD OffsetHigh;
        };

        PVOID Pointer;
    };

    HANDLE hEvent;
} OVERLAPPED, *LPOVERLAPPED;

typedef struct _PROCESS_INFORMATION {
    HANDLE hProcess;
    HANDLE hThread;
    DWORD dwProcessId;
    DWORD dwThreadId;
} PROCESS_INFORMATION, *PPROCESS_INFORMATION, *LPPROCESS_INFORMATION;

BOOL GetQueuedCompletionStatus(
    HANDLE CompletionPort,
    LPDWORD lpNumberOfBytesTransferred,
    PULONG_PTR lpCompletionKey,
    LPOVERLAPPED *lpOverlapped,
    DWORD dwMilliseconds
    );

BOOL PostQueuedCompletionStatus(
	HANDLE CompletionPort,
	DWORD dwNumberOfBytesTransferred,
	ULONG_PTR dwCompletionKey,
	LPOVERLAPPED lpOverlapped
);


typedef struct _BY_HANDLE_FILE_INFORMATION {
    DWORD dwFileAttributes;
    FILETIME ftCreationTime;
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD dwVolumeSerialNumber;
    DWORD nFileSizeHigh;
    DWORD nFileSizeLow;
    DWORD nNumberOfLinks;
    DWORD nFileIndexHigh;
    DWORD nFileIndexLow;
} BY_HANDLE_FILE_INFORMATION, *PBY_HANDLE_FILE_INFORMATION, *LPBY_HANDLE_FILE_INFORMATION;
]]


ffi.cdef[[
//
// Dual Mode API below this line. Dual Mode Structures also included.
//

static const int  STARTF_USESHOWWINDOW    =0x00000001;
static const int  STARTF_USESIZE          =0x00000002;
static const int  STARTF_USEPOSITION      =0x00000004;
static const int  STARTF_USECOUNTCHARS    =0x00000008;
static const int  STARTF_USEFILLATTRIBUTE =0x00000010;
static const int  STARTF_RUNFULLSCREEN    =0x00000020; // ignored for non-x86 platforms
static const int  STARTF_FORCEONFEEDBACK  =0x00000040;
static const int  STARTF_FORCEOFFFEEDBACK =0x00000080;
static const int  STARTF_USESTDHANDLES    =0x00000100;


static const int  STARTF_USEHOTKEY        =0x00000200;
static const int  STARTF_TITLEISLINKNAME  =0x00000800;
static const int  STARTF_TITLEISAPPID     =0x00001000;
static const int  STARTF_PREVENTPINNING   =0x00002000;

typedef struct _STARTUPINFOA {
    DWORD   cb;
    LPSTR   lpReserved;
    LPSTR   lpDesktop;
    LPSTR   lpTitle;
    DWORD   dwX;
    DWORD   dwY;
    DWORD   dwXSize;
    DWORD   dwYSize;
    DWORD   dwXCountChars;
    DWORD   dwYCountChars;
    DWORD   dwFillAttribute;
    DWORD   dwFlags;
    WORD    wShowWindow;
    WORD    cbReserved2;
    LPBYTE  lpReserved2;
    HANDLE  hStdInput;
    HANDLE  hStdOutput;
    HANDLE  hStdError;
} STARTUPINFOA, *LPSTARTUPINFOA;

typedef struct _STARTUPINFOW {
    DWORD   cb;
    LPWSTR  lpReserved;
    LPWSTR  lpDesktop;
    LPWSTR  lpTitle;
    DWORD   dwX;
    DWORD   dwY;
    DWORD   dwXSize;
    DWORD   dwYSize;
    DWORD   dwXCountChars;
    DWORD   dwYCountChars;
    DWORD   dwFillAttribute;
    DWORD   dwFlags;
    WORD    wShowWindow;
    WORD    cbReserved2;
    LPBYTE  lpReserved2;
    HANDLE  hStdInput;
    HANDLE  hStdOutput;
    HANDLE  hStdError;
} STARTUPINFOW, *LPSTARTUPINFOW;
]]

if UNICODE then
ffi.cdef[[
typedef STARTUPINFOW STARTUPINFO;
typedef LPSTARTUPINFOW LPSTARTUPINFO;
]]
else
ffi.cdef[[
typedef STARTUPINFOA STARTUPINFO;
typedef LPSTARTUPINFOA LPSTARTUPINFO;
]]
end -- UNICODE

ffi.cdef[[
typedef struct _PROC_THREAD_ATTRIBUTE_LIST *PPROC_THREAD_ATTRIBUTE_LIST, *LPPROC_THREAD_ATTRIBUTE_LIST;

typedef struct _STARTUPINFOEXA {
    STARTUPINFOA StartupInfo;
    LPPROC_THREAD_ATTRIBUTE_LIST lpAttributeList;
} STARTUPINFOEXA, *LPSTARTUPINFOEXA;
typedef struct _STARTUPINFOEXW {
    STARTUPINFOW StartupInfo;
    LPPROC_THREAD_ATTRIBUTE_LIST lpAttributeList;
} STARTUPINFOEXW, *LPSTARTUPINFOEXW;
]]

if UNICODE then
ffi.cdef[[
typedef STARTUPINFOEXW STARTUPINFOEX;
typedef LPSTARTUPINFOEXW LPSTARTUPINFOEX;
]]
else
ffi.cdef[[
typedef STARTUPINFOEXA STARTUPINFOEX;
typedef LPSTARTUPINFOEXA LPSTARTUPINFOEX;
]]
end -- UNICODE



ffi.cdef[[
//
// LogonFlags
//
static const int LOGON_WITH_PROFILE            =  0x00000001;
static const int  LOGON_NETCREDENTIALS_ONLY    =   0x00000002;
static const int  LOGON_ZERO_PASSWORD_BUFFER   =   0x80000000;

BOOL
CreateProcessWithLogonW(
    LPCWSTR lpUsername,
    LPCWSTR lpDomain,
    LPCWSTR lpPassword,
    DWORD dwLogonFlags,
    LPCWSTR lpApplicationName,
    LPWSTR lpCommandLine,
    DWORD dwCreationFlags,
    LPVOID lpEnvironment,
    LPCWSTR lpCurrentDirectory,
    LPSTARTUPINFOW lpStartupInfo,
    LPPROCESS_INFORMATION lpProcessInformation
    );


BOOL
CreateProcessWithTokenW(
    HANDLE hToken,
    DWORD dwLogonFlags,
    LPCWSTR lpApplicationName,
    LPWSTR lpCommandLine,
    DWORD dwCreationFlags,
    LPVOID lpEnvironment,
    LPCWSTR lpCurrentDirectory,
    LPSTARTUPINFOW lpStartupInfo,
    LPPROCESS_INFORMATION lpProcessInformation
    );
]]

