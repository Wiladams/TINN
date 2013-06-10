-- WinIoCtl.lua

local ffi = require("ffi");

local bit = require("bit");
local bor = bit.bor;
local band = bit.band;
local lshift = bit.lshift;
local rshift = bit.rshift;

local WinNT = require("WinNT");
local WTypes = require("WTypes");


-- begin_ntddk begin_wdm begin_nthal begin_ntifs
--
-- Define the various device type values.  Note that values used by Microsoft
-- Corporation are in the range 0-32767, and 32768-65535 are reserved for use
-- by customers.
--

--DEVICE_TYPE DWORD

FILE_DEVICE_BEEP                = 0x00000001;
FILE_DEVICE_CD_ROM              = 0x00000002;
FILE_DEVICE_CD_ROM_FILE_SYSTEM  = 0x00000003;
FILE_DEVICE_CONTROLLER          = 0x00000004;
FILE_DEVICE_DATALINK            = 0x00000005;
FILE_DEVICE_DFS                 = 0x00000006;
FILE_DEVICE_DISK                = 0x00000007;
FILE_DEVICE_DISK_FILE_SYSTEM    = 0x00000008;
FILE_DEVICE_FILE_SYSTEM         = 0x00000009;
FILE_DEVICE_INPORT_PORT         = 0x0000000a;
FILE_DEVICE_KEYBOARD            = 0x0000000b;
FILE_DEVICE_MAILSLOT            = 0x0000000c;
FILE_DEVICE_MIDI_IN             = 0x0000000d;
FILE_DEVICE_MIDI_OUT            = 0x0000000e;
FILE_DEVICE_MOUSE               = 0x0000000f;
FILE_DEVICE_MULTI_UNC_PROVIDER  = 0x00000010;
FILE_DEVICE_NAMED_PIPE          = 0x00000011;
FILE_DEVICE_NETWORK             = 0x00000012;
FILE_DEVICE_NETWORK_BROWSER     = 0x00000013;
FILE_DEVICE_NETWORK_FILE_SYSTEM = 0x00000014;
FILE_DEVICE_NULL                = 0x00000015;
FILE_DEVICE_PARALLEL_PORT       = 0x00000016;
FILE_DEVICE_PHYSICAL_NETCARD    = 0x00000017;
FILE_DEVICE_PRINTER             = 0x00000018;
FILE_DEVICE_SCANNER             = 0x00000019;
FILE_DEVICE_SERIAL_MOUSE_PORT   = 0x0000001a;
FILE_DEVICE_SERIAL_PORT         = 0x0000001b;
FILE_DEVICE_SCREEN              = 0x0000001c;
FILE_DEVICE_SOUND               = 0x0000001d;
FILE_DEVICE_STREAMS             = 0x0000001e;
FILE_DEVICE_TAPE                = 0x0000001f;
FILE_DEVICE_TAPE_FILE_SYSTEM    = 0x00000020;
FILE_DEVICE_TRANSPORT           = 0x00000021;
FILE_DEVICE_UNKNOWN             = 0x00000022;
FILE_DEVICE_VIDEO               = 0x00000023;
FILE_DEVICE_VIRTUAL_DISK        = 0x00000024;
FILE_DEVICE_WAVE_IN             = 0x00000025;
FILE_DEVICE_WAVE_OUT            = 0x00000026;
FILE_DEVICE_8042_PORT           = 0x00000027;
FILE_DEVICE_NETWORK_REDIRECTOR  = 0x00000028;
FILE_DEVICE_BATTERY             = 0x00000029;
FILE_DEVICE_BUS_EXTENDER        = 0x0000002a;
FILE_DEVICE_MODEM               = 0x0000002b;
FILE_DEVICE_VDM                 = 0x0000002c;
FILE_DEVICE_MASS_STORAGE        = 0x0000002d;
FILE_DEVICE_SMB                 = 0x0000002e;
FILE_DEVICE_KS                  = 0x0000002f;
FILE_DEVICE_CHANGER             = 0x00000030;
FILE_DEVICE_SMARTCARD           = 0x00000031;
FILE_DEVICE_ACPI                = 0x00000032;
FILE_DEVICE_DVD                 = 0x00000033;
FILE_DEVICE_FULLSCREEN_VIDEO    = 0x00000034;
FILE_DEVICE_DFS_FILE_SYSTEM     = 0x00000035;
FILE_DEVICE_DFS_VOLUME          = 0x00000036;
FILE_DEVICE_SERENUM             = 0x00000037;
FILE_DEVICE_TERMSRV             = 0x00000038;
FILE_DEVICE_KSEC                = 0x00000039;
FILE_DEVICE_FIPS                = 0x0000003A;
FILE_DEVICE_INFINIBAND          = 0x0000003B;
FILE_DEVICE_VMBUS               = 0x0000003E;
FILE_DEVICE_CRYPT_PROVIDER      = 0x0000003F;
FILE_DEVICE_WPD                 = 0x00000040;
FILE_DEVICE_BLUETOOTH           = 0x00000041;
FILE_DEVICE_MT_COMPOSITE        = 0x00000042;
FILE_DEVICE_MT_TRANSPORT        = 0x00000043;
FILE_DEVICE_BIOMETRIC		    = 0x00000044;
FILE_DEVICE_PMI                 = 0x00000045;


--
-- Macro definition for defining IOCTL and FSCTL function control codes.  Note
-- that function codes 0-2047 are reserved for Microsoft Corporation, and
-- 2048-4095 are reserved for customers.
--

local CTL_CODE = function( DeviceType, Function, Method, Access ) 
	return bor(lshift(DeviceType, 16), lshift(Access, 14), lshift(Function, 2), Method);
end

--
-- Macro to extract device type out of the device io control code
--
DEVICE_TYPE_FROM_CTL_CODE = function(ctrlCode)
	return rshift(band(ctrlCode, 0xffff0000), 16);
end

--
-- Macro to extract buffering method out of the device io control code
--
METHOD_FROM_CTL_CODE = function(ctrlCode)
	return (band(ctrlCode, 3));
end

--
-- Define the method codes for how buffers are passed for I/O and FS controls
--

METHOD_BUFFERED              =   0;
METHOD_IN_DIRECT             =   1;
METHOD_OUT_DIRECT            =   2;
METHOD_NEITHER               =   3;

--
-- Define some easier to comprehend aliases:
--   METHOD_DIRECT_TO_HARDWARE (writes, aka METHOD_IN_DIRECT)
--   METHOD_DIRECT_FROM_HARDWARE (reads, aka METHOD_OUT_DIRECT)
--

METHOD_DIRECT_TO_HARDWARE      = METHOD_IN_DIRECT;
METHOD_DIRECT_FROM_HARDWARE    = METHOD_OUT_DIRECT;

--
-- Define the access check value for any access
--
--
-- The FILE_READ_ACCESS and FILE_WRITE_ACCESS constants are also defined in
-- ntioapi.h as FILE_READ_DATA and FILE_WRITE_DATA. The values for these
-- constants *MUST* always be in sync.
--
--
-- FILE_SPECIAL_ACCESS is checked by the NT I/O system the same as FILE_ANY_ACCESS.
-- The file systems, however, may add additional access checks for I/O and FS controls
-- that use this value.
--


FILE_ANY_ACCESS        =   0;
FILE_SPECIAL_ACCESS    =   (FILE_ANY_ACCESS);
FILE_READ_ACCESS       =   ( 0x0001 );    -- file & pipe
FILE_WRITE_ACCESS      =   ( 0x0002 );    -- file & pipe


--
-- The following is a list of the native file system fsctls followed by
-- additional network file system fsctls.  Some values have been
-- decommissioned.
--

FSCTL_REQUEST_OPLOCK_LEVEL_1    = CTL_CODE(FILE_DEVICE_FILE_SYSTEM,  0, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_REQUEST_OPLOCK_LEVEL_2    = CTL_CODE(FILE_DEVICE_FILE_SYSTEM,  1, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_REQUEST_BATCH_OPLOCK      = CTL_CODE(FILE_DEVICE_FILE_SYSTEM,  2, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_OPLOCK_BREAK_ACKNOWLEDGE  = CTL_CODE(FILE_DEVICE_FILE_SYSTEM,  3, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_OPBATCH_ACK_CLOSE_PENDING = CTL_CODE(FILE_DEVICE_FILE_SYSTEM,  4, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_OPLOCK_BREAK_NOTIFY       = CTL_CODE(FILE_DEVICE_FILE_SYSTEM,  5, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_LOCK_VOLUME               = CTL_CODE(FILE_DEVICE_FILE_SYSTEM,  6, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_UNLOCK_VOLUME             = CTL_CODE(FILE_DEVICE_FILE_SYSTEM,  7, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_DISMOUNT_VOLUME           = CTL_CODE(FILE_DEVICE_FILE_SYSTEM,  8, METHOD_BUFFERED, FILE_ANY_ACCESS);
-- decommissioned fsctl value                                              9
FSCTL_IS_VOLUME_MOUNTED         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 10, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_IS_PATHNAME_VALID         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 11, METHOD_BUFFERED, FILE_ANY_ACCESS); -- PATHNAME_BUFFER,
FSCTL_MARK_VOLUME_DIRTY         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 12, METHOD_BUFFERED, FILE_ANY_ACCESS);
-- decommissioned fsctl value                                             13
FSCTL_QUERY_RETRIEVAL_POINTERS  = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 14,  METHOD_NEITHER, FILE_ANY_ACCESS);
FSCTL_GET_COMPRESSION           = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 15, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_SET_COMPRESSION           = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 16, METHOD_BUFFERED, bor(FILE_READ_DATA, FILE_WRITE_DATA));
-- decommissioned fsctl value                                             17
-- decommissioned fsctl value                                             18
FSCTL_SET_BOOTLOADER_ACCESSED   = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 19,  METHOD_NEITHER, FILE_ANY_ACCESS);
FSCTL_OPLOCK_BREAK_ACK_NO_2     = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 20, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_INVALIDATE_VOLUMES        = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 21, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_QUERY_FAT_BPB             = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 22, METHOD_BUFFERED, FILE_ANY_ACCESS); -- FSCTL_QUERY_FAT_BPB_BUFFER
FSCTL_REQUEST_FILTER_OPLOCK     = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 23, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_FILESYSTEM_GET_STATISTICS = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 24, METHOD_BUFFERED, FILE_ANY_ACCESS); -- FILESYSTEM_STATISTICS

--#if (_WIN32_WINNT >= 0x0400)
FSCTL_GET_NTFS_VOLUME_DATA      = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 25, METHOD_BUFFERED, FILE_ANY_ACCESS); -- NTFS_VOLUME_DATA_BUFFER
FSCTL_GET_NTFS_FILE_RECORD      = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 26, METHOD_BUFFERED, FILE_ANY_ACCESS); -- NTFS_FILE_RECORD_INPUT_BUFFER, NTFS_FILE_RECORD_OUTPUT_BUFFER
FSCTL_GET_VOLUME_BITMAP         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 27,  METHOD_NEITHER, FILE_ANY_ACCESS); -- STARTING_LCN_INPUT_BUFFER, VOLUME_BITMAP_BUFFER
FSCTL_GET_RETRIEVAL_POINTERS    = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 28,  METHOD_NEITHER, FILE_ANY_ACCESS); -- STARTING_VCN_INPUT_BUFFER, RETRIEVAL_POINTERS_BUFFER
FSCTL_MOVE_FILE                 = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 29, METHOD_BUFFERED, FILE_SPECIAL_ACCESS); -- MOVE_FILE_DATA,
FSCTL_IS_VOLUME_DIRTY           = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 30, METHOD_BUFFERED, FILE_ANY_ACCESS);
-- decomissioned fsctl value                                              31
FSCTL_ALLOW_EXTENDED_DASD_IO    = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 32, METHOD_NEITHER,  FILE_ANY_ACCESS);
--#endif /* _WIN32_WINNT >= 0x0400 */

