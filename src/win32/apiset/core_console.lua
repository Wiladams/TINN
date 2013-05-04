-- core-console-l1-1-0.lua
-- api-ms-win-core-console-l1-1-0.dll	

local ffi = require("ffi");
require ("WTypes");
local k32Lib = ffi.load("kernel32");

NOGDI = true;

ffi.cdef[[
typedef int16_t     SHORT;
]]

ffi.cdef[[
typedef struct _COORD {
    SHORT X;
    SHORT Y;
} COORD, *PCOORD;

typedef struct _SMALL_RECT {
    SHORT Left;
    SHORT Top;
    SHORT Right;
    SHORT Bottom;
} SMALL_RECT, *PSMALL_RECT;

typedef struct _KEY_EVENT_RECORD {
    BOOL bKeyDown;
    WORD wRepeatCount;
    WORD wVirtualKeyCode;
    WORD wVirtualScanCode;
    union {
        WCHAR UnicodeChar;
        CHAR   AsciiChar;
    } uChar;
    DWORD dwControlKeyState;
} KEY_EVENT_RECORD, *PKEY_EVENT_RECORD;

//
// ControlKeyState flags
//

static const int RIGHT_ALT_PRESSED     = 0x0001; // the right alt key is pressed.
static const int LEFT_ALT_PRESSED      = 0x0002; // the left alt key is pressed.
static const int RIGHT_CTRL_PRESSED    = 0x0004; // the right ctrl key is pressed.
static const int LEFT_CTRL_PRESSED     = 0x0008; // the left ctrl key is pressed.
static const int SHIFT_PRESSED         = 0x0010; // the shift key is pressed.
static const int NUMLOCK_ON            = 0x0020; // the numlock light is on.
static const int SCROLLLOCK_ON         = 0x0040; // the scrolllock light is on.
static const int CAPSLOCK_ON           = 0x0080; // the capslock light is on.
static const int ENHANCED_KEY          = 0x0100; // the key is enhanced.
static const int NLS_DBCSCHAR          = 0x00010000; // DBCS for JPN: SBCS/DBCS mode.
static const int NLS_ALPHANUMERIC      = 0x00000000; // DBCS for JPN: Alphanumeric mode.
static const int NLS_KATAKANA          = 0x00020000; // DBCS for JPN: Katakana mode.
static const int NLS_HIRAGANA          = 0x00040000; // DBCS for JPN: Hiragana mode.
static const int NLS_ROMAN             = 0x00400000; // DBCS for JPN: Roman/Noroman mode.
static const int NLS_IME_CONVERSION    = 0x00800000; // DBCS for JPN: IME conversion.
static const int NLS_IME_DISABLE       = 0x20000000; // DBCS for JPN: IME enable/disable.

typedef struct _MOUSE_EVENT_RECORD {
    COORD dwMousePosition;
    DWORD dwButtonState;
    DWORD dwControlKeyState;
    DWORD dwEventFlags;
} MOUSE_EVENT_RECORD, *PMOUSE_EVENT_RECORD;

//
// ButtonState flags
//

static const int FROM_LEFT_1ST_BUTTON_PRESSED    =0x0001;
static const int RIGHTMOST_BUTTON_PRESSED        =0x0002;
static const int FROM_LEFT_2ND_BUTTON_PRESSED    =0x0004;
static const int FROM_LEFT_3RD_BUTTON_PRESSED    =0x0008;
static const int FROM_LEFT_4TH_BUTTON_PRESSED    =0x0010;

//
// EventFlags
//

static const int MOUSE_MOVED   =0x0001;
static const int DOUBLE_CLICK  =0x0002;
static const int MOUSE_WHEELED =0x0004;
static const int MOUSE_HWHEELED =0x0008;


typedef struct _WINDOW_BUFFER_SIZE_RECORD {
    COORD dwSize;
} WINDOW_BUFFER_SIZE_RECORD, *PWINDOW_BUFFER_SIZE_RECORD;

typedef struct _MENU_EVENT_RECORD {
    UINT dwCommandId;
} MENU_EVENT_RECORD, *PMENU_EVENT_RECORD;

typedef struct _FOCUS_EVENT_RECORD {
    BOOL bSetFocus;
} FOCUS_EVENT_RECORD, *PFOCUS_EVENT_RECORD;

typedef struct _INPUT_RECORD {
    WORD EventType;
    union {
        KEY_EVENT_RECORD KeyEvent;
        MOUSE_EVENT_RECORD MouseEvent;
        WINDOW_BUFFER_SIZE_RECORD WindowBufferSizeEvent;
        MENU_EVENT_RECORD MenuEvent;
        FOCUS_EVENT_RECORD FocusEvent;
    } Event;
} INPUT_RECORD, *PINPUT_RECORD;

//
//  EventType flags:
//

static const int KEY_EVENT         =0x0001; // Event contains key event record
static const int MOUSE_EVENT       =0x0002; // Event contains mouse event record
static const int WINDOW_BUFFER_SIZE_EVENT =0x0004; // Event contains window change event record
static const int MENU_EVENT =0x0008; // Event contains menu event record
static const int FOCUS_EVENT =0x0010; // event contains focus change

typedef struct _CHAR_INFO {
    union {
        WCHAR UnicodeChar;
        CHAR   AsciiChar;
    } Char;
    WORD Attributes;
} CHAR_INFO, *PCHAR_INFO;

//
// Attributes flags:
//

static const int FOREGROUND_BLUE      = 0x0001; // text color contains blue.
static const int FOREGROUND_GREEN     = 0x0002; // text color contains green.
static const int FOREGROUND_RED       = 0x0004; // text color contains red.
static const int FOREGROUND_INTENSITY = 0x0008; // text color is intensified.
static const int BACKGROUND_BLUE      = 0x0010; // background color contains blue.
static const int BACKGROUND_GREEN     = 0x0020; // background color contains green.
static const int BACKGROUND_RED       = 0x0040; // background color contains red.
static const int BACKGROUND_INTENSITY = 0x0080; // background color is intensified.
static const int COMMON_LVB_LEADING_BYTE    = 0x0100; // Leading Byte of DBCS
static const int COMMON_LVB_TRAILING_BYTE   = 0x0200; // Trailing Byte of DBCS
static const int COMMON_LVB_GRID_HORIZONTAL = 0x0400; // DBCS: Grid attribute: top horizontal.
static const int COMMON_LVB_GRID_LVERTICAL  = 0x0800; // DBCS: Grid attribute: left vertical.
static const int COMMON_LVB_GRID_RVERTICAL  = 0x1000; // DBCS: Grid attribute: right vertical.
static const int COMMON_LVB_REVERSE_VIDEO   = 0x4000; // DBCS: Reverse fore/back ground attribute.
static const int COMMON_LVB_UNDERSCORE      = 0x8000; // DBCS: Underscore.

static const int COMMON_LVB_SBCSDBCS        = 0x0300; // SBCS or DBCS flag.


typedef struct _CONSOLE_SCREEN_BUFFER_INFO {
    COORD dwSize;
    COORD dwCursorPosition;
    WORD  wAttributes;
    SMALL_RECT srWindow;
    COORD dwMaximumWindowSize;
} CONSOLE_SCREEN_BUFFER_INFO, *PCONSOLE_SCREEN_BUFFER_INFO;

typedef struct _CONSOLE_SCREEN_BUFFER_INFOEX {
    ULONG cbSize;
    COORD dwSize;
    COORD dwCursorPosition;
    WORD wAttributes;
    SMALL_RECT srWindow;
    COORD dwMaximumWindowSize;
    WORD wPopupAttributes;
    BOOL bFullscreenSupported;
    COLORREF ColorTable[16];
} CONSOLE_SCREEN_BUFFER_INFOEX, *PCONSOLE_SCREEN_BUFFER_INFOEX;

typedef struct _CONSOLE_CURSOR_INFO {
    DWORD  dwSize;
    BOOL   bVisible;
} CONSOLE_CURSOR_INFO, *PCONSOLE_CURSOR_INFO;

typedef struct _CONSOLE_FONT_INFO {
    DWORD  nFont;
    COORD  dwFontSize;
} CONSOLE_FONT_INFO, *PCONSOLE_FONT_INFO;
]]

