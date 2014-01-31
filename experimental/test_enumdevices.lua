--test_enumdevices.lua
local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;
local band = bit.band;

local DeviceRecordSet = require("DeviceRecordSet")
local serpent = require("serpent")
local Functor = require("Functor")
local devguid = require("devguid")

local fun = require("fun")()


local function printIt(record)
	print("==========")
	each(print, record)
--[[
	for k,v in pairs(record) do
		print(k, v)
		if type(v) == "table" then
			printIt(v)
		end
	end
--]]
	print("----------")
end

local function enumerateAll()
	local drs = DeviceRecordSet();

	-- show everything for every device
	each(printIt, drs:devices())

	-- do a projection on the fields
--each(printIt, map(function(x) return {objectname = x.objectname, description = x.description} end, drs:devices()))

	-- show only certain records
	local function enumeratorFilter(x)
		return x.enumerator == "STORAGE"
	end

	--each(printIt, filter(enumeratorFilter, drs:devices()))
end


local function enumerateBatteries()
	local Flags = bor(ffi.C.DIGCF_PRESENT, ffi.C.DIGCF_DEVICEINTERFACE)
	local ClassGuid = GUID_DEVCLASS_BATTERY;
	
	local drs = DeviceRecordSet(Flags, ClassGuid);

	each(print, drs:interfaces(ClassGuid))
	--for _,name in  drs:interfaces(ClassGuid) do
	--	print(name)
	--end

end

--enumerateAll();
enumerateBatteries();
