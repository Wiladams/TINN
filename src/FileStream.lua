
local ffi = require "ffi"
local stream = require "stream"


local FileStream = {}
local FileStream_mt = {
	__index = FileStream,
}

function FileStream.new(handle)
	handle = handle or io.stdout
	--if not handle then return nil end

	local obj = {
		FileHandle = handle,
		}

	setmetatable(obj, FileStream_mt)

	return obj;
end


function FileStream.Open(filename, mode)
	if not filename then return nil end

	mode = mode or "wb+"
	local handle = io.open(filename, mode)

	if not handle then return nil end

	return FileStream.new(handle)
end


function FileStream:Close()
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

function FileStream:Seek(offset, origin)
	offset = offset or 0
	origin = origin or stream.SEEK_SET

	if origin == stream.SEEK_CUR then
		return self.FileHandle:seek("cur", offset)
	elseif origin == stream.SEEK_SET then
		return self.FileHandle:seek("set", offset)
	elseif origin == stream.SEEK_END then
		return self.FileHandle:seek("end", offset)
	end

	return nil
end

function FileStream:ReadByte()
	local str = self.FileHandle:read(1)
	if not str then return str end

	return string.byte(str);
end

function FileStream:ReadBytes(buffer, len, offset)
	offset = offset or 0
	local str = self.FileHandle:read(len)
	local maxbytes = math.min(len, #str)
	ffi.copy(buffer+offset, str, maxbytes)

	return maxbytes
end

function FileStream:ReadString(count)
	local str = self.FileHandle:read(count)

--[[
	if str then
		print("FileStream:ReadString: ", #str)
	else
		print("FileStream:ReadString: ", str)
	end
--]]
	return str
end



function FileStream:WriteByte(value)
	self.FileHandle:write(string.char(value))
	return 1
end

function FileStream:WriteBytes(buffer, len, offset)
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

function FileStream:WriteString(str, count, offset)
	if type(str) == "string" or type(str) == "number" then
		self.FileHandle:write(str);
		return #str
	end

	offset = offset or 0
	count = count or ffi.sizeof(str)
	local strptr = ffi.cast("uint8_t *", str);

	return self:WriteBytes(strptr, count, offset)
end

function FileStream:WriteLine(line)
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

return FileStream;
