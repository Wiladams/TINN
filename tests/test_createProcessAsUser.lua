--
-- References
-- http://msdn.microsoft.com/en-us/library/windows/desktop/aa379608(v=vs.85).aspx
--
local ffi = require("ffi");
local sspi = require("sspicli");
local errorhandling = require("core_errorhandling_l1_1_1");
require("win_error");
local core_string = require("core_string_l1_1_0");
local core_process = require("core_processthreads_l1_1_1");
local security_base = require("security_base_l1_2_0");

local Token = require("Token");


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
        print(k,v);
    end
--[[
    for key,value in ipairs(tbl) do
        if type(value) == "table" then
            for k,v in pairs(value) do
                print(k,v);
            end
        else
            print(key, value);
        end
    end
--]]
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
    --  print(v.Sid);
    --end
end





local logonTypes = {
LOGON32_LOGON_INTERACTIVE     =  2;
LOGON32_LOGON_NETWORK         =  3;
LOGON32_LOGON_BATCH           =  4;
LOGON32_LOGON_SERVICE         =  5;
LOGON32_LOGON_UNLOCK          =  7;
LOGON32_LOGON_NETWORK_CLEARTEXT =8;
LOGON32_LOGON_NEW_CREDENTIALS   =9;    
};

local providerType = {
LOGON32_PROVIDER_DEFAULT    =0;
LOGON32_PROVIDER_WINNT35    =1;
LOGON32_PROVIDER_WINNT40    =2;
LOGON32_PROVIDER_WINNT50    =3;
LOGON32_PROVIDER_VIRTUAL    =4;
}

-- Call LogonUser to obtain a handle to an access token.
local domain = arg[1];
local user = arg[2];
local password = arg[3];

local tryAllLogins = function(domain, user, password)
    local res = {};

    --logonUser(domain, user, password, dwLogonType, dwLogonProvider);
    local userToken;
    for prname,prval in pairs(providerType) do
        print("PROVIDER: ", prname);
        for k,lot in pairs(logonTypes) do
            local userToken, err = logonUser(domain, user, password, lot, prval);

            if userToken then 
                table.insert(res, {Provider=prname, LogonType=k});
                print('\t',k, "SUCCESS");
            else 
                --print('\t',k, "FAIL");
            end
        end
    end

    return res;
end



--local successes = tryAllLogins(domain, user, password);


-- for read users
local userToken, err = logonUser(domain, user, password, ffi.C.LOGON32_LOGON_BATCH, ffi.C.LOGON32_PROVIDER_WINNT50);
-- for appgtest
--local userToken, err = logonUser(domain, user, password, ffi.C.LOGON32_LOGON_INTERACTIVE, ffi.C.LOGON32_PROVIDER_WINNT50);


if not userToken then
    print("logonUser, ERROR: ", err)
    return false, 'no user token created'
end


local status = security_base.ImpersonateLoggedOnUser(userToken.Handle.Handle);

-- print the token 
print("========== USER TOKEN ==========")
printToken(userToken);



-- turn on quota increase privilege on process token
--print("========== PROCESS TOKEN ========");
--local processToken = Token:getProcessToken();
--processToken:enablePrivilege(Token.Privileges.SE_INCREASE_QUOTA_NAME);
--processToken:enablePrivilege(Token.Privileges.SE_ASSIGNPRIMARYTOKEN_NAME );
--printToken(processToken);


security_base.ImpersonateSelf(ffi.C.SecurityIdentification);





--[==[

pi = ffi.new("PROCESS_INFORMATION[1]");
si = ffi.new("STARTUPINFOW");

si.cb = ffi.sizeof("STARTUPINFOW");
si.lpReserved = nil;
si.lpDesktop = nil;
si.lpTitle = core_string.toUnicode("Title");
si.dwX = 0;
si.dwY = 0;
si.dwXSize = 640;
si.dwYSize = 480;
si.dwXCountChars = 80;
si.dwYCountChars = 24;
si.dwFillAttribute = 0;
si.dwFlags = 0;
si.wShowWindow = 0;
si.cbReserved2 = 0;
si.lpReserved2 = nil;

 
--                        // Create structs
--                        SECURITY_ATTRIBUTES saProcessAttributes = new SECURITY_ATTRIBUTES();
--                        SECURITY_ATTRIBUTES saThreadAttributes = new SECURITY_ATTRIBUTES();
 
-- Now create the process as the user
local saProcessAttributes = nil;
local saThreadAttributes = nil;

local status = core_process.CreateProcessAsUserW(
    userToken.Handle.Handle, 
    nil, 
    core_string.toUnicode("C:\\tools\\tinn\\tinn.exe"),
    saProcessAttributes, 
    saThreadAttributes, 
    false, 
    0, 
    nil, 
    nil, 
    si, 
    pi);

if status == 0 then
    local err = errorhandling.GetLastError();
    print("CreateProcess, ERROR: ", err);
end

pi = pi[0];


--]==]