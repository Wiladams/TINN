-- samcli.lua	
-- samcli.dll

local ffi = require("ffi");
local WTypes = require("WTypes");
local WinNT = require("WinNT");

local core_string = require("core_string_l1_1_0");
local lmcons = require("lmcons");

local L = core_string.toUnicode;
local Lib = ffi.load("NetApi32");

local samcli = {}

ffi.cdef[[
//typedef uintptr_t       ULONG_PTR;
typedef unsigned long   ULONG_PTR;
typedef ULONG_PTR       DWORD_PTR, *PDWORD_PTR;
]]

ffi.cdef[[
//
//  Data Structures - Group
//

typedef struct _GROUP_INFO_0 {
    LPWSTR   grpi0_name;
}GROUP_INFO_0, *PGROUP_INFO_0, *LPGROUP_INFO_0;

typedef struct _GROUP_INFO_1 {
    LPWSTR   grpi1_name;
    LPWSTR   grpi1_comment;
}GROUP_INFO_1, *PGROUP_INFO_1, *LPGROUP_INFO_1;

typedef struct _GROUP_INFO_2 {
    LPWSTR   grpi2_name;
    LPWSTR   grpi2_comment;
    DWORD    grpi2_group_id;
    DWORD    grpi2_attributes;
}GROUP_INFO_2, *PGROUP_INFO_2;

typedef struct _GROUP_INFO_3 {
    LPWSTR   grpi3_name;
    LPWSTR   grpi3_comment;
    PSID     grpi3_group_sid;
    DWORD    grpi3_attributes;
}GROUP_INFO_3, *PGROUP_INFO_3;

typedef struct _GROUP_INFO_1002 {
     LPWSTR  grpi1002_comment;
} GROUP_INFO_1002, *PGROUP_INFO_1002, *LPGROUP_INFO_1002;

typedef struct _GROUP_INFO_1005 {
     DWORD  grpi1005_attributes;
} GROUP_INFO_1005, *PGROUP_INFO_1005, *LPGROUP_INFO_1005;


typedef struct _GROUP_USERS_INFO_0 {
     LPWSTR  grui0_name;
} GROUP_USERS_INFO_0, *PGROUP_USERS_INFO_0, *LPGROUP_USERS_INFO_0;

typedef struct _GROUP_USERS_INFO_1 {
     LPWSTR  grui1_name;
     DWORD   grui1_attributes;
} GROUP_USERS_INFO_1, *PGROUP_USERS_INFO_1, *LPGROUP_USERS_INFO_1;

//
// Special Values and Constants - Group
//

static const int GROUPIDMASK               =  0x8000;      // MSB set if uid refers
                                                // to a group
]]

--[[
//
// Predefined group for all normal users, administrators and guests
// LOCAL is a special group for pinball local security.
//
--]]

samcli.GROUP_SPECIALGRP_USERS     = L"USERS";
samcli.GROUP_SPECIALGRP_ADMINS    = L"ADMINS";
samcli.GROUP_SPECIALGRP_GUESTS    = L"GUESTS";
samcli.GROUP_SPECIALGRP_LOCAL     = L"LOCAL";

ffi.cdef[[
//
// parmnum manifests for SetInfo calls (only comment is settable)
//

static const int GROUP_ALL_PARMNUM          = 0;
static const int GROUP_NAME_PARMNUM         = 1;
static const int GROUP_COMMENT_PARMNUM      = 2;
static const int GROUP_ATTRIBUTES_PARMNUM   = 3;
]]

ffi.cdef[[
//
// the new infolevel counterparts of the old info level + parmnum
//

static const int GROUP_ALL_INFOLEVEL         =    \
            (PARMNUM_BASE_INFOLEVEL + GROUP_ALL_PARMNUM);
static const int GROUP_NAME_INFOLEVEL        =    \
            (PARMNUM_BASE_INFOLEVEL + GROUP_NAME_PARMNUM);
static const int GROUP_COMMENT_INFOLEVEL     =    \
            (PARMNUM_BASE_INFOLEVEL + GROUP_COMMENT_PARMNUM);
static const int GROUP_ATTRIBUTES_INFOLEVEL  =    \
            (PARMNUM_BASE_INFOLEVEL + GROUP_ATTRIBUTES_PARMNUM);
]]

-- BUGBUG
-- GROUP_POSIX_ID_PARMNUM, doesn't seem to be defined
-- static const int GROUP_POSIX_ID_INFOLEVEL    =    (PARMNUM_BASE_INFOLEVEL + GROUP_POSIX_ID_PARMNUM);


ffi.cdef[[
NET_API_STATUS
NetGetDisplayInformationIndex(
     LPCWSTR ServerName ,
     DWORD Level,
     LPCWSTR Prefix,
     LPDWORD Index );

NET_API_STATUS
NetGroupAdd (
      LPCWSTR   servername ,
      DWORD    level,
      LPBYTE   buf,
     LPDWORD  parm_err 
    );

NET_API_STATUS
NetGroupAddUser (
      LPCWSTR   servername ,
      LPCWSTR   GroupName,
      LPCWSTR   username
    );

NET_API_STATUS
NetGroupDel (
      LPCWSTR   servername ,
      LPCWSTR   groupname
    );

NET_API_STATUS
NetGroupDelUser (
      LPCWSTR   servername ,
      LPCWSTR   GroupName,
      LPCWSTR   Username
    );

NET_API_STATUS
NetGroupEnum (
      LPCWSTR      servername ,
      DWORD       level,
     LPBYTE      *bufptr,
      DWORD       prefmaxlen,
     LPDWORD     entriesread,
     LPDWORD     totalentries,
      PDWORD_PTR resume_handle 
    );

NET_API_STATUS
NetGroupGetInfo (
      LPCWSTR   servername ,
      LPCWSTR   groupname,
      DWORD    level,
     LPBYTE   *bufptr
    );

NET_API_STATUS
NetGroupGetUsers (
      LPCWSTR     servername ,
      LPCWSTR     groupname,
      DWORD      level,
     LPBYTE     *bufptr,
      DWORD      prefmaxlen,
     LPDWORD    entriesread,
     LPDWORD    totalentries,
      PDWORD_PTR ResumeHandle
    );

NET_API_STATUS
NetGroupSetInfo (
      LPCWSTR   servername ,
      LPCWSTR   groupname,
      DWORD    level,
      LPBYTE   buf,
     LPDWORD  parm_err 
    );

NET_API_STATUS
NetGroupSetUsers (
      LPCWSTR     servername ,
      LPCWSTR     groupname,
      DWORD      level,
      LPBYTE     buf,
      DWORD      totalentries
    );
]]

