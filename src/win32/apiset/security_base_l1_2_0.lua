-- security_base_l1_2_0.lua	
-- api-ms-win-security-base-l1-2-0.dll	
local ffi = require("ffi");
local WTypes = require("WTypes");
local advapiLib = ffi.load("AdvApi32");

ffi.cdef[[
BOOL
AccessCheck (
       PSECURITY_DESCRIPTOR pSecurityDescriptor,
       HANDLE ClientToken,
       DWORD DesiredAccess,
       PGENERIC_MAPPING GenericMapping,
    PPRIVILEGE_SET PrivilegeSet,
    LPDWORD PrivilegeSetLength,
      LPDWORD GrantedAccess,
      LPBOOL AccessStatus
    );

BOOL
AccessCheckAndAuditAlarmW (
        LPCWSTR SubsystemName,
    LPVOID HandleId,
        LPWSTR ObjectTypeName,
    LPWSTR ObjectName,
        PSECURITY_DESCRIPTOR SecurityDescriptor,
        DWORD DesiredAccess,
        PGENERIC_MAPPING GenericMapping,
        BOOL ObjectCreation,
       LPDWORD GrantedAccess,
       LPBOOL AccessStatus,
       LPBOOL pfGenerateOnClose
    );

BOOL
AccessCheckByType (
        PSECURITY_DESCRIPTOR pSecurityDescriptor,
    PSID PrincipalSelfSid,
        HANDLE ClientToken,
        DWORD DesiredAccess,
   POBJECT_TYPE_LIST ObjectTypeList,
        DWORD ObjectTypeListLength,
        PGENERIC_MAPPING GenericMapping,
    PPRIVILEGE_SET PrivilegeSet,
     LPDWORD PrivilegeSetLength,
       LPDWORD GrantedAccess,
       LPBOOL AccessStatus
    );


BOOL
AccessCheckByTypeAndAuditAlarmW (
        LPCWSTR SubsystemName,
        LPVOID HandleId,
        LPCWSTR ObjectTypeName,
    LPCWSTR ObjectName,
        PSECURITY_DESCRIPTOR SecurityDescriptor,
    PSID PrincipalSelfSid,
        DWORD DesiredAccess,
        AUDIT_EVENT_TYPE AuditType,
        DWORD Flags,
    POBJECT_TYPE_LIST ObjectTypeList,
        DWORD ObjectTypeListLength,
        PGENERIC_MAPPING GenericMapping,
        BOOL ObjectCreation,
       LPDWORD GrantedAccess,
       LPBOOL AccessStatus,
       LPBOOL pfGenerateOnClose
    );


BOOL
AccessCheckByTypeResultList (
        PSECURITY_DESCRIPTOR pSecurityDescriptor,
    PSID PrincipalSelfSid,
        HANDLE ClientToken,
        DWORD DesiredAccess,
    POBJECT_TYPE_LIST ObjectTypeList,
        DWORD ObjectTypeListLength,
        PGENERIC_MAPPING GenericMapping,
    PPRIVILEGE_SET PrivilegeSet,
     LPDWORD PrivilegeSetLength,
       LPDWORD GrantedAccessList,
       LPDWORD AccessStatusList
    );


BOOL
AccessCheckByTypeResultListAndAuditAlarmByHandleW (
        LPCWSTR SubsystemName,
        LPVOID HandleId,
        HANDLE ClientToken,
        LPCWSTR ObjectTypeName,
    LPCWSTR ObjectName,
        PSECURITY_DESCRIPTOR SecurityDescriptor,
    PSID PrincipalSelfSid,
        DWORD DesiredAccess,
        AUDIT_EVENT_TYPE AuditType,
        DWORD Flags,
    POBJECT_TYPE_LIST ObjectTypeList,
        DWORD ObjectTypeListLength,
        PGENERIC_MAPPING GenericMapping,
        BOOL ObjectCreation,
       LPDWORD GrantedAccess,
       LPDWORD AccessStatusList,
       LPBOOL pfGenerateOnClose
    );


BOOL
AccessCheckByTypeResultListAndAuditAlarmW (
        LPCWSTR SubsystemName,
        LPVOID HandleId,
        LPCWSTR ObjectTypeName,
    LPCWSTR ObjectName,
        PSECURITY_DESCRIPTOR SecurityDescriptor,
    PSID PrincipalSelfSid,
        DWORD DesiredAccess,
        AUDIT_EVENT_TYPE AuditType,
        DWORD Flags,
    POBJECT_TYPE_LIST ObjectTypeList,
        DWORD ObjectTypeListLength,
        PGENERIC_MAPPING GenericMapping,
        BOOL ObjectCreation,
       LPDWORD GrantedAccess,
       LPDWORD AccessStatusList,
       LPBOOL pfGenerateOnClose
    );

BOOL
AddAccessAllowedAce (
    PACL pAcl,
       DWORD dwAceRevision,
       DWORD AccessMask,
       PSID pSid
    );

BOOL
AddAccessAllowedAceEx (
    PACL pAcl,
       DWORD dwAceRevision,
       DWORD AceFlags,
       DWORD AccessMask,
       PSID pSid
    );

BOOL
AddAccessAllowedObjectAce (
     PACL pAcl,
        DWORD dwAceRevision,
        DWORD AceFlags,
        DWORD AccessMask,
    GUID *ObjectTypeGuid,
    GUID *InheritedObjectTypeGuid,
        PSID pSid
    );

BOOL
AddAccessDeniedAce (
    PACL pAcl,
       DWORD dwAceRevision,
       DWORD AccessMask,
       PSID pSid
    );

BOOL
AddAccessDeniedAceEx (
    PACL pAcl,
       DWORD dwAceRevision,
       DWORD AceFlags,
       DWORD AccessMask,
       PSID pSid
    );

BOOL
AddAccessDeniedObjectAce (
     PACL pAcl,
        DWORD dwAceRevision,
        DWORD AceFlags,
        DWORD AccessMask,
    GUID *ObjectTypeGuid,
    GUID *InheritedObjectTypeGuid,
        PSID pSid
    );

BOOL
AddAce (
    PACL pAcl,
       DWORD dwAceRevision,
       DWORD dwStartingAceIndex,
    LPVOID pAceList,
       DWORD nAceListLength
    );

BOOL
AddAuditAccessAce(
    PACL pAcl,
       DWORD dwAceRevision,
       DWORD dwAccessMask,
       PSID pSid,
       BOOL bAuditSuccess,
       BOOL bAuditFailure
    );

BOOL
AddAuditAccessAceEx(
    PACL pAcl,
       DWORD dwAceRevision,
       DWORD AceFlags,
       DWORD dwAccessMask,
       PSID pSid,
       BOOL bAuditSuccess,
       BOOL bAuditFailure
    );

BOOL
AddAuditAccessObjectAce (
     PACL pAcl,
        DWORD dwAceRevision,
        DWORD AceFlags,
        DWORD AccessMask,
    GUID *ObjectTypeGuid,
    GUID *InheritedObjectTypeGuid,
        PSID pSid,
        BOOL bAuditSuccess,
        BOOL bAuditFailure
    );

BOOL
AddAuditAccessObjectAce (
     PACL pAcl,
        DWORD dwAceRevision,
        DWORD AceFlags,
        DWORD AccessMask,
    GUID *ObjectTypeGuid,
    GUID *InheritedObjectTypeGuid,
        PSID pSid,
        BOOL bAuditSuccess,
        BOOL bAuditFailure
    );

BOOL
AddMandatoryAce (
    PACL pAcl,
       DWORD dwAceRevision,
       DWORD AceFlags,
       DWORD MandatoryPolicy,
       PSID pLabelSid
    );

BOOL
AdjustTokenGroups (
         HANDLE TokenHandle,
         BOOL ResetToDefault,
     PTOKEN_GROUPS NewState,
         DWORD BufferLength,
    PTOKEN_GROUPS PreviousState,
    PDWORD ReturnLength
    );

BOOL
AdjustTokenPrivileges (
         HANDLE TokenHandle,
         BOOL DisableAllPrivileges,
     PTOKEN_PRIVILEGES NewState,
         DWORD BufferLength,
    PTOKEN_PRIVILEGES PreviousState,
    PDWORD ReturnLength
    );

BOOL
AllocateAndInitializeSid (
           PSID_IDENTIFIER_AUTHORITY pIdentifierAuthority,
           BYTE nSubAuthorityCount,
           DWORD nSubAuthority0,
           DWORD nSubAuthority1,
           DWORD nSubAuthority2,
           DWORD nSubAuthority3,
           DWORD nSubAuthority4,
           DWORD nSubAuthority5,
           DWORD nSubAuthority6,
           DWORD nSubAuthority7,
    PSID *pSid
    );

BOOL
AllocateLocallyUniqueId(
    PLUID Luid
    );

BOOL
AreAllAccessesGranted (
    DWORD GrantedAccess,
    DWORD DesiredAccess
    );

BOOL
AreAnyAccessesGranted (
    DWORD GrantedAccess,
    DWORD DesiredAccess
    );

BOOL
CheckTokenMembership(
    HANDLE TokenHandle,
        PSID SidToCheck,
       PBOOL IsMember
    );

BOOL
ConvertToAutoInheritPrivateObjectSecurity(
       PSECURITY_DESCRIPTOR ParentDescriptor,
           PSECURITY_DESCRIPTOR CurrentSecurityDescriptor,
    PSECURITY_DESCRIPTOR *NewSecurityDescriptor,
       GUID *ObjectType,
           BOOLEAN IsDirectoryObject,
           PGENERIC_MAPPING GenericMapping
    );

BOOL
CopySid (
    DWORD nDestinationSidLength,
    PSID pDestinationSid,
    PSID pSourceSid
    );

BOOL
CreatePrivateObjectSecurity (
       PSECURITY_DESCRIPTOR ParentDescriptor,
       PSECURITY_DESCRIPTOR CreatorDescriptor,
    PSECURITY_DESCRIPTOR * NewDescriptor,
           BOOL IsDirectoryObject,
       HANDLE Token,
           PGENERIC_MAPPING GenericMapping
    );

BOOL
CreatePrivateObjectSecurityEx (
       PSECURITY_DESCRIPTOR ParentDescriptor,
       PSECURITY_DESCRIPTOR CreatorDescriptor,
    PSECURITY_DESCRIPTOR * NewDescriptor,
       GUID *ObjectType,
           BOOL IsContainerObject,
           ULONG AutoInheritFlags,
       HANDLE Token,
           PGENERIC_MAPPING GenericMapping
    );

BOOL
CreatePrivateObjectSecurityWithMultipleInheritance (
       PSECURITY_DESCRIPTOR ParentDescriptor,
       PSECURITY_DESCRIPTOR CreatorDescriptor,
    PSECURITY_DESCRIPTOR * NewDescriptor,
    GUID **ObjectTypes,
           ULONG GuidCount,
           BOOL IsContainerObject,
           ULONG AutoInheritFlags,
       HANDLE Token,
           PGENERIC_MAPPING GenericMapping
    );

BOOL
CreateRestrictedToken(
           HANDLE ExistingTokenHandle,
           DWORD Flags,
           DWORD DisableSidCount,
    PSID_AND_ATTRIBUTES SidsToDisable,
           DWORD DeletePrivilegeCount,
    PLUID_AND_ATTRIBUTES PrivilegesToDelete,
           DWORD RestrictedSidCount,
    PSID_AND_ATTRIBUTES SidsToRestrict,
    PHANDLE NewTokenHandle
    );


BOOL
CreateWellKnownSid(
        WELL_KNOWN_SID_TYPE WellKnownSidType,
    PSID DomainSid,
    PSID pSid,
     DWORD *cbSid
    );

BOOL
DeleteAce (
    PACL pAcl,
       DWORD dwAceIndex
    );

BOOL
DestroyPrivateObjectSecurity (
    PSECURITY_DESCRIPTOR * ObjectDescriptor
    );

BOOL
DuplicateToken(
           HANDLE ExistingTokenHandle,
           SECURITY_IMPERSONATION_LEVEL ImpersonationLevel,
    PHANDLE DuplicateTokenHandle
    );

BOOL
DuplicateTokenEx(
           HANDLE hExistingToken,
           DWORD dwDesiredAccess,
       LPSECURITY_ATTRIBUTES lpTokenAttributes,
           SECURITY_IMPERSONATION_LEVEL ImpersonationLevel,
           TOKEN_TYPE TokenType,
    PHANDLE phNewToken);

BOOL
EqualDomainSid(
     PSID pSid1,
     PSID pSid2,
    BOOL *pfEqual
    );

BOOL
EqualPrefixSid (
    PSID pSid1,
    PSID pSid2
    );

BOOL
EqualSid (
    PSID pSid1,
    PSID pSid2
    );

BOOL
FindFirstFreeAce (
           PACL pAcl,
    LPVOID *pAce
    );

PVOID
FreeSid(
    PSID pSid
    );

BOOL
GetAce (
  PACL pAcl,
  DWORD dwAceIndex,
  LPVOID *pAce
  );

BOOL
GetAclInformation (
  PACL pAcl,
  LPVOID pAclInformation,
  DWORD nAclInformationLength,
  ACL_INFORMATION_CLASS dwAclInformationClass
  );

BOOL
GetFileSecurityW (
     LPCWSTR lpFileName,
     SECURITY_INFORMATION RequestedInformation,
    PSECURITY_DESCRIPTOR pSecurityDescriptor,
     DWORD nLength,
    LPDWORD lpnLengthNeeded
    );

BOOL
GetKernelObjectSecurity (
     HANDLE Handle,
     SECURITY_INFORMATION RequestedInformation,
    PSECURITY_DESCRIPTOR pSecurityDescriptor,
     DWORD nLength,
    LPDWORD lpnLengthNeeded
    );

DWORD
GetLengthSid (
    PSID pSid
    );

BOOL
GetPrivateObjectSecurity (
     PSECURITY_DESCRIPTOR ObjectDescriptor,
     SECURITY_INFORMATION SecurityInformation,
    PSECURITY_DESCRIPTOR ResultantDescriptor,
     DWORD DescriptorLength,
    PDWORD ReturnLength
    );

BOOL
GetSecurityDescriptorControl (
     PSECURITY_DESCRIPTOR pSecurityDescriptor,
    PSECURITY_DESCRIPTOR_CONTROL pControl,
    LPDWORD lpdwRevision
    );

BOOL
GetSecurityDescriptorDacl (
           PSECURITY_DESCRIPTOR pSecurityDescriptor,
          LPBOOL lpbDaclPresent,
    PACL *pDacl,
          LPBOOL lpbDaclDefaulted
    );

BOOL
GetSecurityDescriptorGroup (
           PSECURITY_DESCRIPTOR pSecurityDescriptor,
    PSID *pGroup,
          LPBOOL lpbGroupDefaulted
    );

DWORD
GetSecurityDescriptorLength (
    PSECURITY_DESCRIPTOR pSecurityDescriptor
    );

BOOL
GetSecurityDescriptorOwner (
           PSECURITY_DESCRIPTOR pSecurityDescriptor,
    PSID *pOwner,
          LPBOOL lpbOwnerDefaulted
    );

DWORD
GetSecurityDescriptorRMControl(
     PSECURITY_DESCRIPTOR SecurityDescriptor,
    PUCHAR RMControl
    );

BOOL
GetSecurityDescriptorSacl (
           PSECURITY_DESCRIPTOR pSecurityDescriptor,
          LPBOOL lpbSaclPresent,
    PACL *pSacl,
          LPBOOL lpbSaclDefaulted
    );

PSID_IDENTIFIER_AUTHORITY
GetSidIdentifierAuthority (
    PSID pSid
    );

DWORD
GetSidLengthRequired (
    UCHAR nSubAuthorityCount
    );

PDWORD
GetSidSubAuthority (
    PSID pSid,
    DWORD nSubAuthority
    );

PUCHAR
GetSidSubAuthorityCount (
    PSID pSid
    );

BOOL
GetTokenInformation (
         HANDLE TokenHandle,
         TOKEN_INFORMATION_CLASS TokenInformationClass,
    LPVOID TokenInformation,
         DWORD TokenInformationLength,
        PDWORD ReturnLength
    );

BOOL
GetWindowsAccountDomainSid(
       PSID pSid,
    PSID pDomainSid,
    DWORD* cbDomainSid
    );

BOOL
ImpersonateAnonymousToken(
    HANDLE ThreadHandle
    );

BOOL
ImpersonateLoggedOnUser(
    HANDLE  hToken
    );

BOOL
ImpersonateSelf(
    SECURITY_IMPERSONATION_LEVEL ImpersonationLevel
    );

BOOL
InitializeAcl (
    PACL pAcl,
    DWORD nAclLength,
    DWORD dwAclRevision
    );

BOOL
InitializeSecurityDescriptor (
    PSECURITY_DESCRIPTOR pSecurityDescriptor,
     DWORD dwRevision
    );

BOOL
InitializeSid (
    PSID Sid,
     PSID_IDENTIFIER_AUTHORITY pIdentifierAuthority,
     BYTE nSubAuthorityCount
    );

BOOL
IsTokenRestricted(
    HANDLE TokenHandle
    );

BOOL
IsValidAcl (
    PACL pAcl
    );

BOOL
IsValidSecurityDescriptor (
    PSECURITY_DESCRIPTOR pSecurityDescriptor
    );


BOOL
IsValidSid (
    PSID pSid
    );

BOOL
IsWellKnownSid (
    PSID pSid,
    WELL_KNOWN_SID_TYPE WellKnownSidType
    );

BOOL
MakeAbsoluteSD (
       PSECURITY_DESCRIPTOR pSelfRelativeSecurityDescriptor,
    PSECURITY_DESCRIPTOR pAbsoluteSecurityDescriptor,
    LPDWORD lpdwAbsoluteSecurityDescriptorSize,
    PACL pDacl,
    LPDWORD lpdwDaclSize,
    PACL pSacl,
    LPDWORD lpdwSaclSize,
    PSID pOwner,
    LPDWORD lpdwOwnerSize,
    PSID pPrimaryGroup,
    LPDWORD lpdwPrimaryGroupSize
    );

BOOL
MakeSelfRelativeSD (
       PSECURITY_DESCRIPTOR pAbsoluteSecurityDescriptor,
    PSECURITY_DESCRIPTOR pSelfRelativeSecurityDescriptor,
    LPDWORD lpdwBufferLength
    );

VOID
MapGenericMask (
    PDWORD AccessMask,
       PGENERIC_MAPPING GenericMapping
    );


BOOL
ObjectCloseAuditAlarmW (
    LPCWSTR SubsystemName,
    LPVOID HandleId,
    BOOL GenerateOnClose
    );

BOOL
ObjectDeleteAuditAlarmW (
    LPCWSTR SubsystemName,
    LPVOID HandleId,
    BOOL GenerateOnClose
    );

BOOL
ObjectOpenAuditAlarmW (
        LPCWSTR SubsystemName,
        LPVOID HandleId,
        LPWSTR ObjectTypeName,
    LPWSTR ObjectName,
        PSECURITY_DESCRIPTOR pSecurityDescriptor,
        HANDLE ClientToken,
        DWORD DesiredAccess,
        DWORD GrantedAccess,
    PPRIVILEGE_SET Privileges,
        BOOL ObjectCreation,
        BOOL AccessGranted,
       LPBOOL GenerateOnClose
    );

BOOL
ObjectPrivilegeAuditAlarmW (
    LPCWSTR SubsystemName,
    LPVOID HandleId,
    HANDLE ClientToken,
    DWORD DesiredAccess,
    PPRIVILEGE_SET Privileges,
    BOOL AccessGranted
    );

BOOL
PrivilegeCheck (
       HANDLE ClientToken,
    PPRIVILEGE_SET RequiredPrivileges,
      LPBOOL pfResult
    );

BOOL
PrivilegedServiceAuditAlarmW (
    LPCWSTR SubsystemName,
    LPCWSTR ServiceName,
    HANDLE ClientToken,
    PPRIVILEGE_SET Privileges,
    BOOL AccessGranted
    );

VOID
QuerySecurityAccessMask(
    SECURITY_INFORMATION SecurityInformation,
    LPDWORD DesiredAccess
    );

BOOL
RevertToSelf (
    VOID
    );

BOOL
SetAclInformation (
    PACL pAcl,
    LPVOID pAclInformation,
       DWORD nAclInformationLength,
       ACL_INFORMATION_CLASS dwAclInformationClass
    );

BOOL
SetFileSecurityW (
    LPCWSTR lpFileName,
    SECURITY_INFORMATION SecurityInformation,
    PSECURITY_DESCRIPTOR pSecurityDescriptor
    );

BOOL
SetKernelObjectSecurity (
    HANDLE Handle,
    SECURITY_INFORMATION SecurityInformation,
    PSECURITY_DESCRIPTOR SecurityDescriptor
    );

BOOL
SetPrivateObjectSecurity (
             SECURITY_INFORMATION SecurityInformation,
             PSECURITY_DESCRIPTOR ModificationDescriptor,
    PSECURITY_DESCRIPTOR *ObjectsSecurityDescriptor,
             PGENERIC_MAPPING GenericMapping,
         HANDLE Token
    );

BOOL
SetPrivateObjectSecurityEx (
             SECURITY_INFORMATION SecurityInformation,
             PSECURITY_DESCRIPTOR ModificationDescriptor,
    PSECURITY_DESCRIPTOR *ObjectsSecurityDescriptor,
             ULONG AutoInheritFlags,
             PGENERIC_MAPPING GenericMapping,
         HANDLE Token
    );

VOID
SetSecurityAccessMask(
    SECURITY_INFORMATION SecurityInformation,
    LPDWORD DesiredAccess
    );

BOOL
SetSecurityDescriptorControl (
    PSECURITY_DESCRIPTOR pSecurityDescriptor,
    SECURITY_DESCRIPTOR_CONTROL ControlBitsOfInterest,
    SECURITY_DESCRIPTOR_CONTROL ControlBitsToSet
    );

BOOL
SetSecurityDescriptorDacl (
     PSECURITY_DESCRIPTOR pSecurityDescriptor,
        BOOL bDaclPresent,
    PACL pDacl,
        BOOL bDaclDefaulted
    );

BOOL
SetSecurityDescriptorGroup (
     PSECURITY_DESCRIPTOR pSecurityDescriptor,
    PSID pGroup,
        BOOL bGroupDefaulted
    );

BOOL
SetSecurityDescriptorOwner (
     PSECURITY_DESCRIPTOR pSecurityDescriptor,
    PSID pOwner,
        BOOL bOwnerDefaulted
    );

DWORD
SetSecurityDescriptorRMControl(
     PSECURITY_DESCRIPTOR SecurityDescriptor,
    PUCHAR RMControl
    );

BOOL
SetSecurityDescriptorSacl (
     PSECURITY_DESCRIPTOR pSecurityDescriptor,
        BOOL bSaclPresent,
    PACL pSacl,
        BOOL bSaclDefaulted
    );

BOOL
SetTokenInformation (
    HANDLE TokenHandle,
    TOKEN_INFORMATION_CLASS TokenInformationClass,
    LPVOID TokenInformation,
    DWORD TokenInformationLength
    );
]]

