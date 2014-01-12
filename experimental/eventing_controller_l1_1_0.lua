-- api-ms-win-eventing-controller-l1-1-0.dll 

local ffi = require("ffi")

local eventing_provider = require("eventing_provider_l1_1_0")
local eventing_consumer = require("eventing_consumer_l1_1_0")

local WinNT = require("WinNT")

local Lib = ffi.load("Advapi32")

ffi.cdef[[
//
// WNODE definition
typedef struct _WNODE_HEADER
{
    ULONG BufferSize;        // Size of entire buffer inclusive of this ULONG
    ULONG ProviderId;    // Provider Id of driver returning this buffer
    union
    {
        ULONG64 HistoricalContext;  // Logger use
        struct
            {
            ULONG Version;           // Reserved
            ULONG Linkage;           // Linkage field reserved for WMI
        } DUMMYSTRUCTNAME;
    } DUMMYUNIONNAME;

    union
    {
        ULONG CountLost;         // Reserved
        HANDLE KernelHandle;     // Kernel handle for data block
        LARGE_INTEGER TimeStamp; // Timestamp as returned in units of 100ns
                                 // since 1/1/1601
    } DUMMYUNIONNAME2;
    GUID Guid;                  // Guid for data block returned with results
    ULONG ClientContext;
    ULONG Flags;             // Flags, see below
} WNODE_HEADER, *PWNODE_HEADER;


//
// Logger configuration and running statistics. This structure is used
// by user-mode callers, such as PDH library
//

typedef struct _EVENT_TRACE_PROPERTIES {
    WNODE_HEADER Wnode;
//
// data provided by caller
    ULONG BufferSize;                   // buffer size for logging (kbytes)
    ULONG MinimumBuffers;               // minimum to preallocate
    ULONG MaximumBuffers;               // maximum buffers allowed
    ULONG MaximumFileSize;              // maximum logfile size (in MBytes)
    ULONG LogFileMode;                  // sequential, circular
    ULONG FlushTimer;                   // buffer flush timer, in seconds
    ULONG EnableFlags;                  // trace enable flags
    LONG  AgeLimit;                     // unused

// data returned to caller
    ULONG NumberOfBuffers;              // no of buffers in use
    ULONG FreeBuffers;                  // no of buffers free
    ULONG EventsLost;                   // event records lost
    ULONG BuffersWritten;               // no of buffers written to file
    ULONG LogBuffersLost;               // no of logfile write failures
    ULONG RealTimeBuffersLost;          // no of rt delivery failures
    HANDLE LoggerThreadId;              // thread id of Logger
    ULONG LogFileNameOffset;            // Offset to LogFileName
    ULONG LoggerNameOffset;             // Offset to LoggerName
} EVENT_TRACE_PROPERTIES, *PEVENT_TRACE_PROPERTIES;
]]

ffi.cdef[[
typedef enum _TRACE_QUERY_INFO_CLASS {
    TraceGuidQueryList,
    TraceGuidQueryInfo,
    TraceGuidQueryProcess,
    TraceStackTracingInfo,   // Win7
    MaxTraceSetInfoClass
} TRACE_QUERY_INFO_CLASS, TRACE_INFO_CLASS;
]]

ffi.cdef[[
static const int ENABLE_TRACE_PARAMETERS_VERSION = 1;

//typedef struct _EVENT_FILTER_DESCRIPTOR
//               EVENT_FILTER_DESCRIPTOR, *PEVENT_FILTER_DESCRIPTOR;

typedef struct _ENABLE_TRACE_PARAMETERS {
    ULONG                    Version;
    ULONG                    EnableProperty;
    ULONG                    ControlFlags;
    GUID                     SourceId;    
    PEVENT_FILTER_DESCRIPTOR EnableFilterDesc;
} ENABLE_TRACE_PARAMETERS, *PENABLE_TRACE_PARAMETERS;
]]

ffi.cdef[[
ULONG
ControlTraceW(
    TRACEHANDLE TraceHandle,
    LPCWSTR InstanceName,
    PEVENT_TRACE_PROPERTIES Properties,
    ULONG ControlCode
    );

ULONG
EnableTraceEx2(
    TRACEHANDLE TraceHandle,
    LPCGUID ProviderId,
    ULONG ControlCode,
    UCHAR Level,
    ULONGLONG MatchAnyKeyword,
    ULONGLONG MatchAllKeyword,
    ULONG Timeout,
    PENABLE_TRACE_PARAMETERS EnableParameters
    );

ULONG
EnumerateTraceGuidsEx(
    TRACE_QUERY_INFO_CLASS TraceQueryInfoClass,
    PVOID InBuffer,
    ULONG InBufferSize,
    PVOID OutBuffer,
    ULONG OutBufferSize,
    PULONG ReturnLength
    );

ULONG
EventAccessControl(
    LPGUID Guid,
    ULONG Operation,
    PSID Sid,
    ULONG Rights,
    BOOLEAN AllowOrDeny
    );

ULONG
EventAccessQuery(
    LPGUID Guid,
    PSECURITY_DESCRIPTOR Buffer,
    PULONG BufferSize
    );

ULONG EventAccessRemove(LPGUID Guid);

ULONG
QueryAllTracesW(
    PEVENT_TRACE_PROPERTIES *PropertyArray,
    ULONG PropertyArrayCount,
    PULONG LoggerCount
    );

ULONG
StartTraceW(
    PTRACEHANDLE TraceHandle,
    LPCWSTR InstanceName,
    PEVENT_TRACE_PROPERTIES Properties
    );

ULONG
StopTraceW(
    TRACEHANDLE TraceHandle,
    LPCWSTR InstanceName,
    PEVENT_TRACE_PROPERTIES Properties
    );

ULONG
TraceSetInformation(
    TRACEHANDLE SessionHandle,
    TRACE_INFO_CLASS InformationClass,
    PVOID TraceInformation,
    ULONG InformationLength
    );
]]

return {
	ControlTraceW = Lib.ControlTraceW,
	EnableTraceEx2 = Lib.EnableTraceEx2,
	EnumerateTraceGuidsEx = Lib.EnumerateTraceGuidsEx,
	EventAccessControl = Lib.EventAccessControl,
	EventAccessQuery = Lib.EventAccessQuery,
	EventAccessRemove = Lib.EventAccessRemove,
	QueryAllTracesW = Lib.QueryAllTracesW,
	StartTraceW = Lib.StartTraceW,
	StopTraceW = Lib.StopTraceW,
	--TraceQueryInformation = Lib.TraceQueryInformation,
	TraceSetInformation = Lib.TraceSetInformation,
 
}

