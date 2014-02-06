#ifndef NSE_BINLIB
#define NSE_BINLIB

#define NSE_BINLIBNAME "bin"

LUALIB_API int luaopen_binlib (lua_State *L);

typedef unsigned __int8 uint8_t;
typedef unsigned __int16 uint16_t;
typedef unsigned __int32 uint32_t;
typedef unsigned __int64 uint64_t;
typedef signed __int8 int8_t;
typedef signed __int16 int16_t;
typedef signed __int32 int32_t;
typedef signed __int64 int64_t;


typedef int8_t		s8;
typedef int16_t		s16;
typedef int32_t		s32;
typedef int64_t		s64;

typedef uint8_t 	u8;
typedef uint16_t 	u16;
typedef uint32_t	u32;
typedef uint64_t	u64;


#endif /* NSE_BINLIB */