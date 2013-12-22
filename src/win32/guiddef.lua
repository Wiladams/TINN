--
-- From guiddef.h
--
local ffi = require "ffi"
local C = ffi.C


ffi.cdef[[
typedef struct {
    unsigned long 	Data1;
    unsigned short	Data2;
    unsigned short	Data3;
    unsigned char	Data4[8];
} GUID, UUID, *LPGUID;
]]

ffi.cdef[[
typedef const GUID *	LPCGUID;
typedef const GUID *	REFGUID;

typedef GUID 			IID;
typedef IID *			LPIID;
typedef const IID *		REFIID;

typedef GUID 			CLSID;
typedef CLSID *			LPCLSID;
typedef const GUID *	REFCLSID;
]]


local function bytecompare(a, b, n)
	local res = true
	for i=0,n-1 do
		if a[i] ~= b[i] then
			return false
		end
	end
	return res
end

GUID = ffi.typeof("GUID");
GUID_mt = {
	__tostring = function(self)
		local res = string.format("%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
			self.Data1, self.Data2, self.Data3,
			self.Data4[0], self.Data4[1],
			self.Data4[2], self.Data4[3], self.Data4[4],
			self.Data4[5], self.Data4[6], self.Data4[7])
		return res
	end,

	__eq = function(a, b)
		return (a.Data1 == b.Data1) and
			(a.Data2 == b.Data2) and
			(a.Data3 == b.Data3) and
			bytecompare(a.Data4, b.Data4, 4)
	end,

	__index = {
		Define = function(self, name, l, w1, w2, b1, b2,  b3,  b4,  b5,  b6,  b7,  b8 )
			return GUID({ l, w1, w2, { b1, b2,  b3,  b4,  b5,  b6,  b7,  b8 } }), name
		end,

		DefineOle = function(self, name, l, w1, w2)
			return GUID({ l, w1, w2, { 0xC0,0,0,0,0,0,0,0x46 } }), name
		end,
	},
}
GUID = ffi.metatype("GUID", GUID_mt)

--require "CGuid"

GUID_NULL = GUID()
IID_NULL = GUID_NULL
CLSID_NULL = GUID_NULL
FMTID_NULL = GUID_NULL


function DEFINE_GUID(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8)
	return GUID():Define(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8)
end

DEFINE_UUID = DEFINE_GUID

function DEFINE_OLEGUID(name, l, w1, w2)
	return GUID():DefineOle(name, l, w1, w2)
end

--[[
	Useful routines
--]]

function IsEqualIID(riid1, riid2)
	return riid1 == riid2
end

function IsEqualCLSID(rclsid1, rclsid2)
	return rclsid1 == rclsid2
end

function IsEqualFMTID(rfmtid1, rfmtid2)
	return rfmtid1 == rfmtid2
end




-- From Rpcrt4.h

Rpcrt4 = ffi.load("Rpcrt4")

ffi.cdef[[
int UuidCreate(UUID * Uuid);

int UuidFromStringA(const char * StringUuid, UUID * Uuid);

int UuidToStringA(UUID * Uuid , char ** StringUuid);
]]


-- Helpful function for constructing a UUID/GUID
-- from a string
function UUIDFromString(stringid)
	local id = ffi.new("UUID")
	Rpcrt4.UuidFromStringA(stringid, id)

	return id
end

function GetNewGUID()
	local lpGUID = ffi.new("GUID[1]")
	local status = Rpcrt4.UuidCreate(lpGUID)
	if status ~= 0 then	-- RPC_S_OK
		return nil
	end
	
	return lpGUID[0]
end
