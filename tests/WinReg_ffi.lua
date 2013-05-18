--[[
 BUILD Version: 0001    // Increment this if a change has global effects

Copyright (c) Microsoft Corporation.  All rights reserved.

Module Name:

    Winreg.h

Abstract:

    This module contains the function prototypes and constant, type and
    structure definitions for the Windows 32-Bit Registry API.

--]]
local ffi = require("ffi");
require("WTypes");



ffi.cdef[[
typedef LONG * PLONG;
]]

ffi.cdef[[
//
// RRF - Registry Routine Flags (for RegGetValue)
//

static const int RRF_RT_REG_NONE        = 0x00000001;  // restrict type to REG_NONE      (other data types will not return ERROR_SUCCESS)
static const int RRF_RT_REG_SZ          = 0x00000002;  // restrict type to REG_SZ        (other data types will not return ERROR_SUCCESS) (automatically converts REG_EXPAND_SZ to REG_SZ unless RRF_NOEXPAND is specified)
static const int RRF_RT_REG_EXPAND_SZ   = 0x00000004;  // restrict type to REG_EXPAND_SZ (other data types will not return ERROR_SUCCESS) (must specify RRF_NOEXPAND or RegGetValue will fail with ERROR_INVALID_PARAMETER)
static const int RRF_RT_REG_BINARY      = 0x00000008;  // restrict type to REG_BINARY    (other data types will not return ERROR_SUCCESS)
static const int RRF_RT_REG_DWORD       = 0x00000010;  // restrict type to REG_DWORD     (other data types will not return ERROR_SUCCESS)
static const int RRF_RT_REG_MULTI_SZ    = 0x00000020;  // restrict type to REG_MULTI_SZ  (other data types will not return ERROR_SUCCESS)
static const int RRF_RT_REG_QWORD       = 0x00000040;  // restrict type to REG_QWORD     (other data types will not return ERROR_SUCCESS)

static const int RRF_RT_DWORD           = (RRF_RT_REG_BINARY | RRF_RT_REG_DWORD); // restrict type to *32-bit* RRF_RT_REG_BINARY or RRF_RT_REG_DWORD (other data types will not return ERROR_SUCCESS)
static const int RRF_RT_QWORD           = (RRF_RT_REG_BINARY | RRF_RT_REG_QWORD); // restrict type to *64-bit* RRF_RT_REG_BINARY or RRF_RT_REG_DWORD (other data types will not return ERROR_SUCCESS)
static const int RRF_RT_ANY             = 0x0000ffff;                             // no type restriction

static const int RRF_NOEXPAND           = 0x10000000;  // do not automatically expand environment strings if value is of type REG_EXPAND_SZ
static const int RRF_ZEROONFAILURE      = 0x20000000;  // if pvData is not NULL, set content to all zeros on failure
]]

ffi.cdef[[
//
// Flags for RegLoadAppKey
//
static const int REG_PROCESS_APPKEY       =   0x00000001;

//
// Flags for RegLoadMUIString
//
static const int REG_MUI_STRING_TRUNCATE   =  0x00000001;

//
// Requested Key access mask type.
//

typedef ACCESS_MASK REGSAM;
]]

--
-- Reserved Key Handles.
--

HKEY_CLASSES_ROOT                   = ffi.cast("HKEY", ffi.cast("uintptr_t",0x80000000));
HKEY_CURRENT_USER                   = ffi.cast("HKEY", ffi.cast("uintptr_t",0x80000001));
HKEY_LOCAL_MACHINE                  = ffi.cast("HKEY", ffi.cast("uintptr_t",0x80000002));
HKEY_USERS                          = ffi.cast("HKEY", ffi.cast("uintptr_t",0x80000003));
HKEY_PERFORMANCE_DATA               = ffi.cast("HKEY", ffi.cast("uintptr_t",0x80000004));
HKEY_PERFORMANCE_TEXT               = ffi.cast("HKEY", ffi.cast("uintptr_t",0x80000050));
HKEY_PERFORMANCE_NLSTEXT            = ffi.cast("HKEY", ffi.cast("uintptr_t",0x80000060));
HKEY_CURRENT_CONFIG                 = ffi.cast("HKEY", ffi.cast("uintptr_t",0x80000005));
HKEY_DYN_DATA                       = ffi.cast("HKEY", ffi.cast("uintptr_t",0x80000006));
HKEY_CURRENT_USER_LOCAL_SETTINGS    = ffi.cast("HKEY", ffi.cast("uintptr_t",0x80000007));

