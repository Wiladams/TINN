local ffi = require("ffi")

local libraryloader = require("core_libraryloader_l1_1_1");

local WTypes = require("WTypes")

ffi.cdef[[
BOOL QueryWorkingSetEx(HANDLE hProcess,PVOID pv,DWORD cb);
]]

local function main()
	local handle = libraryloader.LoadLibraryExA("psapi", nil, 0);

	proc = libraryloader.GetProcAddress(handle, "QueryWorkingSetEx")

	libraryloader.FreeLibrary(handle)
end

main()