if not NOGDI then
ffi.cdef[[
typedef struct _CONSOLE_FONT_INFOEX {
    ULONG cbSize;
    DWORD nFont;
    COORD dwFontSize;
    UINT FontFamily;
    UINT FontWeight;
    WCHAR FaceName[LF_FACESIZE];
} CONSOLE_FONT_INFOEX, *PCONSOLE_FONT_INFOEX;
]]
end

ffi.cdef[[
static const int HISTORY_NO_DUP_FLAG = 0x1;

typedef struct _CONSOLE_HISTORY_INFO {
    UINT cbSize;
    UINT HistoryBufferSize;
    UINT NumberOfHistoryBuffers;
    DWORD dwFlags;
} CONSOLE_HISTORY_INFO, *PCONSOLE_HISTORY_INFO;

typedef struct _CONSOLE_SELECTION_INFO {
    DWORD dwFlags;
    COORD dwSelectionAnchor;
    SMALL_RECT srSelection;
} CONSOLE_SELECTION_INFO, *PCONSOLE_SELECTION_INFO;

//
// Selection flags
//

static const int CONSOLE_NO_SELECTION            = 0x0000;
static const int CONSOLE_SELECTION_IN_PROGRESS   = 0x0001  ; // selection has begun
static const int CONSOLE_SELECTION_NOT_EMPTY     = 0x0002  ; // non-null select rectangle
static const int CONSOLE_MOUSE_SELECTION         = 0x0004  ; // selecting with mouse
static const int CONSOLE_MOUSE_DOWN              = 0x0008  ; // mouse is down

static const int CTRL_C_EVENT        =0;
static const int CTRL_BREAK_EVENT    =1;
static const int CTRL_CLOSE_EVENT    =2;
// 3 is reserved!
// 4 is reserved!
static const int CTRL_LOGOFF_EVENT   =5;
static const int CTRL_SHUTDOWN_EVENT =6;

//
//  Input Mode flags:
//

static const int ENABLE_PROCESSED_INPUT  = 0x0001;
static const int ENABLE_LINE_INPUT       = 0x0002;
static const int ENABLE_ECHO_INPUT       = 0x0004;
static const int ENABLE_WINDOW_INPUT     = 0x0008;
static const int ENABLE_MOUSE_INPUT      = 0x0010;
static const int ENABLE_INSERT_MODE      = 0x0020;
static const int ENABLE_QUICK_EDIT_MODE  = 0x0040;
static const int ENABLE_EXTENDED_FLAGS   = 0x0080;
static const int ENABLE_AUTO_POSITION    = 0x0100;

//
// Output Mode flags:
//

static const int ENABLE_PROCESSED_OUTPUT    = 0x0001;
static const int ENABLE_WRAP_AT_EOL_OUTPUT  = 0x0002;




typedef BOOL ( *PHANDLER_ROUTINE)(DWORD CtrlType);

typedef struct _CONSOLE_READCONSOLE_CONTROL {
    ULONG nLength;
    ULONG nInitialChars;
    ULONG dwCtrlWakeupMask;
    ULONG dwControlKeyState;
} CONSOLE_READCONSOLE_CONTROL, *PCONSOLE_READCONSOLE_CONTROL;

]]

CONSOLE_REAL_OUTPUT_HANDLE = ffi.cast("HANDLE", ffi.cast("LONG_PTR", -2)); -- (LongToHandle(-2))
CONSOLE_REAL_INPUT_HANDLE    = ffi.cast("HANDLE", ffi.cast("LONG_PTR", -3)); -- (LongToHandle(-3))

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
GetNumberOfConsoleInputEvents(
    HANDLE hConsoleInput,
    LPDWORD lpNumberOfEvents
    );

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
