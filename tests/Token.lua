local ffi = require("ffi");
local sspi = require("sspicli");
local error_handling = require("core_errorhandling_l1_1_1");
local security_base = require("security_base_l1_2_0");
require("win_error");
local core_string = require("core_string_l1_1_0");
local Handle = require("Handle");
local WinNT = require("WinNT");


local tokenInfoStructs = {
	[ffi.C.TokenUser] = {ffi.typeof("TOKEN_USER")},
    [ffi.C.TokenGroups] = {ffi.typeof("TOKEN_GROUPS")},
    [ffi.C.TokenPrivileges] = {ffi.typeof("TOKEN_PRIVILEGES")},
    [ffi.C.TokenOwner] = {ffi.typeof("TOKEN_OWNER")},
    [ffi.C.TokenPrimaryGroup] = {ffi.typeof("TOKEN_PRIMARY_GROUP")},
    [ffi.C.TokenDefaultDacl] = {ffi.typeof("TOKEN_DEFAULT_DACL")},
    [ffi.C.TokenSource] = {ffi.typeof("TOKEN_SOURCE")},
    [ffi.C.TokenType] = {ffi.typeof("TOKEN_TYPE")},
    [ffi.C.TokenImpersonationLevel] = {ffi.typeof("TOKEN_IMPERSONATION_LEVEL")},
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



local Token = {}
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
	--print("Info Size: ", TokenInformationLength);

	local tokenStruct = tokenInfoStructs[TokenInformationClass]
	if not tokenStruct then
		return false, "Uknown token information class"
	end

	print("tokenStruct length: ", ffi.sizeof(tokenStruct));
	print("TokenInformationLength: ", TokenInformationLength);

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
	--return ffi.cast(ffi.typeof("$ *",tokenStruct), TokenInformation);
end

