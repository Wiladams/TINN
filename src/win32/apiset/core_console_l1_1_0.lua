-- core-console-l1-1-0.lua
-- api-ms-win-core-console-l1-1-0.dll	

local ffi = require("ffi");
require ("WTypes");
local k32Lib = ffi.load("kernel32");
local WinCon = require("WinCon");


ffi.cdef[[
BOOL
AllocConsole(void);

UINT
GetConsoleCP(void);

BOOL
GetConsoleMode(HANDLE hConsoleHandle, LPDWORD lpMode);

UINT
GetConsoleOutputCP(void);

BOOL
GetNumberOfConsoleInputEvents(HANDLE hConsoleInput,LPDWORD lpNumberOfEvents);

BOOL
PeekConsoleInputA(
    HANDLE hConsoleInput,
    PINPUT_RECORD lpBuffer,
    DWORD nLength,
    LPDWORD lpNumberOfEventsRead
    );

BOOL
ReadConsoleA(
    HANDLE hConsoleInput,
    LPVOID lpBuffer,
    DWORD nNumberOfCharsToRead,
    LPDWORD lpNumberOfCharsRead,
    PCONSOLE_READCONSOLE_CONTROL pInputControl
    );

BOOL
ReadConsoleInputA(
    HANDLE hConsoleInput,
    PINPUT_RECORD lpBuffer,
    DWORD nLength,
    LPDWORD lpNumberOfEventsRead
    );

BOOL
ReadConsoleInputW(
    HANDLE hConsoleInput,
    PINPUT_RECORD lpBuffer,
    DWORD nLength,
    LPDWORD lpNumberOfEventsRead
    );

BOOL
ReadConsoleW(
    HANDLE hConsoleInput,
    LPVOID lpBuffer,
    DWORD nNumberOfCharsToRead,
    LPDWORD lpNumberOfCharsRead,
    PCONSOLE_READCONSOLE_CONTROL pInputControl
    );

BOOL
SetConsoleCtrlHandler(PHANDLER_ROUTINE HandlerRoutine, BOOL Add);

BOOL
SetConsoleMode(HANDLE hConsoleHandle, DWORD dwMode);

BOOL
WriteConsoleA(HANDLE hConsoleOutput,
    const void *lpBuffer,
    DWORD nNumberOfCharsToWrite,
     LPDWORD lpNumberOfCharsWritten,
     LPVOID lpReserved);

BOOL
WriteConsoleW(HANDLE hConsoleOutput,
    const void *lpBuffer,
    DWORD nNumberOfCharsToWrite,
     LPDWORD lpNumberOfCharsWritten,
     LPVOID lpReserved);
]]

return k32Lib;
