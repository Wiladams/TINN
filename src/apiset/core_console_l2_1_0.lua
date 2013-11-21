-- core_console_l2_1_0.lua	
-- api-ms-win-core-console-l2-1-0.dll	
--

local ffi = require("ffi");
local k32Lib = ffi.load("kernel32");
require("WTypes");
require("WinCon");

ffi.cdef[[
BOOL
AttachConsole(
    DWORD dwProcessId);

HANDLE
CreateConsoleScreenBuffer(
    DWORD dwDesiredAccess,
    DWORD dwShareMode,
    const SECURITY_ATTRIBUTES *lpSecurityAttributes,
    DWORD dwFlags,
    LPVOID lpScreenBufferData
    );

BOOL
FillConsoleOutputAttribute(
    HANDLE hConsoleOutput,
    WORD   wAttribute,
    DWORD  nLength,
    COORD  dwWriteCoord,
    LPDWORD lpNumberOfAttrsWritten
    );


BOOL
FillConsoleOutputCharacterA(
    HANDLE hConsoleOutput,
    CHAR  cCharacter,
    DWORD  nLength,
    COORD  dwWriteCoord,
    LPDWORD lpNumberOfCharsWritten
    );

BOOL
FillConsoleOutputCharacterW(
    HANDLE hConsoleOutput,
    WCHAR  cCharacter,
    DWORD  nLength,
    COORD  dwWriteCoord,
    LPDWORD lpNumberOfCharsWritten
    );

BOOL
FlushConsoleInputBuffer(
    HANDLE hConsoleInput
    );

BOOL
FreeConsole(void);

BOOL
GenerateConsoleCtrlEvent(
    DWORD dwCtrlEvent,
    DWORD dwProcessGroupId);

BOOL
GetConsoleCursorInfo(
    HANDLE hConsoleOutput,
    PCONSOLE_CURSOR_INFO lpConsoleCursorInfo
    );

BOOL
GetConsoleScreenBufferInfo(
    HANDLE hConsoleOutput,
    PCONSOLE_SCREEN_BUFFER_INFO lpConsoleScreenBufferInfo
    );

BOOL
GetConsoleScreenBufferInfoEx(
    HANDLE hConsoleOutput,
    PCONSOLE_SCREEN_BUFFER_INFOEX lpConsoleScreenBufferInfoEx);


DWORD
GetConsoleTitleW(
    LPWSTR lpConsoleTitle,
    DWORD nSize
    );

COORD
GetLargestConsoleWindowSize(
    HANDLE hConsoleOutput
    );

BOOL
PeekConsoleInputW(
    HANDLE hConsoleInput,
    PINPUT_RECORD lpBuffer,
    DWORD nLength,
    LPDWORD lpNumberOfEventsRead
    );

BOOL
ReadConsoleOutputA(
    HANDLE hConsoleOutput,
    PCHAR_INFO lpBuffer,
    COORD dwBufferSize,
    COORD dwBufferCoord,
    PSMALL_RECT lpReadRegion
    );

BOOL
ReadConsoleOutputAttribute(
    HANDLE hConsoleOutput,
    LPWORD lpAttribute,
    DWORD nLength,
    COORD dwReadCoord,
    LPDWORD lpNumberOfAttrsRead
    );

BOOL
ReadConsoleOutputCharacterA(
    HANDLE hConsoleOutput,
    LPSTR lpCharacter,
    DWORD nLength,
    COORD dwReadCoord,
    LPDWORD lpNumberOfCharsRead
    );

BOOL
ReadConsoleOutputCharacterW(
    HANDLE hConsoleOutput,
    LPWSTR lpCharacter,
    DWORD nLength,
    COORD dwReadCoord,
    LPDWORD lpNumberOfCharsRead
    );

BOOL
ReadConsoleOutputW(
    HANDLE hConsoleOutput,
    PCHAR_INFO lpBuffer,
    COORD dwBufferSize,
    COORD dwBufferCoord,
    PSMALL_RECT lpReadRegion
    );

BOOL
ScrollConsoleScreenBufferA(
    HANDLE hConsoleOutput,
    const SMALL_RECT *lpScrollRectangle,
    const SMALL_RECT *lpClipRectangle,
    COORD dwDestinationOrigin,
    const CHAR_INFO *lpFill
    );

BOOL
ScrollConsoleScreenBufferW(
    HANDLE hConsoleOutput,
    const SMALL_RECT *lpScrollRectangle,
    const SMALL_RECT *lpClipRectangle,
    COORD dwDestinationOrigin,
    const CHAR_INFO *lpFill
    );

BOOL
SetConsoleActiveScreenBuffer(HANDLE hConsoleOutput);

BOOL
SetConsoleCP(UINT wCodePageID);

BOOL
SetConsoleCursorInfo(
    HANDLE hConsoleOutput,
    const CONSOLE_CURSOR_INFO *lpConsoleCursorInfo
    );

BOOL
SetConsoleCursorPosition(
    HANDLE hConsoleOutput,
    COORD dwCursorPosition
    );

BOOL
SetConsoleOutputCP(
    UINT wCodePageID
    );

BOOL
SetConsoleScreenBufferInfoEx(
    HANDLE hConsoleOutput,
    PCONSOLE_SCREEN_BUFFER_INFOEX lpConsoleScreenBufferInfoEx);


BOOL
SetConsoleScreenBufferSize(
    HANDLE hConsoleOutput,
    COORD dwSize
    );


BOOL
SetConsoleTextAttribute(
    HANDLE hConsoleOutput,
    WORD wAttributes
    );

BOOL
SetConsoleTitleW(LPCWSTR lpConsoleTitle);

BOOL
SetConsoleWindowInfo(
    HANDLE hConsoleOutput,
    BOOL bAbsolute,
    const SMALL_RECT *lpConsoleWindow
    );

BOOL
WriteConsoleInputA(
    HANDLE hConsoleInput,
    const INPUT_RECORD *lpBuffer,
    DWORD nLength,
    LPDWORD lpNumberOfEventsWritten
    );

BOOL
WriteConsoleInputA(
    HANDLE hConsoleInput,
    const INPUT_RECORD *lpBuffer,
    DWORD nLength,
    LPDWORD lpNumberOfEventsWritten
    );

BOOL
WriteConsoleInputW(
    HANDLE hConsoleInput,
    const INPUT_RECORD *lpBuffer,
    DWORD nLength,
    LPDWORD lpNumberOfEventsWritten
    );

BOOL
WriteConsoleOutputA(
    HANDLE hConsoleOutput,
    const CHAR_INFO *lpBuffer,
    COORD dwBufferSize,
    COORD dwBufferCoord,
    PSMALL_RECT lpWriteRegion
    );

BOOL
WriteConsoleOutputAttribute(
    HANDLE hConsoleOutput,
    const WORD *lpAttribute,
    DWORD nLength,
    COORD dwWriteCoord,
    LPDWORD lpNumberOfAttrsWritten
    );

BOOL
WriteConsoleOutputCharacterA(
    HANDLE hConsoleOutput,
    LPCSTR lpCharacter,
    DWORD nLength,
    COORD dwWriteCoord,
    LPDWORD lpNumberOfCharsWritten
    );

BOOL
WriteConsoleOutputCharacterW(
    HANDLE hConsoleOutput,
    LPCWSTR lpCharacter,
    DWORD nLength,
    COORD dwWriteCoord,
    LPDWORD lpNumberOfCharsWritten
    );

BOOL
WriteConsoleOutputW(
    HANDLE hConsoleOutput,
    const CHAR_INFO *lpBuffer,
    COORD dwBufferSize,
    COORD dwBufferCoord,
    PSMALL_RECT lpWriteRegion
    );
]]


