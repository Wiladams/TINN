local ffi = require("ffi");

local Handle = require("Handle");
local WinNT = require("WinNT");
local WinError = require("win_error");

local sspi = require("sspicli");
local error_handling = require("core_errorhandling_l1_1_1");
local core_process = require("core_processthreads_l1_1_1");
local core_string = require("core_string_l1_1_0");
local security_base = require("security_base_l1_2_0");
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


local Token = {
	Privileges = {
		SE_CREATE_TOKEN_NAME              = "SeCreateTokenPrivilege";
		SE_ASSIGNPRIMARYTOKEN_NAME        = "SeAssignPrimaryTokenPrivilege";
		SE_LOCK_MEMORY_NAME               = "SeLockMemoryPrivilege";
		SE_INCREASE_QUOTA_NAME            = "SeIncreaseQuotaPrivilege";
		SE_UNSOLICITED_INPUT_NAME         = "SeUnsolicitedInputPrivilege";
		SE_MACHINE_ACCOUNT_NAME           = "SeMachineAccountPrivilege";
		SE_TCB_NAME                       = "SeTcbPrivilege";
		SE_SECURITY_NAME                  = "SeSecurityPrivilege";
		SE_TAKE_OWNERSHIP_NAME            = "SeTakeOwnershipPrivilege";
		SE_LOAD_DRIVER_NAME               = "SeLoadDriverPrivilege";
		SE_SYSTEM_PROFILE_NAME            = "SeSystemProfilePrivilege";
		SE_SYSTEMTIME_NAME                = "SeSystemtimePrivilege";
		SE_PROF_SINGLE_PROCESS_NAME       = "SeProfileSingleProcessPrivilege";
		SE_INC_BASE_PRIORITY_NAME         = "SeIncreaseBasePriorityPrivilege";
		SE_CREATE_PAGEFILE_NAME           = "SeCreatePagefilePrivilege";
		SE_CREATE_PERMANENT_NAME          = "SeCreatePermanentPrivilege";
		SE_BACKUP_NAME                    = "SeBackupPrivilege";
		SE_RESTORE_NAME                   = "SeRestorePrivilege";
		SE_SHUTDOWN_NAME                  = "SeShutdownPrivilege";
		SE_DEBUG_NAME                     = "SeDebugPrivilege";
		SE_AUDIT_NAME                     = "SeAuditPrivilege";
		SE_SYSTEM_ENVIRONMENT_NAME        = "SeSystemEnvironmentPrivilege";
		SE_CHANGE_NOTIFY_NAME             = "SeChangeNotifyPrivilege";
		SE_REMOTE_SHUTDOWN_NAME           = "SeRemoteShutdownPrivilege";
		SE_UNDOCK_NAME                    = "SeUndockPrivilege";
		SE_SYNC_AGENT_NAME                = "SeSyncAgentPrivilege";
		SE_ENABLE_DELEGATION_NAME         = "SeEnableDelegationPrivilege";
		SE_MANAGE_VOLUME_NAME             = "SeManageVolumePrivilege";
		SE_IMPERSONATE_NAME               = "SeImpersonatePrivilege";
		SE_CREATE_GLOBAL_NAME             = "SeCreateGlobalPrivilege";
		SE_TRUSTED_CREDMAN_ACCESS_NAME    = "SeTrustedCredManAccessPrivilege";
		SE_RELABEL_NAME                   = "SeRelabelPrivilege";
		SE_INC_WORKING_SET_NAME           = "SeIncreaseWorkingSetPrivilege";
		SE_TIME_ZONE_NAME                 = "SeTimeZonePrivilege";
		SE_CREATE_SYMBOLIC_LINK_NAME      = "SeCreateSymbolicLinkPrivilege";
	},
}
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

Token.getLocalPrivilege = function(self, lpName)
	if not lpName then
		return false, "no privilege specified"
	end

	lpSystemName = nil;
	lpName = core_string.toUnicode(lpName);

	local lpLuid = ffi.new("LUID[1]");
	local status = security_lookup.LookupPrivilegeValueW(lpSystemName, lpName, lpLuid);
	
	if status == 0 then
		return false, errorhandling.GetLastError();
	end
	return lpLuid[0];
end

--[[
typedef struct _TOKEN_PRIVILEGES {
    DWORD PrivilegeCount;
    LUID_AND_ATTRIBUTES Privileges[ANYSIZE_ARRAY];
} TOKEN_PRIVILEGES, *PTOKEN_PRIVILEGES;

BOOL
AdjustTokenPrivileges (
         HANDLE TokenHandle,
         BOOL DisableAllPrivileges,
     PTOKEN_PRIVILEGES NewState,
         DWORD BufferLength,
    PTOKEN_PRIVILEGES PreviousState,
    PDWORD ReturnLength
    );
--]]

Token.enablePrivilege = function(self, privilege)
	local lpLuid, err = self:getLocalPrivilege(privilege);
	if not lpLuid then
		return false, err;
	end

	local tkp = ffi.new("TOKEN_PRIVILEGES");
	tkp.PrivilegeCount = 1;
	tkp.Privileges[0].Luid = lpLuid;
	tkp.Privileges[0].Attributes = ffi.C.SE_PRIVILEGE_ENABLED;

	local status = security_base.AdjustTokenPrivileges(self.Handle.Handle, false, tkp, 0, nil, nil);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

Token.disablePrivilege = function(self, privilege)
	local lpLuid, err = self:getLocalPrivilege(privilege);
	if not lpLuid then
		return false, err;
	end

	local tkp = ffi.new("TOKEN_PRIVILEGES");
	tkp.PrivilegeCount = 1;
	tkp.Privileges[0].Luid = lpLuid;
	tkp.Privileges[0].Attributes = ffi.C.SE_PRIVILEGE_REMOVE;

	local status = security_base.AdjustTokenPrivileges(self.Handle.Handle, false, tkp, 0, nil, nil);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

return Token;
