
local ffi = require("ffi");

_WIN64 = ffi.os == "Windows" and ffi.abi("64bit");

-- intsafe.h contains many of these base
-- definitions as well.

ffi.cdef[[
typedef char          	CHAR;
typedef unsigned char	UCHAR;
typedef unsigned char 	BYTE;
typedef int16_t     	SHORT;
typedef unsigned short  USHORT;
typedef uint16_t		WORD;
typedef int         	INT;
typedef unsigned int	UINT;
typedef long        	LONG;
typedef unsigned long	ULONG;
typedef unsigned long 	DWORD;
typedef int64_t     	LONGLONG;
typedef uint64_t		ULONGLONG;
typedef uint64_t    	DWORDLONG;
]]

ffi.cdef[[
typedef uint64_t   *PDWORDLONG;
]]

ffi.cdef[[
typedef int8_t         INT8, *PINT8;
typedef int16_t        INT16, *PINT16;
typedef int32_t          INT32, *PINT32;
typedef int64_t      INT64, *PINT64;
typedef uint8_t       UINT8, *PUINT8;
typedef uint16_t      UINT16, *PUINT16;
typedef uint32_t        UINT32, *PUINT32;
typedef uint64_t    UINT64, *PUINT64;
]]

ffi.cdef[[
//
// The following types are guaranteed to be signed and 32 bits wide.
//

typedef int32_t LONG32, *PLONG32;

//
// The following types are guaranteed to be unsigned and 32 bits wide.
//

typedef uint32_t  ULONG32, *PULONG32;
typedef uint32_t  DWORD32, *PDWORD32;
]]

if _WIN64 then
ffi.cdef[[
typedef int64_t   INT_PTR, *PINT_PTR;
typedef uint64_t  UINT_PTR, *PUINT_PTR;
typedef int64_t   LONG_PTR, *PLONG_PTR;ONG
typedef uint64_t  ULONG_PTR, *PULONG_PTR;
]]
else
ffi.cdef[[
typedef int             INT_PTR, *PINT_PTR;
typedef unsigned int    UINT_PTR, *PUINT_PTR;
typedef long            LONG_PTR, *PLONG_PTR;
typedef unsigned long   ULONG_PTR, *PULONG_PTR;
]]

end

ffi.cdef[[
typedef ULONG_PTR			SIZE_T, *PSIZE_T;
typedef LONG_PTR SSIZE_T, *PSSIZE_T;
]]


ffi.cdef[[
//
// Add Windows flavor DWORD_PTR types
//

typedef ULONG_PTR DWORD_PTR, *PDWORD_PTR;

//
// The following types are guaranteed to be signed and 64 bits wide.
//

typedef int64_t LONG64, *PLONG64;

//
// The following types are guaranteed to be unsigned and 64 bits wide.
//

typedef uint64_t ULONG64, *PULONG64;
typedef uint64_t DWORD64, *PDWORD64;

//
// Structure to represent a group-specific affinity, such as that of a
// thread.  Specifies the group number and the affinity within that group.
//
typedef ULONG_PTR KAFFINITY;
typedef KAFFINITY *PKAFFINITY;
]]
