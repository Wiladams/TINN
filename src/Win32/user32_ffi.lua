local ffi = require "ffi"
local C = ffi.C

require "WTypes"

-- Winnt.h
MAXIMUM_WAIT_OBJECTS = 64     -- Maximum number of wait objects

local user32_ffi = {
	CW_USEDEFAULT = 0x80000000,

	CS_VREDRAW			= 0x0001,
	CS_HREDRAW			= 0x0002,
	CS_DBLCLKS			= 0x0008,
	CS_OWNDC			= 0x0020,
	CS_CLASSDC			= 0x0040,
	CS_NOCLOSE			= 0x0200,
	CS_SAVEBITS			= 0x0800,
	CS_BYTEALIGNCLIENT	= 0x1000,
	CS_BYTEALIGNWINDOW	= 0x2000,
	CS_GLOBALCLASS		= 0x4000,
	CS_DROPSHADOW		= 0x00020000,


	WS_POPUP			= 0x80000000,
	WS_MAXIMIZEBOX 		= 0x00010000,
	WS_SIZEBOX 			= 0x00040000,
	WS_SYSMENU 			= 0x00080000,
	WS_HSCROLL 			= 0x00100000,
	WS_VSCROLL 			= 0x00200000,
	WS_OVERLAPPEDWINDOW = 0x00CF0000,
	WS_MAXIMIZE 		= 0x01000000,
	WS_VISIBLE 			= 0x10000000,
	WS_MINIMIZE 		= 0x20000000,

	WS_EX_WINDOWEDGE	= 0x00000100,
	WS_EX_APPWINDOW		= 0x00040000,

	-- Standard User32 Messages
	WM_CREATE 			= 0x0001,
	WM_DESTROY 			= 0x0002,
	WM_SIZE 			= 0x0005,
	WM_ACTIVATE 		= 0x0006,
	WM_SETFOCUS			= 0x0007,
	WM_KILLFOCUS		= 0x0008,
	WM_ENABLE			= 0x000A,
	WM_SETTEXT 			= 0x000C,
	WM_GETTEXT 			= 0x000D,
	WM_PAINT			= 0x000F,
	WM_CLOSE 			= 0x0010,
	WM_QUIT 			= 0x0012,
	WM_ACTIVATEAPP 		= 0x001C,

	WM_SETCURSOR 		= 0x0020,
	WM_GETMINMAXINFO 	= 0x0024,
	WM_WINDOWPOSCHANGING = 0x0046,
	WM_WINDOWPOSCHANGED = 0x0047,
	WM_NCCREATE 		= 0x0081,
	WM_NCDESTROY 		= 0x0082,
	WM_NCCALCSIZE 		= 0x0083,
	WM_NCHITTEST 		= 0x0084,
	WM_NCPAINT 			= 0x0085,
	WM_NCACTIVATE 		= 0x0086,

	-- Non Client (NC) mouse activity
	WM_NCMOUSEMOVE 		= 0x00A0,
	WM_NCLBUTTONDOWN 	= 0x00A1,
	WM_NCLBUTTONUP 		= 0x00A2,
	WM_NCLBUTTONDBLCLK 	= 0x00A3,
	WM_NCRBUTTONDOWN 	= 0x00A4,
	WM_NCRBUTTONUP 		= 0x00A5,
	WM_NCRBUTTONDBLCLK 	= 0x00A6,
	WM_NCMBUTTONDOWN 	= 0x00A7,
	WM_NCMBUTTONUP 		= 0x00A8,
	WM_NCMBUTTONDBLCLK 	= 0x00A9,

	WM_INPUT_DEVICE_CHANGE = 0x00FE,
	WM_INPUT			= 0x00FF,

	-- Keyboard Activity
	WM_KEYDOWN			= 0x0100,
	WM_KEYUP			= 0x0101,
	WM_CHAR				= 0x0102,
	WM_DEADCHAR			= 0x0103,
	WM_SYSKEYDOWN		= 0x0104,
	WM_SYSKEYUP			= 0x0105,
	WM_SYSCHAR			= 0x0106,
	WM_SYSDEADCHAR		= 0x0107,
	WM_COMMAND			= 0x0111,
	WM_SYSCOMMAND		= 0x0112,


	WM_TIMER = 0x0113,

	-- client area mouse activity
	WM_MOUSEFIRST		= 0x0200,
	WM_MOUSEMOVE		= 0x0200,
	WM_LBUTTONDOWN		= 0x0201,
	WM_LBUTTONUP		= 0x0202,
	WM_LBUTTONDBLCLK	= 0x0203,
	WM_RBUTTONDOWN		= 0x0204,
	WM_RBUTTONUP		= 0x0205,
	WM_RBUTTONDBLCLK	= 0x0206,
	WM_MBUTTONDOWN		= 0x0207,
	WM_MBUTTONUP		= 0x0208,
	WM_MBUTTONDBLCLK	= 0x0209,
	WM_MOUSEWHEEL		= 0x020A,
	WM_XBUTTONDOWN		= 0x020B,
	WM_XBUTTONUP		= 0x020C,
	WM_XBUTTONDBLCLK	= 0x020D,
	WM_MOUSELAST		= 0x020D,

	WM_SIZING 			= 0x0214,
	WM_CAPTURECHANGED 	= 0x0215,
	WM_MOVING 			= 0x0216,
	WM_DEVICECHANGE 	= 0x0219,

	WM_ENTERSIZEMOVE 	= 0x0231,
	WM_EXITSIZEMOVE 	= 0x0232,
	WM_DROPFILES 		= 0x0233,

	WM_IME_SETCONTEXT 	= 0x0281,
	WM_IME_NOTIFY 		= 0x0282,

	WM_NCMOUSEHOVER		= 0x02A0,
	WM_MOUSEHOVER 		= 0x02A1,
	WM_NCMOUSELEAVE		= 0x02A2,
	WM_MOUSELEAVE		= 0x02A3,

	WM_PRINT = 0x0317,

	WM_DWMCOMPOSITIONCHANGED  =      0x031E,
	WM_DWMNCRENDERINGCHANGED  =      0x031F,
	WM_DWMCOLORIZATIONCOLORCHANGED = 0x0320,
	WM_DWMWINDOWMAXIMIZEDCHANGE    = 0x0321,


	SW_SHOW = 5,

	PM_REMOVE = 0x0001,
	PM_NOYIELD = 0x0002,

	-- dwWakeMask of MsgWaitForMultipleObjectsEx()
	QS_KEY				= 0x0001,
	QS_MOUSEMOVE		= 0x0002,
	QS_MOUSEBUTTON		= 0x0004,
	QS_MOUSE			= 0x0006,
	QS_POSTMESSAGE		= 0x0008,
	QS_TIMER			= 0x0010,
	QS_PAINT			= 0x0020,
	QS_SENDMESSAGE		= 0x0040,
	QS_HOTKEY			= 0x0080,
	QS_ALLPOSTMESSAGE	= 0x0100,
	QS_RAWINPUT			= 0x0400,
	QS_INPUT			= 0x0407,
	QS_ALLEVENTS		= 0x04BF,
	QS_ALLINPUT			= 0x04FF,

	-- dwFlags of MsgWaitForMultipleObjectsEx()
	MWMO_WAITALL		= 0x0001,
	MWMO_ALERTABLE		= 0x0002,
	MWMO_INPUTAVAILABLE	= 0x0004,

      WAIT_OBJECT_0 	= 0x00000000,
      INFINITE 			=  0xFFFFFFFF,

	HWND_DESKTOP    	= 0x0000,
	HWND_BROADCAST  	= 0xffff,
	HWND_TOP        	= (0),
	HWND_BOTTOM     	= (1),
	HWND_TOPMOST    	= (-1),
	HWND_NOTOPMOST  	= (-2),
	HWND_MESSAGE 		= (-3),


	-- Used for GetSystemMetrics
	CXSCREEN = 0,
	CYSCREEN = 1,
	CXVSCROLL = 2,
	CYHSCROLL = 3,
	CYCAPTION = 4,
	CXBORDER = 5,
	CYBORDER = 6,
	CXDLGFRAME = 7,
	CXFIXEDFRAME = 7,
	CYDLGFRAME = 8,
	CYFIXEDFRAME = 8,
	CYVTHUMB = 9,
	CXHTHUMB = 10,
	CXICON = 11,
	CYICON = 12,
	CXCURSOR = 13,
	CYCURSOR = 14,
	CYMENU = 15,
	CXFULLSCREEN = 16,
	CYFULLSCREEN = 17,
	CYKANJIWINDOW = 18,
	MOUSEPRESENT = 19,
	CYVSCROLL = 20,
	CXHSCROLL = 21,
	DEBUG = 22,
	SWAPBUTTON = 23,
	RESERVED1 = 24,
	RESERVED2 = 25,
	RESERVED3 = 26,
	RESERVED4 = 27,
	CXMIN = 28,
	CYMIN = 29,
	CXSIZE = 30,
	CYSIZE = 31,
	CXSIZEFRAME = 32,
	CXFRAME = 32,
	CYFRAME = 33,
	CYSIZEFRAME = 33,
	CXMINTRACK = 34,
	CYMINTRACK = 35,
	CXDOUBLECLK = 36,
	CYDOUBLECLK = 37,
	CXICONSPACING = 38,
	CYICONSPACING = 39,
	MENUDROPALIGNMENT = 40,
	PENWINDOWS = 41,
	DBCSENABLED = 42,
	CMOUSEBUTTONS = 43,
	SECURE = 44,
	CXEDGE = 45,
	CYEDGE = 46,
	CXMINSPACING = 47,
	CYMINSPACING = 48,
	CXSMICON = 49,
	CYSMICON = 50,
	CYSMCAPTION = 51,
	CXSMSIZE = 52,
	CYSMSIZE = 53,
	CXMENUSIZE = 54,
	CYMENUSIZE = 55,
	ARRANGE = 56,
	CXMINIMIZED = 57,
	CYMINIMIZED = 58,
	CXMAXTRACK = 59,
	CYMAXTRACK = 60,
	CXMAXIMIZED = 61,
	CYMAXIMIZED = 62,
	NETWORK = 63,
	CLEANBOOT = 67,
	CXDRAG = 68,
	CYDRAG = 69,
	SHOWSOUNDS = 70,
	CXMENUCHECK = 71,
	CYMENUCHECK = 72,
	SLOWMACHINE = 73,
	MIDEASTENABLED = 74,
	MOUSEWHEELPRESENT = 75,
	XVIRTUALSCREEN = 76,
	YVIRTUALSCREEN = 77,
	CXVIRTUALSCREEN = 78,
	CYVIRTUALSCREEN = 79,
	CMONITORS = 80,
	SAMEDISPLAYFORMAT = 81,
	CMETRICS = 83,


}

