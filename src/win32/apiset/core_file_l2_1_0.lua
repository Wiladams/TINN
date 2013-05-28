-- core_file_l2_1_0.lua	
-- api-ms-win-core-file-l2-1-0.dll	

local ffi = require("ffi");

local k32Lib = ffi.load("kernel32");
local WTypes = require("WTypes");
local WinBase = require("WinBase");


ffi.cdef[[
typedef
DWORD ( *LPPROGRESS_ROUTINE)(
        LARGE_INTEGER TotalFileSize,
        LARGE_INTEGER TotalBytesTransferred,
        LARGE_INTEGER StreamSize,
        LARGE_INTEGER StreamBytesTransferred,
        DWORD dwStreamNumber,
        DWORD dwCallbackReason,
        HANDLE hSourceFile,
        HANDLE hDestinationFile,
    LPVOID lpData
    );
]]

ffi.cdef[[
BOOL
CopyFileExW(
    LPCWSTR lpExistingFileName,
    LPCWSTR lpNewFileName,
    LPPROGRESS_ROUTINE lpProgressRoutine,
    LPVOID lpData,
    LPBOOL pbCancel,
    DWORD dwCopyFlags
    );

BOOL
CreateDirectoryExW(
    LPCWSTR lpTemplateDirectory,
    LPCWSTR lpNewDirectory,
    LPSECURITY_ATTRIBUTES lpSecurityAttributes
    );

BOOL
CreateHardLinkW(
    LPCWSTR lpFileName,
    LPCWSTR lpExistingFileName,
    LPSECURITY_ATTRIBUTES lpSecurityAttributes
    );

BOOLEAN
CreateSymbolicLinkW (
    LPCWSTR lpSymlinkFileName,
    LPCWSTR lpTargetFileName,
    DWORD dwFlags
    );


BOOL
GetFileInformationByHandleEx(
    HANDLE hFile,
    FILE_INFO_BY_HANDLE_CLASS FileInformationClass,
    LPVOID lpFileInformation,
    DWORD dwBufferSize
);


BOOL
MoveFileExW(
        LPCWSTR lpExistingFileName,
    LPCWSTR lpNewFileName,
        DWORD    dwFlags
    );

BOOL
MoveFileWithProgressW(
        LPCWSTR lpExistingFileName,
    LPCWSTR lpNewFileName,
    LPPROGRESS_ROUTINE lpProgressRoutine,
    LPVOID lpData,
        DWORD dwFlags
    );

BOOL
ReadDirectoryChangesW(
    HANDLE hDirectory,
    LPVOID lpBuffer,
    DWORD nBufferLength,
    BOOL bWatchSubtree,
    DWORD dwNotifyFilter,
    LPDWORD lpBytesReturned,
    LPOVERLAPPED lpOverlapped,
    LPOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
    );

HANDLE
ReOpenFile(
    HANDLE  hOriginalFile,
    DWORD   dwDesiredAccess,
    DWORD   dwShareMode,
    DWORD   dwFlagsAndAttributes
    );

BOOL
ReplaceFileW(
    LPCWSTR lpReplacedFileName,
    LPCWSTR lpReplacementFileName,
    LPCWSTR lpBackupFileName,
    DWORD    dwReplaceFlags,
    LPVOID   lpExclude,
    LPVOID  lpReserved
    );
]]

return {
--CopyFile2
	CopyFileExW = k32Lib.CopyFileExW,
	CreateDirectoryExW = k32Lib.CreateDirectoryExW,
	CreateHardLinkW = k32Lib.CreateHardLinkW,
	CreateSymbolicLinkW = k32Lib.CreateSymbolicLinkW,
	GetFileInformationByHandleEx = k32Lib.GetFileInformationByHandleEx,
	MoveFileExW = k32Lib.MoveFileExW,
	MoveFileWithProgressW = k32Lib.MoveFileWithProgressW,
	ReadDirectoryChangesW = k32Lib.ReadDirectoryChangesW,
	ReOpenFile = k32Lib.ReOpenFile,
	ReplaceFileW = k32Lib.ReplaceFileW,
}
