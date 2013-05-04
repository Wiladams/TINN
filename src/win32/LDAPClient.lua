-- LDAPClient.lua

local ffi = require("ffi");
local wldap32 = require("wldap32_ffi");

--[[
	Create a smart handle to wrap the basic session 
	handle.  This will ensure that the session handle
	is properly cleaned up if it goes out of scope.

	Some basic operations are also implemented, such as
	setting and getting attributes of the session handle.

	All the really heavy duty activity lives on the
	LDAPClient class though.
--]]

ffi.cdef[[
typedef struct {
	LDAP * Handle;
} LDAPSessionHandle;
]]
LDAPSessionHandle = ffi.typeof("LDAPSessionHandle");
LDAPSessionHandle_t = {};
LDAPSessionHandle_mt = {
	__gc = function(self)
		print("GC: LDAPSessionHandle");
		wldap32.ldap_unbind(self.Handle);
	end,

	__index = LDAPSessionHandle_t,	
}
ffi.metatype(LDAPSessionHandle, LDAPSessionHandle_mt);

LDAPSessionHandle_t.setOption = function(self, option, invalue)
	local status = wldap32.ldap_set_option(self.Handle, option, ffi.cast("void *", invalue));

	if status ~= ffi.C.LDAP_SUCCESS then
		return false, wldap32.LdapGetLastError();
	end

	return true;
end

LDAPSessionHandle_t.setIntOption = function(self, opt, value)
	local pValue = ffi.new("int32_t[1]", value);
	
	return self:setOption(opt, pValue);
end

LDAPSessionHandle_t.setVersion = function(self, version)
	self:setIntOption(ffi.C.LDAP_OPT_PROTOCOL_VERSION, version);
end

LDAPSessionHandle_t.connect = function(self, timeout)
	local status = wldap32.ldap_connect(self.Handle, nil);
	if status ~= ffi.C.LDAP_SUCCESS then
		return false, wldap32.LdapGetLastError();
	end

	return true;
end


--[[
	This is the primary interface to the LDAP Service.
--]]
local LDAPClient = {
	Native = wldap32;
}
setmetatable(LDAPClient, {
	__call = function(self,...)
		return self:new(...);
	end,
});

local LDAPClient_mt = {
	__index = LDAPClient,
}

--[[
	Schema for params
		HostName		Name of host machine running LDAP Server
		PortNumber		Port number server is listening on
		SizeLimit		Limit the number of records returned each query
		Version			Version of the LDAP API to use
--]]
LDAPClient.new = function(self, params)
	params = params or {};

	params.HostName = params.HostName or "localhost";
	params.PortNumber = params.PortNumber or ffi.C.LDAP_PORT;
	params.Version = params.Version or ffi.C.LDAP_VERSION3;


	local handle = wldap32.ldap_initA(params.HostName, params.PortNumber);

	if handle == nil then
		return false, wldap32.LdapGetLastError();
	end

	local obj = {
		Handle = LDAPSessionHandle(handle);
	}
	setmetatable(obj, LDAPClient_mt);

	-- Setup options
	obj.Handle:setVersion(params.Version);

	-- Size limit
	if params.SizeLimit then
		obj.Handle:setIntOption(ffi.C.LDAP_OPT_SIZELIMIT, params.SizeLimit);
	end

	return obj;
end

LDAPClient.connect = function(self)
	return self.Handle:connect();
end


return LDAPClient;
