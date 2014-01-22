-- security-sddl-l1-1-0.dll	
--api-ms-win-security-sddl-l1-1-0.dll	

local ffi = require("ffi");
local advapiLib = ffi.load("advapi32");
require("WTypes");
require("WinNT");


ffi.cdef[[
BOOL
ConvertSecurityDescriptorToStringSecurityDescriptorW(
    PSECURITY_DESCRIPTOR  SecurityDescriptor,
    DWORD RequestedStringSDRevision,
    SECURITY_INFORMATION SecurityInformation,
    LPWSTR  *StringSecurityDescriptor,
    PULONG StringSecurityDescriptorLen
    );

BOOL
ConvertSidToStringSidW(PSID Sid, LPWSTR  *StringSid);

BOOL
ConvertStringSecurityDescriptorToSecurityDescriptorW(
     LPCWSTR StringSecurityDescriptor,
     DWORD StringSDRevision,
    PSECURITY_DESCRIPTOR  *SecurityDescriptor,
    PULONG  SecurityDescriptorSize
    );

BOOL
ConvertStringSidToSidW(
    LPCWSTR   StringSid,
    PSID   *Sid
    );
]]

return {
    Lib = advapiLib,
    
	ConvertSecurityDescriptorToStringSecurityDescriptorW = advapiLib.ConvertSecurityDescriptorToStringSecurityDescriptorW,
	ConvertSidToStringSidW = advapiLib.ConvertSidToStringSidW,
	ConvertStringSecurityDescriptorToSecurityDescriptorW= advapiLib.ConvertStringSecurityDescriptorToSecurityDescriptorW,
	ConvertStringSidToSidW = advapiLib.ConvertStringSidToSidW,
}
