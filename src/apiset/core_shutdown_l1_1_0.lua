-- core_shutdown_l1_1_0.lua
-- api-ms-win-core-shutdown-l1-1-0.dll	

local ffi = require("ffi");
require ("WTypes")
local Lib = ffi.load("advapi32");

ffi.cdef[[
//
// MAX Shutdown TimeOut == 10 Years in seconds
//
static const int MAX_SHUTDOWN_TIMEOUT = (10*365*24*60*60);
]]


ffi.cdef[[
//
// defines for InitiateSystemShutdownEx reason codes
//

// Reason flags

// Flags used by the various UIs.
static const int SHTDN_REASON_FLAG_COMMENT_REQUIRED          = 0x01000000;
static const int SHTDN_REASON_FLAG_DIRTY_PROBLEM_ID_REQUIRED = 0x02000000;
static const int SHTDN_REASON_FLAG_CLEAN_UI                  = 0x04000000;
static const int SHTDN_REASON_FLAG_DIRTY_UI                  = 0x08000000;

// Flags that end up in the event log code.
static const int SHTDN_REASON_FLAG_USER_DEFINED          = 0x40000000;
static const int SHTDN_REASON_FLAG_PLANNED               = 0x80000000;

// Microsoft major reasons.
static const int SHTDN_REASON_MAJOR_OTHER                = 0x00000000;
static const int SHTDN_REASON_MAJOR_NONE                 = 0x00000000;
static const int SHTDN_REASON_MAJOR_HARDWARE             = 0x00010000;
static const int SHTDN_REASON_MAJOR_OPERATINGSYSTEM      = 0x00020000;
static const int SHTDN_REASON_MAJOR_SOFTWARE             = 0x00030000;
static const int SHTDN_REASON_MAJOR_APPLICATION          = 0x00040000;
static const int SHTDN_REASON_MAJOR_SYSTEM               = 0x00050000;
static const int SHTDN_REASON_MAJOR_POWER                = 0x00060000;
static const int SHTDN_REASON_MAJOR_LEGACY_API           = 0x00070000;

// Microsoft minor reasons.
static const int SHTDN_REASON_MINOR_OTHER                = 0x00000000;
static const int SHTDN_REASON_MINOR_NONE                 = 0x000000ff;
static const int SHTDN_REASON_MINOR_MAINTENANCE          = 0x00000001;
static const int SHTDN_REASON_MINOR_INSTALLATION         = 0x00000002;
static const int SHTDN_REASON_MINOR_UPGRADE              = 0x00000003;
static const int SHTDN_REASON_MINOR_RECONFIG             = 0x00000004;
static const int SHTDN_REASON_MINOR_HUNG                 = 0x00000005;
static const int SHTDN_REASON_MINOR_UNSTABLE             = 0x00000006;
static const int SHTDN_REASON_MINOR_DISK                 = 0x00000007;
static const int SHTDN_REASON_MINOR_PROCESSOR            = 0x00000008;
static const int SHTDN_REASON_MINOR_NETWORKCARD          = 0x00000009;
static const int SHTDN_REASON_MINOR_POWER_SUPPLY         = 0x0000000a;
static const int SHTDN_REASON_MINOR_CORDUNPLUGGED        = 0x0000000b;
static const int SHTDN_REASON_MINOR_ENVIRONMENT          = 0x0000000c;
static const int SHTDN_REASON_MINOR_HARDWARE_DRIVER      = 0x0000000d;
static const int SHTDN_REASON_MINOR_OTHERDRIVER          = 0x0000000e;
static const int SHTDN_REASON_MINOR_BLUESCREEN           = 0x0000000F;
static const int SHTDN_REASON_MINOR_SERVICEPACK          = 0x00000010;
static const int SHTDN_REASON_MINOR_HOTFIX               = 0x00000011;
static const int SHTDN_REASON_MINOR_SECURITYFIX          = 0x00000012;
static const int SHTDN_REASON_MINOR_SECURITY             = 0x00000013;
static const int SHTDN_REASON_MINOR_NETWORK_CONNECTIVITY = 0x00000014;
static const int SHTDN_REASON_MINOR_WMI                  = 0x00000015;
static const int SHTDN_REASON_MINOR_SERVICEPACK_UNINSTALL = 0x00000016;
static const int SHTDN_REASON_MINOR_HOTFIX_UNINSTALL     = 0x00000017;
static const int SHTDN_REASON_MINOR_SECURITYFIX_UNINSTALL = 0x00000018;
static const int SHTDN_REASON_MINOR_MMC                  = 0x00000019;
static const int SHTDN_REASON_MINOR_SYSTEMRESTORE        = 0x0000001a;
static const int SHTDN_REASON_MINOR_TERMSRV              = 0x00000020;
static const int SHTDN_REASON_MINOR_DC_PROMOTION         = 0x00000021;
static const int SHTDN_REASON_MINOR_DC_DEMOTION          = 0x00000022;

static const int SHTDN_REASON_UNKNOWN                    =SHTDN_REASON_MINOR_NONE;
static const int SHTDN_REASON_LEGACY_API                 =(SHTDN_REASON_MAJOR_LEGACY_API | SHTDN_REASON_FLAG_PLANNED);

// This mask cuts out UI flags.
static const int SHTDN_REASON_VALID_BIT_MASK             = 0xc0ffffff;

// Convenience flags.
static const int PCLEANUI               = (SHTDN_REASON_FLAG_PLANNED | SHTDN_REASON_FLAG_CLEAN_UI);
static const int UCLEANUI               = (SHTDN_REASON_FLAG_CLEAN_UI);
static const int PDIRTYUI               = (SHTDN_REASON_FLAG_PLANNED | SHTDN_REASON_FLAG_DIRTY_UI);
static const int UDIRTYUI               = (SHTDN_REASON_FLAG_DIRTY_UI);

/*
 * Maximum character lengths for reason name, description, problem id, and
 * comment respectively.
 */
static const int MAX_REASON_NAME_LEN  =64;
static const int MAX_REASON_DESC_LEN  =256;
static const int MAX_REASON_BUGID_LEN =32;
static const int MAX_REASON_COMMENT_LEN = 512;
static const int SHUTDOWN_TYPE_LEN =32;

/*
 *	S.E.T. policy value
 *
 */
static const int POLICY_SHOWREASONUI_NEVER				=0;
static const int POLICY_SHOWREASONUI_ALWAYS				=1;
static const int POLICY_SHOWREASONUI_WORKSTATIONONLY	=2;
static const int POLICY_SHOWREASONUI_SERVERONLY			=3;


/*
 * Snapshot policy values
 */
static const int SNAPSHOT_POLICY_NEVER           = 0;
static const int SNAPSHOT_POLICY_ALWAYS          = 1;
static const int SNAPSHOT_POLICY_UNPLANNED       = 2;

/*
 * Maximue user defined reasons
 */
static const int MAX_NUM_REASONS =256;
]]