-- Input handling
ffi.cdef[[
static const int MOUSEEVENTF_ABSOLUTE = 0x8000;
static const int MOUSEEVENTF_HWHEEL = 0x01000;
static const int MOUSEEVENTF_MOVE = 0x0001;
static const int MOUSEEVENTF_MOVE_NOCOALESCE = 0x2000;
static const int MOUSEEVENTF_LEFTDOWN = 0x0002;
static const int MOUSEEVENTF_LEFTUP = 0x0004;
static const int MOUSEEVENTF_RIGHTDOWN = 0x0008;
static const int MOUSEEVENTF_RIGHTUP = 0x0010;
static const int MOUSEEVENTF_MIDDLEDOWN = 0x0020;
static const int MOUSEEVENTF_MIDDLEUP = 0x0040;
static const int MOUSEEVENTF_VIRTUALDESK = 0x4000;
static const int MOUSEEVENTF_WHEEL = 0x0800;
static const int MOUSEEVENTF_XDOWN = 0x0080;
static const int MOUSEEVENTF_XUP = 0x0100;

typedef struct tagMOUSEINPUT {
  LONG      dx;
  LONG      dy;
  DWORD     mouseData;
  DWORD     dwFlags;
  DWORD     time;
  ULONG_PTR dwExtraInfo;
} MOUSEINPUT, *PMOUSEINPUT;

static const int KEYEVENTF_EXTENDEDKEY = 0x0001;
static const int KEYEVENTF_KEYUP = 0x0002;
static const int KEYEVENTF_SCANCODE = 0x0008;
static const int KEYEVENTF_UNICODE = 0x0004;

typedef struct tagKEYBDINPUT {
  WORD      wVk;
  WORD      wScan;
  DWORD     dwFlags;
  DWORD     time;
  ULONG_PTR dwExtraInfo;
} KEYBDINPUT, *PKEYBDINPUT;

typedef struct tagHARDWAREINPUT {
  DWORD uMsg;
  WORD  wParamL;
  WORD  wParamH;
} HARDWAREINPUT, *PHARDWAREINPUT;


static const int INPUT_MOUSE = 0;
static const int INPUT_KEYBOARD = 1;
static const int INPUT_HARDWARE = 2;

typedef struct tagINPUT {
  DWORD type;
  union {
    MOUSEINPUT    mi;
    KEYBDINPUT    ki;
    HARDWAREINPUT hi;
  };
} INPUT, *PINPUT;

UINT SendInput(
    UINT nInputs,
    PINPUT pInputs,
    int cbSize
);
]]