ffi.cdef[[
//
// RegConnectRegistryEx supported flags
//
static const int REG_SECURE_CONNECTION  = 1;
]]


-- NOINC
if not _PROVIDER_STRUCTS_DEFINED then
_PROVIDER_STRUCTS_DEFINED = true;

ffi.cdef[[
static const int PROVIDER_KEEPS_VALUE_LENGTH = 0x1;

struct val_context {
    int valuelen;       // the total length of this value
    LPVOID value_context;   // provider's context
    LPVOID val_buff_ptr;    // where in the ouput buffer the value is.
};

typedef struct val_context  *PVALCONTEXT;

typedef struct pvalueA {           // Provider supplied value/context.
    LPSTR   pv_valuename;          // The value name pointer
    int pv_valuelen;
    LPVOID pv_value_context;
    DWORD pv_type;
}PVALUEA,  *PPVALUEA;
typedef struct pvalueW {           // Provider supplied value/context.
    LPWSTR  pv_valuename;          // The value name pointer
    int pv_valuelen;
    LPVOID pv_value_context;
    DWORD pv_type;
}PVALUEW,  *PPVALUEW;
]]

if UNICODE then
ffi.cdef[[
typedef PVALUEW PVALUE;
typedef PPVALUEW PPVALUE;
]]
else
ffi.cdef[[
typedef PVALUEA PVALUE;
typedef PPVALUEA PPVALUE;
]]
end -- UNICODE


ffi.cdef[[
typedef
DWORD 
QUERYHANDLER (LPVOID keycontext, PVALCONTEXT val_list, DWORD num_vals,
          LPVOID outputbuffer, DWORD  *total_outlen, DWORD input_blen);

typedef QUERYHANDLER  *PQUERYHANDLER;

typedef struct provider_info {
    PQUERYHANDLER pi_R0_1val;
    PQUERYHANDLER pi_R0_allvals;
    PQUERYHANDLER pi_R3_1val;
    PQUERYHANDLER pi_R3_allvals;
    DWORD pi_flags;    // capability flags (none defined yet).
    LPVOID pi_key_context;
}REG_PROVIDER;

typedef struct provider_info  *PPROVIDER;

typedef struct value_entA {
    LPSTR   ve_valuename;
    DWORD ve_valuelen;
    DWORD_PTR ve_valueptr;
    DWORD ve_type;
}VALENTA,  *PVALENTA;
typedef struct value_entW {
    LPWSTR  ve_valuename;
    DWORD ve_valuelen;
    DWORD_PTR ve_valueptr;
    DWORD ve_type;
}VALENTW,  *PVALENTW;
]]


if UNICODE then
ffi.cdef[[
typedef VALENTW VALENT;
typedef PVALENTW PVALENT;
]]
else
ffi.cdef[[
typedef VALENTA VALENT;
typedef PVALENTA PVALENT;
]]
end -- UNICODE

end -- not(_PROVIDER_STRUCTS_DEFINED)
-- INC



ffi.cdef[[
//
// API Prototypes.
//

//typedef __success(return==ERROR_SUCCESS) LONG LSTATUS;
typedef LONG LSTATUS;

LSTATUS
RegCloseKey (HKEY hKey);


LSTATUS
RegOverridePredefKey (HKEY hKey,
    HKEY hNewHKey
    );


LSTATUS
RegOpenUserClassesRoot(HANDLE hToken,
    DWORD dwOptions,
    REGSAM samDesired,
    PHKEY  phkResult
    );


LSTATUS
RegOpenCurrentUser(REGSAM samDesired,
    PHKEY phkResult
    );


LSTATUS
RegDisablePredefinedCache(void);


LSTATUS
RegDisablePredefinedCacheEx(void);


LSTATUS
RegConnectRegistryA (
    LPCSTR lpMachineName,
    HKEY hKey,
    HKEY * phkResult);

LSTATUS
RegConnectRegistryW (
    LPCWSTR lpMachineName,
    HKEY hKey,
    PHKEY phkResult
    );
]]



