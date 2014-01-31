local ffi = require("ffi")
local WTypes = require("WTypes")
local WinNT = require("WinNT")

ffi.cdef[[
]]

ffi.cdef[[
typedef PVOID HDEVINFO;

static const int GBS_HASBATTERY = 0x1;
static const int GBS_ONBATTERY  = 0x2;
]]


ffi.cdef[[
//
// Flags controlling what is included in the device information set built
// by SetupDiGetClassDevs
//
static const int DIGCF_DEFAULT          = 0x00000001;  // only valid with DIGCF_DEVICEINTERFACE
static const int DIGCF_PRESENT          = 0x00000002;
static const int DIGCF_ALLCLASSES       = 0x00000004;
static const int DIGCF_PROFILE          = 0x00000008;
static const int DIGCF_DEVICEINTERFACE  = 0x00000010;
]]

ffi.cdef[[
#pragma pack(1)

//
// Device interface information structure (references a device
// interface that is associated with the device information
// element that owns it).
//
typedef struct _SP_DEVICE_INTERFACE_DATA {
    DWORD cbSize;
    GUID  InterfaceClassGuid;
    DWORD Flags;
    ULONG_PTR Reserved;
} SP_DEVICE_INTERFACE_DATA, *PSP_DEVICE_INTERFACE_DATA;

/*
typedef struct _SP_DEVICE_INTERFACE_DETAIL_DATA_A {
    DWORD  cbSize;
    CHAR   DevicePath[260];
} SP_DEVICE_INTERFACE_DETAIL_DATA_A, *PSP_DEVICE_INTERFACE_DETAIL_DATA_A;
*/


typedef struct _SP_DEVICE_INTERFACE_DETAIL_DATA_A {
    DWORD  cbSize;
    CHAR   DevicePath[ANYSIZE_ARRAY];
} SP_DEVICE_INTERFACE_DETAIL_DATA_A, *PSP_DEVICE_INTERFACE_DETAIL_DATA_A;

//
// Device information structure (references a device instance
// that is a member of a device information set)
//
typedef struct _SP_DEVINFO_DATA {
    DWORD cbSize;
    GUID  ClassGuid;
    DWORD DevInst;    // DEVINST handle
    ULONG_PTR Reserved;
} SP_DEVINFO_DATA, *PSP_DEVINFO_DATA;


//
// Flags for SP_DEVICE_INTERFACE_DATA.Flags field.
//
static const int SPINT_ACTIVE  =0x00000001;
static const int SPINT_DEFAULT =0x00000002;
static const int SPINT_REMOVED =0x00000004;



//
// Device registry property codes
// (Codes marked as read-only (R) may only be used for
// SetupDiGetDeviceRegistryProperty)
//
// These values should cover the same set of registry properties
// as defined by the CM_DRP codes in cfgmgr32.h.
//
// Note that SPDRP codes are zero based while CM_DRP codes are one based!
//
static const int SPDRP_DEVICEDESC                  = (0x00000000);  // DeviceDesc (R/W)
static const int SPDRP_HARDWAREID                  = (0x00000001);  // HardwareID (R/W)
static const int SPDRP_COMPATIBLEIDS               = (0x00000002);  // CompatibleIDs (R/W)
static const int SPDRP_UNUSED0                     = (0x00000003);  // unused
static const int SPDRP_SERVICE                     = (0x00000004);  // Service (R/W)
static const int SPDRP_UNUSED1                     = (0x00000005);  // unused
static const int SPDRP_UNUSED2                     = (0x00000006);  // unused
static const int SPDRP_CLASS                       = (0x00000007);  // Class (R--tied to ClassGUID)
static const int SPDRP_CLASSGUID                   = (0x00000008);  // ClassGUID (R/W)
static const int SPDRP_DRIVER                      = (0x00000009);  // Driver (R/W)
static const int SPDRP_CONFIGFLAGS                 = (0x0000000A);  // ConfigFlags (R/W)
static const int SPDRP_MFG                         = (0x0000000B);  // Mfg (R/W)
static const int SPDRP_FRIENDLYNAME                = (0x0000000C);  // FriendlyName (R/W)
static const int SPDRP_LOCATION_INFORMATION        = (0x0000000D);  // LocationInformation (R/W)
static const int SPDRP_PHYSICAL_DEVICE_OBJECT_NAME = (0x0000000E);  // PhysicalDeviceObjectName (R)
static const int SPDRP_CAPABILITIES                = (0x0000000F);  // Capabilities (R)
static const int SPDRP_UI_NUMBER                   = (0x00000010);  // UiNumber (R)
static const int SPDRP_UPPERFILTERS                = (0x00000011);  // UpperFilters (R/W)
static const int SPDRP_LOWERFILTERS                = (0x00000012);  // LowerFilters (R/W)
static const int SPDRP_BUSTYPEGUID                 = (0x00000013);  // BusTypeGUID (R)
static const int SPDRP_LEGACYBUSTYPE               = (0x00000014);  // LegacyBusType (R)
static const int SPDRP_BUSNUMBER                   = (0x00000015);  // BusNumber (R)
static const int SPDRP_ENUMERATOR_NAME             = (0x00000016);  // Enumerator Name (R)
static const int SPDRP_SECURITY                    = (0x00000017);  // Security (R/W, binary form)
static const int SPDRP_SECURITY_SDS                = (0x00000018);  // Security (W, SDS form)
static const int SPDRP_DEVTYPE                     = (0x00000019);  // Device Type (R/W)
static const int SPDRP_EXCLUSIVE                   = (0x0000001A);  // Device is exclusive-access (R/W)
static const int SPDRP_CHARACTERISTICS             = (0x0000001B);  // Device Characteristics (R/W)
static const int SPDRP_ADDRESS                     = (0x0000001C);  // Device Address (R)
static const int SPDRP_UI_NUMBER_DESC_FORMAT       = (0x0000001D);  // UiNumberDescFormat (R/W)
static const int SPDRP_DEVICE_POWER_DATA           = (0x0000001E);  // Device Power Data (R)
static const int SPDRP_REMOVAL_POLICY              = (0x0000001F);  // Removal Policy (R)
static const int SPDRP_REMOVAL_POLICY_HW_DEFAULT   = (0x00000020);  // Hardware Removal Policy (R)
static const int SPDRP_REMOVAL_POLICY_OVERRIDE     = (0x00000021);  // Removal Policy Override (RW)
static const int SPDRP_INSTALL_STATE               = (0x00000022);  // Device Install State (R)
static const int SPDRP_LOCATION_PATHS              = (0x00000023);  // Device Location Paths (R)
static const int SPDRP_BASE_CONTAINERID            = (0x00000024);  // Base ContainerID (R)

static const int SPDRP_MAXIMUM_PROPERTY            = (0x00000025);  // Upper bound on ordinals


]]

