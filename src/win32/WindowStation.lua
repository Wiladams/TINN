
local ffi = require("ffi")

local User32Lib = ffi.load("user32")
local Desktop_ffi = require("Desktop_ffi")

ffi.cdef[[
typedef struct {
	HWINSTA	Handle;
} WindowStationHandle_t;
]]

local WindowStationHandle_t = ffi.typeof("WindowStationHandle_t");
local WindowStationHandle_mt = {
	__gc = function(self)
		self:free()
	end,
	
	__new = function(ct, params)
		return ffi.new(ct,params)
	end,
	
	__index = {
		free = function(self)
			if self.Handle ~= nil then
				Desktop_ffi.CloseWindowStation(self.Handle);
				self.Handle = nil;
			end

			return true;
		end,
		
	},
}
ffi.metatype(WindowStationHandle_t, WindowStationHandle_mt);







local WindowStation = {}
setmetatable(WindowStation, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local WindowStation_mt = {
	__index = WindowStation,
}

WindowStation.init = function(self, rawhandle)
	local obj = {
		Handle = WindowStation_t(rawhandle)
	}
	setmetatable(obj, WindowStation_mt)

	return obj
end

-- By default, open the specified window station
WindowStation.create = function(self, lpszWinSta)
	local fInherit = true;
	local dwDesiredAccess = ffi.C.WINSTA_ALL_ACCESS; -- ACCESS_MASK

	local rawhandle = Desktop_ffi.OpenWindowStation(lpszWinSta, fInherit,dwDesiredAccess);

	if rawhandle == nil then
		return nil, err 
	end

	return self:init(rawhandle)
end

WindowStation.getWindowStations = function(self)
	local stations = {}

	--jit.off(enumdesktop)
	function enumstation(stationname, lParam)
		local name = ffi.string(stationname)
		--print("Station: ", name)
		table.insert(stations, name)

		return 0
	end


	while Desktop_ffi.EnumWindowStationsA(enumstation, 0) > 0 do end

	return stations
end

WindowStation.getNativeHandle = function(self)
	return self.Handle.Handle;
end

WindowStation.close = function(self)
	local res = self.Handle:free();
	--false, User32Lib.GetLastError();

	return res;
end


return WindowStation;