-- WINDOW CONSTRUCTION
ffi.cdef[[
typedef LRESULT (__stdcall *WNDPROC) (HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);
typedef LRESULT (__stdcall *MsgProc) (HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);

typedef struct {
    HWND hwnd;
    UINT message;
    WPARAM wParam;
    LPARAM lParam;
    DWORD time;
    POINT pt;
} MSG, *PMSG;

typedef struct {
    UINT style;
    WNDPROC lpfnWndProc;
    int cbClsExtra;
    int cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    LPCSTR lpszMenuName;
    LPCSTR lpszClassName;
} WNDCLASSA, *PWNDCLASSA;

typedef struct {
    UINT cbSize;
    UINT style;
    WNDPROC lpfnWndProc;
    int cbClsExtra;
    int cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    LPCSTR lpszMenuName;
    LPCSTR lpszClassName;
    HICON hIconSm;
} WNDCLASSEXA, *PWNDCLASSEXA;



typedef struct tagCREATESTRUCT {
    LPVOID lpCreateParams;
    HINSTANCE hInstance;
    HMENU hMenu;
    HWND hwndParent;
    int cy;
    int cx;
    int y;
    int x;
    LONG style;
    LPCSTR lpszName;
    LPCSTR lpszClass;
    DWORD dwExStyle;
} CREATESTRUCTA, *LPCREATESTRUCTA;

typedef struct {
    POINT ptReserved;
    POINT ptMaxSize;
    POINT ptMaxPosition;
    POINT ptMinTrackSize;
    POINT ptMaxTrackSize;
} MINMAXINFO, *PMINMAXINFO;



static const int	CCHDEVICENAME = 32;
static const int 	CCHFORMNAME = 32;


typedef struct _devicemode {
  BCHAR  dmDeviceName[CCHDEVICENAME];
  WORD   dmSpecVersion;
  WORD   dmDriverVersion;
  WORD   dmSize;
  WORD   dmDriverExtra;
  DWORD  dmFields;
  union {
    struct {
      short dmOrientation;
      short dmPaperSize;
      short dmPaperLength;
      short dmPaperWidth;
      short dmScale;
      short dmCopies;
      short dmDefaultSource;
      short dmPrintQuality;
    };
    POINTL dmPosition;
    DWORD  dmDisplayOrientation;
    DWORD  dmDisplayFixedOutput;
  };

  short  dmColor;
  short  dmDuplex;
  short  dmYResolution;
  short  dmTTOption;
  short  dmCollate;
  BYTE  dmFormName[CCHFORMNAME];
  WORD  dmLogPixels;
  DWORD  dmBitsPerPel;
  DWORD  dmPelsWidth;
  DWORD  dmPelsHeight;
  union {
    DWORD  dmDisplayFlags;
    DWORD  dmNup;
  };
  DWORD  dmDisplayFrequency;
  DWORD  dmICMMethod;
  DWORD  dmICMIntent;
  DWORD  dmMediaType;
  DWORD  dmDitherType;
  DWORD  dmReserved1;
  DWORD  dmReserved2;
  DWORD  dmPanningWidth;
  DWORD  dmPanningHeight;
} DEVMODE, *PDEVMODE;



]]