ffi.cdef[[

LSTATUS
RegConnectRegistryExA (
    LPCSTR lpMachineName,
    HKEY hKey,
    ULONG Flags,
    PHKEY phkResult
    );

LSTATUS
RegConnectRegistryExW (
    LPCWSTR lpMachineName,
    HKEY hKey,
    ULONG Flags,
    PHKEY phkResult
    );
]]



ffi.cdef[[

LSTATUS
RegCreateKeyA (
    HKEY hKey,
    LPCSTR lpSubKey,
    PHKEY phkResult
    );

LSTATUS
RegCreateKeyW (
    HKEY hKey,
    LPCWSTR lpSubKey,
    PHKEY phkResult
    );
]]




ffi.cdef[[

LSTATUS
RegCreateKeyExA (
    HKEY hKey,
    LPCSTR lpSubKey,
    DWORD Reserved,
    LPSTR lpClass,
    DWORD dwOptions,
    REGSAM samDesired,
    const LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    PHKEY phkResult,
    LPDWORD lpdwDisposition
    );

LSTATUS

RegCreateKeyExW (
    HKEY hKey,
    LPCWSTR lpSubKey,
    DWORD Reserved,
    LPWSTR lpClass,
    DWORD dwOptions,
    REGSAM samDesired,
    const LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    PHKEY phkResult,
    LPDWORD lpdwDisposition
    );
]]





ffi.cdef[[

LSTATUS

RegCreateKeyTransactedA (
    HKEY hKey,
    LPCSTR lpSubKey,
    DWORD Reserved,
    LPSTR lpClass,
    DWORD dwOptions,
    REGSAM samDesired,
    const LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    PHKEY phkResult,
    LPDWORD lpdwDisposition,
            HANDLE hTransaction,
    PVOID  pExtendedParemeter
    );

LSTATUS

RegCreateKeyTransactedW (
    HKEY hKey,
    LPCWSTR lpSubKey,
    DWORD Reserved,
    LPWSTR lpClass,
    DWORD dwOptions,
    REGSAM samDesired,
    const LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    PHKEY phkResult,
    LPDWORD lpdwDisposition,
            HANDLE hTransaction,
    PVOID  pExtendedParemeter
    );
]]





ffi.cdef[[

LSTATUS

RegDeleteKeyA (
    HKEY hKey,
    LPCSTR lpSubKey
    );

LSTATUS

RegDeleteKeyW (
    HKEY hKey,
    LPCWSTR lpSubKey
    );
]]



ffi.cdef[[

LSTATUS

RegDeleteKeyExA (
    HKEY hKey,
    LPCSTR lpSubKey,
    REGSAM samDesired,
    DWORD Reserved
    );

LSTATUS

RegDeleteKeyExW (
    HKEY hKey,
    LPCWSTR lpSubKey,
    REGSAM samDesired,
    DWORD Reserved
    );
]]




ffi.cdef[[

LSTATUS

RegDeleteKeyTransactedA (
    HKEY hKey,
    LPCSTR lpSubKey,
    REGSAM samDesired,
    DWORD Reserved,
            HANDLE hTransaction,
    PVOID  pExtendedParameter
    );

LSTATUS

RegDeleteKeyTransactedW (
    HKEY hKey,
    LPCWSTR lpSubKey,
    REGSAM samDesired,
    DWORD Reserved,
            HANDLE hTransaction,
    PVOID  pExtendedParameter
    );
]]





ffi.cdef[[

LONG

RegDisableReflectionKey (HKEY hBase);


LONG
RegEnableReflectionKey (
    HKEY hBase
    );    


LONG
RegQueryReflectionKey (
    HKEY hBase,
    BOOL *bIsReflectionDisabled
    );    
    

LSTATUS
RegDeleteValueA (
    HKEY hKey,
    LPCSTR lpValueName
    );


LSTATUS
RegDeleteValueW (
    HKEY hKey,
    LPCWSTR lpValueName
    );
]]





ffi.cdef[[

LSTATUS
RegEnumKeyA (
    HKEY hKey,
    DWORD dwIndex,
    LPSTR lpName,
    DWORD cchName
    );

LSTATUS
RegEnumKeyW (
    HKEY hKey,
    DWORD dwIndex,
    LPWSTR lpName,
    DWORD cchName
    );
]]