ffi.cdef[[

//
// Function Prototypes
//

NET_API_STATUS
NetLocalGroupAdd (
      LPCWSTR   servername ,
      DWORD    level,
      LPBYTE   buf,
     LPDWORD  parm_err 
    );

NET_API_STATUS
NetLocalGroupAddMember (
      LPCWSTR   servername ,
      LPCWSTR   groupname,
      PSID     membersid
    );

NET_API_STATUS
NetLocalGroupEnum (
    LPCWSTR     servername ,
    DWORD       level,
    LPBYTE      *bufptr,
    DWORD       prefmaxlen,
    LPDWORD     entriesread,
    LPDWORD     totalentries,
    LPDWORD resumehandle);
//      DWORD_PTR * resumehandle 

NET_API_STATUS
NetLocalGroupGetInfo (
      LPCWSTR   servername ,
      LPCWSTR   groupname,
      DWORD    level,
     LPBYTE   *bufptr
    );

NET_API_STATUS
NetLocalGroupSetInfo (
      LPCWSTR   servername ,
      LPCWSTR   groupname,
      DWORD    level,
      LPBYTE   buf,
     LPDWORD  parm_err 
    );

NET_API_STATUS
NetLocalGroupDel (
      LPCWSTR   servername ,
      LPCWSTR   groupname
    );

NET_API_STATUS
NetLocalGroupDelMember (
      LPCWSTR   servername ,
      LPCWSTR   groupname,
      PSID     membersid
    );

NET_API_STATUS
NetLocalGroupGetMembers (
      LPCWSTR     servername ,
      LPCWSTR     localgroupname,
      DWORD      level,
     LPBYTE     *bufptr,
      DWORD      prefmaxlen,
     LPDWORD    entriesread,
     LPDWORD    totalentries,
      PDWORD_PTR resumehandle
    );

NET_API_STATUS
NetLocalGroupSetMembers (
      LPCWSTR     servername ,
      LPCWSTR     groupname,
      DWORD      level,
      LPBYTE     buf,
      DWORD      totalentries
    );

NET_API_STATUS
NetLocalGroupAddMembers (
      LPCWSTR     servername ,
      LPCWSTR     groupname,
      DWORD      level,
      LPBYTE     buf,
      DWORD      totalentries
    );

NET_API_STATUS
NetLocalGroupDelMembers (
      LPCWSTR     servername ,
      LPCWSTR     groupname,
      DWORD      level,
      LPBYTE     buf,
      DWORD      totalentries
    );

//
//  Data Structures - LocalGroup
//

typedef struct _LOCALGROUP_INFO_0 {
    LPWSTR   lgrpi0_name;
}LOCALGROUP_INFO_0, *PLOCALGROUP_INFO_0, *LPLOCALGROUP_INFO_0;

typedef struct _LOCALGROUP_INFO_1 {
    LPWSTR   lgrpi1_name;
    LPWSTR   lgrpi1_comment;
}LOCALGROUP_INFO_1, *PLOCALGROUP_INFO_1, *LPLOCALGROUP_INFO_1;

typedef struct _LOCALGROUP_INFO_1002 {
     LPWSTR  lgrpi1002_comment;
}LOCALGROUP_INFO_1002, *PLOCALGROUP_INFO_1002, *LPLOCALGROUP_INFO_1002;

typedef struct _LOCALGROUP_MEMBERS_INFO_0 {
     PSID    lgrmi0_sid;
} LOCALGROUP_MEMBERS_INFO_0, *PLOCALGROUP_MEMBERS_INFO_0,
  *LPLOCALGROUP_MEMBERS_INFO_0;

typedef struct _LOCALGROUP_MEMBERS_INFO_1 {
     PSID         lgrmi1_sid;
     SID_NAME_USE lgrmi1_sidusage;
     LPWSTR       lgrmi1_name;
} LOCALGROUP_MEMBERS_INFO_1, *PLOCALGROUP_MEMBERS_INFO_1,
  *LPLOCALGROUP_MEMBERS_INFO_1;

typedef struct _LOCALGROUP_MEMBERS_INFO_2 {
     PSID         lgrmi2_sid;
     SID_NAME_USE lgrmi2_sidusage;
     LPWSTR       lgrmi2_domainandname;
} LOCALGROUP_MEMBERS_INFO_2, *PLOCALGROUP_MEMBERS_INFO_2,
  *LPLOCALGROUP_MEMBERS_INFO_2;

typedef struct _LOCALGROUP_MEMBERS_INFO_3 {
     LPWSTR       lgrmi3_domainandname;
} LOCALGROUP_MEMBERS_INFO_3, *PLOCALGROUP_MEMBERS_INFO_3,
  *LPLOCALGROUP_MEMBERS_INFO_3;

typedef struct _LOCALGROUP_USERS_INFO_0 {
     LPWSTR  lgrui0_name;
} LOCALGROUP_USERS_INFO_0, *PLOCALGROUP_USERS_INFO_0,
  *LPLOCALGROUP_USERS_INFO_0;


static const int LOCALGROUP_NAME_PARMNUM         = 1;
static const int LOCALGROUP_COMMENT_PARMNUM      = 2;

//
// Display Information APIs
//

NET_API_STATUS
NetQueryDisplayInformation(
     LPCWSTR ServerName ,
     DWORD Level,
     DWORD Index,
     DWORD EntriesRequested,
     DWORD PreferredMaximumLength,
     LPDWORD ReturnedEntryCount,
     PVOID   *SortedBuffer );

NET_API_STATUS
NetGetDisplayInformationIndex(
     LPCWSTR ServerName ,
     DWORD Level,
     LPCWSTR Prefix,
     LPDWORD Index );

//
// QueryDisplayInformation levels

typedef struct _NET_DISPLAY_USER {
    LPWSTR   usri1_name;
    LPWSTR   usri1_comment;
    DWORD    usri1_flags;
    LPWSTR   usri1_full_name;
    DWORD    usri1_user_id;
    DWORD    usri1_next_index;
} NET_DISPLAY_USER, *PNET_DISPLAY_USER;

typedef struct _NET_DISPLAY_MACHINE {
    LPWSTR   usri2_name;
    LPWSTR   usri2_comment;
    DWORD    usri2_flags;
    DWORD    usri2_user_id;
    DWORD    usri2_next_index;
} NET_DISPLAY_MACHINE, *PNET_DISPLAY_MACHINE;

typedef struct _NET_DISPLAY_GROUP {
    LPWSTR   grpi3_name;
    LPWSTR   grpi3_comment;
    DWORD    grpi3_group_id;
    DWORD    grpi3_attributes;
    DWORD    grpi3_next_index;
} NET_DISPLAY_GROUP, *PNET_DISPLAY_GROUP;

]]