-- Windows functions
ffi.cdef[[

DWORD MsgWaitForMultipleObjects(
	DWORD nCount,
	const HANDLE* pHandles,
	BOOL bWaitAll,
	DWORD dwMilliseconds);

DWORD MsgWaitForMultipleObjectsEx(
	DWORD nCount,
	const HANDLE* pHandles,
	DWORD dwMilliseconds,
	DWORD dwWakeMask,
	DWORD dwFlags
);

// PostMessage
BOOL PostMessage(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);

// PostQuitMessage
void PostQuitMessage(int nExitCode);

// PostThreadMessage
BOOL PostThreadMessageA(DWORD idThread, UINT Msg, WPARAM wParam, LPARAM lParam);

// SendMessage
int SendMessageA(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);

//int SendMessageW([In] IntPtr hWnd, int Msg, IntPtr wParam, IntPtr lParam);

// TranslateMessage
BOOL TranslateMessage(const MSG *lpMsg);

// DispatchMessage
LRESULT DispatchMessageA(const MSG *lpmsg);

// GetMessage
BOOL GetMessageA(PMSG lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax);

// GetMessageExtraInfo
LPARAM GetMessageExtraInfo(void);

// PeekMessage
BOOL PeekMessageA(PMSG lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax, UINT wRemoveMsg);

// WaitMessage
BOOL WaitMessage(void);
]]

