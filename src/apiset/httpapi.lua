-- httpapi.dll	
-- httpapi.dll	

local ffi = require("ffi");
local WTypes = require("WTypes");
local Lib = ffi.load("httpapi");

ffi.cdef[[
//
// Flags for HttpFlushResponseCache().
//
// HTTP_FLUSH_RESPONSE_FLAG_RECURSIVE - Flushes the specified URL and all
// hierarchally-related sub-URLs from the response or fragment cache.
//

static const int HTTP_FLUSH_RESPONSE_FLAG_RECURSIVE         = 0x00000001;

static const int HTTP_INITIALIZE_SERVER         = 0x00000001;
static const int HTTP_INITIALIZE_CONFIG         = 0x00000002;


//
// Flag to retrieve secure channel binding with HttpReceiveClientCertificate
//

static const int HTTP_RECEIVE_SECURE_CHANNEL_TOKEN = 0x1;


//
// Opaque identifiers for various HTTPAPI objects.
//

typedef ULONGLONG      HTTP_OPAQUE_ID,         *PHTTP_OPAQUE_ID;

typedef HTTP_OPAQUE_ID HTTP_REQUEST_ID,        *PHTTP_REQUEST_ID;
typedef HTTP_OPAQUE_ID HTTP_CONNECTION_ID,     *PHTTP_CONNECTION_ID;
typedef HTTP_OPAQUE_ID HTTP_RAW_CONNECTION_ID, *PHTTP_RAW_CONNECTION_ID;


typedef HTTP_OPAQUE_ID HTTP_URL_GROUP_ID,      *PHTTP_URL_GROUP_ID;
typedef HTTP_OPAQUE_ID HTTP_SERVER_SESSION_ID, *PHTTP_SERVER_SESSION_ID;

//
// An opaque context for URL manipulation.
//

typedef ULONGLONG HTTP_URL_CONTEXT;

static const int HTTP_URL_FLAG_REMOVE_ALL              =  0x00000001;

]]

ffi.cdef[[
//
// The type for HTTP protocol version numbers.
//

typedef struct _HTTP_VERSION
{
    USHORT MajorVersion;
    USHORT MinorVersion;

} HTTP_VERSION, *PHTTP_VERSION;

]]

ffi.cdef[[
typedef struct _HTTPAPI_VERSION
{
    USHORT HttpApiMajorVersion;
    USHORT HttpApiMinorVersion;

} HTTPAPI_VERSION, *PHTTPAPI_VERSION;
]]

--
-- Macros for opaque identifier manipulations.
--
--[[
local HTTP_NULL_ID  =          (0ui64)
local HTTP_IS_NULL_ID = function(pid)
	return (HTTP_NULL_ID == *(pid))
end

local HTTP_SET_NULL_ID = function(pid)
	return   (*(pid) = HTTP_NULL_ID);
end
--]]

ffi.cdef[[
//
// This structure defines a file byte range.
//
// If the Length field is HTTP_BYTE_RANGE_TO_EOF then the remainder of the
// file (everything after StartingOffset) is sent.
//

static const int HTTP_BYTE_RANGE_TO_EOF = ((ULONGLONG)-1);

typedef struct _HTTP_BYTE_RANGE
{
    ULARGE_INTEGER StartingOffset;
    ULARGE_INTEGER Length;

} HTTP_BYTE_RANGE, *PHTTP_BYTE_RANGE;
]]

ffi.cdef[[
//
// This enum defines a data source for a particular chunk of data.
//

typedef enum _HTTP_DATA_CHUNK_TYPE
{
    HttpDataChunkFromMemory,
    HttpDataChunkFromFileHandle,
    HttpDataChunkFromFragmentCache,
    HttpDataChunkFromFragmentCacheEx,

    HttpDataChunkMaximum

} HTTP_DATA_CHUNK_TYPE, *PHTTP_DATA_CHUNK_TYPE;


//
// This structure describes an individual data chunk.
//

typedef struct _HTTP_DATA_CHUNK
{
    //
    // The type of this data chunk.
    //

    HTTP_DATA_CHUNK_TYPE DataChunkType;

    //
    // The data chunk structures, one per supported data chunk type.
    //

    union
    {
        //
        // From-memory data chunk.
        //

        struct
        {
            PVOID pBuffer;
            ULONG BufferLength;

        } FromMemory;

        //
        // From-file handle data chunk.
        //

        struct
        {
            HTTP_BYTE_RANGE ByteRange;
            HANDLE          FileHandle;

        } FromFileHandle;

        //
        // From-fragment cache data chunk.
        //

        struct
        {
            USHORT FragmentNameLength;      // in bytes not including the NUL
            PCWSTR pFragmentName;

        } FromFragmentCache;

        //
        // From-fragment cache data chunk that specifies a byte range.
        //

        struct
        {
            HTTP_BYTE_RANGE ByteRange;
            PCWSTR pFragmentName;           // NULL-terminated string

        } FromFragmentCacheEx;

    };

} HTTP_DATA_CHUNK, *PHTTP_DATA_CHUNK;
]]