--#if (_WIN32_WINNT >= 0x0500);
-- decommissioned fsctl value                                             33
-- decommissioned fsctl value                                             34
FSCTL_FIND_FILES_BY_SID         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 35, METHOD_NEITHER, FILE_ANY_ACCESS);
-- decommissioned fsctl value                                             36
-- decommissioned fsctl value                                             37
FSCTL_SET_OBJECT_ID             = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 38, METHOD_BUFFERED, FILE_SPECIAL_ACCESS); -- FILE_OBJECTID_BUFFER
FSCTL_GET_OBJECT_ID             = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 39, METHOD_BUFFERED, FILE_ANY_ACCESS); -- FILE_OBJECTID_BUFFER
FSCTL_DELETE_OBJECT_ID          = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 40, METHOD_BUFFERED, FILE_SPECIAL_ACCESS);
FSCTL_SET_REPARSE_POINT         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 41, METHOD_BUFFERED, FILE_SPECIAL_ACCESS); -- REPARSE_DATA_BUFFER,
FSCTL_GET_REPARSE_POINT         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 42, METHOD_BUFFERED, FILE_ANY_ACCESS); -- REPARSE_DATA_BUFFER
FSCTL_DELETE_REPARSE_POINT      = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 43, METHOD_BUFFERED, FILE_SPECIAL_ACCESS); -- REPARSE_DATA_BUFFER,
FSCTL_ENUM_USN_DATA             = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 44,  METHOD_NEITHER, FILE_ANY_ACCESS); -- MFT_ENUM_DATA,
FSCTL_SECURITY_ID_CHECK         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 45,  METHOD_NEITHER, FILE_READ_DATA);  -- BULK_SECURITY_TEST_DATA,
FSCTL_READ_USN_JOURNAL          = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 46,  METHOD_NEITHER, FILE_ANY_ACCESS); -- READ_USN_JOURNAL_DATA, USN
FSCTL_SET_OBJECT_ID_EXTENDED    = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 47, METHOD_BUFFERED, FILE_SPECIAL_ACCESS);
FSCTL_CREATE_OR_GET_OBJECT_ID   = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 48, METHOD_BUFFERED, FILE_ANY_ACCESS); -- FILE_OBJECTID_BUFFER
FSCTL_SET_SPARSE                = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 49, METHOD_BUFFERED, FILE_SPECIAL_ACCESS);
FSCTL_SET_ZERO_DATA             = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 50, METHOD_BUFFERED, FILE_WRITE_DATA); -- FILE_ZERO_DATA_INFORMATION,
FSCTL_QUERY_ALLOCATED_RANGES    = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 51,  METHOD_NEITHER, FILE_READ_DATA);  -- FILE_ALLOCATED_RANGE_BUFFER, FILE_ALLOCATED_RANGE_BUFFER
FSCTL_ENABLE_UPGRADE            = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 52, METHOD_BUFFERED, FILE_WRITE_DATA);
-- decommissioned fsctl value                                             52
FSCTL_SET_ENCRYPTION            = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 53,  METHOD_NEITHER, FILE_ANY_ACCESS); -- ENCRYPTION_BUFFER, DECRYPTION_STATUS_BUFFER
FSCTL_ENCRYPTION_FSCTL_IO       = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 54,  METHOD_NEITHER, FILE_ANY_ACCESS);
FSCTL_WRITE_RAW_ENCRYPTED       = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 55,  METHOD_NEITHER, FILE_SPECIAL_ACCESS); -- ENCRYPTED_DATA_INFO, EXTENDED_ENCRYPTED_DATA_INFO
FSCTL_READ_RAW_ENCRYPTED        = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 56,  METHOD_NEITHER, FILE_SPECIAL_ACCESS); -- REQUEST_RAW_ENCRYPTED_DATA, ENCRYPTED_DATA_INFO, EXTENDED_ENCRYPTED_DATA_INFO
FSCTL_CREATE_USN_JOURNAL        = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 57,  METHOD_NEITHER, FILE_ANY_ACCESS); -- CREATE_USN_JOURNAL_DATA,
FSCTL_READ_FILE_USN_DATA        = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 58,  METHOD_NEITHER, FILE_ANY_ACCESS); -- Read the Usn Record for a file
FSCTL_WRITE_USN_CLOSE_RECORD    = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 59,  METHOD_NEITHER, FILE_ANY_ACCESS); -- Generate Close Usn Record
FSCTL_EXTEND_VOLUME             = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 60, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_QUERY_USN_JOURNAL         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 61, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_DELETE_USN_JOURNAL        = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 62, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_MARK_HANDLE               = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 63, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_SIS_COPYFILE              = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 64, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_SIS_LINK_FILES            = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 65, METHOD_BUFFERED, bor(FILE_READ_DATA, FILE_WRITE_DATA));
-- decommissional fsctl value                                             66
-- decommissioned fsctl value                                             67
-- decommissioned fsctl value                                             68
FSCTL_RECALL_FILE               = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 69, METHOD_NEITHER, FILE_ANY_ACCESS);
-- decommissioned fsctl value                                             70
FSCTL_READ_FROM_PLEX            = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 71, METHOD_OUT_DIRECT, FILE_READ_DATA);
FSCTL_FILE_PREFETCH             = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 72, METHOD_BUFFERED, FILE_SPECIAL_ACCESS); -- FILE_PREFETCH
--#endif /* _WIN32_WINNT >= 0x0500 */

--#if (_WIN32_WINNT >= 0x0600);
FSCTL_MAKE_MEDIA_COMPATIBLE         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 76, METHOD_BUFFERED, FILE_WRITE_DATA); -- UDFS R/W
FSCTL_SET_DEFECT_MANAGEMENT         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 77, METHOD_BUFFERED, FILE_WRITE_DATA); -- UDFS R/W
FSCTL_QUERY_SPARING_INFO            = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 78, METHOD_BUFFERED, FILE_ANY_ACCESS); -- UDFS R/W
FSCTL_QUERY_ON_DISK_VOLUME_INFO     = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 79, METHOD_BUFFERED, FILE_ANY_ACCESS); -- C/UDFS
FSCTL_SET_VOLUME_COMPRESSION_STATE  = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 80, METHOD_BUFFERED, FILE_SPECIAL_ACCESS); -- VOLUME_COMPRESSION_STATE
-- decommissioned fsctl value                                                 80
FSCTL_TXFS_MODIFY_RM                = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 81, METHOD_BUFFERED, FILE_WRITE_DATA); -- TxF
FSCTL_TXFS_QUERY_RM_INFORMATION     = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 82, METHOD_BUFFERED, FILE_READ_DATA);  -- TxF
-- decommissioned fsctl value                                                 83
FSCTL_TXFS_ROLLFORWARD_REDO         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 84, METHOD_BUFFERED, FILE_WRITE_DATA); -- TxF
FSCTL_TXFS_ROLLFORWARD_UNDO         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 85, METHOD_BUFFERED, FILE_WRITE_DATA); -- TxF
FSCTL_TXFS_START_RM                 = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 86, METHOD_BUFFERED, FILE_WRITE_DATA); -- TxF
FSCTL_TXFS_SHUTDOWN_RM              = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 87, METHOD_BUFFERED, FILE_WRITE_DATA); -- TxF
FSCTL_TXFS_READ_BACKUP_INFORMATION  = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 88, METHOD_BUFFERED, FILE_READ_DATA);  -- TxF
FSCTL_TXFS_WRITE_BACKUP_INFORMATION = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 89, METHOD_BUFFERED, FILE_WRITE_DATA); -- TxF
FSCTL_TXFS_CREATE_SECONDARY_RM      = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 90, METHOD_BUFFERED, FILE_WRITE_DATA); -- TxF
FSCTL_TXFS_GET_METADATA_INFO        = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 91, METHOD_BUFFERED, FILE_READ_DATA);  -- TxF
FSCTL_TXFS_GET_TRANSACTED_VERSION   = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 92, METHOD_BUFFERED, FILE_READ_DATA);  -- TxF
-- decommissioned fsctl value                                                 93
FSCTL_TXFS_SAVEPOINT_INFORMATION    = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 94, METHOD_BUFFERED, FILE_WRITE_DATA); -- TxF
FSCTL_TXFS_CREATE_MINIVERSION       = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 95, METHOD_BUFFERED, FILE_WRITE_DATA); -- TxF
-- decommissioned fsctl value                                                 96
-- decommissioned fsctl value                                                 97
-- decommissioned fsctl value                                                 98
FSCTL_TXFS_TRANSACTION_ACTIVE       = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 99, METHOD_BUFFERED, FILE_READ_DATA);  -- TxF
FSCTL_SET_ZERO_ON_DEALLOCATION      = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 101, METHOD_BUFFERED, FILE_SPECIAL_ACCESS);
FSCTL_SET_REPAIR                    = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 102, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_GET_REPAIR                    = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 103, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_WAIT_FOR_REPAIR               = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 104, METHOD_BUFFERED, FILE_ANY_ACCESS);
-- decommissioned fsctl value                                                 105
FSCTL_INITIATE_REPAIR               = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 106, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_CSC_INTERNAL                  = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 107, METHOD_NEITHER, FILE_ANY_ACCESS); -- CSC internal implementation
FSCTL_SHRINK_VOLUME                 = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 108, METHOD_BUFFERED, FILE_SPECIAL_ACCESS); -- SHRINK_VOLUME_INFORMATION
FSCTL_SET_SHORT_NAME_BEHAVIOR       = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 109, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_DFSR_SET_GHOST_HANDLE_STATE   = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 110, METHOD_BUFFERED, FILE_ANY_ACCESS);

--
--  Values 111 - 119 are reserved for FSRM.
--

FSCTL_TXFS_LIST_TRANSACTION_LOCKED_FILES = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 120, METHOD_BUFFERED, FILE_READ_DATA); -- TxF
FSCTL_TXFS_LIST_TRANSACTIONS        = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 121, METHOD_BUFFERED, FILE_READ_DATA); -- TxF
FSCTL_QUERY_PAGEFILE_ENCRYPTION     = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 122, METHOD_BUFFERED, FILE_ANY_ACCESS);
-- #endif /* _WIN32_WINNT >= 0x0600 */

--#if (_WIN32_WINNT >= 0x0600);
FSCTL_RESET_VOLUME_ALLOCATION_HINTS = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 123, METHOD_BUFFERED, FILE_ANY_ACCESS);
--#endif /* _WIN32_WINNT >= 0x0600 */

--#if (_WIN32_WINNT >= 0x0601);
FSCTL_QUERY_DEPENDENT_VOLUME        = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 124, METHOD_BUFFERED, FILE_ANY_ACCESS);    -- Dependency File System Filter
FSCTL_SD_GLOBAL_CHANGE              = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 125, METHOD_BUFFERED, FILE_ANY_ACCESS); -- Update NTFS Security Descriptors
--#endif /* _WIN32_WINNT >= 0x0601 */

--#if (_WIN32_WINNT >= 0x0600);
FSCTL_TXFS_READ_BACKUP_INFORMATION2 = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 126, METHOD_BUFFERED, FILE_ANY_ACCESS); -- TxF
--#endif /* _WIN32_WINNT >= 0x0600 */

--#if (_WIN32_WINNT >= 0x0601);
FSCTL_LOOKUP_STREAM_FROM_CLUSTER    = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 127, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_TXFS_WRITE_BACKUP_INFORMATION2 = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 128, METHOD_BUFFERED, FILE_ANY_ACCESS); -- TxF
FSCTL_FILE_TYPE_NOTIFICATION        = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 129, METHOD_BUFFERED, FILE_ANY_ACCESS);
--#endif


--
--  Values 130 - 130 are available
--

--
--  Values 131 - 139 are reserved for FSRM.
--

--#if (_WIN32_WINNT >= 0x0601);
FSCTL_GET_BOOT_AREA_INFO            = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 140, METHOD_BUFFERED, FILE_ANY_ACCESS); -- BOOT_AREA_INFO
FSCTL_GET_RETRIEVAL_POINTER_BASE    = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 141, METHOD_BUFFERED, FILE_ANY_ACCESS); -- RETRIEVAL_POINTER_BASE
FSCTL_SET_PERSISTENT_VOLUME_STATE   = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 142, METHOD_BUFFERED, FILE_ANY_ACCESS);  -- FILE_FS_PERSISTENT_VOLUME_INFORMATION
FSCTL_QUERY_PERSISTENT_VOLUME_STATE = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 143, METHOD_BUFFERED, FILE_ANY_ACCESS);  -- FILE_FS_PERSISTENT_VOLUME_INFORMATION

FSCTL_REQUEST_OPLOCK                = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 144, METHOD_BUFFERED, FILE_ANY_ACCESS);

FSCTL_CSV_TUNNEL_REQUEST            = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 145, METHOD_BUFFERED, FILE_ANY_ACCESS); -- CSV_TUNNEL_REQUEST
FSCTL_IS_CSV_FILE                   = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 146, METHOD_BUFFERED, FILE_ANY_ACCESS); -- IS_CSV_FILE

FSCTL_QUERY_FILE_SYSTEM_RECOGNITION = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 147, METHOD_BUFFERED, FILE_ANY_ACCESS); -- 
FSCTL_CSV_GET_VOLUME_PATH_NAME      = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 148, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_CSV_GET_VOLUME_NAME_FOR_VOLUME_MOUNT_POINT = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 149, METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_CSV_GET_VOLUME_PATH_NAMES_FOR_VOLUME_NAME = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 150,  METHOD_BUFFERED, FILE_ANY_ACCESS);
FSCTL_IS_FILE_ON_CSV_VOLUME         = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 151,  METHOD_BUFFERED, FILE_ANY_ACCESS);

--#endif /* _WIN32_WINNT >= 0x0601 */

FSCTL_MARK_AS_SYSTEM_HIVE         =  FSCTL_SET_BOOTLOADER_ACCESSED;

-- end_ntifs
-- begin_ntddk
--
-- AVIO IOCTLS.
--
--[[
IOCTL_AVIO_ALLOCATE_STREAM      = CTL_CODE(FILE_DEVICE_AVIO, 1, METHOD_BUFFERED, FILE_SPECIAL_ACCESS);
IOCTL_AVIO_FREE_STREAM          = CTL_CODE(FILE_DEVICE_AVIO, 2, METHOD_BUFFERED, FILE_SPECIAL_ACCESS);
IOCTL_AVIO_MODIFY_STREAM        = CTL_CODE(FILE_DEVICE_AVIO, 3, METHOD_BUFFERED, FILE_SPECIAL_ACCESS);
--]]

--#if(_WIN32_WINNT >= 0x0601)

ffi.cdef[[
//
// Structure for FSCTL_IS_CSV_FILE
//

typedef struct _CSV_NAMESPACE_INFO {

    DWORD         Version;
    DWORD         DeviceNumber;
    LARGE_INTEGER StartingOffset;
    DWORD         SectorSize;

} CSV_NAMESPACE_INFO, *PCSV_NAMESPACE_INFO;

static const int CSV_NAMESPACE_INFO_V1 = (sizeof(CSV_NAMESPACE_INFO));
static const int CSV_INVALID_DEVICE_NUMBER = 0xFFFFFFFF;
]]
--#endif /* _WIN32_WINNT >= 0x0601 */

