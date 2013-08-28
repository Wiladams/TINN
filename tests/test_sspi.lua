package.path = package.path..";../?.lua"

local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;
local band = bit.band;

local sspi = require("sspi");
local SecurityInterface = sspi.SecurityInterface;
local SecurityPackage = sspi.SecurityPackage;
local schannel = sspi.schannel;





function test_EnumeratePackages()
	local packages, err = SecurityPackage:GetPackages();

	print(" SecurityPackage:GetPackages(): ", packages, err);

	if packages then
		for k, package in pairs(packages) do
			print("================================");
			print("Name: ", package.Name);
			print("Comment: ", package.Comment);
			print("MaxToken: ", package.MaxToken);
			print(package:ListCapabilities());
		end
	end
end

function test_FindPackage()
	local package, err = SecurityPackage:FindPackage("Negotiate");


	print(" SecurityPackage:FindPackage(): ", package, err);

	if package then
		print("================================");
		print("Name: ", package.Name);
		print("Comment: ", package.Comment);
		print(package:ListCapabilities());
	end
end


function test_CreateCreds()
	print("== TEST AcquireCredsHandle - BEGIN ==")

	local package, err = SecurityPackage:FindPackage(schannel.UNISP_NAME);
	
	local authData = ffi.new("SCHANNEL_CRED");

	authData.dwVersion = ffi.C.SCHANNEL_CRED_VERSION;
	authData.grbitEnabledProtocols = ffi.C.SP_PROT_TLS1_2_CLIENT;
	authData.dwFlags = bor(ffi.C.SCH_CRED_AUTO_CRED_VALIDATION, ffi.C.SCH_CRED_USE_DEFAULT_CREDS);

	local creds, err = package:CreateCredentials(ffi.C.SECPKG_CRED_OUTBOUND, authData);

	print("package:CreateCredentials(): ", creds, err);
	print("Cipher Strength: ", creds:GetCipherStrengths());

	print("== TEST AcquireCredsHandle - END ==")
end

function test_DefaultCredentials()
	print("== TEST DefaultCredentials - BEGIN ==")

	local package, err = SecurityPackage:FindPackage(schannel.UNISP_NAME);

--print("FindPackage(): ", package, err);
	if not package then 
		return false, err;
	end

	local creds, err = package:GetDefaultCredentials();

	if not creds then 
		return false, err;
	end

	local protos, err = creds:ListSupportedProtocols();

	print("Protocols: ", err); 
	print(protos);

	print("Supports TLS1_CLIENT: ", creds:SupportsProtocol(ffi.C.SP_PROT_TLS1_CLIENT));
	print("Supports TLS2_SERVER: ", creds:SupportsProtocol(ffi.C.SP_PROT_TLS1_2_SERVER));

	print("Cipher Strength: ", creds:GetCipherStrengths());
	print("User Name: ", creds:GetUserName());

	print("Supported Algorithms")
	local algos, err = creds:GetSupportedAlgorithms();
	if not algos then
		print("No Algorithms: ", err);
	else
		for _,algo in ipairs(algos) do
			print("Algo: ", string.format("0x%x",algo));
		end
	end
	-- Display the attributes of the credentials
	print("== TEST DefaultCredentials - END ==")
end


local test_ClientConnection = function(pszTargetName)

	local package, err = SecurityPackage:FindPackage(schannel.UNISP_NAME);
	
	local creds, err = package:GetDefaultCredentials();


	print("GetCredentials: ", creds, err);

	-- Start initilization process
	local phContext = nil;
	local fContextReq = bor(ffi.C.ISC_REQ_CONFIDENTIALITY, ffi.C.ISC_REQ_EXTENDED_ERROR,ffi.C.ISC_REQ_STREAM);
	local secContext, err = creds:InitializeSecurityContext(phContext, pszTargetName, fContextReq);
	
	print("FIRST InitializeSecurityContext: ",secContext, string.format("0x%x", err));
	

	-- Loop on initialize until done
	-- this is the handshake loop
	while true do 
		local secContext, err = creds:InitializeSecurityContext(secContext, pszTargetName, fContextReq);
	print("  InitializeSecurityContext: ",secContext, string.format("0x%x",err));
		if not secContext then
			return false, err
		end
	end

end



test_EnumeratePackages();
--test_FindPackage();
--test_CreateCreds();
--test_DefaultCredentials();

--test_ClientConnection();

--InitiateClientConnection("www.google.com");



--[[
typedef struct _SCHANNEL_CRED {
  DWORD           dwVersion;
  DWORD           cCreds;
  PCCERT_CONTEXT  *paCred;
  HCERTSTORE      hRootStore;
  DWORD           cMappers;
  struct _HMAPPER  **aphMappers;
  DWORD           cSupportedAlgs;
  ALG_ID          *palgSupportedAlgs;
  DWORD           grbitEnabledProtocols;
  DWORD           dwMinimumCipherStrength;
  DWORD           dwMaximumCipherStrength;
  DWORD           dwSessionLifespan;
  DWORD           dwFlags;
  DWORD           dwCredFormat;
} SCHANNEL_CRED, *PSCHANNEL_CRED;
--]]
--[[
		local channelcreds = ffi.new("SCHANNEL_CRED",
			{
				ffi.C.SCHANNEL_CRED_VERSION;
				0;
				nil,
				nil, 
				0,
				nil;	-- aphMappers
				0;		-- cSupportedAlgs
				nil;	-- palgSupportedAlgs
				0;		-- grbitEnabledProtocols;
				0;		-- dwMinimumCipherStrength;
				0;		-- dwMaximumCipherStrength;
				0;		-- dwSessionLifespan;
				0;		-- dwFlags
				0;		-- dwCredFormat
			});
--]]