ffi.cdef[[
//
// Function Prototypes - User
//

NET_API_STATUS
NetUserAdd (
      LPCWSTR     servername ,
      DWORD      level,
      LPBYTE     buf,
     LPDWORD    parm_err 
    );

NET_API_STATUS
NetUserEnum (
      LPCWSTR     servername ,
      DWORD      level,
      DWORD      filter,
     LPBYTE     *bufptr,
      DWORD      prefmaxlen,
     LPDWORD    entriesread,
     LPDWORD    totalentries,
      LPDWORD resume_handle 
    );

NET_API_STATUS
NetUserGetInfo (
      LPCWSTR     servername ,
      LPCWSTR     username,
      DWORD      level,
     LPBYTE     *bufptr
    );

NET_API_STATUS
NetUserSetInfo (
      LPCWSTR    servername ,
      LPCWSTR    username,
      DWORD     level,
      LPBYTE    buf,
     LPDWORD   parm_err 
    );

NET_API_STATUS
NetUserDel (
      LPCWSTR    servername ,
      LPCWSTR    username
    );

NET_API_STATUS
NetUserGetGroups (
      LPCWSTR    servername ,
      LPCWSTR    username,
      DWORD     level,
     LPBYTE    *bufptr,
      DWORD     prefmaxlen,
     LPDWORD   entriesread,
     LPDWORD   totalentries
    );

NET_API_STATUS
NetUserSetGroups (
      LPCWSTR    servername ,
      LPCWSTR    username,
      DWORD     level,
      LPBYTE    buf,
      DWORD     num_entries
    );

NET_API_STATUS
NetUserGetLocalGroups (
      LPCWSTR    servername ,
      LPCWSTR    username,
      DWORD     level,
      DWORD     flags,
     LPBYTE    *bufptr,
      DWORD     prefmaxlen,
     LPDWORD   entriesread,
     LPDWORD   totalentries
    );

NET_API_STATUS
NetUserModalsGet (
      LPCWSTR    servername ,
      DWORD     level,
     LPBYTE    *bufptr
    );

NET_API_STATUS
NetUserModalsSet (
      LPCWSTR    servername ,
      DWORD     level,
      LPBYTE    buf,
     LPDWORD   parm_err 
    );

NET_API_STATUS
NetUserChangePassword (
    LPCWSTR   domainname ,
    LPCWSTR   username ,
    LPCWSTR   oldpassword,
    LPCWSTR   newpassword
    );


//
//  Data Structures - User
//

typedef struct _USER_INFO_0 {
    LPWSTR   usri0_name;
}USER_INFO_0, *PUSER_INFO_0, *LPUSER_INFO_0;

typedef struct _USER_INFO_1 {
    LPWSTR   usri1_name;
    LPWSTR   usri1_password;
    DWORD    usri1_password_age;
    DWORD    usri1_priv;
    LPWSTR   usri1_home_dir;
    LPWSTR   usri1_comment;
    DWORD    usri1_flags;
    LPWSTR   usri1_script_path;
}USER_INFO_1, *PUSER_INFO_1, *LPUSER_INFO_1;

typedef struct _USER_INFO_2 {
    LPWSTR   usri2_name;
    LPWSTR   usri2_password;
    DWORD    usri2_password_age;
    DWORD    usri2_priv;
    LPWSTR   usri2_home_dir;
    LPWSTR   usri2_comment;
    DWORD    usri2_flags;
    LPWSTR   usri2_script_path;
    DWORD    usri2_auth_flags;
    LPWSTR   usri2_full_name;
    LPWSTR   usri2_usr_comment;
    LPWSTR   usri2_parms;
    LPWSTR   usri2_workstations;
    DWORD    usri2_last_logon;
    DWORD    usri2_last_logoff;
    DWORD    usri2_acct_expires;
    DWORD    usri2_max_storage;
    DWORD    usri2_units_per_week;
    PBYTE    usri2_logon_hours;
    DWORD    usri2_bad_pw_count;
    DWORD    usri2_num_logons;
    LPWSTR   usri2_logon_server;
    DWORD    usri2_country_code;
    DWORD    usri2_code_page;
}USER_INFO_2, *PUSER_INFO_2, *LPUSER_INFO_2;

typedef struct _USER_INFO_3 {
    LPWSTR   usri3_name;
    LPWSTR   usri3_password;
    DWORD    usri3_password_age;
    DWORD    usri3_priv;
    LPWSTR   usri3_home_dir;
    LPWSTR   usri3_comment;
    DWORD    usri3_flags;
    LPWSTR   usri3_script_path;
    DWORD    usri3_auth_flags;
    LPWSTR   usri3_full_name;
    LPWSTR   usri3_usr_comment;
    LPWSTR   usri3_parms;
    LPWSTR   usri3_workstations;
    DWORD    usri3_last_logon;
    DWORD    usri3_last_logoff;
    DWORD    usri3_acct_expires;
    DWORD    usri3_max_storage;
    DWORD    usri3_units_per_week;
    PBYTE    usri3_logon_hours;
    DWORD    usri3_bad_pw_count;
    DWORD    usri3_num_logons;
    LPWSTR   usri3_logon_server;
    DWORD    usri3_country_code;
    DWORD    usri3_code_page;
    DWORD    usri3_user_id;
    DWORD    usri3_primary_group_id;
    LPWSTR   usri3_profile;
    LPWSTR   usri3_home_dir_drive;
    DWORD    usri3_password_expired;
}USER_INFO_3, *PUSER_INFO_3, *LPUSER_INFO_3;

typedef struct _USER_INFO_4 {
    LPWSTR   usri4_name;
    LPWSTR   usri4_password;
    DWORD    usri4_password_age;
    DWORD    usri4_priv;
    LPWSTR   usri4_home_dir;
    LPWSTR   usri4_comment;
    DWORD    usri4_flags;
    LPWSTR   usri4_script_path;
    DWORD    usri4_auth_flags;
    LPWSTR   usri4_full_name;
    LPWSTR   usri4_usr_comment;
    LPWSTR   usri4_parms;
    LPWSTR   usri4_workstations;
    DWORD    usri4_last_logon;
    DWORD    usri4_last_logoff;
    DWORD    usri4_acct_expires;
    DWORD    usri4_max_storage;
    DWORD    usri4_units_per_week;
    PBYTE    usri4_logon_hours;
    DWORD    usri4_bad_pw_count;
    DWORD    usri4_num_logons;
    LPWSTR   usri4_logon_server;
    DWORD    usri4_country_code;
    DWORD    usri4_code_page;
    PSID     usri4_user_sid;
    DWORD    usri4_primary_group_id;
    LPWSTR   usri4_profile;
    LPWSTR   usri4_home_dir_drive;
    DWORD    usri4_password_expired;
}USER_INFO_4, *PUSER_INFO_4, *LPUSER_INFO_4;

typedef struct _USER_INFO_10 {
    LPWSTR   usri10_name;
    LPWSTR   usri10_comment;
    LPWSTR   usri10_usr_comment;
    LPWSTR   usri10_full_name;
}USER_INFO_10, *PUSER_INFO_10, *LPUSER_INFO_10;

typedef struct _USER_INFO_11 {
    LPWSTR   usri11_name;
    LPWSTR   usri11_comment;
    LPWSTR   usri11_usr_comment;
    LPWSTR   usri11_full_name;
    DWORD    usri11_priv;
    DWORD    usri11_auth_flags;
    DWORD    usri11_password_age;
    LPWSTR   usri11_home_dir;
    LPWSTR   usri11_parms;
    DWORD    usri11_last_logon;
    DWORD    usri11_last_logoff;
    DWORD    usri11_bad_pw_count;
    DWORD    usri11_num_logons;
    LPWSTR   usri11_logon_server;
    DWORD    usri11_country_code;
    LPWSTR   usri11_workstations;
    DWORD    usri11_max_storage;
    DWORD    usri11_units_per_week;
    PBYTE    usri11_logon_hours;
    DWORD    usri11_code_page;
}USER_INFO_11, *PUSER_INFO_11, *LPUSER_INFO_11;

typedef struct _USER_INFO_20 {
    LPWSTR   usri20_name;
    LPWSTR   usri20_full_name;
    LPWSTR   usri20_comment;
    DWORD    usri20_flags;
    DWORD    usri20_user_id;
}USER_INFO_20, *PUSER_INFO_20, *LPUSER_INFO_20;

typedef struct _USER_INFO_21 {
    BYTE     usri21_password[ENCRYPTED_PWLEN];
}USER_INFO_21, *PUSER_INFO_21, *LPUSER_INFO_21;

typedef struct _USER_INFO_22 {
    LPWSTR   usri22_name;
    BYTE     usri22_password[ENCRYPTED_PWLEN];
    DWORD    usri22_password_age;
    DWORD    usri22_priv;
    LPWSTR   usri22_home_dir;
    LPWSTR   usri22_comment;
    DWORD    usri22_flags;
    LPWSTR   usri22_script_path;
    DWORD    usri22_auth_flags;
    LPWSTR   usri22_full_name;
    LPWSTR   usri22_usr_comment;
    LPWSTR   usri22_parms;
    LPWSTR   usri22_workstations;
    DWORD    usri22_last_logon;
    DWORD    usri22_last_logoff;
    DWORD    usri22_acct_expires;
    DWORD    usri22_max_storage;
    DWORD    usri22_units_per_week;
    PBYTE    usri22_logon_hours;
    DWORD    usri22_bad_pw_count;
    DWORD    usri22_num_logons;
    LPWSTR   usri22_logon_server;
    DWORD    usri22_country_code;
    DWORD    usri22_code_page;
}USER_INFO_22, *PUSER_INFO_22, *LPUSER_INFO_22;

typedef struct _USER_INFO_23 {
    LPWSTR   usri23_name;
    LPWSTR   usri23_full_name;
    LPWSTR   usri23_comment;
    DWORD    usri23_flags;
    PSID     usri23_user_sid;
}USER_INFO_23, *PUSER_INFO_23, *LPUSER_INFO_23;

typedef struct _USER_INFO_1003 {
     LPWSTR  usri1003_password;
} USER_INFO_1003, *PUSER_INFO_1003, *LPUSER_INFO_1003;

typedef struct _USER_INFO_1005 {
     DWORD   usri1005_priv;
} USER_INFO_1005, *PUSER_INFO_1005, *LPUSER_INFO_1005;

typedef struct _USER_INFO_1006 {
     LPWSTR  usri1006_home_dir;
} USER_INFO_1006, *PUSER_INFO_1006, *LPUSER_INFO_1006;

typedef struct _USER_INFO_1007 {
     LPWSTR  usri1007_comment;
} USER_INFO_1007, *PUSER_INFO_1007, *LPUSER_INFO_1007;

typedef struct _USER_INFO_1008 {
     DWORD   usri1008_flags;
} USER_INFO_1008, *PUSER_INFO_1008, *LPUSER_INFO_1008;

typedef struct _USER_INFO_1009 {
     LPWSTR  usri1009_script_path;
} USER_INFO_1009, *PUSER_INFO_1009, *LPUSER_INFO_1009;

typedef struct _USER_INFO_1010 {
     DWORD   usri1010_auth_flags;
} USER_INFO_1010, *PUSER_INFO_1010, *LPUSER_INFO_1010;

typedef struct _USER_INFO_1011 {
     LPWSTR  usri1011_full_name;
} USER_INFO_1011, *PUSER_INFO_1011, *LPUSER_INFO_1011;

typedef struct _USER_INFO_1012 {
     LPWSTR  usri1012_usr_comment;
} USER_INFO_1012, *PUSER_INFO_1012, *LPUSER_INFO_1012;

typedef struct _USER_INFO_1013 {
     LPWSTR  usri1013_parms;
} USER_INFO_1013, *PUSER_INFO_1013, *LPUSER_INFO_1013;

typedef struct _USER_INFO_1014 {
     LPWSTR  usri1014_workstations;
} USER_INFO_1014, *PUSER_INFO_1014, *LPUSER_INFO_1014;

typedef struct _USER_INFO_1017 {
     DWORD   usri1017_acct_expires;
} USER_INFO_1017, *PUSER_INFO_1017, *LPUSER_INFO_1017;

typedef struct _USER_INFO_1018 {
     DWORD   usri1018_max_storage;
} USER_INFO_1018, *PUSER_INFO_1018, *LPUSER_INFO_1018;

typedef struct _USER_INFO_1020 {
    DWORD   usri1020_units_per_week;
    LPBYTE  usri1020_logon_hours;
} USER_INFO_1020, *PUSER_INFO_1020, *LPUSER_INFO_1020;

typedef struct _USER_INFO_1023 {
     LPWSTR  usri1023_logon_server;
} USER_INFO_1023, *PUSER_INFO_1023, *LPUSER_INFO_1023;

typedef struct _USER_INFO_1024 {
     DWORD   usri1024_country_code;
} USER_INFO_1024, *PUSER_INFO_1024, *LPUSER_INFO_1024;

typedef struct _USER_INFO_1025 {
     DWORD   usri1025_code_page;
} USER_INFO_1025, *PUSER_INFO_1025, *LPUSER_INFO_1025;

typedef struct _USER_INFO_1051 {
     DWORD   usri1051_primary_group_id;
} USER_INFO_1051, *PUSER_INFO_1051, *LPUSER_INFO_1051;

typedef struct _USER_INFO_1052 {
     LPWSTR  usri1052_profile;
} USER_INFO_1052, *PUSER_INFO_1052, *LPUSER_INFO_1052;

typedef struct _USER_INFO_1053 {
     LPWSTR  usri1053_home_dir_drive;
} USER_INFO_1053, *PUSER_INFO_1053, *LPUSER_INFO_1053;


//
//  Data Structures - User Modals
//

typedef struct _USER_MODALS_INFO_0 {
    DWORD    usrmod0_min_passwd_len;
    DWORD    usrmod0_max_passwd_age;
    DWORD    usrmod0_min_passwd_age;
    DWORD    usrmod0_force_logoff;
    DWORD    usrmod0_password_hist_len;
}USER_MODALS_INFO_0, *PUSER_MODALS_INFO_0, *LPUSER_MODALS_INFO_0;

typedef struct _USER_MODALS_INFO_1 {
    DWORD    usrmod1_role;
    LPWSTR   usrmod1_primary;
}USER_MODALS_INFO_1, *PUSER_MODALS_INFO_1, *LPUSER_MODALS_INFO_1;

typedef struct _USER_MODALS_INFO_2 {
    LPWSTR  usrmod2_domain_name;
    PSID    usrmod2_domain_id;
}USER_MODALS_INFO_2, *PUSER_MODALS_INFO_2, *LPUSER_MODALS_INFO_2;

typedef struct _USER_MODALS_INFO_3 {
    DWORD   usrmod3_lockout_duration;
    DWORD   usrmod3_lockout_observation_window;
    DWORD   usrmod3_lockout_threshold;
}USER_MODALS_INFO_3, *PUSER_MODALS_INFO_3, *LPUSER_MODALS_INFO_3;

typedef struct _USER_MODALS_INFO_1001 {
     DWORD   usrmod1001_min_passwd_len;
} USER_MODALS_INFO_1001, *PUSER_MODALS_INFO_1001, *LPUSER_MODALS_INFO_1001;

typedef struct _USER_MODALS_INFO_1002 {
     DWORD   usrmod1002_max_passwd_age;
} USER_MODALS_INFO_1002, *PUSER_MODALS_INFO_1002, *LPUSER_MODALS_INFO_1002;

typedef struct _USER_MODALS_INFO_1003 {
     DWORD   usrmod1003_min_passwd_age;
} USER_MODALS_INFO_1003, *PUSER_MODALS_INFO_1003, *LPUSER_MODALS_INFO_1003;

typedef struct _USER_MODALS_INFO_1004 {
     DWORD   usrmod1004_force_logoff;
} USER_MODALS_INFO_1004, *PUSER_MODALS_INFO_1004, *LPUSER_MODALS_INFO_1004;

typedef struct _USER_MODALS_INFO_1005 {
     DWORD   usrmod1005_password_hist_len;
} USER_MODALS_INFO_1005, *PUSER_MODALS_INFO_1005, *LPUSER_MODALS_INFO_1005;

typedef struct _USER_MODALS_INFO_1006 {
     DWORD   usrmod1006_role;
} USER_MODALS_INFO_1006, *PUSER_MODALS_INFO_1006, *LPUSER_MODALS_INFO_1006;

typedef struct _USER_MODALS_INFO_1007 {
     LPWSTR  usrmod1007_primary;
} USER_MODALS_INFO_1007, *PUSER_MODALS_INFO_1007, *LPUSER_MODALS_INFO_1007;
]]

