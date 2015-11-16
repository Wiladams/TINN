-- test_devicerecordset.lua

local ffi = require("ffi")
local DeviceRecordSet = require("DeviceRecordSet")
local serpent = require("serpent")


local drs = DeviceRecordSet();

--print("drs.Handle: ", drs.Handle)


local function test_regvalue()
	for i=0,99 do 
		local descrip, err = drs:getRegistryValue(ffi.C.SPDRP_DEVICEDESC, i)
		if (descrip) then
			io.write(string.format("%d\t%s", i, descrip))
			local friendly, err2 = drs:getRegistryValue(ffi.C.SPDRP_FRIENDLYNAME, i)
			if (friendly) then
				io.write(string.format("\t==> %s", friendly));
			end
			io.write("\n");
		else
			print("ERROR: ", err) 
			break
		end
	end
end

test_regvalue();