local Machine = require("Machine")
local JSON = require("dkjson")

local function showDOSDevices()
	print("---- DOS Devices ----")
	local res = {}
	for junction in Machine.Devices:DOSDeviceIterator() do
		local junct = {junction=junction, paths={}}
		for path in Machine.Devices:DOSDeviceIterator(junction) do
			table.insert(junct.paths, path)
		end
		table.insert(res, junct)
	end

	-- show it as a json string

	print(JSON.encode(res, {indent = true}))
end


showDOSDevices();
