
local ffi = require("ffi");

require("WTypes");
local k32Lib = ffi.load("kernel32");

ffi.cdef[[
BOOL CloseHandle(HANDLE hObject);

BOOL DuplicateHandle(
    HANDLE hSourceProcessHandle,
    HANDLE hSourceHandle,
    HANDLE hTargetProcessHandle,
    LPHANDLE lpTargetHandle,
    DWORD dwDesiredAccess,
    BOOL bInheritHandle,
    DWORD dwOptions);

BOOL GetHandleInformation(HANDLE hObject, LPDWORD lpdwFlags);

BOOL SetHandleInformation(HANDLE hObject, DWORD dwMask, DWORD dwFlags);

static const int HANDLE_FLAG_INHERIT            = 0x00000001;
static const int HANDLE_FLAG_PROTECT_FROM_CLOSE = 0x00000002;
]]

return {
    Lib = k32Lib,
    
	CloseHandle = k32Lib.CloseHandle,
	DuplicateHandle = k32Lib.DuplicateHandle,
	GetHandleInformation = k32Lib.GetHandleInformation,
	SetHandleInformation = k32Lib.SetHandleInformation,

}