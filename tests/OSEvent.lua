-- OSEvent.lua

local ffi = require("ffi");
local core_synch = require("core_synch_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");


local OSEvent = {}
setmetatable(OSEvent, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local OSEvent_mt = {
	__index = OSEvent;
}

OSEvent.init = function(self, rawhandle)
	local obj = {
		Handle = rawhandle;
	};
	setmetatable(obj, OSEvent_mt);

	return obj;
end

OSEvent.create = function(self, bInitialState, bManualReset, lpEventAttributes, lpName)
	bManualReset = bManualReset or false;
	bInitialState = bInitialState or false;

	local rawhandle = core_synch.CreateEventA(lpEventAttributes,
		bManualReset,
		bInitialState,
		lpName);

	if rawhandle == nil then
		return false, errorhandling.GetLastError();
	end

	return self:init(rawhandle);
end

OSEvent.getNativeHandle = function(self)
	return self.Handle;
end

OSEvent.set = function(self)
	local status = core_synch.SetEvent(self:getNativeHandle());

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

OSEvent.clear = function(self)
	local status = core_synch.ResetEvent(self:getNativeHandle());
	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

OSEvent.wait = function(self, dwMilliseconds)
	dwMilliseconds = dwMilliseconds or ffi.C.INFINITE;
	
	local status = core_synch.WaitForSingleObject(self:getNativeHandle(), dwMilliseconds);	

	if status == WAIT_FAILED then
		return false, errorhandling.GetLastError();
	end

	return status;
end

return OSEvent;
