local ffi = require("ffi")
local core_string = require("core_string_l1_1_0")

local fun = require("fun")()
local iterators = require("msiterators")
local striter = iterators.striter

ffi.cdef[[
typedef struct rgb32 {
	int r:8;
	int g:8;
	int b:8;
} rgb32_t
]]


local src = "big\0boy\0baby\0bear\0bounces\0basketballs\0behind\0the\0barn\0\0"
local src2 = "big\rboy\rbaby\rbear\rbounces\rbasketballs\rbehind\rthe\rbarn\r\r"
local src3 = "big,boy,baby,bear,bounces,basketballs,behind,the,barn,,"
local whello, whellolen = core_string.toUnicode("Hello World");
local wSP = core_string.toUnicode(' ')
local wsp = wSP[0]

local function printAnsi(ptr, len)
	print(ffi.string(ptr, len))
end


local function mstriter(data, separator, datalength)
	return fun.map(function(ptr,len) return ffi.string(ptr, len) end, 
		striter({data = data, datalength = datalength, separator=separator, basetype="char"}))
end



local function mstrziter(data, datalength)
	datalength = datalength or #data

	return fun.map(function(ptr,len) return ffi.string(ptr, len) end, 
		striter({data = data, datalength = datalength, separator=0, basetype="char"}))
end

local function wmstriter(data, separator, datalength)
	if type(separator) == "string" then
		separator = string.byte(separator)
	end

	datalength = datalength or ffi.sizeof(data)
	return map(core_string.toAnsi, striter{data=data, datalength = datalength, basetype="wchar_t", separator=separator})
end

local function wmstrziter(data, datalength)
	datalength = datalength or ffi.sizeof(data)
	return map(core_string.toAnsi, striter{data=data, datalength = datalength, basetype="wchar_t", separator=0})
end


---[=[
-- straight iteration
print("---- each(print, mstrziter(src)")
each(print, mstrziter(src))

print("---- grep('^ba') ----")
each(print, grep("^ba", mstrziter(src)))

print("---- take(3, mstriter(src2, separator='\\r') ----")
each(print, take(3, mstriter(src2, string.byte('\r'))))


print("---- each(print, striter{data=src3})")
each(printAnsi, striter{data=src3, basetype="char"})

print([[---- each(print, map(function(ptr, len) return string.char(ptr[0]) end, striter{data=src3, basetype="char"}))]])
each(print, map(function(ptr, len) return string.char(ptr[0]) end, striter{data=src3, basetype="char"}))


print([[---- each(printAnsi, striter{data=src3, basetype="char", separator=string.byte(',')})]])
each(printAnsi, striter{data=src3, basetype="char", separator=string.byte(',')})

--print("---- each(print, mstrziter({data=src3, separator=',')")
--each(print, mstrziter{data = src3, separator=string.byte(',')})
--]=]

-- do some wide char
print([[---- each(print, wmstriter(whello, ' '))]])
each(print, wmstriter(whello, ' '))


-- take 15 from a cycle
--each(print, take(15, cycle(iterators.mstrziter(ffi.cast("const char *",src), #src))))


--each(print, take(function(i,a) print (i,a) return a ~= "ziter" end, enumerate(iterators.mstrziter(ffi.cast("const char *",src), #src))))

--print("---- mstiter ----")
--each(print, map(function(ptr,len) return ffi.string(ptr, len) end, mstriter{data = src}))

print("======")
