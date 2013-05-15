local ffi = require("ffi");

local Handle = require("Handle");
local WinNT = require("WinNT");
local WinError = require("win_error");

local sspi = require("sspicli");
local error_handling = require("core_errorhandling_l1_1_1");
local security_base = require("security_base_l1_2_0");
local core_process = require("core_processthreads_l1_1_1");
local core_string = require("core_string_l1_1_0");
local security_lookup = require("security_lsalookup_l2_1_0");

local SID = require("SID");


local tokenInfoStructs = {
	[ffi.C.TokenUser] = {ffi.typeof("TOKEN_USER")},
    [ffi.C.TokenGroups] = {ffi.typeof("TOKEN_GROUPS")},
    [ffi.C.TokenPrivileges] = {ffi.typeof("TOKEN_PRIVILEGES")},
    [ffi.C.TokenOwner] = {ffi.typeof("TOKEN_OWNER")},
    [ffi.C.TokenPrimaryGroup] = {ffi.typeof("TOKEN_PRIMARY_GROUP")},
    [ffi.C.TokenDefaultDacl] = {ffi.typeof("TOKEN_DEFAULT_DACL")},
    [ffi.C.TokenSource] = {ffi.typeof("TOKEN_SOURCE")},
    [ffi.C.TokenType] = {ffi.typeof("TOKEN_TYPE")},
--    [ffi.C.TokenImpersonationLevel] = {ffi.typeof("TOKEN_IMPERSONATION_LEVEL")},
    [ffi.C.TokenStatistics] = {ffi.typeof("TOKEN_STATISTICS")},
    [ffi.C.TokenRestrictedSids] = {ffi.typeof("TOKEN_GROUPS")},
--    [ffi.C.TokenSessionId] = {ffi.typeof("")},
    [ffi.C.TokenGroupsAndPrivileges] = {ffi.typeof("TOKEN_GROUPS_AND_PRIVILEGES")},
--    [ffi.C.TokenSessionReference] = {ffi.typeof("")},
    [ffi.C.TokenSandBoxInert] = {ffi.typeof("DWORD[1]")},
--    [ffi.C.TokenAuditPolicy] = {ffi.typeof("")},
    [ffi.C.TokenOrigin] = {ffi.typeof("TOKEN_ORIGIN")},
    [ffi.C.TokenElevationType] = {ffi.typeof("TOKEN_ELEVATION_TYPE")},
    [ffi.C.TokenLinkedToken] = {ffi.typeof("TOKEN_LINKED_TOKEN")},
    [ffi.C.TokenElevation] = {ffi.typeof("TOKEN_ELEVATION")},
    [ffi.C.TokenHasRestrictions] = {ffi.typeof("DWORD[1]")},
    [ffi.C.TokenAccessInformation] = {ffi.typeof("TOKEN_ACCESS_INFORMATION")},
    [ffi.C.TokenVirtualizationAllowed] = {ffi.typeof("DWORD[1]")},
    [ffi.C.TokenVirtualizationEnabled] = {ffi.typeof("DWORD[1]")},
    [ffi.C.TokenIntegrityLevel] = {ffi.typeof("TOKEN_MANDATORY_LABEL")},
    [ffi.C.TokenUIAccess] = {ffi.typeof("DWORD[1]")},
    [ffi.C.TokenMandatoryPolicy] = {ffi.typeof("TOKEN_MANDATORY_POLICY")},
    [ffi.C.TokenLogonSid] = {ffi.typeof("TOKEN_GROUPS")},
}

local getPrivilegeName = function(lpuid)
	local cchName = 256;
	local pcchName = ffi.new("DWORD[1]", cchName);
	local lpName = ffi.new("WCHAR[?]", cchName)
	local status = security_lookup.LookupPrivilegeNameW(nil, lpuid, lpName, pcchName);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return core_string.toAnsi(lpName);
end


local Token = {}
setmetatable(Token, {
	__call = function(self, ...)
		return self:new(...);
	end,

	__index = {
		getProcessToken = function(self, DesiredAccess)
			DesiredAccess = DesiredAccess or ffi.C.TOKEN_ALL_ACCESS;
	
			local ProcessHandle = core_process.GetCurrentProcess();
			local pTokenHandle = ffi.new("HANDLE [1]")
			local status  = core_process.OpenProcessToken (ProcessHandle, DesiredAccess, pTokenHandle);

			if status == 0 then
				return false, errorhandling.GetLastError();
			end

			return Token(pTokenHandle[0]);
		end,
	},
});

