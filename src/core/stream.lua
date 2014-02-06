--[[
	Streaming interface to low level byte devices

--]]

local ffi = require("ffi")

local MemoryStream = require("MemoryStream");
local StreamOps = require("StreamOps")

local Stream = {}

setmetatable(Stream, {
	__call = function(self, ...)
		return self:create(...)
	end,
});

local Stream_mt = {
	__index = Stream;
}	

Stream.init = function(self, device)
	local obj = {
		Device = device;
		--DeviceOffset = 0;
		LineBuffer = ffi.new("uint8_t[1024]"),
		ReadingBuffer = MemoryStream(1500);
	}
	setmetatable(obj, Stream_mt);

	return obj;
end

Stream.create = function(self, ...)
	return self:init(...);
end

--[[
--]]
Stream.flush = function(self)
	return self.Device:flush();
end

--[[
	Reading
--]]
Stream.refillReadingBuffer = function(self)
	--print("Stream:RefillReadingBuffer(): ",self.ReadingBuffer:BytesReadyToBeRead());

	-- if the buffer already has data in it
	-- then just return the number of bytes that
	-- are currently ready to be read.
	if self.ReadingBuffer:BytesReadyToBeRead() > 0 then
		return self.ReadingBuffer:BytesReadyToBeRead();
	end

	-- If there are currently no bytes ready, then we need
	-- to refill the buffer from the source
	local err
	local bytesread

	bytesread, err = self.Device:readBytes(self.ReadingBuffer.Buffer, self.ReadingBuffer.Length,0)

	--print("-- LOADED BYTES: ", bytesread, err);

	if not bytesread then
		return false, err;
	end

	if bytesread == 0 then
		return false, "eof"
	end

	-- move the device position the relative amount
	--self.Device:seek(bytesread, StreamOps.SEEK_CUR);

	--self.DeviceOffset = self.DeviceOffset+bytesread;
	
	self.ReadingBuffer:Reset()
	self.ReadingBuffer.BytesWritten = bytesread

	return bytesread
end


function Stream.readByte(self)

	-- First see if we can get a byte out of the
	-- Reading buffer
	local abyte,err = self.ReadingBuffer:readByte()

	if abyte then
		return abyte
	end

	-- If we did not get a byte out of the reading buffer
	-- try refilling the buffer, and try again
	local bytesread, err = self:refillReadingBuffer()

	if bytesread then
		abyte, err = self.ReadingBuffer:ReadByte()
		return abyte, err
	end

	-- If there was an error
	-- then return that error immediately
	--print("-- IOCPNetStream:readByte, ERROR: ", err)
	return false, err
end


Stream.readBytes = function(self, buffer, len, offset)
	offset = offset or 0
--print("IOCPNetStream:readBytes: ", buffer, len, offset);

	-- Reset the stopwatch
	--self.ReadTimer:Reset();

	local nleft = len;
	local nread = 0;
	local err

	while nleft > 0 do
		local refilled, refillErr = self:refillReadingBuffer();

--print("BytesReady: ", refilled, refillErr)

		if not refilled then
			err = refillErr
			break;
		end

		-- try to fill bytes from existing buffer
		local maxbytes = math.min(nleft, refilled)
		nread, err = self.ReadingBuffer:readBytes(buffer, maxbytes, offset + len-nleft)

--print("IOCPNetStream:readBytes()loop: ", nread, err)

		nleft = nleft - nread;
	end

	local bytesread = len - nleft

	if bytesread > 0 then
		return bytesread
	end

	if bytesread == 0 then
		return false, "eof"
	end

	return false, err;
end

Stream.readString = function(self, bufflen)
	bufflen = bufflen or 1500

	local buff = ffi.new("uint8_t[?]", bufflen);
	if not buff then
		return false, "out of memory"
	end

	local bytesread, err = self:readBytes(buff, bufflen);

	if not bytesread then
		return false, err;
	end

	local str = ffi.string(buff, bytesread)

	return str;
end

--[[
	Read a single line terminated with one of:
	\r\n
	\n
--]]

local CR = string.byte("\r")
local LF = string.byte("\n")

Stream.readOneLine = function(self, buffer, size)
	local nchars = 0;
	local byteread
	local err

	while nchars < size do
		byteread, err = self:readByte();

		if not byteread then
			-- err is either "eof" or some other socket error
			break
		else
			if byteread == 0 then
				break
			elseif byteread == LF then
				--io.write("LF]\n")
				break
			elseif byteread == CR then
				-- swallow it and continue on
				--io.write("[CR")
			else
				-- Just a regular character, so save it
				buffer[nchars] = byteread
				nchars = nchars+1
			end
		end
	end

--print("END OF WHILE:", err, nchars)
	if err and err ~= "eof" then
		return nil, err
	end

	return nchars
end

Stream.readLine = function(self, size)
	size = size or 1024;

	if size > ffi.sizeof(self.LineBuffer) then
		self.LineBuffer = ffi.new("uint8_t[?]", size);
	end

	assert(self.LineBuffer, "out of memory");

	local bytesread, err = self:readOneLine(self.LineBuffer, size)

	if not bytesread then
		print("NS:ReadLine(), Error: ", err)
		return false, err
	end

	local str = ffi.string(self.LineBuffer, bytesread); 	

	return str;
end



--[[
	Writing
--]]
function Stream.writeByte(self, value)
	return self.Device:writeByte(value);
end

function Stream.writeBytes(self, buffer, len, offset)
	return self.Device:writeBytes(buffer, len, offset);
end

function Stream.writeString(self, str, count, offset)
	count = count or #str
	offset = offset or 0

	return  self:writeBytes(ffi.cast("const uint8_t *",str), count, offset)
end

function Stream.writeLine(self, line)
	local BytesWritten = 0;
	local err = nil;
	
	if line and #line > 0 then
		byteswritten, err = self:writeBytes(line, #line, 0)
	
		if err then
			return false, err
		end
	end

	local morebytes, err = self:writeBytes("\r\n", 2);

	if err then
		return false, err;
	end

	return byteswritten + morebytes;
end

function Stream.writeStream(self, stream, size)
	local count = 0
	local abyte = stream:readByte()
	while abyte and count < size do
		self:writeByte(abyte)
		count = count + 1
		abyte = stream:readByte()
	end

	return count
end


return Stream
