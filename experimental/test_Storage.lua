local Storage = require("Storage")
local Machine = require("Machine")
local JSON = require("dkjson")

local function showLogicalDriveNames()
	for name in Storage:logicalDriveNames() do
		local dtype, typeName = Storage:getDriveType(name)
		print(string.format("DRIVE: %s (%s)", name, typeName))
	end
end

local function showVolumes()
	print("==== VOLUMES ====")
	for name in Storage:volumeNames() do
		print("Volume: ", name)
	end
end

local function showDOSDevices()
	print("==== DOS Devices ====")
	local res = {}
	for junction in Machine.Devices:DOSDevices() do
		local junct = {junction=junction, paths={}}
		for path in Machine.Devices:DOSDevices(junction) do
			table.insert(junct.paths, path)
		end
		table.insert(res, junct)
	end

	-- show it as a json string

	print(JSON.encode(res, {indent = true}))
end

showLogicalDriveNames();
showVolumes();
showDOSDevices();