ffi.cdef[[
//
// Special Values and Constants - User
//

//
//  Bit masks for field usriX_flags of USER_INFO_X (X = 0/1).
//

static const int UF_SCRIPT                          = 0x0001;
static const int UF_ACCOUNTDISABLE                  = 0x0002;
static const int UF_HOMEDIR_REQUIRED                = 0x0008;
static const int UF_LOCKOUT                         = 0x0010;
static const int UF_PASSWD_NOTREQD                  = 0x0020;
static const int UF_PASSWD_CANT_CHANGE              = 0x0040;
static const int UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED = 0x0080;

//
// Account type bits as part of usri_flags.
//

static const int UF_TEMP_DUPLICATE_ACCOUNT       = 0x0100;
static const int UF_NORMAL_ACCOUNT               = 0x0200;
static const int UF_INTERDOMAIN_TRUST_ACCOUNT    = 0x0800;
static const int UF_WORKSTATION_TRUST_ACCOUNT    = 0x1000;
static const int UF_SERVER_TRUST_ACCOUNT         = 0x2000;

static const int UF_MACHINE_ACCOUNT_MASK = ( UF_INTERDOMAIN_TRUST_ACCOUNT | \
                                  UF_WORKSTATION_TRUST_ACCOUNT | \
                                  UF_SERVER_TRUST_ACCOUNT );

static const int UF_ACCOUNT_TYPE_MASK      =   ( \
                    UF_TEMP_DUPLICATE_ACCOUNT | \
                    UF_NORMAL_ACCOUNT | \
                    UF_INTERDOMAIN_TRUST_ACCOUNT | \
                    UF_WORKSTATION_TRUST_ACCOUNT | \
                    UF_SERVER_TRUST_ACCOUNT \
                );


static const int UF_DONT_EXPIRE_PASSWD                      =   0x10000;
static const int UF_MNS_LOGON_ACCOUNT                       =   0x20000;
static const int UF_SMARTCARD_REQUIRED                      =   0x40000;
static const int UF_TRUSTED_FOR_DELEGATION                  =   0x80000;
static const int UF_NOT_DELEGATED                           =  0x100000;
static const int UF_USE_DES_KEY_ONLY                        =  0x200000;
static const int UF_DONT_REQUIRE_PREAUTH                    =  0x400000;
static const int UF_PASSWORD_EXPIRED                        =  0x800000;
static const int UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION  = 0x1000000;
static const int UF_NO_AUTH_DATA_REQUIRED                   = 0x2000000;
static const int UF_PARTIAL_SECRETS_ACCOUNT                 = 0x4000000;
static const int UF_USE_AES_KEYS                            = 0x8000000;

static const int UF_SETTABLE_BITS      =  ( \
                    UF_SCRIPT | \
                    UF_ACCOUNTDISABLE | \
                    UF_LOCKOUT | \
                    UF_HOMEDIR_REQUIRED  | \
                    UF_PASSWD_NOTREQD | \
                    UF_PASSWD_CANT_CHANGE | \
                    UF_ACCOUNT_TYPE_MASK | \
                    UF_DONT_EXPIRE_PASSWD | \
                    UF_MNS_LOGON_ACCOUNT |\
                    UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED |\
                    UF_SMARTCARD_REQUIRED | \
                    UF_TRUSTED_FOR_DELEGATION | \
                    UF_NOT_DELEGATED | \
                    UF_USE_DES_KEY_ONLY  | \
                    UF_DONT_REQUIRE_PREAUTH |\
                    UF_PASSWORD_EXPIRED |\
                    UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION |\
                    UF_NO_AUTH_DATA_REQUIRED |\
                    UF_USE_AES_KEYS |\
                    UF_PARTIAL_SECRETS_ACCOUNT \
                );

//
// bit masks for the NetUserEnum filter parameter.
//

static const int FILTER_TEMP_DUPLICATE_ACCOUNT     =  (0x0001);
static const int FILTER_NORMAL_ACCOUNT             =  (0x0002);
static const int FILTER_INTERDOMAIN_TRUST_ACCOUNT  =  (0x0008);
static const int FILTER_WORKSTATION_TRUST_ACCOUNT  =  (0x0010);
static const int FILTER_SERVER_TRUST_ACCOUNT       =  (0x0020);

//
// bit masks for the NetUserGetLocalGroups flags
//
static const int LG_INCLUDE_INDIRECT        = (0x0001);

//
//  Bit masks for field usri2_auth_flags of USER_INFO_2.
//

static const int AF_OP_PRINT            = 0x1;
static const int AF_OP_COMM             = 0x2;
static const int AF_OP_SERVER           = 0x4;
static const int AF_OP_ACCOUNTS         = 0x8;
static const int AF_SETTABLE_BITS       = (AF_OP_PRINT | AF_OP_COMM | \
                                AF_OP_SERVER | AF_OP_ACCOUNTS);

//
//  UAS role manifests under NETLOGON
//

static const int UAS_ROLE_STANDALONE    = 0;
static const int UAS_ROLE_MEMBER        = 1;
static const int UAS_ROLE_BACKUP        = 2;
static const int UAS_ROLE_PRIMARY       = 3;

//
//  Values for ParmError for NetUserSetInfo.
//

static const int USER_NAME_PARMNUM            =   1;
static const int USER_PASSWORD_PARMNUM        =   3;
static const int USER_PASSWORD_AGE_PARMNUM    =   4;
static const int USER_PRIV_PARMNUM            =   5;
static const int USER_HOME_DIR_PARMNUM        =   6;
static const int USER_COMMENT_PARMNUM         =   7;
static const int USER_FLAGS_PARMNUM           =   8;
static const int USER_SCRIPT_PATH_PARMNUM     =   9;
static const int USER_AUTH_FLAGS_PARMNUM      =   10;
static const int USER_FULL_NAME_PARMNUM       =   11;
static const int USER_USR_COMMENT_PARMNUM     =   12;
static const int USER_PARMS_PARMNUM           =   13;
static const int USER_WORKSTATIONS_PARMNUM    =   14;
static const int USER_LAST_LOGON_PARMNUM      =   15;
static const int USER_LAST_LOGOFF_PARMNUM     =   16;
static const int USER_ACCT_EXPIRES_PARMNUM    =   17;
static const int USER_MAX_STORAGE_PARMNUM     =   18;
static const int USER_UNITS_PER_WEEK_PARMNUM  =   19;
static const int USER_LOGON_HOURS_PARMNUM     =   20;
static const int USER_PAD_PW_COUNT_PARMNUM    =   21;
static const int USER_NUM_LOGONS_PARMNUM      =   22;
static const int USER_LOGON_SERVER_PARMNUM    =   23;
static const int USER_COUNTRY_CODE_PARMNUM    =   24;
static const int USER_CODE_PAGE_PARMNUM       =   25;
static const int USER_PRIMARY_GROUP_PARMNUM   =   51;
static const int USER_PROFILE_PARMNUM         =   52;
static const int USER_HOME_DIR_DRIVE_PARMNUM  =   53;

//
// the new infolevel counterparts of the old info level + parmnum
//

static const int USER_NAME_INFOLEVEL =            \
            (PARMNUM_BASE_INFOLEVEL + USER_NAME_PARMNUM);
static const int USER_PASSWORD_INFOLEVEL =        \
            (PARMNUM_BASE_INFOLEVEL + USER_PASSWORD_PARMNUM);
static const int USER_PASSWORD_AGE_INFOLEVEL =    \
            (PARMNUM_BASE_INFOLEVEL + USER_PASSWORD_AGE_PARMNUM);
static const int USER_PRIV_INFOLEVEL         =    \
            (PARMNUM_BASE_INFOLEVEL + USER_PRIV_PARMNUM);
static const int USER_HOME_DIR_INFOLEVEL     =    \
            (PARMNUM_BASE_INFOLEVEL + USER_HOME_DIR_PARMNUM);
static const int USER_COMMENT_INFOLEVEL      =    \
            (PARMNUM_BASE_INFOLEVEL + USER_COMMENT_PARMNUM);
static const int USER_FLAGS_INFOLEVEL        =    \
            (PARMNUM_BASE_INFOLEVEL + USER_FLAGS_PARMNUM);
static const int USER_SCRIPT_PATH_INFOLEVEL  =    \
            (PARMNUM_BASE_INFOLEVEL + USER_SCRIPT_PATH_PARMNUM);
static const int USER_AUTH_FLAGS_INFOLEVEL   =    \
            (PARMNUM_BASE_INFOLEVEL + USER_AUTH_FLAGS_PARMNUM);
static const int USER_FULL_NAME_INFOLEVEL    =    \
            (PARMNUM_BASE_INFOLEVEL + USER_FULL_NAME_PARMNUM);
static const int USER_USR_COMMENT_INFOLEVEL  =    \
            (PARMNUM_BASE_INFOLEVEL + USER_USR_COMMENT_PARMNUM);
static const int USER_PARMS_INFOLEVEL        =    \
            (PARMNUM_BASE_INFOLEVEL + USER_PARMS_PARMNUM);
static const int USER_WORKSTATIONS_INFOLEVEL =    \
            (PARMNUM_BASE_INFOLEVEL + USER_WORKSTATIONS_PARMNUM);
static const int USER_LAST_LOGON_INFOLEVEL   =    \
            (PARMNUM_BASE_INFOLEVEL + USER_LAST_LOGON_PARMNUM);
static const int USER_LAST_LOGOFF_INFOLEVEL  =    \
            (PARMNUM_BASE_INFOLEVEL + USER_LAST_LOGOFF_PARMNUM);
static const int USER_ACCT_EXPIRES_INFOLEVEL =    \
            (PARMNUM_BASE_INFOLEVEL + USER_ACCT_EXPIRES_PARMNUM);
static const int USER_MAX_STORAGE_INFOLEVEL  =    \
            (PARMNUM_BASE_INFOLEVEL + USER_MAX_STORAGE_PARMNUM);
static const int USER_UNITS_PER_WEEK_INFOLEVEL =  \
            (PARMNUM_BASE_INFOLEVEL + USER_UNITS_PER_WEEK_PARMNUM);
static const int USER_LOGON_HOURS_INFOLEVEL    =  \
            (PARMNUM_BASE_INFOLEVEL + USER_LOGON_HOURS_PARMNUM);
static const int USER_PAD_PW_COUNT_INFOLEVEL   =  \
            (PARMNUM_BASE_INFOLEVEL + USER_PAD_PW_COUNT_PARMNUM);
static const int USER_NUM_LOGONS_INFOLEVEL     =  \
            (PARMNUM_BASE_INFOLEVEL + USER_NUM_LOGONS_PARMNUM);
static const int USER_LOGON_SERVER_INFOLEVEL   =  \
            (PARMNUM_BASE_INFOLEVEL + USER_LOGON_SERVER_PARMNUM);
static const int USER_COUNTRY_CODE_INFOLEVEL   =  \
            (PARMNUM_BASE_INFOLEVEL + USER_COUNTRY_CODE_PARMNUM);
static const int USER_CODE_PAGE_INFOLEVEL      =  \
            (PARMNUM_BASE_INFOLEVEL + USER_CODE_PAGE_PARMNUM);
static const int USER_PRIMARY_GROUP_INFOLEVEL  =  \
            (PARMNUM_BASE_INFOLEVEL + USER_PRIMARY_GROUP_PARMNUM);
static const int USER_HOME_DIR_DRIVE_INFOLEVEL =        \
            (PARMNUM_BASE_INFOLEVEL + USER_HOME_DIR_DRIVE_PARMNUM);
]]

