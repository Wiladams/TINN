
local ffi = require "ffi"

local IOProcessor = require("IOProcessor");
local StopWatch = require ("StopWatch")
local MemoryStream = require("MemoryStream");


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
	local socket, err = IOProcessor:createClientSocket(hostname, port, autoclose);

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
	print("IOCPNetStream:RefillReadingBuffer()");

	-- Use the buffer of the memory stream to
	-- read in a bunch of bytes
	local err
	local bytesread

	bytesread, err = self.Socket:receive(self.ReadingBuffer.Buffer, self.ReadingBuffer.Length)

	if not bytesread then
		return false, err;
	end

	-- if we already got bytes, then return them immediately
	print("-- LOADED BYTES: ", bytesread);

	if bytesread == 0 then
		return nil, "eof"
	end

	self.ReadingBuffer:Reset()
	self.ReadingBuffer.BytesWritten = bytesread

	return bytesread
end
--]]


--[[
	Read a byte.
	Return the single byte read, or nil
--]]
--[[
function IOCPNetStream:readByte()
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
	print("-- IOCPNetStream:readByte, ERROR: ", err)
	return false, err
end


--]]

-- The Bytes() function is an iterator on bytes
-- from the stream.  The iterator will return characters one
-- at a time up to maxbytes specified.  An error on the stream will 
-- terminate the iterator.

--[[
function IOCPNetStream:Bytes(maxbytes)
	maxbytes = maxbytes or math.huge
	local bytesleft = maxbytes

	--print("NetStream:Bytes() BYTES LEFT: ", bytesleft);

	local function f()
		--print("-- NetStream:Bytes(), REMAINING: ", bytesleft)
		-- if we've read the maximum number of bytes
		-- then just return nil to indicate finished
		if bytesleft == 0 then
			return
		end

		local abyte
		local err
		local res

		while (true) do
			-- try to read a byte
			-- if we're a blocking socket, we'll just wait
			-- here forever, or until a system specified timeout
			local abyte, err = self:ReadByte()

			-- The return of Socket:Read() is the number of
			-- bytes read if successful, nil on failure
			if abyte then
				bytesleft = bytesleft-1
				return abyte
			end

			-- If there was an error other than wouldblock
			-- then return that error immediately
			if err ~= WSAEWOULDBLOCK then
				bytesleft = 0
				--print("-- NetStream:Bytes ERROR: ", err)
				return nil, err
			end
		end
	end

	return f
end
--]]



function IOCPNetStream:readByte()
	local abyte
	local err
	local res

	self.ReadTimer:Reset();

	abyte, err = self.Socket:receive(self.rb_onebyte, 1)

	if not abyte then
		return false, err;
	end

	--print(abyte, err)
	if abyte == 0 then
		return false, "eof"
	end

	return self.rb_onebyte[0];
end

function IOCPNetStream:readBytes(buffer, len, offset)
--print("IOCPNetStream:readBytes: ", buffer, len, offset);
	offset = offset or 0

	-- Reset the stopwatch
	self.ReadTimer:Reset();

	local nleft = len;
	local nread = 0;
	local err
	local ptr = ffi.cast("uint8_t *",buffer+offset);

	while nleft > 0 do
		nread, err = self.Socket:receive(ptr, nleft);

		--print("IOCPNetStream.readBytes: ", nread, err)

		if not nread then
			--print("IOCPNetStream.readBytes, ERROR: ", nread, err)
			break;
		end

		if nread == 0 then
			break
		end

		nleft = nleft - nread;
		if nleft == 0 then
			break
		end

		ptr = ptr + nread;
	end

	local bytesread = len - nleft

	-- There are two cases where the number of bytes read 
	-- could == 0
	-- 1) We actually read 0 bytes, in which case an 'eof'
	--    is indicated.
	-- 2) There was an error while reading, so the actual
	--    error should be reported.
	if bytesread == 0 then
		if err then 
			return false, err;
		end

		return false, "eof"
	end

	return bytesread
end


function IOCPNetStream:readString(bufflen)
	bufflen = bufflen or 1500

--print("IOCPNetStream:ReadString: 1.0: ", bufflen);

	local buff = ffi.new("uint8_t[?]", bufflen);
	if not buff then
		return false, "out of memory"
	end

	local bytesread, err = self:readBytes(buff, bufflen, 0);

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

local function readOneLine(socket, buff, size)
--print("IOCPSocketIo.readOneLine()")
	local nchars = 0;
	local ptr = ffi.cast("uint8_t *", buff);
	local bytesread, err

	while nchars < size do
		bytesread, err = socket:receive(ptr, 1);
		--io.write(string.format("%02x",ptr[0]));

		if not bytesread then
			-- err is either "eof" or some other socket error
			break
		else
			if ptr[0] == 0 then
				break
			elseif ptr[0] == LF then
				--io.write("LF]\n")
				break
			elseif ptr[0] == CR then
				-- swallow it and continue on
				--io.write("[CR")
			else
				-- Just a regular character
				ptr = ptr + 1
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
	local bytesread, err = readOneLine(self.Socket, self.LineBuffer, size)

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
IOCPNetStream.WriteLine = IOCPNetStream.writeLine;

return IOCPNetStream;
