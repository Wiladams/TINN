-- SecurityContext.lua

local ffi = require("ffi");
local sspi = require("sspi");
local SecurityInterface = sspi.SecurityInterface;


--[[
 	This is the raw data type for the context handle
-- 	The handle needs to be properly freed upon garbage
-- 	collection, so this wrapper exists.
--]]


ffi.cdef[[
typedef struct {
	PCtxtHandle 	Handle;
} SecurityContextHandle, *PSecurityContextHandle;
]]
SecurityContextHandle = ffi.typeof("SecurityContextHandle");
SecurityContextHandle_t = {}
SecurityContextHandle_mt = {
	__gc = function(self)
		print("GC: SecurityContextHandle");
		SecurityInterface.DeleteSecurityContext(self.Handle)
	end,	

	__index = SecurityContextHandle_t,
}
ffi.metatype(SecurityContextHandle, SecurityContextHandle_mt);


SecurityContextHandle_t.QueryContextAttributes = function(self, which, buffer)
	local res = SecurityInterface.QueryContextAttributesA(self.Handle, which, buffer);
	if res ~= SEC_E_OK then
		return false, res;
	end

	return buffer;
end

-- A map of the 'which' to the type of buffer that must
-- be used for that type of attribute
ffi.cdef[[
// These can be found in schannel.lua
//static const int SECPKG_ATTR_REMOTE_CERT_CONTEXT = 0x53;
//static const int SECPKG_ATTR_LOCAL_CERT_CONTEXT = 0x54;
//static const int SECPKG_ATTR_ROOT_STORE = 0x55;
//static const int SECPKG_ATTR_ISSUER_LIST_EX = 0x59;
//static const int SECPKG_ATTR_CONNECTION_INFO = 0x5a;
//static const int SECPKG_ATTR_EAP_KEY_BLOCK = 0x5b;
//static const int SECPKG_ATTR_SESSION_INFO = 0x5d;
//static const int SECPKG_ATTR_APP_DATA = 0x5e;
//static const int SECPKG_ATTR_SUPPORTED_SIGNATURES = 0x66;
static const int SECPKG_ATTR_CREDS_2 = 0x80000086;
]]


