local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift

--[[
	String Functions

	strlen
	strndup
	strdup
	strcpy
	strlcpy
	strlcat

	strchr
	strcmp
	strncmp
	strcasecmp
	strncasecmp

	strrchr
	strstr

	strpbrk

	bin2str
--]]



function strcmp(s1, s2)
--	local s1ptr = ffi.cast("const uint8_t *", s1);
--	local s2ptr = ffi.cast("const uint8_t *", s2);

	-- Move s1 and s2 to the first differing characters
	-- in each string, or the ends of the strings if they
	-- are identical.
	local pos = 0;
	while s1[pos] == s2[pos] do
		if s1[pos] == 0 then
			return 0
		end
		pos = pos + 1;
	end

	return s1[pos] - s2[pos]
end


local function strncmp(str1, str2, num)
	local pos = 0;
	while str1[pos] == str2[pos] do
		if str1[pos] == 0 then
			return 0;
		end

		if pos >= num then
			break;
		end

		pos = pos + 1; 
	end

	return str1[pos] - str2[pos]
end

function strncasecmp(str1, str2, num)
	local ptr1 = ffi.cast("const uint8_t*", str1)
	local ptr2 = ffi.cast("const uint8_t*", str2)

	for i=0,num-1 do
		if str1[i] == 0 or str2[i] == 0 then return 0 end

		if ptr1[i] > ptr2[i] then return 1 end
		if ptr1[i] < ptr2[i] then return -1 end
	end

	return 0
end


function strcasecmp(str1, str2)
	local ptr1 = ffi.cast("const uint8_t*", str1)
	local ptr2 = ffi.cast("const uint8_t*", str2)

	local num = math.min(strlen(ptr1), strlen(ptr2))
	for i=0,num-1 do
		if str1[i] == 0 or str2[i] == 0 then return 0 end

		if tolower(ptr1[i]) > tolower(ptr2[i]) then return 1 end
		if tolower(ptr1[i]) < tolower(ptr2[i]) then return -1 end
	end

	return 0
end

function strlen(str)
	local ptr = ffi.cast("uint8_t *", str);
	local idx = 0
	while ptr[idx] ~= 0 do
		idx = idx + 1
	end

	return idx
end

function strlcpy(dst, src, size)
	local dstptr = ffi.cast("char *", dst)
	local srcptr = ffi.cast("const char *", src)

	local len = strlen(src)
	len = math.min(size-1,len)

	ffi.copy(dstptr, srcptr, len)
	dstptr[len] = 0

	return len
end

function strndup(str,n)
	local newstr = ffi.new("char[?]", n+1);
	strlcpy(newstr, str, n);

	return newstr
end

function strdup(str)
	-- use strlen because we don't know what kind of string
	-- we're being passed.  It could be a Lua string, or a byte array
	return strndup(str, strlen(str));
end

function strcpy(dst, src)
	local len = strlen(src);
	strlcpy(dst, src, len);
end



function strlcat(dst, src, size)
	local dstptr = ffi.cast("char *", dst)
	local srcptr = ffi.cast("const char *", src)

	local dstlen = strlen(dstptr);
	local dstremaining = size-dstlen-1
	local srclen = strlen(srcptr);
	local len = math.min(dstremaining, srclen)


	for idx=dstlen,dstlen+len do
		dstptr[idx] = srcptr[idx-dstlen];
	end

	return dstlen+len
end



local function strchr(s, c)
	local p = ffi.cast("const char *", s);

	while p[0] ~= c do
		if p[0] == 0 then
			return nil
		end
		p = p + 1;
	end

	return p
end

local function strrchr(s, c)
	local p = ffi.cast("const char *", s);
	local offset = strlen(p);

	while offset >= 0 do
		if p[offset] == c then
			return p+offset
		end
		offset = offset - 1;
	end

	return nil
end

local function strstr(str, target)

	if (target == nil or target[0] == 0) then
		return str;
	end

	local p1 = ffi.cast("const char *", str);

	while (p1[0] ~= 0) do

		local p1Begin = p1;
		local p2 = target;

		while (p1[0]~=0 and p2[0]~=0 and p1[0] == p2[0]) do
			p1 = p1 + 1;
			p2 = p2 + 1;
		end

		if (p2[0] == 0) then
			return p1Begin;
		end

		p1 = p1Begin + 1;
	end

	return nil;
end


--[[
	String Helpers
--]]

-- Given two null terminated strings
-- return how many bytes they have in common
-- this is for prefix matching
local function string_same(a, b)
	local p1 = ffi.cast("const char *", a);
	local p2 = ffi.cast("const char *", b);

    local bytes = 0;

    while (p1[bytes] ~= 0 and p2[bytes] ~= 0 and p1[bytes] == p2[bytes]) do
		bytes = bytes+1
    end

    return bytes;
end

-- Stringify binary data. Output buffer must be twice as big as input,
-- because each byte takes 2 bytes in string representation

local hex = strdup("0123456789abcdef")

function bin2str(to, p, len)
--print("bin2str, len: ", len);
	local off1, off2;
	while (len > 0) do
		off1 = rshift(p[0], 4)

		to[0] = hex[off1];
		to = to + 1;
		off2 = band(p[0], 0x0f);
		to[0] = hex[off2];
		to = to + 1;
		p = p + 1;
		len = len - 1;

--		print(off1, off2);
	end
	to[0] = 0;
end


local function bintohex(s)
	return (s:gsub('(.)', function(c)
		return string.format('%02x', string.byte(c))
	end))
end

local function hextobin(s)
	return (s:gsub('(%x%x)', function(hex)
		return string.char(tonumber(hex, 16))
	end))
end

return {
	strlen = strlen,
	strcpy = strcpy,
	strncmp = strncmp,
	
	string_same = string_same,

	bintohex = bintohex,
	hextobin = hextobin,
}
