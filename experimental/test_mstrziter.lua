local ffi = require("ffi")
require("fun")()

-- gen, param, state

local function mstrziter(lpBuffer, nBufferLength)

	local function closure(param, idx)
		local nameBuff = ffi.new("char[256]")
		local len = 0;

		while len < param.maxLen do 
			--print("char: ", string.char(lpBuffer[idx]))
			if param.buffer[idx] == 0 then
				break
			end
		--print('idx: ', idx)

			nameBuff[len] = param.buffer[idx];
			len = len + 1;
			idx = idx + 1;
		end

		if len == 0 then
			return nil;
		end

		return idx+1, ffi.string(nameBuff, len);
	end

	return closure, {maxLen = 255, buffer = ffi.cast("const char *",lpBuffer), buffLen = nBufferLength or #lpBuffer}, 0;
end

local src = "big\0boy\0baby\0bear\0bounces\0basketballs\0behind\0the\0barn\0\0"

-- straight iteration
--each(print, mstrziter(src))
each(print, filter(function(x) return x:sub(1,1) ~= "b" end, mstrziter(src)))

-- take 15 from a cycle
--each(print, take(15, cycle(mstrziter(ffi.cast("const char *",src), #src))))
--each(print, take(3, mstrziter(ffi.cast("const char *",src), #src)))
--each(print, take(function(i,a) print (i,a) return a ~= "ziter" end, enumerate(mstrziter(ffi.cast("const char *",src), #src))))

print("======")
