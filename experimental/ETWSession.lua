-- ETWSession.lua
local ffi = require("ffi")

local eventing_provider = require("eventing_provider_l1_1_0")

ffi.cdef[[
typedef struct {
	PTRACEHANDLE	Handle;
} ETWSession_t;
]]
local ETWSession_t = ffi.typeof("ETWSession_t")

local ETWSession = {}
setmetatable(ETWSession, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local ETWSession_mt = {
	__index = ETWSession;
}

ETWSession.init = function(self, rawhandle)
	local obj = {
		Handle = ETWSession_t(rawhandle)
	}
	setmetatable(obj, ETWSession_mt)

	return obj;
end

ETWSession.create = function(self, SessionName, Properties)
	if not SessionName then
		return nil, "no session name specified"
	end

	local SessionHandle = ffi.new("TRACEHANDLE[1]")
	local res = eventing_provider.StartTrace(SessionHandle, SessionName, Properties)
	
	return self:init(SessionHandle[0])
end