-- BUGBUG
-- USER_POSIX_ID_PARMNUM is bogus
-- static const int USER_POSIX_ID_INFOLEVEL         \
--            (PARMNUM_BASE_INFOLEVEL + USER_POSIX_ID_PARMNUM)

--[[
//
//  For SetInfo call (parmnum 0) when password change not required
//
--]]

samcli.NULL_USERSETINFO_PASSWD  =   "              ";   -- 13 space characters

ffi.cdef[[
static const int TIMEQ_FOREVER              = ((unsigned long) -1L);
static const int USER_MAXSTORAGE_UNLIMITED  = ((unsigned long) -1L);
static const int USER_NO_LOGOFF             = ((unsigned long) -1L);
static const int UNITS_PER_DAY              = 24;
static const int UNITS_PER_WEEK             = UNITS_PER_DAY * 7;

//
// Privilege levels (USER_INFO_X field usriX_priv (X = 0/1)).
//

static const int USER_PRIV_MASK    =  0x3;
static const int USER_PRIV_GUEST   =  0;
static const int USER_PRIV_USER    =  1;
static const int USER_PRIV_ADMIN   =  2;

//
// user modals related defaults
//

static const int MAX_PASSWD_LEN    =  PWLEN;
static const int DEF_MIN_PWLEN     =  6;
static const int DEF_PWUNIQUENESS  =  5;
static const int DEF_MAX_PWHIST    =  8;

static const int DEF_MAX_PWAGE     =  TIMEQ_FOREVER;               // forever
static const int DEF_MIN_PWAGE     =  (unsigned long) 0L;          // 0 days
static const int DEF_FORCE_LOGOFF  =  (unsigned long) 0xffffffff;  // never
static const int DEF_MAX_BADPW     =  0;                           // no limit
static const int ONE_DAY           =  (unsigned long) 01*24*3600;  // 01 day

//
// User Logon Validation (codes returned)
//

static const int VALIDATED_LOGON      =   0;
static const int PASSWORD_EXPIRED     =   2;
static const int NON_VALIDATED_LOGON  =   3;

static const int VALID_LOGOFF         =   1;

//
// parmnum manifests for user modals
//

static const int MODALS_MIN_PASSWD_LEN_PARMNUM      = 1;
static const int MODALS_MAX_PASSWD_AGE_PARMNUM      = 2;
static const int MODALS_MIN_PASSWD_AGE_PARMNUM      = 3;
static const int MODALS_FORCE_LOGOFF_PARMNUM        = 4;
static const int MODALS_PASSWD_HIST_LEN_PARMNUM     = 5;
static const int MODALS_ROLE_PARMNUM                = 6;
static const int MODALS_PRIMARY_PARMNUM             = 7;
static const int MODALS_DOMAIN_NAME_PARMNUM         = 8;
static const int MODALS_DOMAIN_ID_PARMNUM           = 9;
static const int MODALS_LOCKOUT_DURATION_PARMNUM    = 10;
static const int MODALS_LOCKOUT_OBSERVATION_WINDOW_PARMNUM =11;
static const int MODALS_LOCKOUT_THRESHOLD_PARMNUM   = 12;

//
// the new infolevel counterparts of the old info level + parmnum
//

static const int MODALS_MIN_PASSWD_LEN_INFOLEVEL   =  \
            (PARMNUM_BASE_INFOLEVEL + MODALS_MIN_PASSWD_LEN_PARMNUM);
static const int MODALS_MAX_PASSWD_AGE_INFOLEVEL   =  \
            (PARMNUM_BASE_INFOLEVEL + MODALS_MAX_PASSWD_AGE_PARMNUM);
static const int MODALS_MIN_PASSWD_AGE_INFOLEVEL   =  \
            (PARMNUM_BASE_INFOLEVEL + MODALS_MIN_PASSWD_AGE_PARMNUM);
static const int MODALS_FORCE_LOGOFF_INFOLEVEL     =  \
            (PARMNUM_BASE_INFOLEVEL + MODALS_FORCE_LOGOFF_PARMNUM);
static const int MODALS_PASSWD_HIST_LEN_INFOLEVEL  =  \
            (PARMNUM_BASE_INFOLEVEL + MODALS_PASSWD_HIST_LEN_PARMNUM);
static const int MODALS_ROLE_INFOLEVEL             =  \
            (PARMNUM_BASE_INFOLEVEL + MODALS_ROLE_PARMNUM);
static const int MODALS_PRIMARY_INFOLEVEL          =  \
            (PARMNUM_BASE_INFOLEVEL + MODALS_PRIMARY_PARMNUM);
static const int MODALS_DOMAIN_NAME_INFOLEVEL      =  \
            (PARMNUM_BASE_INFOLEVEL + MODALS_DOMAIN_NAME_PARMNUM);
static const int MODALS_DOMAIN_ID_INFOLEVEL        =  \
            (PARMNUM_BASE_INFOLEVEL + MODALS_DOMAIN_ID_PARMNUM);
]]


