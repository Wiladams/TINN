-- RIO_ffi.lua

local ffi = require("ffi");
local WTypes = require("WTypes");

ffi.cdef[[
typedef struct RIO_BUFFERID_t *RIO_BUFFERID, **PRIO_BUFFERID;
typedef struct RIO_CQ_t *RIO_CQ, **PRIO_CQ;
typedef struct RIO_RQ_t *RIO_RQ, **PRIO_RQ;

typedef struct _RIORESULT {
    LONG Status;
    ULONG BytesTransferred;
    ULONGLONG SocketContext;
    ULONGLONG RequestContext;
} RIORESULT, *PRIORESULT;

typedef struct _RIO_BUF {
    RIO_BUFFERID BufferId;
    ULONG Offset;
    ULONG Length;
} RIO_BUF, *PRIO_BUF;

static const int RIO_MSG_DONT_NOTIFY        =   0x00000001;
static const int RIO_MSG_DEFER              =   0x00000002;
static const int RIO_MSG_WAITALL            =   0x00000004;
static const int RIO_MSG_COMMIT_ONLY        =   0x00000008;

static const int RIO_INVALID_BUFFERID       =   ((RIO_BUFFERID)0xFFFFFFFF);
static const int RIO_INVALID_CQ             =   ((RIO_CQ)0);
static const int RIO_INVALID_RQ             =   ((RIO_RQ)0);

static const int RIO_MAX_CQ_SIZE            =   0x8000000;
static const int RIO_CORRUPT_CQ             =   0xFFFFFFFF;

typedef struct _RIO_CMSG_BUFFER {
    ULONG TotalLength;
    /* followed by CMSG_HDR */
} RIO_CMSG_BUFFER, *PRIO_CMSG_BUFFER;
]]

--[[
#define RIO_CMSG_BASE_SIZE WSA_CMSGHDR_ALIGN(sizeof(RIO_CMSG_BUFFER))

#define RIO_CMSG_FIRSTHDR(buffer) \
    (((buffer)->TotalLength >= RIO_CMSG_BASE_SIZE)          \
        ? ((((buffer)->TotalLength - RIO_CMSG_BASE_SIZE) >= \
                sizeof(WSACMSGHDR))                         \
            ? (PWSACMSGHDR)((PUCHAR)(buffer) +              \
                RIO_CMSG_BASE_SIZE)                         \
            : (PWSACMSGHDR)NULL)                            \
        : (PWSACMSGHDR)NULL)

#define RIO_CMSG_NEXTHDR(buffer, cmsg)                      \
    ((cmsg) == NULL                                         \
        ? RIO_CMSG_FIRSTHDR(buffer)                         \
        : (((PUCHAR)(cmsg) +                                \
                    WSA_CMSGHDR_ALIGN((cmsg)->cmsg_len) +   \
                    sizeof(WSACMSGHDR)  >                   \
                (PUCHAR)(buffer) +                          \
                    (buffer)->TotalLength)                  \
            ? (PWSACMSGHDR)NULL                             \
            : (PWSACMSGHDR)((PUCHAR)(cmsg) +                \
                WSA_CMSGHDR_ALIGN((cmsg)->cmsg_len))))
--]]