ffi.cdef[[
//
// The following long list of structs are associated with the preceeding
// file system fsctls.
//

//
// Structure for FSCTL_IS_PATHNAME_VALID
//

typedef struct _PATHNAME_BUFFER {

    DWORD PathNameLength;
    WCHAR Name[1];

} PATHNAME_BUFFER, *PPATHNAME_BUFFER;

//
// Structure for FSCTL_QUERY_BPB_INFO
//

typedef struct _FSCTL_QUERY_FAT_BPB_BUFFER {

    BYTE  First0x24BytesOfBootSector[0x24];

} FSCTL_QUERY_FAT_BPB_BUFFER, *PFSCTL_QUERY_FAT_BPB_BUFFER;
]]


--#if (_WIN32_WINNT >= 0x0400)
ffi.cdef[[
//
// Structures for FSCTL_GET_NTFS_VOLUME_DATA.
// The user must pass the basic buffer below.  Ntfs
// will return as many fields as available in the extended
// buffer which follows immediately after the VOLUME_DATA_BUFFER.
//

typedef struct {

    LARGE_INTEGER VolumeSerialNumber;
    LARGE_INTEGER NumberSectors;
    LARGE_INTEGER TotalClusters;
    LARGE_INTEGER FreeClusters;
    LARGE_INTEGER TotalReserved;
    DWORD BytesPerSector;
    DWORD BytesPerCluster;
    DWORD BytesPerFileRecordSegment;
    DWORD ClustersPerFileRecordSegment;
    LARGE_INTEGER MftValidDataLength;
    LARGE_INTEGER MftStartLcn;
    LARGE_INTEGER Mft2StartLcn;
    LARGE_INTEGER MftZoneStart;
    LARGE_INTEGER MftZoneEnd;

} NTFS_VOLUME_DATA_BUFFER, *PNTFS_VOLUME_DATA_BUFFER;

typedef struct {

    DWORD ByteCount;

    WORD   MajorVersion;
    WORD   MinorVersion;

} NTFS_EXTENDED_VOLUME_DATA, *PNTFS_EXTENDED_VOLUME_DATA;
]]
--#endif /* _WIN32_WINNT >= 0x0400 */

--#if (_WIN32_WINNT >= 0x0400)
ffi.cdef[[
//
// Structure for FSCTL_GET_VOLUME_BITMAP
//

typedef struct {
    LARGE_INTEGER StartingLcn;
} STARTING_LCN_INPUT_BUFFER, *PSTARTING_LCN_INPUT_BUFFER;

typedef struct {
    LARGE_INTEGER StartingLcn;
    LARGE_INTEGER BitmapSize;
    BYTE  Buffer[1];
} VOLUME_BITMAP_BUFFER, *PVOLUME_BITMAP_BUFFER;
]]
--#endif /* _WIN32_WINNT >= 0x0400 */

--#if (_WIN32_WINNT >= 0x0400)
ffi.cdef[[
//
// Structure for FSCTL_GET_RETRIEVAL_POINTERS
//

typedef struct {

    LARGE_INTEGER StartingVcn;

} STARTING_VCN_INPUT_BUFFER, *PSTARTING_VCN_INPUT_BUFFER;

typedef struct RETRIEVAL_POINTERS_BUFFER {

    DWORD ExtentCount;
    LARGE_INTEGER StartingVcn;
    struct {
        LARGE_INTEGER NextVcn;
        LARGE_INTEGER Lcn;
    } Extents[1];

} RETRIEVAL_POINTERS_BUFFER, *PRETRIEVAL_POINTERS_BUFFER;
]]
--#endif /* _WIN32_WINNT >= 0x0400 */

--#if (_WIN32_WINNT >= 0x0400)
ffi.cdef[[
//
// Structures for FSCTL_GET_NTFS_FILE_RECORD
//

typedef struct {

    LARGE_INTEGER FileReferenceNumber;

} NTFS_FILE_RECORD_INPUT_BUFFER, *PNTFS_FILE_RECORD_INPUT_BUFFER;

typedef struct {

    LARGE_INTEGER FileReferenceNumber;
    DWORD FileRecordLength;
    BYTE  FileRecordBuffer[1];

} NTFS_FILE_RECORD_OUTPUT_BUFFER, *PNTFS_FILE_RECORD_OUTPUT_BUFFER;
]]
--#endif /* _WIN32_WINNT >= 0x0400 */

--#if (_WIN32_WINNT >= 0x0400)
ffi.cdef[[
//
// Structure for FSCTL_MOVE_FILE
//

typedef struct {

    HANDLE FileHandle;
    LARGE_INTEGER StartingVcn;
    LARGE_INTEGER StartingLcn;
    DWORD ClusterCount;

} MOVE_FILE_DATA, *PMOVE_FILE_DATA;

typedef struct {

    HANDLE FileHandle;
    LARGE_INTEGER SourceFileRecord;
    LARGE_INTEGER TargetFileRecord;

} MOVE_FILE_RECORD_DATA, *PMOVE_FILE_RECORD_DATA;
]]

if _WIN64 then
ffi.cdef[[
//
//  32/64 Bit thunking support structure
//

typedef struct _MOVE_FILE_DATA32 {

    UINT32 FileHandle;
    LARGE_INTEGER StartingVcn;
    LARGE_INTEGER StartingLcn;
    DWORD ClusterCount;

} MOVE_FILE_DATA32, *PMOVE_FILE_DATA32;
]]
end

--#endif /* _WIN32_WINNT >= 0x0400 */

--#if (_WIN32_WINNT >= 0x0500)
ffi.cdef[[
//
// Structures for FSCTL_FIND_FILES_BY_SID
//

typedef struct {
    DWORD Restart;
    SID Sid;
} FIND_BY_SID_DATA, *PFIND_BY_SID_DATA;

typedef struct {
    DWORD NextEntryOffset;
    DWORD FileIndex;
    DWORD FileNameLength;
    WCHAR FileName[1];
} FIND_BY_SID_OUTPUT, *PFIND_BY_SID_OUTPUT;
]]
--#endif /* _WIN32_WINNT >= 0x0500 */

--#if (_WIN32_WINNT >= 0x0500)
ffi.cdef[[
//
//  The following structures apply to Usn operations.
//

//
// Structure for FSCTL_ENUM_USN_DATA
//

typedef struct {

    DWORDLONG StartFileReferenceNumber;
    USN LowUsn;
    USN HighUsn;

} MFT_ENUM_DATA, *PMFT_ENUM_DATA;

//
// Structure for FSCTL_CREATE_USN_JOURNAL
//

typedef struct {

    DWORDLONG MaximumSize;
    DWORDLONG AllocationDelta;

} CREATE_USN_JOURNAL_DATA, *PCREATE_USN_JOURNAL_DATA;

//
// Structure for FSCTL_READ_USN_JOURNAL
//

typedef struct {

    USN StartUsn;
    DWORD ReasonMask;
    DWORD ReturnOnlyOnClose;
    DWORDLONG Timeout;
    DWORDLONG BytesToWaitFor;
    DWORDLONG UsnJournalID;

} READ_USN_JOURNAL_DATA, *PREAD_USN_JOURNAL_DATA;

//
//  The initial Major.Minor version of the Usn record will be 2.0.
//  In general, the MinorVersion may be changed if fields are added
//  to this structure in such a way that the previous version of the
//  software can still correctly the fields it knows about.  The
//  MajorVersion should only be changed if the previous version of
//  any software using this structure would incorrectly handle new
//  records due to structure changes.
//
//  The first update to this will force the structure to version 2.0.
//  This will add the extended information about the source as
//  well as indicate the file name offset within the structure.
//
//  The following structure is returned with these fsctls.
//
//      FSCTL_READ_USN_JOURNAL
//      FSCTL_READ_FILE_USN_DATA
//      FSCTL_ENUM_USN_DATA
//

typedef struct {

    DWORD RecordLength;
    WORD   MajorVersion;
    WORD   MinorVersion;
    DWORDLONG FileReferenceNumber;
    DWORDLONG ParentFileReferenceNumber;
    USN Usn;
    LARGE_INTEGER TimeStamp;
    DWORD Reason;
    DWORD SourceInfo;
    DWORD SecurityId;
    DWORD FileAttributes;
    WORD   FileNameLength;
    WORD   FileNameOffset;
    WCHAR FileName[1];

} USN_RECORD, *PUSN_RECORD;
]]

ffi.cdef[[
static const int USN_PAGE_SIZE                    =(0x1000);

static const int USN_REASON_DATA_OVERWRITE        =(0x00000001);
static const int USN_REASON_DATA_EXTEND           =(0x00000002);
static const int USN_REASON_DATA_TRUNCATION       =(0x00000004);
static const int USN_REASON_NAMED_DATA_OVERWRITE  =(0x00000010);
static const int USN_REASON_NAMED_DATA_EXTEND     =(0x00000020);
static const int USN_REASON_NAMED_DATA_TRUNCATION =(0x00000040);
static const int USN_REASON_FILE_CREATE           =(0x00000100);
static const int USN_REASON_FILE_DELETE           =(0x00000200);
static const int USN_REASON_EA_CHANGE             =(0x00000400);
static const int USN_REASON_SECURITY_CHANGE       =(0x00000800);
static const int USN_REASON_RENAME_OLD_NAME       =(0x00001000);
static const int USN_REASON_RENAME_NEW_NAME       =(0x00002000);
static const int USN_REASON_INDEXABLE_CHANGE      =(0x00004000);
static const int USN_REASON_BASIC_INFO_CHANGE     =(0x00008000);
static const int USN_REASON_HARD_LINK_CHANGE      =(0x00010000);
static const int USN_REASON_COMPRESSION_CHANGE    =(0x00020000);
static const int USN_REASON_ENCRYPTION_CHANGE     =(0x00040000);
static const int USN_REASON_OBJECT_ID_CHANGE      =(0x00080000);
static const int USN_REASON_REPARSE_POINT_CHANGE  =(0x00100000);
static const int USN_REASON_STREAM_CHANGE         =(0x00200000);
static const int USN_REASON_TRANSACTED_CHANGE     =(0x00400000);
static const int USN_REASON_CLOSE                 =(0x80000000);
]]

ffi.cdef[[
//
//  Structure for FSCTL_QUERY_USN_JOUNAL
//

typedef struct {

    DWORDLONG UsnJournalID;
    USN FirstUsn;
    USN NextUsn;
    USN LowestValidUsn;
    USN MaxUsn;
    DWORDLONG MaximumSize;
    DWORDLONG AllocationDelta;

} USN_JOURNAL_DATA, *PUSN_JOURNAL_DATA;

//
//  Structure for FSCTL_DELETE_USN_JOURNAL
//

typedef struct {

    DWORDLONG UsnJournalID;
    DWORD DeleteFlags;

} DELETE_USN_JOURNAL_DATA, *PDELETE_USN_JOURNAL_DATA;
]]

ffi.cdef[[
static const int USN_DELETE_FLAG_DELETE            =  (0x00000001);
static const int USN_DELETE_FLAG_NOTIFY            =  (0x00000002);

static const int USN_DELETE_VALID_FLAGS            =  (0x00000003);
]]

ffi.cdef[[
//
//  Structure for FSCTL_MARK_HANDLE
//

typedef struct {

    DWORD UsnSourceInfo;
    HANDLE VolumeHandle;
    DWORD HandleInfo;

} MARK_HANDLE_INFO, *PMARK_HANDLE_INFO;
]]

if _WIN64 then
ffi.cdef[[
//
//  32/64 Bit thunking support structure
//

typedef struct {

    DWORD UsnSourceInfo;
    UINT32 VolumeHandle;
    DWORD HandleInfo;

} MARK_HANDLE_INFO32, *PMARK_HANDLE_INFO32;
]]
end

ffi.cdef[[
//
//  Flags for the additional source information above.
//
//      USN_SOURCE_DATA_MANAGEMENT - Service is not modifying the external view
//          of any part of the file.  Typical case is HSM moving data to
//          and from external storage.
//
//      USN_SOURCE_AUXILIARY_DATA - Service is not modifying the external view
//          of the file with regard to the application that created this file.
//          Can be used to add private data streams to a file.
//
//      USN_SOURCE_REPLICATION_MANAGEMENT - Service is modifying a file to match
//          the contents of the same file which exists in another member of the
//          replica set.
//

static const int USN_SOURCE_DATA_MANAGEMENT         = (0x00000001);
static const int USN_SOURCE_AUXILIARY_DATA          = (0x00000002);
static const int USN_SOURCE_REPLICATION_MANAGEMENT  = (0x00000004);

//
//  Flags for the HandleInfo field above
//
//  MARK_HANDLE_PROTECT_CLUSTERS - disallow any defragmenting (FSCTL_MOVE_FILE) until the
//      the handle is closed
//
//  MARK_HANDLE_TXF_SYSTEM_LOG - indicates that this stream is being used as the Txf
//      log for an RM on the volume.  Must be called in the kernel using
//      IRP_MN_KERNEL_CALL.
//
//  MARK_HANDLE_NOT_TXF_SYSTEM_LOG - indicates that this user is no longer using this
//      object as a log file.
//

static const int MARK_HANDLE_PROTECT_CLUSTERS       = (0x00000001);
static const int MARK_HANDLE_TXF_SYSTEM_LOG         = (0x00000004);
static const int MARK_HANDLE_NOT_TXF_SYSTEM_LOG     = (0x00000008);
]]

