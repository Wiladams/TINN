-- wkscli.lua
-- wkscli.dll

local ffi = require("ffi");
local Lib = ffi.load("Netapi32");
local lmcons = require("lmcons");

ffi.cdef[[
//
// The following enumeration must be kept
// in sync with COMPUTER_NAME_TYPE defined
// in winbase.h
//

typedef enum _NET_COMPUTER_NAME_TYPE {
    NetPrimaryComputerName,
    NetAlternateComputerNames,
    NetAllComputerNames,
    NetComputerNameTypeMax
} NET_COMPUTER_NAME_TYPE, *PNET_COMPUTER_NAME_TYPE;
]]

ffi.cdef[[
//
// Types of name that can be validated
//
typedef enum  _NETSETUP_NAME_TYPE {

    NetSetupUnknown = 0,
    NetSetupMachine,
    NetSetupWorkgroup,
    NetSetupDomain,
    NetSetupNonExistentDomain,
    NetSetupDnsMachine

} NETSETUP_NAME_TYPE, *PNETSETUP_NAME_TYPE;


//
// Status of a workstation
//
typedef enum _NETSETUP_JOIN_STATUS {

    NetSetupUnknownStatus = 0,
    NetSetupUnjoined,
    NetSetupWorkgroupName,
    NetSetupDomainName

} NETSETUP_JOIN_STATUS, *PNETSETUP_JOIN_STATUS;
]]


ffi.cdef[[
NET_API_STATUS
NetAddAlternateComputerName(
      LPCWSTR Server ,
      LPCWSTR AlternateName,
      LPCWSTR DomainAccount ,
       LPCWSTR DomainAccountPassword ,
      ULONG Reserved
    );

NET_API_STATUS
NetEnumerateComputerNames(
      LPCWSTR Server ,
      NET_COMPUTER_NAME_TYPE NameType,
      ULONG Reserved,
      PDWORD EntryCount,
    LPWSTR **ComputerNames
    );

NET_API_STATUS
NetGetJoinableOUs(
      LPCWSTR     lpServer ,
      LPCWSTR     lpDomain,
      LPCWSTR     lpAccount ,
       LPCWSTR     lpPassword ,
      DWORD      *OUCount,
     LPWSTR    **OUs
    );

NET_API_STATUS
NetGetJoinInformation(
        LPCWSTR                lpServer ,
       LPWSTR                *lpNameBuffer,
      PNETSETUP_JOIN_STATUS  BufferType
    );

NET_API_STATUS
NetJoinDomain(
      LPCWSTR lpServer ,
      LPCWSTR lpDomain,
      LPCWSTR lpAccountOU, 
      LPCWSTR lpAccount ,
       LPCWSTR lpPassword ,
      DWORD   fJoinOptions
    );

NET_API_STATUS
NetRemoveAlternateComputerName(
      LPCWSTR Server ,
      LPCWSTR AlternateName,
      LPCWSTR DomainAccount ,
       LPCWSTR DomainAccountPassword ,
      ULONG Reserved
    );

NET_API_STATUS
NetRenameMachineInDomain(
      LPCWSTR lpServer ,
      LPCWSTR lpNewMachineName ,
      LPCWSTR lpAccount ,
       LPCWSTR lpPassword ,
      DWORD   fRenameOptions
    );


NET_API_STATUS
NetSetPrimaryComputerName(
      LPCWSTR Server ,
      LPCWSTR PrimaryName,
      LPCWSTR DomainAccount ,
       LPCWSTR DomainAccountPassword ,
      ULONG Reserved
    );

NET_API_STATUS
NetUnjoinDomain(
      LPCWSTR lpServer ,
      LPCWSTR lpAccount ,
       LPCWSTR lpPassword ,
      DWORD   fUnjoinOptions
    );

NET_API_STATUS NetUseAdd (
      LMSTR  UncServerName ,
     DWORD Level,
      LPBYTE Buf,
      LPDWORD ParmError 
    );

NET_API_STATUS NetUseDel (
      LMSTR  UncServerName ,
      LMSTR  UseName,
     DWORD ForceCond
    );

NET_API_STATUS NetUseEnum (
     LMSTR  UncServerName,
     DWORD Level,
     LPBYTE *BufPtr,
     DWORD PreferedMaximumSize,
     LPDWORD EntriesRead,
     LPDWORD TotalEntries,
     LPDWORD ResumeHandle
    );

NET_API_STATUS NetUseGetInfo (
      LMSTR  UncServerName ,
      LMSTR  UseName,
     DWORD Level,
      LPBYTE *BufPtr
    );

NET_API_STATUS
NetValidateName(
      LPCWSTR             lpServer ,
      LPCWSTR             lpName,
      LPCWSTR             lpAccount ,
       LPCWSTR             lpPassword ,
      NETSETUP_NAME_TYPE  NameType
    );

NET_API_STATUS NetWkstaGetInfo (
       LMSTR   servername ,
      DWORD   level,
    LPBYTE  *bufptr
    );

NET_API_STATUS NetWkstaSetInfo (
       LMSTR   servername ,
      DWORD   level,
      LPBYTE  buffer,
      LPDWORD parm_err 
    );

NET_API_STATUS NetWkstaTransportAdd (
     LMSTR   servername ,
      DWORD   level,
     LPBYTE  buf,
     LPDWORD parm_err
    );

NET_API_STATUS NetWkstaTransportDel (
       LMSTR   servername ,
       LMSTR   transportname,
      DWORD   ucond
    );

NET_API_STATUS NetWkstaTransportEnum (
     LMSTR       servername ,
      DWORD       level,
     LPBYTE      *bufptr,
      DWORD       prefmaxlen,
     LPDWORD     entriesread,
     LPDWORD     totalentries,
     LPDWORD resumehandle 
    );

NET_API_STATUS NetWkstaUserEnum (
     LMSTR       servername ,
      DWORD       level,
     LPBYTE      *bufptr,
      DWORD       prefmaxlen,
     LPDWORD     entriesread,
     LPDWORD     totalentries,
     LPDWORD resumehandle 
    );

NET_API_STATUS NetWkstaUserGetInfo (
       LMSTR  reserved,
      DWORD   level,
      LPBYTE  *bufptr
    );

NET_API_STATUS NetWkstaUserSetInfo (
       LMSTR  reserved,
      DWORD   level,
     LPBYTE  buf,
      LPDWORD parm_err 
    );
]]

