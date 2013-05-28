-- SecurityDescriptor.lua

local ffi = require("ffi");
local security_base = require("security_base_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local SID = require("SID");
local WinError = require("win_error");

--[[
GetSecurityDescriptorControl = advapiLib.GetSecurityDescriptorControl,


SetSecurityDescriptorControl = advapiLib.SetSecurityDescriptorControl,
SetSecurityDescriptorDacl = advapiLib.SetSecurityDescriptorDacl,
SetSecurityDescriptorGroup = advapiLib.SetSecurityDescriptorGroup,
SetSecurityDescriptorOwner = advapiLib.SetSecurityDescriptorOwner,
SetSecurityDescriptorRMControl = advapiLib.SetSecurityDescriptorRMControl,
SetSecurityDescriptorSacl = advapiLib.SetSecurityDescriptorSacl,
--]]



local SecurityDescriptor = {}
setmetatable(SecurityDescriptor, {
	__call = function(self, ...)
		return self:new(...);
	end,
	});

local SecurityDescriptor_mt = {
	__index = SecurityDescriptor;
}


SecurityDescriptor.new = function(self, ...)
	local Descriptor = ffi.new("SECURITY_DESCRIPTOR");
	if not Descriptor then
		return nil;
	end
	security_base.InitializeSecurityDescriptor(Descriptor, ffi.C.SECURITY_DESCRIPTOR_REVISION);

	local obj = {
		Descriptor = Descriptor;
	};

	setmetatable(obj, SecurityDescriptor_mt);

	return obj;
end


SecurityDescriptor.getControlInfo = function(self)
	local pControl = ffi.new("SECURITY_DESCRIPTOR_CONTROL[1]");
	local lpdwRevision = ffi.new("DWORD[1]");

	local status = security_base.GetSecurityDescriptorControl(self.Descriptor,
		pControl, lpdwRevision);

	if status == 0 then 
		return false, errorhandling.GetLastError();
	end

	return pControl[0];
end

SecurityDescriptor.isValid = function(self)
	return security_base.IsValidSecurityDescriptor(self.Descriptor) > 0;
end

--
-- Discretionary Access Control List (DACL)
--
SecurityDescriptor.isDaclPresent = function(self)
	local lpbPresent = ffi.new("BOOL[1]");
	local pacl = ffi.new("PACL[1]");
	local lpbDefaulted = ffi.new("BOOL[1]");

	local status = security_base.GetSecurityDescriptorDacl(self.Descriptor, 
		lpbPresent,
		pacl,
		lpbDefaulted);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end


	if lpbPresent[0] == 0 then
		return false;
	end

	return true, pacl[0];
end

SecurityDescriptor.getDacl = function(self)
	local present, dacl = self:isDaclPresent();

	if not present then
		return false, dacl;
	end

	return dacl;
end

--
-- System Access Control List (SACL)
--
SecurityDescriptor.isSaclPresent = function(self)
	local lpbPresent = ffi.new("BOOL[1]");
	local pacl = ffi.new("PACL[1]");
	local lpbDefaulted = ffi.new("BOOL[1]");

	local status = security_base.GetSecurityDescriptorSacl(self.Descriptor, 
		lpbPresent,
		pacl,
		lpbDefaulted);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end


	if lpbPresent[0] == 0 then
		return false;
	end

	return true, pacl[0];
end

SecurityDescriptor.getSacl = function(self)
	local present, acl = self:isSaclPresent();

	if not present then
		return false, acl;
	end

	return acl;
end

SecurityDescriptor.getGroup = function(self)
	local pGroup = ffi.new("PSID[1]");
	local lpbGroupDefaulted = ffi.new("BOOL[1]");

	local status = security_base.GetSecurityDescriptorGroup(self.Descriptor, pGroup, lpbGroupDefaulted);

	if pGroup[0] == nil then
		return nil;
	end

	return SID(pGroup[0]), lpbGroupDefaulted[0];
end

SecurityDescriptor.getOwner = function(self)
	local pEntity = ffi.new("PSID[1]");
	local lpbDefaulted = ffi.new("BOOL[1]");

	local status = security_base.GetSecurityDescriptorOwner(self.Descriptor, pEntity, lpbDefaulted);

	if pEntity[0] == nil then
		return nil;
	end

	return SID(pEntity[0]), lpbDefaulted[0];
end


SecurityDescriptor.getLength = function(self)
	if not self:isValid() then
		return false, "descriptor is not valid";
	end

	return security_base.GetSecurityDescriptorLength(self.Descriptor);
end

-- Resource Manager Control Bits
SecurityDescriptor.isRMControlPresent = function(self)
	local RMControl = ffi.new("UCHAR[1]");
	local status = security_base.GetSecurityDescriptorRMControl(self.Descriptor, RMControl);
	
	if status ~= ERROR_SUCCESS then
		return false, status;
	end

	return tonumber(RMControl[0]);
end

SecurityDescriptor.getRMControlBits = function(self)
	return self:isRMControlPresent();
end

return SecurityDescriptor;
