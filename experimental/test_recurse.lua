-- test_recurse.lua
local ffi = require("ffi")

local function test_loops()
local function looper(count)
print("looper: ", count)

	count = count - 1;
	if count < 1 then
		return
	end

	looper(count)
end

looper(5)

local looper2 = function(count)
print("looper2: ", count)

	count = count - 1;
	if count < 1 then
		return
	end

	looper2(count)
end

looper2(5)

end

require("WTypes")
ffi.cdef[[
static const int ANYSIZE_ARRAY = 1;       

#pragma pack(1)
typedef struct {
	int32_t foo;
	int8_t  bar[ANYSIZE_ARRAY];
} foobar;
]]

print("Sizeof: ", ffi.sizeof("foobar"))