ffi.cdef[[

LSTATUS

RegEnumKeyExA (
    HKEY hKey,
    DWORD dwIndex,
    LPSTR lpName,
    LPDWORD lpcchName,
    LPDWORD lpReserved,
    LPSTR lpClass,
    LPDWORD lpcchClass,
    PFILETIME lpftLastWriteTime
    );

LSTATUS

RegEnumKeyExW (
    HKEY hKey,
    DWORD dwIndex,
    LPWSTR lpName,
    LPDWORD lpcchName,
    LPDWORD lpReserved,
    LPWSTR lpClass,
    LPDWORD lpcchClass,
    PFILETIME lpftLastWriteTime
    );
]]





ffi.cdef[[

LSTATUS
RegEnumValueA (
    HKEY hKey,
    DWORD dwIndex,
    LPSTR lpValueName,
    LPDWORD lpcchValueName,
    LPDWORD lpReserved,
    LPDWORD lpType,
    LPBYTE lpData,
    LPDWORD lpcbData
    );

LSTATUS

RegEnumValueW (
    HKEY hKey,
    DWORD dwIndex,
    LPWSTR lpValueName,
    LPDWORD lpcchValueName,
    LPDWORD lpReserved,
    LPDWORD lpType,
    LPBYTE lpData,
    LPDWORD lpcbData
    );
]]




ffi.cdef[[

LSTATUS
RegFlushKey (
    HKEY hKey
    );


//LSTATUS
//RegGetKeySecurity (
//    HKEY hKey,
//    SECURITY_INFORMATION SecurityInformation,
//    PSECURITY_DESCRIPTOR pSecurityDescriptor,
//    LPDWORD lpcbSecurityDescriptor
//    );


LSTATUS
RegLoadKeyA (
    HKEY    hKey,
    LPCSTR  lpSubKey,
    LPCSTR  lpFile
    );

LSTATUS
RegLoadKeyW (
    HKEY    hKey,
    LPCWSTR  lpSubKey,
    LPCWSTR  lpFile
    );
]]




ffi.cdef[[

LSTATUS
RegNotifyChangeKeyValue (
    HKEY hKey,
    BOOL bWatchSubtree,
    DWORD dwNotifyFilter,
    HANDLE hEvent,
    BOOL fAsynchronous
    );


LSTATUS
RegOpenKeyA (
    HKEY hKey,
    LPCSTR lpSubKey,
    PHKEY phkResult
    );

LSTATUS
RegOpenKeyW (
    HKEY hKey,
    LPCWSTR lpSubKey,
    PHKEY phkResult
    );
]]




ffi.cdef[[

LSTATUS
RegOpenKeyExA (
    HKEY hKey,
    LPCSTR lpSubKey,
    DWORD ulOptions,
    REGSAM samDesired,
    PHKEY phkResult
    );

LSTATUS

RegOpenKeyExW (
    HKEY hKey,
    LPCWSTR lpSubKey,
    DWORD ulOptions,
    REGSAM samDesired,
    PHKEY phkResult
    );
]]





ffi.cdef[[

LSTATUS

RegOpenKeyTransactedA (
    HKEY hKey,
    LPCSTR lpSubKey,
    DWORD ulOptions,
    REGSAM samDesired,
    PHKEY phkResult,
    HANDLE hTransaction,
    PVOID  pExtendedParemeter
    );

LSTATUS

RegOpenKeyTransactedW (
    HKEY hKey,
    LPCWSTR lpSubKey,
    DWORD ulOptions,
    REGSAM samDesired,
    PHKEY phkResult,
    HANDLE hTransaction,
    PVOID  pExtendedParemeter
    );
]]





