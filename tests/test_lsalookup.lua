
local ffi = require("ffi");

local WinError = require("win_error");

local errorhandling = require("core_errorhandling_l1_1_1");
local lsalookup = require("security_lsalookup_l2_1_0");
local core_string = require("core_string_l1_1_0");
local L = core_string.toUnicode;
local SID = require("SID");




local function lookupAccountName(accountName, lpSystemName)
	if lpSystemName then
		lpSystemName = L(lpSystemName);
	end

	local cbSid = ffi.new("DWORD[1]");
	local cchReferencedDomainName = ffi.new("DWORD[1]");
	local peUse = ffi.new("SID_NAME_USE[1]");
	local lpAccountName = L(accountName);

	local status = lsalookup.LookupAccountNameW(
    	nil,
    	lpAccountName,
    	nil,
    	cbSid,
    	nil,
    	cchReferencedDomainName,
    	peUse);

	if status == 0 then
		local err = errorhandling.GetLastError();
		if err ~= ERROR_INSUFFICIENT_BUFFER then
			return false, err;
		end
	end

	local Sid = ffi.new("uint8_t[?]", cbSid[0]);
	local ReferencedDomainName = ffi.new("WCHAR[?]", cchReferencedDomainName[0]+1);

	local status = lsalookup.LookupAccountNameW(
    	nil,
    	lpAccountName,
    	Sid,
    	cbSid,
    	ReferencedDomainName,
    	cchReferencedDomainName,
    	peUse);
	
	ReferencedDomainName = core_string.toAnsi(ReferencedDomainName);

	return SID(Sid), peUse[0], ReferencedDomainName; 
end


local sid, use, domain = lookupAccountName("administrator");

if not sid then
	return false, use
end


print("SID: ", sid);
