-- test_MMDevice.lua
local MMDevice = require("MMDevice")

for device in MMDevice:AudioEndpoints() do
	print("Device ID: ", device:getID())

	for property in device:properties() do
		print("  Property: ", property.vt, tostring(property))
	end
end

