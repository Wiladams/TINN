
local ffi = require "ffi"
local StreamOps = require("StreamOps")

local FileStream = {}
setmetatable(FileStream, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local FileStream_mt = {
	__index = FileStream,
}

FileStream.init = function(self, handle)
	local obj = {
		FileHandle = handle,
		}

	setmetatable(obj, FileStream_mt)

	return obj;
end

FileStream.create = function(self, filename, mode)
	if not filename then
		return self:init(io.stdout)
	end

	mode = mode or "wb+"
	local handle = io.open(filename, mode)

	if not handle then return nil end

	return self:init(handle)
end


--[[
	Core Stream functions
--]]
function FileStream:close()
	self.FileHandle:close();
end

function FileStream:GetLength()
	local currpos = self.FileHandle:seek()
	local size = self.FileHandle:seek("end")

	self.FileHandle:seek("set",currpos)

	return size;
end

function FileStream:GetPosition()
	local currpos = self.FileHandle:seek()
	return currpos;
end

function FileStream:seek(offset, origin)
	offset = offset or 0
	origin = origin or StreamOps.SEEK_SET

	if origin == StreamOps.SEEK_CUR then
		return self.FileHandle:seek("cur", offset)
	elseif origin == StreamOps.SEEK_SET then
		return self.FileHandle:seek("set", offset)
	elseif origin == StreamOps.SEEK_END then
		return self.FileHandle:seek("end", offset)
	end

	return nil
end

function FileStream:readByte()
	local str = self.FileHandle:read(1)
	if not str then return str end

	return string.byte(str);
end

function FileStream:readBytes(buffer, len, offset)
	offset = offset or 0
	local str = self.FileHandle:read(len)
	local maxbytes = math.min(len, #str)
	ffi.copy(buffer+offset, str, maxbytes)

	return maxbytes
end

function FileStream:readString(count)
	local str = self.FileHandle:read(count)

	return str
end



function FileStream:writeByte(value)
	self.FileHandle:write(string.char(value))
	return 1
end

function FileStream:writeBytes(buffer, len, offset)
	offset = offset or 0

	if type(buffer) == "string" then
		self.FileHandle:write(buffer)
		return #buffer
	end

	-- assume we have a pointer to a buffer
	-- convert to string and write it out
	local str = ffi.string(buffer, len)
	self.FileHandle:write(str)

	return len
end

function FileStream:writeString(str, count, offset)
	if type(str) == "string" or type(str) == "number" then
		self.FileHandle:write(str);
		return #str
	end

	offset = offset or 0
	count = count or ffi.sizeof(str)
	local strptr = ffi.cast("uint8_t *", str);

	return self:WriteBytes(strptr, count, offset)
end

function FileStream:writeLine(line)
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



FileStream.Close = FileStream.close;
FileStream.Seek = FileStream.seek;

FileStream.ReadByte = FileStream.readByte;
FileStream.ReadBytes = FileStream.readBytes;
FileStream.ReadString = FileStream.readString;

FileStream.WriteString = FileStream.writeString;
FileStream.WriteLine = FileStream.writeLine;
FileStream.WriteByte = FileStream.writeByte;
FileStream.WriteBytes = FileStream.writeBytes;
FileStream.Open = FileStream.create

return FileStream;
