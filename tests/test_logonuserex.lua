-- Reference
-- http://msdn.microsoft.com/en-us/library/windows/desktop/aa378184(v=vs.85).aspx

local ffi = require("ffi");
local sspi = require("sspicli");
local errorhandling = require("core_errorhandling_l1_1_1");
require("win_error");
local core_string = require("core_string_l1_1_0");
--local WinNT = require("WinNT");
local Token = require("Token");



--[[
	Test case
--]]

local logonUser = function(lpszDomain, lpszUsername, lpszPassword, dwLogonType, dwLogonProvider)
	dwLogonType = dwLogonType or ffi.C.LOGON32_LOGON_BATCH;
	dwLogonProvider = dwLogonProvider or ffi.C.LOGON32_PROVIDER_WINNT50;

	-- out
	local phToken = ffi.new("HANDLE[1]");

	local status = sspi.LogonUserExA(lpszUsername, lpszDomain, lpszPassword, 
		dwLogonType, 
		dwLogonProvider, 
		phToken,
		nil, nil, nil, nil);

--print("LogonUserExA, Status: ", status);
	
	if status == 0 then
		return false, errorhandling.GetLastError();
	end 

	return Token(phToken[0]);
end


local printTable = function(tbl)
	for k,v in pairs(tbl) do
		print(k,v)
	end
end

local printToken = function(token)
	print("TOKEN TYPE")
	print("=================")
	print(token:getTokenType());
	print();

	print("PRIVILEGES");
	print("==========")
	privs = token:getPrivileges();
	printTable(privs);

	print();

	print("SOURCE");
	print("=================")
	print(token:getSource());
	print();

	print("USER");
	print("=================");
	local user = token:getUser();
	print(user);
	print();

	print("GROUPS");
	print("=================");
	--local groups = token:getGroups();
	--for k,v in pairs(groups) do
	--	print(v.Sid);
	--end
end


local token, err = logonUser(arg[1], arg[2], arg[3]);

if not token then
	print("logonUser Error: ", err)
	return false, err;
end

printToken(token);


