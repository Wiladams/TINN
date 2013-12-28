-- core_libraryloader_l1_1_1.lua
-- api-ms-win-core-libraryloader-l1-1-1.dll

local ffi = require("ffi");
local k32Lib = ffi.load("kernel32");
local u32Lib = ffi.load("user32");

ffi.cdef[[
static const int  RESOURCE_ENUM_LN              = (0x0001);
static const int  RESOURCE_ENUM_MUI             = (0x0002);
static const int  RESOURCE_ENUM_MUI_SYSTEM      = (0x0004);
static const int  RESOURCE_ENUM_VALIDATE        = (0x0008);
static const int  RESOURCE_ENUM_MODULE_EXACT    = (0x0010);
]]

ffi.cdef[[
typedef INT_PTR (* FARPROC)();

typedef BOOL (* ENUMRESLANGPROCA)(HMODULE hModule, LPCSTR lpType,
	LPCSTR lpName, WORD  wLanguage, LONG_PTR lParam);
typedef BOOL (* ENUMRESLANGPROCW)(HMODULE hModule, LPCWSTR lpType,
	LPCWSTR lpName, WORD  wLanguage, LONG_PTR lParam);

typedef BOOL (* ENUMRESNAMEPROCA)(HMODULE hModule, LPCSTR lpType,
	LPSTR lpName, LONG_PTR lParam);
typedef BOOL (* ENUMRESNAMEPROCW)(HMODULE hModule, LPCWSTR lpType,
	LPWSTR lpName, LONG_PTR lParam);

typedef BOOL (* ENUMRESTYPEPROCA)(HMODULE hModule, LPSTR lpType,
	LONG_PTR lParam);
typedef BOOL (* ENUMRESTYPEPROCW)(HMODULE hModule, LPWSTR lpType,
	LONG_PTR lParam);

]]


ffi.cdef[[
BOOL
DisableThreadLibraryCalls (HMODULE hLibModule);

BOOL
EnumResourceLanguagesExA(
    HMODULE hModule,
    LPCSTR lpType,
    LPCSTR lpName,
    ENUMRESLANGPROCA lpEnumFunc,
    LONG_PTR lParam,
    DWORD dwFlags,
    LANGID LangId
    );

BOOL
EnumResourceLanguagesExW(
    HMODULE hModule,
    LPCWSTR lpType,
    LPCWSTR lpName,
    ENUMRESLANGPROCW lpEnumFunc,
    LONG_PTR lParam,
    DWORD dwFlags,
    LANGID LangId
    );

BOOL
EnumResourceNamesExA(
    HMODULE hModule,
    LPCSTR lpType,
    ENUMRESNAMEPROCA lpEnumFunc,
    LONG_PTR lParam,
    DWORD dwFlags,
    LANGID LangId
    );

BOOL
EnumResourceNamesExW(
    HMODULE hModule,
    LPCWSTR lpType,
    ENUMRESNAMEPROCW lpEnumFunc,
    LONG_PTR lParam,
    DWORD dwFlags,
    LANGID LangId
    );


BOOL
EnumResourceTypesExA(
    HMODULE hModule,
    ENUMRESTYPEPROCA lpEnumFunc,
    LONG_PTR lParam,
    DWORD dwFlags,
    LANGID LangId
    );

BOOL
EnumResourceTypesExW(
    HMODULE hModule,
    ENUMRESTYPEPROCW lpEnumFunc,
    LONG_PTR lParam,
    DWORD dwFlags,
    LANGID LangId
    );

HRSRC
FindResourceExW(
    HMODULE hModule,
    LPCWSTR lpType,
    LPCWSTR lpName,
    WORD    wLanguage
    );

int
FindStringOrdinal(
    DWORD dwFindStringOrdinalFlags,
    LPCWSTR lpStringSource,
    int cchSource,
    LPCWSTR lpStringValue,
    int cchValue,
    BOOL bIgnoreCase);

BOOL
FreeLibrary (HMODULE hLibModule);

void
FreeLibraryAndExitThread (
    HMODULE hLibModule,
    DWORD dwExitCode
    );

BOOL
FreeResource(HGLOBAL hResData);

DWORD
GetModuleFileNameA(
    HMODULE hModule,
    LPSTR lpFilename,
    DWORD nSize
    );
DWORD
GetModuleFileNameW(
    HMODULE hModule,
    LPWSTR lpFilename,
    DWORD nSize
    );

HMODULE
GetModuleHandleA(LPCSTR lpModuleName);

BOOL
GetModuleHandleExA(
    DWORD    dwFlags,
    LPCSTR lpModuleName,
    HMODULE* phModule);

BOOL
GetModuleHandleExW(
    DWORD    dwFlags,
    LPCWSTR lpModuleName,
    HMODULE* phModule
    );

HMODULE
GetModuleHandleW(
    LPCWSTR lpModuleName
    );

FARPROC
GetProcAddress (
    HMODULE hModule,
    LPCSTR lpProcName
    );

HMODULE
LoadLibraryExA(
    LPCSTR lpLibFileName,
    HANDLE hFile,
    DWORD dwFlags
    );

HMODULE
LoadLibraryExW(
    LPCWSTR lpLibFileName,
    HANDLE hFile,
    DWORD dwFlags
    );

HGLOBAL
LoadResource(
    HMODULE hModule,
    HRSRC hResInfo
    );

int
LoadStringA(
    HINSTANCE hInstance,
    UINT uID,
    LPSTR lpBuffer,
    int cchBufferMax);

int
LoadStringW(
    HINSTANCE hInstance,
    UINT uID,
    LPWSTR lpBuffer,
    int cchBufferMax);

LPVOID
LockResource(HGLOBAL hResData);

DWORD
SizeofResource(
    HMODULE hModule,
    HRSRC hResInfo
    );
]]



