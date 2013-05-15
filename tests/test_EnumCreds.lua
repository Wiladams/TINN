
-- References
-- http://www.rohitab.com/discuss/topic/13775-msn-password-keyloger-help/
--
local ffi = require("ffi");
local bit = require("bit");
local lshift = bit.lshift;

local stringzutils = require("stringzutils");
local security_credentials = require"security_credentials_l1_1_0";
local WinCrypt = require("WinCrypt");
local crypt = require("crypt");
local error_handling = require("core_errorhandling_l1_1_1");
local core_string = require("core_string_l1_1_0");


local CREDENTIAL = ffi.typeof("CREDENTIALA");
local PCREDENTIAL = ffi.typeof("PCREDENTIALA");
local DATA_BLOB = ffi.typeof("DATA_BLOB");

local CredEnumerateA = security_credentials.CredEnumerateA;
local CredReadA = security_credentials.CredReadA;
local CredFree = security_credentials.CredFree;

local CRED_ENUMERATE_ALL_CREDENTIALS = 0x1;

--[[
typedef struct _CREDENTIALA {
    DWORD Flags;
    DWORD Type;
    LPSTR TargetName;
    LPSTR Comment;
    FILETIME LastWritten;
    DWORD CredentialBlobSize;
    LPBYTE CredentialBlob;
    DWORD Persist;
    DWORD AttributeCount;
    PCREDENTIAL_ATTRIBUTEA Attributes;
    LPSTR TargetAlias;
    LPSTR UserName;
} CREDENTIALA, *PCREDENTIALA;
--]]

local function getCredentials()
	local pCredentialCollection = ffi.new("PCREDENTIALA *[1]");
	local pCount = ffi.new("DWORD[1]");

	local status = CredEnumerateA(nil, CRED_ENUMERATE_ALL_CREDENTIALS, pCount, pCredentialCollection);
	if status == 0 then
		return false, error_handling.GetLastError();
	end

	local CredentialCollection = pCredentialCollection[0];

	local Count = pCount[0];

	print("Collection: ", CredentialCollection);
	print("Count: ", Count);

	-- for decoding blobs
	local EntropyData = ffi.new("int16_t[37]");
	local EntropyStringSeed = strdup("82BD0E67-9FEA-4748-8672-D5EFE5B779B0");
	local entropySeedLen = stringzutils.strlen(EntropyStringSeed);
	for i = 0, entropySeedLen-1 do
		local Tmp = EntropyStringSeed[i];
		Tmp = lshift(Tmp, 2);
		EntropyData[i] = Tmp;
	end

	local BlobCrypt = ffi.new("DATA_BLOB");
	local BlobPlainText = ffi.new("DATA_BLOB");
	local BlobEntropy = ffi.new("DATA_BLOB");
	BlobEntropy.pbData = ffi.cast("BYTE *", EntropyData);
	BlobEntropy.cbData = ffi.sizeof(EntropyData);
	


	for i=0,Count-1 do
		local creds = CredentialCollection[i];
		--print("Creds: ", creds);
		local Flags = creds.Flags;
		local Type = creds.Type;
		local TargetName = creds.TargetName;
		local Comment = creds.Comment;
		local TargetAlias = creds.TargetAlias;
		local userName = ffi.string(creds.UserName);

		if TargetName ~= nil then TargetName = ffi.string(TargetName); end
		if Comment ~= nil then Comment = ffi.string(Comment); end

		if creds.CredentialBlobSize > 0 then
			BlobCrypt.pbData = creds.CredentialBlob;
			BlobCrypt.cbData = creds.CredentialBlobSize;
			local status = crypt.CryptUnprotectData(BlobCrypt, nil, BlobEntropy, nil, nil, 1, BlobPlainText);
			--print("STATUS: ", status);
			--print("BlobCrypt: ", BlobCrypt.cbData, BlobCrypt.pbData);
			local blobdatastr = ffi.string(BlobCrypt.pbData, BlobCrypt.cbData);
			--print("BlobCryptData: ", blobdatastr);
			--print("Blob UNICODE: ", core_string.toAnsi(blobdatastr));
			--print("BlobPlainText: ", BlobPlainText.cbData, BlobPlainText.pbData);
		end

		if creds.AttributeCount > 0 then
			local attribs = {};

			print("+++++++++++++++++++++++++++++++++++++");
			for j=0,creds.AttributeCount-1 do
				
				local keyword = creds.Attributes[j].Keyword;
				--print("KEYWORD: ", ffi.string(keyword));
				local value = creds.Attributes[j].Value;
				local valueSize = creds.Attributes[j].ValueSize;
				--print("Value: ", valueSize, value);
				local valueStr = ffi.string(value, valueSize);
				--print("Value String: ", valueStr);
				table.insert(attribs, valueStr);
			end
				valueStr = table.concat(attribs);
