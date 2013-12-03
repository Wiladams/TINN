-- test_WindowStation.lua

local WindowStation = require("WindowStation")

local stations = WindowStation:getWindowStations()

for _,station in ipairs(stations) do
	print("Station: ", station)
end