ffi.cdef[[

LSTATUS
RegQueryInfoKeyA (
    HKEY hKey,
    LPSTR lpClass,
    LPDWORD lpcchClass,
    LPDWORD lpReserved,
    LPDWORD lpcSubKeys,
    LPDWORD lpcbMaxSubKeyLen,
    LPDWORD lpcbMaxClassLen,
    LPDWORD lpcValues,
    LPDWORD lpcbMaxValueNameLen,
    LPDWORD lpcbMaxValueLen,
    LPDWORD lpcbSecurityDescriptor,
    PFILETIME lpftLastWriteTime
    );

LSTATUS

RegQueryInfoKeyW (
    HKEY hKey,
    LPWSTR lpClass,
    LPDWORD lpcchClass,
    LPDWORD lpReserved,
    LPDWORD lpcSubKeys,
    LPDWORD lpcbMaxSubKeyLen,
    LPDWORD lpcbMaxClassLen,
    LPDWORD lpcValues,
    LPDWORD lpcbMaxValueNameLen,
    LPDWORD lpcbMaxValueLen,
    LPDWORD lpcbSecurityDescriptor,
    PFILETIME lpftLastWriteTime
    );
]]




ffi.cdef[[

LSTATUS

RegQueryValueA (
    HKEY hKey,
    LPCSTR lpSubKey,
    LPSTR lpData,
    PLONG lpcbData
    );

LSTATUS

RegQueryValueW (
    HKEY hKey,
    LPCWSTR lpSubKey,
    LPWSTR lpData,
    PLONG lpcbData
    );
]]






ffi.cdef[[

LSTATUS

RegQueryMultipleValuesA (
    HKEY hKey,
    PVALENTA val_list,
    DWORD num_vals,
    LPSTR lpValueBuf,
    LPDWORD ldwTotsize
    );

LSTATUS

RegQueryMultipleValuesW (
    HKEY hKey,
    PVALENTW val_list,
    DWORD num_vals,
    LPWSTR lpValueBuf,
    LPDWORD ldwTotsize
    );
]]



ffi.cdef[[

LSTATUS
RegQueryValueExA (
    HKEY hKey,
    LPCSTR lpValueName,
    LPDWORD lpReserved,
    LPDWORD lpType,
    LPBYTE lpData,
    LPDWORD lpcbData
    );

LSTATUS
RegQueryValueExW (
    HKEY hKey,
    LPCWSTR lpValueName,
    LPDWORD lpReserved,
    LPDWORD lpType,
    LPBYTE lpData,
    LPDWORD lpcbData
    );
]]



ffi.cdef[[

LSTATUS
RegReplaceKeyA (
    HKEY hKey,
    LPCSTR lpSubKey,
    LPCSTR lpNewFile,
    LPCSTR lpOldFile
    );

LSTATUS

RegReplaceKeyW (
    HKEY hKey,
    LPCWSTR lpSubKey,
    LPCWSTR lpNewFile,
    LPCWSTR lpOldFile
    );
]]



ffi.cdef[[

LSTATUS

RegRestoreKeyA (
    HKEY hKey,
    LPCSTR lpFile,
    DWORD dwFlags
    );

LSTATUS

RegRestoreKeyW (
    HKEY hKey,
    LPCWSTR lpFile,
    DWORD dwFlags
    );
]]




ffi.cdef[[

LSTATUS

RegRenameKey(
    HKEY hKey,
    LPCWSTR lpSubKeyName,
    LPCWSTR lpNewKeyName
    );
]]


ffi.cdef[[

LSTATUS

RegSaveKeyA (
    HKEY hKey,
    LPCSTR lpFile,
    const LPSECURITY_ATTRIBUTES lpSecurityAttributes
    );

LSTATUS

RegSaveKeyW (
    HKEY hKey,
    LPCWSTR lpFile,
    const LPSECURITY_ATTRIBUTES lpSecurityAttributes
    );
]]




ffi.cdef[[

//LSTATUS
//RegSetKeySecurity (
//    HKEY hKey,
//    SECURITY_INFORMATION SecurityInformation,
//    PSECURITY_DESCRIPTOR pSecurityDescriptor
//    );


LSTATUS

RegSetValueA (
    HKEY hKey,
    LPCSTR lpSubKey,
    DWORD dwType,
    LPCSTR lpData,
    DWORD cbData
    );

LSTATUS

RegSetValueW (
    HKEY hKey,
    LPCWSTR lpSubKey,
    DWORD dwType,
    LPCWSTR lpData,
    DWORD cbData
    );
]]




