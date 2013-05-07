-- datetime.lua
-- lib = kernel32.dll

local ffi = require("ffi");
local core_string = require("core_string_l1_1_0");
local core_datetime = require("core_datetime_l1_1_1");
local core_errorhandling = require("core_errorhandling_l1_1_1");
local core_string = require("core_string_l1_1_0");


local L = core_string.toUnicode;


local GetTimeFormat = function(lpFormat, dwFlags, lpTime, lpLocaleName)
	dwFlags = dwFlags or 0;
	
	--lpFormat = lpFormat or "hh':'mm':'ss tt";
	if lpFormat then
		lpFormat = L(lpFormat);
	end

	if lpLocaleName then
		lpLocaleName = L(lpLocaleName);
	end

	-- first call to figure out how big the string needs to be
	local buffsize = core_datetime.GetTimeFormatEx(
		lpLocaleName,
		dwFlags,
		lpTime,
		lpFormat,
		lpDataStr,
  		0);

	-- buffsize should be the required size
	if buffsize < 1  then
		return false,  core_errorhandling.GetLastError();
	end

	local lpDataStr = ffi.new("WCHAR[?]", buffsize);
	local res = core_datetime.GetTimeFormatEx(
		lpLocaleName,
		dwFlags,
		lpTime,
		lpFormat,
		lpDataStr,
  		buffsize);


	if res == 0 then
		return false, core_errorhandling.GetLastError();
	end

	-- We have a widechar, turn it into ASCII
	return core_string.toAnsi(lpDataStr);
end

local GetDateFormat = function(lpFormat, dwFlags, lpDate, lpLocaleName)
	dwFlags = dwFlags or 0;

	if lpFormat then
		lpFormat = L(lpFormat);
	end

	local buffsize = core_datetime.GetDateFormatEx(
    	lpLocaleName,
    	dwFlags,
    	lpDate,
    	lpFormat,
    	lpDataStr,
    	0,
    	nil);

	-- buffsize should be the required size
	if buffsize < 1  then
		return false, core_errorhandling.GetLastError();
	end

	local lpDataStr = ffi.new("WCHAR[?]", buffsize);
	local res = core_datetime.GetDateFormatEx(
    	lpLocaleName,
    	dwFlags,
    	lpDate,
    	lpFormat,
    	lpDataStr,
    	buffsize,
    	nil);
	
	if res == 0 then
		return false, core_errorhandling.GetLastError();
	end

	-- We have a widechar, turn it into ASCII
	return core_string.toAnsi(lpDataStr);
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
