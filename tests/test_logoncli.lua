-- test_logoncli.lua
local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;

local logoncli = require("logoncli_ffi");
local WinError = require("win_error");
local netutils = require("netutils");

--[[
typedef struct _DOMAIN_CONTROLLER_INFOA {
    LPSTR DomainControllerName;
    LPSTR DomainControllerAddress;
    ULONG DomainControllerAddressType;
    GUID DomainGuid;
    LPSTR DomainName;
    LPSTR DnsForestName;
    ULONG Flags;
    LPSTR DcSiteName;
    LPSTR ClientSiteName;
} DOMAIN_CONTROLLER_INFOA, *PDOMAIN_CONTROLLER_INFOA;
--]]

local DomainControllerInfo = {}
setmetatable(DomainControllerInfo, {
	__call = function(self, ...) 
		return DomainControllerInfo.new(...) 
	end,
})

local DomainControllerInfo_mt = {
	__index = DomainControllerInfo;
}

DomainControllerInfo.new = function(info)
	local obj = {}
	if info.DomainControllerName ~= nil then
		obj.ControllerName = ffi.string(info.DomainControllerName);
	end

	if info.DomainControllerAddress ~= nil then
		obj.ControllerAddress = ffi.string(info.DomainControllerAddress);
	end

	obj.ControllerAddressType = info.DomainControllerAddressType;
	--obj.DomainGuid = info.DomainGuid;	-- should clone it
	obj.DomainName = ffi.string(info.DomainName);
	obj.DnsForestName = ffi.string(info.DnsForestName);
	obj.Flags = info.Flags;
	obj.DcSiteName = ffi.string(info.DcSiteName);
	obj.ClientSiteName = ffi.string(info.ClientSiteName);

	setmetatable(obj, DomainControllerInfo_mt);

	return obj;

end


local getDCInfo = function(DomainName, ComputerName)
	local DomainGuid = nil;
	local SiteName = "";
	local Flags = bor(ffi.C.DS_WRITABLE_REQUIRED, ffi.C.DS_DIRECTORY_SERVICE_REQUIRED);
	local pDomainControllerInfo = ffi.new("PDOMAIN_CONTROLLER_INFOA[1]");

	local status = logoncli.DsGetDcNameA(ComputerName, DomainName, DomainGuid, SiteName, 
		Flags,
		pDomainControllerInfo);

	if status ~= ERROR_SUCCESS then
		return false, status
	end

	local buff = netutils.NetApiBuffer(pDomainControllerInfo[0]);

	local res = DomainControllerInfo(pDomainControllerInfo[0]);

	return res;
end

local getSiteCoverage = function(ServerName)
	local EntryCount = ffi.new("ULONG[1]");
	local SiteNames = ffi.new("void *[1]");

	local status = logoncli.DsGetDcSiteCoverageA(ServerName,EntryCount,SiteNames);

	if status ~= NO_ERROR then
		return false, status;
	end

	return SiteNames[0], EntryCount[0];
end



printTable = function(tbl)
	for k,v in pairs(tbl) do 
		print(k, v)
	end
end


local test_getDCInfo = function()
	local dcInfo, err = getDCInfo("redmond");

	if dcInfo then
		printTable(dcInfo);
	else
		print("No Info found: ", err);
	end
end

local test_getSiteCoverage = function()
	local dcInfo, err = getDCInfo("redmond");
	
	if not dcInfo then
		return false, err
	end


print("test_getSiteCoverage")
print("Controller Name: ", dcInfo.ControllerName);

	local sites, count = getSiteCoverage(dcInfo.ControllerName);

	if not sites then
		return false, count
	end

	print("Sites: ", sites, count);

	sites = ffi.cast("char **", sites);

	for i=0,count-1 do
		local site = ffi.string(sites[i]);
		print(site);
	end
end

--test_getDCInfo();
test_getSiteCoverage();