ffi.cdef[[
typedef BOOL (PASCAL * LPFN_RIORECEIVE)(
     RIO_RQ SocketQueue,
    PRIO_BUF pData,
     ULONG DataBufferCount,
     DWORD Flags,
     PVOID RequestContext
    );

typedef int (PASCAL * LPFN_RIORECEIVEEX)(
     RIO_RQ SocketQueue,
    PRIO_BUF pData,
     ULONG DataBufferCount,
    PRIO_BUF pLocalAddress,
    PRIO_BUF pRemoteAddress,
    PRIO_BUF pControlContext,
    PRIO_BUF pFlags,
     DWORD Flags,
     PVOID RequestContext
); 

typedef BOOL (PASCAL * LPFN_RIOSEND)(
     RIO_RQ SocketQueue,
    PRIO_BUF pData,
     ULONG DataBufferCount,
     DWORD Flags,
     PVOID RequestContext
);

typedef BOOL (PASCAL * LPFN_RIOSENDEX)(
     RIO_RQ SocketQueue,
    PRIO_BUF pData,
     ULONG DataBufferCount,
    PRIO_BUF pLocalAddress,
    PRIO_BUF pRemoteAddress,
    PRIO_BUF pControlContext,
    PRIO_BUF pFlags,
     DWORD Flags,
     PVOID RequestContext
);

typedef VOID (PASCAL * LPFN_RIOCLOSECOMPLETIONQUEUE)(RIO_CQ CQ);

typedef enum _RIO_NOTIFICATION_COMPLETION_TYPE {
    RIO_EVENT_COMPLETION      = 1,
    RIO_IOCP_COMPLETION       = 2,
} RIO_NOTIFICATION_COMPLETION_TYPE, *PRIO_NOTIFICATION_COMPLETION_TYPE;

#pragma warning(push)
#pragma warning(disable : 4201) /* Nonstandard extension: nameless struct/union */

typedef struct _RIO_NOTIFICATION_COMPLETION {
    RIO_NOTIFICATION_COMPLETION_TYPE Type;
    union {
        struct {
            HANDLE EventHandle;
            BOOL NotifyReset;
        } Event;
        struct {
            HANDLE IocpHandle;
            PVOID CompletionKey;
            PVOID Overlapped;
        } Iocp;
    };
} RIO_NOTIFICATION_COMPLETION, *PRIO_NOTIFICATION_COMPLETION;

#pragma warning(pop)

typedef RIO_CQ (PASCAL * LPFN_RIOCREATECOMPLETIONQUEUE)(
     DWORD QueueSize,
    PRIO_NOTIFICATION_COMPLETION NotificationCompletion
);

typedef RIO_RQ (PASCAL * LPFN_RIOCREATEREQUESTQUEUE)(
     SOCKET Socket,
     ULONG MaxOutstandingReceive,
     ULONG MaxReceiveDataBuffers,
     ULONG MaxOutstandingSend,
     ULONG MaxSendDataBuffers,
     RIO_CQ ReceiveCQ,
     RIO_CQ SendCQ,
     PVOID SocketContext
);

typedef ULONG (PASCAL * LPFN_RIODEQUEUECOMPLETION)(
     RIO_CQ CQ,
    PRIORESULT Array,
     ULONG ArraySize
);

typedef VOID (PASCAL * LPFN_RIODEREGISTERBUFFER)(
     RIO_BUFFERID BufferId
);

typedef INT (PASCAL * LPFN_RIONOTIFY)(
     RIO_CQ CQ
);

typedef RIO_BUFFERID (PASCAL * LPFN_RIOREGISTERBUFFER)(
     PCHAR DataBuffer,
     DWORD DataLength
);

typedef BOOL (PASCAL * LPFN_RIORESIZECOMPLETIONQUEUE) (
     RIO_CQ CQ,
     DWORD QueueSize
);

typedef BOOL (PASCAL * LPFN_RIORESIZEREQUESTQUEUE) (
     RIO_RQ RQ,
     DWORD MaxOutstandingReceive,
     DWORD MaxOutstandingSend
);

typedef struct _RIO_EXTENSION_FUNCTION_TABLE {
    DWORD cbSize;

    LPFN_RIORECEIVE RIOReceive;
    LPFN_RIORECEIVEEX RIOReceiveEx;
    LPFN_RIOSEND RIOSend;
    LPFN_RIOSENDEX RIOSendEx;
    LPFN_RIOCLOSECOMPLETIONQUEUE RIOCloseCompletionQueue;
    LPFN_RIOCREATECOMPLETIONQUEUE RIOCreateCompletionQueue;
    LPFN_RIOCREATEREQUESTQUEUE RIOCreateRequestQueue;
    LPFN_RIODEQUEUECOMPLETION RIODequeueCompletion;
    LPFN_RIODEREGISTERBUFFER RIODeregisterBuffer;
    LPFN_RIONOTIFY RIONotify;
    LPFN_RIOREGISTERBUFFER RIORegisterBuffer;
    LPFN_RIORESIZECOMPLETIONQUEUE RIOResizeCompletionQueue;
    LPFN_RIORESIZEREQUESTQUEUE RIOResizeRequestQueue;
} RIO_EXTENSION_FUNCTION_TABLE, *PRIO_EXTENSION_FUNCTION_TABLE;
]]

#define WSAID_MULTIPLE_RIO /* 8509e081-96dd-4005-b165-9e2ee8c79e3f */ \
    {0x8509e081,0x96dd,0x4005,{0xb1,0x65,0x9e,0x2e,0xe8,0xc7,0x9e,0x3f}}


local Lib = ffi.load("mswsock");

return {
RIOCloseCompletionQueue
RIOCreateCompletionQueue
RIOCreateRequestQueue
RIODequeueCompletion
RIODeregisterBuffer
RIONotify
RIOReceive
RIOReceiveEx
RIORegisterBuffer
RIOResizeCompletionQueue
RIOResizeRequestQueue
RIOSend
RIOSendEx
}
