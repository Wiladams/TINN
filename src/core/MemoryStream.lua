
local ffi = require "ffi"
local stream = require "stream"


local MemoryStream = {}
local MemoryStream_mt = {
	__index = MemoryStream;
}

function MemoryStream.new(size, buff, byteswritten)
	size = size or 8192
	byteswritten = byteswritten or 0
	buff = buff or ffi.new("uint8_t[?]", size)

	return MemoryStream.Open(buff, size, byteswritten)
end

function MemoryStream.Open(buff, bufflen, byteswritten)
	if not buff then return nil end


	offset = offset or 0
	--byteswritten = byteswritten or 0

	if not bufflen then
		if type(buff) == "string" then
			bufflen = #buff
		elseif type(buff) == "ctype" then
			bufflen = ffi.sizeof(buff)
		end
	end

	byteswritten = byteswritten or bufflen;

	local obj = {
		Length = bufflen,
		Buffer = buff,
		Offset = offset,
		Position = 0,
		BytesWritten = byteswritten,
		}

	setmetatable(obj, MemoryStream_mt)

	return obj
end

function MemoryStream:Reset()
	self.Offset = 0
	self.Position = 0
	self.BytesWritten = 0
end

function MemoryStream:GetLength()
	return self.Length
end

function MemoryStream:GetPosition()
	return self.Position
end

function MemoryStream:GetRemaining()
	return self.Length - self.Position
end

function MemoryStream:BytesReadyToBeRead()
	return self.BytesWritten - self.Position
end

function MemoryStream:CanRead()
	return self:BytesReadyToBeRead() > 0
end

function MemoryStream:Seek(pos, origin)
	origin = origin or stream.SEEK_SET

	if origin == stream.SEEK_CUR then
		local newpos = self.Position + pos
		if newpos >= 0 and newpos < self.Length then
			self.Position = newpos
		end
	elseif origin == stream.SEEK_SET then
		if pos >= 0 and pos < self.Length then
			self.Position = pos;
		end
	elseif origin == stream.SEEK_END then
		local newpos = self.Length-1 + pos
		if newpos >= 0 and newpos < self.Length then
			self.Position = newpos
		end
	end

	return self.Position
end

--[[
	Reading interface
--]]
-- The Bytes() function acts as an iterator on bytes
-- from the stream.
function MemoryStream:Bytes(maxbytes)
	local bytesleft = maxbytes or math.huge
	local pos = -1

	local function closure()
		--print("-- REMAINING: ", bytesleft)
		-- if we've read the maximum nuber of bytes
		-- then just return nil to indicate finished
		if bytesleft == 0 then return end

		pos = pos + 1

		-- We've reached the end of the stream
		if pos >= self.Position then
			return nil
		end
		bytesleft = bytesleft - 1

		return self.Buffer[pos]
	end

	return closure
end

function MemoryStream:ReadByte()
	local buffptr = ffi.cast("uint8_t *", self.Buffer);

	local pos = self.Position
	if pos < self.BytesWritten then
		self.Position = pos + 1
		return buffptr[pos];
	end

	return nil, "eof"
end

function MemoryStream:ReadBytes(buff, count, offset)
	offset = offset or 0

	local pos = self.Position
	local remaining = self:GetRemaining()
	local src = ffi.cast("const uint8_t *", self.Buffer)+pos
	local dst = ffi.cast("uint8_t *", buff)+offset

	local maxbytes = math.min(count, remaining)
	if maxbytes < 1 then
		return nil, "eof"
	end

	ffi.copy(dst, src, maxbytes)

	self.Position = pos + maxbytes

	return maxbytes
end

function MemoryStream:ReadString(count)
	local pos = self.Position
	local remaining = self.Length - pos

	local maxbytes = math.min(count, remaining)
	if maxbytes < 1 then return nil end


	local src = ffi.cast("const uint8_t *", self.Buffer)+pos

	self.Position = pos + maxbytes

	return ffi.string(src, maxbytes)
