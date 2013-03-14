--[[
	base64.lua
	base64 encoding and decoding for LuaJIT
	William Adams <william_a_adams@msn.com>
	17 Mar 2012
	This code is hereby placed in the public domain

	The derivation of this code is from a public domain
	implementation in 'C' by Luiz Henrique de Figueiredo <lhf@tecgraf.puc-rio.br>
--]]

local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local rshift = bit.rshift

base64={}
base64.base64bytes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- ' ' 0x20, '\t' 0x09, '\n' 0x0a, '\v' 0x0b, '\f' 0x0c, '\r' 0x0d
function base64.isspace(c)
	return c == 0x20 or c == 0x08 or c == 0x09 or
	  c == 0x0a or c == 0x0b or c == 0x0c or c == 0x0d
end

function base64.char64index(c)
	local pstart = ffi.cast("const char *", base64.base64bytes);
	local p = pstart
	local offset = 0;

	while p[offset] ~= c do
		if p[offset] == 0 then
			--print("RETURNING NULL");
			return nil
		end
		offset = offset + 1
	end

	return offset
end



function base64.bencode(b, c1, c2, c3, n)
	local tuple = (c3+256*(c2+256*c1));
	local i;
	local s = {}

	for i=0, 3 do
		local offset = (tuple % 64)+1
		local c = base64.base64bytes:sub(offset, offset)

		s[4-i] = c;
		tuple = rshift(tuple, 6)	-- tuple/64;
	end

	for i=n+2, 4 do
		s[i]='=';
	end

	local encoded = table.concat(s)

	table.insert(b,encoded);
end


function base64.encode(s, l)
	l = l or #s
	local ptr = ffi.cast("const uint8_t *", s);

	local b = {};
	local n = math.floor(l/3)
	for i=1,n do
		local c1 = ptr[(i-1)*3+0]
		local c2 = ptr[(i-1)*3+1]
		local c3 = ptr[(i-1)*3+2]
		base64.bencode(b,c1,c2,c3,3);
	end

	-- Finish off the last few bytes
	local leftovers = l%3

	if leftovers == 1 then
		local c1 = ptr[(n*3)+0]
		base64.bencode(b,c1,0,0,1);
	elseif leftovers == 2 then
		local c1 = ptr[(n*3)+0]
		local c2 = ptr[(n*3)+1]
		base64.bencode(b,c1,c2,0,2);
	end

	return table.concat(b)
end


function base64.bdecode(b, c1, c2, c3, c4, n)
	local tuple = c4+64*(c3+64*(c2+64*c1));
	local s={};

	for i=1,n-1 do
		local shifter = 8 * (3-i)
		local abyte = band(rshift(tuple, shifter), 0xff)
		local achar = string.char(abyte);
		s[i] = achar
	end

	local decoded = table.concat(s)
	table.insert(b, decoded)
end


function base64.decode(s)
	local T_eq = string.byte('=')
	local l = #s;
	local b = {};
	local n=0;
	local t = ffi.new("char[4]",0);
	local offset = 0
	local ptr = ffi.cast("const char *", s);

	while (offset < l) do
		local c = ptr[offset];
		offset = offset + 1

		if c == 0 then
			return table.concat(b);
		elseif c == T_eq then
			if n ==  1 then
				base64.bdecode(b,t[0],0,0,0,1);
			end
			if n == 2 then
				base64.bdecode(b,t[0],t[1],0,0,2);
			end
			if n == 3 then
				base64.bdecode(b,t[0],t[1],t[2],0,3);
			end

			-- If we've swallowed the '=', then
			-- we're at the end of the string, so return
			return table.concat(b)
		elseif base64.isspace(c) then
			-- If whitespace, then do nothing
		else
			local p = base64.char64index(c);
			if (p==nil) then
				return nil;
			end

			t[n]= p;
			n = n+1
			if (n==4) then
				base64.bdecode(b,t[0],t[1],t[2],t[3],4);
				n=0;
			end
		end
	end

	-- if we've gotten to here, we've reached
	-- the end of the string, and there were
	-- no padding characters, so return decoded
	-- string in full
	return table.concat(b);
end

return base64
