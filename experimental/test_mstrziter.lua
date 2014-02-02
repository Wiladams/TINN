local ffi = require("ffi")
require("fun")()
local iterators = require("iterators")
local mstrziter = iterators.mstrziter



local src = "big\0boy\0baby\0bear\0bounces\0basketballs\0behind\0the\0barn\0\0"
local src2 = "big\rboy\rbaby\rbear\rbounces\rbasketballs\rbehind\rthe\rbarn\r\r"

-- straight iteration
print("---- each(print, mstrziter(src)")
each(print, mstrziter{data = src})

print("---- grep('^ba') ----")
each(print, grep("^ba", mstrziter{data = src}))
--each(print, filter(function(x) return x:sub(1,1) ~= "b" end, iterators.mstrziter(src)))

-- take 15 from a cycle
--each(print, take(15, cycle(iterators.mstrziter(ffi.cast("const char *",src), #src))))

print("---- take(3, mstrziter(src2) ----")
each(print, take(3, mstrziter{data = src2, separator = string.byte('\r')}))

--each(print, take(function(i,a) print (i,a) return a ~= "ziter" end, enumerate(iterators.mstrziter(ffi.cast("const char *",src), #src))))

print("======")