--#endif /* _WIN32_WINNT >= 0x0500 */

--#if (_WIN32_WINNT >= 0x0601)
ffi.cdef[[
static const int MARK_HANDLE_REALTIME               = (0x00000020);
static const int MARK_HANDLE_NOT_REALTIME           = (0x00000040);

static const int NO_8DOT3_NAME_PRESENT              = (0x00000001);
static const int REMOVED_8DOT3_NAME                 = (0x00000002);

static const int PERSISTENT_VOLUME_STATE_SHORT_NAME_CREATION_DISABLED       = (0x00000001);
]]
--#endif /* _WIN32_WINNT >= 0x0601 */


--#if (_WIN32_WINNT >= 0x0500)
ffi.cdef[[
//
// Structure for FSCTL_SECURITY_ID_CHECK
//

typedef struct {

    ACCESS_MASK DesiredAccess;
    DWORD SecurityIds[1];

} BULK_SECURITY_TEST_DATA, *PBULK_SECURITY_TEST_DATA;
]]
--#endif /* _WIN32_WINNT >= 0x0500 */

--#if (_WIN32_WINNT >= 0x0500)
ffi.cdef[[
//
//  Output flags for the FSCTL_IS_VOLUME_DIRTY
//

static const int VOLUME_IS_DIRTY                 = (0x00000001);
static const int VOLUME_UPGRADE_SCHEDULED        = (0x00000002);
static const int VOLUME_SESSION_OPEN             = (0x00000004);
]]
--#endif /* _WIN32_WINNT >= 0x0500 */

--#if (_WIN32_WINNT >= 0x0500)
ffi.cdef[[
//
// Structures for FSCTL_FILE_PREFETCH
//

typedef struct _FILE_PREFETCH {
    DWORD Type;
    DWORD Count;
    DWORDLONG Prefetch[1];
} FILE_PREFETCH, *PFILE_PREFETCH;

typedef struct _FILE_PREFETCH_EX {
    DWORD Type;
    DWORD Count;
    PVOID Context;
    DWORDLONG Prefetch[1];
} FILE_PREFETCH_EX, *PFILE_PREFETCH_EX;

static const int FILE_PREFETCH_TYPE_FOR_CREATE      = 0x1;
static const int FILE_PREFETCH_TYPE_FOR_DIRENUM     = 0x2;
static const int FILE_PREFETCH_TYPE_FOR_CREATE_EX   = 0x3;
static const int FILE_PREFETCH_TYPE_FOR_DIRENUM_EX  = 0x4;

static const int FILE_PREFETCH_TYPE_MAX             = 0x4;
]]
--#endif /* _WIN32_WINNT >= 0x0500 */

ffi.cdef[[
//
// Structures for FSCTL_FILESYSTEM_GET_STATISTICS
//
// Filesystem performance counters
//

typedef struct _FILESYSTEM_STATISTICS {

    WORD   FileSystemType;
    WORD   Version;                     // currently version 1

    DWORD SizeOfCompleteStructure;      // must by a mutiple of 64 bytes

    DWORD UserFileReads;
    DWORD UserFileReadBytes;
    DWORD UserDiskReads;
    DWORD UserFileWrites;
    DWORD UserFileWriteBytes;
    DWORD UserDiskWrites;

    DWORD MetaDataReads;
    DWORD MetaDataReadBytes;
    DWORD MetaDataDiskReads;
    DWORD MetaDataWrites;
    DWORD MetaDataWriteBytes;
    DWORD MetaDataDiskWrites;

    //
    //  The file system's private structure is appended here.
    //

} FILESYSTEM_STATISTICS, *PFILESYSTEM_STATISTICS;
]]

ffi.cdef[[
// values for FS_STATISTICS.FileSystemType

static const int FILESYSTEM_STATISTICS_TYPE_NTFS    = 1;
static const int FILESYSTEM_STATISTICS_TYPE_FAT     = 2;
static const int FILESYSTEM_STATISTICS_TYPE_EXFAT   = 3;

//
//  File System Specific Statistics Data
//

typedef struct _FAT_STATISTICS {
    DWORD CreateHits;
    DWORD SuccessfulCreates;
    DWORD FailedCreates;

    DWORD NonCachedReads;
    DWORD NonCachedReadBytes;
    DWORD NonCachedWrites;
    DWORD NonCachedWriteBytes;

    DWORD NonCachedDiskReads;
    DWORD NonCachedDiskWrites;
} FAT_STATISTICS, *PFAT_STATISTICS;

typedef struct _EXFAT_STATISTICS {
    DWORD CreateHits;
    DWORD SuccessfulCreates;
    DWORD FailedCreates;

    DWORD NonCachedReads;
    DWORD NonCachedReadBytes;
    DWORD NonCachedWrites;
    DWORD NonCachedWriteBytes;

    DWORD NonCachedDiskReads;
    DWORD NonCachedDiskWrites;
} EXFAT_STATISTICS, *PEXFAT_STATISTICS;

typedef struct _NTFS_STATISTICS {

    DWORD LogFileFullExceptions;
    DWORD OtherExceptions;

    //
    // Other meta data io's
    //

    DWORD MftReads;
    DWORD MftReadBytes;
    DWORD MftWrites;
    DWORD MftWriteBytes;
    struct {
        WORD   Write;
        WORD   Create;
        WORD   SetInfo;
        WORD   Flush;
    } MftWritesUserLevel;

    WORD   MftWritesFlushForLogFileFull;
    WORD   MftWritesLazyWriter;
    WORD   MftWritesUserRequest;

    DWORD Mft2Writes;
    DWORD Mft2WriteBytes;
    struct {
        WORD   Write;
        WORD   Create;
        WORD   SetInfo;
        WORD   Flush;
    } Mft2WritesUserLevel;

    WORD   Mft2WritesFlushForLogFileFull;
    WORD   Mft2WritesLazyWriter;
    WORD   Mft2WritesUserRequest;

    DWORD RootIndexReads;
    DWORD RootIndexReadBytes;
    DWORD RootIndexWrites;
    DWORD RootIndexWriteBytes;

    DWORD BitmapReads;
    DWORD BitmapReadBytes;
    DWORD BitmapWrites;
    DWORD BitmapWriteBytes;

    WORD   BitmapWritesFlushForLogFileFull;
    WORD   BitmapWritesLazyWriter;
    WORD   BitmapWritesUserRequest;

    struct {
        WORD   Write;
        WORD   Create;
        WORD   SetInfo;
    } BitmapWritesUserLevel;

    DWORD MftBitmapReads;
    DWORD MftBitmapReadBytes;
    DWORD MftBitmapWrites;
    DWORD MftBitmapWriteBytes;

    WORD   MftBitmapWritesFlushForLogFileFull;
    WORD   MftBitmapWritesLazyWriter;
    WORD   MftBitmapWritesUserRequest;

    struct {
        WORD   Write;
        WORD   Create;
        WORD   SetInfo;
        WORD   Flush;
    } MftBitmapWritesUserLevel;

    DWORD UserIndexReads;
    DWORD UserIndexReadBytes;
    DWORD UserIndexWrites;
    DWORD UserIndexWriteBytes;

    //
    // Additions for NT 5.0
    //

    DWORD LogFileReads;
    DWORD LogFileReadBytes;
    DWORD LogFileWrites;
    DWORD LogFileWriteBytes;

    struct {
        DWORD Calls;                // number of individual calls to allocate clusters
        DWORD Clusters;             // number of clusters allocated
        DWORD Hints;                // number of times a hint was specified

        DWORD RunsReturned;         // number of runs used to satisify all the requests

        DWORD HintsHonored;         // number of times the hint was useful
        DWORD HintsClusters;        // number of clusters allocated via the hint
        DWORD Cache;                // number of times the cache was useful other than the hint
        DWORD CacheClusters;        // number of clusters allocated via the cache other than the hint
        DWORD CacheMiss;            // number of times the cache wasn't useful
        DWORD CacheMissClusters;    // number of clusters allocated without the cache
    } Allocate;

} NTFS_STATISTICS, *PNTFS_STATISTICS;
]]


--#if (_WIN32_WINNT >= 0x0500)
ffi.cdef[[
//
// Structure for FSCTL_SET_OBJECT_ID, FSCTL_GET_OBJECT_ID, and FSCTL_CREATE_OR_GET_OBJECT_ID
//


typedef struct _FILE_OBJECTID_BUFFER {

    //
    //  This is the portion of the object id that is indexed.
    //

    BYTE  ObjectId[16];

    //
    //  This portion of the object id is not indexed, it's just
    //  some metadata for the user's benefit.
    //

    union {
        struct {
            BYTE  BirthVolumeId[16];
            BYTE  BirthObjectId[16];
            BYTE  DomainId[16];
        } DUMMYSTRUCTNAME;
        BYTE  ExtendedInfo[48];
    } DUMMYUNIONNAME;

} FILE_OBJECTID_BUFFER, *PFILE_OBJECTID_BUFFER;
]]

-- #endif /* _WIN32_WINNT >= 0x0500 */


--#if (_WIN32_WINNT >= 0x0500)
ffi.cdef[[
//
// Structure for FSCTL_SET_SPARSE
//

typedef struct _FILE_SET_SPARSE_BUFFER {
    BOOLEAN SetSparse;
} FILE_SET_SPARSE_BUFFER, *PFILE_SET_SPARSE_BUFFER;
]]

--#endif /* _WIN32_WINNT >= 0x0500 */


--#if (_WIN32_WINNT >= 0x0500)
ffi.cdef[[
//
// Structure for FSCTL_SET_ZERO_DATA
//

typedef struct _FILE_ZERO_DATA_INFORMATION {

    LARGE_INTEGER FileOffset;
    LARGE_INTEGER BeyondFinalZero;

} FILE_ZERO_DATA_INFORMATION, *PFILE_ZERO_DATA_INFORMATION;
]]
--#endif /* _WIN32_WINNT >= 0x0500 */

--#if (_WIN32_WINNT >= 0x0500)
ffi.cdef[[
//
// Structure for FSCTL_QUERY_ALLOCATED_RANGES
//

//
// Querying the allocated ranges requires an output buffer to store the
// allocated ranges and an input buffer to specify the range to query.
// The input buffer contains a single entry, the output buffer is an
// array of the following structure.
//

typedef struct _FILE_ALLOCATED_RANGE_BUFFER {

    LARGE_INTEGER FileOffset;
    LARGE_INTEGER Length;

} FILE_ALLOCATED_RANGE_BUFFER, *PFILE_ALLOCATED_RANGE_BUFFER;
]]
--#endif /* _WIN32_WINNT >= 0x0500 */