ffi.cdef[[

LSTATUS

RegSetValueExA (
    HKEY hKey,
    LPCSTR lpValueName,
    DWORD Reserved,
    DWORD dwType,
    const BYTE* lpData,
    DWORD cbData
    );

LSTATUS

RegSetValueExW (
    HKEY hKey,
    LPCWSTR lpValueName,
    DWORD Reserved,
    DWORD dwType,
    const BYTE* lpData,
    DWORD cbData
    );
]]




ffi.cdef[[

LSTATUS

RegUnLoadKeyA (
    HKEY    hKey,
    LPCSTR lpSubKey
    );

LSTATUS

RegUnLoadKeyW (
    HKEY    hKey,
    LPCWSTR lpSubKey
    );
]]



ffi.cdef[[
//
// Utils wrappers
//


LSTATUS

RegDeleteKeyValueA (
          HKEY     hKey,
      LPCSTR lpSubKey,
      LPCSTR lpValueName
    );

LSTATUS

RegDeleteKeyValueW (
          HKEY     hKey,
      LPCWSTR lpSubKey,
      LPCWSTR lpValueName
    );
]]




ffi.cdef[[

LSTATUS

RegSetKeyValueA (
            HKEY     hKey,
        LPCSTR  lpSubKey,
        LPCSTR  lpValueName,
            DWORD    dwType,
   LPCVOID  lpData,
            DWORD    cbData
    );

LSTATUS

RegSetKeyValueW (
            HKEY     hKey,
        LPCWSTR  lpSubKey,
        LPCWSTR  lpValueName,
            DWORD    dwType,
    LPCVOID  lpData,
            DWORD    cbData
    );
]]




ffi.cdef[[

LSTATUS

RegDeleteTreeA (
            HKEY     hKey,
        LPCSTR  lpSubKey
    );

LSTATUS

RegDeleteTreeW (
            HKEY     hKey,
        LPCWSTR  lpSubKey
    );
]]



ffi.cdef[[

LSTATUS

RegCopyTreeA (
            HKEY     hKeySrc,
        LPCSTR  lpSubKey,
            HKEY     hKeyDest
    );

LSTATUS

RegCopyTreeW (
            HKEY     hKeySrc,
        LPCWSTR  lpSubKey,
            HKEY     hKeyDest
    );
]]



ffi.cdef[[

LSTATUS

RegGetValueA (
    HKEY    hkey,
    LPCSTR  lpSubKey,
    LPCSTR  lpValue,
    DWORD    dwFlags,
    LPDWORD pdwType,
    PVOID   pvData,
    LPDWORD pcbData
    );

LSTATUS

RegGetValueW (
    HKEY    hkey,
    LPCWSTR  lpSubKey,
    LPCWSTR  lpValue,
    DWORD    dwFlags,
    LPDWORD pdwType,
    PVOID   pvData,
    LPDWORD pcbData
    );
]]



ffi.cdef[[

LSTATUS

RegLoadMUIStringA (
                                        HKEY        hKey,
                                    LPCSTR    pszValue,
                    LPSTR     pszOutBuf,
                                        DWORD       cbOutBuf,
                    LPDWORD     pcbData,
                                        DWORD       Flags,   
                                    LPCSTR    pszDirectory
                    );

LSTATUS

RegLoadMUIStringW (
                                        HKEY        hKey,
                                    LPCWSTR    pszValue,
                    LPWSTR     pszOutBuf,
                                        DWORD       cbOutBuf,
                    LPDWORD     pcbData,
                                        DWORD       Flags,   
                                    LPCWSTR    pszDirectory
                    );
]]



ffi.cdef[[

LSTATUS

RegLoadAppKeyA (
                LPCSTR    lpFile,
               PHKEY       phkResult,
                REGSAM      samDesired, 
                DWORD       dwOptions,
          DWORD       Reserved
    );

LSTATUS

RegLoadAppKeyW (
                LPCWSTR    lpFile,
               PHKEY       phkResult,
                REGSAM      samDesired, 
                DWORD       dwOptions,
          DWORD       Reserved
    );
]]



ffi.cdef[[

LSTATUS
RegSaveKeyExA (
    HKEY hKey,
    LPCSTR lpFile,
    const LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    DWORD Flags
    );

LSTATUS
RegSaveKeyExW (
    HKEY hKey,
    LPCWSTR lpFile,
    const LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    DWORD Flags
    );
]]
