-- test_tokeninfo.lua
--

local ffi = require("ffi");
local errorhandling = require("core_errorhandling_l1_1_1");
local core_string = require("core_string_l1_1_0");

local Token = require("Token");
local SID = require("SID");


local printDict = function(tbl)
	for k,v in pairs(tbl) do
		print(k,v)
	end
end


local printToken = function(token, params)
	params = params or {}

	print("TOKEN TYPE")
	print("=================")
	print(token:getTokenType());
	print();
	
	print("IMPERSONATION LEVEL");
	print("=================")
	print(token:getImpersonationLevel());
	print();

	print("PRIVILEGES");
	print("==========")
	privs = token:getPrivileges();
	printDict(privs);
	print();

print("SOURCE");
print("=================")
print(token:getSource());
print();

print("USER");
print("=================");
local user = token:getUser();
print(user);
--print(user:getAccountName());
print();

	if (params.Groups) then
		print("GROUPS");
		print("=================");
		local groups = token:getGroups();
		printDict(groups);
	end
	
	if (params.Capabilities) then
		print("Capabilities");
		print("=================");
		local capabilities,err = token:getCapabilities();
		if capabilities then
			printDict(capabilities);
		else
			print("ERROR: ", err);
		end
	end
end

local token, err = Token:getProcessToken();

if not token then
	return false, err;
end

printToken(token);

local duptoken, err = token:duplicate();
print("DUPTOKEN: ", duptoken, err);
printToken(duptoken,{Capabilities=true});
print("STATISTICS")
printDict(duptoken:getStats());

-- enable shutdown privilege 
--print("EnablePrivilege: ", token:enablePrivilege(Token.Privileges.SE_SHUTDOWN_NAME));

--print("After Enable Shutdown")
--printToken(token);