--#if (_WIN32_WINNT >= 0x0500)
ffi.cdef[[
//
// Structures for FSCTL_SET_ENCRYPTION, FSCTL_WRITE_RAW_ENCRYPTED, and FSCTL_READ_RAW_ENCRYPTED
//

//
//  The input buffer to set encryption indicates whether we are to encrypt/decrypt a file
//  or an individual stream.
//

typedef struct _ENCRYPTION_BUFFER {

    DWORD EncryptionOperation;
    BYTE  Private[1];

} ENCRYPTION_BUFFER, *PENCRYPTION_BUFFER;

static const int FILE_SET_ENCRYPTION        = 0x00000001;
static const int FILE_CLEAR_ENCRYPTION      = 0x00000002;
static const int STREAM_SET_ENCRYPTION      = 0x00000003;
static const int STREAM_CLEAR_ENCRYPTION    = 0x00000004;

static const int MAXIMUM_ENCRYPTION_VALUE   = 0x00000004;

//
//  The optional output buffer to set encryption indicates that the last encrypted
//  stream in a file has been marked as decrypted.
//

typedef struct _DECRYPTION_STATUS_BUFFER {

    BOOLEAN NoEncryptedStreams;

} DECRYPTION_STATUS_BUFFER, *PDECRYPTION_STATUS_BUFFER;

static const int ENCRYPTION_FORMAT_DEFAULT       = (0x01);

static const int COMPRESSION_FORMAT_SPARSE       = (0x4000);

//
//  Request Encrypted Data structure.  This is used to indicate
//  the range of the file to read.  It also describes the
//  output buffer used to return the data.
//

typedef struct _REQUEST_RAW_ENCRYPTED_DATA {

    //
    //  Requested file offset and requested length to read.
    //  The fsctl will round the starting offset down
    //  to a file system boundary.  It will also
    //  round the length up to a file system boundary.
    //

    LONGLONG FileOffset;
    DWORD Length;

} REQUEST_RAW_ENCRYPTED_DATA, *PREQUEST_RAW_ENCRYPTED_DATA;

//
//  Encrypted Data Information structure.  This structure
//  is used to return raw encrypted data from a file in
//  order to perform off-line recovery.  The data will be
//  encrypted or encrypted and compressed.  The off-line
//  service will need to use the encryption and compression
//  format information to recover the file data.  In the
//  event that the data is both encrypted and compressed then
//  the decryption must occur before decompression.  All
//  the data units below must be encrypted and compressed
//  with the same format.
//
//  The data will be returned in units.  The data unit size
//  will be fixed per request.  If the data is compressed
//  then the data unit size will be the compression unit size.
//
//  This structure is at the beginning of the buffer used to
//  return the encrypted data.  The actual raw bytes from
//  the file will follow this buffer.  The offset of the
//  raw bytes from the beginning of this structure is
//  specified in the REQUEST_RAW_ENCRYPTED_DATA structure
//  described above.
//

typedef struct _ENCRYPTED_DATA_INFO {

    //
    //  This is the file offset for the first entry in the
    //  data block array.  The file system will round
    //  the requested start offset down to a boundary
    //  that is consistent with the format of the file.
    //

    DWORDLONG StartingFileOffset;

    //
    //  Data offset in output buffer.  The output buffer
    //  begins with an ENCRYPTED_DATA_INFO structure.
    //  The file system will then store the raw bytes from
    //  disk beginning at the following offset within the
    //  output buffer.
    //

    DWORD OutputBufferOffset;

    //
    //  The number of bytes being returned that are within
    //  the size of the file.  If this value is less than
    //  (NumberOfDataBlocks << DataUnitShift), it means the
    //  end of the file occurs within this transfer.  Any
    //  data beyond file size is invalid and was never
    //  passed to the encryption driver.
    //

    DWORD BytesWithinFileSize;

    //
    //  The number of bytes being returned that are below
    //  valid data length.  If this value is less than
    //  (NumberOfDataBlocks << DataUnitShift), it means the
    //  end of the valid data occurs within this transfer.
    //  After decrypting the data from this transfer, any
    //  byte(s) beyond valid data length must be zeroed.
    //

    DWORD BytesWithinValidDataLength;

    //
    //  Code for the compression format as defined in
    //  ntrtl.h.  Note that COMPRESSION_FORMAT_NONE
    //  and COMPRESSION_FORMAT_DEFAULT are invalid if
    //  any of the described chunks are compressed.
    //

    WORD   CompressionFormat;

    //
    //  The DataUnit is the granularity used to access the
    //  disk.  It will be the same as the compression unit
    //  size for a compressed file.  For an uncompressed
    //  file, it will be some cluster-aligned power of 2 that
    //  the file system deems convenient.  A caller should
    //  not expect that successive calls will have the
    //  same data unit shift value as the previous call.
    //
    //  Since chunks and compression units are expected to be
    //  powers of 2 in size, we express them log2.  So, for
    //  example (1 << ChunkShift) == ChunkSizeInBytes.  The
    //  ClusterShift indicates how much space must be saved
    //  to successfully compress a compression unit - each
    //  successfully compressed data unit must occupy
    //  at least one cluster less in bytes than an uncompressed
    //  data block unit.
    //

    BYTE  DataUnitShift;
    BYTE  ChunkShift;
    BYTE  ClusterShift;

    //
    //  The format for the encryption.
    //

    BYTE  EncryptionFormat;

    //
    //  This is the number of entries in the data block size
    //  array.
    //

    WORD   NumberOfDataBlocks;

    //
    //  This is an array of sizes in the data block array.  There
    //  must be one entry in this array for each data block
    //  read from disk.  The size has a different meaning
    //  depending on whether the file is compressed.
    //
    //  A size of zero always indicates that the final data consists entirely
    //  of zeroes.  There is no decryption or decompression to
    //  perform.
    //
    //  If the file is compressed then the data block size indicates
    //  whether this block is compressed.  A size equal to
    //  the block size indicates that the corresponding block did
    //  not compress.  Any other non-zero size indicates the
    //  size of the compressed data which needs to be
    //  decrypted/decompressed.
    //
    //  If the file is not compressed then the data block size
    //  indicates the amount of data within the block that
    //  needs to be decrypted.  Any other non-zero size indicates
    //  that the remaining bytes in the data unit within the file
    //  consists of zeros.  An example of this is when the
    //  the read spans the valid data length of the file.  There
    //  is no data to decrypt past the valid data length.
    //

    DWORD DataBlockSize[ANYSIZE_ARRAY];

} ENCRYPTED_DATA_INFO;
typedef ENCRYPTED_DATA_INFO *PENCRYPTED_DATA_INFO;
]]
--#endif /* _WIN32_WINNT >= 0x0500 */


--#if (_WIN32_WINNT >= 0x0500)
ffi.cdef[[
//
//  FSCTL_READ_FROM_PLEX support
//  Request Plex Read Data structure.  This is used to indicate
//  the range of the file to read.  It also describes
//  which plex to perform the read from.
//

typedef struct _PLEX_READ_DATA_REQUEST {

    //
    //  Requested offset and length to read.
    //  The offset can be the virtual offset (vbo) in to a file,
    //  or a volume. In the case of a file offset,
    //  the fsd will round the starting offset down
    //  to a file system boundary.  It will also
    //  round the length up to a file system boundary and
    //  enforce any other applicable limits.
    //

    LARGE_INTEGER ByteOffset;
    DWORD ByteLength;
    DWORD PlexNumber;

} PLEX_READ_DATA_REQUEST, *PPLEX_READ_DATA_REQUEST;
]]
--#endif /* _WIN32_WINNT >= 0x0500 */

--#if (_WIN32_WINNT >= 0x0500)
ffi.cdef[[
//
// FSCTL_SIS_COPYFILE support
// Source and destination file names are passed in the FileNameBuffer.
// Both strings are null terminated, with the source name starting at
// the beginning of FileNameBuffer, and the destination name immediately
// following.  Length fields include terminating nulls.
//

typedef struct _SI_COPYFILE {
    DWORD SourceFileNameLength;
    DWORD DestinationFileNameLength;
    DWORD Flags;
    WCHAR FileNameBuffer[1];
} SI_COPYFILE, *PSI_COPYFILE;

static const int COPYFILE_SIS_LINK     =  0x0001;              // Copy only if source is SIS
static const int COPYFILE_SIS_REPLACE  =  0x0002;              // Replace destination if it exists, otherwise don't.
static const int COPYFILE_SIS_FLAGS    =  0x0003;
]]
--#endif /* _WIN32_WINNT >= 0x0500 */

--#if (_WIN32_WINNT >= 0x0600)
ffi.cdef[[
//
//  Input parameter structure for FSCTL_MAKE_COMPATIBLE
//

typedef struct _FILE_MAKE_COMPATIBLE_BUFFER {
    BOOLEAN CloseDisc;
} FILE_MAKE_COMPATIBLE_BUFFER, *PFILE_MAKE_COMPATIBLE_BUFFER;

//
//  Input parameter structure for FSCTL_SET_DEFECT_MANAGEMENT
//

typedef struct _FILE_SET_DEFECT_MGMT_BUFFER {
    BOOLEAN Disable;
} FILE_SET_DEFECT_MGMT_BUFFER, *PFILE_SET_DEFECT_MGMT_BUFFER;

//
//  Output structure for FSCTL_QUERY_SPARING_INFO
//

typedef struct _FILE_QUERY_SPARING_BUFFER {
    DWORD SparingUnitBytes;
    BOOLEAN SoftwareSparing;
    DWORD TotalSpareBlocks;
    DWORD FreeSpareBlocks;
} FILE_QUERY_SPARING_BUFFER, *PFILE_QUERY_SPARING_BUFFER;

//
//  Output structure for FSCTL_QUERY_ON_DISK_VOLUME_INFO
//

typedef struct _FILE_QUERY_ON_DISK_VOL_INFO_BUFFER {
    LARGE_INTEGER DirectoryCount;       // -1 = unknown
    LARGE_INTEGER FileCount;            // -1 = unknown
    WORD   FsFormatMajVersion;          // -1 = unknown or n/a
    WORD   FsFormatMinVersion;          // -1 = unknown or n/a
    WCHAR FsFormatName[ 12];
    LARGE_INTEGER FormatTime;
    LARGE_INTEGER LastUpdateTime;
    WCHAR CopyrightInfo[ 34];
    WCHAR AbstractInfo[ 34];
    WCHAR FormattingImplementationInfo[ 34];
    WCHAR LastModifyingImplementationInfo[ 34];
} FILE_QUERY_ON_DISK_VOL_INFO_BUFFER, *PFILE_QUERY_ON_DISK_VOL_INFO_BUFFER;
]]

ffi.cdef[[
//
//  Input flags for FSCTL_SET_REPAIR
//

static const int SET_REPAIR_ENABLED                                     = (0x00000001);
static const int SET_REPAIR_VOLUME_BITMAP_SCAN                          = (0x00000002);
static const int SET_REPAIR_DELETE_CROSSLINK                            = (0x00000004);
static const int SET_REPAIR_WARN_ABOUT_DATA_LOSS                        = (0x00000008);
static const int SET_REPAIR_DISABLED_AND_BUGCHECK_ON_CORRUPT            = (0x00000010);
static const int SET_REPAIR_VALID_MASK                                  = (0x0000001F);
]]

ffi.cdef[[
//
//  Input structures for FSCTL_SHRINK_VOLUME.
//

typedef enum _SHRINK_VOLUME_REQUEST_TYPES
{
    ShrinkPrepare = 1,
    ShrinkCommit,
    ShrinkAbort

} SHRINK_VOLUME_REQUEST_TYPES, *PSHRINK_VOLUME_REQUEST_TYPES;

typedef struct _SHRINK_VOLUME_INFORMATION
{
    SHRINK_VOLUME_REQUEST_TYPES ShrinkRequestType;
    DWORDLONG Flags;
    LONGLONG NewNumberOfSectors;

} SHRINK_VOLUME_INFORMATION, *PSHRINK_VOLUME_INFORMATION;
]]

ffi.cdef[[
//
//  Structures for FSCTL_TXFS_MODIFY_RM and FSCTL_TXFS_QUERY_RM_INFORMATION
//
//  For ModifyRM, TXFS_RM_FLAG_LOG_GROWTH_INCREMENT_NUM_CONTAINERS and
//  TXFS_RM_FLAG_LOG_GROWTH_INCREMENT_PERCENT are mutually exclusive.
//  You can specify the log growth amount in number of containers or as a percentage.
//
//  For ModifyRM, TXFS_RM_FLAG_LOG_CONTAINER_COUNT_MAX and
//  TXFS_RM_FLAG_LOG_NO_CONTAINER_COUNT_MAX are mutually exclusive.
//
//  For ModifyRM, TXFS_RM_FLAG_LOG_CONTAINER_COUNT_MIN and
//  TXFS_RM_FLAG_LOG_NO_CONTAINER_COUNT_MIN are mutually exclusive.
//
//  For ModifyRM, TXFS_RM_FLAG_RESET_RM_AT_NEXT_START and
//  TXFS_RM_FLAG_DO_NOT_RESET_RM_AT_NEXT_START are mutually exclusive and only
//  apply to default RMs.
//
//  For ModifyRM, TXFS_RM_FLAG_PREFER_CONSISTENCY and
//  TXFS_RM_FLAG_PREFER_AVAILABILITY are mutually exclusive.  After calling ModifyRM
//  with one of these flags set the RM must be restarted for the change to take effect.
//

static const int TXFS_RM_FLAG_LOGGING_MODE                         =  0x00000001;
static const int TXFS_RM_FLAG_RENAME_RM                            =  0x00000002;
static const int TXFS_RM_FLAG_LOG_CONTAINER_COUNT_MAX              =  0x00000004;
static const int TXFS_RM_FLAG_LOG_CONTAINER_COUNT_MIN              =  0x00000008;
static const int TXFS_RM_FLAG_LOG_GROWTH_INCREMENT_NUM_CONTAINERS  =  0x00000010;
static const int TXFS_RM_FLAG_LOG_GROWTH_INCREMENT_PERCENT         = 0x00000020;
static const int TXFS_RM_FLAG_LOG_AUTO_SHRINK_PERCENTAGE           =  0x00000040;
static const int TXFS_RM_FLAG_LOG_NO_CONTAINER_COUNT_MAX           =  0x00000080;
static const int TXFS_RM_FLAG_LOG_NO_CONTAINER_COUNT_MIN           =  0x00000100;
static const int TXFS_RM_FLAG_GROW_LOG                             =  0x00000400;
static const int TXFS_RM_FLAG_SHRINK_LOG                           =  0x00000800;
static const int TXFS_RM_FLAG_ENFORCE_MINIMUM_SIZE                 =  0x00001000;
static const int TXFS_RM_FLAG_PRESERVE_CHANGES                     =  0x00002000;
static const int TXFS_RM_FLAG_RESET_RM_AT_NEXT_START               =  0x00004000;
static const int TXFS_RM_FLAG_DO_NOT_RESET_RM_AT_NEXT_START        =  0x00008000;
static const int TXFS_RM_FLAG_PREFER_CONSISTENCY                   =  0x00010000;
static const int TXFS_RM_FLAG_PREFER_AVAILABILITY                  =  0x00020000;

static const int TXFS_LOGGING_MODE_SIMPLE       = (0x0001);
static const int TXFS_LOGGING_MODE_FULL         = (0x0002);

static const int TXFS_TRANSACTION_STATE_NONE        = 0x00;
static const int TXFS_TRANSACTION_STATE_ACTIVE      = 0x01;
static const int TXFS_TRANSACTION_STATE_PREPARED    = 0x02;
static const int TXFS_TRANSACTION_STATE_NOTACTIVE   = 0x03;

static const int TXFS_MODIFY_RM_VALID_FLAGS                  =                    \
                (TXFS_RM_FLAG_LOGGING_MODE                          |   \
                 TXFS_RM_FLAG_RENAME_RM                             |   \
                 TXFS_RM_FLAG_LOG_CONTAINER_COUNT_MAX               |   \
                 TXFS_RM_FLAG_LOG_CONTAINER_COUNT_MIN               |   \
                 TXFS_RM_FLAG_LOG_GROWTH_INCREMENT_NUM_CONTAINERS   |   \
                 TXFS_RM_FLAG_LOG_GROWTH_INCREMENT_PERCENT          |   \
                 TXFS_RM_FLAG_LOG_AUTO_SHRINK_PERCENTAGE            |   \
                 TXFS_RM_FLAG_LOG_NO_CONTAINER_COUNT_MAX            |   \
                 TXFS_RM_FLAG_LOG_NO_CONTAINER_COUNT_MIN            |   \
                 TXFS_RM_FLAG_SHRINK_LOG                            |   \
                 TXFS_RM_FLAG_GROW_LOG                              |   \
                 TXFS_RM_FLAG_ENFORCE_MINIMUM_SIZE                  |   \
                 TXFS_RM_FLAG_PRESERVE_CHANGES                      |   \
                 TXFS_RM_FLAG_RESET_RM_AT_NEXT_START                |   \
                 TXFS_RM_FLAG_DO_NOT_RESET_RM_AT_NEXT_START         |   \
                 TXFS_RM_FLAG_PREFER_CONSISTENCY                    |   \
                 TXFS_RM_FLAG_PREFER_AVAILABILITY);
]]

