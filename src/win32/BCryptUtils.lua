local ffi = require "ffi"

local BCrypt = require "BCrypt"

local function bintohex(bytes, len)
	local str = ffi.string(bytes, len)

	return (str:gsub('(.)', function(c)
		return string.format('%02x', string.byte(c))
	end))
end


local BCryptKey = ffi.typeof("BCryptKey");
local BCryptKey_mt = {
	__gc = function(self)
		status = BCrypt.Lib.BCryptDestroyKey(self.Handle)
	end,

	__index  = {
		FinalizeKeyPair = function(self)
			local status = BCrypt.Lib.BCryptFinalizeKeyPair(self.Handle);

			return status == 0 or nil, status
		end,
	},
}
BCryptKey = ffi.metatype(BCryptKey, BCryptKey_mt);


local BCryptHash = ffi.typeof("BCryptHash");
local BCryptHash_mt = {
	__gc = function(self)
		local status = BCrypt.Lib.BCryptDestroyHash(self.Handle);
	end,

	__new = function(ct, algorithm)
		local phHash = ffi.new("BCRYPT_HASH_HANDLE[1]");
		local pbHashObject = nil
		local cbHashObject = 0
		local pbSecret = nil
		local cbSecret = 0
		local flags = 0

		local status = BCrypt.Lib.BCryptCreateHash(algorithm.Handle,
			phHash,
			pbHashObject,
			cbHashObject,
			pbSecret,
			cbSecret,
			flags);

		if status ~= 0 then
			return nil, status
		end

		return ffi.new(ct, phHash[0]);
	end,

	__index = {
		GetProperty = function(self, name, buffer, size)
			local pcbResult = ffi.new("uint32_t[1]")
			local buffptr = ffi.cast("uint8_t *", buffer)
			local status = BCrypt.Lib.BCryptGetProperty(self.Handle,
				name,
				buffptr, size,
				pcbResult,
				0);

			if status ~= 0 then
				--print("GetProperty, Error status: ", status);
				return nil, status
			end

			-- got the result back
			-- return it to the user
			return buffptr, pcbResult[0]
		end,

		GetPropertyBuffer = function(self, name)
			local pcbResult = ffi.new("uint32_t[1]")
			local status = BCrypt.Lib.BCryptGetProperty(self.Handle,
				name,
				nil, 0,
				pcbResult,
				0);

			if status ~= 0 then
				return nil, status
			end

			local bytesneeded = pcbResult[0]
			local pbOutput = ffi.new("uint8_t[?]", pcbResult[0]);

			return pbOutput, bytesneeded
		end,

		GetHashDigestLength = function(self)
			local size = ffi.sizeof("int32_t");
			local buff = ffi.new("int[1]")
			local outbuff, byteswritten = self:GetProperty(BCrypt.BCRYPT_HASH_LENGTH, buff, size)

			--print("GetHashLength: ", outbuff, byteswritten);

			if not outbuff then
				return nil, byteswritten
			end

			return buff[0];
		end,

		Clone = function(self)
			local phNewHash = ffi.new("BCRYPT_HASH_HANDLE[1]");
			local pbHashObject = nil
			local cbHashObject = 0
			local pbSecret = nil
			local cbSecret = 0
			local flags = 0

			local status = BCrypt.Lib.BCryptDuplicateHash(self.Handle,
				phNewHash,
				pbHashObject,
				cbHashObject,
				flags);

			if status ~= 0 then
				return nil, status
			end

			return ffi.new("BCryptHash", phNewHash[0]);
		end,

		HashMore = function(self, chunk, chunksize)
			local pbInput = chunk
			local cbInput
			local flags = 0
--print("HashMore: ", chunk, chunksize)
			if type(chunk) == "string" then
				pbInput = ffi.cast("const uint8_t *", chunk);
				cbInput = chunksie or #chunk
			else
				cbInput = cbInput or 0
			end

			local status = BCrypt.Lib.BCryptHashData(self.Handle,
				pbInput,
				cbInput,
				flags);

			return status == 0 or nil, status
		end,

		Finish = function(self, pbOutput, cbOutput)
			local flags = 0
			local status = BCrypt.Lib.BCryptFinishHash(self.Handle,
				pbOutput,
				cbOutput,
				flags);

			return status == 0 or nil, status
		end,

		CreateDigest = function(self, input, inputLength)
			local outlen = self:GetHashDigestLength();
			local outbuff = ffi.new("uint8_t[?]", outlen);

			self:HashMore(input, inputLength);
			self:Finish(outbuff, outlen);

			local hex = bintohex(outbuff, outlen);

			return hex, outbuff, outlen
		end,

	},
}

BCryptHash = ffi.metatype(BCryptHash, BCryptHash_mt);


local BCryptAlgorithm = ffi.typeof("struct BCryptAlgorithm")
local BCryptAlgorithm_mt = {
	__gc = function(self)
		--print("BCryptAlgorithm: GC")
		if self.Handle ~= nil then
			BCrypt.Lib.BCryptCloseAlgorithmProvider(self.Handle, 0)
		end
	end;

	__new = function(ctype, ...)
		--print("BCryptAlgorithm: NEW");
		local params = {...}
		local algoid = params[1]
		local impl = params[2]

		if not algoid then
			return nil
		end

		local lphAlgo = ffi.new("BCRYPT_ALG_HANDLE[1]")
		local algoidptr = ffi.cast("const uint16_t *", algoid)
		local status = BCrypt.Lib.BCryptOpenAlgorithmProvider(lphAlgo, algoidptr, impl, 0);

		if not BCrypt.BCRYPT_SUCCESS(status) then
			--print("BCryptAlgorithm(), status: ", status);
			return nil
		end

		local newone = ffi.new("struct BCryptAlgorithm", lphAlgo[0])
		return newone;
	end;

	__index = {
		-- CreateHash
		CreateHash = function(self)
			return BCryptHash(self);
		end,

		CreateKeyPair = function(self, length, flags)
			length = length or 384
			flags = flags or 0
			local fullKey = ffi.new("BCRYPT_KEY_HANDLE[1]");
			local status = BCrypt.Lib.BCryptGenerateKeyPair(self.Handle,
				fullKey, length, flags);

			if status ~= 0 then
				return nil, status
			end

			-- create the key pair
			local fullKey = fullKey[0];

		end,
	}
};
BCryptAlgorithm = ffi.metatype(BCryptAlgorithm, BCryptAlgorithm_mt);

