-- test_filesecurity.lua
local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;

local core_file = require("core_file_l1_2_0");
local core_string = require("core_string_l1_1_0");
local security_base = require("security_base_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");

local WinNT = require("WinNT");
local WinBase = require("WinBase");
local SID = require("SID");
local SecurityDescriptor = require("SecurityDescriptor");

local advlib = ffi.load("AdvApi32");

ffi.cdef[[
typedef enum _SE_OBJECT_TYPE
{
    SE_UNKNOWN_OBJECT_TYPE = 0,
    SE_FILE_OBJECT,
    SE_SERVICE,
    SE_PRINTER,
    SE_REGISTRY_KEY,
    SE_LMSHARE,
    SE_KERNEL_OBJECT,
    SE_WINDOW_OBJECT,
    SE_DS_OBJECT,
    SE_DS_OBJECT_ALL,
    SE_PROVIDER_DEFINED_OBJECT,
    SE_WMIGUID_OBJECT,
    SE_REGISTRY_WOW64_32KEY,
} SE_OBJECT_TYPE;
]]

ffi.cdef[[
static const int  OWNER_SECURITY_INFORMATION      = (0x00000001);
static const int  GROUP_SECURITY_INFORMATION      = (0x00000002);
static const int  DACL_SECURITY_INFORMATION       = (0x00000004);
static const int  SACL_SECURITY_INFORMATION       = (0x00000008);
static const int  LABEL_SECURITY_INFORMATION      = (0x00000010);
]]

ffi.cdef[[
DWORD GetSecurityInfo(
    HANDLE handle,
    SE_OBJECT_TYPE ObjectType,
    SECURITY_INFORMATION SecurityInfo,
    PSID *ppsidOwner,
    PSID *ppsidGroup,
    PACL *ppDacl,
    PACL *ppSacl,
    PSECURITY_DESCRIPTOR *ppSecurityDescriptor
);
]]

local printDescriptor = function(descrip)
    print("IsValid: ", descrip:isValid());
    print("Length: ", descrip:getLength());
    print("Owner: ", descrip:getOwner());
    print("Group: ", descrip:getGroup());
    print("DACL Present: ", descrip:isDaclPresent());
    print("SACL Present: ", descrip:isSaclPresent());
    print("RM Control Present: ", descrip:isRMControlPresent());    
    print("Control Info: ", descrip:getControlInfo());
end

local getFileSecurityOld = function(filename)

local hFile = core_file.CreateFileA(filename,
                  ffi.C.GENERIC_READ,
                  FILE_SHARE_READ,
                  nil,
                  OPEN_EXISTING,
                  ffi.C.FILE_ATTRIBUTE_NORMAL,
                  nil);

print("Handle: ", hFile);

-- Get the owner SID of the file.
local pSidOwner = ffi.new("PSID[1]");
local pSidGroup = ffi.new("PSID[1]");

local pSD = ffi.new("PSECURITY_DESCRIPTOR[1]");

local status = advlib.GetSecurityInfo(
  hFile,
  ffi.C.SE_FILE_OBJECT,
  bor(ffi.C.GROUP_SECURITY_INFORMATION, ffi.C.OWNER_SECURITY_INFORMATION),
  pSidOwner,
  pSidGroup,
  nil,
  nil,
  pSD);

print("GetSecurityInfo: ", status);

if status ~= 0 then
	return false, status;
end

local ownersid = SID(pSidOwner[0]);
local groupsid = SID(pSidGroup[0]);
--print("Owner: ", pSidOwner[0]);
print("Owner: ", ownersid);
print("Group: ", groupsid);

--local descrip = SecurityDescriptor(pSD[0]);

--printDescriptor(descrip);
end


local getFileSecurity = function(filename, RequestedInformation)
    if not filename then
        return false, "no filename specified";
    end

    local lpFileName = core_string.toUnicode(filename);
    RequestedInformation = RequestedInformation or 
      bor(ffi.C.GROUP_SECURITY_INFORMATION, 
        ffi.C.OWNER_SECURITY_INFORMATION,
        ffi.C.DACL_SECURITY_INFORMATION);
    local pSecurityDescriptor = nil;
    local nLength = 0;
    local lpnLengthNeeded = ffi.new("DWORD[1]");

    local status = security_base.GetFileSecurityW (
        lpFileName,
        RequestedInformation,
        pSecurityDescriptor,
        nLength,
        lpnLengthNeeded);

    if status == 0 then
        local err = errorhandling.GetLastError();

        if err ~= ERROR_INSUFFICIENT_BUFFER then
          print("FAILURE: ", err);
          return false, err;
        end
    end

    print("Needed: ", lpnLengthNeeded[0], nLength);
    nLength = lpnLengthNeeded[0];
    pSecurityDescriptor = ffi.new("uint8_t[?]", nLength);

    local status = security_base.GetFileSecurityW (
        lpFileName,
        RequestedInformation,
        ffi.cast("PSECURITY_DESCRIPTOR",pSecurityDescriptor),
        nLength,
        lpnLengthNeeded);

    if status == 0 then
        local err = errorhandling.GetLastError();
        return false, err;
    end

    return pSecurityDescriptor;
end


local descrip, err = getFileSecurity("file.txt");

if not descrip then
    print("ERROR: ", err);
    return err;
end

descrip = SecurityDescriptor(descrip);
printDescriptor(descrip);