end

-- Read characters from a stream until the specified
-- ending is found, or until the stream runs out of bytes
local CR = string.byte("\r")
local LF = string.byte("\n")

function MemoryStream:ReadLine(maxbytes)
--print("-- MemoryStream:ReadLine()");

	local readytoberead = self:BytesReadyToBeRead()

	maxbytes = maxbytes or readytoberead

	local maxlen = math.min(maxbytes, readytoberead)
	local buffptr = ffi.cast("uint8_t *", self.Buffer);

	local nchars = 0;
	local bytesconsumed = 0;
	local startptr = buffptr + self.Position
	local abyte
	local err

--print("-- MemoryStream:ReadLine(), maxlen: ", maxlen);

	for n=1, maxlen do
		abyte, err = self:ReadByte()
--io.write(string.char(abyte))
		if not abyte then
			break
		end

		bytesconsumed = bytesconsumed + 1

		if abyte == LF then
			break
		elseif abyte ~= CR then
			nchars = nchars+1
		end
	end

	-- End of File, nothing consumed
	if bytesconsumed == 0 then
		return nil, "eof"
	end

	-- A blank line
	if nchars == 0 then
		return ''
	end

	-- an actual line of data
	return ffi.string(startptr, nchars);
end

--[[
	Writing interface
--]]

function MemoryStream:WriteByte(byte)
	-- don't write a nil value
	-- a nil is not the same as a '0'
	if not byte then return end

	local pos = self.Position
	if pos < self.Length-1 then
		(ffi.cast("uint8_t *", self.Buffer)+pos)[0] = byte

		self.Position = pos + 1
		if self.Position > self.BytesWritten then
			self.BytesWritten = self.Position
		end

		return 1
	end

	return false
end

function MemoryStream:WriteBytes(buff, count, offset)
	count = count or #buff;
	offset = offset or 0;
	local pos = self.Position;
	local size = self.Length;
	local remaining = size - pos;
	local maxbytes = math.min(remaining, count);

	if maxbytes <= 0
		then return 0
	end

	local dst = ffi.cast("uint8_t *", self.Buffer)+pos
	local src = ffi.cast("const uint8_t *", buff)+offset

	ffi.copy(dst, src, maxbytes);


	self.Position = pos + maxbytes;
	if self.Position > self.BytesWritten then
		self.BytesWritten = self.Position
	end

	return maxbytes;
end

function MemoryStream:WriteString(str, count, offset)
	offset = offset or 0
	count = count or #str

	--print("-- MemoryStream:WriteString():", str);

	return self:WriteBytes(str, count, offset)
end

--[[
	Write the specified number of bytes from the current
	stream into the specified stream.

	Start from the current position in the current stream
--]]

function MemoryStream:WriteStream(stream, size)
	local count = 0
	local abyte = stream:ReadByte()
	while abyte and count < size do
		self:WriteByte(abyte)
		count = count + 1
		abyte = stream:ReadByte()
	end

	return count
end

function MemoryStream:WriteLine(line)
	local status, err

	if line then
		status, err = self:WriteString(line)
		if err then
			return nil, err
		end
	end

	-- write the terminator
	status, err = self:WriteString("\r\n");

	return status, err
end

--[[
	Moving big chunks around
--]]

function MemoryStream:CopyTo(stream)
	-- copy from the beginning
	-- to the current position
	local remaining = self.BytesWritten
	local byteswritten = 0

	while (byteswritten < remaining) do
		byteswritten = byteswritten + stream:WriteBytes(self.Buffer, self.Position, byteswritten)
	end
end



--[[
	Utility
--]]
function MemoryStream:ToString()
	local len = self.Position

	if len > 0 then
		--print("Buffer: ", self.Buffer, len);
		local str = ffi.string(self.Buffer, len)
		return str;
	end

	return nil
end

return MemoryStream;
