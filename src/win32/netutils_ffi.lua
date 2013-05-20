-- netutils.lua
-- netutils.dll	

local ffi = require("ffi");
local netutils = ffi.load('netutils');
local lmcons = require("lmcons");

require ("WTypes");

ffi.cdef[[

static const int NERR_Success =        0;       /* Success */

]]

ffi.cdef[[
NET_API_STATUS NetApiBufferAllocate(DWORD ByteCount, LPVOID * Buffer);

NET_API_STATUS NetApiBufferFree (LPVOID Buffer);

NET_API_STATUS NetApiBufferReallocate(LPVOID OldBuffer, DWORD NewByteCount, LPVOID * NewBuffer);

NET_API_STATUS NetApiBufferSize(LPVOID Buffer, LPDWORD ByteCount);

NET_API_STATUS NetRemoteComputerSupports(
    LPCWSTR UncServerName,   // Must start with "\\".
    DWORD OptionsWanted,             // Set SUPPORTS_ bits wanted.
    LPDWORD OptionsSupported);        // Supported features, masked.
]]

return {
	Lib = netutils;

	NetApiBufferAllocate = netutils.NetApiBufferAllocate;
	NetApiBufferFree = netutils.NetApiBufferFree,
	NetApiBufferReallocate = netutils.NetApiBufferReallocate,
	NetApiBufferSize = netutils.NetApiBufferSize,
	NetRemoteComputerSupports = netutils.NetRemoteComputerSupports,
}