ffi.cdef[[

LRESULT CallWindowProc(WNDPROC lpPrevWndFunc, HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);

LRESULT DefWindowProcA(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);


ATOM RegisterClassExA(const WNDCLASSEXA *lpwcx);
ATOM RegisterClassA(const WNDCLASSA *lpWndClass);

HWND CreateWindow(
		LPCSTR lpClassName,
		LPCSTR lpWindowName,
		DWORD dwStyle,
		int x,
		int y,
		int nWidth,
		int nHeight,
		HWND hWndParent,
		HMENU hMenu,
		HINSTANCE hInstance,
		LPVOID lpParam);

HWND CreateWindowExA(
	DWORD dwExStyle,
	const LPCSTR lpClassName,
	const LPCSTR lpWindowName,
	DWORD dwStyle,
	int x,
	int y,
	int nWidth,
	int nHeight,
	HWND hWndParent,
	HMENU hMenu,
	HINSTANCE hInstance,
	LPVOID lpParam
	);

BOOL DestroyWindow(HWND hWnd);

BOOL ShowWindow(HWND hWnd, int nCmdShow);

BOOL UpdateWindow(HWND hWnd);

HICON LoadIconA(HINSTANCE hInstance, LPCSTR lpIconName);

HCURSOR LoadCursorA(HINSTANCE hInstance, LPCSTR lpCursorName);

int GetClientRect(HWND hWnd, RECT *rect);


]]

-- System related calls
ffi.cdef[[
int GetSystemMetrics(int nIndex);
]]


-- WINDOW DRAWING
ffi.cdef[[
HDC GetDC(HWND hWnd);

HDC GetWindowDC(HWND hWnd);
BOOL InvalidateRect(HWND hWnd, const RECT* lpRect, BOOL bErase);


// WINDOW UTILITIES


typedef BOOL (*WNDENUMPROC)(HWND hwnd, LPARAM l);

int EnumWindows(WNDENUMPROC func, LPARAM l);

HWND GetForegroundWindow(void);

BOOL MessageBeep(UINT type);

int MessageBoxA(HWND hWnd,
		LPCTSTR lpText,
		LPCTSTR lpCaption,
		UINT uType
	);
]]

-- Window Station
ffi.cdef[[
BOOL  CloseWindowStation(HWINSTA hWinSta);

HWINSTA  CreateWindowStation(
	LPCTSTR lpwinsta,
	DWORD dwFlags,
	ACCESS_MASK dwDesiredAccess,
	LPSECURITY_ATTRIBUTES lpsa
);


// Callback function for EnumWindowStations
typedef BOOL (__stdcall *WINSTAENUMPROC) (LPTSTR lpszWindowStation,LPARAM lParam);

BOOL  EnumWindowStations(WINSTAENUMPROC lpEnumFunc, LPARAM lParam);

HWINSTA  GetProcessWindowStation(void);

HWINSTA  OpenWindowStationA(LPTSTR lpszWinSta, BOOL fInherit, ACCESS_MASK dwDesiredAccess);
HWINSTA  OpenWindowStationW(LPTSTR lpszWinSta, BOOL fInherit, ACCESS_MASK dwDesiredAccess);

BOOL  SetProcessWindowStation(HWINSTA hWinSta);

BOOL  GetUserObjectInformation(HANDLE hObj,
    int nIndex,
	PVOID pvInfo,
    DWORD nLength,
	LPDWORD lpnLengthNeeded
);

/*
BOOL  GetUserObjectSecurity(HANDLE hObj,
	PSECURITY_INFORMATION pSIRequested,
	PSECURITY_DESCRIPTOR pSD,
	DWORD nLength,
	LPDWORD lpnLengthNeeded
);


BOOL  SetUserObjectInformation(HANDLE hObj,
  int nIndex,
  PVOID pvInfo,
  DWORD nLength
);

BOOL  SetUserObjectSecurity(HANDLE hObj,
  PSECURITY_INFORMATION pSIRequested,
  PSECURITY_DESCRIPTOR pSID
);
*/
]]


return user32_ffi
