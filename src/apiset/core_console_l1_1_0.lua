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

return {
    Lib = k32Lib,
    
    AllocConsole = k32Lib.AllocConsole,
    GetConsoleCP = k32Lib.GetConsoleCP,
    GetConsoleMode = k32Lib.GetConsoleMode,
    GetConsoleOutputCP = k32Lib.GetConsoleOutputCP,
    GetNumberOfConsoleInputEvents = k32Lib.GetNumberOfConsoleInputEvents,
    PeekConsoleInputA = k32Lib.PeekConsoleInputA,
    ReadConsoleA = k32Lib.ReadConsoleA,
    ReadConsoleInputA = k32Lib.ReadConsoleInputA,
    ReadConsoleInputW = k32Lib.ReadConsoleInputW,
    ReadConsoleW = k32Lib.ReadConsoleW,
    SetConsoleCtrlHandler = k32Lib.SetConsoleCtrlHandler,
    SetConsoleMode = k32Lib.SetConsoleMode,
    WriteConsoleA = k32Lib.WriteConsoleA,
    WriteConsoleW = k32Lib.WriteConsoleW,
}