ffi.cdef[[
//
//    What kind of password checking is to be performed?
//        NetValidateAuthentication : Check if the authentication can be done
//        NetValidatePasswordChange: Check if the password can be changed
//        NetValidatePasswordReset: Reset the password to the given value
//
typedef enum _NET_VALIDATE_PASSWORD_TYPE{
    NetValidateAuthentication = 1,
    NetValidatePasswordChange,
    NetValidatePasswordReset
} NET_VALIDATE_PASSWORD_TYPE, *PNET_VALIDATE_PASSWORD_TYPE;

//
//    Structure to keep the password hash
//
typedef struct _NET_VALIDATE_PASSWORD_HASH{
    ULONG Length;
    LPBYTE Hash;
} NET_VALIDATE_PASSWORD_HASH, *PNET_VALIDATE_PASSWORD_HASH;

// To be used with PresentFields member of NET_VALIDATE_PERSISTED_FIELDS
static const int NET_VALIDATE_PASSWORD_LAST_SET        =  0x00000001;
static const int NET_VALIDATE_BAD_PASSWORD_TIME        =  0x00000002;
static const int NET_VALIDATE_LOCKOUT_TIME             =  0x00000004;
static const int NET_VALIDATE_BAD_PASSWORD_COUNT       =  0x00000008;
static const int NET_VALIDATE_PASSWORD_HISTORY_LENGTH  =  0x00000010;
static const int NET_VALIDATE_PASSWORD_HISTORY         =  0x00000020;

NET_API_STATUS
NetValidatePasswordPolicy(
     LPCWSTR ServerName,
     LPVOID Qualifier,
     NET_VALIDATE_PASSWORD_TYPE ValidationType,
     LPVOID InputArg,
     LPVOID *OutputArg
    );

NET_API_STATUS
NetValidatePasswordPolicyFree(
     LPVOID *OutputArg
    );
]]