ffi.cdef[[
typedef struct _TXFS_MODIFY_RM {

    //
    //  TXFS_RM_FLAG_* flags
    //

    DWORD Flags;

    //
    //  Maximum log container count if TXFS_RM_FLAG_LOG_CONTAINER_COUNT_MAX is set.
    //

    DWORD LogContainerCountMax;

    //
    //  Minimum log container count if TXFS_RM_FLAG_LOG_CONTAINER_COUNT_MIN is set.
    //

    DWORD LogContainerCountMin;

    //
    //  Target log container count for TXFS_RM_FLAG_SHRINK_LOG or _GROW_LOG.
    //

    DWORD LogContainerCount;

    //
    //  When the log is full, increase its size by this much.  Indicated as either a percent of
    //  the log size or absolute container count, depending on which of the TXFS_RM_FLAG_LOG_GROWTH_INCREMENT_*
    //  flags is set.
    //

    DWORD LogGrowthIncrement;

    //
    //  Sets autoshrink policy if TXFS_RM_FLAG_LOG_AUTO_SHRINK_PERCENTAGE is set.  Autoshrink
    //  makes the log shrink so that no more than this percentage of the log is free at any time.
    //

    DWORD LogAutoShrinkPercentage;

    //
    //  Reserved.
    //

    DWORDLONG Reserved;

    //
    //  If TXFS_RM_FLAG_LOGGING_MODE is set, this must contain one of TXFS_LOGGING_MODE_SIMPLE
    //  or TXFS_LOGGING_MODE_FULL.
    //

    WORD   LoggingMode;

} TXFS_MODIFY_RM,
 *PTXFS_MODIFY_RM;
]]

ffi.cdef[[
static const int TXFS_RM_STATE_NOT_STARTED      = 0;
static const int TXFS_RM_STATE_STARTING         = 1;
static const int TXFS_RM_STATE_ACTIVE           = 2;
static const int TXFS_RM_STATE_SHUTTING_DOWN    = 3;
]]

ffi.cdef[[
//
//  The flags field for query RM information is used for the following information:
//
//  1)  To indicate whether the LogGrowthIncrement field is reported as a percent
//      or as a number of containers.  Possible flag values for this are:
//
//      TXFS_RM_FLAG_LOG_GROWTH_INCREMENT_NUM_CONTAINERS xor TXFS_RM_FLAG_LOG_GROWTH_INCREMENT_PERCENT
//
//  2)  To indicate that there is no set maximum or minimum container count.  Possible
//      flag values for this are:
//
//      TXFS_RM_FLAG_LOG_NO_CONTAINER_COUNT_MAX
//      TXFS_RM_FLAG_LOG_NO_CONTAINER_COUNT_MIN
//
//      Note that these flags are not mutually exclusive.
//
//  2)  To report whether the RM will be reset the next time it is started.  Note that
//      only the default RM will report a meaningful value (secondary RMs will always
//      report DO_NOT_RESET) Possible flag values for this are:
//
//      TXFS_RM_FLAG_RESET_RM_AT_NEXT_START xor TXFS_RM_FLAG_DO_NOT_RESET_RM_AT_NEXT_START
//
//  3)  To report whether the RM is in consistency mode or availability mode.  Possible
//      flag values for this are:
//
//      TXFS_RM_FLAG_PREFER_CONSISTENCY xor TXFS_RM_FLAG_PREFER_AVAILABILITY
//
//  The RmState field can have exactly one of the above-defined TXF_RM_STATE_ values.
//

static const int TXFS_QUERY_RM_INFORMATION_VALID_FLAGS =                          \
                (TXFS_RM_FLAG_LOG_GROWTH_INCREMENT_NUM_CONTAINERS   |   \
                 TXFS_RM_FLAG_LOG_GROWTH_INCREMENT_PERCENT          |   \
                 TXFS_RM_FLAG_LOG_NO_CONTAINER_COUNT_MAX            |   \
                 TXFS_RM_FLAG_LOG_NO_CONTAINER_COUNT_MIN            |   \
                 TXFS_RM_FLAG_RESET_RM_AT_NEXT_START                |   \
                 TXFS_RM_FLAG_DO_NOT_RESET_RM_AT_NEXT_START         |   \
                 TXFS_RM_FLAG_PREFER_CONSISTENCY                    |   \
                 TXFS_RM_FLAG_PREFER_AVAILABILITY);
]]

ffi.cdef[[
typedef struct _TXFS_QUERY_RM_INFORMATION {

    //
    //  If the return value is STATUS_BUFFER_OVERFLOW (ERROR_MORE_DATA), this
    //  will indicate how much space is required to hold everything.
    //

    DWORD BytesRequired;

    //
    //  LSN of earliest available record in the RM's log.
    //

    DWORDLONG TailLsn;

    //
    //  LSN of most recently-written record in the RM's log.
    //

    DWORDLONG CurrentLsn;

    //
    //  LSN of the log's archive tail.
    //

    DWORDLONG ArchiveTailLsn;

    //
    //  Size of a log container in bytes.
    //

    DWORDLONG LogContainerSize;

    //
    //  Highest virtual clock value recorded in this RM's log.
    //

    LARGE_INTEGER HighestVirtualClock;

    //
    //  Number of containers in this RM's log.
    //

    DWORD LogContainerCount;

    //
    //  Maximum-allowed log container count.
    //

    DWORD LogContainerCountMax;

    //
    //  Minimum-allowed log container count.
    //

    DWORD LogContainerCountMin;

    //
    //  Amount by which log will grow when it gets full.  Indicated as either a percent of
    //  the log size or absolute container count, depending on which of the TXFS_RM_FLAG_LOG_GROWTH_INCREMENT_*
    //  flags is set.
    //

    DWORD LogGrowthIncrement;

    //
    //  Reports on the autoshrink policy if.  Autoshrink makes the log shrink so that no more than this
    //  percentage of the log is free at any time.  A value of 0 indicates that autoshrink is off (i.e.
    //  the log will not automatically shrink).
    //

    DWORD LogAutoShrinkPercentage;

    //
    //  TXFS_RM_FLAG_* flags.  See the comment above at TXFS_QUERY_RM_INFORMATION_VALID_FLAGS to see
    //  what the flags here mean.
    //

    DWORD Flags;

    //
    //  Exactly one of TXFS_LOGGING_MODE_SIMPLE or TXFS_LOGGING_MODE_FULL.
    //

    WORD   LoggingMode;

    //
    //  Reserved.
    //

    WORD   Reserved;

    //
    //  Activity state of the RM.  May be exactly one of the above-defined TXF_RM_STATE_ values.
    //

    DWORD RmState;

    //
    //  Total capacity of the log in bytes.
    //

    DWORDLONG LogCapacity;

    //
    //  Amount of free space in the log in bytes.
    //

    DWORDLONG LogFree;

    //
    //  Size of $Tops in bytes.
    //

    DWORDLONG TopsSize;

    //
    //  Amount of space in $Tops in use.
    //

    DWORDLONG TopsUsed;

    //
    //  Number of transactions active in the RM at the time of the call.
    //

    DWORDLONG TransactionCount;

    //
    //  Total number of single-phase commits that have happened the RM.
    //

    DWORDLONG OnePCCount;

    //
    //  Total number of two-phase commits that have happened the RM.
    //

    DWORDLONG TwoPCCount;

    //
    //  Number of times the log has filled up.
    //

    DWORDLONG NumberLogFileFull;

    //
    //  Age of oldest active transaction in the RM, in milliseconds.
    //

    DWORDLONG OldestTransactionAge;

    //
    //  Name of the RM.
    //

    GUID RMName;

    //
    //  Offset in bytes from the beginning of this structure to a NULL-terminated Unicode
    //  string indicating the path to the RM's transaction manager's log.
    //

    DWORD TmLogPathOffset;

} TXFS_QUERY_RM_INFORMATION,
 *PTXFS_QUERY_RM_INFORMATION;
]]

ffi.cdef[[
//
// Structures for FSCTL_TXFS_ROLLFORWARD_REDO
//

static const int TXFS_ROLLFORWARD_REDO_FLAG_USE_LAST_REDO_LSN       = 0x01;
static const int TXFS_ROLLFORWARD_REDO_FLAG_USE_LAST_VIRTUAL_CLOCK  = 0x02;

static const int TXFS_ROLLFORWARD_REDO_VALID_FLAGS =                              \
                (TXFS_ROLLFORWARD_REDO_FLAG_USE_LAST_REDO_LSN |         \
                 TXFS_ROLLFORWARD_REDO_FLAG_USE_LAST_VIRTUAL_CLOCK);
]]

ffi.cdef[[
typedef struct _TXFS_ROLLFORWARD_REDO_INFORMATION {
    LARGE_INTEGER  LastVirtualClock;
    DWORDLONG LastRedoLsn;
    DWORDLONG HighestRecoveryLsn;
    DWORD Flags;
} TXFS_ROLLFORWARD_REDO_INFORMATION,
 *PTXFS_ROLLFORWARD_REDO_INFORMATION;
]]

ffi.cdef[[
//
//  Structures for FSCTL_TXFS_START_RM
//
//  Note that TXFS_START_RM_FLAG_LOG_GROWTH_INCREMENT_NUM_CONTAINERS and
//  TXFS_START_RM_FLAG_LOG_GROWTH_INCREMENT_PERCENT are mutually exclusive.
//  You can specify the log growth amount in number of containers or as a percentage.
//
//  TXFS_START_RM_FLAG_CONTAINER_COUNT_MAX and TXFS_START_RM_FLAG_LOG_NO_CONTAINER_COUNT_MAX
//  are mutually exclusive.
//
//  TXFS_START_RM_FLAG_LOG_CONTAINER_COUNT_MIN and TXFS_START_RM_FLAG_LOG_NO_CONTAINER_COUNT_MIN
//  are mutually exclusive.
//
//  TXFS_START_RM_FLAG_PREFER_CONSISTENCY and TXFS_START_RM_FLAG_PREFER_AVAILABILITY
//  are mutually exclusive.
//
//  Optional parameters will have system-supplied defaults applied if omitted.
//

static const int TXFS_START_RM_FLAG_LOG_CONTAINER_COUNT_MAX             = 0x00000001;
static const int TXFS_START_RM_FLAG_LOG_CONTAINER_COUNT_MIN             = 0x00000002;
static const int TXFS_START_RM_FLAG_LOG_CONTAINER_SIZE                  = 0x00000004;
static const int TXFS_START_RM_FLAG_LOG_GROWTH_INCREMENT_NUM_CONTAINERS = 0x00000008;
static const int TXFS_START_RM_FLAG_LOG_GROWTH_INCREMENT_PERCENT        = 0x00000010;
static const int TXFS_START_RM_FLAG_LOG_AUTO_SHRINK_PERCENTAGE          = 0x00000020;
static const int TXFS_START_RM_FLAG_LOG_NO_CONTAINER_COUNT_MAX          = 0x00000040;
static const int TXFS_START_RM_FLAG_LOG_NO_CONTAINER_COUNT_MIN          = 0x00000080;

static const int TXFS_START_RM_FLAG_RECOVER_BEST_EFFORT                 = 0x00000200;
static const int TXFS_START_RM_FLAG_LOGGING_MODE                        = 0x00000400;
static const int TXFS_START_RM_FLAG_PRESERVE_CHANGES                    = 0x00000800;

static const int TXFS_START_RM_FLAG_PREFER_CONSISTENCY                  = 0x00001000;
static const int TXFS_START_RM_FLAG_PREFER_AVAILABILITY                 = 0x00002000;

static const int TXFS_START_RM_VALID_FLAGS                              =             \
                (TXFS_START_RM_FLAG_LOG_CONTAINER_COUNT_MAX             |   \
                 TXFS_START_RM_FLAG_LOG_CONTAINER_COUNT_MIN             |   \
                 TXFS_START_RM_FLAG_LOG_CONTAINER_SIZE                  |   \
                 TXFS_START_RM_FLAG_LOG_GROWTH_INCREMENT_NUM_CONTAINERS |   \
                 TXFS_START_RM_FLAG_LOG_GROWTH_INCREMENT_PERCENT        |   \
                 TXFS_START_RM_FLAG_LOG_AUTO_SHRINK_PERCENTAGE          |   \
                 TXFS_START_RM_FLAG_RECOVER_BEST_EFFORT                 |   \
                 TXFS_START_RM_FLAG_LOG_NO_CONTAINER_COUNT_MAX          |   \
                 TXFS_START_RM_FLAG_LOGGING_MODE                        |   \
                 TXFS_START_RM_FLAG_PRESERVE_CHANGES                    |   \
                 TXFS_START_RM_FLAG_PREFER_CONSISTENCY                  |   \
                 TXFS_START_RM_FLAG_PREFER_AVAILABILITY);
]]

