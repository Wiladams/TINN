-- test_createprocesswithlogon

local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;
local rshift = bit.rshift;
local lshift = bit.lshift;

local kernel32 = require("win_kernel32");
local k32Lib = kernel32.Lib;
local advlib = ffi.load("AdvApi32");
local L = kernel32.AnsiToUnicode16;


ffi.cdef[[
DWORD
FormatMessageA(
    DWORD dwFlags,
    LPCVOID lpSource,
    DWORD dwMessageId,
    DWORD dwLanguageId,
    LPSTR lpBuffer,
    DWORD nSize,
    va_list *Arguments
    );

static const int FORMAT_MESSAGE_FROM_SYSTEM    = 0x00001000;
static const int LANG_NEUTRAL                  = 0x00;
static const int SUBLANG_DEFAULT               = 0x01;    // user default

]]

MAKELANGID = function(p, s)
  return bor(lshift(s, 10), p);
end

PRIMARYLANGID = function(lgid)
  return band(lgid, 0x3ff);
end

SUBLANGID = function(lgid)
  return rshift(lgid, 10);
end

local function DisplayError(pszAPI)
    local buffSize = 512;
    local lpvMessageBuffer = ffi.new("char[?]", buffSize);
    local errorCode = k32Lib.GetLastError();

    k32Lib.FormatMessageA( ffi.C.FORMAT_MESSAGE_FROM_SYSTEM,
        nil, 
        errorCode, 
        MAKELANGID(ffi.C.LANG_NEUTRAL, ffi.C.SUBLANG_DEFAULT), 
        lpvMessageBuffer, 
        buffSize, 
        nil);

    print("ERROR: API    = ", pszAPI);
    print("   error code = ", errorCode);
    print("      message = ", ffi.string(lpvMessageBuffer));

end


local CreateProcessWithLogon = function(usercreds, lpApplicationName, lpCommandLine)
    local dwLogonFlags = 0;
    local dwCreationFlags = 0;
    local lpEnvironment = nil;
    local lpCurrentDirectory = nil;
    local lpStartupInfo = ffi.new("STARTUPINFOW");

    if lpCommandLine then
      lpCommandLine = L(lpCommandLine);
    end

    lpStartupInfo.cb = ffi.sizeof("STARTUPINFOW");
    lpStartupInfo.lpReserved = nil;
    lpStartupInfo.lpDesktop = nil;
    lpStartupInfo.lpTitle = L"Title";
    lpStartupInfo.dwX = 0;
    lpStartupInfo.dwY = 0;
    lpStartupInfo.dwXSize = 640;
    lpStartupInfo.dwYSize = 480;
    lpStartupInfo.dwXCountChars = 80;
    lpStartupInfo.dwYCountChars = 24;
    lpStartupInfo.dwFillAttribute = 0;
    lpStartupInfo.dwFlags = 0;
    lpStartupInfo.wShowWindow = 0;
    lpStartupInfo.cbReserved2 = 0;
    lpStartupInfo.lpReserved2 = nil;
    --lpStartupInfo.hStdInput =  ;
    --lpStartupInfo.hStdOutput = ;
    --lpStartupInfo.hStdError = ;



    local lpProcessInfo = ffi.new("PPROCESS_INFORMATION");

    local res = advlib.CreateProcessWithLogonW(
      L(usercreds.UserName),
      L(usercreds.Domain),
      L(usercreds.Password),
      dwLogonFlags,
      L(lpApplicationName),
      lpCommandLine,
      dwCreationFlags,
      lpEnvironment,
      lpCurrentDirectory,
      lpStartupInfo,
      lpProcessInfo);

    if res == 0 then
        DisplayError("CreateProcessWithLogonW");
        return false, k32Lib.GetLastError();
    end

    return lpProcessInfo;
end


local usercreds = {UserName = Domain = Password = };

    local res, err = CreateProcessWithLogon(usercreds, "c:\\tools\\tinn\\tinn.exe", "-v");

