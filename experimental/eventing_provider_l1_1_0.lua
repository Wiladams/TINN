-- api-ms-win-eventing-provider-l1-1-0.dll 
-- eventing_provider_l1_1_0

local ffi = require("ffi")

local WTypes = require("WTypes")
require("guiddef")

local Lib = ffi.load("Advapi32")

ffi.cdef[[
static const int EVENT_MIN_LEVEL                      = (0);
static const int EVENT_MAX_LEVEL                      = (0xff);

static const int EVENT_ACTIVITY_CTRL_GET_ID           = (1);
static const int EVENT_ACTIVITY_CTRL_SET_ID           = (2);
static const int EVENT_ACTIVITY_CTRL_CREATE_ID        = (3);
static const int EVENT_ACTIVITY_CTRL_GET_SET_ID       = (4);
static const int EVENT_ACTIVITY_CTRL_CREATE_SET_ID    = (5);

typedef ULONGLONG REGHANDLE, *PREGHANDLE;

static const int MAX_EVENT_DATA_DESCRIPTORS           = (128);
static const int MAX_EVENT_FILTER_DATA_SIZE           = (1024);

static const uint32_t EVENT_FILTER_TYPE_SCHEMATIZED        = (0x80000000);
]]

ffi.cdef[[
typedef struct _EVENT_TRACE_HEADER {        // overlays WNODE_HEADER
    USHORT          Size;                   // Size of entire record
    union {
        USHORT      FieldTypeFlags;         // Indicates valid fields
        struct {
            UCHAR   HeaderType;             // Header type - internal use only
            UCHAR   MarkerFlags;            // Marker - internal use only
        } DUMMYSTRUCTNAME;
    } DUMMYUNIONNAME;
    union {
        ULONG       Version;
        struct {
            UCHAR   Type;                   // event type
            UCHAR   Level;                  // trace instrumentation level
            USHORT  Version;                // version of trace record
        } Class;
    } DUMMYUNIONNAME2;
    ULONG           ThreadId;               // Thread Id
    ULONG           ProcessId;              // Process Id
    LARGE_INTEGER   TimeStamp;              // time when event happens
    union {
        GUID        Guid;                   // Guid that identifies event
        ULONGLONG   GuidPtr;                // use with WNODE_FLAG_USE_GUID_PTR
    } DUMMYUNIONNAME3;
    union {
        struct {
            ULONG   KernelTime;             // Kernel Mode CPU ticks
            ULONG   UserTime;               // User mode CPU ticks
        } DUMMYSTRUCTNAME;
        ULONG64     ProcessorTime;          // Processor Clock
        struct {
            ULONG   ClientContext;          // Reserved
            ULONG   Flags;                  // Event Flags
        } DUMMYSTRUCTNAME2;
    } DUMMYUNIONNAME4;
} EVENT_TRACE_HEADER, *PEVENT_TRACE_HEADER;
]]

ffi.cdef[[
typedef struct _ETW_BUFFER_CONTEXT {
    UCHAR   ProcessorNumber;
    UCHAR   Alignment;
    USHORT  LoggerId;
} ETW_BUFFER_CONTEXT, *PETW_BUFFER_CONTEXT;


typedef struct _EVENT_TRACE {
    EVENT_TRACE_HEADER      Header;             // Event trace header
    ULONG                   InstanceId;         // Instance Id of this event
    ULONG                   ParentInstanceId;   // Parent Instance Id.
    GUID                    ParentGuid;         // Parent Guid;
    PVOID                   MofData;            // Pointer to Variable Data
    ULONG                   MofLength;          // Variable Datablock Length
    union {
        ULONG               ClientContext;
        ETW_BUFFER_CONTEXT  BufferContext;
    } DUMMYUNIONNAME;
} EVENT_TRACE, *PEVENT_TRACE;
]]

ffi.cdef[[
static const int EVENT_CONTROL_CODE_DISABLE_PROVIDER = 0;
static const int EVENT_CONTROL_CODE_ENABLE_PROVIDER  = 1;
static const int EVENT_CONTROL_CODE_CAPTURE_STATE    = 2;

typedef struct _EVENT_RECORD
                EVENT_RECORD, *PEVENT_RECORD;

typedef struct _EVENT_TRACE_LOGFILEW
                EVENT_TRACE_LOGFILEW, *PEVENT_TRACE_LOGFILEW;

typedef struct _EVENT_TRACE_LOGFILEA
                EVENT_TRACE_LOGFILEA, *PEVENT_TRACE_LOGFILEA;

typedef ULONG (__stdcall * PEVENT_TRACE_BUFFER_CALLBACKW) (PEVENT_TRACE_LOGFILEW Logfile);

typedef ULONG (__stdcall * PEVENT_TRACE_BUFFER_CALLBACKA) (PEVENT_TRACE_LOGFILEA Logfile);

typedef void (__stdcall *PEVENT_CALLBACK)( PEVENT_TRACE pEvent );

typedef VOID (__stdcall *PEVENT_RECORD_CALLBACK) (PEVENT_RECORD EventRecord);

]]