ffi.cdef[[
typedef enum _HTTP_RESPONSE_INFO_TYPE
{
    HttpResponseInfoTypeMultipleKnownHeaders,
    HttpResponseInfoTypeAuthenticationProperty,
    HttpResponseInfoTypeQoSProperty
    
    ,HttpResponseInfoTypeChannelBind

} HTTP_RESPONSE_INFO_TYPE, PHTTP_RESPONSE_INFO_TYPE;

typedef struct _HTTP_RESPONSE_INFO
{
    HTTP_RESPONSE_INFO_TYPE Type;
    ULONG                   Length;
    PVOID                   pInfo;
} HTTP_RESPONSE_INFO, *PHTTP_RESPONSE_INFO;
]]




ffi.cdef[[
typedef struct _HTTP_TRANSPORT_ADDRESS
{
    PSOCKADDR      pRemoteAddress;
    PSOCKADDR      pLocalAddress;

} HTTP_TRANSPORT_ADDRESS, *PHTTP_TRANSPORT_ADDRESS;
]]

ffi.cdef[[
//
// Structure defining format of cooked URL.
//

typedef struct _HTTP_COOKED_URL
{
    //
    // Pointers overlap and point into pFullUrl. NULL if not present.
    //

    USHORT FullUrlLength;       // in bytes not including the NUL
    USHORT HostLength;          // in bytes (no NUL)
    USHORT AbsPathLength;       // in bytes (no NUL)
    USHORT QueryStringLength;   // in bytes (no NUL)

    PCWSTR pFullUrl;     // points to "http://hostname:port/abs/.../path?query"
    PCWSTR pHost;        // points to the first char in the hostname
    PCWSTR pAbsPath;     // Points to the 3rd '/' char
    PCWSTR pQueryString; // Points to the 1st '?' char or NULL

} HTTP_COOKED_URL, *PHTTP_COOKED_URL;
]]






ffi.cdef[[
//
// Cache control.
//

//
// This enum defines the available cache policies.
//

typedef enum _HTTP_CACHE_POLICY_TYPE
{
    HttpCachePolicyNocache,
    HttpCachePolicyUserInvalidates,
    HttpCachePolicyTimeToLive,

    HttpCachePolicyMaximum

} HTTP_CACHE_POLICY_TYPE, *PHTTP_CACHE_POLICY_TYPE;


//
//  Only cache unauthorized GETs + HEADs.
//

typedef struct _HTTP_CACHE_POLICY
{
    HTTP_CACHE_POLICY_TYPE  Policy;
    ULONG                   SecondsToLive;

} HTTP_CACHE_POLICY, *PHTTP_CACHE_POLICY;
]]


ffi.cdef[[
//
// Enum that is used with HttpSetServiceConfiguration(),
// HttpQueryServiceConfiguration(), and HttpDeleteServiceConfiguration() APIs.
//

typedef enum _HTTP_SERVICE_CONFIG_ID
{
    HttpServiceConfigIPListenList,    // Set, Query & Delete.
    HttpServiceConfigSSLCertInfo,     // Set, Query & Delete.
    HttpServiceConfigUrlAclInfo,      // Set, Query & Delete.
    HttpServiceConfigTimeout,         // Set, Query & Delete.
    HttpServiceConfigCache,           // Set, Query & Delete.
    HttpServiceConfigMax

} HTTP_SERVICE_CONFIG_ID, *PHTTP_SERVICE_CONFIG_ID;
]]


ffi.cdef[[
//
// Following section defines the properties supported by the
// server side HTTP API.
//

typedef enum _HTTP_SERVER_PROPERTY
{
    //
    // Used for enabling server side authentication.
    //

    HttpServerAuthenticationProperty,

    //
    // Used for enabling logging.
    //

    HttpServerLoggingProperty,

    //
    // Used for setting QoS properties.
    //

    HttpServerQosProperty,

    //
    // Used for configuring timeouts.
    //

    HttpServerTimeoutsProperty,

    //
    // Used for limiting request queue lengths.
    //

    HttpServerQueueLengthProperty,

    //
    // Used for manipulating the state.
    //

    HttpServerStateProperty,

    //
    // Used for modifying the verbosity level of 503 type responses
    // generated by server side API.
    //

    HttpServer503VerbosityProperty,

    //
    // Used for manipulating Url Group to Request Queue association.
    //

    HttpServerBindingProperty,

    //
    // Extended authentication property.
    //

    HttpServerExtendedAuthenticationProperty,

    //
    // Listening endpoint property.
    //

    HttpServerListenEndpointProperty

    //
    // Authentication channel binding property
    //


    ,HttpServerChannelBindProperty

    //
    // IP Protection level policy for a Url Group.
    //

    ,HttpServerProtectionLevelProperty


} HTTP_SERVER_PROPERTY, *PHTTP_SERVER_PROPERTY;
]]


ffi.cdef[[
//
// SSL Client certificate information.
//

typedef struct _HTTP_SSL_CLIENT_CERT_INFO
{
    ULONG   CertFlags;
    ULONG   CertEncodedSize;
    PUCHAR  pCertEncoded;
    HANDLE  Token;
    BOOLEAN CertDeniedByMapper;

} HTTP_SSL_CLIENT_CERT_INFO, *PHTTP_SSL_CLIENT_CERT_INFO;


]]


