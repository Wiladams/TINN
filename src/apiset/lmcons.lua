
local ffi = require("ffi");
require("WTypes");

ffi.cdef[[
typedef DWORD NET_API_STATUS;
]]

ffi.cdef[[
//
// String Lengths for various LanMan names
//

static const int CNLEN       =15;                  // Computer name length
static const int LM20_CNLEN  =15;                  // LM 2.0 Computer name length
static const int DNLEN       =CNLEN;               // Maximum domain name length
static const int LM20_DNLEN  =LM20_CNLEN;          // LM 2.0 Maximum domain name length
]]


ffi.cdef[[
static const int UNCLEN      =(CNLEN+2);           // UNC computer name length
static const int LM20_UNCLEN =(LM20_CNLEN+2);      // LM 2.0 UNC computer name length

static const int NNLEN       =80;                  // Net name length (share name)
static const int LM20_NNLEN  =12;                  // LM 2.0 Net name length

static const int RMLEN       =(UNCLEN+1+NNLEN);    // Max remote name length
static const int LM20_RMLEN  =(LM20_UNCLEN+1+LM20_NNLEN); // LM 2.0 Max remote name length

static const int SNLEN       =80;                  // Service name length
static const int LM20_SNLEN  =15;                  // LM 2.0 Service name length
static const int STXTLEN     =256;                 // Service text length
static const int LM20_STXTLEN =63;                 // LM 2.0 Service text length

static const int PATHLEN      = 256;                 // Max. path (not including drive name)
static const int LM20_PATHLEN = 256;                // LM 2.0 Max. path

static const int DEVLEN      = 80;                  // Device name length
static const int LM20_DEVLEN = 8;                   // LM 2.0 Device name length

static const int EVLEN       = 16;                  // Event name length
]]

ffi.cdef[[
//
// User, Group and Password lengths
//

static const int UNLEN       = 256;                 // Maximum user name length
static const int LM20_UNLEN  = 20;                  // LM 2.0 Maximum user name length

static const int GNLEN       =UNLEN;               // Group name
static const int LM20_GNLEN  =LM20_UNLEN;          // LM 2.0 Group name

static const int PWLEN       =256;                 // Maximum password length
static const int LM20_PWLEN  = 14;                  // LM 2.0 Maximum password length

static const int SHPWLEN    = 8;                   // Share password length (bytes)


static const int CLTYPE_LEN  = 12;                  // Length of client type string


static const int MAXCOMMENTSZ = 256;                // Multipurpose comment length
static const int LM20_MAXCOMMENTSZ = 48;            // LM 2.0 Multipurpose comment length

static const int QNLEN       = NNLEN;               // Queue name maximum length
static const int LM20_QNLEN  = LM20_NNLEN;          // LM 2.0 Queue name maximum length
]]

ffi.cdef[[
//
// The ALERTSZ and MAXDEVENTRIES defines have not yet been NT'ized.
// Whoever ports these components should change these values appropriately.
//

static const int ALERTSZ    = 128;                 // size of alert string in server
static const int MAXDEVENTRIES =(sizeof (int)*8);  // Max number of device entries

                                        //
                                        // We use int bitmap to represent
                                        //

static const int NETBIOS_NAME_LEN  =16;            // NetBIOS net name (bytes)

//
// Value to be used with APIs which have a "preferred maximum length"
// parameter.  This value indicates that the API should just allocate
// "as much as it takes."
//

static const int MAX_PREFERRED_LENGTH   = ((DWORD) -1);
]]

ffi.cdef[[
//
//        Constants used with encryption
//

static const int CRYPT_KEY_LEN          = 7;
static const int CRYPT_TXT_LEN          = 8;
static const int ENCRYPTED_PWLEN        = 16;
static const int SESSION_PWLEN          = 24;
static const int SESSION_CRYPT_KLEN     = 21;
]]

ffi.cdef[[
//
//  Value to be used with SetInfo calls to allow setting of all
//  settable parameters (parmnum zero option)
//
static const int PARMNUM_ALL             = 0;

static const int PARM_ERROR_UNKNOWN      = ( (DWORD) (-1) );
static const int PARM_ERROR_NONE         = 0;
static const int PARMNUM_BASE_INFOLEVEL  = 1000;
]]

--[[
//
// Only the UNICODE version of the LM APIs are available on NT.
// Non-UNICODE version on other platforms
//
--]]

--if defined( _WIN32_WINNT ) || defined( WINNT ) || defined( __midl ) \
--    || defined( FORCE_UNICODE )
ffi.cdef[[
typedef   LPWSTR LMSTR;
typedef   LPCWSTR LMCSTR;
]]
--else
--ffi.cdef[[
--typedef LPSTR  LMSTR;
--typedef LPCSTR LMCSTR;
--]]
--end
--]]

--[[
//
//        Message File Names
//
--]]

MESSAGE_FILENAME    =    "NETMSG";
OS2MSG_FILENAME     =    "BASE";
HELP_MSG_FILENAME   =    "NETH";


ffi.cdef[[
typedef DWORD  NET_API_STATUS;
]]





ffi.cdef[[
//
// The platform ID indicates the levels to use for platform-specific
// information.
//

static const int PLATFORM_ID_DOS = 300;
static const int PLATFORM_ID_OS2 = 400;
static const int PLATFORM_ID_NT  = 500;
static const int PLATFORM_ID_OSF = 600;
static const int PLATFORM_ID_VMS = 700;
]]

ffi.cdef[[
//
//      There message numbers assigned to different LANMAN components
//      are as defined below.
//
//      lmerr.h:        2100 - 2999     NERR_BASE
//      alertmsg.h:     3000 - 3049     ALERT_BASE
//      lmsvc.h:        3050 - 3099     SERVICE_BASE
//      lmerrlog.h:     3100 - 3299     ERRLOG_BASE
//      msgtext.h:      3300 - 3499     MTXT_BASE
//      apperr.h:       3500 - 3999     APPERR_BASE
//      apperrfs.h:     4000 - 4299     APPERRFS_BASE
//      apperr2.h:      4300 - 5299     APPERR2_BASE
//      ncberr.h:       5300 - 5499     NRCERR_BASE
//      alertmsg.h:     5500 - 5599     ALERT2_BASE
//      lmsvc.h:        5600 - 5699     SERVICE2_BASE
//      lmerrlog.h      5700 - 5899     ERRLOG2_BASE
//

static const int NERR_BASE       =2100;

static const int MIN_LANMAN_MESSAGE_ID  = NERR_BASE;
static const int MAX_LANMAN_MESSAGE_ID  = 5899;
]]