ffi.cdef[[
BOOL
AbortSystemShutdownW(LPWSTR lpMachineName);

BOOL
InitiateSystemShutdownExW(
    LPWSTR lpMachineName,
    LPWSTR lpMessage,
    DWORD dwTimeout,
    BOOL bForceAppsClosed,
    BOOL bRebootAfterShutdown,
    DWORD dwReason);
]]

return {
    Lib = Lib,
    
	AbortSystemShutdownW = Lib.AbortSystemShutdownW,
	InitiateSystemShutdownExW = Lib.InitiateSystemShutdownExW,
}


--[=[
ffi.cdef[[
//
// Remoteable System Shutdown APIs
//

BOOL
InitiateSystemShutdownA(
    LPSTR lpMachineName,
    LPSTR lpMessage,
    DWORD dwTimeout,
    BOOL bForceAppsClosed,
    BOOL bRebootAfterShutdown
    );

BOOL
InitiateSystemShutdownW(
    LPWSTR lpMachineName,
    LPWSTR lpMessage,
    DWORD dwTimeout,
    BOOL bForceAppsClosed,
    BOOL bRebootAfterShutdown
    );
]]



ffi.cdef[[

BOOL
AbortSystemShutdownA(
    LPSTR lpMachineName
    );
]]

ffi.cdef[[

BOOL
InitiateSystemShutdownExA(
    LPSTR lpMachineName,
    LPSTR lpMessage,
    DWORD dwTimeout,
    BOOL bForceAppsClosed,
    BOOL bRebootAfterShutdown,
    DWORD dwReason
    );
]]

ffi.cdef[[
//
// Shutdown flags
// for InitiateShutdownW

static const int SHUTDOWN_FORCE_OTHERS           =0x00000001;
static const int SHUTDOWN_FORCE_SELF             =0x00000002;
static const int SHUTDOWN_RESTART                =0x00000004;
static const int SHUTDOWN_POWEROFF               =0x00000008;
static const int SHUTDOWN_NOREBOOT               =0x00000010;
static const int SHUTDOWN_GRACE_OVERRIDE         =0x00000020;
static const int SHUTDOWN_INSTALL_UPDATES        =0x00000040;
static const int SHUTDOWN_RESTARTAPPS            =0x00000080;
static const int SHUTDOWN_SKIP_SVC_PRESHUTDOWN   =0x00000100;
static const int SHUTDOWN_HYBRID				 =0x00000200;
]]

ffi.cdef[[

DWORD
InitiateShutdownA(
    LPSTR lpMachineName,
    LPSTR lpMessage,
         DWORD dwGracePeriod,
         DWORD dwShutdownFlags,
         DWORD dwReason
    );

DWORD
InitiateShutdownW(
    LPWSTR lpMachineName,
    LPWSTR lpMessage,
         DWORD dwGracePeriod,
         DWORD dwShutdownFlags,
         DWORD dwReason
    );
]]

--]=]