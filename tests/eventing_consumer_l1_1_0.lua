-- api-ms-win-eventing-consumer-l1-1-0.dll
-- eventing_consumer_l1_1_0 

local ffi = require("ffi")

local WTypes = require("WTypes")
local eventing_provider = require("eventing_provider_l1_1_0")


local Lib = ffi.load("Advapi32")

ffi.cdef[[
typedef ULONG64 TRACEHANDLE, *PTRACEHANDLE;
]]

ffi.cdef[[
ULONG CloseTrace(TRACEHANDLE TraceHandle);

TRACEHANDLE OpenTraceW(PEVENT_TRACE_LOGFILEW Logfile);

ULONG ProcessTrace(PTRACEHANDLE HandleArray,
    ULONG HandleCount,
    LPFILETIME StartTime,
    LPFILETIME EndTime
    );
]]

return {
	CloseTrace = Lib.CloseTrace,
	OpenTraceW = Lib.OpenTraceW,
	ProcessTrace = Lib.ProcessTrace,
}