ffi.cdef[[
//
//  Data Structures
//

//
// NetWkstaGetInfo and NetWkstaSetInfo
//

//
// NetWkstaGetInfo only.  System information - guest access
//
typedef struct _WKSTA_INFO_100 {
    DWORD   wki100_platform_id;
    LMSTR   wki100_computername;
    LMSTR   wki100_langroup;
    DWORD   wki100_ver_major;
    DWORD   wki100_ver_minor;
}WKSTA_INFO_100, *PWKSTA_INFO_100, *LPWKSTA_INFO_100;

//
// NetWkstaGetInfo only.  System information - user access
//
typedef struct _WKSTA_INFO_101 {
    DWORD   wki101_platform_id;
    LMSTR   wki101_computername;
    LMSTR   wki101_langroup;
    DWORD   wki101_ver_major;
    DWORD   wki101_ver_minor;
    LMSTR   wki101_lanroot;
}WKSTA_INFO_101, *PWKSTA_INFO_101, *LPWKSTA_INFO_101;

//
// NetWkstaGetInfo only.  System information - admin or operator access
//
typedef struct _WKSTA_INFO_102 {
    DWORD   wki102_platform_id;
    LMSTR   wki102_computername;
    LMSTR   wki102_langroup;
    DWORD   wki102_ver_major;
    DWORD   wki102_ver_minor;
    LMSTR   wki102_lanroot;
    DWORD   wki102_logged_on_users;
}WKSTA_INFO_102, *PWKSTA_INFO_102, *LPWKSTA_INFO_102;

//
// Down-level NetWkstaGetInfo and NetWkstaSetInfo.
//
// DOS specific workstation information -
//    admin or domain operator access
//
typedef struct _WKSTA_INFO_302{
    DWORD   wki302_char_wait;
    DWORD   wki302_collection_time;
    DWORD   wki302_maximum_collection_count;
    DWORD   wki302_keep_conn;
    DWORD   wki302_keep_search;
    DWORD   wki302_max_cmds;
    DWORD   wki302_num_work_buf;
    DWORD   wki302_siz_work_buf;
    DWORD   wki302_max_wrk_cache;
    DWORD   wki302_sess_timeout;
    DWORD   wki302_siz_error;
    DWORD   wki302_num_alerts;
    DWORD   wki302_num_services;
    DWORD   wki302_errlog_sz;
    DWORD   wki302_print_buf_time;
    DWORD   wki302_num_char_buf;
    DWORD   wki302_siz_char_buf;
    LMSTR   wki302_wrk_heuristics;
    DWORD   wki302_mailslots;
    DWORD   wki302_num_dgram_buf;
}WKSTA_INFO_302, *PWKSTA_INFO_302, *LPWKSTA_INFO_302;

//
// Down-level NetWkstaGetInfo and NetWkstaSetInfo
//
// OS/2 specific workstation information -
//    admin or domain operator access
//
typedef struct _WKSTA_INFO_402{
    DWORD   wki402_char_wait;
    DWORD   wki402_collection_time;
    DWORD   wki402_maximum_collection_count;
    DWORD   wki402_keep_conn;
    DWORD   wki402_keep_search;
    DWORD   wki402_max_cmds;
    DWORD   wki402_num_work_buf;
    DWORD   wki402_siz_work_buf;
    DWORD   wki402_max_wrk_cache;
    DWORD   wki402_sess_timeout;
    DWORD   wki402_siz_error;
    DWORD   wki402_num_alerts;
    DWORD   wki402_num_services;
    DWORD   wki402_errlog_sz;
    DWORD   wki402_print_buf_time;
    DWORD   wki402_num_char_buf;
    DWORD   wki402_siz_char_buf;
    LMSTR   wki402_wrk_heuristics;
    DWORD   wki402_mailslots;
    DWORD   wki402_num_dgram_buf;
    DWORD   wki402_max_threads;
}WKSTA_INFO_402, *PWKSTA_INFO_402, *LPWKSTA_INFO_402;

//
// Same-level NetWkstaGetInfo and NetWkstaSetInfo.
//
// NT specific workstation information -
//    admin or domain operator access
//
typedef struct _WKSTA_INFO_502{
    DWORD   wki502_char_wait;
    DWORD   wki502_collection_time;
    DWORD   wki502_maximum_collection_count;
    DWORD   wki502_keep_conn;
    DWORD   wki502_max_cmds;
    DWORD   wki502_sess_timeout;
    DWORD   wki502_siz_char_buf;
    DWORD   wki502_max_threads;

    DWORD   wki502_lock_quota;
    DWORD   wki502_lock_increment;
    DWORD   wki502_lock_maximum;
    DWORD   wki502_pipe_increment;
    DWORD   wki502_pipe_maximum;
    DWORD   wki502_cache_file_timeout;
    DWORD   wki502_dormant_file_limit;
    DWORD   wki502_read_ahead_throughput;

    DWORD   wki502_num_mailslot_buffers;
    DWORD   wki502_num_srv_announce_buffers;
    DWORD   wki502_max_illegal_datagram_events;
    DWORD   wki502_illegal_datagram_event_reset_frequency;
    BOOL    wki502_log_election_packets;

    BOOL    wki502_use_opportunistic_locking;
    BOOL    wki502_use_unlock_behind;
    BOOL    wki502_use_close_behind;
    BOOL    wki502_buf_named_pipes;
    BOOL    wki502_use_lock_read_unlock;
    BOOL    wki502_utilize_nt_caching;
    BOOL    wki502_use_raw_read;
    BOOL    wki502_use_raw_write;
    BOOL    wki502_use_write_raw_data;
    BOOL    wki502_use_encryption;
    BOOL    wki502_buf_files_deny_write;
    BOOL    wki502_buf_read_only_files;
    BOOL    wki502_force_core_create_mode;
    BOOL    wki502_use_512_byte_max_transfer;
}WKSTA_INFO_502, *PWKSTA_INFO_502, *LPWKSTA_INFO_502;


//
// The following info-levels are only valid for NetWkstaSetInfo
//

//
// The following levels are supported on down-level systems (LAN Man 2.x)
// as well as NT systems:
//
typedef struct _WKSTA_INFO_1010 {
     DWORD  wki1010_char_wait;
} WKSTA_INFO_1010, *PWKSTA_INFO_1010, *LPWKSTA_INFO_1010;

typedef struct _WKSTA_INFO_1011 {
     DWORD  wki1011_collection_time;
} WKSTA_INFO_1011, *PWKSTA_INFO_1011, *LPWKSTA_INFO_1011;

typedef struct _WKSTA_INFO_1012 {
     DWORD  wki1012_maximum_collection_count;
} WKSTA_INFO_1012, *PWKSTA_INFO_1012, *LPWKSTA_INFO_1012;

//
// The following level are supported on down-level systems (LAN Man 2.x)
// only:
//
typedef struct _WKSTA_INFO_1027 {
     DWORD  wki1027_errlog_sz;
} WKSTA_INFO_1027, *PWKSTA_INFO_1027, *LPWKSTA_INFO_1027;

typedef struct _WKSTA_INFO_1028 {
     DWORD  wki1028_print_buf_time;
} WKSTA_INFO_1028, *PWKSTA_INFO_1028, *LPWKSTA_INFO_1028;

typedef struct _WKSTA_INFO_1032 {
     DWORD  wki1032_wrk_heuristics;
} WKSTA_INFO_1032, *PWKSTA_INFO_1032, *LPWKSTA_INFO_1032;

//
// The following levels are settable on NT systems, and have no
// effect on down-level systems (i.e. LANMan 2.x) since these
// fields cannot be set on them:
//
typedef struct _WKSTA_INFO_1013 {
     DWORD  wki1013_keep_conn;
} WKSTA_INFO_1013, *PWKSTA_INFO_1013, *LPWKSTA_INFO_1013;

typedef struct _WKSTA_INFO_1018 {
     DWORD  wki1018_sess_timeout;
} WKSTA_INFO_1018, *PWKSTA_INFO_1018, *LPWKSTA_INFO_1018;

typedef struct _WKSTA_INFO_1023 {
     DWORD  wki1023_siz_char_buf;
} WKSTA_INFO_1023, *PWKSTA_INFO_1023, *LPWKSTA_INFO_1023;

typedef struct _WKSTA_INFO_1033 {
     DWORD  wki1033_max_threads;
} WKSTA_INFO_1033, *PWKSTA_INFO_1033, *LPWKSTA_INFO_1033;

//
// The following levels are only supported on NT systems:
//
typedef struct _WKSTA_INFO_1041 {
    DWORD   wki1041_lock_quota;
} WKSTA_INFO_1041, *PWKSTA_INFO_1041, *LPWKSTA_INFO_1041;

typedef struct _WKSTA_INFO_1042 {
    DWORD   wki1042_lock_increment;
} WKSTA_INFO_1042, *PWKSTA_INFO_1042, *LPWKSTA_INFO_1042;

typedef struct _WKSTA_INFO_1043 {
    DWORD   wki1043_lock_maximum;
} WKSTA_INFO_1043, *PWKSTA_INFO_1043, *LPWKSTA_INFO_1043;

typedef struct _WKSTA_INFO_1044 {
    DWORD   wki1044_pipe_increment;
} WKSTA_INFO_1044, *PWKSTA_INFO_1044, *LPWKSTA_INFO_1044;

typedef struct _WKSTA_INFO_1045 {
    DWORD   wki1045_pipe_maximum;
} WKSTA_INFO_1045, *PWKSTA_INFO_1045, *LPWKSTA_INFO_1045;

typedef struct _WKSTA_INFO_1046 {
    DWORD   wki1046_dormant_file_limit;
} WKSTA_INFO_1046, *PWKSTA_INFO_1046, *LPWKSTA_INFO_1046;

typedef struct _WKSTA_INFO_1047 {
    DWORD    wki1047_cache_file_timeout;
} WKSTA_INFO_1047, *PWKSTA_INFO_1047, *LPWKSTA_INFO_1047;

typedef struct _WKSTA_INFO_1048 {
    BOOL     wki1048_use_opportunistic_locking;
} WKSTA_INFO_1048, *PWKSTA_INFO_1048, *LPWKSTA_INFO_1048;

typedef struct _WKSTA_INFO_1049 {
    BOOL     wki1049_use_unlock_behind;
} WKSTA_INFO_1049, *PWKSTA_INFO_1049, *LPWKSTA_INFO_1049;

typedef struct _WKSTA_INFO_1050 {
    BOOL     wki1050_use_close_behind;
} WKSTA_INFO_1050, *PWKSTA_INFO_1050, *LPWKSTA_INFO_1050;

typedef struct _WKSTA_INFO_1051 {
    BOOL     wki1051_buf_named_pipes;
} WKSTA_INFO_1051, *PWKSTA_INFO_1051, *LPWKSTA_INFO_1051;

typedef struct _WKSTA_INFO_1052 {
    BOOL     wki1052_use_lock_read_unlock;
} WKSTA_INFO_1052, *PWKSTA_INFO_1052, *LPWKSTA_INFO_1052;

typedef struct _WKSTA_INFO_1053 {
    BOOL     wki1053_utilize_nt_caching;
} WKSTA_INFO_1053, *PWKSTA_INFO_1053, *LPWKSTA_INFO_1053;

typedef struct _WKSTA_INFO_1054 {
    BOOL     wki1054_use_raw_read;
} WKSTA_INFO_1054, *PWKSTA_INFO_1054, *LPWKSTA_INFO_1054;

typedef struct _WKSTA_INFO_1055 {
    BOOL     wki1055_use_raw_write;
} WKSTA_INFO_1055, *PWKSTA_INFO_1055, *LPWKSTA_INFO_1055;

typedef struct _WKSTA_INFO_1056 {
    BOOL     wki1056_use_write_raw_data;
} WKSTA_INFO_1056, *PWKSTA_INFO_1056, *LPWKSTA_INFO_1056;

typedef struct _WKSTA_INFO_1057 {
    BOOL     wki1057_use_encryption;
} WKSTA_INFO_1057, *PWKSTA_INFO_1057, *LPWKSTA_INFO_1057;

typedef struct _WKSTA_INFO_1058 {
    BOOL     wki1058_buf_files_deny_write;
} WKSTA_INFO_1058, *PWKSTA_INFO_1058, *LPWKSTA_INFO_1058;

typedef struct _WKSTA_INFO_1059 {
    BOOL     wki1059_buf_read_only_files;
} WKSTA_INFO_1059, *PWKSTA_INFO_1059, *LPWKSTA_INFO_1059;

typedef struct _WKSTA_INFO_1060 {
    BOOL     wki1060_force_core_create_mode;
} WKSTA_INFO_1060, *PWKSTA_INFO_1060, *LPWKSTA_INFO_1060;

typedef struct _WKSTA_INFO_1061 {
    BOOL     wki1061_use_512_byte_max_transfer;
} WKSTA_INFO_1061, *PWKSTA_INFO_1061, *LPWKSTA_INFO_1061;

typedef struct _WKSTA_INFO_1062 {
    DWORD   wki1062_read_ahead_throughput;
} WKSTA_INFO_1062, *PWKSTA_INFO_1062, *LPWKSTA_INFO_1062;


//
// NetWkstaUserGetInfo (local only) and NetWkstaUserEnum -
//     no access restrictions.
//
typedef struct _WKSTA_USER_INFO_0 {
    LMSTR   wkui0_username;
}WKSTA_USER_INFO_0, *PWKSTA_USER_INFO_0, *LPWKSTA_USER_INFO_0;

//
// NetWkstaUserGetInfo (local only) and NetWkstaUserEnum -
//     no access restrictions.
//
typedef struct _WKSTA_USER_INFO_1 {
    LMSTR   wkui1_username;
    LMSTR   wkui1_logon_domain;
    LMSTR   wkui1_oth_domains;
    LMSTR   wkui1_logon_server;
}WKSTA_USER_INFO_1, *PWKSTA_USER_INFO_1, *LPWKSTA_USER_INFO_1;

//
// NetWkstaUserSetInfo - local access.
//
typedef struct _WKSTA_USER_INFO_1101 {
     LMSTR   wkui1101_oth_domains;
} WKSTA_USER_INFO_1101, *PWKSTA_USER_INFO_1101,
  *LPWKSTA_USER_INFO_1101;


//
// NetWkstaTransportAdd - admin access
//
typedef struct _WKSTA_TRANSPORT_INFO_0 {
    DWORD   wkti0_quality_of_service;
    DWORD   wkti0_number_of_vcs;
    LMSTR   wkti0_transport_name;
    LMSTR   wkti0_transport_address;
    BOOL    wkti0_wan_ish;
}WKSTA_TRANSPORT_INFO_0, *PWKSTA_TRANSPORT_INFO_0,
 *LPWKSTA_TRANSPORT_INFO_0;
 ]]