ffi.cdef[[
//
// Generic request information type.
//

typedef enum _HTTP_REQUEST_INFO_TYPE
{
    HttpRequestInfoTypeAuth

    ,HttpRequestInfoTypeChannelBind

} HTTP_REQUEST_INFO_TYPE, *PHTTP_REQUEST_INFO_TYPE;

typedef struct _HTTP_REQUEST_INFO
{
    HTTP_REQUEST_INFO_TYPE InfoType;
    ULONG                  InfoLength;
    PVOID                  pInfo;

} HTTP_REQUEST_INFO, *PHTTP_REQUEST_INFO;

]]


ffi.cdef[[
//
// The enum type for HTTP verbs.
//

typedef enum _HTTP_VERB
{
    HttpVerbUnparsed,
    HttpVerbUnknown,
    HttpVerbInvalid,
    HttpVerbOPTIONS,
    HttpVerbGET,
    HttpVerbHEAD,
    HttpVerbPOST,
    HttpVerbPUT,
    HttpVerbDELETE,
    HttpVerbTRACE,
    HttpVerbCONNECT,
    HttpVerbTRACK,  // used by Microsoft Cluster Server for a non-logged trace
    HttpVerbMOVE,
    HttpVerbCOPY,
    HttpVerbPROPFIND,
    HttpVerbPROPPATCH,
    HttpVerbMKCOL,
    HttpVerbLOCK,
    HttpVerbUNLOCK,
    HttpVerbSEARCH,

    HttpVerbMaximum

} HTTP_VERB, *PHTTP_VERB;
]]

ffi.cdef[[
//
// Symbols for all HTTP/1.1 headers and other tokens. Notice request +
// response values overlap. Make sure you know which type of header array
// you are indexing.
//
// These values are used as offsets into arrays and as token values in
// HTTP_KNOWN_HEADER arrays in HTTP_REQUEST_HEADERS and HTTP_RESPONSE_HEADERS.
//
// See RFC 2616, HTTP/1.1, for further explanation of most of these headers.
//

typedef enum _HTTP_HEADER_ID
{
    HttpHeaderCacheControl          = 0,    // general-header [section 4.5]
    HttpHeaderConnection            = 1,    // general-header [section 4.5]
    HttpHeaderDate                  = 2,    // general-header [section 4.5]
    HttpHeaderKeepAlive             = 3,    // general-header [not in rfc]
    HttpHeaderPragma                = 4,    // general-header [section 4.5]
    HttpHeaderTrailer               = 5,    // general-header [section 4.5]
    HttpHeaderTransferEncoding      = 6,    // general-header [section 4.5]
    HttpHeaderUpgrade               = 7,    // general-header [section 4.5]
    HttpHeaderVia                   = 8,    // general-header [section 4.5]
    HttpHeaderWarning               = 9,    // general-header [section 4.5]

    HttpHeaderAllow                 = 10,   // entity-header  [section 7.1]
    HttpHeaderContentLength         = 11,   // entity-header  [section 7.1]
    HttpHeaderContentType           = 12,   // entity-header  [section 7.1]
    HttpHeaderContentEncoding       = 13,   // entity-header  [section 7.1]
    HttpHeaderContentLanguage       = 14,   // entity-header  [section 7.1]
    HttpHeaderContentLocation       = 15,   // entity-header  [section 7.1]
    HttpHeaderContentMd5            = 16,   // entity-header  [section 7.1]
    HttpHeaderContentRange          = 17,   // entity-header  [section 7.1]
    HttpHeaderExpires               = 18,   // entity-header  [section 7.1]
    HttpHeaderLastModified          = 19,   // entity-header  [section 7.1]


    // Request Headers

    HttpHeaderAccept                = 20,   // request-header [section 5.3]
    HttpHeaderAcceptCharset         = 21,   // request-header [section 5.3]
    HttpHeaderAcceptEncoding        = 22,   // request-header [section 5.3]
    HttpHeaderAcceptLanguage        = 23,   // request-header [section 5.3]
    HttpHeaderAuthorization         = 24,   // request-header [section 5.3]
    HttpHeaderCookie                = 25,   // request-header [not in rfc]
    HttpHeaderExpect                = 26,   // request-header [section 5.3]
    HttpHeaderFrom                  = 27,   // request-header [section 5.3]
    HttpHeaderHost                  = 28,   // request-header [section 5.3]
    HttpHeaderIfMatch               = 29,   // request-header [section 5.3]

    HttpHeaderIfModifiedSince       = 30,   // request-header [section 5.3]
    HttpHeaderIfNoneMatch           = 31,   // request-header [section 5.3]
    HttpHeaderIfRange               = 32,   // request-header [section 5.3]
    HttpHeaderIfUnmodifiedSince     = 33,   // request-header [section 5.3]
    HttpHeaderMaxForwards           = 34,   // request-header [section 5.3]
    HttpHeaderProxyAuthorization    = 35,   // request-header [section 5.3]
    HttpHeaderReferer               = 36,   // request-header [section 5.3]
    HttpHeaderRange                 = 37,   // request-header [section 5.3]
    HttpHeaderTe                    = 38,   // request-header [section 5.3]
    HttpHeaderTranslate             = 39,   // request-header [webDAV, not in rfc 2518]

    HttpHeaderUserAgent             = 40,   // request-header [section 5.3]

    HttpHeaderRequestMaximum        = 41,


    // Response Headers

    HttpHeaderAcceptRanges          = 20,   // response-header [section 6.2]
    HttpHeaderAge                   = 21,   // response-header [section 6.2]
    HttpHeaderEtag                  = 22,   // response-header [section 6.2]
    HttpHeaderLocation              = 23,   // response-header [section 6.2]
    HttpHeaderProxyAuthenticate     = 24,   // response-header [section 6.2]
    HttpHeaderRetryAfter            = 25,   // response-header [section 6.2]
    HttpHeaderServer                = 26,   // response-header [section 6.2]
    HttpHeaderSetCookie             = 27,   // response-header [not in rfc]
    HttpHeaderVary                  = 28,   // response-header [section 6.2]
    HttpHeaderWwwAuthenticate       = 29,   // response-header [section 6.2]

    HttpHeaderResponseMaximum       = 30,


    HttpHeaderMaximum               = 41

} HTTP_HEADER_ID, *PHTTP_HEADER_ID;


//
// Structure defining format of a known HTTP header.
// Name is from HTTP_HEADER_ID.
//

typedef struct _HTTP_KNOWN_HEADER
{
    USHORT RawValueLength;     // in bytes not including the NUL
    PCSTR  pRawValue;

} HTTP_KNOWN_HEADER, *PHTTP_KNOWN_HEADER;

//
// Structure defining format of an unknown header.
//

typedef struct _HTTP_UNKNOWN_HEADER
{
    USHORT NameLength;          // in bytes not including the NUL
    USHORT RawValueLength;      // in bytes not including the NUL
    PCSTR  pName;               // The header name (minus the ':' character)
    PCSTR  pRawValue;           // The header value

} HTTP_UNKNOWN_HEADER, *PHTTP_UNKNOWN_HEADER;
]]