samcli.Lib = Lib;
samcli.NetGetDisplayInformationIndex = Lib.NetGetDisplayInformationIndex;
samcli.NetGroupAdd = Lib.NetGroupAdd;
samcli.NetGroupAddUser = Lib.NetGroupAddUser;
samcli.NetGroupDel = Lib.NetGroupDel;
samcli.NetGroupDelUser = Lib.NetGroupDelUser;
samcli.NetGroupEnum = Lib.NetGroupEnum;
samcli.NetGroupGetInfo = Lib.NetGroupGetInfo;
samcli.NetGroupGetUsers = Lib.NetGroupGetUsers;
samcli.NetGroupSetInfo = Lib.NetGroupSetInfo;
samcli.NetGroupSetUsers = Lib.NetGroupSetUsers;
samcli.NetLocalGroupAdd = Lib.NetLocalGroupAdd;
samcli.NetLocalGroupAddMember = Lib.NetLocalGroupAddMember;
samcli.NetLocalGroupAddMembers = Lib.NetLocalGroupAddMembers;
samcli.NetLocalGroupDel = Lib.NetLocalGroupDel;
samcli.NetLocalGroupDelMember = Lib.NetLocalGroupDelMember;
samcli.NetLocalGroupDelMembers = Lib.NetLocalGroupDelMembers;
samcli.NetLocalGroupEnum = Lib.NetLocalGroupEnum;
samcli.NetLocalGroupGetInfo = Lib.NetLocalGroupGetInfo;
samcli.NetLocalGroupGetMembers = Lib.NetLocalGroupGetMembers;
samcli.NetLocalGroupSetInfo = Lib.NetLocalGroupSetInfo;
samcli.NetLocalGroupSetMembers = Lib.NetLocalGroupSetMembers;
samcli.NetQueryDisplayInformation = Lib.NetQueryDisplayInformation;
samcli.NetUserAdd = Lib.NetUserAdd;
samcli.NetUserChangePassword = Lib.NetUserChangePassword;
samcli.NetUserDel = Lib.NetUserDel;
samcli.NetUserEnum = Lib.NetUserEnum;
samcli.NetUserGetGroups = Lib.NetUserGetGroups;
samcli.NetUserGetInfo = Lib.NetUserGetInfo;
samcli.NetUserGetLocalGroups = Lib.NetUserGetLocalGroups;
samcli.NetUserModalsGet = Lib.NetUserModalsGet;
samcli.NetUserModalsSet = Lib.NetUserModalsSet;
samcli.NetUserSetGroups = Lib.NetUserSetGroups;
samcli.NetUserSetInfo = Lib.NetUserSetInfo;
samcli.NetValidatePasswordPolicy = Lib.NetValidatePasswordPolicy;
samcli.NetValidatePasswordPolicyFree = Lib.NetValidatePasswordPolicyFree;

return samcli;