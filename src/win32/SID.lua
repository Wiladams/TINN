local ffi = require("ffi");
local sddl = require("security_sddl_l1_1_0");
local security_lookup = require("security_lsalookup_l2_1_0");
local core_string = require("core_string_l1_1_0");
local errorhandling = require("core_errorhandling_l1_1_1");


-- typedef enum _SID_NAME_USE
local getSidUse = function(use)

	if use == ffi.C.SidTypeUser then return "SidTypeUser" end
	if use == ffi.C.SidTypeGroup then return "SidTypeGroup" end
	if use == ffi.C.SidTypeDomain then return "SidTypeDomain" end
	if use == ffi.C.SidTypeAlias then return "SidTypeAlias" end
	if use == ffi.C.SidTypeWellKnownGroup then return "SidTypeWellKnownGroup" end
	if use == ffi.C.SidTypeDeletedAccount then return "SidTypeDeletedAccount" end
	if use == ffi.C.SidTypeInvalid then return "SidTypeInvalid" end
	if use == ffi.C.SidTypeUnknown then return "SidTypeUnknown" end
	if use == ffi.C.SidTypeComputer then return "SidTypeComputer" end
	if use == ffi.C.SidTypeLabel then return "SidTypeLabel" end

	return "<unknown>";
end

local SID = {}
setmetatable(SID, {
	__call = function(self, ...)
		return self:new(...);
	end,
});

local SID_mt = {
	__index = SID;

	__tostring = function(self)
		return self:asString();
	end,
}

SID.new = function(self, sid)
	--print("SID.new");
	local obj = {
		Handle = sid;
	}
	setmetatable(obj, SID_mt);

	return obj;
end

SID.asString = function(self)
	self:getAccountInfo();

	return string.format("%s => %s\\%s [%s]", self.SIDString, self.Domain, self.Name, self.Use);
end

SID.getAccountInfo = function(self)
	if self.Name then
		return self;
	end

	-- convert sid to string representation
	local StringSid = ffi.new("WCHAR *[1]");
	local status = sddl.ConvertSidToStringSidW(self.Handle, StringSid);

	-- convert the string the ansi 
	self.SIDString = core_string.toAnsi(StringSid[0]);

	local Name = nil;
	local pcchName = ffi.new("DWORD[1]");
	local pcchReferencedDomainName = ffi.new("DWORD[1]");
	local peUse = ffi.new("SID_NAME_USE[1]");
	local status = security_lookup.LookupAccountSidW(nil, self.Handle, Name, pcchName, ReferencedDomainName, pcchReferencedDomainName, peUse);
 
	-- ERROR_NONE_MAPPED
	if status == 0 then 
		local err = errorhandling.GetLastError();
		if err ~= ERROR_INSUFFICIENT_BUFFER then
			return false, err;
		end
	end

	local Name = ffi.new("WCHAR[?]", pcchName[0]);
	local ReferencedDomainName = ffi.new("WCHAR[?]", pcchReferencedDomainName[0]);

	local status = security_lookup.LookupAccountSidW(nil, 
		self.Handle, 
		Name, pcchName, 
		ReferencedDomainName, pcchReferencedDomainName, 
		peUse);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	self.Name = core_string.toAnsi(Name);
	self.Domain = core_string.toAnsi(ReferencedDomainName);
	self.Use = getSidUse(peUse[0]);

	return self;
end

SID.getAccountName = function(self)
	if not self.Name then
		self:getAccountInfo();
	end

	if self.Domain and self.Name then
		return self.Domain.."\\"..self.Name;
	elseif self.Name then
		return self.Name;
	end

	return self:asString();
end

return SID;
