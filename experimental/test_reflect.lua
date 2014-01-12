-- http://www.corsix.org/lua/reflect/api.html
local ffi = require("ffi");
local reflect = require("reflect");
local structForm = require("reflectutil");

local GDI32 = require("GDI32")





local function printType(atype, depth)
	depth = depth or 1;

	local refType = reflect.typeof(atype);
	local str = structForm(refType, depth);
	print(str);
end


require("WTypes");

ffi.cdef[[
typedef struct _Foo {
	int x;
	int y;	

	uint32_t r;
	float g;
	double b;
} Foo;

int (* PFNFooFuncPROC)(int x, int y);

BOOL
GetConsoleMode(HANDLE hConsoleHandle, LPDWORD lpMode);


]]


-- printing out data structures
printType(ffi.typeof("Foo"));
--printType(ffi.typeof("GDIDIBSection"));


-- printing out function pointers
--printType(ffi.C["GetConsoleMode"]);
--printType(ffi.C["Ellipse"]);

--printType(ffi.typeof("PFNFooFuncPROC"));