ffi.cdef[[
BOOL
SetupDiEnumDeviceInfo(
    HDEVINFO DeviceInfoSet,
    DWORD MemberIndex,
    PSP_DEVINFO_DATA DeviceInfoData);

BOOL
SetupDiEnumDeviceInterfaces(
    HDEVINFO DeviceInfoSet,
    PSP_DEVINFO_DATA DeviceInfoData,
    const GUID *InterfaceClassGuid,
    DWORD MemberIndex,
    PSP_DEVICE_INTERFACE_DATA DeviceInterfaceData);

HDEVINFO
SetupDiGetClassDevsA(
    const GUID *ClassGuid,
    PCSTR Enumerator,
    HWND hwndParent,
    DWORD Flags);


BOOL
SetupDiGetDeviceInterfaceDetailA(
    HDEVINFO DeviceInfoSet,
    PSP_DEVICE_INTERFACE_DATA DeviceInterfaceData,
    PSP_DEVICE_INTERFACE_DETAIL_DATA_A DeviceInterfaceDetailData, 
    DWORD DeviceInterfaceDetailDataSize,
    PDWORD RequiredSize,
    PSP_DEVINFO_DATA DeviceInfoData
    );

BOOL
SetupDiGetDeviceRegistryPropertyA(
    HDEVINFO DeviceInfoSet,
    PSP_DEVINFO_DATA DeviceInfoData,
    DWORD Property,
    PDWORD PropertyRegDataType, 
    PBYTE PropertyBuffer,
    DWORD PropertyBufferSize,
    PDWORD RequiredSize 
    );

]]

ffi.cdef[[
]]

SetupLib = ffi.load("setupapi")

return {
	Lib = SetupLib,

	SetupDiEnumDeviceInfo = SetupLib.SetupDiEnumDeviceInfo,
	SetupDiEnumDeviceInterfaces = SetupLib.SetupDiEnumDeviceInterfaces,
	SetupDiGetClassDevs = SetupLib.SetupDiGetClassDevsA,
	SetupDiGetDeviceInterfaceDetail = SetupLib.SetupDiGetDeviceInterfaceDetailA,
	SetupDiGetDeviceRegistryProperty = SetupLib.SetupDiGetDeviceRegistryPropertyA,
}