ffi.cdef[[
typedef struct _TXFS_START_RM_INFORMATION {

    //
    //  TXFS_START_RM_FLAG_* flags.
    //

    DWORD Flags;

    //
    //  RM log container size, in bytes.  This parameter is optional.
    //

    DWORDLONG LogContainerSize;

    //
    //  RM minimum log container count.  This parameter is optional.
    //

    DWORD LogContainerCountMin;

    //
    //  RM maximum log container count.  This parameter is optional.
    //

    DWORD LogContainerCountMax;

    //
    //  RM log growth increment in number of containers or percent, as indicated
    //  by TXFS_START_RM_FLAG_LOG_GROWTH_INCREMENT_* flag.  This parameter is
    //  optional.
    //

    DWORD LogGrowthIncrement;

    //
    //  RM log auto shrink percentage.  This parameter is optional.
    //

    DWORD LogAutoShrinkPercentage;

    //
    //  Offset from the beginning of this structure to the log path for the KTM
    //  instance to be used by this RM.  This must be a two-byte (WCHAR) aligned
    //  value.  This parameter is required.
    //

    DWORD TmLogPathOffset;

    //
    //  Length in bytes of log path for the KTM instance to be used by this RM.
    //  This parameter is required.
    //

    WORD   TmLogPathLength;

    //
    //  Logging mode for this RM.  One of TXFS_LOGGING_MODE_SIMPLE or
    //  TXFS_LOGGING_MODE_FULL (mutually exclusive).  This parameter is optional,
    //  and will default to TXFS_LOGGING_MODE_SIMPLE.
    //

    WORD   LoggingMode;

    //
    //  Length in bytes of the path to the log to be used by the RM.  This parameter
    //  is required.
    //

    WORD   LogPathLength;

    //
    //  Reserved.
    //

    WORD   Reserved;

    //
    //  The path to the log (in Unicode characters) to be used by the RM goes here.
    //  This parameter is required.
    //

    WCHAR LogPath[1];

} TXFS_START_RM_INFORMATION,
 *PTXFS_START_RM_INFORMATION;

//
//  Structures for FSCTL_TXFS_GET_METADATA_INFO
//

typedef struct _TXFS_GET_METADATA_INFO_OUT {

    //
    //  Returns the TxfId of the file referenced by the handle used to call this routine.
    //

    struct {
        LONGLONG LowPart;
        LONGLONG HighPart;
    } TxfFileId;

    //
    //  The GUID of the transaction that has the file locked, if applicable.
    //

    GUID LockingTransaction;

    //
    //  Returns the LSN for the most recent log record we've written for the file.
    //

    DWORDLONG LastLsn;

    //
    //  Transaction state, a TXFS_TRANSACTION_STATE_* value.
    //

    DWORD TransactionState;

} TXFS_GET_METADATA_INFO_OUT, *PTXFS_GET_METADATA_INFO_OUT;
]]

ffi.cdef[[
//
//  Structures for FSCTL_TXFS_LIST_TRANSACTION_LOCKED_FILES
//
//  TXFS_LIST_TRANSACTION_LOCKED_FILES_ENTRY_FLAG_CREATED means the reported name was created
//  in the locking transaction.
//
//  TXFS_LIST_TRANSACTION_LOCKED_FILES_ENTRY_FLAG_DELETED means the reported name was deleted
//  in the locking transaction.
//
//  Note that both flags may appear if the name was both created and deleted in the same
//  transaction.  In that case the FileName[] member will contain only "\0", as there is
//  no meaningful name to report.
//

static const int TXFS_LIST_TRANSACTION_LOCKED_FILES_ENTRY_FLAG_CREATED  = 0x00000001;
static const int TXFS_LIST_TRANSACTION_LOCKED_FILES_ENTRY_FLAG_DELETED  = 0x00000002;

typedef struct _TXFS_LIST_TRANSACTION_LOCKED_FILES_ENTRY {

    //
    //  Offset in bytes from the beginning of the TXFS_LIST_TRANSACTION_LOCKED_FILES
    //  structure to the next TXFS_LIST_TRANSACTION_LOCKED_FILES_ENTRY.
    //

    DWORDLONG Offset;

    //
    //  TXFS_LIST_TRANSACTION_LOCKED_FILES_ENTRY_FLAG_* flags to indicate whether the
    //  current name was deleted or created in the transaction.
    //

    DWORD NameFlags;

    //
    //  NTFS File ID of the file.
    //

    LONGLONG FileId;

    //
    //  Reserved.
    //

    DWORD Reserved1;
    DWORD Reserved2;
    LONGLONG Reserved3;

    //
    //  NULL-terminated Unicode path to this file, relative to RM root.
    //

    WCHAR FileName[1];
} TXFS_LIST_TRANSACTION_LOCKED_FILES_ENTRY, *PTXFS_LIST_TRANSACTION_LOCKED_FILES_ENTRY;


typedef struct _TXFS_LIST_TRANSACTION_LOCKED_FILES {

    //
    //  GUID name of the KTM transaction that files should be enumerated from.
    //

    GUID KtmTransaction;

    //
    //  On output, the number of files involved in the transaction on this RM.
    //

    DWORDLONG NumberOfFiles;

    //
    //  The length of the buffer required to obtain the complete list of files.
    //  This value may change from call to call as the transaction locks more files.
    //

    DWORDLONG BufferSizeRequired;

    //
    //  Offset in bytes from the beginning of this structure to the first
    //  TXFS_LIST_TRANSACTION_LOCKED_FILES_ENTRY.
    //

    DWORDLONG Offset;
} TXFS_LIST_TRANSACTION_LOCKED_FILES, *PTXFS_LIST_TRANSACTION_LOCKED_FILES;

//
//  Structures for FSCTL_TXFS_LIST_TRANSACTIONS
//

typedef struct _TXFS_LIST_TRANSACTIONS_ENTRY {

    //
    //  Transaction GUID.
    //

    GUID TransactionId;

    //
    //  Transaction state, a TXFS_TRANSACTION_STATE_* value.
    //

    DWORD TransactionState;

    //
    //  Reserved fields
    //

    DWORD Reserved1;
    DWORD Reserved2;
    LONGLONG Reserved3;
} TXFS_LIST_TRANSACTIONS_ENTRY, *PTXFS_LIST_TRANSACTIONS_ENTRY;

typedef struct _TXFS_LIST_TRANSACTIONS {

    //
    //  On output, the number of transactions involved in this RM.
    //

    DWORDLONG NumberOfTransactions;

    //
    //  The length of the buffer required to obtain the complete list of
    //  transactions.  Note that this value may change from call to call
    //  as transactions enter and exit the system.
    //

    DWORDLONG BufferSizeRequired;
} TXFS_LIST_TRANSACTIONS, *PTXFS_LIST_TRANSACTIONS;
]]

ffi.cdef[[
//
//  Structures for FSCTL_TXFS_READ_BACKUP_INFORMATION
//


typedef struct _TXFS_READ_BACKUP_INFORMATION_OUT {
    union {

        //
        //  Used to return the required buffer size if return code is STATUS_BUFFER_OVERFLOW
        //

        DWORD BufferLength;

        //
        //  On success the data is copied here.
        //

        BYTE  Buffer[1];
    } DUMMYUNIONNAME;
} TXFS_READ_BACKUP_INFORMATION_OUT, *PTXFS_READ_BACKUP_INFORMATION_OUT;
]]


ffi.cdef[[
//
//  Structures for FSCTL_TXFS_WRITE_BACKUP_INFORMATION
//

typedef struct _TXFS_WRITE_BACKUP_INFORMATION {

    //
    //  The data returned in the Buffer member of a previous call to
    //  FSCTL_TXFS_READ_BACKUP_INFORMATION goes here.
    //

    BYTE  Buffer[1];
} TXFS_WRITE_BACKUP_INFORMATION, *PTXFS_WRITE_BACKUP_INFORMATION;
]]

ffi.cdef[[
//
//  Output structure for FSCTL_TXFS_GET_TRANSACTED_VERSION
//

static const int TXFS_TRANSACTED_VERSION_NONTRANSACTED  = 0xFFFFFFFE;
static const int TXFS_TRANSACTED_VERSION_UNCOMMITTED    = 0xFFFFFFFF;

typedef struct _TXFS_GET_TRANSACTED_VERSION {

    //
    //  The version that this handle is opened to.  This will be
    //  TXFS_TRANSACTED_VERSION_UNCOMMITTED for nontransacted and
    //  transactional writer handles.
    //

    DWORD ThisBaseVersion;

    //
    //  The most recent committed version available.
    //

    DWORD LatestVersion;

    //
    //  If this is a handle to a miniversion, the ID of the miniversion.
    //  If it is not a handle to a minivers, this field will be 0.
    //

    WORD   ThisMiniVersion;

    //
    //  The first available miniversion.  Unless the miniversions are
    //  visible to the transaction bound to this handle, this field will be zero.
    //

    WORD   FirstMiniVersion;

    //
    //  The latest available miniversion.  Unless the miniversions are
    //  visible to the transaction bound to this handle, this field will be zero.
    //

    WORD   LatestMiniVersion;

} TXFS_GET_TRANSACTED_VERSION, *PTXFS_GET_TRANSACTED_VERSION;
]]

ffi.cdef[[
//
//  Structures for FSCTL_TXFS_SAVEPOINT_INFORMATION
//
//  Note that the TXFS_SAVEPOINT_INFORMATION structure is both and in and out structure.
//  The KtmTransaction and ActionCode members are always in-parameters, and the SavepointId
//  member is either an in-parameter, an out-parameter, or not used (see its definition below).
//

//
//  Create a new savepoint.
//

static const int TXFS_SAVEPOINT_SET                     = 0x00000001;

//
//  Roll back to a specified savepoint.
//

static const int TXFS_SAVEPOINT_ROLLBACK                = 0x00000002;

//
//  Clear (make unavailable for rollback) the most recently set savepoint
//  that has not yet been cleared.
//

static const int TXFS_SAVEPOINT_CLEAR                   = 0x00000004;

//
//  Clear all savepoints from the transaction.
//

static const int TXFS_SAVEPOINT_CLEAR_ALL               = 0x00000010;
]]

ffi.cdef[[
typedef struct _TXFS_SAVEPOINT_INFORMATION {

    //
    //  Handle to the transaction on which to perform the savepoint operation.
    //

    HANDLE KtmTransaction;

    //
    //  Specifies the savepoint action to take.  A TXFS_SAVEPOINT_* value.
    //

    DWORD ActionCode;

    //
    //  In-parameter for TXFS_ROLLBACK_TO_SAVEPOINT - specifies the savepoint to which
    //  to roll back.
    //
    //  Out-parameter for TXFS_SET_SAVEPOINT - the newly-created savepoint ID will be
    //  returned here.
    //
    //  Not used for TXFS_CLEAR_SAVEPOINT or TXFS_CLEAR_ALL_SAVEPOINTS.
    //

    DWORD SavepointId;

} TXFS_SAVEPOINT_INFORMATION, *PTXFS_SAVEPOINT_INFORMATION;

//
//  Structures for FSCTL_TXFS_CREATE_MINIVERSION
//
//      Only an out parameter is necessary.  That returns the identifier of the new miniversion created.
//

typedef struct _TXFS_CREATE_MINIVERSION_INFO {

    WORD   StructureVersion;

    WORD   StructureLength;

    //
    //  The base version for the newly created miniversion.
    //

    DWORD BaseVersion;

    //
    //  The miniversion that was just created.
    //

    WORD   MiniVersion;

} TXFS_CREATE_MINIVERSION_INFO, *PTXFS_CREATE_MINIVERSION_INFO;

//
//  Structure for FSCTL_TXFS_TRANSACTION_ACTIVE
//

typedef struct _TXFS_TRANSACTION_ACTIVE_INFO {

    //
    //  Whether or not the volume had active transactions when this snapshot was taken.
    //

    BOOLEAN TransactionsActiveAtSnapshot;

} TXFS_TRANSACTION_ACTIVE_INFO, *PTXFS_TRANSACTION_ACTIVE_INFO;
]]

--#endif /* _WIN32_WINNT >= 0x0600 */

--#if (_WIN32_WINNT >= 0x0601)
ffi.cdef[[
//
// Output structure for FSCTL_GET_BOOT_AREA_INFO
//

typedef struct _BOOT_AREA_INFO {

    DWORD               BootSectorCount;  // the count of boot sectors present on the file system
    struct {
        LARGE_INTEGER   Offset;
    } BootSectors[2];                     // variable number of boot sectors.

} BOOT_AREA_INFO, *PBOOT_AREA_INFO;

//
// Output structure for FSCTL_GET_RETRIEVAL_POINTER_BASE
//

typedef struct _RETRIEVAL_POINTER_BASE {

    LARGE_INTEGER       FileAreaOffset; // sector offset to the first allocatable unit on the filesystem
} RETRIEVAL_POINTER_BASE, *PRETRIEVAL_POINTER_BASE;

//
// Structure for FSCTL_SET_PERSISTENT_VOLUME_STATE and FSCTL_GET_PERSISTENT_VOLUME_STATE
// The initial version will be 1.0
//

typedef struct _FILE_FS_PERSISTENT_VOLUME_INFORMATION {

    DWORD VolumeFlags;
    DWORD FlagMask;
    DWORD Version;
    DWORD Reserved;

} FILE_FS_PERSISTENT_VOLUME_INFORMATION, *PFILE_FS_PERSISTENT_VOLUME_INFORMATION;

//
//  Structure for FSCTL_QUERY_FILE_SYSTEM_RECOGNITION
//

typedef struct _FILE_SYSTEM_RECOGNITION_INFORMATION {

    CHAR FileSystem[9];

} FILE_SYSTEM_RECOGNITION_INFORMATION, *PFILE_SYSTEM_RECOGNITION_INFORMATION;
]]

