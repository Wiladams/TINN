-- sspi.lua
local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;
local band = require("bit").band;

local win_error = require("win_error")
local sspi_ffi = require("sspi_ffi");
--local sspicli = require("sspicli");
local SecError = require ("SecError");
local sspilib = ffi.load("secur32");
local schannel = require("schannel");
local errorhandling = require("core_errorhandling_l1_1_1");


--[[
	Module: SecurityInterface

	Provides access to the SecurityInterface vtable
--]]

local SecurityInterface = {
	VTable = sspilib.InitSecurityInterfaceA();
}
setmetatable(SecurityInterface, {
	__index = function(self, key)
		return self.VTable[key]
	end,

});





--[[
	Security Package Capabilities
	SECPKG_FLAG_
	Used with Security Package Capabilities
--]]

local PackageCaps = {
	[0x00000001] = {"INTEGRITY", "Supports integrity on messages"},
	[0x00000002] = {"PRIVACY","Supports privacy (confidentiality)"},
	[0x00000004] = {"TOKEN_ONLY","Only security token needed"},
	[0x00000008] = {"DATAGRAM","Datagram RPC support"},
	[0x00000010] = {"CONNECTION","Connection oriented RPC support"},
	[0x00000020] = {"MULTI_REQUIRED","Full 3-leg required for re-auth."},
	[0x00000040] = {"CLIENT_ONLY","Server side functionality not available"},
	[0x00000080] = {"EXTENDED_ERROR","Supports extended error msgs"},
	[0x00000100] = {"IMPERSONATION","Supports impersonation"},
	[0x00000200] = {"ACCEPT_WIN32_NAME","Accepts Win32 names"},
	[0x00000400] = {"STREAM","Supports stream semantics"},
	[0x00000800] = {"NEGOTIABLE", "Can be used by the negotiate package"},
	[0x00001000] = {"GSS_COMPATIBLE","GSS Compatibility Available"},
	[0x00002000] = {"LOGON","Supports common LsaLogonUser"},
	[0x00004000] = {"ASCII_BUFFERS","Token Buffers are in ASCII"},
	[0x00008000] = {"FRAGMENT","Package can fragment to fit"},
	[0x00010000] = {"MUTUAL_AUTH","Package can perform mutual authentication"},
	[0x00020000] = {"DELEGATION","Package can delegate"},
	[0x00040000] = {"READONLY_WITH_CHECKSUM","Package can delegate"},
	[0x00080000] = {"RESTRICTED_TOKENS","Package supports restricted callers"},
	[0x00100000] = {"NEGO_EXTENDER","this package extends SPNEGO, there is at most one"},
	[0x00200000] = {"NEGOTIABLE2","this package is negotiated under the NegoExtender"},
}

--local SecInterface = SecurityInterface();


local EnumerateSecurityPackages = function()
	local pcPackages = ffi.new("int[1]");
	local ppPackageInfo = ffi.new("PSecPkgInfoA[1]");

	local res = SecurityInterface.EnumerateSecurityPackagesA(pcPackages, ppPackageInfo);

--print("EnumerateWSecurityPackages: ", res, pcPackages[0]);

	if res ~= 0 then
		return false, res;
	end
	
	local packagecount = pcPackages[0];
	
	local packages = {}
	local packageInfos = ppPackageInfo[0];

	for i=1,packagecount do
		local package =  SecurityPackage(packageInfos[i-1]);
		packages[package.Name] = package;
	end

--	SecInterface.FreeContextBuffer(packageInfos);
	SecurityInterface.FreeContextBuffer(packageInfos);

	return packages;
end


SecurityPackage = {
	GetPackages = function(self)
		if self.Packages then return self.Packages; end

		local err;
		self.Packages, err = EnumerateSecurityPackages();

		if self.Packages then
			return self.Packages;
		end

		return false, res;
	end,

	FindPackage = function(self, packageName)
		local packages, err = self:GetPackages();

		if not packages then
			return false, err;
		end

		return packages[packageName];
	end,
}
setmetatable(SecurityPackage, {__call = function(self, ...) return SecurityPackage.new(self, ...) end;});

SecurityPackage_mt = {
	__index = SecurityPackage;
}

SecurityPackage.new = function(self, ...)
	local nargs = select('#', ...);
	
	local obj = {};
	setmetatable(obj, SecurityPackage_mt);

	if nargs == 1 and type(select(1,...)) == "cdata" then
		local packageInfo = select(1,...);
		obj.Capabilities = packageInfo.fCapabilities;
		obj.Version = packageInfo.wVersion;
		obj.MaxToken = packageInfo.cbMaxToken;
		obj.RPCID = packageInfo.wRPCID;
		obj.Name = ffi.string(packageInfo.Name);
		obj.Comment = ffi.string(packageInfo.Comment);
	end

	return obj
