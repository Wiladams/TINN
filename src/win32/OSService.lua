local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;
local band = bit.band;

local service_core = require("service_core_l1_1_1");
local service_manager = require("service_management_l1_1_0");

local core_string = require("core_string_l1_1_0")
local WinError = require("win_error");


local OSService = {}
setmetatable(OSService, {
	__call = function(self, ...)
		return self:new(...);
	end,
})

local OSService_mt = {
	__index = OSService;
}

OSService.new = function(self, handle)
	local obj = {
		Handle = handle;
	}
	setmetatable(obj, OSService_mt);

	return obj;
end

return SCServiceHandle;
