-- 
-- References
-- http://msdn.microsoft.com/en-us/library/windows/desktop/aa446595(v=vs.85).aspx
--
local ffi = require('ffi');
local WinBase = require("WinBase");
local security_base = require("security_base_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");

local SecurityAcl = require("SecurityAcl");
local SecurityDescriptor = require("SecurityDescriptor");
local SID = require("SID");



local printDescriptor = function(descrip)
    print("IsValid: ", descrip:isValid());
    print("Length: ", descrip:getLength());
    print("Owner: ", descrip:getOwner());
    print("Group: ", descrip:getGroup());
    print("DACL Present: ", descrip:isDaclPresent());
    print("SACL Present: ", descrip:isSaclPresent());
    print("RM Control Present: ", descrip:isRMControlPresent());    
    print("Control Info: ", descrip:getControlInfo());
end

local printAcl = function(acl)
    print("==============================");
    print("Security ACL: ", acl, err);
    print("Sizes");
    local sizes, err = acl:getSizes();
    if sizes then
        for k,v in pairs(sizes) do 
            print(k,v);
        end
    end
end


local descrip = SecurityDescriptor();

printDescriptor(descrip);

local SIDAuthNT = SECURITY_NT_AUTHORITY;



-- Create a well-known SID for the Everyone group.
local pEveryoneSID = SID:create(SECURITY_WORLD_SID_AUTHORITY, 1, ffi.C.SECURITY_WORLD_RID);


local pAdminSID = SID:create(SECURITY_NT_AUTHORITY, 2, 
    ffi.C.SECURITY_BUILTIN_DOMAIN_RID,
    ffi.C.DOMAIN_ALIAS_RID_ADMINS);

print("EVERYONE SID: ", pEveryoneSID);
print("ADMIN SID: ", pAdminSID);



local acl, err = SecurityAcl(4*1024);

printAcl(acl);


local AccessMask = FILE_SHARE_READ;
print("AccessMask: ", AccessMask);

print("Add allow Access: ", acl:addAllowAccess(pEveryoneSID, AccessMask));

printAcl(acl);


--[[
-- Initialize an EXPLICIT_ACCESS structure for an ACE.
-- The ACE will allow Everyone read access to the key.
local ea = ffi.new("EXPLICIT_ACCESS[2]");
ea[0].grfAccessPermissions = KEY_READ;
ea[0].grfAccessMode = SET_ACCESS;
ea[0].grfInheritance= NO_INHERITANCE;
ea[0].Trustee.TrusteeForm = TRUSTEE_IS_SID;
ea[0].Trustee.TrusteeType = TRUSTEE_IS_WELL_KNOWN_GROUP;
ea[0].Trustee.ptstrName  = (LPTSTR) pEveryoneSID;
--]]

--[[

    local pAdminSID = nil;
    PACL pACL = NULL;
    PSECURITY_DESCRIPTOR pSD = NULL;
    SECURITY_ATTRIBUTES sa;
    LONG lRes;
    HKEY hkSub = NULL;



    // Create a SID for the BUILTIN\Administrators group.
    if(! AllocateAndInitializeSid(&SIDAuthNT, 2,
                     SECURITY_BUILTIN_DOMAIN_RID,
                     DOMAIN_ALIAS_RID_ADMINS,
                     0, 0, 0, 0, 0, 0,
                     &pAdminSID)) 
    {
        _tprintf(_T("AllocateAndInitializeSid Error %u\n"), GetLastError());
        goto Cleanup; 
    }

    -- Initialize an EXPLICIT_ACCESS structure for an ACE.
    -- The ACE will allow the Administrators group full access to
    -- the key.
    ea[1].grfAccessPermissions = KEY_ALL_ACCESS;
    ea[1].grfAccessMode = SET_ACCESS;
    ea[1].grfInheritance= NO_INHERITANCE;
    ea[1].Trustee.TrusteeForm = TRUSTEE_IS_SID;
    ea[1].Trustee.TrusteeType = TRUSTEE_IS_GROUP;
    ea[1].Trustee.ptstrName  = (LPTSTR) pAdminSID;

    -- Create a new ACL that contains the new ACEs.
    local dwRes;
    dwRes = SetEntriesInAcl(2, ea, NULL, &pACL);
    if (ERROR_SUCCESS != dwRes) 
    {
        _tprintf(_T("SetEntriesInAcl Error %u\n"), GetLastError());
        goto Cleanup;
    }

    // Initialize a security descriptor.  
    pSD = (PSECURITY_DESCRIPTOR) LocalAlloc(LPTR, 
                             SECURITY_DESCRIPTOR_MIN_LENGTH); 
    if (NULL == pSD) 
    { 
        _tprintf(_T("LocalAlloc Error %u\n"), GetLastError());
        goto Cleanup; 
    } 
 
    if (!InitializeSecurityDescriptor(pSD,
            SECURITY_DESCRIPTOR_REVISION)) 
    {  
        _tprintf(_T("InitializeSecurityDescriptor Error %u\n"),
                                GetLastError());
        goto Cleanup; 
    } 
 
    // Add the ACL to the security descriptor. 
    if (!SetSecurityDescriptorDacl(pSD, 
            TRUE,     // bDaclPresent flag   
            pACL, 
            FALSE))   // not a default DACL 

    // Initialize a security attributes structure.
    sa.nLength = sizeof (SECURITY_ATTRIBUTES);
    sa.lpSecurityDescriptor = pSD;
    sa.bInheritHandle = FALSE;

    // Use the security attributes to set the security descriptor 
    // when you create a key.
    local dwDisposition
    lRes = RegCreateKeyEx(HKEY_CURRENT_USER, _T("mykey"), 0, _T(""), 0, 
            KEY_READ | KEY_WRITE, &sa, &hkSub, &dwDisposition); 

--]]
