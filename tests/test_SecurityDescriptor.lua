-- 
-- References
-- http://msdn.microsoft.com/en-us/library/windows/desktop/aa446595(v=vs.85).aspx
--
local ffi = require('ffi');
local bit = require("bit");
local bor = bit.bor;

local BitBang = require("BitBang");
local WinBase = require("WinBase");
local WinNT = require("WinNT");
local security_base = require("security_base_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");

local SecurityAce = require("SecurityAce");
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


--[[
Access Rights Mask
Bits    Meaning
0–15
Specific rights. Contains the access mask specific to the object type associated with the mask.

16–23
Standard rights. Contains the object's standard access rights.

24
Access system security (ACCESS_SYSTEM_SECURITY). It is used to indicate access to a system access control list (SACL). This type of access requires the calling process to have the SE_SECURITY_NAME (Manage auditing and security log) privilege. If this flag is set in the access mask of an audit access ACE (successful or unsuccessful access), the SACL access will be audited.

25
Maximum allowed (MAXIMUM_ALLOWED).

26–27
Reserved.

28
Generic all (GENERIC_ALL).

29
Generic execute (GENERIC_EXECUTE).

30
Generic write (GENERIC_WRITE).

31
Generic read (GENERIC_READ).
--]]

local printAccessMask = function(mask)
    local rights = {
        specific = BitBang.getbitsvalue(mask, 0, 16);
        standard = BitBang.getbitsvalue(mask, 16, 16);
        ass = BitBang.getbitsvalue(mask, 24, 1);
        maxallowed = BitBang.getbitsvalue(mask, 25, 1);
        reserved = BitBang.getbitsvalue(mask, 26, 2);
        generic_all = BitBang.getbitsvalue(mask, 28, 1);
        generic_exec = BitBang.getbitsvalue(mask, 29, 1);
        generic_write = BitBang.getbitsvalue(mask, 30, 1);
        generic_read = BitBang.getbitsvalue(mask, 31, 1);
    }

    for k,v in pairs(rights) do
        print(k,v);
    end
end


local printAcl = function(acl)
    print("==============================");
    print("Security ACL: ", acl, err);
    print("Sizes");
    local sizes, err = acl:getSizes();
    if sizes then
        print("==  Sizes  ==");
        for k,v in pairs(sizes) do 
            print(k,v);
        end
    end

    for entry in acl:entries() do
        print("ACE: ", tostring(entry));
        local tbl = entry:toTable();
        for k,v in pairs(tbl) do
            print(k,v);
        end

--[[
        local ace = ffi.cast("ACE_HEADER *", entry);
        print("++ ENTRY ++")
        print("entry: ", ace, err);
        print("Type: ", ace.AceType);
        print("Flags: ", string.format("0x%x", ace.AceFlags));
        print("Size: ", ace.AceSize);

        if ace.AceType == ffi.C.ACCESS_ALLOWED_ACE_TYPE then
            local allowed = ffi.cast("ACCESS_ALLOWED_ACE *", entry);
        end
--]]
    end
end


local descrip = SecurityDescriptor:create();

printDescriptor(descrip);

local SIDAuthNT = SECURITY_NT_AUTHORITY;



-- Create a well-known SID for the Everyone group.
local pEveryoneSID = SID:create(SECURITY_WORLD_SID_AUTHORITY, 1, ffi.C.SECURITY_WORLD_RID);


local pAdminSID = SID:create(SECURITY_NT_AUTHORITY, 2, 
    ffi.C.SECURITY_BUILTIN_DOMAIN_RID,
    ffi.C.DOMAIN_ALIAS_RID_ADMINS);

print("EVERYONE SID: ", pEveryoneSID);
print("ADMIN SID: ", pAdminSID);



local acl, err = SecurityAcl:create(4*1024);

printAcl(acl);


local AccessMask = bor(ffi.C.GENERIC_READ,
    FILE_SHARE_READ, 
    FILE_SHARE_WRITE, 
    WinNT.StandardRights.Execute);
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