end

SecurityPackage.HasCapability = function(self, capability)
	capability = capability or 0;

	return band(self.Capabilities, capability) > 0;
end

SecurityPackage.ListCapabilities = function(self)
	local res = {};
	for i=0,31 do
		if self:HasCapability(math.pow(2,i)) then
			local cap = PackageCaps[math.pow(2,i)][1];
			table.insert(res, cap);
		end
	end

	return table.concat(res, '\n');
end


SecurityPackage.AcquireCredentialsHandle = function(self, usage, authData)
	usage = usage or ffi.C.SECPKG_CRED_OUTBOUND;

	local phCredential = ffi.new("CredHandle");

	local res = SecurityInterface.AcquireCredentialsHandleA(
		nil,
        ffi.cast("char *", self.Name),
        usage,       
    	nil,          
    	authData,   
    	nil,           
    	nil,    
        phCredential,        
    	nil);


print("CredHandle: ",phCredential.dwLower, phCredential.dwUpper);

	if res ~= SEC_E_OK then
		-- return failure values
		local severity, facility, code = HRESULT_PARTS(res);

print(string.format("ERROR AcquireCredentialsHandle: 0x%x => 0x%x, 0x%x, 0x%x", res, severity, facility, code));

		-- return failure values
		return false, res
	end

	-- return the credhandle
	return phCredential;
end

SecurityPackage.CreateCredentials = function(self, usage, authData)
	if not authData then
		authData = ffi.new("SCHANNEL_CRED");

		authData.dwVersion = ffi.C.SCHANNEL_CRED_VERSION;
		authData.grbitEnabledProtocols = ffi.C.SP_PROT_TLS2_CLIENT;
		authData.dwFlags = bor(ffi.C.SCH_CRED_AUTO_CRED_VALIDATION, ffi.C.SCH_CRED_USE_DEFAULT_CREDS);
	end		

	return self:AcquireCredentialsHandle(usage, authData);
end

SecurityPackage.GetDefaultCredentials = function(self, usage)
	return self:AcquireCredentialsHandle(usage);
end





--[[
	CredHandle
--]]

-- List of schannel protocols.  
-- Used wit GetSupportedProtocols()
local Protocols = {
[0x00000000]={"SP_PROT_NONE"},        
[0xffffffff]={"SP_PROT_ALL"},                 

[0x00000001]={"SP_PROT_PCT1_SERVER"},          
[0x00000002]={"SP_PROT_PCT1_CLIENT"},          

[0x00000004]={"SP_PROT_SSL2_SERVER"},          
[0x00000008]={"SP_PROT_SSL2_CLIENT"},          

[0x00000010]={"SP_PROT_SSL3_SERVER"},          
[0x00000020]={"SP_PROT_SSL3_CLIENT"},          

[0x00000040]={"SP_PROT_TLS1_SERVER"},          
[0x00000080]={"SP_PROT_TLS1_CLIENT"},           


[0x40000000]={"SP_PROT_UNI_SERVER"},           
[0x80000000]={"SP_PROT_UNI_CLIENT"},              


[0x00000100]={"SP_PROT_TLS1_1_SERVER"},        
[0x00000200]={"SP_PROT_TLS1_1_CLIENT"},        

[0x00000400]={"SP_PROT_TLS1_2_SERVER"},         
[0x00000800]={"SP_PROT_TLS1_2_CLIENT"},           
}


CredHandle = ffi.typeof("CredHandle");
CredHandle_t = {}
CredHandle_mt = {
	__gc = function(self)
		--print("GC: CredHandle");
		SecurityInterface.FreeCredentialHandle(self);
	end,

	__index = CredHandle_t;
}
ffi.metatype(CredHandle, CredHandle_mt);

CredHandle_t.GetAttribute = function(self, which, pBuffer)
	local res = SecurityInterface.QueryCredentialsAttributesA(self, which, pBuffer);

	if res ~= SEC_E_OK then
		return false, res;
	end

	return pBuffer;
end

CredHandle_t.GetUserName = function(self)
	local pBuffer = ffi.new("SecPkgCredentials_NamesA");

	local res, err = self:GetAttribute(ffi.C.SECPKG_CRED_ATTR_NAMES, pBuffer);

	if not res then
		return false, err;
	end

	return ffi.string(pBuffer.sUserName);
end

CredHandle_t.GetSupportedAlgorithms = function(self)
	local pBuffer = ffi.new("SecPkgCred_SupportedAlgs");

	local res, err = self:GetAttribute(ffi.C.SECPKG_ATTR_SUPPORTED_ALGS, pBuffer);

	if not res then
		return false, err;
	end

	local res = {}
	for i=0,pBuffer.cSupportedAlgs do
		table.insert(res, pBuffer.palgSupportedAlgs[i]);
	end

	return res;
