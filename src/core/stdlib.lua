local ffi = require("ffi")

ffi.cdef[[
// string conversion
double atof (const char* str);
int atoi (const char * str);
long int atol ( const char * str );
long long int atoll ( const char * str );

// Dynamic memory management
void * calloc (size_t num, size_t size);
void   free   ( void * ptr );
void * malloc ( size_t size );
void * realloc( void * ptr, size_t size );
]]

return {
	calloc = ffi.C.calloc;
	free = ffi.C.free;
	malloc = ffi.C.malloc;
	realloc = ffi.C.realloc;
}