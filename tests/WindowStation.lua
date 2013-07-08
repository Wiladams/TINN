function GetWindowStations()
	local stations = {}

	--jit.off(enumdesktop)
	function enumstation(stationname, lParam)
		local name = ffi.string(stationname)
		print("Station: ", name)
		table.insert(stations, name)

		return 0
	end


	while C.EnumWindowStationsA(enumstation, 0) > 0 do end

	return stations
end