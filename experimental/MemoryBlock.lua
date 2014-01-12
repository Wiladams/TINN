
local ffi = require "ffi"
local StreamOps = require("StreamOps")

local MemoryBlock = {}
setmetatable(MemoryBlock, {
	__call = function(self, ...)
		return self:create(...);
	end,
})

local MemoryBlock_mt = {
	__index = MemoryBlock;
}

function MemoryBlock.init(self, buff, bufflen, offset, byteswritten)
	if not buff then
		return nil, "no buffer specified"
	end

	bufflen = bufflen or 0
	offset = offset or 0
	byteswritten = byteswritten or 0

	local obj = {
		Length = bufflen,
		Buffer = buff,
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
function MemoryBlock.create(self, ...)
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
		buff = ffi.cast("unit8_t *", select(1,...))
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


function MemoryBlock.cancel = function(self)
	return true;
end

function MemoryBlock.canseek = function(self)
	return true;
end

function MemoryBlock:reset()
	self.Offset = 0
	self.Position = 0
	self.BytesWritten = 0
end

function MemoryBlock:GetLength()
	return self.Length
end

function MemoryBlock:GetPosition()
	return self.Position
end

function MemoryBlock:GetRemaining()
	return self.Length - self.Position
end

function MemoryBlock:BytesReadyToBeRead()
	return self.BytesWritten - self.Position
end


function MemoryBlock:seek(pos, origin)
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

function MemoryBlock:readBytes(buff, count, offset)
	offset = offset or 0

	local pos = self.Position
	local remaining = self:GetRemaining()
	local maxbytes = math.min(count, remaining)
	
	if maxbytes < 1 then
		return nil, "eof"
	end

	local src = ffi.cast("const uint8_t *", self.Buffer)+pos
	local dst = ffi.cast("uint8_t *", buff)+offset


	ffi.copy(dst, src, maxbytes)

	return maxbytes
end



--[[
	Writing interface
--]]
function MemoryBlock:writeBytes(buff, count, offset)
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


--	self.Position = pos + maxbytes;
--	if self.Position > self.BytesWritten then
--		self.BytesWritten = self.Position
--	end

	return maxbytes;
end



return MemoryBlock;
