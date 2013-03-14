package.path = package.path..";../?.lua"

local ffi = require("ffi")

local MemoryStream = require("MemoryStream")
local BinaryStream = require("BinaryStream")

local test_WriteByte = function()
	local mstream = MemoryStream.new(1024);
	local bstream = BinaryStream.new(mstream);

	bstream:WriteByte(string.byte('H'))
	mstream:WriteBytes("ello, World!");

	mstream:Seek(0);
	for i=1,mstream:BytesReadyToBeRead() do
		local abyte = bstream:ReadByte();
		print(abyte, string.char(abyte))
	end
end

local test_Int16 = function()
	local mstream = MemoryStream.new(1024);
	local bstream = BinaryStream.new(mstream, true);

	bstream:WriteInt16(0x00ff);
	bstream:WriteInt16(0xff00);

	mstream:Seek(0);
	for i=1,mstream:BytesReadyToBeRead() do
		local abyte = bstream:ReadByte();
		print(string.format("0x%02x", abyte))
	end

	mstream:Seek(0)
	local value1 = bstream:ReadInt16();
	print("value1:", type(value1), string.format("0x%04x",value1), value1);

	local value2 = bstream:ReadInt16();
	print("value2:", type(value2), string.format("0x%04x",value2), value2);
	print("value1:", type(value1), string.format("0x%04x",value1), value1);

	mstream:Seek(2);
	local value3 = bstream:ReadUInt16();
	print("value3:", type(value3), string.format("0x%04x",value3), value3);
end


local test_Int32 = function()
	local mstream = MemoryStream.new(1024);
	local bstream = BinaryStream.new(mstream);


	bstream:WriteUInt32(0x0000ffff);
	bstream:WriteUInt32(0xffff0000);

	mstream:Seek(0);
	for i=1,mstream:BytesReadyToBeRead() do
		local abyte = bstream:ReadByte();
		print(string.format("0x%02x", abyte))
	end

	mstream:Seek(0)
	local value1 = bstream:ReadInt32();
	print("value1:", type(value1), string.format("0x%08x",value1), value1);

	local value2 = bstream:ReadInt32();
	print("value2:", type(value2), string.format("0x%08x",value2), value2);
	print("value1:", type(value1), string.format("0x%08x",value1), value1);

	mstream:Seek(4);
	local value3 = bstream:ReadUInt32();
	print("value3:", type(value3), string.format("0x%08x",value3), value3);
end

local test_Int64 = function()
	local mstream = MemoryStream.new(1024);
	local bstream = BinaryStream.new(mstream);


	--bstream:WriteUInt64(0xFFFF);		-- 52-bit pattern
	bstream:WriteUInt64(0x7FFFFFFFFFFFF);		-- 52-bit pattern
	bstream:WriteUInt64(0x0000000fffffffffULL);
	bstream:WriteInt64(0x7fffffffffffffffLL);

	print("Position: ", mstream:GetPosition());

	mstream:Seek(0);
	for i=1,mstream:BytesReadyToBeRead() do
		local abyte = bstream:ReadByte();
		print(string.format("0x%02x", abyte))
	end

	mstream:Seek(0)
	local value1 = bstream:ReadInt64();
	print("value1:", type(value1), value1);


	local value2 = bstream:ReadUInt64();
	print("value2:", type(value2),  value2);
	print("value1:", type(value1),  value1);

	local value3 = bstream:ReadInt64();
	assert(value3 == 0x7fffffffffffffffLL)
end

local test_Single = function()
	local mstream = MemoryStream.new(1024);
	local bstream = BinaryStream.new(mstream);


	bstream:WriteSingle(25.7);
	bstream:WriteSingle(54321.2345);

	mstream:Seek(0);
	for i=1,mstream:BytesReadyToBeRead() do
		local abyte = bstream:ReadByte();
		print(string.format("0x%02x", abyte))
	end

	mstream:Seek(0)
	local value1 = bstream:ReadSingle();
	print("value1:", type(value1), value1);

	local value2 = bstream:ReadSingle();
	print("value2:", type(value2), value2);
	print("value1:", type(value1), value1);

	mstream:Seek(4);
	local value3 = bstream:ReadSingle();
	print("value3:", type(value3), value3);
end



--test_WriteByte();

--test_Int16();
--test_Int32();
test_Int64();
--test_Single();



	