return {	
	--AddDllDirectory
	DisableThreadLibraryCalls = k32Lib.DisableThreadLibraryCalls,
	EnumResourceLanguagesExA = k32Lib.EnumResourceLanguagesExA,
	EnumResourceLanguagesExW = k32Lib.EnumResourceLanguagesExW,
	EnumResourceNamesExA = k32Lib.EnumResourceNamesExA,
	EnumResourceNamesExW = k32Lib.EnumResourceNamesExW,
	EnumResourceTypesExA = k32Lib.EnumResourceTypesExA,
	EnumResourceTypesExW = k32Lib.EnumResourceTypesExW,
	FindResourceExW = k32Lib.FindResourceExW,
	FindStringOrdinal = k32Lib.FindStringOrdinal,
	FreeLibrary = k32Lib.FreeLibrary,
	FreeLibraryAndExitThread = k32Lib.FreeLibraryAndExitThread,
	FreeResource = k32Lib.FreeResource,
	GetModuleFileNameA = k32Lib.GetModuleFileNameA,
	GetModuleFileNameW = k32Lib.GetModuleFileNameW,
	GetModuleHandleA = k32Lib.GetModuleHandleA,
	GetModuleHandleExA = k32Lib.GetModuleHandleExA,
	GetModuleHandleExW = k32Lib.GetModuleHandleExW,
	GetModuleHandleW = k32Lib.GetModuleHandleW,
	GetProcAddress = k32Lib.GetProcAddress,
	LoadLibraryExA = k32Lib.LoadLibraryExA,
	LoadLibraryExW = k32Lib.LoadLibraryExW,
	LoadResource = k32Lib.LoadResource,
	LoadStringA = u32Lib.LoadStringA,
	LoadStringW = u32Lib.LoadStringW,
	LockResource = k32Lib.LockResource,
	--QueryOptionalDelayLoadedAPI
	--RemoveDllDirectory
	--SetDefaultDllDirectories
	SizeofResource = k32Lib.SizeofResource,
}
