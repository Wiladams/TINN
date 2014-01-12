-- ETWProvider.lua
local ffi = require("ffi")

local eventing_provider = require("eventing_provider_l1_1_0")
local errorhandling = require("core_errorhandling_l1_1_1");

--[[
	The handle
--]]
ffi.cdef[[
typedef struct {
	REGHANDLE	Handle;
} ETWProviderHandle_t;
]]
local ETWProviderHandle_t = ffi.typeof("ETWProviderHandle_t")
local ETWProviderHandle_mt = {
	__gc = function(self)
		eventing_provider.EventUnregister(self.Handle)
	end,

	__index = {

	},
}


--[[
	Interface to provider
--]]
local ETWProvider = {}
setmetatable(ETWProvider, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local ETWProvider_mt = {
	__index = ETWProvider,
}

ETWProvider.enableTrace = function(self, TraceHandle, 
	ProviderId, SourceId, ControlCode, 
	Level, MatchAnyKeyword, MatchAlKeyword,
	Timout, EnableParameters)

	local res = eventing_provider.EnableTraceEx2(TraceHandle, ProviderId, ControlCode,
		Level, MatchAnyKeyword, MatchAllKeyword,
		Timout, EnableParameters);


end

ETWProvider.init = function(self, rawhandle)
	local obj = {
		Handle = ETWProviderHandle_t(rawhandle)
	}
	setmetatable(ETWProvider, ETWProvider_mt)

	return obj;
end

ETWProvider.create = function(self, ProviderId, EnableCallback, CallbackContext)
	ProviderId = ProviderId or "GUID"	

	local RegHandle = ffi.new("REGHANDLE[1]")
	local rawhandle = eventing_provider.EventRegister(ProviderId, EnableCallback, CallbackContext, RegHandle)

	if rawhandle ~= 0 then
		return false, errorhandling.GetLastError();
	end

	return self:init(RegHandle[0])
end

ETWProvider.getNativeHandle = function(self)
	return self.Handle.Handle;
end

ETWProvider.eventWrite = function(self, ...)
	--eventing_provider.EventWrite();
end

ETWProvider.eventWriteString = function(self, message, Keyword, Level)
	
	if not message then
		return false;
	end

	-- message MUST be turned into a widechar
	Level = Level or 0
	Keyword = Keyword or 0

	local res = eventing_provider.EventWriteString(self:getNativeHandle(), Level, Keyword, message);
end

ETWProvider.eventWriteTransfer = function(self, ...)
end

ETWProvider.event