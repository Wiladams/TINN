
local ffi = require("ffi");
local security_base = require("security_base_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local SecurityAce = require("SecurityAce");


-- FindFirstFreeAce = advapiLib.FindFirstFreeAce,

SecurityAcl = {}
setmetatable(SecurityAcl, {
	__call = function(self, ...)
		return self:create(...);
	end,

	__index = SecurityAcl,
});

SecurityAcl_mt = {
	__index = SecurityAcl;
}

SecurityAcl.create = function(self, nAclLength, dwAclRevision)
	nAclLength = nAclLength or 0;
	dwAclRevision = dwAclRevision or ffi.C.ACL_REVISION;

	if nAclLength == 0 then
		nAclLength = ffi.sizeof("ACL");
	end

	local acl = ffi.new("uint8_t[?]", nAclLength);
		
	local status = security_base.InitializeAcl(ffi.cast("PACL",acl), nAclLength, dwAclRevision);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return self:init(acl);
end

SecurityAcl.init = function(self, aclbuff)
	local obj = {
		Acl = aclbuff;
	}
	setmetatable(obj, SecurityAcl_mt);

	return obj;
end


SecurityAcl.getInfo = function(self, dwAclInformationClass)
	dwAclInformationClass = dwAclInformationClass or ffi.C.AclSizeInformation
	local pAclInformation = nil;

	if dwAclInformationClass == ffi.C.AclSizeInformation then
		pAclInformation = ffi.new("ACL_SIZE_INFORMATION");
	elseif dwAclInformationClass == ffi.C.AclRevisionInformation then
		pAclInformation = ffi.new("ACL_REVISION_INFORMATION");
	else
		return false, "uknown AclInformationClass";
	end
	local nAclInformationLength = ffi.sizeof(pAclInformation);

	local status = security_base.GetAclInformation(ffi.cast("PACL",self.Acl),
		pAclInformation,
		nAclInformationLength,
		dwAclInformationClass);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return pAclInformation;
end

SecurityAcl.getRevision = function(self)
	local info, err = self:getInfo(ffi.C.AclRevisionInformation);
	if not info then 
		return false, err;
	end

	return info.AclRevision;
end

SecurityAcl.getSizes = function(self)
	local info, err = self:getInfo(ffi.C.AclSizeInformation);
	if not info then
		return false, err;
	end

	return {
		AceCount = info.AceCount;
		BytesUsed = info.AclBytesInUse;
		BytesFree = info.AclBytesFree;
	};
end

--AddAce = advapiLib.AddAce,
SecurityAcl.add = function(self, ace)
end

--DeleteAce = advapiLib.DeleteAce,
SecurityAcl.delete = function(self, idx)
end

-- GetAce = advapiLib.GetAce,
--[[
BOOL
GetAce (
  PACL pAcl,
  DWORD dwAceIndex,
  LPVOID *pAce
  );
 --]]
SecurityAcl.getEntry = function(self, idx)
	idx = idx or 0;
	local sizes = self:getSizes();
	if idx > sizes.AceCount-1 then
		return false, "index exceeds number of ACEs";
	end

	local pAce = ffi.new("void *[1]");
	local status = security_base.GetAce(ffi.cast("PACL",self.Acl), idx, pAce);
	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return pAce[0];
end

SecurityAcl.entries = function(self)
    local sizes, err = self:getSizes();
    local idx = -1;

    local closure = function()
    	if not sizes then
    		return nil;
    	end

    	idx = idx + 1;

    	if idx > sizes.AceCount - 1 then
    		return nil;
    	end

        local entry, err = self:getEntry(idx);
        if not entry then 
        	return nil;
        end

        return SecurityAce:init(entry);
    end

	return closure;
end

--AddAuditAccessAce = advapiLib.AddAuditAccessAce,
--AddAuditAccessAceEx = advapiLib.AddAuditAccessAceEx,
--AddAuditAccessObjectAce = advapiLib.AddAuditAccessObjectAce,

SecurityAcl.addAuditAccess = function(self, ace)
end


-- AddMandatoryAce = advapiLib.AddMandatoryAce,
SecurityAcl.addMandatoryAccess = function(self, ace)
end

--AddAccessAllowedAce = advapiLib.AddAccessAllowedAce,
--AddAccessAllowedAceEx = advapiLib.AddAccessAllowedAceEx,
--AddAccessAllowedObjectAce = advapiLib.AddAccessAllowedObjectAce,

SecurityAcl.addAllowAccess = function(self, sid, AccessMask)
	local dwAceRevision = ffi.C.ACL_REVISION;
	AccessMask = AccessMask or 0;

--print("addAllowAccess: ", sid);
--print("      revision: ", dwAceRevision);
--print("        Access: ", AccessMask);

	local status = security_base.AddAccessAllowedAce(
    	ffi.cast("PACL",self.Acl),
    	dwAceRevision,
    	AccessMask,
    	sid:getNativeHandle());

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

--AddAccessDeniedAce = advapiLib.AddAccessDeniedAce,
--AddAccessDeniedAceEx = advapiLib.AddAccessDeniedAceEx,
--AddAccessDeniedObjectAce = advapiLib.AddAccessDeniedObjectAce,

SecurityAcl.addDenyAccess = function(self, sid, AccessMask)
	local dwAceRevision = ffi.C.ACL_REVISION;
	AccessMask = AccessMask or 0;

	local status = security_base.AddAccessDeniedAce(
    	ffi.cast("PACL",self.Acl),
    	dwAceRevision,
    	AccessMask,
    	sid:getNativeHandle());

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

return SecurityAcl;
