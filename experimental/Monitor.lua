local ffi = require("ffi")
local Monitor_ffi = require("Monitor_ffi")


-- A Monitor class
local Monitor = {}
setmetatable(Monitor, {
	__call = function(self, ...)
		return self:create(...)
	end,
})
local Monitor_mt = {
	__index = Monitor,

	__tostring = function(self)
		return string.format("Name: %s, Area: %s, WorkArea: %s", self.Name, self.Area, self.WorkArea)
	end,
}

Monitor.init = function(self, hMonitor)
	if hMonitor == nil then
		return false, "a valid handle was not specified"
	end

	local info = Monitor_ffi.MONITORINFOEXA();
	local res = Monitor_ffi.GetMonitorInfoA(hMonitor, ffi.cast("MONITORINFO *",info))

	local obj = {
		Name = ffi.string(info.szDevice);
		Flags = info.dwFlags;
    	Area = ffi.new("RECT", info.rcMonitor);
    	WorkArea = ffi.new("RECT",info.rcWork);
	}
	setmetatable(obj, Monitor_mt)

	return obj;
end

Monitor.create = function(self, ...)
	return self:init(...)
end

-- Returns an iterator of all the monitors 
-- in the system
Monitor.Monitors = function(self, hdc, lprcClip, dwData)
	dwData = dwData or 0

	local resultList = {}

	-- Monitor enumeration callback
	local enumMonitors = function(hMonitor, HDC, LPRECT, LPARAM)
		local mon = Monitor:init(hMonitor)
		table.insert(resultList, mon);

		return 1;	-- return 1 to indicate enumeration should continue
	end

	Monitor_ffi.EnumDisplayMonitors(nil, nil, enumMonitors, 0)

	-- This closure simply enumerates the list
	-- of monitors that have been retrieved already
	local idx = 0;
	local closure = function()
		idx = idx + 1;
		if idx > #resultList then
			return nil;
		end

		return resultList[idx]
	end

	return closure
end


return Monitor
