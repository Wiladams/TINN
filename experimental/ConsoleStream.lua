-- ConsoleFile.lua
local NativeFile = require("NativeFile")

local ConsoleStream = {}
setmetatable(ConsoleStream, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local ConsoleStream_mt = {
	__index = ConsoleStream;
}

ConsoleStream.init = function(self, ...)
	local obj = {
		Input = NativeFile("CONIN$", nil, OPEN_EXISTING, FILE_SHARE_READ);
		Output = NativeFile("CONOUT$", nil, OPEN_EXISTING, FILE_SHARE_WRITE);
	}
	setmetatable(obj, ConsoleStream_mt);

	return obj;
end

ConsoleStream.create = function(self, ...)
	return self:init(...);
end


ConsoleStream.readBytes = function(self, buff, len, offset)
	return self.Input:readBytes(buff, len, offset)
end


ConsoleStream.writeBytes = function(self, buff, len, offset)
	return self.Output:writeBytes(buff, len, offset)
end

ConsoleStream.writeString = function(self, astring)
	return self:writeBytes(astring, #astring, 0)
end


return ConsoleStream
