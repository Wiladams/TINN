
local ffi = require("ffi");
local lsalookup = require("security_lsalookup_l2_1_0");
local sddl = require("security_sddl_l1_1_0");

local WinError = require("win_error");
local k32 = require("win_kernel32");
local core_string = require("core_string_l1_1_0");
local L = core_string.toUnicode;



local SID = {}
setmetatable(SID, {
	__call = function(self, ...)
		return self:new(...);
	end,
});

local SID_mt = {
	__index = SID;

	__tostring = function(self)
		return self:asString();
	end,
}

SID.new = function(self, sid)
	--print("SID.new");
	local obj = {
		Handle = sid;
	}
	setmetatable(obj, SID_mt);

	return obj;
end

SID.asString = function(self)
	if self.AsString then
		return self.AsString;
	end

	-- convert sid to string representation
	local StringSid = ffi.new("WCHAR *[1]");
	local status = sddl.ConvertSidToStringSidW(self.Handle, StringSid);

	-- convert the string the ansi 
	self.AsString = core_string.toAnsi(StringSid[0]);

	return self.AsString;
end


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
		local err = k32.GetLastError();
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
