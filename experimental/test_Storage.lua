local Storage = require("Storage")

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


showLogicalDriveNames();
showVolumes();
