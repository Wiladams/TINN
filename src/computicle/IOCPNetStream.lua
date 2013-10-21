
local ffi = require "ffi"

local StopWatch = require ("StopWatch")
local MemoryStream = require("MemoryStream");
local IOCPSocket = require("IOCPSocket");


local IOCPNetStream = {}
setmetatable(IOCPNetStream, {
	__call = function(self, ...)
		return self:create(...);
	end,
});
local IOCPNetStream_mt = {
	__index = IOCPNetStream,
}


function IOCPNetStream:init(socket)
--	print("IOCPNetStream.init")

	if not socket then
		return nil
	end

	local obj = {
		Socket = socket,
		CanSeek = false,

		ReadTimer = StopWatch(),
		ReadTimeout = nil,

		WriteTimer = StopWatch(),
		WriteTimeout = nil,

		rb_onebyte = ffi.new("uint8_t[1]"),
		wb_onebyte = ffi.new("uint8_t[1]"),
		LineBuffer = ffi.new("uint8_t[1024]"),

		ReadingBuffer = MemoryStream(1500);
	}

	setmetatable(obj, IOCPNetStream_mt)

	return obj;
end

function IOCPNetStream.create(self, hostname, port, autoclose)
	local socket, err = IOCPSocket:createClient(hostname, port);

	if not socket then
		return nil, err
	end

	return self:init(socket)
end


function IOCPNetStream:isConnected()
	return self.Socket:isConnected();
end



--[[
	IsIdle()
	When called, this routine will compare the last
	read and write activity times.  If the time is beyond
	the respective timeout periods, then it will return 'true'.

	All other cases will return false.
--]]
function IOCPNetStream:isIdle()
	--print("IOCPNetStream: IsIdle()");

	-- First condition of expiration
	-- both timeouts exist
	if self.ReadTimeout and self.WriteTimeout then
		if (self.ReadTimer:Seconds() > self.ReadTimeout) and
			(self.WriteTimer:Seconds() > self.WriteTimeout) then
			--print("IOCPNetStream:IsIdle: BOTH");
			return true;
		end
	elseif self.ReadTimeout then
		if (self.ReadTimer:Seconds() > self.ReadTimeout) then
			--print("IOCPNetStream:IsIdle: READ");
			return true;
		end
	elseif self.WriteTimeout then
		if (self.WriteTimer:Seconds() > self.WriteTimeout) then
			--print("IOCPNetStream:IsIdle: WRITE");
			return true;
		end
	end

	return false
end

function IOCPNetStream:resetTimeout()
	self.ReadTimer:Reset();
	self.WriteTimer:Reset();
end



-- Set the timeout for inactivity
-- After the specified amount of time off
-- inactivity, timeout, and forcefully close the stream
function IOCPNetStream:setIdleInterval(seconds)
	self:SetReadTimeout(seconds);
	self:SetWriteTimeout(seconds);
end

function IOCPNetStream:setReadTimeout(seconds)
	self.ReadTimeout = seconds
end

function IOCPNetStream:setWriteTimeout(seconds)
	self.WriteTimeout = seconds;
end


function IOCPNetStream:closeDown()
	return self.Socket:closeDown();
end

function IOCPNetStream:getLength()
	return 0	-- or math.huge
end

function IOCPNetStream:getPosition()
	return self.Consumed  -- or number of bytes consumed so far
end

function IOCPNetStream:setNonBlocking(nonblocking)
	return self.Socket:setNonBlocking(nonblocking)
end

--[[
	READING
--]]


function IOCPNetStream:refillReadingBuffer()
	--print("IOCPNetStream:RefillReadingBuffer(): ",self.ReadingBuffer:BytesReadyToBeRead());

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

	bytesread, err = self.Socket:receive(self.ReadingBuffer.Buffer, self.ReadingBuffer.Length)

	--print("-- LOADED BYTES: ", bytesread, err);

	if not bytesread then
		return false, err;
	end

	if bytesread == 0 then
		return false, "eof"
	end

	self.ReadingBuffer:Reset()
	self.ReadingBuffer.BytesWritten = bytesread

	return bytesread
