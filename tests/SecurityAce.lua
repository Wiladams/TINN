-- SecurityAce.lua

local ffi = require("ffi");
local WinNT = require("WinNT");
local SID = require("SID");


local AceTypes = {
	[ffi.C.ACCESS_ALLOWED_ACE_TYPE] = ffi.typeof("ACCESS_ALLOWED_ACE");	
	[ffi.C.ACCESS_DENIED_ACE_TYPE] = ffi.typeof("ACCESS_DENIED_ACE");
};



ffi.cdef[[
typedef struct {
	uint32_t	specific:16;
	uint32_t	standard:16;
	uint32_t	ass:1;
	uint32_t	maxallowed:1;
	uint32_t	reserved:2;
	uint32_t	generic_all:1;
	uint32_t	generic_exec:1;
	uint32_t	generic_write:1;
	uint32_t	generic_read:1;
} RightsBits;

typedef union AccessMask {
	int32_t Mask;
	struct {
		uint32_t	specific:16;
		uint32_t	standard:16;
		uint32_t	ass:1;
		uint32_t	maxallowed:1;
		uint32_t	reserved:2;
		uint32_t	generic_all:1;
		uint32_t	generic_exec:1;
		uint32_t	generic_write:1;
		uint32_t	generic_read:1;
	} Parsed;
} AccessMask;
]];
RightsBits = ffi.typeof("RightsBits");
AccessMask = ffi.typeof("AccessMask");



local SecurityAce = {}
setmetatable(SecurityAce, {
	__call = function(self, ...)
		return self:init(...);
	end,
});

local SecurityAce_mt = {
	__index = SecurityAce,

	__tostring = function(self)
        local allowed = ffi.cast("ACCESS_ALLOWED_ACE *", self.Handle);
        local SidOffset = ffi.offsetof(ffi.typeof("ACCESS_ALLOWED_ACE"), "SidStart");
        local SidPtr = ffi.cast("char *",self.Handle)+SidOffset;
--print("SidPtr: ", SidPtr);
--print("Raw Ptr: ", ffi.cast("char *",allowed.SidStart));

        local asid = SID(SidPtr);
        --printAccessMask(allowed.Mask);
        local masker = AccessMask(allowed.Mask);

        return string.format("%s  Mask: 0x%x", tostring(asid), masker.Mask);
	end,
};

SecurityAce.init = function(self, aceptr)
	local obj = {
		Handle = aceptr;
	};
	setmetatable(obj, SecurityAce_mt);

	return obj;
end


SecurityAce.hasGenericAll = function(self)
	return RightsBits(ffi.cast("ACCESS_ALLOWED_ACE *", self.Handle).Mask).generic_all > 0;
end

SecurityAce.hasGenericRead = function(self)
	return RightsBits(ffi.cast("ACCESS_ALLOWED_ACE *", self.Handle).Mask).generic_read > 0;
end

SecurityAce.hasGenericWrite = function(self)
	return RightsBits(ffi.cast("ACCESS_ALLOWED_ACE *", self.Handle).Mask).generic_write > 0;
end

SecurityAce.hasGenericExec = function(self)
	return RightsBits(ffi.cast("ACCESS_ALLOWED_ACE *", self.Handle).Mask).generic_exec > 0;
end

SecurityAce.getSpecificRights = function(self)
	return AccessMask(ffi.cast("ACCESS_ALLOWED_ACE *", self.Handle).Mask).Parsed.specific;
end

SecurityAce.getStandardRights = function(self)
	return AccessMask(ffi.cast("ACCESS_ALLOWED_ACE *", self.Handle).Mask).Parsed.standard;
end

SecurityAce.toTable = function(self)
	local res = {
		GenericAll = self:hasGenericAll() or nil;
		GenericRead = self:hasGenericRead() or nil;
		GenericWrite = self:hasGenericWrite() or nil;
		GenericExec = self:hasGenericExec() or nil;
		
		Specific = self:getSpecificRights();
		Standard = self:getStandardRights();
	};

	return res;
end



return SecurityAce;
