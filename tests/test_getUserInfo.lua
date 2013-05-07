local ffi = require("ffi");

local sspi = require("sspi");

--[[
    // unknown name type
    NameUnknown = 0,

    // CN=John Doe, OU=Software, OU=Engineering, O=Widget, C=US
    NameFullyQualifiedDN = 1,

    // Engineering\JohnDoe
    NameSamCompatible = 2,

    // Probably "John Doe" but could be something else.  I.e. The
    // display name is not necessarily the defining RDN.
    NameDisplay = 3,


    // String-ized GUID as returned by IIDFromString().
    // eg: {4fa050f0-f561-11cf-bdd9-00aa003a77b6}
    NameUniqueId = 6,

    // engineering.widget.com/software/John Doe
    NameCanonical = 7,

    // someone@example.com
    NameUserPrincipal = 8,

    // Same as NameCanonical except that rightmost '/' is
    // replaced with '\n' - even in domain-only case.
    // eg: engineering.widget.com/software\nJohn Doe
    NameCanonicalEx = 9,

    // www/srv.engineering.com/engineering.com
    NameServicePrincipal = 10,

    // DNS domain name + SAM username
    // eg: engineering.widget.com\JohnDoe
    NameDnsDomain = 12
--]]

print(sspi.getUserName(ffi.C.NameFullyQualifiedDN));
print(sspi.getUserName(ffi.C.NameSamCompatible));
print(sspi.getUserName(ffi.C.NameDisplay));
print(sspi.getUserName(ffi.C.NameUniqueId));
print(sspi.getUserName(ffi.C.NameCanonical));
print(sspi.getUserName(ffi.C.NameUserPrincipal));
print(sspi.getUserName(ffi.C.NameCanonicalEx));

