local ffi = require('ffi');
local WinBase = require("WinBase");
local security_base = require("security_base_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");

local SecurityAcl = require("SecurityAcl");
local SecurityDescriptor = require("SecurityDescriptor");
local SID = require("SID");



local pEveryoneSID = SID:create(SECURITY_WORLD_SID_AUTHORITY, 1, ffi.C.SECURITY_WORLD_RID);
local pEveryoneSID2 = SID:create(SECURITY_WORLD_SID_AUTHORITY, 1, ffi.C.SECURITY_WORLD_RID);
local pAdminSID = SID:create(SECURITY_NT_AUTHORITY, 2, 
    ffi.C.SECURITY_BUILTIN_DOMAIN_RID,
    ffi.C.DOMAIN_ALIAS_RID_ADMINS);

print("EQUAL (everyone1 == everyone1): ", pEveryoneSID == pEveryoneSID);
print("EQUAL (everyone1 == everyone2): ", pEveryoneSID == pEveryoneSID2);
print("EQUAL (everyone1 == adminsid): ", pEveryoneSID == pAdminSID);
