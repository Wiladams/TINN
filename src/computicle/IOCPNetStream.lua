
local ffi = require "ffi"
--local Stream = require "stream"

local IOProcessor = require("IOProcessor");
local IOCPSocketIo = require("IOCPSocketIo");
local StopWatch = require ("StopWatch")



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
		IoCore = IOCPSocketIo,
		CanSeek = false,

		ReadTimer = StopWatch(),
		ReadTimeout = nil,

		WriteTimer = StopWatch(),
		WriteTimeout = nil,

		rb_onebyte = ffi.new("uint8_t[1]"),
		wb_onebyte = ffi.new("uint8_t[1]"),
		LineBuffer = ffi.new("uint8_t[1024]"),
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
function IOCPNetStream:CanReadWithoutBlocking()
	return self.Socket:canReadWithoutBlocking();
end



--[[
	Read a byte.
	Return the single byte read, or nil
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

	return self.IoCore.ReadN(self.Socket, buffer, len);
end


function IOCPNetStream:readString(bufflen)
	bufflen = bufflen or 8192

--print("NS:ReadString: 1.0: ", bufflen);

	local buff = ffi.new("uint8_t[?]", bufflen);
	if not buff then
		return nil, "out of memory"
	end

	self.ReadTimer:Reset();

--print("NS:ReadSring, 2.0: ");

	local bytesread, err = self.IoCore.ReadN(self.Socket, buff, bufflen);

	if not bytesread then
		return false, err;
	end

--print("NS:ReadString, 3.0: ", bytesread, err);

	local str = ffi.string(buff, bytesread)

--print("NS:readString(): ", str);

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
--print("IOCPSocketIo.ReadLine()")
	local nchars = 0;
	local ptr = ffi.cast("uint8_t *", buff);
	local bytesread, err

	while nchars < size do
		bytesread, err = socket:receive(ptr, 1);
		
		if not bytesread then
			-- err is either "eof" or some other socket error
			break
		else
			if ptr[0] == LF then
				--io.write("LF]\n")
				break
			elseif ptr[0] == CR then
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

--print("NS:ReadLine()");

	if size > ffi.sizeof(self.LineBuffer) then
		self.LineBuffer = ffi.new("uint8_t[?]", size);
	end

	assert(self.LineBuffer, "out of memory");
--print("NS:ReadLine(), after assert")

	--local bytesread, err = self.Socket:receive(self.LineBuffer, size);
	local bytesread, err = readOneLine(self.Socket, self.LineBuffer, size)

--print("NS:ReadLine(), ReadLine: ", bytesread, err)

--	self.ReadTimer:Reset();

--print("AFTER Reset()");

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

function IOCPNetStream:writeString(str, count, offset)
	count = count or #str
	offset = offset or 0

	return  self:writeBytes(ffi.cast("const uint8_t *",str), count, offset)
end


function IOCPNetStream:writeLine(line)

	local status, err
	if line then
		status, err = self:writeBytes(line, #line, 0)
		if err then
			return nil, err
		end
	end

	status, err = self:writeBytes("\r\n", 2, 0);

	return status, err
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