ffi.cdef[[
//
//  Data Structures
//

typedef struct _USE_INFO_0 {
    LMSTR   ui0_local;
    LMSTR   ui0_remote;
}USE_INFO_0, *PUSE_INFO_0, *LPUSE_INFO_0;

typedef struct _USE_INFO_1 {
    LMSTR   ui1_local;
    LMSTR   ui1_remote;
    LMSTR   ui1_password;
    DWORD   ui1_status;
    DWORD   ui1_asg_type;
    DWORD   ui1_refcount;
    DWORD   ui1_usecount;
}USE_INFO_1, *PUSE_INFO_1, *LPUSE_INFO_1;

typedef struct _USE_INFO_2 {
    LMSTR    ui2_local;
    LMSTR    ui2_remote;
    LMSTR    ui2_password;
    DWORD    ui2_status;
    DWORD    ui2_asg_type;
    DWORD    ui2_refcount;
    DWORD    ui2_usecount;
    LMSTR    ui2_username;
    LMSTR    ui2_domainname;
}USE_INFO_2, *PUSE_INFO_2, *LPUSE_INFO_2;

typedef struct _USE_INFO_3 {
    USE_INFO_2 ui3_ui2;
    ULONG      ui3_flags;
} USE_INFO_3, *PUSE_INFO_3, *LPUSE_INFO_3;

typedef struct _USE_INFO_4 {
    USE_INFO_3 ui4_ui3;
    DWORD      ui4_auth_identity_length;
    PBYTE      ui4_auth_identity;
} USE_INFO_4, *PUSE_INFO_4, *LPUSE_INFO_4;
]]