ffi.cdef[[
//
//  Structures for FSCTL_REQUEST_OPLOCK
//

static const int OPLOCK_LEVEL_CACHE_READ        = (0x00000001);
static const int OPLOCK_LEVEL_CACHE_HANDLE      = (0x00000002);
static const int OPLOCK_LEVEL_CACHE_WRITE       = (0x00000004);

static const int REQUEST_OPLOCK_INPUT_FLAG_REQUEST               =(0x00000001);
static const int REQUEST_OPLOCK_INPUT_FLAG_ACK                   =(0x00000002);
static const int REQUEST_OPLOCK_INPUT_FLAG_COMPLETE_ACK_ON_CLOSE =(0x00000004);

static const int REQUEST_OPLOCK_CURRENT_VERSION        =  1;

typedef struct _REQUEST_OPLOCK_INPUT_BUFFER {

    //
    //  This should be set to REQUEST_OPLOCK_CURRENT_VERSION.
    //

    WORD   StructureVersion;

    WORD   StructureLength;

    //
    //  One or more OPLOCK_LEVEL_CACHE_* values to indicate the desired level of the oplock.
    //

    DWORD RequestedOplockLevel;

    //
    //  REQUEST_OPLOCK_INPUT_FLAG_* flags.
    //

    DWORD Flags;

} REQUEST_OPLOCK_INPUT_BUFFER, *PREQUEST_OPLOCK_INPUT_BUFFER;
]]

ffi.cdef[[
static const int REQUEST_OPLOCK_OUTPUT_FLAG_ACK_REQUIRED    = (0x00000001);
static const int REQUEST_OPLOCK_OUTPUT_FLAG_MODES_PROVIDED  = (0x00000002);

typedef struct _REQUEST_OPLOCK_OUTPUT_BUFFER {

    //
    //  This should be set to REQUEST_OPLOCK_CURRENT_VERSION.
    //

    WORD   StructureVersion;

    WORD   StructureLength;

    //
    //  One or more OPLOCK_LEVEL_CACHE_* values indicating the level of the oplock that
    //  was just broken.
    //

    DWORD OriginalOplockLevel;

    //
    //  One or more OPLOCK_LEVEL_CACHE_* values indicating the level to which an oplock
    //  is being broken, or an oplock level that may be available for granting, depending
    //  on the operation returning this buffer.
    //

    DWORD NewOplockLevel;

    //
    //  REQUEST_OPLOCK_OUTPUT_FLAG_* flags.
    //

    DWORD Flags;

    //
    //  When REQUEST_OPLOCK_OUTPUT_FLAG_MODES_PROVIDED is set, and when the
    //  OPLOCK_LEVEL_CACHE_HANDLE level is being lost in an oplock break, these fields
    //  contain the access mode and share mode of the request that is causing the break.
    //

    ACCESS_MASK AccessMode;

    WORD   ShareMode;

} REQUEST_OPLOCK_OUTPUT_BUFFER, *PREQUEST_OPLOCK_OUTPUT_BUFFER;
]]

ffi.cdef[[
//
//  Structures for FSCTL_SD_GLOBAL_CHANGE
//

//
//  list of operations supported
//

static const int SD_GLOBAL_CHANGE_TYPE_MACHINE_SID  = 1;


//
//  Operation specific structures for SD_GLOBAL_CHANGE_TYPE_MACHINE_SID
//
//  This con
//

typedef struct _SD_CHANGE_MACHINE_SID_INPUT {

    //
    //  The current machine SID to change.
    //  This define the offset from the beginning of the SD_GLOBAL_CHANGE_INPUT
    //  structure of where the CurrentMachineSID to replace begins.  This will
    //  be a SID structure.  The length defines the length of the imbedded SID
    //  structure.
    //

    WORD   CurrentMachineSIDOffset;
    WORD   CurrentMachineSIDLength;

    //
    //  The new machine SID value to set inplace of the current machine SID
    //  This define the offset from the beginning of the SD_GLOBAL_CHANGE_INPUT
    //  structure of where the NewMachineSID to set begins.  This will
    //  be a SID structure.  The length defines the length of the imbedded SID
    //  structure.
    //

    WORD   NewMachineSIDOffset;
    WORD   NewMachineSIDLength;

} SD_CHANGE_MACHINE_SID_INPUT, *PSD_CHANGE_MACHINE_SID_INPUT;

typedef struct _SD_CHANGE_MACHINE_SID_OUTPUT {

    //
    //  How many entries were successfully changed in the $Secure stream
    //

    DWORDLONG NumSDChangedSuccess;

    //
    //  How many entires failed the update in the $Secure stream
    //

    DWORDLONG NumSDChangedFail;

    //
    //  How many entires are unused in the current security stream
    //

    DWORDLONG NumSDUnused;

    //
    //  The total number of entries processed in the $Secure stream
    //

    DWORDLONG NumSDTotal;

    //
    //  How many entries were successfully changed in the $MFT file
    //

    DWORDLONG NumMftSDChangedSuccess;

    //
    //  How many entries failed the update in the $MFT file
    //

    DWORDLONG NumMftSDChangedFail;

    //
    //  Total number of entriess process in the $MFT file
    //

    DWORDLONG NumMftSDTotal;

} SD_CHANGE_MACHINE_SID_OUTPUT, *PSD_CHANGE_MACHINE_SID_OUTPUT;
]]

ffi.cdef[[
//
//  Generic INPUT & OUTPUT structures for FSCTL_SD_GLOBAL_CHANGE
//

typedef struct _SD_GLOBAL_CHANGE_INPUT
{
    //
    //  Input flags (none currently defined)
    //

    DWORD Flags;

    //
    //  Specifies which type of change we are doing and pics which member
    //  of the below union is in use.
    //

    DWORD ChangeType;

    union {

        SD_CHANGE_MACHINE_SID_INPUT SdChange;
    };

} SD_GLOBAL_CHANGE_INPUT, *PSD_GLOBAL_CHANGE_INPUT;

typedef struct _SD_GLOBAL_CHANGE_OUTPUT
{

    //
    //  Output State Flags (none currently defined)
    //

    DWORD Flags;

    //
    //  Specifies which below union to use
    //

    DWORD ChangeType;

    union {

        SD_CHANGE_MACHINE_SID_OUTPUT SdChange;
    };

} SD_GLOBAL_CHANGE_OUTPUT, *PSD_GLOBAL_CHANGE_OUTPUT;
]]

ffi.cdef[[
//
//  Flag to indicate the encrypted file is sparse
//

static const int ENCRYPTED_DATA_INFO_SPARSE_FILE   = 1;

typedef struct _EXTENDED_ENCRYPTED_DATA_INFO {

    //
    //  This is really a 4 byte character array which
    //  must have the value "EXTD".  We use this
    //  to determine if we should read the extended data
    //  or not.
    //

    DWORD ExtendedCode;

    //
    //  The length of the extended data structure
    //

    DWORD Length;

    //
    //  Encrypted data flags (currently only sparse is defined)
    //

    DWORD Flags;
    DWORD Reserved;

} EXTENDED_ENCRYPTED_DATA_INFO, *PEXTENDED_ENCRYPTED_DATA_INFO;


typedef struct _LOOKUP_STREAM_FROM_CLUSTER_INPUT {

    //
    //  Flags for the operation.  Currently no flags are defined.
    //
    DWORD         Flags;

    //
    //  Number of clusters in the following array of clusters.
    //  The input buffer must be large enough to contain this
    //  number or the operation will fail.
    //
    DWORD         NumberOfClusters;

    //
    //  An array of one or more clusters to look up.
    //
    LARGE_INTEGER Cluster[1];
} LOOKUP_STREAM_FROM_CLUSTER_INPUT, *PLOOKUP_STREAM_FROM_CLUSTER_INPUT;

typedef struct _LOOKUP_STREAM_FROM_CLUSTER_OUTPUT {
    //
    //  Offset from the beginning of this structure to the first entry
    //  returned.  If no entries are returned, this value is zero.
    //
    DWORD         Offset;

    //
    //  Number of matches to the input criteria.  Note that more matches
    //  may be found than entries returned if the buffer is not large
    //  enough.
    //
    DWORD         NumberOfMatches;

    //
    //  Minimum size of the buffer, in bytes, which would be needed to
    //  contain all matching entries to the input criteria.
    //
    DWORD         BufferSizeRequired;
} LOOKUP_STREAM_FROM_CLUSTER_OUTPUT, *PLOOKUP_STREAM_FROM_CLUSTER_OUTPUT;
]]

ffi.cdef[[
static const int LOOKUP_STREAM_FROM_CLUSTER_ENTRY_FLAG_PAGE_FILE          = 0x00000001;
static const int LOOKUP_STREAM_FROM_CLUSTER_ENTRY_FLAG_DENY_DEFRAG_SET    = 0x00000002;
static const int LOOKUP_STREAM_FROM_CLUSTER_ENTRY_FLAG_FS_SYSTEM_FILE     = 0x00000004;
static const int LOOKUP_STREAM_FROM_CLUSTER_ENTRY_FLAG_TXF_SYSTEM_FILE    = 0x00000008;

static const int LOOKUP_STREAM_FROM_CLUSTER_ENTRY_ATTRIBUTE_MASK          = 0xff000000;
static const int LOOKUP_STREAM_FROM_CLUSTER_ENTRY_ATTRIBUTE_DATA          = 0x01000000;
static const int LOOKUP_STREAM_FROM_CLUSTER_ENTRY_ATTRIBUTE_INDEX         = 0x02000000;
static const int LOOKUP_STREAM_FROM_CLUSTER_ENTRY_ATTRIBUTE_SYSTEM        = 0x03000000;

typedef struct _LOOKUP_STREAM_FROM_CLUSTER_ENTRY {
    //
    //  Offset from the beginning of this structure to the next entry
    //  returned.  If there are no more entries, this value is zero.
    //
    DWORD         OffsetToNext;

    //
    //  Flags describing characteristics about this stream.
    //
    DWORD         Flags;

    //
    //  This value is reserved and is currently zero.
    //
    LARGE_INTEGER Reserved;

    //
    //  This is the cluster that this entry refers to.  It will be one
    //  of the clusters passed in the input structure.
    //
    LARGE_INTEGER Cluster;

    //
    //  A NULL-terminated Unicode string containing the path of the
    //  object relative to the root of the volume.  This string
    //  will refer to the attribute or stream represented by the
    //  cluster.
    //
    WCHAR         FileName[1];
} LOOKUP_STREAM_FROM_CLUSTER_ENTRY, *PLOOKUP_STREAM_FROM_CLUSTER_ENTRY;

//
//  This is the structure for the FSCTL_FILE_TYPE_NOTIFICATION operation.
//  Its purpose is to notify the storage stack about the extents of certain
//  types of files.  This is only callable from kernel mode
//

typedef struct _FILE_TYPE_NOTIFICATION_INPUT {

    //
    //  Flags for this operation
    //  FILE_TYPE_NOTIFICATION_FLAG_*
    //

    DWORD Flags;

    //
    //  A count of how many FileTypeID guids are given
    //

    DWORD NumFileTypeIDs;

    //
    //  This is a unique identifer for the type of file notification occuring
    //

    GUID FileTypeID[1];

} FILE_TYPE_NOTIFICATION_INPUT, *PFILE_TYPE_NOTIFICATION_INPUT;

//
//  Flags for the given operation
//

static const int FILE_TYPE_NOTIFICATION_FLAG_USAGE_BEGIN    = 0x00000001;      //Set when adding the specified usage on the given file
static const int FILE_TYPE_NOTIFICATION_FLAG_USAGE_END      = 0x00000002;      //Set when removing the specified usage on the given file
]]

--[[
//
//  These are the globally defined file types
//
--]]

FILE_TYPE_NOTIFICATION_GUID_PAGE_FILE = DEFINE_GUID( "FILE_TYPE_NOTIFICATION_GUID_PAGE_FILE",         0x0d0a64a1, 0x38fc, 0x4db8, 0x9f, 0xe7, 0x3f, 0x43, 0x52, 0xcd, 0x7c, 0x5c );
FILE_TYPE_NOTIFICATION_GUID_HIBERNATION_FILE = DEFINE_GUID( "FILE_TYPE_NOTIFICATION_GUID_HIBERNATION_FILE",  0xb7624d64, 0xb9a3, 0x4cf8, 0x80, 0x11, 0x5b, 0x86, 0xc9, 0x40, 0xe7, 0xb7 );
FILE_TYPE_NOTIFICATION_GUID_CRASHDUMP_FILE = DEFINE_GUID( "FILE_TYPE_NOTIFICATION_GUID_CRASHDUMP_FILE",    0x9d453eb7, 0xd2a6, 0x4dbd, 0xa2, 0xe3, 0xfb, 0xd0, 0xed, 0x91, 0x09, 0xa9 );

--#endif /* _WIN32_WINNT >= 0x0601 */


