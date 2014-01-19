
local ffi = require("ffi")

-- given a unicode string which contains
-- null terminated strings
-- return individual ansi strings
local function wstrziter(lpBuffer, nBufferLength)

	local maxLen = 255;
	local idx = -1;

	local nameBuff = ffi.new("char[256]")

	local function closure()
		idx = idx + 1;
		local len = 0;

		while len < maxLen do 
			--print("char: ", string.char(lpBuffer[idx]))
			if lpBuffer[idx] == 0 then
				break
			end
		
			nameBuff[len] = lpBuffer[idx];
			len = len + 1;
			idx = idx + 1;
		end

		if len == 0 then
			return nil;
		end

		return ffi.string(nameBuff, len);
	end

	return closure;
end

return {
	wstrziter = wstrziter,
}