ffi.cdef[[
//
// Log fields data structure is used for logging a request. This structure must
// be provided along with an HttpSendHttpResponse or HttpSendResponseEntityBody
// call that concludes the send.
//

// Base structure is for future versioning.

typedef enum _HTTP_LOG_DATA_TYPE
{
    HttpLogDataTypeFields = 0

} HTTP_LOG_DATA_TYPE, *PHTTP_LOG_DATA_TYPE;

// should we DECLSPEC_ALIGN(4 or 8) == DECLSPEC_POINTERALIGN?
typedef struct _HTTP_LOG_DATA
{
    HTTP_LOG_DATA_TYPE Type;

} HTTP_LOG_DATA, *PHTTP_LOG_DATA;

// Current log fields data structure for of type HttpLogDataTypeFields.

typedef struct _HTTP_LOG_FIELDS_DATA
{
    HTTP_LOG_DATA Base;

    USHORT UserNameLength;
    USHORT UriStemLength;
    USHORT ClientIpLength;
    USHORT ServerNameLength;
    USHORT ServiceNameLength;
    USHORT ServerIpLength;
    USHORT MethodLength;
    USHORT UriQueryLength;
    USHORT HostLength;
    USHORT UserAgentLength;
    USHORT CookieLength;
    USHORT ReferrerLength;

    PWCHAR UserName;
    PWCHAR UriStem;
    PCHAR  ClientIp;
    PCHAR  ServerName;
    PCHAR  ServiceName;
    PCHAR  ServerIp;
    PCHAR  Method;
    PCHAR  UriQuery;
    PCHAR  Host;
    PCHAR  UserAgent;
    PCHAR  Cookie;
    PCHAR  Referrer;

    USHORT ServerPort;
    USHORT ProtocolStatus;

    ULONG  Win32Status;

    HTTP_VERB MethodNum;

    USHORT SubStatus;

} HTTP_LOG_FIELDS_DATA, *PHTTP_LOG_FIELDS_DATA;
]]


ffi.cdef[[
typedef struct _HTTP_REQUEST_HEADERS
{
    //
    // The array of unknown HTTP headers and the number of
    // entries in the array.
    //

    USHORT               UnknownHeaderCount;
    PHTTP_UNKNOWN_HEADER pUnknownHeaders;

    //
    // Trailers - we don't use these currently, reserved for a future release
    //
    USHORT               TrailerCount;   // Reserved, must be 0
    PHTTP_UNKNOWN_HEADER pTrailers;      // Reserved, must be NULL


    //
    // Known headers.
    //

    HTTP_KNOWN_HEADER    KnownHeaders[HttpHeaderRequestMaximum];

} HTTP_REQUEST_HEADERS, *PHTTP_REQUEST_HEADERS;
]]

ffi.cdef[[
//
// Structure defining format of response headers.
//

typedef struct _HTTP_RESPONSE_HEADERS
{
    //
    // The array of unknown HTTP headers and the number of
    // entries in the array.
    //

    USHORT               UnknownHeaderCount;
    PHTTP_UNKNOWN_HEADER pUnknownHeaders;

    //
    // Trailers - we don't use these currently, reserved for a future release
    //
    USHORT               TrailerCount;   // Reserved, must be 0
    PHTTP_UNKNOWN_HEADER pTrailers;      // Reserved, must be NULL

    //
    // Known headers.
    //

    HTTP_KNOWN_HEADER    KnownHeaders[HttpHeaderResponseMaximum];

} HTTP_RESPONSE_HEADERS, *PHTTP_RESPONSE_HEADERS;
]]

