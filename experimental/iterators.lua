
local ffi = require("ffi")


local function mstrziter(params)
	params = params or {}

	params.separator = params.separator or 0
	params.datalength = params.datalength or #params.data
	params.basetype = params.basetype or ffi.typeof("char")
	params.basetypeptr = ffi.typeof("const $ *", params.basetype)
	params.maxlen = params.maxlen or params.datalength-1;

	local function closure(param, idx)
		if not params.data then
			return nil;
		end

		local len = 0;
		
		while ffi.cast(param.basetypeptr, param.data)[idx + len] ~= param.separator and (len < param.maxlen) do
			len = len +1;
		end

		if len == 0 then
			return nil;
		end

		return (idx + len+1), ffi.string(ffi.cast(param.basetypeptr, param.data)+idx, len*ffi.sizeof(param.basetype));
	end

	return closure, params, 0;
end


-- given a unicode string which contains
-- null terminated strings
-- return individual ansi strings
local function wmstrziter(lpBuffer, nBufferLength)

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
	mstrziter = mstrziter,
	wmstrziter = wmstrziter,
}