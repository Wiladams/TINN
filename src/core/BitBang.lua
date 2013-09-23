local ffi = require "ffi"

local bit = require "bit"
local band = bit.band
local bor = bit.bor
local bxor = bit.bxor
local bnot = bit.bnot
local rshift = bit.rshift


function isset(value, bit, endian)
	return band(value, 2^bit) > 0
end

function setbit(value, bit, endian)
	if endian == "be" then
		return bor(value, 2^bit)
	else
		return bor(value, 2^bit)
	end
end

function clearbit(value, bit)
	return band(value, bnot(2^bit))
end

function numbertobinary(value, nbits, bigendian)
	nbits = nbits or 32
	local res={}

	if bigendian then
		for i=nbits-1,0,-1 do
			if isset(value,i) then
				table.insert(res, '1')
			else
				table.insert(res, '0')
			end
		end
	else
		for i=0, nbits-1 do
			if isset(value,i) then
				table.insert(res, '1')
			else
				table.insert(res, '0')
			end
		end
	end

	return table.concat(res)
end



function binarytonumber(str, bigendian)
	local len = string.len(str)
	local value = 0

	if bigendian then
		for i=0,len-1 do
			if str:sub(len-i,len-i) == '1' then
				value = setbit(value, i)
			end
		end
	else
		for i=0, len-1 do
			if str:sub(i+1,i+1) == '1' then
				value = setbit(value, i)
			end
		end
	end

	return value
end

function bytestobinary(bytes, length, offset, bigendian)
	offset = offset or 0
	nbits = 8

	local res={}

	if bigendian then
		for idx=offset+length-1, 0,-1 do
			table.insert(res, numbertobinary(bytes[idx],nbits, bigendian))
		end

	else
		for idx=offset,offset+length-1 do
			table.insert(res, numbertobinary(bytes[idx],nbits, bigendian))
		end
	end

	return table.concat(res)
end

function getbitsvalue(src, lowbit, bitcount)
	lowbit = lowbit or 0
	bitcount = bitcount or 32

	local value = 0
	for i=0,bitcount-1 do
		value = bor(value, band(src, 2^(lowbit+i)))
	end

	return rshift(value,lowbit)
end

function getbitstring(value, lowbit, bitcount, bigendian)
	return numbertobinary(getbitsvalue(value, lowbit, bitcount), bitcount, bigendian)
end

-- Given a bit number, calculate which byte
-- it would be in, and which bit within that
-- byte.
function getbitbyteoffset(bitnumber, bigendian)
	local byteoffset = math.floor(bitnumber /8)
	local bitoffset

	if bigendian then
		bitoffset = 7 - (bitnumber % 8)
	else
		bitoffset = bitnumber % 8
	end

	return byteoffset, bitoffset
end


function getbitsfrombytes(bytes, startbit, bitcount, bigendian)
	if not bytes then return nil end

	local value = 0
	local byteoffset, bitoffset;

--print("=================")
--print("getbitsfrombytes: ", startbit, bitcount, bigendian);

	for i=1,bitcount do
		local byteoffset, bitoffset = getbitbyteoffset(startbit+i-1, bigendian)
		local bitval = isset(bytes[byteoffset], bitoffset)

--print(bitval)

		--value = setbit(value, i-1)

		if bitval then
			if bigendian then
				value = setbit(value, bitcount - i);
			else
				value = setbit(value, i-1)
			end
		end
	end
--print(value)
--print("=================")
	return value
end

function setbitstobytes(bytes, startbit, bitcount, value, bigendian)

	for i=0,bitcount-1 do
		local byteoffset, bitoffset = getbitbyteoffset(startbit+i, bigendian)
		local bitval
		if bigendian then
			bitval = isset(value, bitcount-1-i)
		else
			bitval = isset(value, i)
		end
--print("byte,bit,val: ", byteoffset, bitoffset, bitval)
		if bitval then
			bytes[byteoffset] = setbit(bytes[byteoffset], bitoffset)			
		end
	end

	return bytes
end

return {
	isset = isset,
	clearbit = clearbit,
	setbit = setbit, 
	
	binarytonumber = binarytonumber,
	bytestobinary = bytestobinary,
	getbitstring = getbitstring,
	getbitsvalue = getbitsvalue,
	getbitsfrombytes = getbitsfrombytes,
	numbertobinary = numbertobinary,
	setbitstobytes = setbitstobytes,
}
