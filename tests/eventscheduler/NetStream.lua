
local ffi = require "ffi"
local Stream = require "stream"

local MemoryStream = require "MemoryStream"

local NativeSocket = require "NativeSocket"
local CoSocketIo = require("CoSocketIo");
local SocketUtils = require("SocketUtils")
local StopWatch = require ("StopWatch")

local strutils = require "stringzutils"


local NetStream = {}
local NetStream_mt = {
	__index = NetStream,
}


function NetStream.new(socket, iocore)
--	print("NEW NETSTREAM")
	iocore = iocore or CoSocketIo;

	if not socket then
		return nil
	end

	local obj = {
		Socket = socket,
		IoCore = iocore,
		CanSeek = false,

		ReadTimer = StopWatch(),
		ReadTimeout = nil,

		WriteTimer = StopWatch(),
		WriteTimeout = nil,

		rb_onebyte = ffi.new("uint8_t[1]"),
		wb_onebyte = ffi.new("uint8_t[1]"),
		LineBuffer = ffi.new("uint8_t[1024]"),
	}

	setmetatable(obj, NetStream_mt)

	return obj;
end

function NetStream.Open(hostname, port, iocore)
	local socket, err = SocketUtils.CreateTcpClientSocket(hostname, port)

	if not socket then
		return nil, err
	end

	return NetStream.new(socket, iocore)
end


function NetStream:IsConnected()
	return self.Socket:IsConnected();
end



--[[
	IsIdle()
	When called, this routine will compare the last
	read and write activity times.  If the time is beyond
	the respective timeout periods, then it will return 'true'.

	All other cases will return false.
--]]
function NetStream:IsIdle()
	--print("NetStream: IsIdle()");

	-- First condition of expiration
	-- both timeouts exist
	if self.ReadTimeout and self.WriteTimeout then
		if (self.ReadTimer:Seconds() > self.ReadTimeout) and
			(self.WriteTimer:Seconds() > self.WriteTimeout) then
			--print("NetStream:IsIdle: BOTH");
			return true;
		end
	elseif self.ReadTimeout then
		if (self.ReadTimer:Seconds() > self.ReadTimeout) then
			--print("NetStream:IsIdle: READ");
			return true;
		end
	elseif self.WriteTimeout then
		if (self.WriteTimer:Seconds() > self.WriteTimeout) then
			--print("NetStream:IsIdle: WRITE");
			return true;
		end
	end

	return false
end

function NetStream:ResetTimeout()
	self.ReadTimer:Reset();
	self.WriteTimer:Reset();
end



-- Set the timeout for inactivity
-- After the specified amount of time off
-- inactivity, timeout, and forcefully close the stream
function NetStream:SetIdleInterval(seconds)
	self:SetReadTimeout(seconds);
	self:SetWriteTimeout(seconds);
end

function NetStream:SetReadTimeout(seconds)
	self.ReadTimeout = seconds
end

function NetStream:SetWriteTimeout(seconds)
	self.WriteTimeout = seconds;
end


function NetStream:CloseDown()
	return self.Socket:CloseDown();
end

function NetStream:GetLength()
	return 0	-- or math.huge
end

function NetStream:GetPosition()
	return self.Consumed  -- or number of bytes consumed so far
end

function NetStream:SetNonBlocking(nonblocking)
	return self.Socket:SetNonBlocking(nonblocking)
end

--[[
	READING
--]]
function NetStream:CanReadWithoutBlocking()
	return self.Socket:CanReadWithoutBlocking();
end



--[[
function NetStream:RefillReadingBuffer()
	print("NetStream:RefillReadingBuffer()");

	-- Use the buffer of the memory stream to
	-- read in a bunch of bytes
	local err
	local bytesread

	repeat
		bytesread, err = self.Socket:Receive(self.ReadingBuffer.Buffer, self.ReadingBuffer.Length)

		-- if we already got bytes, then return them immediately
		if bytesread then
			print("-- LOADED BYTES: ", bytesread);

			if bytesread == 0 then
				return nil, "eof"
			end

			self.ReadingBuffer:Reset()
			self.ReadingBuffer.BytesWritten = bytesread
			return bytesread, nil
		end

		if err ~= WSAEWOULDBLOCK then
			print("-- NetStream:RefillReadingBuffer(), ERROR: ", err)
			return nil, err
		end

		print("REPEAT");
	until bytesread

	return bytesread
end
--]]