return {
--[[
AccessCheck
AccessCheckAndAuditAlarmW
AccessCheckByType
AccessCheckByTypeAndAuditAlarmW
AccessCheckByTypeResultList
AccessCheckByTypeResultListAndAuditAlarmByHandleW
AccessCheckByTypeResultListAndAuditAlarmW
AddAccessAllowedAce
AddAccessAllowedAceEx
AddAccessAllowedObjectAce
AddAccessDeniedAce
AddAccessDeniedAceEx
AddAccessDeniedObjectAce
AddAce
AddAuditAccessAce
AddAuditAccessAceEx
AddAuditAccessObjectAce
AddMandatoryAce
--AddResourceAttributeAce
--AddScopedPolicyIDAce
AdjustTokenGroups
AdjustTokenPrivileges
AllocateAndInitializeSid
AllocateLocallyUniqueId
AreAllAccessesGranted
AreAnyAccessesGranted
--CheckTokenCapability
CheckTokenMembership
--CheckTokenMembershipEx
ConvertToAutoInheritPrivateObjectSecurity
CopySid
CreatePrivateObjectSecurity
CreatePrivateObjectSecurityEx
CreatePrivateObjectSecurityWithMultipleInheritance
CreateRestrictedToken
CreateWellKnownSid
DeleteAce
DestroyPrivateObjectSecurity
DuplicateToken
DuplicateTokenEx
EqualDomainSid
EqualPrefixSid
EqualSid
FindFirstFreeAce
FreeSid
GetAce
GetAclInformation
--GetAppContainerAce
--GetCachedSigningLevel
GetFileSecurityW
GetKernelObjectSecurity
GetLengthSid
GetPrivateObjectSecurity
GetSecurityDescriptorControl
GetSecurityDescriptorDacl
GetSecurityDescriptorGroup
GetSecurityDescriptorLength
GetSecurityDescriptorOwner
GetSecurityDescriptorRMControl
GetSecurityDescriptorSacl
GetSidIdentifierAuthority
GetSidLengthRequired
GetSidSubAuthority
GetSidSubAuthorityCount
--]]

GetTokenInformation = advapiLib.GetTokenInformation,
GetWindowsAccountDomainSid = advapiLib.GetWindowsAccountDomainSid,
ImpersonateAnonymousToken = advapiLib.ImpersonateAnonymousToken,
ImpersonateLoggedOnUser = advapiLib.ImpersonateLoggedOnUser,
ImpersonateSelf = advapiLib.ImpersonateSelf,

--[[
InitializeAcl
InitializeSecurityDescriptor
InitializeSid
IsTokenRestricted
IsValidAcl
IsValidSecurityDescriptor
IsValidSid
IsWellKnownSid
MakeAbsoluteSD
MakeSelfRelativeSD
MapGenericMask
ObjectCloseAuditAlarmW
ObjectDeleteAuditAlarmW
ObjectOpenAuditAlarmW
ObjectPrivilegeAuditAlarmW
PrivilegeCheck
PrivilegedServiceAuditAlarmW
QuerySecurityAccessMask
RevertToSelf
SetAclInformation
--SetCachedSigningLevel
SetFileSecurityW
SetKernelObjectSecurity
SetPrivateObjectSecurity
SetPrivateObjectSecurityEx
SetSecurityAccessMask
SetSecurityDescriptorControl
SetSecurityDescriptorDacl
SetSecurityDescriptorGroup
SetSecurityDescriptorOwner
SetSecurityDescriptorRMControl
SetSecurityDescriptorSacl
SetTokenInformation
--]]
}
