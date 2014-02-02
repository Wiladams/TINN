-- fstring.lua

local ffi = require("ffi");

local stringzutils = require("stringzutils");


ffi.cdef[[
typedef struct {
	const char * Data;
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
		-- print("SToken:__eq(): ", type(self), type(other));

		local otherData = ffi.cast("const uint8_t *", other);
		local otherLength = #other;
		local otherOffset = 0;

		if type(other) == "string" then
		else
			otherOffset = other.Offset;
		end


		local maxbytes = math.min(self.Length, otherLength);

		for i=0,maxbytes-1 do
			if self.Data[self.Offset+i] > otherData[otherOffset+i] then 
				--print("RETURN 1.0");
				return false 
			end

			if self.Data[self.Offset+i] < otherData[otherOffset+i] then
				--print("RETURN 2.0");
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