ffi.cdef[[
//
// This structure describes an HTTP response.
//

typedef struct _HTTP_RESPONSE_V1
{
    //
    // Response flags (see HTTP_RESPONSE_FLAG_* definitions below).
    //

    ULONG Flags;

    //
    // The raw HTTP protocol version number.
    //

    HTTP_VERSION Version;

    //
    // The HTTP status code (e.g., 200).
    //

    USHORT StatusCode;

    //
    // The HTTP reason (e.g., "OK"). This MUST not contain
    // non-ASCII characters (i.e., all chars must be in range 0x20-0x7E).
    //

    USHORT ReasonLength;                 // in bytes not including the '\0'
    PCSTR  pReason;

    //
    // The response headers.
    //

    HTTP_RESPONSE_HEADERS Headers;

    //
    // pEntityChunks points to an array of EntityChunkCount HTTP_DATA_CHUNKs.
    //

    USHORT           EntityChunkCount;
    PHTTP_DATA_CHUNK pEntityChunks;

} HTTP_RESPONSE_V1, *PHTTP_RESPONSE_V1;
]]

ffi.cdef[[
//
// Version 2.0 members are defined here
// N.B. One must define V2 elements in two places :(
//      This is due to the fact that C++ doesn't allow anonymous
//      structure declarations and one must use structure
//      inheritance instead.
//


typedef struct _HTTP_RESPONSE_V2
{
    struct _HTTP_RESPONSE_V1;

    //
    // Version 2.0 members are declared below
    //

    USHORT ResponseInfoCount;
    PHTTP_RESPONSE_INFO pResponseInfo;
} HTTP_RESPONSE_V2, *PHTTP_RESPONSE_V2;


typedef HTTP_RESPONSE_V2 HTTP_RESPONSE;


typedef HTTP_RESPONSE_V1 HTTP_RESPONSE;


typedef HTTP_RESPONSE *PHTTP_RESPONSE;
]]




ffi.cdef[[
//
// Request Authentication related.
//

typedef enum _HTTP_AUTH_STATUS
{
    HttpAuthStatusSuccess,
    HttpAuthStatusNotAuthenticated,
    HttpAuthStatusFailure

} HTTP_AUTH_STATUS, *PHTTP_AUTH_STATUS;


typedef enum _HTTP_REQUEST_AUTH_TYPE
{
    HttpRequestAuthTypeNone = 0,
    HttpRequestAuthTypeBasic,
    HttpRequestAuthTypeDigest,
    HttpRequestAuthTypeNTLM,
    HttpRequestAuthTypeNegotiate,
    HttpRequestAuthTypeKerberos


} HTTP_REQUEST_AUTH_TYPE, *PHTTP_REQUEST_AUTH_TYPE;

//
// Authentication request info structure
//

static const int HTTP_REQUEST_AUTH_FLAG_TOKEN_FOR_CACHED_CRED = (0x00000001);

typedef struct _HTTP_REQUEST_AUTH_INFO
{
    HTTP_AUTH_STATUS AuthStatus;
    SECURITY_STATUS  SecStatus;

    ULONG Flags;

    HTTP_REQUEST_AUTH_TYPE AuthType;

    HANDLE AccessToken;
    ULONG ContextAttributes;

    //
    // Optional serialized context.
    //

    ULONG PackedContextLength;
    ULONG PackedContextType;
    PVOID PackedContext;

    //
    // Optional mutual authentication data and its length in bytes.
    //

    ULONG MutualAuthDataLength;
    PCHAR pMutualAuthData;

    //
    // For SSPI based schemes the package name is returned. Length does
    // not include the terminating null and it is in bytes.
    //

    USHORT PackageNameLength;
    PWSTR pPackageName;

} HTTP_REQUEST_AUTH_INFO, *PHTTP_REQUEST_AUTH_INFO;
]]

ffi.cdef[[
//
// Data computed during SSL handshake.
//

typedef struct _HTTP_SSL_INFO
{
    USHORT ServerCertKeySize;
    USHORT ConnectionKeySize;
    ULONG  ServerCertIssuerSize;
    ULONG  ServerCertSubjectSize;

    PCSTR  pServerCertIssuer;
    PCSTR  pServerCertSubject;

    PHTTP_SSL_CLIENT_CERT_INFO pClientCertInfo;
    ULONG                      SslClientCertNegotiated;

} HTTP_SSL_INFO, *PHTTP_SSL_INFO;
]]

