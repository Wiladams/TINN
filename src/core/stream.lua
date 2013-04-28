--[[
	Abstract interface for a stream object

	-- Attributes of the stream
	function Stream:GetLength()
	end

	function Stream:GetPosition()
	end

	function Stream:Seek(offset, origin)
	end

	-- Reading interface
	function Stream:Bytes()
		return function()
			return nil
		end
	end

	function Stream:ReadByte()
		return nil;
	end

	function Stream:ReadBytes(buffer, len, offset)
		return 0
	end

	function Stream:ReadString(count)
		return nil
	end


	-- Writing interface
	function Stream:WriteByte(value)
		return 0
	end

	function Stream:WriteBytes(buffer, len, offset)
		return 0
	end

	function Stream:WriteString(str, count, offset)
		offset = offset or 0
		count = count or #str

		return self:WriteBytes(str, count, offset)
	end

	function Stream:WriteStream(stream, count)
	end

	-- Copying
	function Stream:CopyTo(stream)
	end
--]]



local STREAM_SEEK_SET = 0	-- from beginning
local STREAM_SEEK_CUR = 1	-- from current position
local STREAM_SEEK_END = 2	-- from end

-- Read characters from a stream until the specified
-- ending is found, or until the stream runs out of bytes

local function ReadLine(stream, maxbytes)
	if not stream then
		return nil
	end

	maxbytes = maxbytes or 1024
--print(string.format("-- ReadLine(), maxbytes: 0x%x", maxbytes));

	local chartable = {}
	local CR = string.byte("\r")
	local LF = string.byte("\n")


	-- use the stream's byte iterator
	local haveCR = false
	for abyte in stream:Bytes(maxbytes) do
		if abyte == CR then
			haveCR = true
		elseif abyte == LF then
			break
		else
			table.insert(chartable, string.char(abyte))
		end
	end

	local str = table.concat(chartable)

	return str
end


local function WriteToStream(inputstream, outputstream, size)
	local size = size or math.huge
	local count = 0
	local abyte = inputstream:ReadByte()
	while abyte and count < size-1 do
	--print("WriteToStream(), first byte: ", abyte, count);
		outputstream:WriteByte(abyte)
		count = count + 1
		abyte = inputstream:ReadByte()
	end

	return count
end


return {
	SEEK_SET = STREAM_SEEK_SET,
	SEEK_CUR = STREAM_SEEK_CUR,
	SEEK_END = STREAM_SEEK_END,

	ReadLine = ReadLine,
	WriteToStream = WriteToStream,
}
