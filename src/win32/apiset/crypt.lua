-- crypt.lua
-- crypt.dll

local ffi = require("ffi");

local WTypes = require("WTypes");
local WinCrypt = require("WinCrypt");

local Lib = ffi.load("crypt32");

ffi.cdef[[
typedef struct  _CRYPTPROTECT_PROMPTSTRUCT
{
    DWORD cbSize;
    DWORD dwPromptFlags;
    HWND  hwndApp;
    LPCWSTR szPrompt;
} CRYPTPROTECT_PROMPTSTRUCT, *PCRYPTPROTECT_PROMPTSTRUCT;


BOOL CryptUnprotectData(
  DATA_BLOB *pDataIn,
  LPWSTR *ppszDataDescr,
  DATA_BLOB *pOptionalEntropy,
  PVOID pvReserved,
  CRYPTPROTECT_PROMPTSTRUCT *pPromptStruct,
  DWORD dwFlags,
  DATA_BLOB *pDataOut);
]]

return Lib