local Token_mt = {
	__index = Token;	
}

Token.new = function(self, rawhandle)
	local obj = {
		Handle = Handle(rawhandle);
	}

	setmetatable(obj, Token_mt);

	return obj;
end



Token.getTokenInfo = function(self, TokenInformationClass)
	TokenInformationClass = TokenInformationClass or ffi.C.TokenUser;
	local TokenInformation;
	local TokenInformationLength = 0;
	local ReturnLength = ffi.new("DWORD[1]");

	local status = security_base.GetTokenInformation(self.Handle.Handle, 
		TokenInformationClass, 
		TokenInformation, 
		TokenInformationLength,
		ReturnLength);

	if status == 0 then
		local err = error_handling.GetLastError();
		if err ~= ERROR_INSUFFICIENT_BUFFER then
			return false, err
		end
	end

	-- We should now have the length, so allocate a buffer of the right
	-- size and make the call again.
	TokenInformationLength = ReturnLength[0];
--	print("Info Size: ", TokenInformationLength);

	local tokenStruct = tokenInfoStructs[TokenInformationClass]
	if not tokenStruct then
		return false, "Uknown token information class"
	end

	tokenStruct = tokenStruct[1];
--	print("tokenStruct: ", tokenStruct);
--	print("tokenStruct length: ", ffi.sizeof(tokenStruct));
--	print("TokenInformationLength: ", TokenInformationLength);

	TokenInformation = ffi.new("uint8_t[?]", TokenInformationLength);
	ReturnLength[0] = 0;
	local status = security_base.GetTokenInformation(self.Handle.Handle, 
		TokenInformationClass, 
		TokenInformation, 
		TokenInformationLength,
		ReturnLength);

	if status == 0 then
		return false, error_handling.GetLastError();
	end

	return TokenInformation;
end



Token.getGroups = function(self)
	local tokInfo, err = self:getTokenInfo(ffi.C.TokenGroups);

	if not tokInfo then
		return false, err;
	end

	local tokGroups = ffi.cast("TOKEN_GROUPS *", tokInfo);

	local res = {}
	for i=0,tokGroups.GroupCount do
		local sid = tokGroups.Groups[i].Sid;
		local attrs = tokGroups.Groups[i].Attributes;
		local asid = SID(sid);
		if asid then
			local sidstr = tostring(asid); 
			if sidstr ~= nil then
				res[sidstr] = {Sid = asid, Attributes = attrs};
			end
		end
	end

	return res;
end

Token.getPrivileges = function(self)
	local tokInfo, err = self:getTokenInfo(ffi.C.TokenPrivileges);

	if not tokInfo then
		return false, err;
	end

	local tokPriv = ffi.cast("TOKEN_PRIVILEGES *", tokInfo);
--	print("Privilege Count: ", tokPriv.PrivilegeCount);
	local res = {};

	for i=0,tokPriv.PrivilegeCount-1 do		
		local privName = getPrivilegeName(tokPriv.Privileges[i].Luid);
		res[privName] = tokPriv.Privileges[i].Attributes;
	end

	return res;
end


Token.getSource = function(self)
	local tokInfo, err = self:getTokenInfo(ffi.C.TokenSource);

	if not tokInfo then
		return false, err;
	end

	local tokSource = ffi.cast("TOKEN_SOURCE *", tokInfo);	

	return ffi.string(tokSource.SourceName, ffi.C.TOKEN_SOURCE_LENGTH);
end

Token.getTokenType = function(self)
	local tokInfo, err = self:getTokenInfo(ffi.C.TokenType);

	if not tokInfo then
		return false, err;
	end

	local tokType = ffi.cast("TOKEN_TYPE *", tokInfo);
	if tokType == ffi.C.TokenPrimary then 
		return "Primary"
	end

	return "Impersonation";
end

Token.getUser = function(self)
	local tokInfo, err = self:getTokenInfo(ffi.C.TokenUser);

	if not tokInfo then
		return false, err;
	end

	local tokUser = ffi.cast("TOKEN_USER *", tokInfo);

	return SID(tokUser.User.Sid);
end

return Token;