end


--[[
	Read a byte.
	Return the single byte read, or nil
--]]

function IOCPNetStream:readByte()
	self.ReadTimer:Reset();

	-- First see if we can get a byte out of the
	-- Reading buffer
	local abyte,err = self.ReadingBuffer:ReadByte()

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


function IOCPNetStream:readBytes(buffer, len, offset)
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


function IOCPNetStream:readString(bufflen)
	bufflen = bufflen or 1500

--print("IOCPNetStream:ReadString: 1.0: ", bufflen);

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

function IOCPNetStream:readOneLine(buffer, size)
	local nchars = 0;
	local ptr = ffi.cast("uint8_t *", buff);
	local bytesread
	local byteread
	local err

	while nchars < size do
		byteread, err = self:readByte();
		--bytesread, err = self.Socket:receive(ptr, 1);
		--io.write(string.format("%02x",ptr[0]));

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
				--ptr = ptr + 1
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

function IOCPNetStream:readLine(size)
	size = size or 1024;

	if size > ffi.sizeof(self.LineBuffer) then
		self.LineBuffer = ffi.new("uint8_t[?]", size);
	end

	assert(self.LineBuffer, "out of memory");

	--local bytesread, err = self.Socket:receive(self.LineBuffer, size);
	local bytesread, err = self:readOneLine(self.LineBuffer, size)

--	self.ReadTimer:Reset();

	if not bytesread then
		print("NS:ReadLine(), Error: ", err)
		return false, err
	end

	local str = ffi.string(self.LineBuffer, bytesread); 	

--print(string.format("NS:ReadLine(), END[%d]: %s", self.Socket:getNativeSocket(),str));	

	return str;
end



--[[
	WRITING
--]]

function IOCPNetStream:canWrite()
	return self.Socket:canWriteWithoutBlocking();
end

function IOCPNetStream:writeByte(value)
	self.wb_onebyte[0] = value;
	local byteswritten, err = self.Socket:send(self.wb_onebyte, 1);

	self.WriteTimer:Reset();

	return byteswritten, err
end

function IOCPNetStream:writeBytes(buffer, len, offset)
	len = len or #buffer
	offset = offset or 0
	local ptr = ffi.cast("const uint8_t *", buffer)+offset;


	local nleft = len;
	local nwritten = 0;
	local err

	while nleft > 0 do
		nwritten, err = self.Socket:send(ptr, nleft)

--print("WriteN, send, err: ", nwritten, err);
		if not nwritten then
			break;
		end

		nleft = nleft - nwritten

		if nwritten == 0 then
			break
		end
					
		ptr = ptr + nwritten;
	end

	local byteswritten =  len-nleft

	-- reset the write timer
	self.WriteTimer:Reset();

	return byteswritten, err
end

function IOCPNetStream:writeString(str, count, offset)
	count = count or #str
	offset = offset or 0

	return  self:writeBytes(ffi.cast("const uint8_t *",str), count, offset)
end


function IOCPNetStream:writeLine(line)
	local BytesWritten = 0;
	local err = nil;
	
	if line and #line > 0 then
		byteswritten, err = self:writeBytes(line, #line, 0)
	
		if err then
			return false, err
		end
	end

	local morebytes, err = self:writeBytes("\r\n", 2, 0);

	if err then
		return false, err;
	end

	return byteswritten + morebytes;
end


function IOCPNetStream:writeStream(stream, size)
	local count = 0
	local abyte = stream:readByte()
	while abyte and count < size do
		self:writeByte(abyte)
		count = count + 1
		abyte = stream:readByte()
	end

	return count
end

IOCPNetStream.ReadByte = IOCPNetStream.readByte;
IOCPNetStream.ReadBytes = IOCPNetStream.readBytes;
IOCPNetStream.ReadLine = IOCPNetStream.readLine;
IOCPNetStream.ReadString = IOCPNetStream.readString;
IOCPNetStream.WriteBytes = IOCPNetStream.writeBytes;
IOCPNetStream.WriteLine = IOCPNetStream.writeLine;

return IOCPNetStream;