--			print("Attribute Value")
			print(valueStr);			
		end
--[[
		print("====================================");
		print("Flags: ", string.format("0x%x", Flags));
		print("Type: ", string.format("0x%x", Type));
		print("TargetName: ", TargetName);
		print("Comment: ", Comment);
		print("Blob Size: ", creds.CredentialBlobSize);
		print("Blob Ptr: ", creds.CredentialBlob);
		print("Persist: ", creds.Persist);
		print("Attribute Count: ", creds.AttributeCount);
		print("TargetAlias: ", TargetAlias);
		print("UserName: ", userName);
--]]
	end
end

local function CREDENTIALS()
	

	local function closure()
		local pCredentialCollection = ffi.new("PCREDENTIALA [1]");
		local pCount = ffi.new("DWORD[1]");
		local res = {};

--		local status = CredEnumerateA("Passport.Net\\*", NULL, pCount, CredentialCollection);
		local status = CredEnumerateA(nil, CRED_ENUMERATE_ALL_CREDENTIALS, pCount, pCredentialCollection);
		if status == 0 then
			return false, error_handling.GetLastError();
		end

		local CredentialCollection = pCredentialCollection[0];

		print("CredUnumerateA SUCCESS: ", CredentialCollection);

--	local EntropyStringSeed = ffi.new("char [37]");
--		strlcpy(EntropyStringSeed, "82BD0E67-9FEA-4748-8672-D5EFE5B779B0", ffi.sizeof(EntropyStringSeed)); -- credui.dll
		local EntropyData = ffi.new("int16_t[37]");
		local EntropyStringSeed = strdup("82BD0E67-9FEA-4748-8672-D5EFE5B779B0");

print("after strdup: ", ffi.string(EntropyStringSeed));

		local Count = pCount[0];
print("Count: ", Count);

		if (Count > 0) then
			local entropySeedLen = stringzutils.strlen(EntropyStringSeed);
print("entropySeedLen: ", entropySeedLen);

			for i = 0, entropySeedLen-1 do
				local Tmp = EntropyStringSeed[i];
				Tmp = lshift(Tmp, 2);
				EntropyData[i] = Tmp;
			end

			local BlobCrypt = ffi.new("DATA_BLOB");
			local BlobPlainText = ffi.new("DATA_BLOB");
			local BlobEntropy = ffi.new("DATA_BLOB");

print("after blob creation");

			for i = 0, Count-1 do
				BlobEntropy.pbData = ffi.cast("BYTE *", EntropyData);
				BlobEntropy.cbData = ffi.sizeof(EntropyData);
				BlobCrypt.pbData = CredentialCollection[i].CredentialBlob;
				BlobCrypt.cbData = CredentialCollection[i].CredentialBlobSize;
				local status = crypt.CryptUnprotectData(BlobCrypt, nil, BlobEntropy, nil, nil, 1, BlobPlainText);
print("after unprotect: ", status);
				local userName = ffi.string(CredentialCollection[i].UserName);
				local password = ffi.string(BlobPlainText.pbData, BlobPlainText.cbData);
				table.insert(res, {UserName = userName, Password = password});
			end

		end

		CredFree(CredentialCollection);
		
		return res;
	end
	
	return closure();
end


local function main()

	local credentials, err = CREDENTIALS();
	if not credentials then
		return false, err;
	end

	for _,credential in ipairs(credentials) do
		print(string.format("Username : %s\nPassword : %s\n", credential.UserName, credential.Password));
	end
end

--print(main());

print(getCredentials());
