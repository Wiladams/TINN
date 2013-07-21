-- fstring.lua

local ffi = require("ffi");

local stringzutils = require("stringzutils");


ffi.cdef[[
typedef struct {
	const uint8_t * Data;
	const int Offset;
	const int Length;
} SToken;
]]

local SToken = ffi.typeof("SToken");
local SToken_t = {}
local SToken_mt = {

	__index = SToken_t;

	__new = function(ct, ...)
		--print("SToken:__new()", ...)
		return ffi.new(ct, ...);
	end,


	__gc = function(self)
		--print("GC: SToken");
	end,

	__len = function(self)
		return self.Length;
	end,

	__eq = function(self, other)
	print("SToken:__eq()");
		local maxbytes = math.min(self.Length, other.Length);

		for i=0,maxbytes-1 do
			if self.Data[self.Offset+i] > other.Data[other.Offset+i] then 
				print("RETURN 1.0");
				return false 
			end

			if self.Data[self.Offset+i] < other.Data[other.Offset+i] then
				print("RETURN 2.0");
				return false 
			end
		end

		return true;
	end,

	__tostring = function(self)
		return ffi.string(self.Data+self.Offset, self.Length);
	end,

}
ffi.metatype(SToken, SToken_mt);


return SToken;