end

CredHandle_t.GetCipherStrengths = function(self)
	local pBuffer = ffi.new("SecPkgCred_CipherStrengths");

	local res, err = self:GetAttribute(ffi.C.SECPKG_ATTR_CIPHER_STRENGTHS, pBuffer);

	if not res then
		return false, err;
	end

	return pBuffer.dwMinimumCipherStrength, pBuffer.dwMaximumCipherStrength;
end



CredHandle_t.SupportsProtocol = function(self, which)
	local pBuffer = ffi.new("SecPkgCred_SupportedProtocols");
	local res, err = self:GetAttribute(ffi.C.SECPKG_ATTR_SUPPORTED_PROTOCOLS, pBuffer);

	if not res then
		return false, err;
	end

	return band(pBuffer.grbitProtocol, which) > 0;
end

local ListProtocols = function(protobits)
	local res = {};
	for i=0,31 do
		local bitval = math.pow(2,i);
		if band(bitval, protobits) > 0 then
			local proto = Protocols[bitval][1];
			table.insert(res, proto);
		end
	end
	return table.concat(res, '\n');
end


CredHandle_t.ListSupportedProtocols = function(self)
	local pBuffer = ffi.new("SecPkgCred_SupportedProtocols");
	local res, err = self:GetAttribute(ffi.C.SECPKG_ATTR_SUPPORTED_PROTOCOLS, pBuffer);

	if not res then
		return false, err;
	end
	
	return ListProtocols(pBuffer.grbitProtocol);
end
--[[
CredHandle_t.InitializeSecurityContext = function(self, phContext,pszTargetName, fContextReq)
--print("InitializeSecurityContext : ", phContext, pszTargetName, fContextReq);

	fContextReq = fContextReq or 0;
	local Reserved1 = 0;							-- Reserved, MUST be 0
	local TargetDataRep = 0;						-- for schannel, MUST be 0

	local TCP_SSL_REQUEST_CONTEXT_FLAGS =bor(
		ffi.C.ISC_REQ_ALLOCATE_MEMORY,
		ffi.C.ISC_REQ_CONFIDENTIALITY,
		ffi.C.ISC_RET_EXTENDED_ERROR,
		ffi.C.ISC_REQ_REPLAY_DETECT,
		ffi.C.ISC_REQ_SEQUENCE_DETECT,
		ffi.C.ISC_REQ_STREAM);

	--local pInput = ffi.new("PSecBufferDesc[1]");
	local pInput = ffi.new("SecBufferDesc");
	local Reserved2 = 0								-- Reserved, MUST be 0
	--local phNewContext = ffi.new("PCtxtHandle[1]");
	local phNewContext = ffi.new("CtxtHandle");
	local pfContextAttr = ffi.new("ULONG[1]");
	local ptsExpiry = nil;

	local sendBuffer = ffi.new("SecBuffer");
	sendBuffer.cbBuffer = 0;
	sendBuffer.pvBuffer = nil;
	sendBuffer.BufferType = ffi.C.SECBUFFER_TOKEN;

	local pOutput = ffi.new("SecBufferDesc");
	local outBufferDesc = ffi.new("SecBufferDesc");
	outBufferDesc.cBuffers = 1;
	outBufferDesc.pBuffers = sendBuffer;
	outBufferDesc.ulVersion = ffi.C.SECBUFFER_VERSION;

	local res = SecurityInterface.InitializeSecurityContextA(
		self,
		phContext,                 			-- must be NULL on first call. 
		ffi.cast("char *",pszTargetName),
		TCP_SSL_REQUEST_CONTEXT_FLAGS,
		0,                    				-- must be 0. 
		ffi.C.SECURITY_NATIVE_DREP, 		-- must be 0 on msdn, but ... 
		nil,                 				-- must be NULL on first call. 
		0,                    				-- must be 0. 
		phNewContext,
		outBufferDesc,
		pfContextAttr,
		nil);


	-- parse the result to see what we got
	local severity, facility, code = HRESULT_PARTS(res);

print(string.format("InitializeSecurityContextA: 0x%x, 0x%x, 0x%x", severity, facility, code));

	if severity ~= 0 then
		return false, code;
	end

	return phNewContext, code;
end
--]]


local function getUserName(format)
	format = format or ffi.C.NameFullyQualifiedDN;
	local buffSize = 256;
	local pBuffSize = ffi.new("DWORD[1]", buffSize);
	local nameBuffer = ffi.new("char[?]", buffSize);

	local status = sspilib.GetUserNameExA(format, nameBuffer, pBuffSize);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return ffi.string(nameBuffer);
end


return {
	schannel = schannel;
	
	SecurityInterface = SecurityInterface;
	SecurityPackage = SecurityPackage;
	Credentials = CredHandle;

	getUserName = getUserName,
}