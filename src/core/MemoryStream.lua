
local ffi = require "ffi"
local StreamOps = require("StreamOps")

local MemoryStream = {}
setmetatable(MemoryStream, {
	__call = function(self, ...)
		return self:create(...);
	end,
})

local MemoryStream_mt = {
	__index = MemoryStream;
}

function MemoryStream.init(self, buff, bufflen, offset, byteswritten)
	if not buff then
		return nil, "no buffer specified"
	end

	bufflen = bufflen or 0
	offset = offset or 0
	byteswritten = byteswritten or 0

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

-- Parameters
--		size
-- OR
--		buff
--		bufflen
--		offset
--		byteswritten
function MemoryStream.create(self, ...)
	local nargs = select('#', ...);
	local buff = nil;
	local bufflen = 0;
	local offset = 0;
	local byteswritten = 0;

	if nargs == 1 and type(select(1,...)) == "number" then
		-- allocate a buffer of the given size
		bufflen = select(1,...)
		buff = ffi.new("uint8_t[?]", bufflen);
	else
		buff = ffi.cast("uint8_t *", select(1,...))
		if nargs >= 2 and type(select(2,...)) == "number" then
			bufflen = select(2,...);
			byteswritten = bufflen;

			if nargs >= 3 then
				offset = select(3,...);
			end
			if nargs >= 4 then
				byteswritten = select(4,...);
			end
		else
			bufflen = #select(1,...);
			byteswritten = bufflen;
		end
	end

	return self:init(buff, bufflen, offset, byteswritten);
end



function MemoryStream:reset()
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

function MemoryStream:seek(pos, origin)
	origin = origin or StreamOps.SEEK_SET

	if origin == StreamOps.SEEK_CUR then
		local newpos = self.Position + pos
		if newpos >= 0 and newpos < self.Length then
			self.Position = newpos
		end
	elseif origin == StreamOps.SEEK_SET then
		if pos >= 0 and pos < self.Length then
			self.Position = pos;
		end
	elseif origin == StreamOps.SEEK_END then
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
function MemoryStream:bytes(maxbytes)
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

function MemoryStream:readByte()
	local buffptr = ffi.cast("uint8_t *", self.Buffer);

	local pos = self.Position
	if pos < self.BytesWritten then
		self.Position = pos + 1
		return buffptr[pos];
	end

	return nil, "eof"
end

function MemoryStream:readBytes(buff, count, offset)
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

function MemoryStream:readString(count)
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

function MemoryStream:readLine(maxbytes)
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

function MemoryStream:writeByte(byte)
	-- don't write a nil value
	-- a nil is not the same as a '0'
	if not byte then 
		return false
	end

	local pos = self.Position
	if pos < self.Length then
		ffi.cast("uint8_t *", self.Buffer)[pos] = byte

		self.Position = pos + 1
		if self.Position > self.BytesWritten then
			self.BytesWritten = self.Position
		end

		return 1
	end

	return false
end

function MemoryStream:writeBytes(buff, count, offset)
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

function MemoryStream:writeString(str, count, offset)
	offset = offset or 0
	count = count or #str

	return self:WriteBytes(str, count, offset)
end

--[[
	Write the specified number of bytes from the current
	stream into the specified stream.

	Start from the current position in the current stream
--]]

function MemoryStream:writeStream(stream, size)
	local count = 0
	local abyte = stream:ReadByte()
	while abyte and count < size do
		self:WriteByte(abyte)
		count = count + 1
		abyte = stream:ReadByte()
	end

	return count
end

function MemoryStream:writeLine(line)
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



MemoryStream.Reset = MemoryStream.reset;
MemoryStream.Seek = MemoryStream.seek;

MemoryStream.Bytes = MemoryStream.bytes;

MemoryStream.ReadByte = MemoryStream.readByte;
MemoryStream.ReadBytes = MemoryStream.readBytes;
MemoryStream.ReadString = MemoryStream.readString;
MemoryStream.ReadLine = MemoryStream.readLine;

MemoryStream.WriteByte = MemoryStream.writeByte;
MemoryStream.WriteBytes = MemoryStream.writeBytes;
MemoryStream.WriteLine = MemoryStream.writeLine;
MemoryStream.WriteString = MemoryStream.writeString;
MemoryStream.WriteStream = MemoryStream.writeStream;

return MemoryStream;
