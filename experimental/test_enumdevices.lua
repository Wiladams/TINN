--test_enumdevices.lua
local ffi = require("ffi")
local DeviceRecordSet = require("DeviceRecordSet")
local serpent = require("serpent")

local drs = DeviceRecordSet();

local idx = 0;
local fields = {
		ffi.C.SPDRP_DEVICEDESC,
		ffi.C.SPDRP_MFG,
		ffi.C.SPDRP_CLASS,
		ffi.C.SPDRP_ENUMERATOR_NAME,
		ffi.C.SPDRP_FRIENDLYNAME,
		ffi.C.SPDRP_LOCATION_INFORMATION ,
		ffi.C.SPDRP_LOCATION_PATHS,
		ffi.C.SPDRP_PHYSICAL_DEVICE_OBJECT_NAME,
		ffi.C.SPDRP_SERVICE,
	}

for record in drs:devices(fields) do
	idx = idx + 1;
	print("==========")
	print(serpent.serialize(record, {}))
end