ffi.cdef[[
//
// The structure of an HTTP request for downlevel OS
//

typedef struct _HTTP_REQUEST_V1
{
    //
    // Request flags (see HTTP_REQUEST_FLAG_* definitions below).
    //

    ULONG Flags;

    //
    // An opaque request identifier. These values are used by the driver
    // to correlate outgoing responses with incoming requests.
    //

    HTTP_CONNECTION_ID ConnectionId;
    HTTP_REQUEST_ID    RequestId;

    //
    // The context associated with the URL prefix.
    //

    HTTP_URL_CONTEXT UrlContext;

    //
    // The HTTP version number.
    //

    HTTP_VERSION Version;

    //
    // The request verb.
    //

    HTTP_VERB Verb;

    //
    // The length of the verb string if the Verb field is HttpVerbUnknown.
    //

    USHORT UnknownVerbLength;           // in bytes not including the NUL

    //
    // The length of the raw (uncooked) URL
    //

    USHORT RawUrlLength;                // in bytes not including the NUL

    //
    // Pointer to the verb string if the Verb field is HttpVerbUnknown.
    //

    PCSTR  pUnknownVerb;

    //
    // Pointer to the raw (uncooked) URL
    //

    PCSTR  pRawUrl;

    //
    // The canonicalized Unicode URL
    //

    HTTP_COOKED_URL CookedUrl;

    //
    // Local and remote transport addresses for the connection.
    //

    HTTP_TRANSPORT_ADDRESS Address;

    //
    // The request headers.
    //

    HTTP_REQUEST_HEADERS Headers;

    //
    // The total number of bytes received from network for this request.
    //

    ULONGLONG BytesReceived;

    //
    // pEntityChunks is an array of EntityChunkCount HTTP_DATA_CHUNKs. The
    // entity body is copied only if HTTP_RECEIVE_REQUEST_FLAG_COPY_BODY
    // was passed to HttpReceiveHttpRequest().
    //

    USHORT           EntityChunkCount;
    PHTTP_DATA_CHUNK pEntityChunks;

    //
    // SSL connection information.
    //

    HTTP_RAW_CONNECTION_ID RawConnectionId;
    PHTTP_SSL_INFO         pSslInfo;

} HTTP_REQUEST_V1, *PHTTP_REQUEST_V1;
]]



ffi.cdef[[
// Vista

//
// Version 2.0 members are defined here
// N.B. One must define V2 elements in two places :(
//      This is due to the fact that C++ doesn't allow anonymous
//      structure declarations and one must use structure
//      inheritance instead.
//

typedef struct _HTTP_REQUEST_V2
{
    struct _HTTP_REQUEST_V1;        // Anonymous structure

    //
    // Version 2.0 members are declared below
    //

    //
    // Additional Request Informations.
    //

    USHORT             RequestInfoCount;
    PHTTP_REQUEST_INFO pRequestInfo;
} HTTP_REQUEST_V2, *PHTTP_REQUEST_V2;


typedef HTTP_REQUEST_V2 HTTP_REQUEST;

typedef HTTP_REQUEST * PHTTP_REQUEST;
]]

ffi.cdef[[

//
// Values for HTTP_REQUEST::Flags. Zero or more of these may be ORed together.
//
// HTTP_REQUEST_FLAG_MORE_ENTITY_BODY_EXISTS - there is more entity body
// to be read for this request. Otherwise, there is no entity body or
// all of the entity body was copied into pEntityChunks.
// HTTP_REQUEST_FLAG_IP_ROUTED - This flag indicates that the request has been
// routed based on host plus ip or ip binding.This is a hint for the application
// to include the local ip while flushing kernel cache entries build for this
// request if any.
//

static const int HTTP_REQUEST_FLAG_MORE_ENTITY_BODY_EXISTS  = 0x00000001;
static const int HTTP_REQUEST_FLAG_IP_ROUTED                = 0x00000002;
]]

