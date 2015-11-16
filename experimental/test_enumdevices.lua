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
	print("----------")
end

local function enumerateAll()
	local drs = DeviceRecordSet();

	-- show everything for every device
	each(printIt, drs:devices())
--[[
	-- do a projection on the fields
	local function projection(fields, gen, param, state)
		local function projector(x)
			local res = {}
			for _,name in ipairs(fields) do
				--print("name: ", name, x[name])
				res[name] = x[name];
			end
			return res
		end

		return map(projector, gen, param, state)
	end
	--each(printIt, map(function(x) return {objectname = x.objectname, description = x.description} end, drs:devices()))
	each(printIt, projection({"locationpaths", "objectname", "description", "friendlyname"}, drs:devices()))

	-- show only certain records
	local function enumeratorFilter(name, x)
		return x.enumerator == name
	end

	--each(printIt, filter(Functor(enumeratorFilter, "STORAGE"), drs:devices()))
--]]
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

enumerateAll();
--enumerateBatteries();
