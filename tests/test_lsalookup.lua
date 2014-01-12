
local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;


local WinError = require("win_error");

local errorhandling = require("core_errorhandling_l1_1_1");
local lsalookup = require("security_lsalookup_l2_1_0");
local core_string = require("core_string_l1_1_0");
local L = core_string.toUnicode;
local SID = require("SID");
local advapiLib = ffi.load("advapi32");
local NTSecAPI = require("NTSecAPI");
local Token = require("Token");


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

local test_lookupAccount = function(name)
	local sid, use, domain = lookupAccountName(name);

	if not sid then
		return false, use
	end

	print("SID: ", sid);
end

--[[
LsaOpenPolicy(
    PLSA_UNICODE_STRING SystemName,
    PLSA_OBJECT_ATTRIBUTES ObjectAttributes,
    ACCESS_MASK DesiredAccess,
    PLSA_HANDLE PolicyHandle
    );
--]]

ffi.cdef[[
typedef struct {
	LSA_HANDLE 		Handle;
} PolicyHandle;
]]
local PolicyHandle = ffi.typeof("PolicyHandle");
local PolicyHandle_mt = {
	__gc = function(self)
		NTSecAPI.LsaClose(self.Handle);
	end,
}
ffi.metatype(PolicyHandle, PolicyHandle_mt);


local openPolicyHandler = function()
	local SystemName = nil;
	local ObjectAttributes = ffi.new("LSA_OBJECT_ATTRIBUTES");
	local DesiredAccess = bor(ffi.C.POLICY_VIEW_LOCAL_INFORMATION, ffi.C.POLICY_LOOKUP_NAMES);
	local pPolicyHandle = ffi.new("LSA_HANDLE[1]");
	local status = advapiLib.LsaOpenPolicy(SystemName, ObjectAttributes, DesiredAccess, pPolicyHandle);

	print("LsaOpenPolicy: ", string.format("0x%x",status));

	if status ~= 0 then
		return false, status;
	end

	return PolicyHandle(pPolicyHandle[0]);
end


local test_enumdomains = function()
print("==== test_enumdomains()");

	local pHandle, err = openPolicyHandler();

	if not pHandle then
		return false, err;
	end

	local PreferedMaximumLength = 512;
	local EnumerationContext = ffi.new("LSA_ENUMERATION_HANDLE[1]");
	local Buffer = ffi.new("uint8_t * [1]");
	local pCountReturned = ffi.new("ULONG[1]");

	local status = lsalookup.LsaEnumerateTrustedDomains(
    	pHandle.Handle,
    	EnumerationContext,
    	ffi.cast("void **", Buffer),
    	PreferedMaximumLength,
    	pCountReturned);

	print("Status: ", string.format("0x%x",status));
	print("Count Returned: ", pCountReturned[0]);
end

local enumAccountRights = function()
	print("==== enumAccountPrivileges");

	-- get policy handle
	local pHandle, err = openPolicyHandler();

	if not pHandle then
		return false, err;
	end

	-- get token for current process
	local tok = Token:getProcessToken();

	local AccountSid = tok:getUser();
	local UserRights = ffi.new("PLSA_UNICODE_STRING[1]");
	local pCountOfRights = ffi.new("ULONG[1]");

	local status = NTSecAPI.LsaEnumerateAccountRights(pHandle.Handle,
    	AccountSid:getNativeHandle(),
    	UserRights, 
    	pCountOfRights);

	print("NT Status: ", string.format("0x%x", status));

	status = NTSecAPI.LsaNtStatusToWinError(status);

	print("Status: ", string.format("0x%x", status));
	print("Count of Rights: ", pCountOfRights[0]);
end

--test_lookupAccount("administrator");

test_enumdomains();

--enumAccountRights();
