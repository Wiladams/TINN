-- core_io_l1_1_1.lua	
-- api-ms-win-core-io-l1-1-1.dll	

local ffi = require("ffi");
local Lib = ffi.load("kernel32");
local WinBase = require("WinBase");

ffi.cdef[[
BOOL
CancelIo(HANDLE hFile);

BOOL
CancelIoEx(HANDLE hFile,
     LPOVERLAPPED lpOverlapped);

BOOL
CancelSynchronousIo(HANDLE hThread);


HANDLE CreateIoCompletionPort(HANDLE FileHandle,
	HANDLE ExistingCompletionPort,
	ULONG_PTR CompletionKey,
	DWORD NumberOfConcurrentThreads);

BOOL
DeviceIoControl(
    HANDLE hDevice,
    DWORD dwIoControlCode,
    LPVOID lpInBuffer,
    DWORD nInBufferSize,
    LPVOID lpOutBuffer,
    DWORD nOutBufferSize,
    LPDWORD lpBytesReturned,
    LPOVERLAPPED lpOverlapped
    );

BOOL
GetOverlappedResult(
    HANDLE hFile,
    LPOVERLAPPED lpOverlapped,
    LPDWORD lpNumberOfBytesTransferred,
    BOOL bWait
    );

BOOL GetQueuedCompletionStatus(
    HANDLE CompletionPort,
    LPDWORD lpNumberOfBytesTransferred,
    PULONG_PTR lpCompletionKey,
    LPOVERLAPPED *lpOverlapped,
    DWORD dwMilliseconds
    );

BOOL
GetQueuedCompletionStatusEx(
    HANDLE CompletionPort,
    LPOVERLAPPED_ENTRY lpCompletionPortEntries,
    ULONG ulCount,
    PULONG ulNumEntriesRemoved,
    DWORD dwMilliseconds,
    BOOL fAlertable
    );

BOOL PostQueuedCompletionStatus(
	HANDLE CompletionPort,
	DWORD dwNumberOfBytesTransferred,
	ULONG_PTR dwCompletionKey,
	LPOVERLAPPED lpOverlapped
);
]]

return {
    Lib = Lib,
    
	CancelIo = Lib.CancelIo,
	CancelIoEx = Lib.CancelIoEx,
	CancelSynchronousIo = Lib.CancelSynchronousIo,
	CreateIoCompletionPort = Lib.CreateIoCompletionPort,
	DeviceIoControl = Lib.DeviceIoControl,
	GetOverlappedResult = Lib.GetOverlappedResult,
--	GetOverlappedResultEx = Lib.GetOverlappedResultEx,
	GetQueuedCompletionStatus = Lib.GetQueuedCompletionStatus,
	GetQueuedCompletionStatusEx = Lib.GetQueuedCompletionStatusEx,
	PostQueuedCompletionStatus = Lib.PostQueuedCompletionStatus,
}
