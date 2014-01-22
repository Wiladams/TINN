
local ffi = require("ffi")

--local User32Lib = ffi.load("user32")
local Desktop_ffi = require("Desktop_ffi")
local errorhandling = require("core_errorhandling_l1_1_1");

ffi.cdef[[
typedef struct {
	HWINSTA	Handle;
	bool AutoClose;
} WindowStationHandle_t;
]]

local WindowStationHandle_t = ffi.typeof("WindowStationHandle_t");
local WindowStationHandle_mt = {
	__gc = function(self)
		self:free()
	end,
	
	__new = function(ct, ...)
		return ffi.new(ct,...)
	end,
	
	__index = {
		free = function(self)
			if self.Handle ~= nil and self.AutoClose then
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

WindowStation.init = function(self, rawhandle, autoclose)
	autoclose = autoclose or false

	local obj = {
		Handle = WindowStation_t(rawhandle, autoclose)
	}
	setmetatable(obj, WindowStation_mt)

	return obj
end

-- By default, open the specified window station
WindowStation.create = function(self, name)
	local fInherit = true;
	local dwDesiredAccess = ffi.C.WINSTA_ALL_ACCESS; -- ACCESS_MASK

	local rawhandle = nil;
	local autoclose = false;

	if not name then
		rawhandle = Desktop_ffi.GetProcessWindowStation();
	else
		rawhandle = Desktop_ffi.OpenWindowStation(name, fInherit, dwDesiredAccess);
		autoclose = true;
	end

	if rawhandle == nil then
		return nil, errorhandling.GetLastError();
	end

	return self:init(rawhandle, autoclose)
end

WindowStation.createNew = function(self, name)
	local dwFlags = 0;
	local dwDesiredAccess = ffi.C.WINSTA_ALL_ACCESS; -- ACCESS_MASK
	local lpsa = nil;	-- Security_Attributes

	local rawhandle = Desktop_ffi.CreateWindowStation(name, dwFlags, 
		dwDesiredAccess, lpsa);

	if rawhandle == nil then
		return nil, errorhandling.GetLastError();
	end

	return self:init(rawhandle, true)
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


--[[
	Instance Methods
--]]
WindowStation.getNativeHandle = function(self)
	return self.Handle.Handle;
end

WindowStation.close = function(self)
	local res = self.Handle:free();
	--false, User32Lib.GetLastError();

	return res;
end

WindowStation.setAsProcessWindowStation = function(self)
	local res = Desktop_ffi.SetProcessWindowStation(self:getNativeHandle())

	if res == 0 then
		return false, errorhandling.GetLastError();
	end
end

return WindowStation;
