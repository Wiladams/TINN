
local ffi = require("ffi");

local desktop_ffi = require("Desktop_ffi");

ffi.cdef[[
typedef struct {
	HDESK	Handle;
	bool	OwnAllocation;
} DesktopHandle;
]]

DesktopHandle = ffi.typeof("DesktopHandle");
DesktopHandle_mt = {
	__gc = function(self)
		if self.OwnAllocation then
			desktop_ffi.CloseDesktop(self.Handle);
		end
	end,
	
	__index = {
	},
}

local Desktop = {}
setmetatable(Desktop, {
	__call = function(self, ...)
		return self:create(...);
	end,
})

Desktop.init = function(self, rawhandle, ownit)
	local obj = {
		Handle = DesktopHandle(rawhandle, ownit)
	}
	setmetatable(obj, Desktop_mt);

	return obj;
end

Desktop.create = function(self, name, dwFlags, dwAccess, lpsa)
	dwFlags = dwFlags or 0
	dwAccess = dwAccess or 0
	lpsa = lpsa or nil;

	local rawhandle = desktop_ffi.CreateDesktopA(name, nil, nil, dwFlags, dwAccess, lpsa);
	if not rawhandle then
		return false, errorhandling.GetLastError();
	end

	return self:init(rawhandle, true);
end

Desktop.getNativeHandle = function(self)
	return self.Handle.Handle;
end


jit.off(GetDesktops)
Desktop.desktops = function(self, winsta)
	winsta = winsta or desktop_ffi.GetProcessWindowStation()

	local desktops = {}

	local counter = 0;

	jit.off(enumdesktop)
	function enumdesktop(desktopname, lParam)
		counter = counter + 1;
		local name = ffi.string(desktopname)
		--print("Desktop: ", counter, name)
		table.insert(desktops, name)

		return true
	end
	
	local enumproc = ffi.cast("DESKTOPENUMPROCA", enumdesktop);


	local result = desktop_ffi.EnumDesktopsA(winsta, enumproc, 0)
	print("RESULT: ", result);

	--repeat
	--	local result = desktop_ffi.EnumDesktopsA(winsta, enumproc, 0)  
	--	print(result, counter)
	--until not result;

	return desktops
end

return Desktop