ffi.cdef[[
ULONG
HttpAddFragmentToCache(
    HANDLE ReqQueueHandle,
    PCWSTR pUrlPrefix,
    PHTTP_DATA_CHUNK pDataChunk,
    PHTTP_CACHE_POLICY pCachePolicy,
    LPOVERLAPPED pOverlapped 
    );

ULONG
HttpAddUrl(
    HANDLE ReqQueueHandle,
    PCWSTR pFullyQualifiedUrl,
    PVOID pReserved
    );

ULONG
HttpAddUrlToUrlGroup(
    HTTP_URL_GROUP_ID UrlGroupId,
    PCWSTR pFullyQualifiedUrl,
    HTTP_URL_CONTEXT UrlContext ,
    ULONG Reserved
    );

ULONG
HttpCancelHttpRequest(
    HANDLE ReqQueueHandle,
    HTTP_REQUEST_ID RequestId,
    LPOVERLAPPED pOverlapped 
    );

ULONG
HttpCloseRequestQueue(
    HANDLE ReqQueueHandle
    );

ULONG
HttpCloseServerSession(
    HTTP_SERVER_SESSION_ID ServerSessionId
    );

ULONG
HttpCloseUrlGroup(
    HTTP_URL_GROUP_ID UrlGroupId
    );

ULONG
HttpCreateHttpHandle(
    PHANDLE pReqQueueHandle,
    ULONG Reserved
    );

ULONG
HttpCreateRequestQueue(
    HTTPAPI_VERSION Version,
    PCWSTR pName ,
    PSECURITY_ATTRIBUTES pSecurityAttributes ,
    ULONG Flags ,
    PHANDLE pReqQueueHandle
    );

ULONG
HttpCreateServerSession(
    HTTPAPI_VERSION Version,
    PHTTP_SERVER_SESSION_ID pServerSessionId,
    ULONG Reserved
    );

ULONG
HttpCreateUrlGroup(
    HTTP_SERVER_SESSION_ID ServerSessionId,
    PHTTP_URL_GROUP_ID pUrlGroupId,
    ULONG Reserved
    );

ULONG
HttpDeleteServiceConfiguration(
    HANDLE ServiceHandle,
    HTTP_SERVICE_CONFIG_ID ConfigId,
    PVOID pConfigInformation,
    ULONG ConfigInformationLength,
    LPOVERLAPPED pOverlapped
    );

ULONG
HttpFlushResponseCache(
    HANDLE ReqQueueHandle,
    PCWSTR pUrlPrefix,
    ULONG Flags,
    LPOVERLAPPED pOverlapped 
    );

ULONG
HttpInitialize(
    HTTPAPI_VERSION Version,
    ULONG Flags,
    PVOID pReserved
    );

ULONG
HttpQueryRequestQueueProperty(
    HANDLE Handle,
    HTTP_SERVER_PROPERTY Property,
    PVOID pPropertyInformation,
    ULONG PropertyInformationLength,
    ULONG Reserved,
    PULONG pReturnLength ,
    PVOID pReserved
    );

ULONG
HttpQueryServerSessionProperty(
    HTTP_SERVER_SESSION_ID ServerSessionId,
    HTTP_SERVER_PROPERTY Property,
    PVOID pPropertyInformation,
    ULONG PropertyInformationLength,
    PULONG pReturnLength 
    );

ULONG
HttpQueryServiceConfiguration(
    HANDLE ServiceHandle,
    HTTP_SERVICE_CONFIG_ID ConfigId,
    PVOID pInputConfigInformation ,
    ULONG InputConfigInformationLength ,
    PVOID pOutputConfigInformation ,
    ULONG OutputConfigInformationLength ,
    PULONG pReturnLength ,
    LPOVERLAPPED pOverlapped
    );

ULONG
HttpQueryUrlGroupProperty(
    HTTP_URL_GROUP_ID UrlGroupId,
    HTTP_SERVER_PROPERTY Property,
    PVOID pPropertyInformation,
    ULONG PropertyInformationLength,
    PULONG pReturnLength 
    );

ULONG
HttpReadFragmentFromCache(
    HANDLE ReqQueueHandle,
    PCWSTR pUrlPrefix,
    PHTTP_BYTE_RANGE pByteRange ,
    PVOID pBuffer,
    ULONG BufferLength,
    PULONG pBytesRead ,
    LPOVERLAPPED pOverlapped 
    );

ULONG
HttpReceiveClientCertificate(
    HANDLE ReqQueueHandle,
    HTTP_CONNECTION_ID ConnectionId,
    ULONG Flags,
    PHTTP_SSL_CLIENT_CERT_INFO pSslClientCertInfo,
    ULONG SslClientCertInfoSize,
    PULONG pBytesReceived ,
    LPOVERLAPPED pOverlapped 
    );

ULONG
HttpReceiveHttpRequest(
    HANDLE ReqQueueHandle,
    HTTP_REQUEST_ID RequestId,
    ULONG Flags,
    PHTTP_REQUEST pRequestBuffer,
    ULONG RequestBufferLength,
    PULONG pBytesReceived ,
    LPOVERLAPPED pOverlapped 
    );


ULONG
HttpReceiveRequestEntityBody(
    HANDLE ReqQueueHandle,
    HTTP_REQUEST_ID RequestId,
    ULONG Flags,
    PVOID pBuffer,
    ULONG BufferLength,
    PULONG pBytesReceived ,
    LPOVERLAPPED pOverlapped 
    );

ULONG
HttpRemoveUrl(
    HANDLE ReqQueueHandle,
    PCWSTR pFullyQualifiedUrl
    );


ULONG
HttpRemoveUrlFromUrlGroup(
    HTTP_URL_GROUP_ID UrlGroupId,
    PCWSTR pFullyQualifiedUrl,
    ULONG Flags
    );

ULONG
HttpSendHttpResponse(
    HANDLE ReqQueueHandle,
    HTTP_REQUEST_ID RequestId,
    ULONG Flags,
    PHTTP_RESPONSE pHttpResponse,
    PHTTP_CACHE_POLICY pCachePolicy ,
    PULONG pBytesSent ,
    PVOID pReserved1 , // must be NULL
    ULONG Reserved2 , // must be 0
    LPOVERLAPPED pOverlapped ,
    PHTTP_LOG_DATA pLogData 
    );

ULONG
HttpSendResponseEntityBody(
    HANDLE ReqQueueHandle,
    HTTP_REQUEST_ID RequestId,
    ULONG Flags,
    USHORT EntityChunkCount ,
    PHTTP_DATA_CHUNK pEntityChunks ,
    PULONG pBytesSent ,
    PVOID pReserved1 , // must be NULL
    ULONG Reserved2 , // must be 0
    LPOVERLAPPED pOverlapped ,
    PHTTP_LOG_DATA pLogData 
    );

ULONG
HttpSetRequestQueueProperty(
    HANDLE Handle,
    HTTP_SERVER_PROPERTY Property,
    PVOID pPropertyInformation,
    ULONG PropertyInformationLength,
    ULONG Reserved,
    PVOID pReserved
    );

ULONG
HttpSetServerSessionProperty(
    HTTP_SERVER_SESSION_ID ServerSessionId,
    HTTP_SERVER_PROPERTY Property,
    PVOID pPropertyInformation,
    ULONG PropertyInformationLength
    );


ULONG
HttpSetServiceConfiguration(
    HANDLE ServiceHandle,
    HTTP_SERVICE_CONFIG_ID ConfigId,
    PVOID pConfigInformation,
    ULONG ConfigInformationLength,
    LPOVERLAPPED pOverlapped
    );

ULONG
HttpSetUrlGroupProperty(
    HTTP_URL_GROUP_ID UrlGroupId,
    HTTP_SERVER_PROPERTY Property,
    PVOID pPropertyInformation,
    ULONG PropertyInformationLength
    );

ULONG
HttpShutdownRequestQueue(
    HANDLE ReqQueueHandle
    );

ULONG
HttpTerminate(
    ULONG Flags,
    PVOID pReserved
    );

ULONG
HttpWaitForDemandStart(
    HANDLE ReqQueueHandle,
    LPOVERLAPPED pOverlapped 
    );

ULONG
HttpWaitForDisconnect(
    HANDLE ReqQueueHandle,
    HTTP_CONNECTION_ID ConnectionId,
    LPOVERLAPPED pOverlapped 
    );

ULONG
HttpWaitForDisconnectEx(
    HANDLE ReqQueueHandle,
    HTTP_CONNECTION_ID ConnectionId,
    ULONG Reserved ,
    LPOVERLAPPED pOverlapped 
    );
]]