ffi.cdef[[
//
// Special Values and Constants
//

//
//  Identifiers for use as NetWkstaSetInfo parmnum parameter
//

//
// One of these values indicates the parameter within an information
// structure that is invalid when ERROR_INVALID_PARAMETER is returned by
// NetWkstaSetInfo.
//

static const int WKSTA_PLATFORM_ID_PARMNUM              = 100;
static const int WKSTA_COMPUTERNAME_PARMNUM             = 1;
static const int WKSTA_LANGROUP_PARMNUM                 = 2;
static const int WKSTA_VER_MAJOR_PARMNUM                = 4;
static const int WKSTA_VER_MINOR_PARMNUM                = 5;
static const int WKSTA_LOGGED_ON_USERS_PARMNUM          = 6;
static const int WKSTA_LANROOT_PARMNUM                  = 7;
static const int WKSTA_LOGON_DOMAIN_PARMNUM             = 8;
static const int WKSTA_LOGON_SERVER_PARMNUM             = 9;
static const int WKSTA_CHARWAIT_PARMNUM                 = 10;  // Supported by down-level.
static const int WKSTA_CHARTIME_PARMNUM                 = 11;  // Supported by down-level.
static const int WKSTA_CHARCOUNT_PARMNUM                = 12; // Supported by down-level.
static const int WKSTA_KEEPCONN_PARMNUM                 = 13;
static const int WKSTA_KEEPSEARCH_PARMNUM               = 14;
static const int WKSTA_MAXCMDS_PARMNUM                  = 15;
static const int WKSTA_NUMWORKBUF_PARMNUM               = 16;
static const int WKSTA_MAXWRKCACHE_PARMNUM              = 17;
static const int WKSTA_SESSTIMEOUT_PARMNUM              = 18;
static const int WKSTA_SIZERROR_PARMNUM                 = 19;
static const int WKSTA_NUMALERTS_PARMNUM                = 20;
static const int WKSTA_NUMSERVICES_PARMNUM              = 21;
static const int WKSTA_NUMCHARBUF_PARMNUM               = 22;
static const int WKSTA_SIZCHARBUF_PARMNUM               = 23;
static const int WKSTA_ERRLOGSZ_PARMNUM                 = 27;  // Supported by down-level.
static const int WKSTA_PRINTBUFTIME_PARMNUM             = 28; // Supported by down-level.
static const int WKSTA_SIZWORKBUF_PARMNUM               = 29;
static const int WKSTA_MAILSLOTS_PARMNUM                = 30;
static const int WKSTA_NUMDGRAMBUF_PARMNUM              = 31;
static const int WKSTA_WRKHEURISTICS_PARMNUM            = 32;  // Supported by down-level.
static const int WKSTA_MAXTHREADS_PARMNUM               = 33;

static const int WKSTA_LOCKQUOTA_PARMNUM                = 41;
static const int WKSTA_LOCKINCREMENT_PARMNUM            = 42;
static const int WKSTA_LOCKMAXIMUM_PARMNUM              = 43;
static const int WKSTA_PIPEINCREMENT_PARMNUM            = 44;
static const int WKSTA_PIPEMAXIMUM_PARMNUM              = 45;
static const int WKSTA_DORMANTFILELIMIT_PARMNUM         = 46;
static const int WKSTA_CACHEFILETIMEOUT_PARMNUM         = 47;
static const int WKSTA_USEOPPORTUNISTICLOCKING_PARMNUM  = 48;
static const int WKSTA_USEUNLOCKBEHIND_PARMNUM          = 49;
static const int WKSTA_USECLOSEBEHIND_PARMNUM           = 50;
static const int WKSTA_BUFFERNAMEDPIPES_PARMNUM         = 51;
static const int WKSTA_USELOCKANDREADANDUNLOCK_PARMNUM  = 52;
static const int WKSTA_UTILIZENTCACHING_PARMNUM         = 53;
static const int WKSTA_USERAWREAD_PARMNUM               = 54;
static const int WKSTA_USERAWWRITE_PARMNUM              = 55;
static const int WKSTA_USEWRITERAWWITHDATA_PARMNUM      = 56;
static const int WKSTA_USEENCRYPTION_PARMNUM            = 57;
static const int WKSTA_BUFFILESWITHDENYWRITE_PARMNUM    = 58;
static const int WKSTA_BUFFERREADONLYFILES_PARMNUM      = 59;
static const int WKSTA_FORCECORECREATEMODE_PARMNUM      = 60;
static const int WKSTA_USE512BYTESMAXTRANSFER_PARMNUM   = 61;
static const int WKSTA_READAHEADTHRUPUT_PARMNUM         = 62;


//
// One of these values indicates the parameter within an information
// structure that is invalid when ERROR_INVALID_PARAMETER is returned by
// NetWkstaUserSetInfo.
//

static const int WKSTA_OTH_DOMAINS_PARMNUM             = 101;


//
// One of these values indicates the parameter within an information
// structure that is invalid when ERROR_INVALID_PARAMETER is returned by
// NetWkstaTransportAdd.
//

static const int TRANSPORT_QUALITYOFSERVICE_PARMNUM    = 201;
static const int TRANSPORT_NAME_PARMNUM                = 202;
]]

