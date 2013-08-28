-- Desktop_ffi.lua
local ffi = require "ffi"

local WTypes = require "WTypes"
local WinNT = require("WinNT");
local user32_ffi = require("user32_ffi");

ffi.cdef[[

typedef BOOL (__stdcall *DESKTOPENUMPROCA)(LPTSTR lpszDesktop, LPARAM lParam);
typedef BOOL (__stdcall *WINSTAENUMPROCA)(LPTSTR stationname, LPARAM lParam);



// CloseDesktop
BOOL CloseDesktop(HDESK hDesktop);

// CreateDesktop
HDESK CreateDesktopA(LPCTSTR lpszDesktop, LPCTSTR lpszDevice,
	PDEVMODE pDevmode,DWORD dwFlags,
	ACCESS_MASK dwDesiredAccess, LPSECURITY_ATTRIBUTES lpsa);


// EnumDesktops
BOOL EnumDesktopsA(HWINSTA hwinsta, DESKTOPENUMPROCA lpEnumFunc, LPARAM lParam);

// EnumDesktopWindows
BOOL EnumDesktopWindows(HDESK hDesktop, WNDENUMPROC lpfn, LPARAM lParam);


// GetThreadDesktop
HDESK GetThreadDesktop(DWORD dwThreadId);

// OpenDesktop
HDESK
OpenDesktopA(
    LPCSTR lpszDesktop,
    DWORD dwFlags,
    BOOL fInherit,
    ACCESS_MASK dwDesiredAccess);


// OpenInputDesktop
HDESK OpenInputDesktop(DWORD dwFlags, BOOL fInherit, ACCESS_MASK dwDesiredAccess);

// SetThreadDesktop
BOOL SetThreadDesktop(HDESK hDesktop);

// SwitchDesktop
BOOL SwitchDesktop(HDESK hDesktop);

// PaintDesktop
BOOL PaintDesktop(HDC hdc);


// Window Station
BOOL CloseWindowStation(HWINSTA hWinSta);

HWINSTA CreateWindowStationA(LPCTSTR lpwinsta,
  DWORD dwFlags,
  ACCESS_MASK dwDesiredAccess,
  LPSECURITY_ATTRIBUTES lpsa);

BOOL EnumWindowStationsA(WINSTAENUMPROCA lpEnumFunc, LPARAM lParam);


HWINSTA GetProcessWindowStation();

BOOL LockWorkStation(void);

HWINSTA
OpenWindowStationA(
    LPCSTR lpszWinSta,
    BOOL fInherit,
    ACCESS_MASK dwDesiredAccess);

BOOL SetProcessWindowStation(HWINSTA hWinSta);

]]


local Lib = ffi.load("user32");

return 
{
	CloseDesktop = Lib.CloseDesktop,
	CreateDesktopA = Lib.CreateDesktopA,
	EnumDesktopsA = Lib.EnumDesktopsA,
	EnumDesktopWindows = Lib.EnumDesktopWindows,
	GetThreadDesktop = Lib.GetThreadDesktop,
	OpenDesktopA = Lib.OpenDesktopA,
	OpenInputDesktop = Lib.OpenInputDesktop,
	SetThreadDesktop = Lib.SetThreadDesktop,
	SwitchDesktop = Lib.SwitchDesktop,
	PaintDesktop = Lib.PaintDesktop,

	CloseWindowStation = Lib.CloseWindowStation,
	CreateWindowStationA = Lib.CreateWindowStationA,
	EnumWindowStationsA = Lib.EnumWindowStationsA,
	GetProcessWindowStation = Lib.GetProcessWindowStation,
	LockWorkStation = Lib.LockWorkStation,
	OpenWindowStationA = Lib.OpenWindowStationA,
	SetProcessWindowStation = Lib.SetProcessWindowStation,
}