local attribmap = {

[ffi.C.SECPKG_ATTR_REMOTE_CERT_CONTEXT]	= {struct = ffi.typeof("PCCERT_CONTEXT")};
[ffi.C.SECPKG_ATTR_LOCAL_CERT_CONTEXT]	= {struct = ffi.typeof("PCCERT_CONTEXT")};
--[ffi.C.SECPKG_ATTR_ROOT_STORE]			= {struct = ffi.typeof("HCERTCONTEXT")};
[ffi.C.SECPKG_ATTR_ISSUER_LIST_EX]		= {struct = ffi.typeof("SecPkgContext_IssuerListInfoEx")};
[ffi.C.SECPKG_ATTR_CONNECTION_INFO]		= {struct = ffi.typeof("SecPkgContext_ConnectionInfo")};
[ffi.C.SECPKG_ATTR_EAP_KEY_BLOCK]		= {struct = ffi.typeof("SecPkgContext_EapKeyBlock")};
[ffi.C.SECPKG_ATTR_SESSION_INFO]		= {struct = ffi.typeof("SecPkgContext_SessionInfo")};
[ffi.C.SECPKG_ATTR_SUPPORTED_SIGNATURES]		= {struct = ffi.typeof("SecPkgContext_SupportedSignatures")};

[ffi.C.SECPKG_ATTR_APP_DATA]			= {struct = ffi.typeof("SecPkgContext_SessionAppData")};
--[ffi.C.SECPKG_ATTR_CREDS_2]				= {struct = ffi.typeof("SecPkgContext_ClientCreds")};


[ffi.C.SECPKG_ATTR_SIZES]           = {struct = ffi.typeof("SecPkgContext_Sizes")};
[ffi.C.SECPKG_ATTR_NAMES]           = {struct = ffi.typeof("SecPkgContext_NamesA")};
[ffi.C.SECPKG_ATTR_LIFESPAN]        = {struct = ffi.typeof("SecPkgContext_Lifespan")};
[ffi.C.SECPKG_ATTR_DCE_INFO]        = {struct = ffi.typeof("SecPkgContext_DceInfo")};
[ffi.C.SECPKG_ATTR_STREAM_SIZES]    = {struct = ffi.typeof("SecPkgContext_StreamSizes")};
[ffi.C.SECPKG_ATTR_KEY_INFO]        = {struct = ffi.typeof("SecPkgContext_KeyInfoA")};
[ffi.C.SECPKG_ATTR_AUTHORITY]       = {struct = ffi.typeof("SecPkgContext_AuthorityA")};
[ffi.C.SECPKG_ATTR_PROTO_INFO]      = 7;
[ffi.C.SECPKG_ATTR_PASSWORD_EXPIRY] = {struct = ffi.typeof("SecPkgContext_PasswordExpiry")};
[ffi.C.SECPKG_ATTR_SESSION_KEY]     = {struct = ffi.typeof("SecPkgContext_SessionKey")};
[ffi.C.SECPKG_ATTR_PACKAGE_INFO]    = {struct = ffi.typeof("SecPkgContext_PackageInfoA")};
[ffi.C.SECPKG_ATTR_USER_FLAGS]      = 11;
[ffi.C.SECPKG_ATTR_NEGOTIATION_INFO] = {struct = ffi.typeof("SecPkgContext_NegotiationInfoA")};
[ffi.C.SECPKG_ATTR_NATIVE_NAMES]    = {struct = ffi.typeof("SecPkgContext_NativeNamesA")};
[ffi.C.SECPKG_ATTR_FLAGS]           = {struct = ffi.typeof("SecPkgContext_Flags")};
[ffi.C.SECPKG_ATTR_USE_VALIDATED]   = 15;
[ffi.C.SECPKG_ATTR_CREDENTIAL_NAME] = 16;
[ffi.C.SECPKG_ATTR_TARGET_INFORMATION] = {struct = ffi.typeof("SecPkgContext_TargetInformation")};
[ffi.C.SECPKG_ATTR_ACCESS_TOKEN]    = {struct = ffi.typeof("SecPkgContext_AccessToken")};
[ffi.C.SECPKG_ATTR_TARGET]          = 19;
[ffi.C.SECPKG_ATTR_AUTHENTICATION_ID]  = 20;
[ffi.C.SECPKG_ATTR_LOGOFF_TIME]     = 21;
[ffi.C.SECPKG_ATTR_NEGO_KEYS]         = 22;
[ffi.C.SECPKG_ATTR_PROMPTING_NEEDED]  = 24;
[ffi.C.SECPKG_ATTR_UNIQUE_BINDINGS]   = {struct = ffi.typeof("SecPkgContext_Bindings")};
[ffi.C.SECPKG_ATTR_ENDPOINT_BINDINGS] = {struct = ffi.typeof("SecPkgContext_Bindings")};
[ffi.C.SECPKG_ATTR_CLIENT_SPECIFIED_TARGET] = 27;
[ffi.C.SECPKG_ATTR_LAST_CLIENT_TOKEN_STATUS] = 30;
[ffi.C.SECPKG_ATTR_NEGO_PKG_INFO]        = 31;
[ffi.C.SECPKG_ATTR_NEGO_STATUS]          = 32;
[ffi.C.SECPKG_ATTR_CONTEXT_DELETED]      = 33;
[ffi.C.SECPKG_ATTR_SUBJECT_SECURITY_ATTRIBUTES] = 128;
}


SecurityContextHandle_t.GetAttribute = function(self, which)
	-- lookup the attribute in the table
	local entry = attribmap[which];
	if not entry then
		return false, "Uknown attribute";
	end
	local buffer = entry.struct();

	local attrib, err = self:QueryContextAttributes(which, buffer);

	if not attrib then
		return false, err
	end

	return attrib;
end

return SecurityContextHandle