local httpapi = {
    Lib = Lib,
    
	HttpAddFragmentToCache = Lib.HttpAddFragmentToCache,
	HttpAddUrl = Lib.HttpAddUrl,
	HttpAddUrlToUrlGroup = Lib.HttpAddUrlToUrlGroup,
	HttpCancelHttpRequest = Lib.HttpCancelHttpRequest,
	HttpCloseRequestQueue = Lib.HttpCloseRequestQueue,
	HttpCloseServerSession = Lib.HttpCloseServerSession,
	HttpCloseUrlGroup = Lib.HttpCloseUrlGroup,
--	HttpControlService = Lib.HttpControlService,
	HttpCreateHttpHandle = Lib.HttpCreateHttpHandle,
	HttpCreateRequestQueue = Lib.HttpCreateRequestQueue,
	HttpCreateServerSession = Lib.HttpCreateServerSession,
	HttpCreateUrlGroup = Lib.HttpCreateUrlGroup,
	HttpDeleteServiceConfiguration = Lib.HttpDeleteServiceConfiguration,
	HttpFlushResponseCache = Lib.HttpFlushResponseCache,
--	HttpGetCounters = Lib.HttpGetCounters,
	HttpInitialize = Lib.HttpInitialize,	
--	HttpPrepareUrl = Lib.HttpPrepareUrl,
	HttpQueryRequestQueueProperty = Lib.HttpQueryRequestQueueProperty,
	HttpQueryServerSessionProperty = Lib.HttpQueryServerSessionProperty,
	HttpQueryServiceConfiguration = Lib.HttpQueryServiceConfiguration,
	HttpQueryUrlGroupProperty = Lib.HttpQueryUrlGroupProperty,
	HttpReadFragmentFromCache = Lib.HttpReadFragmentFromCache,
	HttpReceiveClientCertificate = Lib.HttpReceiveClientCertificate,
	HttpReceiveHttpRequest = Lib.HttpReceiveHttpRequest,
	HttpReceiveRequestEntityBody = Lib.HttpReceiveRequestEntityBody,
	HttpRemoveUrl = Lib.HttpRemoveUrl,
	HttpRemoveUrlFromUrlGroup = Lib.HttpRemoveUrlFromUrlGroup,
	HttpSendHttpResponse = Lib.HttpSendHttpResponse,
	HttpSendResponseEntityBody = Lib.HttpSendResponseEntityBody,
	HttpSetRequestQueueProperty = Lib.HttpSetRequestQueueProperty,
	HttpSetServerSessionProperty = Lib.HttpSetServerSessionProperty,
	HttpSetServiceConfiguration = Lib.HttpSetServiceConfiguration,
	HttpSetUrlGroupProperty = Lib.HttpSetUrlGroupProperty,
	HttpShutdownRequestQueue = Lib.HttpShutdownRequestQueue,
	HttpTerminate = Lib.HttpTerminate,
	HttpWaitForDemandStart = Lib.HttpWaitForDemandStart,
	HttpWaitForDisconnect = Lib.HttpWaitForDisconnect,
	HttpWaitForDisconnectEx = Lib.HttpWaitForDisconnectEx,
}

-- Call HttpInitialize to get things started
--#define HTTPAPI_VERSION_2 { 2, 0 }
local version = ffi.new("HTTPAPI_VERSION", 2, 0);

httpapi.HttpInitialize(version, ffi.C.HTTP_INITIALIZE_SERVER, nil);

return httpapi;