CryptUtils = {
	BCryptKey = BCryptKey,
	BCryptHash = BCryptHash,
	BCryptAlgorithm = BCryptAlgorithm,
}

--[[
	Pre allocated Algorithm objects
--]]

-- Hash Algorithms
CryptUtils.MD2Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_MD2_ALGORITHM);
CryptUtils.MD4Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_MD4_ALGORITHM);
CryptUtils.MD5Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_MD5_ALGORITHM);

CryptUtils.SHA1Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_SHA1_ALGORITHM);
CryptUtils.SHA256Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_SHA256_ALGORITHM);
CryptUtils.SHA384Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_SHA384_ALGORITHM);
CryptUtils.SHA512Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_SHA512_ALGORITHM);

-- Random Number Generators
CryptUtils.RNGAlgorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_RNG_ALGORITHM);
CryptUtils.RNGFIPS186DSAAlgorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_RNG_FIPS186_DSA_ALGORITHM);
CryptUtils.RNGDUALECAlgorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_RNG_DUAL_EC_ALGORITHM);



CryptUtils.RSAAlgorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_RSA_ALGORITHM);
CryptUtils.RSASignAlgorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_RSA_SIGN_ALGORITHM);

CryptUtils.DHAlgorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_DH_ALGORITHM);
CryptUtils.DSAAlgorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_DSA_ALGORITHM);
CryptUtils.RC2Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_RC2_ALGORITHM);
CryptUtils.RC4Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_RC4_ALGORITHM);

CryptUtils.AESAlgorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_AES_ALGORITHM);
CryptUtils.AESGMACAlgorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_AES_GMAC_ALGORITHM);

CryptUtils.DESAlgorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_DES_ALGORITHM);
CryptUtils.DESXAlgorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_DESX_ALGORITHM);
CryptUtils.DES3Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_3DES_ALGORITHM);
CryptUtils.DES3_112Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_3DES_112_ALGORITHM);


CryptUtils.ECDSA_P256Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_ECDSA_P256_ALGORITHM);
CryptUtils.ECDSA_P384Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_ECDSA_P384_ALGORITHM);
CryptUtils.ECDSA_P521Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_ECDSA_P521_ALGORITHM);
CryptUtils.ECDH_P256Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_ECDH_P256_ALGORITHM);
CryptUtils.ECDH_P384Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_ECDH_P384_ALGORITHM);
CryptUtils.ECDH_P521Algorithm = CryptUtils.BCryptAlgorithm(BCrypt.BCRYPT_ECDH_P521_ALGORITHM);



--[[
	Hash Functions
--]]
CryptUtils.Hashes = {
--	MD2 = CryptUtils.MD2Algorithm:CreateHash();
--	MD4 = CryptUtils.MD4Algorithm:CreateHash();
--	MD5 = CryptUtils.MD5Algorithm:CreateHash();

	SHA1 = CryptUtils.SHA1Algorithm:CreateHash();
	SHA256 = CryptUtils.SHA256Algorithm:CreateHash();
	SHA384 = CryptUtils.SHA384Algorithm:CreateHash();
	SHA512 = CryptUtils.SHA512Algorithm:CreateHash();
}

CryptUtils.MD2 = function(content, len)
	local MD2 = CryptUtils.MD2Algorithm:CreateHash();
	return MD2:CreateDigest(content, len);
end

CryptUtils.MD4 = function(content, len)
	local MD4 = CryptUtils.MD4Algorithm:CreateHash();
	return MD4:CreateDigest(content, len);
end

CryptUtils.MD5 = function(content, len)
	local MD5 = CryptUtils.MD5Algorithm:CreateHash();
	
	return MD5:CreateDigest(content, len);
end



CryptUtils.SHA1 = function(content, len)
	local SHA1 = CryptUtils.SHA1Algorithm:CreateHash();
	return SHA1:CreateDigest(content, len);
end

CryptUtils.SHA256 = function(content, len)
	local SHA256 = CryptUtils.SHA256Algorithm:CreateHash();

	return SHA256:CreateDigest(content, len);
end

CryptUtils.SHA384 = function(content, len)
	local SHA384 = CryptUtils.SHA384Algorithm:CreateHash();
	return SHA384:CreateDigest(content, len);
end

CryptUtils.SHA512 = function(content, len)
	local SHA512 = CryptUtils.SHA512Algorithm:CreateHash();
	return SHA512:CreateDigest(content, len);
end



--[[
	Convenience Functions
--]]

CryptUtils.GetRandomBytes = function(howmany)
	howmany = howmany or 4

	local rngBuff = ffi.new("uint8_t[?]", howmany)

	local status =  BCrypt.Lib.BCryptGenRandom(nil, rngBuff, howmany, BCrypt.BCRYPT_USE_SYSTEM_PREFERRED_RNG);
	if status >= 0 then
		return rngBuff, howmany
	end

	return nil, status
end

return CryptUtils