--[[
	Read a byte.
	Return the single byte read, or nil
--]]

function NetStream:ReadByte()
	local abyte
	local err
	local res

	self.ReadTimer:Reset();

	repeat
		abyte, err = self.Socket:Receive(self.rb_onebyte, 1)
		--print(abyte, err)
		if abyte then
			if abyte == 0 then
				return nil, "eof"
			end

			return self.rb_onebyte[0]
		end

		if err ~= WSAEWOULDBLOCK then
			print("-- NetStream:ReadByte() - Err: ", err);
			return nil, err
		end
	until abyte

	return abyte

--[[
	-- First see if we can get a byte out of the
	-- Reading buffer
	abyte,err = self.ReadingBuffer:ReadByte()

	if abyte then
		return abyte
	end

	repeat
		-- If we did not get a byte out of the reading buffer
		-- try refilling the buffer, and try again
		local bytesread, err = self:RefillReadingBuffer()

		if bytesread then
			abyte, err = self.ReadingBuffer:ReadByte()
			return abyte, err
		else
			-- If there was an error
			-- then return that error immediately
			print("-- NetStream:ReadByte, ERROR: ", err)
			return nil, err
		end
	until false
--]]
end




function NetStream:ReadBytes(buffer, len, offset)
	offset = offset or 0

	-- Reset the stopwatch
	self.ReadTimer:Reset();

	return self.IoCore.ReadN(self.Socket, buffer, len)
end


function NetStream:ReadString(bufflen)
	bufflen = bufflen or 8192

--print("NS:ReadString: 1.0: ", bufflen);

	local buff = ffi.new("uint8_t[?]", bufflen);
	if not buff then
		return nil, "out of memory"
	end

	self.ReadTimer:Reset();

--print("NS:ReadSring, 2.0: ");

	local bytesread, err = self.IoCore.ReadN(self.Socket, buff, bufflen);

--print("NS:ReadString, 3.0: ", bytesread, err);

	if bytesread and bytesread > 0 then
		return ffi.string(buff, bytesread)
	end

	return nil, err
end


function NetStream:ReadLine(size)
--print("NS:ReadLine()");

	if size > ffi.sizeof(self.LineBuffer) then
		self.LineBuffer = ffi.new("uint8_t[?]", size);
	end

	assert(self.LineBuffer, "out of memory");
--print("NS:ReadLine(), after assert")

	local bytesread, err = self.IoCore.ReadLine(self.Socket, self.LineBuffer, size)
--print("NS:ReadLine(), ReadLine: ", bytesread, err)

	self.ReadTimer:Reset();

	if not bytesread then
		print("NS:ReadLine(), Error: ", err)
		return nil, err
	end

	local str = ffi.string(self.LineBuffer, bytesread); 	
--print("NS:ReadLine(): ", bytesread, err, str)	
	return str;
end

--[[
	WRITING
--]]

function NetStream:CanWrite()
	return self.Socket:CanWriteWithoutBlocking();
end

function NetStream:WriteByte(value)
	self.wb_onebyte[0] = value;
	local byteswritten, err = self.IoCore.WriteN(self.Socket, self.wb_onebyte, 1);

	self.WriteTimer:Reset();

	return byteswritten, err
end

function NetStream:WriteBytes(buffer, len, offset)
	len = len or 0
	offset = offset or 0
	local ptr = buffer;

	if type(buffer) == "string" then
		ptr = ffi.cast("const uint8_t *", buffer)
		len = len or #buffer
	end

	local byteswritten, err = self.IoCore.WriteN(self.Socket, ptr, len)

	-- reset the write timer
	self.WriteTimer:Reset();

	return byteswritten, err
end

function NetStream:WriteString(str, count, offset)
	count = count or #str
	offset = offset or 0

	return  self:WriteBytes(ffi.cast("const uint8_t *",str), count, offset)
end


function NetStream:WriteLine(line)

	local status, err
	if line then
		status, err = self:WriteBytes(line, #line, 0)
		if err then
			return nil, err
		end
	end

	status, err = self:WriteBytes("\r\n", 2, 0);

	return status, err
end

function NetStream:WriteStream(stream, size)
	local count = 0
	local abyte = stream:ReadByte()
	while abyte and count < size do
		self:WriteByte(abyte)
		count = count + 1
		abyte = stream:ReadByte()
	end

	return count
end

return NetStream;
