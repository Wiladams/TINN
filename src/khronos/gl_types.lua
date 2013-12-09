local ffi = require("ffi")

ffi.cdef[[
typedef unsigned int GLenum;
typedef unsigned char GLboolean;
typedef unsigned int GLbitfield;
typedef signed char GLbyte;
typedef int GLint;
typedef int GLsizei;
typedef unsigned char GLubyte;
typedef char GLchar;
typedef char GLcharARB;
typedef short GLshort;
typedef unsigned short GLushort;
typedef unsigned int GLuint;
typedef int64_t GLint64;
typedef uint64_t GLuint64;
typedef int64_t GLint64EXT;
typedef uint64_t GLuint64EXT;

typedef unsigned short GLhalfNV;

typedef float GLfloat;
typedef float GLclampf;

typedef double GLdouble;
typedef double GLclampd;

typedef void GLvoid;
typedef long GLintptr;
typedef long GLsizeiptr;
typedef void *GLhandleARB;
typedef long GLintptrARB;
typedef long GLsizeiptrARB;
typedef unsigned short GLhalfARB;
typedef unsigned short GLhalf;
]]
