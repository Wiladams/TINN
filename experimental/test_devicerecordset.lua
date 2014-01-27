-- test_devicerecordset.lua

local ffi = require("ffi")
local DeviceRecordSet = require("DeviceRecordSet")
local serpent = require("serpent")


local drs = DeviceRecordSet();

print("drs.Handle: ", drs.Handle)


local function test_regvalue()
	for i=0,99 do 
		local value, err = drs:getRegistryValue(ffi.C.SPDRP_DEVICEDESC, i)
		print(i, value, err)
		if not value then 
			break
		end
	end
end

test_regvalue();