return {
	AttachConsole = k32Lib.AttachConsole,
	CreateConsoleScreenBuffer = k32Lib.CreateConsoleScreenBuffer,
	FillConsoleOutputAttribute = k32Lib.FillConsoleOutputAttribute,
	FillConsoleOutputCharacterA = k32Lib.FillConsoleOutputCharacterA,
	FillConsoleOutputCharacterW = k32Lib.FillConsoleOutputCharacterW,
	FlushConsoleInputBuffer = k32Lib.FlushConsoleInputBuffer,
	FreeConsole = k32Lib.FreeConsole,
	GenerateConsoleCtrlEvent = k32Lib.GenerateConsoleCtrlEvent,
	GetConsoleCursorInfo = k32Lib.GetConsoleCursorInfo,
	GetConsoleScreenBufferInfo = k32Lib.GetConsoleScreenBufferInfo,
	GetConsoleScreenBufferInfoEx = k32Lib.GetConsoleScreenBufferInfoEx,
	GetConsoleTitleW = k32Lib.GetConsoleTitleW,
	GetLargestConsoleWindowSize = k32Lib.GetLargestConsoleWindowSize,
	PeekConsoleInputW = k32Lib.PeekConsoleInputW,
	ReadConsoleOutputA = k32Lib.ReadConsoleOutputA,
	ReadConsoleOutputAttribute = k32Lib.ReadConsoleOutputAttribute,
	ReadConsoleOutputCharacterA = k32Lib.ReadConsoleOutputCharacterA,
	ReadConsoleOutputCharacterW = k32Lib.ReadConsoleOutputCharacterW,
	ReadConsoleOutputW = k32Lib.ReadConsoleOutputW,
	ScrollConsoleScreenBufferA = k32Lib.ScrollConsoleScreenBufferA,
	ScrollConsoleScreenBufferW = k32Lib.ScrollConsoleScreenBufferW,
	SetConsoleActiveScreenBuffer = k32Lib.SetConsoleActiveScreenBuffer,
	SetConsoleCP = k32Lib.SetConsoleCP,
	SetConsoleCursorInfo = k32Lib.SetConsoleCursorInfo,
	SetConsoleCursorPosition = k32Lib.SetConsoleCursorPosition,
	SetConsoleOutputCP = k32Lib.SetConsoleOutputCP,
	SetConsoleScreenBufferInfoEx = k32Lib.SetConsoleScreenBufferInfoEx,
	SetConsoleScreenBufferSize = k32Lib.SetConsoleScreenBufferSize,
	SetConsoleTextAttribute = k32Lib.SetConsoleTextAttribute,
	SetConsoleTitleW = k32Lib.SetConsoleTitleW,
	SetConsoleWindowInfo = k32Lib.SetConsoleWindowInfo,
	WriteConsoleInputA = k32Lib.WriteConsoleInputA,
	WriteConsoleInputW = k32Lib.WriteConsoleInputW,
	WriteConsoleOutputA = k32Lib.WriteConsoleOutputA,
	WriteConsoleOutputAttribute = k32Lib.WriteConsoleOutputAttribute,
	WriteConsoleOutputCharacterA = k32Lib.WriteConsoleOutputCharacterA,
	WriteConsoleOutputCharacterW = k32Lib.WriteConsoleOutputCharacterW,
	WriteConsoleOutputW = k32Lib.WriteConsoleOutputW,
}
