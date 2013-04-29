-- datetime.lua
-- lib = kernel32.dll

local ffi = require("ffi");
local k32 = require("win_kernel32");
local k32Lib = k32.Lib;

local datetime_ffi = require("datetime_ffi");

local GetTimeFormat = function(lpFormat, dwFlags, lpTime, lpLocaleName)
	dwFlags = dwFlags or 0;
	
	--lpFormat = lpFormat or "hh':'mm':'ss tt";
	if lpFormat then
		lpFormat = k32.AnsiToUnicode16(lpFormat);
	end

	if lpLocaleName then
		lpLocaleName = k32.AnsiToUnicode16(lpLocaleName);
	end

	-- first call to figure out how big the string needs to be
	local buffsize = k32Lib.GetTimeFormatEx(
		lpLocaleName,
		dwFlags,
		lpTime,
		lpFormat,
		lpDataStr,
  		0);

	-- buffsize should be the required size
	if buffsize < 1  then
		return false,  k32Lib.GetLastError();
	end

	local lpDataStr = ffi.new("WCHAR[?]", buffsize);
	local res = k32Lib.GetTimeFormatEx(
		lpLocaleName,
		dwFlags,
		lpTime,
		lpFormat,
		lpDataStr,
  		buffsize);


	if res == 0 then
		return false, Lib.GetLastError();
	end

	-- We have a widechar, turn it into ASCII
	return k32.Unicode16ToAnsi(lpDataStr);
end

local GetDateFormat = function(lpFormat, dwFlags, lpDate, lpLocaleName)
	dwFlags = dwFlags or 0;

	if lpFormat then
		lpFormat = k32.AnsiToUnicode16(lpFormat);
	end

	local buffsize = k32Lib.GetDateFormatEx(
    	lpLocaleName,
    	dwFlags,
    	lpDate,
    	lpFormat,
    	lpDataStr,
    	0,
    	nil);

	-- buffsize should be the required size
	if buffsize < 1  then
		return false, k32Lib.GetLastError();
	end

	local lpDataStr = ffi.new("WCHAR[?]", buffsize);
	local res = k32Lib.GetDateFormatEx(
    	lpLocaleName,
    	dwFlags,
    	lpDate,
    	lpFormat,
    	lpDataStr,
    	buffsize,
    	nil);
	
	if res == 0 then
		return false, Lib.GetLastError();
	end

	-- We have a widechar, turn it into ASCII
	return k32.Unicode16ToAnsi(lpDataStr);
end

local time = function(...)
	print(GetTimeFormat(...));
end

local date = function(...)
	print(GetDateFormat(...));
end

return {
	time = time,
	date = date,
	
	getTime = GetTimeFormat;
	getDate = GetDateFormat;

	GetDateFormat = GetDateFormat,
	GetTimeFormat = GetTimeFormat,
}