return {
  Lib = Lib,
  
NetAddAlternateComputerName = Lib.NetAddAlternateComputerName,
NetEnumerateComputerNames = Lib.NetEnumerateComputerNames,
NetGetJoinableOUs = Lib.NetGetJoinableOUs,
NetGetJoinInformation = Lib.NetGetJoinInformation,
NetJoinDomain = Lib.NetJoinDomain,
NetRemoveAlternateComputerName = Lib.NetRemoveAlternateComputerName,
NetRenameMachineInDomain = Lib.NetRenameMachineInDomain,
NetSetPrimaryComputerName = Lib.NetSetPrimaryComputerName,
NetUnjoinDomain = Lib.NetUnjoinDomain,
NetUseAdd = Lib.NetUseAdd,
NetUseDel = Lib.NetUseDel,
NetUseEnum = Lib.NetUseEnum,
NetUseGetInfo = Lib.NetUseGetInfo,
NetValidateName = Lib.NetValidateName,
NetWkstaGetInfo = Lib.NetWkstaGetInfo,
NetWkstaSetInfo = Lib.NetWkstaSetInfo,
--NetWkstaStatisticsGet = Lib.NetWkstaStatisticsGet,
NetWkstaTransportAdd = Lib.NetWkstaTransportAdd,
NetWkstaTransportDel = Lib.NetWkstaTransportDel,
NetWkstaTransportEnum = Lib.NetWkstaTransportEnum,
NetWkstaUserEnum = Lib.NetWkstaUserEnum,
NetWkstaUserGetInfo = Lib.NetWkstaUserGetInfo,
NetWkstaUserSetInfo = Lib.NetWkstaUserSetInfo,
}
