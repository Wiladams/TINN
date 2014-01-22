-- dsrole.lua	
-- dsrole.dll
local ffi = require("ffi");
local Lib = ffi.load("Netapi32");

local WTypes = require("WTypes");
local WinError = require("win_error");
local core_string = require("core_string_l1_1_0");
local errorhandling = require("core_errorhandling_l1_1_1");

ffi.cdef[[
//
// Domain information
//
typedef enum _DSROLE_MACHINE_ROLE {
    DsRole_RoleStandaloneWorkstation,
    DsRole_RoleMemberWorkstation,
    DsRole_RoleStandaloneServer,
    DsRole_RoleMemberServer,
    DsRole_RoleBackupDomainController,
    DsRole_RolePrimaryDomainController
} DSROLE_MACHINE_ROLE;

//
// Previous server state
//
typedef enum _DSROLE_SERVER_STATE {
    DsRoleServerUnknown = 0,
    DsRoleServerPrimary,
    DsRoleServerBackup
} DSROLE_SERVER_STATE, *PDSROLE_SERVER_STATE;

typedef enum _DSROLE_PRIMARY_DOMAIN_INFO_LEVEL {

    DsRolePrimaryDomainInfoBasic = 1,
    DsRoleUpgradeStatus,
    DsRoleOperationState

} DSROLE_PRIMARY_DOMAIN_INFO_LEVEL;

//
// Flags to be used with the PRIMARY_DOMAIN_INFO_LEVEL structures below
//
static const int DSROLE_PRIMARY_DS_RUNNING           = 0x00000001;
static const int DSROLE_PRIMARY_DS_MIXED_MODE        = 0x00000002;
static const int DSROLE_UPGRADE_IN_PROGRESS          = 0x00000004;
static const int DSROLE_PRIMARY_DS_READONLY          = 0x00000008;
static const int DSROLE_PRIMARY_DOMAIN_GUID_PRESENT  = 0x01000000;

//
// Structure that correspond to the DSROLE_PRIMARY_DOMAIN_INFO_LEVEL
//
typedef struct _DSROLE_PRIMARY_DOMAIN_INFO_BASIC {
    DSROLE_MACHINE_ROLE MachineRole;
    ULONG Flags;
    LPWSTR DomainNameFlat;
    LPWSTR DomainNameDns;
    LPWSTR DomainForestName;
    GUID DomainGuid;
} DSROLE_PRIMARY_DOMAIN_INFO_BASIC, *PDSROLE_PRIMARY_DOMAIN_INFO_BASIC;

typedef struct _DSROLE_UPGRADE_STATUS_INFO {
    ULONG OperationState;
    DSROLE_SERVER_STATE PreviousServerState;
} DSROLE_UPGRADE_STATUS_INFO, *PDSROLE_UPGRADE_STATUS_INFO;

typedef enum _DSROLE_OPERATION_STATE {
    DsRoleOperationIdle = 0,
    DsRoleOperationActive,
    DsRoleOperationNeedReboot
} DSROLE_OPERATION_STATE;

typedef struct _DSROLE_OPERATION_STATE_INFO {
    DSROLE_OPERATION_STATE OperationState;
} DSROLE_OPERATION_STATE_INFO, *PDSROLE_OPERATION_STATE_INFO;
]]


ffi.cdef[[
void
DsRoleFreeMemory(PVOID Buffer);

DWORD
DsRoleGetPrimaryDomainInformation(
    LPCWSTR lpServer,
    DSROLE_PRIMARY_DOMAIN_INFO_LEVEL InfoLevel,
    PBYTE *Buffer 
    );
]]

local dsrole = {
    Lib = Lib,
    
    DsRoleFreeMemory = Lib.DsRoleFreeMemory,
    DsRoleGetPrimaryDomainInformation = Lib.DsRoleGetPrimaryDomainInformation,    
};

dsrole.getPrimaryDomainInfo = function(lpServer)
    local Buffer = ffi.new("BYTE *[1]")
    local InfoLevel = ffi.C.DsRolePrimaryDomainInfoBasic;

    local status = dsrole.DsRoleGetPrimaryDomainInformation(lpServer, InfoLevel, Buffer);

    if status ~= ERROR_SUCCESS then
       local err = errorhandling.GetLastError();
    
       return false, err;
    end 

    local buffPtr = ffi.cast("DSROLE_PRIMARY_DOMAIN_INFO_BASIC *", Buffer[0]);

    local res = {
        Flags = buffPtr.Flags,
    };

    if buffPtr.DomainNameFlat ~= nil then
        res.FlatName = core_string.toAnsi(buffPtr.DomainNameFlat);
    end

    if buffPtr.DomainNameDns ~= nil then
        res.DnsName = core_string.toAnsi(buffPtr.DomainNameDns);
    end

    if buffPtr.DomainForestName ~= nil then
        res.ForestName = core_string.toAnsi(buffPtr.DomainForestName);
    end

    dsrole.DsRoleFreeMemory(buffPtr);

    return res;
end


return dsrole;
