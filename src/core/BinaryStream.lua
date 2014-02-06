--[[
	References:

	http://en.wikipedia.org/wiki/Endianness
	http://local.wasp.uwa.edu.au/~pbourke/dataformats/endian/

	The BinaryStream object wraps a basic stream and implements
	a series of readers and writers of base types.  There are a
	couple of benefits to having this class.

	1) It can work with any stream.  The stream just has to
	implement ReadByte(), ReadBytes(buffer, count, offset) and
	WriteByte(value), WriteBytes(buffer, count, offset).  With
	these basic functions available, any of the base types
	can be read and written.

	2) It can deal with endianness (LSB, and MSB).  The stream
	can be configured to assume the base stream is LSB or MSB
	and will perform all the conversions automatically.
--]]


local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local bswap = bit.bswap
local lshift = bit.lshift
local rshift = bit.rshift

local BinaryStream = {}
setmetatable(BinaryStream, {
	__call = function(self, ...)
		return BinaryStream.new(...);
	end,
})
local BinaryStream_mt = {
	__index = BinaryStream;
}

ffi.cdef[[
typedef union  {
		uint8_t		Byte;
		int16_t 	Int16;
		uint16_t	UInt16;
		int32_t		Int32;
		uint32_t	UInt32;
		int64_t		Int64;
		uint64_t	UInt64;
		float 		Single;
		double 		Double;
		uint8_t bytes[8];
} bstream_types_t
]]
local bstream_types_t = ffi.typeof("bstream_types_t")


function BinaryStream.new(stream, bigendian)
	local obj = {
		Stream = stream,
		BigEndian = bigendian,
		NeedSwap = 	bigendian == ffi.abi("le"),
		valunion = bstream_types_t();
	}

	setmetatable(obj, BinaryStream_mt);

	return obj
end


function BinaryStream.readByte(self)
	return self.Stream:readByte()
end

function BinaryStream:readBytes(buffer, size, offset)
	return self.Stream:readBytes(buffer, size, offset)
end

function BinaryStream:ReadBytesN(buff, n, reverse)
	if reverse then
		for i=n,1,-1 do
			buff[i-1] = self:ReadByte()	
		end
	else
		for i=1,n do
			buff[i-1] = self:ReadByte()
		end
	end
end



function BinaryStream:ReadIntN(n)
	local value = 0;

	if self.BigEndian then
		for i=1,n do
			value = lshift(value,8) + self:ReadByte()
		end
	else
		for i=1,n do
			value = value + lshift(self:ReadByte(),8*(i-1))
		end
	end

	return value;
end


function BinaryStream:ReadInt16()
	return tonumber(ffi.cast("int16_t", self:ReadIntN(2)));
end

function BinaryStream:ReadUInt16()
	return tonumber(ffi.cast("uint16_t", self:ReadIntN(2)));
end

function BinaryStream:ReadInt32()
	return tonumber(ffi.cast("int32_t", self:ReadIntN(4)));
end

function BinaryStream:ReadUInt32()
	return tonumber(ffi.cast("uint32_t", self:ReadIntN(4)));
end

function BinaryStream:ReadInt64()
	self:ReadBytesN(self.valunion.bytes, 8, self.NeedSwap)
	return self.valunion.Int64;
end

function BinaryStream:ReadUInt64()
	self:ReadBytesN(self.valunion.bytes, 8, self.NeedSwap)
	return tonumber(self.valunion.UInt64);
end

--[[
	Assuming IEEE format for 4-byte floats
--]]
function BinaryStream:ReadSingle()
	self:ReadBytesN(self.valunion.bytes, 4, self.NeedSwap)
	return tonumber(self.valunion.Single);
end

function BinaryStream:ReadDouble()
	self:ReadBytesN(self.valunion.bytes, 8, self.NeedSwap)
	return tonumber(self.valunion.Double);
end




--[[
	Writing
--]]

function BinaryStream:writeByte(value)
	self.valunion.Byte = value;
	return self.Stream:writeBytes(self.valunion.bytes, 1, 0);
	--return self.Stream:writeByte(value) == 1;
end

function BinaryStream.writeBytes(self, buff, len, offset)
	return self.Stream:writeBytes(buff, len, offset);
end

function BinaryStream:WriteBytesN(buff, n, reverse)
	if reverse then
		for i=n,1,-1 do
			self:writeByte(buff[i-1])	
		end
	else
		for i=1,n do
			self:writeByte(buff[i-1])
		end
	end
end

function BinaryStream:WriteIntN(n, value)
	--print("WriteIntN: ", value, tonumber(value));
	value = tonumber(value)

	if self.BigEndian then
		for i=n,1,-1 do
			local bytesWritten, err = self:writeByte(rshift(band(lshift(0xff,8*(i-1)), value), 8*(i-1)));
			if not bytesWritten then
				return false, err
			end
		end
	else
		for i=1,n do
			local bytesWritten, err = self:writeByte(rshift(band(lshift(0xff,8*(i-1)), value), 8*(i-1)));
			if not bytesWritten then
				return false, err;
			end
		end
	end

	return n;
end

function BinaryStream:WriteInt16(value)
	return self:WriteIntN(2, ffi.cast("int16_t", value));
end

function BinaryStream:WriteUInt16(value)
	return self:WriteIntN(2, ffi.cast("uint16_t", value));
end

function BinaryStream:WriteInt32(value)
	return self:WriteIntN(4, ffi.cast("int32_t", value));
end

function BinaryStream:WriteUInt32(value)
	return self:WriteIntN(4, ffi.cast("uint32_t", value));
end


function BinaryStream:WriteInt64(value)
	self.valunion.Int64 = value
	self:WriteBytesN(self.valunion.bytes, 8, self.NeedSwap)

	return self
end

function BinaryStream:WriteUInt64(value)
	self.valunion.Int64 = value
	self:WriteBytesN(self.valunion.bytes, 8, self.NeedSwap)

	return self
end


function BinaryStream:WriteSingle(value)
	self.valunion.Single = value
	self:WriteBytesN(self.valunion.bytes, 4, self.NeedSwap)

	return self
end

function BinaryStream:WriteDouble(value)
	self.valunion.Double = value
	self:WriteBytesN(self.valunion.bytes, 8, self.NeedSwap)

	return self
end

BinaryStream.ReadByte = BinaryStream.readByte;
BinaryStream.ReadBytes = BinaryStream.readBytes;

BinaryStream.WriteByte = BinaryStream.writeByte;
BinaryStream.WriteBytes = BinaryStream.writeBytes;


return BinaryStream;