ffi.cdef[[
//
// EVENT_DATA_DESCRIPTOR is used to pass in user data items
// in events.
// 
typedef struct _EVENT_DATA_DESCRIPTOR {

    ULONGLONG   Ptr;        // Pointer to data
    ULONG       Size;       // Size of data in bytes
    ULONG       Reserved;

} EVENT_DATA_DESCRIPTOR, *PEVENT_DATA_DESCRIPTOR;

//
// EVENT_DESCRIPTOR describes and categorizes an event.
// 
typedef struct _EVENT_DESCRIPTOR {

    USHORT      Id;
    UCHAR       Version;
    UCHAR       Channel;
    UCHAR       Level;
    UCHAR       Opcode;
    USHORT      Task;
    ULONGLONG   Keyword;

} EVENT_DESCRIPTOR, *PEVENT_DESCRIPTOR;

typedef const EVENT_DESCRIPTOR *PCEVENT_DESCRIPTOR;

//
// EVENT_FILTER_DESCRIPTOR is used to pass in enable filter
// data item to a user callback function.
// 
typedef struct _EVENT_FILTER_DESCRIPTOR {

    ULONGLONG   Ptr;
    ULONG       Size;
    ULONG       Type;

} EVENT_FILTER_DESCRIPTOR, *PEVENT_FILTER_DESCRIPTOR;


typedef struct _EVENT_FILTER_HEADER {

    USHORT     Id;
    UCHAR      Version;
    UCHAR      Reserved[5];
    ULONGLONG  InstanceId;
    ULONG      Size;
    ULONG      NextOffset;

} EVENT_FILTER_HEADER, *PEVENT_FILTER_HEADER;
]]

ffi.cdef[[
//
// Optional callback function that users provide
//
typedef void (__stdcall *PENABLECALLBACK) (
    LPCGUID SourceId,
    ULONG IsEnabled,
    UCHAR Level,
    ULONGLONG MatchAnyKeyword,
    ULONGLONG MatchAllKeyword,
    PEVENT_FILTER_DESCRIPTOR FilterData,
    PVOID CallbackContext);  
]]


ffi.cdef[[
ULONG
EventActivityIdControl(
    ULONG ControlCode,
    LPGUID ActivityId
    );

BOOLEAN
EventEnabled(
    REGHANDLE RegHandle,
    PCEVENT_DESCRIPTOR EventDescriptor
    );

BOOLEAN
EventProviderEnabled(
    REGHANDLE RegHandle,
    UCHAR Level,
    ULONGLONG Keyword
    );

ULONG
EventRegister(
    LPCGUID ProviderId,
    PENABLECALLBACK EnableCallback,
    PVOID CallbackContext,
    PREGHANDLE RegHandle
    );

ULONG
EventUnregister(
    REGHANDLE RegHandle
    );

ULONG
EventWrite(
    REGHANDLE RegHandle,
    PCEVENT_DESCRIPTOR EventDescriptor,
    ULONG UserDataCount,
    PEVENT_DATA_DESCRIPTOR UserData
    );

ULONG
EventWriteEx(
    REGHANDLE RegHandle,
    PCEVENT_DESCRIPTOR EventDescriptor,
    ULONG64 Filter,
    ULONG Flags,
    LPCGUID ActivityId,
    LPCGUID RelatedActivityId,
    ULONG UserDataCount,
    PEVENT_DATA_DESCRIPTOR UserData
    );

ULONG
EventWriteString(
    REGHANDLE RegHandle,
    UCHAR Level,
    ULONGLONG Keyword,
    PCWSTR String
    );

ULONG
EventWriteTransfer(
    REGHANDLE RegHandle,
    PCEVENT_DESCRIPTOR EventDescriptor,
    LPCGUID ActivityId,
    LPCGUID RelatedActivityId,
    ULONG UserDataCount,
    PEVENT_DATA_DESCRIPTOR UserData
    );

]]

return { 
	EventActivityIdControl = Lib.EventActivityIdControl,
	EventEnabled = Lib.EventEnabled,
	EventProviderEnabled = Lib.EventProviderEnabled,
	EventRegister = Lib.EventRegister,
	--EventSetInformation = Lib.EventSetInformation,
	EventUnregister = Lib.EventUnregister,
	EventWrite = Lib.EventWrite,
	EventWriteEx = Lib.EventWriteEx,
	EventWriteString = Lib.EventWriteString,
	EventWriteTransfer = Lib.EventWriteTransfer,
}
